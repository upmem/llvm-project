//===-- DPUTargetSreamer.h - DPU Target Streamer ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_DPU_DPUTARGETSTREAMER_H
#define LLVM_LIB_TARGET_DPU_DPUTARGETSTREAMER_H

/* #include "llvm/BinaryFormat/ELF.h" */

#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/DPUBuildAttributes.h"
#include "llvm/Support/LEB128.h"

#define DPU_ABI_VERSION 2

namespace llvm {
class DPUTargetStreamer : public MCTargetStreamer {
public:
  enum class AttributeType { Hidden, Numeric, Text, NumericAndText };

  struct AttributeItem {
    AttributeType Type;
    unsigned Tag;
    unsigned IntValue;
    std::string StringValue;
  };
  StringRef CurrentVendor;
  SmallVector<AttributeItem, 64> Contents;

  MCSection *AttributeSection = nullptr;

  AttributeItem *getAttributeItem(unsigned Attribute) {
    for (size_t i = 0; i < Contents.size(); ++i)
      if (Contents[i].Tag == Attribute)
        return &Contents[i];
    return nullptr;
  }

  void setAttributeItem(unsigned Attribute, unsigned Value,
                        bool OverwriteExisting) {
    // Look for existing attribute item.
    if (AttributeItem *Item = getAttributeItem(Attribute)) {
      if (!OverwriteExisting)
        return;
      Item->Type = AttributeType::Numeric;
      Item->IntValue = Value;
      return;
    }

    // Create new attribute item.
    Contents.push_back({AttributeType::Numeric, Attribute, Value, ""});
  }

  void setAttributeItem(unsigned Attribute, StringRef Value,
                        bool OverwriteExisting) {
    // Look for existing attribute item.
    if (AttributeItem *Item = getAttributeItem(Attribute)) {
      if (!OverwriteExisting)
        return;
      Item->Type = AttributeType::Text;
      Item->StringValue = std::string(Value);
      return;
    }

    // Create new attribute item.
    Contents.push_back({AttributeType::Text, Attribute, 0, std::string(Value)});
  }

  void setAttributeItems(unsigned Attribute, unsigned IntValue,
                         StringRef StringValue, bool OverwriteExisting) {
    // Look for existing attribute item.
    if (AttributeItem *Item = getAttributeItem(Attribute)) {
      if (!OverwriteExisting)
        return;
      Item->Type = AttributeType::NumericAndText;
      Item->IntValue = IntValue;
      Item->StringValue = std::string(StringValue);
      return;
    }

    // Create new attribute item.
    Contents.push_back({AttributeType::NumericAndText, Attribute, IntValue,
                        std::string(StringValue)});
  }

  MCELFStreamer &getStreamer() {
    return static_cast<MCELFStreamer &>(Streamer);
  }

  DPUTargetStreamer(MCStreamer &S,
		    const MCSubtargetInfo &STI)
    : MCTargetStreamer(S), CurrentVendor("upmem") {
    MCAssembler &MCA = getStreamer().getAssembler();
    MCA.setELFHeaderEFlags(
        EF_EABI_DPU_SET(MCA.getELFHeaderEFlags(), DPU_ABI_VERSION));
    setAttributeItem(DPUBuildAttrs::CPU_name, STI.getCPU(), true);
  }

  size_t calculateContentSize() const {
    size_t Result = 0;
    for (AttributeItem item : Contents) {
      switch (item.Type) {
      case AttributeType::Hidden:
        break;
      case AttributeType::Numeric:
        Result += getULEB128Size(item.Tag);
        Result += getULEB128Size(item.IntValue);
        break;
      case AttributeType::Text:
        Result += getULEB128Size(item.Tag);
        Result += item.StringValue.size() + 1; // string + '\0'
        break;
      case AttributeType::NumericAndText:
        Result += getULEB128Size(item.Tag);
        Result += getULEB128Size(item.IntValue);
        Result += item.StringValue.size() + 1; // string + '\0';
        break;
      }
    }
    return Result;
  }

  void finish() override {
    if (Contents.empty())
      return;

    if (AttributeSection) {
      Streamer.SwitchSection(AttributeSection);
    } else {
      MCAssembler &MCA = getStreamer().getAssembler();
      AttributeSection = MCA.getContext().getELFSection(".dpu.attributes", ELF::SHT_DPU_ATTRIBUTES, 0);
      Streamer.SwitchSection(AttributeSection);

      Streamer.emitInt8(ELFAttrs::Format_Version);
    }

    // Vendor size + Vendor name + '\0'
    const size_t VendorHeaderSize = 4 + CurrentVendor.size() + 1;

    // Tag + Tag Size
    const size_t TagHeaderSize = 1 + 4;

    const size_t ContentsSize = calculateContentSize();

    Streamer.emitInt32(VendorHeaderSize + TagHeaderSize + ContentsSize);
    Streamer.emitBytes(CurrentVendor);
    Streamer.emitInt8(0); // '\0'

    Streamer.emitInt8(ELFAttrs::File);
    Streamer.emitInt32(TagHeaderSize + ContentsSize);

    // Size should have been accounted for already, now
    // emit each field as its type (ULEB or String).
    for (AttributeItem item : Contents) {
      Streamer.emitULEB128IntValue(item.Tag);
      switch (item.Type) {
      default:
        llvm_unreachable("Invalid attribute type");
      case AttributeType::Numeric:
        Streamer.emitULEB128IntValue(item.IntValue);
        break;
      case AttributeType::Text:
        Streamer.emitBytes(item.StringValue);
        Streamer.emitInt8(0); // '\0'
        break;
      case AttributeType::NumericAndText:
        Streamer.emitULEB128IntValue(item.IntValue);
        Streamer.emitBytes(item.StringValue);
        Streamer.emitInt8(0); // '\0'
        break;
      }
    }

    Contents.clear();
  }
};

}
#endif
