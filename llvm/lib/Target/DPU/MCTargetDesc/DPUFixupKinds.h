//===-- DPUFixupKinds.h - DPU Specific Fixup Entries ------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_DPU_MCTARGETDESC_DPUFIXUPKINDS_H
#define LLVM_LIB_TARGET_DPU_MCTARGETDESC_DPUFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace DPU {
// Although most of the current fixup types reflect a unique relocation
// one can have multiple fixup types for a given relocation and thus need
// to be uniquely named.
//
// This table *must* be in the same order as
// MCFixupKindInfo Infos[DPU::NumTargetFixupKinds]
// in DPUAsmBackend.cpp.
enum Fixups {
  FIXUP_DPU_NONE = FirstTargetFixupKind,

  FIXUP_DPU_IMM12,
  FIXUP_DPU_IMM13_STR,
  FIXUP_DPU_IMM16_STR,
  FIXUP_DPU_IMM22,
  FIXUP_DPU_IMM22_RB,
  FIXUP_DPU_IMM24,
  FIXUP_DPU_IMM32,
  FIXUP_DPU_IMM32_DUS_RB,
  FIXUP_DPU_IMM32_ZERO_RB,
  FIXUP_DPU_IMM4,
  FIXUP_DPU_IMM5,
  FIXUP_DPU_IMM5_RB,
  FIXUP_DPU_IMM5_RB_INV,
  FIXUP_DPU_IMM8,
  FIXUP_DPU_IMM8_DMA,
  FIXUP_DPU_IMM8_STR,
  FIXUP_DPU_PC,

  // Marker
  LastTargetFixupKind,
  NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
};

static inline void applyDPUFixup(uint64_t &Data, uint64_t Value, Fixups Kind) {
  switch (Kind) {
  default:
    llvm_unreachable("Invalid kind!");
  case FIXUP_DPU_NONE:
    break;
  case FIXUP_DPU_IMM12:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 15) << 27) |
            (((Value >> 8) & 7) << 22) | (((Value >> 11) & 1) << 38);
    break;
  case FIXUP_DPU_IMM13_STR:
    Data |= (((Value >> 0) & 255) << 14) | (((Value >> 8) & 31) << 0);
    break;
  case FIXUP_DPU_IMM16_STR:
    Data |= (((Value >> 0) & 511) << 5) | (((Value >> 9) & 7) << 22) |
            (((Value >> 12) & 15) << 27);
    break;
  case FIXUP_DPU_IMM22:
    Data |= (((Value >> 0) & 255) << 14) | (((Value >> 8) & 16383) << 0);
    break;
  case FIXUP_DPU_IMM22_RB:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 15) << 27) |
            (((Value >> 8) & 16383) << 0);
    break;
  case FIXUP_DPU_IMM24:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 15) << 27) |
            (((Value >> 8) & 16383) << 0) | (((Value >> 22) & 3) << 38);
    break;
  case FIXUP_DPU_IMM32:
    Data |= (((Value >> 0) & 255) << 14) | (((Value >> 8) & 16383) << 0) |
            (((Value >> 22) & 63) << 38) | (((Value >> 28) & 15) << 27);
    break;
  case FIXUP_DPU_IMM32_DUS_RB:
    Data |= (((Value >> 0) & 255) << 14) | (((Value >> 8) & 16383) << 0) |
            (((Value >> 22) & 63) << 38) | (((Value >> 28) & 7) << 33) |
            (((Value >> 31) & 1) << 44);
    break;
  case FIXUP_DPU_IMM32_ZERO_RB:
    Data |= (((Value >> 0) & 255) << 14) | (((Value >> 8) & 16383) << 0) |
            (((Value >> 22) & 63) << 38) | (((Value >> 28) & 7) << 33) |
            (((Value >> 31) & 1) << 22);
    break;
  case FIXUP_DPU_IMM4:
    Data |= (((Value >> 0) & 15) << 14);
    break;
  case FIXUP_DPU_IMM5:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 1) << 27);
    break;
  case FIXUP_DPU_IMM5_RB:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 1) << 38);
    break;
  case FIXUP_DPU_IMM5_RB_INV:
    Data |= ((((~Value) >> 0) & 15) << 14) | ((((~Value) >> 4) & 1) << 38);
    break;
  case FIXUP_DPU_IMM8:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 15) << 27);
    break;
  case FIXUP_DPU_IMM8_DMA:
    Data |= (((Value >> 0) & 255) << 5);
    break;
  case FIXUP_DPU_IMM8_STR:
    Data |= (((Value >> 0) & 255) << 5);
    break;
  case FIXUP_DPU_PC:
    Data |= (((Value >> 0) & 16383) << 0);
    break;
  }
}

} // namespace DPU
} // namespace llvm

#endif // LLVM_LIB_TARGET_DPU_MCTARGETDESC_DPUFIXUPKINDS_H
