add_llvm_component_group(DPU)

set(LLVM_TARGET_DEFINITIONS DPU.td)

tablegen(LLVM DPUGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM DPUGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM DPUGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM DPUGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM DPUGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM DPUGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM DPUGenCallingConv.inc -gen-callingconv)
tablegen(LLVM DPUGenMCCodeEmitter.inc -gen-emitter)

add_public_tablegen_target(DPUCommonTableGen)

add_llvm_target(DPUCodeGen
        DPUTargetMachine.cpp
        DPURegisterInfo.cpp
        DPUFrameLowering.cpp
        DPUTargetLowering.cpp
        DPUMachineFunctionInfo.cpp
        DPUInstrInfo.cpp
        DPUSubtarget.cpp
        DPUISelDAGToDAG.cpp
        DPUAsmPrinter.cpp
        DPUMCInstLower.cpp
        DPUMergeComboInstrPass.cpp
        DPUResolveMacroInstrPass.cpp
        DPUMacroFusion.cpp
        DPUSelectionDAGInfo.cpp

        DEPENDS
        intrinsics_gen

        LINK_COMPONENTS
        Analysis
        AsmPrinter
        CodeGen
        Core
        DPUAsmParser
        DPUDesc
        DPUInfo
        MC
        SelectionDAG
        Support
        Target
        TransformUtils

        ADD_TO_COMPONENT
        DPU
        )

add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
