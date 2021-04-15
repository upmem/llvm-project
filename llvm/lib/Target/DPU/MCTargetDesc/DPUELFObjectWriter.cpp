//===-- DPUELFObjectWriter.cpp - DPU ELF Writer ---------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the DPUELFObjectWriter class.
//
//===----------------------------------------------------------------------===//

#include "DPUELFObjectWriter.h"
#include "DPUFixupKinds.h"
#include "llvm/MC/MCValue.h"

#define DEBUG_TYPE "elfobjectwriter"

namespace llvm {

bool DPUELFObjectWriter::needsRelocateWithSymbol(const MCSymbol &Sym,
                                                 unsigned Type) const {
  return true;
}

unsigned int DPUELFObjectWriter::getRelocType(MCContext &Ctx,
                                              const MCValue &Target,
                                              const MCFixup &Fixup,
                                              bool IsPCRel) const {
  unsigned Type;
  unsigned Kind = static_cast<unsigned>(Fixup.getKind());
  switch (Kind) {
  case DPU::FIXUP_DPU_NONE:
    Type = ELF::R_DPU_NONE;
    break;
  case MCFixupKind ::FK_Data_1:
    Type = ELF::R_DPU_8;
    break;
  case MCFixupKind ::FK_Data_2:
    Type = ELF::R_DPU_16;
    break;
  case MCFixupKind ::FK_Data_4:
    Type = ELF::R_DPU_32;
    break;
  case MCFixupKind ::FK_Data_8:
    Type = ELF::R_DPU_64;
    break;
  case DPU::FIXUP_DPU_IMM12:
    Type = ELF::R_DPU_IMM12;
    break;
  case DPU::FIXUP_DPU_IMM13_STR:
    Type = ELF::R_DPU_IMM13_STR;
    break;
  case DPU::FIXUP_DPU_IMM16_STR:
    Type = ELF::R_DPU_IMM16_STR;
    break;
  case DPU::FIXUP_DPU_IMM22:
    Type = ELF::R_DPU_IMM22;
    break;
  case DPU::FIXUP_DPU_IMM22_RB:
    Type = ELF::R_DPU_IMM22_RB;
    break;
  case DPU::FIXUP_DPU_IMM24:
    Type = ELF::R_DPU_IMM24;
    break;
  case DPU::FIXUP_DPU_IMM32:
    Type = ELF::R_DPU_IMM32;
    break;
  case DPU::FIXUP_DPU_IMM32_DUS_RB:
    Type = ELF::R_DPU_IMM32_DUS_RB;
    break;
  case DPU::FIXUP_DPU_IMM32_ZERO_RB:
    Type = ELF::R_DPU_IMM32_ZERO_RB;
    break;
  case DPU::FIXUP_DPU_IMM4:
    Type = ELF::R_DPU_IMM4;
    break;
  case DPU::FIXUP_DPU_IMM5:
    Type = ELF::R_DPU_IMM5;
    break;
  case DPU::FIXUP_DPU_IMM5_RB:
    Type = ELF::R_DPU_IMM5_RB;
    break;
  case DPU::FIXUP_DPU_IMM5_RB_INV:
    Type = ELF::R_DPU_IMM5_RB_INV;
    break;
  case DPU::FIXUP_DPU_IMM8:
    Type = ELF::R_DPU_IMM8;
    break;
  case DPU::FIXUP_DPU_IMM8_DMA:
    Type = ELF::R_DPU_IMM8_DMA;
    break;
  case DPU::FIXUP_DPU_IMM8_STR:
    Type = ELF::R_DPU_IMM8_STR;
    break;
  case DPU::FIXUP_DPU_PC:
    Type = ELF::R_DPU_PC;
    break;
  default:
    llvm_unreachable("Invalid fixup kind!");
  }
  return Type;
}

std::unique_ptr<MCObjectTargetWriter> createDPUELFObjectWriter() {
  return std::make_unique<DPUELFObjectWriter>();
}

} // namespace llvm
