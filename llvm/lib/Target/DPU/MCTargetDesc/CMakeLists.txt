add_llvm_component_library(LLVMDPUDesc
  DPUMCTargetDesc.cpp
  DPUMCCodeEmitter.cpp
  DPUAsmBackend.cpp
  DPUELFObjectWriter.cpp
  DPUAsmCondition.cpp
  DPUInstPrinter.cpp

  LINK_COMPONENTS
  DPUInfo
  MC
  MCDisassembler
  Support

  ADD_TO_COMPONENT
  DPU
  )
