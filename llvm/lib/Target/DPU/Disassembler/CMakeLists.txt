add_llvm_component_library(LLVMDPUDisassembler
        DPUDisassembler.cpp
        DPUInstructionDecoder.cpp
        DPUOperandDecoder.cpp

        LINK_COMPONENTS
        DPUDesc
        DPUInfo
        MC
        MCDisassembler
        Support

        ADD_TO_COMPONENT
        DPU
        )
