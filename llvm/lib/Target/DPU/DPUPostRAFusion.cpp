#include "DPUTargetMachine.h"
#include "DPU.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include <llvm/CodeGen/MachineInstrBuilder.h>

#define GET_INSTRINFO_ENUM

#include "DPUCondCodes.h"
#include "DPUGenInstrInfo.inc"
#include "DPUISelLowering.h"
#include "MCTargetDesc/DPUAsmCondition.h"

#define GET_REGINFO_ENUM
#include "DPUGenRegisterInfo.inc"

#define DEBUG_TYPE "dpu-postra-fusion"

using namespace llvm;

namespace {
class DPUPostRAFusionPass : public MachineFunctionPass {
public:
  static char ID;

  explicit DPUPostRAFusionPass(DPUTargetMachine &tm)
      : MachineFunctionPass(ID), TM(tm) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  llvm::StringRef getPassName() const override {
    return "DPU PostRA Fussion";
  }

private:
  const DPUTargetMachine &TM;
};

char DPUPostRAFusionPass::ID = 0;
} // namespace

FunctionPass *llvm::createDPUPostRAFusionPass(DPUTargetMachine &tm) {
  return new DPUPostRAFusionPass(tm);
}

static MachineInstr *
getLastNonDebugInstrFrom(MachineBasicBlock::reverse_iterator &I,
                         MachineBasicBlock::reverse_iterator REnd) {
  // Skip all the debug instructions.
  while (I != REnd &&
         (I->isDebugValue() || I->getOpcode() == TargetOpcode::DBG_VALUE)) {
    ++I;
  }
  if (I == REnd) {
    return NULL;
  }
  return &*I;
}

static bool do_have_special_metadata(MachineInstr *MI) {
  for (const MachineOperand &Op : MI->operands()) {
    if (Op.isMetadata() && Op.getMetadata()->getOperand(0).get() == MDString::get(MI->getMF()->getFunction().getContext(), "MySpecialMetadata")) {
      return true;
    }
  }

  return false;
}

static bool runOnMachineBB(MachineBasicBlock *MBB,
			   const DPUInstrInfo &InstrInfo) {
  MachineBasicBlock::reverse_iterator I = MBB->rbegin(), REnd = MBB->rend();
  MachineInstr *LastInst, *SecondLastInst;
  unsigned int LastOpc, SecondLastOpc;

  // LLVMContext &Context = MBB->getParent()->getFunction().getContext();
  // MDNode *N = MDNode::get(Context, MDString::get(Context, "MySpecialMetadata"));

  LastInst = getLastNonDebugInstrFrom(I, REnd);
  if (LastInst == NULL) {
    // LLVM_DEBUG(dbgs() << "KO: I == REnd\n");
    return false;
  }
  I++;
  SecondLastInst = getLastNonDebugInstrFrom(I, REnd);
  if (SecondLastInst == NULL) {
    // LLVM_DEBUG(dbgs() << "KO: I++ == REnd\n");
    return false;
  }

  if (!do_have_special_metadata(LastInst)
      || !do_have_special_metadata(SecondLastInst))
    return false;
  
  LastOpc = LastInst->getOpcode();
  SecondLastOpc = SecondLastInst->getOpcode();

  // attempt to merge lslx/lsrx and XX 32 jeq XX 32 instructions
  // TODO: check if it's shift32 as well?
  //       or maybe use other metadata?
  //         but this is to be extra careful, or for the next player in the game ... :)
  // though, here I apply only when with my metadata
  //   but if I actually not test my metadata, maybe
  //     and add JNEQrii, I could pop both
  //     and why not tackle other possible optim that may have introduce this code
  //        event from user maybe
  // original code is JEQrii, but JNEQrii could be introduce by analyzeBranch
  if ((LastOpc == DPU::JEQrii || LastOpc == DPU::JNEQrii) 
      && SecondLastOpc == DPU::ANDrri) {
    I++;
    MachineInstr *ThirdLastInst = getLastNonDebugInstrFrom(I, REnd);
    if (ThirdLastInst == NULL) {
      // LLVM_DEBUG(dbgs() << "KO: I++ == REnd\n");
      return false;
    }
    if (!do_have_special_metadata(ThirdLastInst))
      return false;
    
    unsigned int ThirdLastOpc = ThirdLastInst->getOpcode();
    if ((ThirdLastOpc == DPU::LSLXrrr || ThirdLastOpc == DPU::LSRXrrr)) {

      LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "before change: \n";
	dbgs() << "** MBB "; MBB->dump();
      });

      unsigned int new_opcode = (ThirdLastOpc == DPU::LSLXrrr ?
				 DPU::LSLXrrrci : DPU::LSRXrrrci);
      MachineInstrBuilder ComboInst = BuildMI(MBB, ThirdLastInst->getDebugLoc(),
					      InstrInfo.get(new_opcode));
      ComboInst.add(ThirdLastInst->getOperand(0));
      ComboInst.add(ThirdLastInst->getOperand(1));
      ComboInst.add(ThirdLastInst->getOperand(2));
      ComboInst.addImm(DPUAsmCondition::Condition::Shift32);
      ComboInst.addMBB(LastInst->getOperand(2).getMBB());
      // ComboInst.addMetadata(N); now that we merge, we don't need to prohibe sink
      
      LLVM_DEBUG({
	  dbgs() << "OK\n";
	  dbgs() << "del "; ThirdLastInst->dump();
	  dbgs() << "del "; SecondLastInst->dump();
	  dbgs() << "del "; LastInst->dump();
	  dbgs() << "fused to\n";
	  dbgs() << "add "; ComboInst->dump();
	});

      LastInst->eraseFromParent();
      SecondLastInst->eraseFromParent();
      ThirdLastInst->eraseFromParent();
      LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "after change: \n";
	dbgs() << "** MBB "; MBB->dump();
      });
      return true;
    }
  }

  // attempt to optimize MUL_UL_ULrrr + comp res 256 + branch
  // original code is JLTUrii, but JGEUrii could be introduce by analyzeBranch
  if ((LastOpc == DPU::JLTUrii || LastOpc == DPU::JGEUrii)
      && SecondLastOpc == DPU::MUL_UL_ULrrr) {

    LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "before change: \n";
	dbgs() << "** MBB "; MBB->dump();
      });
      
    MachineInstrBuilder ComboInst = BuildMI(MBB, SecondLastInst->getDebugLoc(),
					    InstrInfo.get(DPU::MUL_UL_ULrrrci));
    ComboInst.add(SecondLastInst->getOperand(0));
    ComboInst.add(SecondLastInst->getOperand(1));
    ComboInst.add(SecondLastInst->getOperand(2));
    ComboInst.addImm(DPUAsmCondition::Small);
    ComboInst.add(LastInst->getOperand(2));
    // ComboInst.addMetadata(N); now that we merge, we don't need to prohibe sink
    
    LLVM_DEBUG({
	dbgs() << "OK\n";
	dbgs() << "del "; SecondLastInst->dump();
	dbgs() << "del "; LastInst->dump();
	dbgs() << "fused to\n";
	dbgs() << "add "; ComboInst->dump();
      });
    LastInst->eraseFromParent();
    SecondLastInst->eraseFromParent();

    LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "after change: \n";
	dbgs() << "** MBB "; MBB->dump();
      });

    return true;
  }

  // original code is JNEQrii, but JEQrii could be introduce by analyzeBranch
  if ((LastOpc == DPU::JNEQrii || LastOpc == DPU::JEQrii)
      && SecondLastOpc == DPU::CLZ_Urr) {

    LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "before change: \n";
	dbgs() << "** MBB "; MBB->dump();
      });

    MachineInstrBuilder ComboInst = BuildMI(MBB, SecondLastInst->getDebugLoc(),
					    InstrInfo.get(DPU::CLZ_Urrci));
    ComboInst.add(SecondLastInst->getOperand(0));
    ComboInst.add(SecondLastInst->getOperand(1));
    ComboInst.addImm((LastOpc == DPU::JNEQrii) ?
		     DPUAsmCondition::Condition::NotMaximum : DPUAsmCondition::Condition::Maximum);
    ComboInst.add(LastInst->getOperand(2));
    // ComboInst.addMetadata(N); now that we merge, we don't need to prohibe sink

    LLVM_DEBUG({
	dbgs() << "OK\n";
	dbgs() << "del "; SecondLastInst->dump();
	dbgs() << "del "; LastInst->dump();
	dbgs() << "fused to\n";
	dbgs() << "add "; ComboInst->dump();
      });
    
    LastInst->eraseFromParent();
    SecondLastInst->eraseFromParent();

    LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "after change: \n";
	dbgs() << "** MBB "; MBB->dump();
      });

    return true;
  }

  return false;
}

bool DPUPostRAFusionPass::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "********** DPU/DPUPostRAFusionPass: " << MF.getName()
                    << " **********\n\n");

  auto &SubTarget = static_cast<const DPUSubtarget &>(MF.getSubtarget());
  auto &InstrInfo = *SubTarget.getInstrInfo();
  bool changeMade = false;

  for (auto &MFI : MF) {
    MachineBasicBlock *MBB = &MFI;
    changeMade |= runOnMachineBB(MBB, InstrInfo);
  }

  LLVM_DEBUG(dbgs() << "********** DPU/DPUPostRAFusionPass: " << MF.getName()
                    << " done: changeMade = " << changeMade << " **********\n\n");
  return changeMade;
}
