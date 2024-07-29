//===-- DPUInstrInfo.h - DPU Instruction Information ------------*- C++ -*-===//
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
#ifndef LLVM_LIB_TARGET_DPU_DPUINSTRINFO_H
#define LLVM_LIB_TARGET_DPU_DPUINSTRINFO_H

#include "DPURegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER

#include "DPUGenInstrInfo.inc"

namespace llvm {
  class DPUSubtarget;

class DPUInstrInfo : public DPUGenInstrInfo {
  const DPURegisterInfo RI;
  const DPUSubtarget& Subtarget;
public:
  explicit DPUInstrInfo(DPUSubtarget &ST);

  const DPURegisterInfo &getRegisterInfo() const { return RI; }

  void storeRegToStackSlot(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI, Register SrcReg,
                           bool isKill, int FrameIndex,
                           const TargetRegisterClass *RC,
                           const TargetRegisterInfo *TRI) const override;

  void loadRegFromStackSlot(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator I, Register DestReg,
                            int FI, const TargetRegisterClass *RC,
                            const TargetRegisterInfo *TRI) const override;

  bool expandPostRAPseudo(MachineInstr &MI) const override;
  void expand64BitRegisterAluInstruction(MachineInstr &MI,
					 MachineBasicBlock &MBB,
					 unsigned int LsbOpcode,
					 unsigned int MsbOpcode) const;
  void expand64BitImmediateAluInstruction(MachineInstr &MI,
					  MachineBasicBlock &MBB,
					  unsigned int LsbOpcode,
					  unsigned int MsbOpcode) const;
  
  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                   const DebugLoc &DL, MCRegister DestReg, MCRegister SrcReg,
                   bool KillSrc) const override;

  bool
  reverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const override;
  
  bool analyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
                     MachineBasicBlock *&FBB,
                     SmallVectorImpl<MachineOperand> &Cond,
                     bool AllowModify) const override;

  unsigned removeBranch(MachineBasicBlock &MBB,
                        int *BytesRemoved) const override;

  unsigned insertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                        MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                        const DebugLoc &DL, int *BytesAdded) const override;

  void buildConditionalBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                              DebugLoc DL, ArrayRef<MachineOperand> Cond) const;

  bool shouldSink(const MachineInstr &MI) const override;
};

} // namespace llvm

#endif /* LLVM_LIB_TARGET_DPU_DPUINSTRINFO_H */
