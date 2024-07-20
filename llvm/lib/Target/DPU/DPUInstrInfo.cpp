//===-- DPUInstrInfo.cpp - DPU Instruction Information --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the DPU implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "DPUInstrInfo.h"
#include "DPUTargetMachine.h"

#include "llvm/CodeGen/LiveVariables.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/StackMaps.h"

//#define GET_INSTRINFO_NAMED_OPS // For getNamedOperandIdx() function
#define GET_INSTRINFO_CTOR_DTOR
#define GET_INSTRINFO_ENUM

#include "DPUGenInstrInfo.inc"

#define GET_REGINFO_ENUM

#include "DPUCondCodes.h"
#include "DPUGenRegisterInfo.inc"
#include "DPUISelLowering.h"
#include "MCTargetDesc/DPUAsmCondition.h"

#define DEBUG_TYPE "asm-printer"

using namespace llvm;

// Specify here that ADJCALLSTACKDOWN/UP are respectively the CF setup/destroy
// opcodes. That way (see PrologEpilogInserter::replaceFrameIndices) we give an
// opportunity to adjust the stack pointer upon function call, via
// DPUFrameLowering::eliminateCallFramePseudoInstr.
DPUInstrInfo::DPUInstrInfo(DPUSubtarget &ST)
  : DPUGenInstrInfo(DPU::ADJCALLSTACKDOWN, DPU::ADJCALLSTACKUP), RI(),
    Subtarget(ST) {}

void DPUInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       Register SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI) const {
  DebugLoc DL = (I != MBB.end()) ? I->getDebugLoc() : DebugLoc();
  unsigned Opcode = (RC == &DPU::GP_REGRegClass
		     // || RC == &DPU::GPZ_REGRegClass
		     ) ? DPU::SWrir : DPU::SDrir;

  LLVM_DEBUG({
    dbgs() << "DPU/Instr - storeRegToStackSlot DestReg="
           << std::to_string(SrcReg) << " Opcode= " << std::to_string(Opcode)
           << " BB=\n";
    MBB.dump();
    dbgs() << "!!!! FI = " << std::to_string(FI) << "\n";
  });

  // At this level, we COULD generate a STORErm directly with the frame
  // register, as given by the static method DPURegisterInfo::getFrameRegister
  // However, the generated instruction should go through eliminateFrameIndex
  // then, so we can inject FI.
  BuildMI(MBB, I, DL, get(Opcode))
      .addFrameIndex(FI)
      .addImm(0)
      .addReg(SrcReg, getKillRegState(IsKill))
      .setMIFlag(MachineInstr::MIFlag::FrameSetup);
}

void DPUInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator I,
                                        Register DestReg, int FI,
                                        const TargetRegisterClass *RC,
                                        const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();
  unsigned Opcode = (RC == &DPU::GP_REGRegClass
		     // || RC == &DPU::GPZ_REGRegClass
		     ) ? DPU::LWrri : DPU::LDrri;
  LLVM_DEBUG({
    dbgs() << "DPU/Instr - loadRegFromStackSlot DestReg="
           << std::to_string(DestReg) << " Opcode= " << std::to_string(Opcode)
           << " BB=\n";
    MBB.dump();
    dbgs() << "!!!! FI = " << std::to_string(FI) << "\n";
  });

  BuildMI(MBB, I, DL, get(Opcode), DestReg).addFrameIndex(FI).addImm(0);
}

bool DPUInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  MachineBasicBlock &MBB = *MI.getParent();
  MachineFunction *MF = MBB.getParent();
  MachineFrameInfo &MFI = MF->getFrameInfo();

  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "instruction to expand: "; MI.dump();
      dbgs() << "** MBB: "; MBB.dump();
      dbgs() << "****** \n";
    });
  switch (MI.getDesc().getOpcode()) {
  default:
    LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "Don't know how to expand.\n";
      });
    return false;
  case DPU::RETi:
    BuildMI(MBB, MI, MI.getDebugLoc(), get(DPU::JUMPr)).addReg(DPU::R23);
    break;
  case DPU::CALLi:
    BuildMI(MBB, MI, MI.getDebugLoc(), get(DPU::CALLri), DPU::R23)
        .add(MI.getOperand(0))
        .copyImplicitOps(MI);
    break;
  case DPU::CALLr:
    BuildMI(MBB, MI, MI.getDebugLoc(), get(DPU::CALLrr), DPU::R23)
        .add(MI.getOperand(0))
        .copyImplicitOps(MI);
    break;
  case DPU::ADD_VAStart: { // Get the first index in stack where the first
                           // vaargs is stored
    unsigned int StackSize = 0;
    if (MFI.hasCalls()) {
      StackSize = MF->getFrameInfo().getStackSize();
    }
    unsigned int ResultReg = MI.getOperand(0).getReg();
    BuildMI(MBB, MI, MI.getDebugLoc(), get(DPU::SUBrrif), ResultReg)
        .addReg(DPU::R22)
        .addImm(StackSize + STACK_SIZE_FOR_D22)
        .addImm(DPUAsmCondition::Condition::False);
    break;
  }

  // case DPU::Jcci:
  // case DPU::TmpJcci:
  // case DPU::Jcc: {
  //   // don't expand yet as they are used for late optimization
  //   // these late optimization should be reworked and placed earlier in the pipeline
  //   // so we could treat more cases of optim
  //   break;
  // }
  }

  MBB.erase(MI);

  LLVM_DEBUG({
      dbgs() << "** MBB: "; MBB.dump();
    });
  return true;
}

void DPUInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator I,
                               const DebugLoc &DL, MCRegister DestReg,
                               MCRegister SrcReg, bool KillSrc) const {
  if (DPU::GP_REGRegClass.contains(DestReg) &&
      DPU::OP_REGRegClass.contains(SrcReg)) {
    LLVM_DEBUG(dbgs() << "DPU/Instr - copyPhysReg from src=" << SrcReg
                      << " kill= " << KillSrc << " to dest=" << DestReg
                      << "\n");
    BuildMI(MBB, I, DL, get(DPU::MOVErr), DestReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
  } else if (DPU::GP64_REGRegClass.contains(DestReg, SrcReg)) {
    LLVM_DEBUG(dbgs() << "DPU/Instr - copyPhysReg from src=" << SrcReg
                      << " kill= " << KillSrc << " to dest=" << DestReg
                      << "\n");
    BuildMI(MBB, I, DL, get(DPU::MOVDrr), DestReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
  } else if (DPU::GP64_REGRegClass.contains(SrcReg) &&
             DPU::GP_REGRegClass.contains(DestReg)) {
    // Truncating 64 bits to 32... There's a macro for that.
    LLVM_DEBUG(dbgs() << "DPU/Instr - copyPhysReg from src=" << SrcReg
                      << " kill= " << KillSrc << " to dest=" << DestReg
                      << "\n");
    BuildMI(MBB, I, DL, get(DPU::EXTRACT_SUBREG), DestReg)
        .addReg(SrcReg, getKillRegState(KillSrc))
        .addImm(DPU::sub_32bit);
  } else if (DPU::GP_REGRegClass.contains(SrcReg) &&
             DPU::GP64_REGRegClass.contains(DestReg)) {
    // Expanding 32 bits to 64... There's an instruction for that.
    LLVM_DEBUG(dbgs() << "DPU/Instr - copyPhysReg from src=" << SrcReg
                      << " kill= " << KillSrc << " to dest=" << DestReg
                      << "\n");
    BuildMI(MBB, I, DL, get(DPU::MOVE_Srr), DestReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
  } else {
    llvm_unreachable("Impossible reg-to-reg copy");
  }
}

static bool reverseBranchOpc(unsigned Opc, unsigned &ReversedOpc) {
  switch (Opc) {
  default:
    return false;
  case DPU::JEQrii:
    ReversedOpc = DPU::JNEQrii;
    break;
  case DPU::JEQrri:
    ReversedOpc = DPU::JNEQrri;
    break;
  case DPU::JNEQrii:
    ReversedOpc = DPU::JEQrii;
    break;
  case DPU::JNEQrri:
    ReversedOpc = DPU::JNEQrri;
    break;
  case DPU::JZri:
    ReversedOpc = DPU::JNZri;
    break;
  case DPU::JNZri:
    ReversedOpc = DPU::JZri;
    break;
  case DPU::JLTUrii:
    ReversedOpc = DPU::JGEUrii;
    break;
  case DPU::JLTUrri:
    ReversedOpc = DPU::JGEUrri;
    break;
  case DPU::JGEUrii:
    ReversedOpc = DPU::JLTUrii;
    break;
  case DPU::JGEUrri:
    ReversedOpc = DPU::JLTUrri;
    break;
  case DPU::JLEUrii:
    ReversedOpc = DPU::JGTUrii;
    break;
  case DPU::JLEUrri:
    ReversedOpc = DPU::JGTUrri;
    break;
  case DPU::JGTUrii:
    ReversedOpc = DPU::JLEUrii;
    break;
  case DPU::JGTUrri:
    ReversedOpc = DPU::JLEUrri;
    break;
  case DPU::JLTSrii:
    ReversedOpc = DPU::JGESrii;
    break;
  case DPU::JLTSrri:
    ReversedOpc = DPU::JGESrri;
    break;
  case DPU::JGESrii:
    ReversedOpc = DPU::JLTSrii;
    break;
  case DPU::JGESrri:
    ReversedOpc = DPU::JLTSrri;
    break;
  case DPU::JLESrii:
    ReversedOpc = DPU::JGTSrii;
    break;
  case DPU::JLESrri:
    ReversedOpc = DPU::JGTSrri;
    break;
  case DPU::JGTSrii:
    ReversedOpc = DPU::JLESrii;
    break;
  case DPU::JGTSrri:
    ReversedOpc = DPU::JLESrri;
    break;
  }

  return true;
}

bool DPUInstrInfo::reverseBranchCondition(
    SmallVectorImpl<MachineOperand> &Cond) const {
  unsigned Opc = Cond[0].getImm();

  switch (Opc) {
  case DPU::Jcc:
  case DPU::Jcci:
  case DPU::Jcc64:
    Cond[1].setImm(ISD::getSetCCInverse(ISD::CondCode(Cond[1].getImm()), MVT::i32));
    break;
  default: {
    unsigned ReversedOpc;
    if (!reverseBranchOpc(Opc, ReversedOpc)) {
      return true;
    }
    Cond[0].setImm(ReversedOpc);
    break;
  }
  }

  return false;
}

static void
fetchUnconditionalBranchInfo(MachineInstr *Inst,
                             unsigned &targetBasicBlockOperandIndex) {
  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "Inst "; Inst->dump();
    });

  switch (Inst->getOpcode()) {
  case DPU::JUMPi:
    targetBasicBlockOperandIndex = 0;
    break;
  default:
    assert(false && "invalid opcode for unconditional branch");
  }
}

static void fetchConditionalBranchInfo(MachineInstr *Inst,
                                       unsigned &targetBasicBlockOperandIndex,
                                       SmallVectorImpl<MachineOperand> &Cond) {
  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "Inst "; Inst->dump();
      for (unsigned i = 0; i < Cond.size(); ++i) {
	dbgs() << "Cond[" << i << "] "; Cond[i].dump();
      }
    });
  
  unsigned Opc = Inst->getOpcode();
  Cond.push_back(MachineOperand::CreateImm(Opc));

  unsigned int NumOp = Inst->getNumExplicitOperands();

  for (unsigned int eachOperandIndex = 0; eachOperandIndex < NumOp;
       eachOperandIndex++) {
    MachineOperand &operand = Inst->getOperand(eachOperandIndex);
    if (operand.isMBB()) {
      targetBasicBlockOperandIndex = eachOperandIndex;
    } else {
      Cond.push_back(operand);
    }
  }

  for (const MachineOperand &Op : Inst->operands()) {
    if (Op.isMetadata() && Op.getMetadata()->getOperand(0).get() == MDString::get(Inst->getMF()->getFunction().getContext(), "MySpecialMetadata")) {
      Cond.push_back(Op);
    }
  }
  
  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "Inst "; Inst->dump();
      for (unsigned i = 0; i < Cond.size(); ++i) {
	dbgs() << "Cond[" << i << "] "; Cond[i].dump();
      }
    });
}

static inline bool isAnalyzableBranch(MachineInstr *Inst) {
  return Inst->isBranch() && !Inst->isIndirectBranch();
}

bool DPUInstrInfo::analyzeBranch(MachineBasicBlock &MBB,
                                 MachineBasicBlock *&TBB,
                                 MachineBasicBlock *&FBB,
                                 SmallVectorImpl<MachineOperand> &Cond,
                                 bool AllowModify) const {

  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "MBB "; MBB.dump();
      for (unsigned i = 0; i < Cond.size(); ++i) {
	dbgs() << "Cond[" << i << "] "; Cond[i].dump();
      }
    });
  
  MachineBasicBlock::reverse_iterator I = MBB.rbegin(), REnd = MBB.rend();

  // Skip all the debug instructions.
  while (I != REnd && I->isDebugValue()) {
    ++I;
  }

  // If this block ends with no branches (it just falls through to its succ),
  // Leave TBB/FBB null.
  if (I == REnd || !isUnpredicatedTerminator(*I)) {
    TBB = FBB = nullptr;
    return false;
  }

  MachineInstr *LastInst = &*I;
  MachineInstr *SecondLastInst = nullptr;

  // If not an analyzable branch (e.g., indirect jump), just leave.
  if (!isAnalyzableBranch(LastInst)) {
    return true;
  }

  if (++I != REnd) {
    SecondLastInst = &*I;
    if (!isUnpredicatedTerminator(*SecondLastInst) ||
        !isAnalyzableBranch(SecondLastInst)) {
      // If not a branch, reset to nullptr.
      SecondLastInst = nullptr;
    }
  }

  // If there is only one terminator instruction, process it.
  if (SecondLastInst == nullptr) {
    // Unconditional branch.
    if (LastInst->isUnconditionalBranch()) {
      unsigned int TBBOpIdx;
      fetchUnconditionalBranchInfo(LastInst, TBBOpIdx);
      FBB = nullptr;

      // Delete the Branch if it's equivalent to a fall-through.
      if (AllowModify &&
          MBB.isLayoutSuccessor(LastInst->getOperand(TBBOpIdx).getMBB())) {
        TBB = nullptr;
        LastInst->eraseFromParent();
        return false;
      }

      TBB = LastInst->getOperand(TBBOpIdx).getMBB();
      return false;
    }

    // Conditional branch
    if (LastInst->isConditionalBranch()) {
      unsigned int TBBOpIdx;
      fetchConditionalBranchInfo(LastInst, TBBOpIdx, Cond);
      LLVM_DEBUG({
	  dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	  dbgs() << "MBB "; MBB.dump();
	  for (unsigned i = 0; i < Cond.size(); ++i) {
	    dbgs() << "Cond[" << i << "] "; Cond[i].dump();
	  }
	});
      TBB = LastInst->getOperand(TBBOpIdx).getMBB();
      return false;
    }

    // Unknown branch type
    return true;
  }

  // If we reached here, there are two branches.
  // If there are three terminators, we don't know what sort of block this is.
  if (++I != REnd && isUnpredicatedTerminator(*I)) {
    return true;
  }

  // If second to last instruction is an unconditional branch,
  // analyze it and remove the last instruction.
  if (SecondLastInst->isUnconditionalBranch()) {
    // Return if the last instruction cannot be removed.
    if (!AllowModify) {
      return true;
    }
    unsigned int TBBOpIdx;
    fetchUnconditionalBranchInfo(SecondLastInst, TBBOpIdx);

    TBB = SecondLastInst->getOperand(TBBOpIdx).getMBB();
    LastInst->eraseFromParent();
    return false;
  }

  if (SecondLastInst->isConditionalBranch()) {
    // Conditional branch followed by an unconditional branch.
    // The last one must be unconditional.
    if (!LastInst->isUnconditionalBranch()) {
      return true;
    }
    unsigned int TBBOpIdx;
    unsigned int FTBBOpIdx;

    fetchUnconditionalBranchInfo(LastInst, FTBBOpIdx);
    fetchConditionalBranchInfo(SecondLastInst, TBBOpIdx, Cond);
    TBB = SecondLastInst->getOperand(TBBOpIdx).getMBB();
    FBB = LastInst->getOperand(FTBBOpIdx).getMBB();
    LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "MBB "; MBB.dump();
	for (unsigned i = 0; i < Cond.size(); ++i) {
	  dbgs() << "Cond[" << i << "] "; Cond[i].dump();
	}
      });
    return false;
  }

  // Unknown branch type
  return true;
}

unsigned DPUInstrInfo::removeBranch(MachineBasicBlock &MBB,
                                    int *BytesRemoved) const {
  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "MBB "; MBB.dump();
    });
  MachineBasicBlock::iterator I = MBB.end();
  unsigned Count = 0;

  while (I != MBB.begin()) {
    --I;
    if (I->isDebugValue())
      continue;
    if (!I->isBranch())
      break;
    // Remove the branch.
    I->eraseFromParent();
    I = MBB.end();
    ++Count;
  }

  // DPU instruction size is constant, meaning that bytes removed is equivalent
  // to instructions removed
  if (BytesRemoved)
    *BytesRemoved = Count;
  return Count;
}

void DPUInstrInfo::buildConditionalBranch(MachineBasicBlock &MBB,
                                          MachineBasicBlock *TBB, DebugLoc DL,
                                          ArrayRef<MachineOperand> Cond) const {
  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "MBB "; MBB.dump();
      for (unsigned i = 0; i < Cond.size(); ++i) {
	  dbgs() << "Cond[" << i << "] "; Cond[i].dump();
      }
    });

  // LLVM_DEBUG({
  //     dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
  //     dbgs() << "DPU::sub_32bit " << DPU::sub_32bit << "\n";
  //     dbgs() << "DPU::sub_32bit_hi " << DPU::sub_32bit_hi << "\n";
  //     for (unsigned i = 0; i < Cond.size(); ++i) {
  // 	dbgs() << "Cond[" << i << "] = "; Cond[i].dump();
  // 	if (Cond[i].isReg()) {
  // 	  dbgs() << "is Reg\n";
  // 	  dbgs() << Cond[i].getReg() << "\n";
  // 	  dbgs() << Cond[i].getSubReg() << "\n";

  // 	  dbgs() << "contains " << DPU::GP64_REGRegClass.contains(Cond[i].getReg()) << "\n";
  // 	}
  //     }
  //   });

  MachineInstrBuilder MIB;

  unsigned Opc = Cond[0].getImm();

  MIB = BuildMI(&MBB, DL, get(Opc));

  for (unsigned i = 1; i < Cond.size(); ++i) {
    if (Cond[i].isReg()) {
      // The register in question could potentially be a
      // subreg hi/lo of a 64-bit vreg
      if (unsigned SubReg = Cond[i].getSubReg()) {
	MIB.addReg(Cond[i].getReg(), 0, SubReg);
      } else {
	MIB.addReg(Cond[i].getReg());
      }
    } else if (Cond[i].isImm()) {
      MIB.addImm(Cond[i].getImm());
    } else if (Cond[i].isMetadata()) {
      // MIB.addMetadata(Cond[i].getMetadata());
    } else {
      assert(false && "Cannot copy operand");
    }
  }

  MIB.addMBB(TBB);

  // add back remaining metadata
  for (unsigned i = 0; i < Cond.size(); ++i) {
     if (Cond[i].isMetadata()) {
      MIB.addMetadata(Cond[i].getMetadata());
     }
  }
  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "MIB "; MIB->dump();
    });
}

unsigned DPUInstrInfo::insertBranch(MachineBasicBlock &MBB,
                                    MachineBasicBlock *TBB,
                                    MachineBasicBlock *FBB,
                                    ArrayRef<MachineOperand> Cond,
                                    const DebugLoc &DL, int *BytesAdded) const {
  LLVM_DEBUG({
      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
      dbgs() << "MBB "; MBB.dump();
      for (unsigned i = 0; i < Cond.size(); ++i) {
	dbgs() << "Cond[" << i << "] "; Cond[i].dump();
      }
    });
  unsigned nrOfInsertedMachineInstr = 0;
  // Shouldn't be a fall through.
  assert(TBB && "InsertBranch must not be told to insert a fallthrough");

  // Unconditional branch
  if (Cond.empty()) {
    // Be sure that this is a valid unconditional branch
    assert(!FBB && "Unconditional branch with multiple successors!");
    BuildMI(&MBB, DL, get(DPU::JUMPi)).addMBB(TBB);
    nrOfInsertedMachineInstr++;
  } else {
    // Conditional branch
    buildConditionalBranch(MBB, TBB, DL, Cond);
    nrOfInsertedMachineInstr++;

    if (FBB) {
      BuildMI(&MBB, DL, get(DPU::JUMPi)).addMBB(FBB);
      nrOfInsertedMachineInstr++;
    }
  }

  // DPU instruction size is constant, implying that bytes added is equivalent
  // to instructions added.
  if (BytesAdded)
    *BytesAdded = nrOfInsertedMachineInstr;
  return nrOfInsertedMachineInstr;
}

bool DPUInstrInfo::shouldSink(const MachineInstr &MI) const {
  switch (MI.getDesc().getOpcode()) {
  default:
    break;
  case DPU::CLZ_Urr:
  case DPU::LSLXrrr:
  case DPU::LSRXrrr:
  case DPU::ANDrri:
  case DPU::JEQrii:
  case DPU::JNEQrii:
    {
      //   return false;
      for (const MachineOperand &Op : MI.operands()) {
	if (Op.isMetadata() && Op.getMetadata()->getOperand(0).get() == MDString::get(MI.getMF()->getFunction().getContext(), "MySpecialMetadata")) {
	  LLVM_DEBUG({
	      dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << " Don't sink because I have MySpecialMetadata.\n";
	    });
	  return false; // Do not sink this instruction
	}
      }
      LLVM_DEBUG({
	  dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << " I'm potentially something used in arith+cond+jump from EmitInstrWithCustomInserter but I allow sink because I don't have MySpecialMetadata.\n";
	});
      break;
    }
  }

  // return true;
  return TargetInstrInfo::shouldSink(MI);
}
