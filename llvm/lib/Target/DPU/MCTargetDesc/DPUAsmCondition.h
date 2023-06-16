//===-- DPUAsmCondition.h - DPU Assembler Condition Representation ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DPUASMCONDITION_H
#define LLVM_DPUASMCONDITION_H

#include "llvm/ADT/StringRef.h"
#include <string>

namespace llvm {
namespace DPUAsmCondition {
enum Condition {
  Carry = 0,
  Equal = 1,
  Even = 2,
  ExtendedGreaterThanSigned = 3,
  ExtendedGreaterThanUnsigned = 4,
  ExtendedLessOrEqualSigned = 5,
  ExtendedLessOrEqualUnsigned = 6,
  ExtendedNotZero = 7,
  ExtendedZero = 8,
  False = 9,
  GreaterOrEqualSigned = 10,
  GreaterOrEqualUnsigned = 11,
  GreaterThanSigned = 12,
  GreaterThanUnsigned = 13,
  Large = 14,
  LessOrEqualSigned = 15,
  LessOrEqualUnsigned = 16,
  LessThanSigned = 17,
  LessThanUnsigned = 18,
  Maximum = 19,
  Negative = 20,
  NotCarry = 21,
  NotCarry10 = 22,
  NotCarry11 = 23,
  NotCarry12 = 24,
  NotCarry5 = 25,
  NotCarry6 = 26,
  NotCarry7 = 27,
  NotCarry8 = 28,
  NotCarry9 = 29,
  NotEqual = 30,
  NotMaximum = 31,
  NotOverflow = 32,
  NotShift32 = 33,
  NotZero = 34,
  Odd = 35,
  Overflow = 36,
  PositiveOrNull = 37,
  Shift32 = 38,
  Small = 39,
  SourceEven = 40,
  SourceNegative = 41,
  SourceNotZero = 42,
  SourceOdd = 43,
  SourcePositiveOrNull = 44,
  SourceZero = 45,
  True = 46,
  Zero = 47,
  NR_CONDITIONS = 48
};

enum ConditionClass {
  AddCC = 0,
  Add_nzCC = 1,
  BootCC = 2,
  Boot_nzCC = 3,
  ConstCC_ge0 = 4,
  ConstCC_geu = 5,
  ConstCC_zero = 6,
  CountCC = 7,
  Count_nzCC = 8,
  DivCC = 9,
  Div_nzCC = 10,
  Ext_sub_setCC = 11,
  FalseCC = 12,
  Imm_shiftCC = 13,
  Imm_shift_nzCC = 14,
  LogCC = 15,
  Log_nzCC = 16,
  Log_setCC = 17,
  MulCC = 18,
  Mul_nzCC = 19,
  NoCC = 20,
  ShiftCC = 21,
  Shift_nzCC = 22,
  SubCC = 23,
  Sub_nzCC = 24,
  Sub_setCC = 25,
  TrueCC = 26,
  True_falseCC = 27,
  NR_CONDITION_CLASSES = 28
};

bool fromString(const std::string &string, Condition &Cond);

StringRef toString(Condition Cond);

bool isInConditionClass(Condition Cond, ConditionClass CondClass);

int64_t getEncoding(Condition Cond, ConditionClass CondClass);

int64_t getDecoding(uint64_t Cond, ConditionClass CondClass);

ConditionClass findConditionClassForInstruction(unsigned InstOpcode);

const unsigned int nrEncodingValue = 64;
} // namespace DPUAsmCondition
} // namespace llvm

#endif // LLVM_DPUASMCONDITION_H
