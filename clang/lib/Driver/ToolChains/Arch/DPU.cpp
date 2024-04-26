//===--- DPU.cpp - Tools Implementations ----------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "DPU.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/DriverDiagnostic.h"
#include "clang/Driver/Options.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Option/ArgList.h"

using namespace clang::driver;
using namespace clang::driver::tools;
using namespace clang;
using namespace llvm::opt;

std::string dpu::getDPUVersionFromArgs(const ArgList &Args) {
  std::string SubArch;

  if (const Arg *A = Args.getLastArg(options::OPT_march_EQ)) {
    SubArch = A->getValue();
  } else if (const Arg *A = Args.getLastArg(options::OPT_mcpu_EQ)) {
    SubArch = A->getValue();
  }

  if (SubArch.empty()) {
    SubArch = "v1A";
  }

  return SubArch;
}

std::string dpu::getDPUTargetCPU(const ArgList &Args,
				 const llvm::Triple &Triple) {
  return getDPUVersionFromArgs(Args);
}

void dpu::getDPUTargetFeatures(const Driver &D, const llvm::Triple &Triple,
			       const ArgList &Args, ArgStringList &CmdArgs,
			       std::vector<StringRef> &Features) {}
