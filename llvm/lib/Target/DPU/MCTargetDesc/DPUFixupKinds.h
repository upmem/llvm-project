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

  FIXUP_DPU_32,
  FIXUP_DPU_PC,
  FIXUP_DPU_IMM4,
  FIXUP_DPU_IMM5,
  FIXUP_DPU_IMM5_RB,
  FIXUP_DPU_IMM5_RB_INV,
  FIXUP_DPU_IMM8,
  FIXUP_DPU_IMM8_DMA,
  FIXUP_DPU_IMM8_STR,
  FIXUP_DPU_IMM12,
  FIXUP_DPU_IMM14_STR,
  FIXUP_DPU_IMM16_STR,
  FIXUP_DPU_IMM22,
  FIXUP_DPU_IMM22_RB,
  FIXUP_DPU_IMM24,
  FIXUP_DPU_IMM32,
  FIXUP_DPU_IMM32_ZERO_RB,
  FIXUP_DPU_IMM32_DUS_RB,

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
  case FIXUP_DPU_32:
    Data |= (((Value >> 0) & 0xffffffffl) << 0);
    break;
  case FIXUP_DPU_PC:
    Data |= (((Value >> 0) & 0x3fffl) << 0);
    break;
  case FIXUP_DPU_IMM4:
    Data |= (((Value >> 0) & 15) << 14);
    break;
  case FIXUP_DPU_IMM5:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 1) << 28);
    break;
  case FIXUP_DPU_IMM5_RB:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 1) << 24);
    break;
  case FIXUP_DPU_IMM5_RB_INV:
    Data |= ((((~Value) >> 0) & 15) << 14) | ((((~Value) >> 4) & 1) << 24);
    break;
  case FIXUP_DPU_IMM8:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 15) << 28);
    break;
  case FIXUP_DPU_IMM8_DMA:
    Data |= (((Value >> 0) & 0xffl) << 6);
    break;
  case FIXUP_DPU_IMM8_STR:
    Data |= (((Value >> 0) & 1) << 23) | (((Value >> 1) & 7) << 39) | (((Value >> 4) & 15) << 28);
    break;
  case FIXUP_DPU_IMM12:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 7) << 28) | (((Value >> 7) & 1) << 24) | (((Value >> 8) & 7) << 39) | (((Value >> 11) & 1) << 31);
    break;
  case FIXUP_DPU_IMM14_STR:
    Data |= (((Value >> 8) & 63) << 0) | (((Value >> 0) & 255) << 14);
    break;
  case FIXUP_DPU_IMM16_STR:
    Data |= (((Value >> 0) & 1) << 23) | (((Value >> 1) & 7) << 39) | (((Value >> 4) & 15) << 28) | (((Value >> 8) & 255) << 6);
    break;
  case FIXUP_DPU_IMM22:
    Data |= (((Value >> 8) & 16383) << 0) | (((Value >> 0) & 15) << 14) | (((Value >> 4) & 15) << 18);
    break;
  case FIXUP_DPU_IMM22_RB:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 7) << 28) | (((Value >> 7) & 1) << 13) | (((Value >> 8) & 0x1fff) << 0) | (((Value >> 21) & 1) << 31);
    break;
  case FIXUP_DPU_IMM24:
    Data |= (((Value >> 0) & 15) << 14) | (((Value >> 4) & 7) << 28) | (((Value >> 7) & 1) << 24) | (((Value >> 8) & 0x3fff) << 0) | (((Value >> 22) & 1) << 22) | (((Value >> 23) & 1) << 31);
    break;
  case FIXUP_DPU_IMM32:
    Data |= (((Value >> 8) & 16383) << 0) | (((Value >> 0) & 15) << 14) | (((Value >> 22) & 1023) << 18) | (((Value >> 4) & 15) << 28);
    break;
  case FIXUP_DPU_IMM32_ZERO_RB:
    Data |= (((Value >> 8) & 16383) << 0) | (((Value >> 0) & 15) << 14) | (((Value >> 22) & 1023) << 18) | (((Value >> 4) & 7) << 34) | (((Value >> 7) & 1) << 39);
    break;
  case FIXUP_DPU_IMM32_DUS_RB:
    Data |= (((Value >> 8) & 16383) << 0) | (((Value >> 0) & 15) << 14) | (((Value >> 22) & 1023) << 18) | (((Value >> 4) & 7) << 34) | (((Value >> 7) & 1) << 44);
    break;
  }
}

} // namespace DPU
} // namespace llvm

#endif // LLVM_LIB_TARGET_DPU_MCTARGETDESC_DPUFIXUPKINDS_H
