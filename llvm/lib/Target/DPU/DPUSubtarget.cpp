//===-- DPUSubtarget.cpp - DPU Subtarget Information ----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the DPU specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "DPUSubtarget.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "dpu-subtarget"

#define GET_SUBTARGETINFO_ENUM
#define GET_SUBTARGETINFO_CTOR
#define GET_SUBTARGETINFO_TARGET_DESC

#include "DPUGenSubtargetInfo.inc"

void DPUSubtarget::anchor() {}

DPUSubtarget &DPUSubtarget::initializeSubtargetDependencies(StringRef CPU, StringRef FS) {
  IsV1A = false;
  IsV1B = false;

  // Determine default and user specified characteristics
  std::string CPUName = std::string(CPU);

  // Parse features string.
  ParseSubtargetFeatures(CPUName, /*TuneCPU*/ CPUName, FS);

  return *this;
}

DPUSubtarget::DPUSubtarget(const Triple &TT, const StringRef &CPU,
                           const StringRef &FS, const TargetMachine &TM)
    : DPUGenSubtargetInfo(TT, CPU, CPU, FS),
      InstrInfo(initializeSubtargetDependencies(CPU, FS)), FrameLowering(*this),
      TargetLowering(TM, *this), TSInfo() {
}

bool DPUSubtarget::enableMachineScheduler() const { return true; }
