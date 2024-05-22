//===-- DPUBuildAttributes.h - DPU Attributes --------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef LLVM_SUPPORT_DPUBUILDATTRIBUTES_H
#define LLVM_SUPPORT_DPUBUILDATTRIBUTES_H

#include "llvm/Support/ELFAttributes.h"

namespace llvm {
namespace DPUBuildAttrs {

extern const TagNameMap DPUAttributeTags;

enum AttrType : unsigned {
  // Attribute types in ELF/.dpu.attributes.
  CPU_name = 5,
};

// enum { NotAllowed = 0, Allowed = 1 };

} // namespace DPUBuildAttrs
} // namespace llvm

#endif
