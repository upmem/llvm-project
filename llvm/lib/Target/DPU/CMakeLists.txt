add_llvm_component_group(DPU)

set(LLVM_TARGET_DEFINITIONS DPU.td)

tablegen(LLVM DPUGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM DPUGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM DPUGenCallingConv.inc -gen-callingconv)
tablegen(LLVM DPUGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM DPUGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM DPUGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM DPUGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM DPUGenSubtargetInfo.inc -gen-subtarget)

add_public_tablegen_target(DPUCommonTableGen)

add_llvm_target(DPUCodeGen
        DPUAsmPrinter.cpp
        DPUFrameLowering.cpp
        DPUHelper.cpp
        DPUInstrInfo.cpp
        DPUISelDAGToDAG.cpp
        DPUMachineFunctionInfo.cpp
        DPUMacroFusion.cpp
        DPUMergeComboInstrPass.cpp
        DPUMCInstLower.cpp
        DPUPostRAFusion.cpp
        DPURegisterInfo.cpp
        DPUResolveMacroInstrPass.cpp
        DPUSelectionDAGInfo.cpp
        DPUSubtarget.cpp
        DPUTargetLowering.cpp
        DPUTargetMachine.cpp

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
