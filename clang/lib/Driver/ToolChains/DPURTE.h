//===--- DPURTE.h - DPU RTE ToolChain Implementations -----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_DPURTE_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_DPURTE_H

#include "Gnu.h"
#include "clang/Driver/Options.h"
#include "clang/Driver/Tool.h"
#include "clang/Driver/ToolChain.h"
#include "llvm/Option/ArgList.h"
#include <stdlib.h>

namespace clang {
namespace driver {
namespace toolchains {

class LLVM_LIBRARY_VISIBILITY DPURTE : public Generic_ELF {
public:
  DPURTE(const Driver &D, const llvm::Triple &Triple,
         const llvm::opt::ArgList &Args)
      : Generic_ELF(D, Triple, Args) {}

  unsigned GetDefaultDwarfVersion() const override { return 4; }

  SanitizerMask getSupportedSanitizers() const override {
    SanitizerMask Res = ToolChain::getSupportedSanitizers();
    // Safe stack not supported yet Res |= SanitizerKind::SafeStack;
    return Res;
  }

  bool IsIntegratedAssemblerDefault() const override { return true; }

  bool HasNativeLLVMSupport() const override { return true; }

  void
  AddClangSystemIncludeArgs(const llvm::opt::ArgList &DriverArgs,
                            llvm::opt::ArgStringList &CC1Args) const override;

  void
  addClangTargetOptions(const llvm::opt::ArgList &DriverArgs,
                        llvm::opt::ArgStringList &CC1Args,
                        Action::OffloadKind DeviceOffloadKind) const override;

  std::string computeSysRoot() const override;
protected:
  Tool *buildLinker() const override;
};
} // end namespace toolchains
namespace tools {
namespace dpu {
class LLVM_LIBRARY_VISIBILITY Linker : public Tool {
public:
  Linker(const ToolChain &TC) : Tool("dpu::Linker", "ld.lld", TC) {}

  bool isLinkJob() const override { return true; }

  bool hasIntegratedCPP() const override { return true; }

  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};
} // end namespace dpu
} // end namespace tools
} // end namespace driver
} // end namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_DPURTE_H
