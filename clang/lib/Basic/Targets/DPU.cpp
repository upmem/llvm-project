//===--- DPU.cpp - Implement DPU target feature support ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements DPU TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "DPU.h"
#include <Targets.h>

#include "clang/Basic/Builtins.h"
#include "clang/Basic/MacroBuilder.h"
#include "clang/Basic/TargetBuiltins.h"

#include "../../Driver/ToolChains/DPUCharacteristics.h"

using namespace clang;
using namespace clang::targets;

const Builtin::Info DPUTargetInfo::BuiltinInfo[] = {
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  {#ID, TYPE, ATTRS, nullptr, ALL_LANGUAGES, nullptr},

#include "clang/Basic/BuiltinsDPU.def"
};

void DPUTargetInfo::getTargetDefines(const LangOptions &Opts,
                                     MacroBuilder &Builder) const {
  DefineStd(Builder, "DPU", Opts);
  Builder.defineMacro("__ELF__");
  Builder.defineMacro("NR_THREADS", Twine(DPU_NR_THREADS));
}

ArrayRef<Builtin::Info> DPUTargetInfo::getTargetBuiltins() const {
  return llvm::makeArrayRef(BuiltinInfo, clang::DPU::LastTSBuiltin -
                                             Builtin::FirstTSBuiltin);
}
