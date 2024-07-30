#include "DPUHelper.h"

#include <llvm/CodeGen/MachineOperand.h>
#include <llvm/IR/Function.h>

namespace llvm {

#define POSTRA_FUSION_METADATA_STRING "MySpecialMetadata"

MDNode *getPostRAFusionMetadata(const MachineFunction *MF) {
  LLVMContext &Context = MF->getFunction().getContext();
  return MDNode::get(Context,
                     MDString::get(Context, POSTRA_FUSION_METADATA_STRING));
}

bool hasPostRAFusionMetadata(const MachineInstr *MI) {
  for (const MachineOperand &Op : MI->operands()) {
    if (!Op.isMetadata())
      continue;

    LLVMContext &Context = MI->getMF()->getFunction().getContext();
    if (Op.getMetadata()->getOperand(0).get() ==
        MDString::get(Context, POSTRA_FUSION_METADATA_STRING)) {
      return true;
    }
  }

  return false;
}

MachineInstr *
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

} // namespace llvm
