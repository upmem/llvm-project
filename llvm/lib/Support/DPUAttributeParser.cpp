//===-- DPUAttributeParser.cpp - DPU Attribute Parser -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/DPUAttributeParser.h"
#include "llvm/ADT/StringExtras.h"

using namespace llvm;

const DPUAttributeParser::DisplayHandler
    DPUAttributeParser::displayRoutines[] = {
        {
            DPUBuildAttrs::CPU_name,
            &ELFAttributeParser::stringAttribute,
        }};

Error DPUAttributeParser::handler(uint64_t tag, bool &handled) {
  handled = false;
  for (unsigned AHI = 0, AHE = array_lengthof(displayRoutines); AHI != AHE;
       ++AHI) {
    if (uint64_t(displayRoutines[AHI].attribute) == tag) {
      if (Error e = (this->*displayRoutines[AHI].routine)(tag))
        return e;
      handled = true;
      break;
    }
  }

  return Error::success();
}
