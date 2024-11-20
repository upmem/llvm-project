#ifndef LLVM_LIB_TARGET_DPU_DPUHELPER_H
#define LLVM_LIB_TARGET_DPU_DPUHELPER_H

#include <llvm/CodeGen/MachineBasicBlock.h>
#include <llvm/CodeGen/MachineFunction.h>
#include <llvm/CodeGen/MachineInstr.h>
#include <llvm/IR/Metadata.h>

namespace llvm {

MDNode *getPostRAFusionMetadata(const MachineFunction *MF);
bool hasPostRAFusionMetadata(const MachineInstr *MI);

MachineInstr *
getLastNonDebugInstrFrom(MachineBasicBlock::reverse_iterator &I,
                         MachineBasicBlock::reverse_iterator REnd);

} // namespace llvm

#endif // LLVM_LIB_TARGET_DPU_DPUHELPER_H
