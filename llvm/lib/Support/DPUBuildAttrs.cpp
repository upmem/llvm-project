//===-- DPUBuildAttributes.cpp - DPU Attributes ----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/DPUBuildAttributes.h"

using namespace llvm;

static const TagNameItem tagData[] = {
  {DPUBuildAttrs::CPU_name, "Tag_CPU_name"},
};

const TagNameMap llvm::DPUBuildAttrs::DPUAttributeTags(tagData,
                                                      sizeof(tagData) /
                                                          sizeof(TagNameItem));
