//===-- DPU.td - Describe the DPU Target Machine -----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// Target-independent interfaces which we are implementing
include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// DPU Features on codegen
//===----------------------------------------------------------------------===//

def FeatureDPUNoSugar : SubtargetFeature<"nosugar", "noSugar", "false", "Disable the use of Syntactic Sugar Instruction">;
def FeatureDPUDisableMramCheck : SubtargetFeature<"disablemramcheck", "disableMramCheck", "false", "Disable the check of alignment of buffer of the transfer with the MRAM">;

//===----------------------------------------------------------------------===//
// DPU Subtarget features
//===----------------------------------------------------------------------===//

def FeatureDPUv1A : SubtargetFeature<"v1A", "IsV1A", "true", "this is v1A">;
def FeatureDPUv1B : SubtargetFeature<"v1B", "IsV1B", "true", "this is v1B">;

//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "DPURegisterInfo.td"
include "DPUInstrInfo.td"
include "DPUCallingConv.td"

def DPUInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// DPU processors supported
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"generic", []>;

def : Proc<"v1A", [FeatureDPUv1A]>;
def : Proc<"v1B", [FeatureDPUv1B]>;

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def DPUAsmParser : AsmParser {
  let ShouldEmitMatchRegisterName = 1;
}

def DPUAsmParserVariant : AsmParserVariant {
  let Variant = 0;
  let RegisterPrefix = "%";
  let CommentDelimiter = "//";
}

// To generate assembler as output.
def DPUInstPrinter : AsmWriter {
  string AsmWriterClassName  = "InstPrinter";
  bit isMCAsmWriter = 1;
}

def DPU : Target {
  let InstructionSet = DPUInstrInfo;
  let AssemblyParsers = [DPUAsmParser];
  let AssemblyParserVariants = [DPUAsmParserVariant];
  let AssemblyWriters = [DPUInstPrinter];
  let AllowRegisterRenaming = 1;
}
