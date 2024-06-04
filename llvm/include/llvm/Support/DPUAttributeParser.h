//===-- DPUAttributeParser.h - DPU Attribute Parser ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_DPUATTRIBUTEPARSER_H
#define LLVM_SUPPORT_DPUATTRIBUTEPARSER_H

#include "DPUBuildAttributes.h"
#include "llvm/Support/ELFAttributeParser.h"

namespace llvm {
class DPUAttributeParser : public ELFAttributeParser {
  struct DisplayHandler {
    DPUBuildAttrs::AttrType attribute;
    Error (DPUAttributeParser::*routine)(unsigned);
  };
  static const DisplayHandler displayRoutines[];

  Error handler(uint64_t tag, bool &handled) override;

public:
  DPUAttributeParser(ScopedPrinter *sw)
      : ELFAttributeParser(sw, DPUBuildAttrs::DPUAttributeTags, "upmem") {}
  DPUAttributeParser()
      : ELFAttributeParser(DPUBuildAttrs::DPUAttributeTags, "upmem") {}
};

} // namespace llvm

#endif
