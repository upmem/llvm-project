#include "DPU.h"
#include "DPUHelper.h"
#include "DPUTargetMachine.h"

#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

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
  const DPUInstrInfo *TII;
  static char ID;

  explicit DPUPostRAFusionPass(DPUTargetMachine &TM)
      : MachineFunctionPass(ID), TM(TM) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  llvm::StringRef getPassName() const override {
    return "DPU PostRA Fussion";
  }

private:
  const DPUTargetMachine &TM;
  bool runOnMachineBB(MachineBasicBlock &MBB);
};

char DPUPostRAFusionPass::ID = 0;
} // namespace

FunctionPass *llvm::createDPUPostRAFusionPass(DPUTargetMachine &TM) {
  return new DPUPostRAFusionPass(TM);
}

bool DPUPostRAFusionPass::runOnMachineBB(MachineBasicBlock &MBB) {
  MachineBasicBlock::reverse_iterator I = MBB.rbegin(), REnd = MBB.rend();
  MachineInstr *LastInst, *SecondLastInst;
  unsigned int LastOpc, SecondLastOpc;

  LastInst = getLastNonDebugInstrFrom(I, REnd);
  if (LastInst == NULL) {
    return false;
  }
  I++;
  SecondLastInst = getLastNonDebugInstrFrom(I, REnd);
  if (SecondLastInst == NULL) {
    return false;
  }

  LastOpc = LastInst->getOpcode();
  SecondLastOpc = SecondLastInst->getOpcode();

  if (!hasPostRAFusionMetadata(LastInst)
      || !hasPostRAFusionMetadata(SecondLastInst)) {
    return false;
  }

  DebugLoc DL = SecondLastInst->getDebugLoc();

  // attempt to merge lsl/r variant; and XX 32; jeq XX 32; instructions
  // that has a special metadata
  // TODO: implement more generic situation without the metadata
  // TODO: split-critical-edge could break BB and reverse cond+branch
  if ((LastOpc == DPU::JEQrii // || LastOpc == DPU::JNEQrii
       )
      && SecondLastOpc == DPU::ANDrri) {
    I++;
    MachineInstr *ThirdLastInst = getLastNonDebugInstrFrom(I, REnd);
    if (ThirdLastInst == NULL) {
      // LLVM_DEBUG(dbgs() << "KO: I++ == REnd\n");
      return false;
    }

    if (!hasPostRAFusionMetadata(ThirdLastInst)) {
      // This should not happen AFAIK, but I don't know everything yet ...
      return false;
    }

    unsigned int ThirdLastOpc = ThirdLastInst->getOpcode();
    if (ThirdLastOpc == DPU::LSLXrrr || ThirdLastOpc == DPU::LSRXrrr
	|| ThirdLastOpc == DPU::LSLrrr || ThirdLastOpc == DPU::LSRrrr) {

      LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "before change: \n";
	dbgs() << "** MBB "; MBB.dump();
      });

      unsigned int NewOpcode;

      switch (ThirdLastOpc) {
      default:
	report_fatal_error("This should not happen. Please report to UPMEM.");
	break;

      case DPU::LSLXrrr:
	NewOpcode = DPU::LSLXrrrci;
	break;

      case DPU::LSRXrrr:
	NewOpcode = DPU::LSRXrrrci;
	break;

      case DPU::LSLrrr:
	NewOpcode = DPU::LSLrrrci;
	break;

      case DPU::LSRrrr:
	NewOpcode = DPU::LSRrrrci;
	break;
      }

      MachineInstrBuilder ComboInst = BuildMI(&MBB, ThirdLastInst->getDebugLoc(),
					      TII->get(NewOpcode),
					      ThirdLastInst->getOperand(0).getReg());
      ComboInst.add(ThirdLastInst->getOperand(1));
      ComboInst.add(ThirdLastInst->getOperand(2));
      ComboInst.addImm(DPUAsmCondition::Condition::Shift32);
      ComboInst.addMBB(LastInst->getOperand(2).getMBB());
      // ComboInst.addMetadata(N);

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
	dbgs() << "** MBB "; MBB.dump();
      });
      return true;
    }
  }

  // attempt to optimize MUL_UL_ULrrr + comp res 256 + branch
  // original code is JLTUrii, but JGEUrii could be introduce by analyzeBranch
  // if ((LastOpc == DPU::JLTUrii || LastOpc == DPU::JGEUrii)
  //     && SecondLastOpc == DPU::MUL_UL_ULrrr) {

  //   LLVM_DEBUG({
  // 	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
  // 	dbgs() << "before change: \n";
  // 	dbgs() << "** MBB "; MBB->dump();
  //     });

  //   MachineInstrBuilder ComboInst = BuildMI(MBB, SecondLastInst->getDebugLoc(),
  // 					    InstrInfo.get(DPU::MUL_UL_ULrrrci),
  // 					    SecondLastInst->getOperand(0).getReg());
  //   ComboInst.add(SecondLastInst->getOperand(1));
  //   ComboInst.add(SecondLastInst->getOperand(1));
  //   ComboInst.addImm(DPUAsmCondition::Small);
  //   ComboInst.addMBB(LastInst->getOperand(2).getMBB());
  //   // ComboInst.addMetadata(N);

  //   LLVM_DEBUG({
  // 	dbgs() << "OK\n";
  // 	dbgs() << "del "; SecondLastInst->dump();
  // 	dbgs() << "del "; LastInst->dump();
  // 	dbgs() << "fused to\n";
  // 	dbgs() << "add "; ComboInst->dump();
  //     });
  //   LastInst->eraseFromParent();
  //   SecondLastInst->eraseFromParent();

  //   LLVM_DEBUG({
  // 	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
  // 	dbgs() << "after change: \n";
  // 	dbgs() << "** MBB "; MBB->dump();
  //     });

  //   return true;
  // }

  // the original code is JNEQrii, but it is possible that split-critical-edge breaks
  //   the BB and reverse cond+branch
  if ((LastOpc == DPU::JNEQrii || LastOpc == DPU::JEQrii)
      && SecondLastOpc == DPU::CLZ_Urr) {

    LLVM_DEBUG({
	dbgs() << __FILE__ << " " << __LINE__ << " " << __func__ << "\n";
	dbgs() << "before change: \n";
	dbgs() << "** MBB "; MBB.dump();
      });

    MachineInstrBuilder ComboInst = BuildMI(&MBB, DL, TII->get(DPU::CLZ_Urrci),
					    SecondLastInst->getOperand(0).getReg());
    ComboInst.add(SecondLastInst->getOperand(1));
    ComboInst.addImm((LastOpc == DPU::JNEQrii) ?
		     DPUAsmCondition::Condition::NotMaximum : DPUAsmCondition::Condition::Maximum);
    ComboInst.addMBB(LastInst->getOperand(2).getMBB());
    // ComboInst.addMetadata(N);

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
	dbgs() << "** MBB "; MBB.dump();
      });

    return true;
  }

  return false;
}

bool DPUPostRAFusionPass::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "********** DPU/DPUPostRAFusionPass: " << MF.getName()
                    << " **********\n\n");

  TII = static_cast<const DPUInstrInfo *>(MF.getSubtarget().getInstrInfo());
  bool Modified = false;

  for (auto &MBB : MF) {
    Modified |= runOnMachineBB(MBB);
  }

  LLVM_DEBUG(dbgs() << "********** DPU/DPUPostRAFusionPass: " << MF.getName()
                    << " done: Modified = " << Modified << " **********\n\n");
  return Modified;
}
