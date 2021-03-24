//===-- DPUAsmBackend.cpp - DPU Assembler Backend -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the DPUAsmBackend class.
//
//===----------------------------------------------------------------------===//

#include "DPUAsmBackend.h"
#include "DPUFixupKinds.h"
#include <llvm/MC/MCFixupKindInfo.h>

#define DEBUG_TYPE "mcasmbackend"

namespace llvm {
MCAsmBackend *createDPUAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                  const MCRegisterInfo &MRI,
                                  const MCTargetOptions &Options) {
  return new DPUAsmBackend(T, STI, MRI, Options);
}

std::unique_ptr<MCObjectTargetWriter>
DPUAsmBackend::createObjectTargetWriter() const {
  return createDPUELFObjectWriter();
}

unsigned int DPUAsmBackend::getNumFixupKinds() const {
  return DPU::NumTargetFixupKinds;
}

void DPUAsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                               const MCValue &Target,
                               MutableArrayRef<char> Data, uint64_t Value,
                               bool IsResolved,
                               const MCSubtargetInfo *STI) const {
  if (!Value)
    return; // This value doesn't change the encoding

  MCFixupKind Kind = Fixup.getKind();

  uint64_t CurVal = 0;
  if (Kind < FirstTargetFixupKind) {
    CurVal = Value;
  } else {
    DPU::applyDPUFixup(CurVal, Value, static_cast<DPU::Fixups>(Kind));
  }

  MCFixupKindInfo Info = getFixupKindInfo(Kind);
  // Shift the value into position.
  CurVal <<= Info.TargetOffset;

  unsigned Offset = Fixup.getOffset();
  unsigned NumBytes = static_cast<unsigned int>(
      alignTo(Info.TargetSize + Info.TargetOffset, 8) / 8);

  assert(Offset + NumBytes <= Data.size() && "Invalid fixup offset!");

  // For each byte of the fragment that the fixup touches, mask in the
  // bits from the fixup value.
  for (unsigned i = 0; i != NumBytes; ++i) {
    Data[Offset + i] |= uint8_t((CurVal >> (i * 8)) & 0xff);
  }
}

bool DPUAsmBackend::mayNeedRelaxation(const MCInst &Inst,
                                      const MCSubtargetInfo &STI) const {
  return false;
}

bool DPUAsmBackend::fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                                         const MCRelaxableFragment *DF,
                                         const MCAsmLayout &Layout) const {
  return false;
}

void DPUAsmBackend::relaxInstruction(MCInst &, const MCSubtargetInfo &) const {
  llvm_unreachable("no instruction should be relaxed");
}

bool DPUAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count) const {
  return Count == 0; // todo
}

const MCFixupKindInfo &DPUAsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  static const MCFixupKindInfo Infos[DPU::NumTargetFixupKinds] = {
      // This table *must* be in same the order of fixup_* kinds in
      // DPUFixupKinds.h.
      // Note: because DPU immediate encoding is not simple, bits are not
      // usually contiguous.
      {"FIXUP_DPU_NONE", 0, 0, 0},
      {"FIXUP_DPU_32", 0, 32, 0},
      {"FIXUP_DPU_PC", 0, 14, 0},
      {"FIXUP_DPU_IMM4", 0, 48 /* 4*/, 0},
      {"FIXUP_DPU_IMM5", 0, 48 /* 5*/, 0},
      {"FIXUP_DPU_IMM5_RB", 0, 48 /* 5*/, 0},
      {"FIXUP_DPU_IMM5_RB_INV", 0, 48 /* 5*/, 0},
      {"FIXUP_DPU_IMM8", 0, 48 /* 8*/, 0},
      {"FIXUP_DPU_IMM8_DMA", 0, 48 /* 8*/, 0},
      {"FIXUP_DPU_IMM8_STR", 0, 48 /* 8*/, 0},
      {"FIXUP_DPU_IMM12", 0, 48 /*12*/, 0},
      {"FIXUP_DPU_IMM14_STR", 0, 48 /*14*/, 0},
      {"FIXUP_DPU_IMM16_STR", 0, 48 /*16*/, 0},
      {"FIXUP_DPU_IMM22", 0, 48 /*22*/, 0},
      {"FIXUP_DPU_IMM22_RB", 0, 48 /*22*/, 0},
      {"FIXUP_DPU_IMM24", 0, 48 /*24*/, 0},
      {"FIXUP_DPU_IMM32", 0, 48 /*32*/, 0},
      {"FIXUP_DPU_IMM32_ZERO_RB", 0, 48 /*32*/, 0},
      {"FIXUP_DPU_IMM32_DUS_RB", 0, 48 /*32*/, 0},
  };

  if (Kind < FirstTargetFixupKind)
    return MCAsmBackend::getFixupKindInfo(Kind);

  assert(unsigned(Kind - FirstTargetFixupKind) < getNumFixupKinds() &&
         "Invalid kind!");
  return Infos[Kind - FirstTargetFixupKind];
}
} // namespace llvm
