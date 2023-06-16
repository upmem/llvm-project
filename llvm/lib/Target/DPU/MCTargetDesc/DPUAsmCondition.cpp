//===-- DPUAsmCondition.cpp - DPU Assembler Condition Representation ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "DPUAsmCondition.h"
#include "assert.h"
#include <map>
#include <set>

#define GET_INSTRINFO_ENUM
#include "DPUGenInstrInfo.inc"

namespace llvm {
namespace DPUAsmCondition {
const std::string ConditionStrings[] = {
    {"c"},     {"eq"},   {"e"},     {"xgts"}, {"xgtu"},  {"xles"},  {"xleu"},
    {"xnz"},   {"xz"},   {"false"}, {"ges"},  {"geu"},   {"gts"},   {"gtu"},
    {"large"}, {"les"},  {"leu"},   {"lts"},  {"ltu"},   {"max"},   {"mi"},
    {"nc"},    {"nc10"}, {"nc11"},  {"nc12"}, {"nc5"},   {"nc6"},   {"nc7"},
    {"nc8"},   {"nc9"},  {"neq"},   {"nmax"}, {"nov"},   {"nsh32"}, {"nz"},
    {"o"},     {"ov"},   {"pl"},    {"sh32"}, {"small"}, {"se"},    {"smi"},
    {"snz"},   {"so"},   {"spl"},   {"sz"},   {"true"},  {"z"},
};

std::map<const std::string, const std::string> ConditionStringsAliases = {
    {"C", "c"},         {"c", "c"},         {"EQ", "eq"},
    {"eq", "eq"},       {"E", "e"},         {"e", "e"},
    {"XGTS", "xgts"},   {"xgts", "xgts"},   {"XGTU", "xgtu"},
    {"xgtu", "xgtu"},   {"XLES", "xles"},   {"xles", "xles"},
    {"XLEU", "xleu"},   {"xleu", "xleu"},   {"XNZ", "xnz"},
    {"xnz", "xnz"},     {"XZ", "xz"},       {"xz", "xz"},
    {"FALSE", "false"}, {"false", "false"}, {"GES", "ges"},
    {"ges", "ges"},     {"GEU", "geu"},     {"geu", "geu"},
    {"GTS", "gts"},     {"gts", "gts"},     {"GTU", "gtu"},
    {"gtu", "gtu"},     {"LARGE", "large"}, {"large", "large"},
    {"LES", "les"},     {"les", "les"},     {"LEU", "leu"},
    {"leu", "leu"},     {"LTS", "lts"},     {"lts", "lts"},
    {"LTU", "ltu"},     {"ltu", "ltu"},     {"MAX", "max"},
    {"max", "max"},     {"MI", "mi"},       {"mi", "mi"},
    {"NC", "nc"},       {"nc", "nc"},       {"NC10", "nc10"},
    {"nc10", "nc10"},   {"NC11", "nc11"},   {"nc11", "nc11"},
    {"NC12", "nc12"},   {"nc12", "nc12"},   {"NC5", "nc5"},
    {"nc5", "nc5"},     {"NC6", "nc6"},     {"nc6", "nc6"},
    {"NC7", "nc7"},     {"nc7", "nc7"},     {"NC8", "nc8"},
    {"nc8", "nc8"},     {"NC9", "nc9"},     {"nc9", "nc9"},
    {"NEQ", "neq"},     {"neq", "neq"},     {"NMAX", "nmax"},
    {"nmax", "nmax"},   {"NOV", "nov"},     {"nov", "nov"},
    {"NSH32", "nsh32"}, {"nsh32", "nsh32"}, {"NZ", "nz"},
    {"nz", "nz"},       {"O", "o"},         {"o", "o"},
    {"OV", "ov"},       {"ov", "ov"},       {"PL", "pl"},
    {"pl", "pl"},       {"SH32", "sh32"},   {"sh32", "sh32"},
    {"SMALL", "small"}, {"small", "small"}, {"SE", "se"},
    {"se", "se"},       {"SMI", "smi"},     {"smi", "smi"},
    {"SNZ", "snz"},     {"snz", "snz"},     {"SO", "so"},
    {"so", "so"},       {"SPL", "spl"},     {"spl", "spl"},
    {"SZ", "sz"},       {"sz", "sz"},       {"TRUE", "true"},
    {"true", "true"},   {"Z", "z"},         {"z", "z"},
    {"nsz", "snz"},     {"NSZ", "snz"},     {"t", "true"},
    {"T", "true"},
};

const std::set<Condition> ConditionClassSets[] = {
    {Condition::Carry,
     Condition::ExtendedNotZero,
     Condition::ExtendedZero,
     Condition::False,
     Condition::Negative,
     Condition::NotCarry,
     Condition::NotCarry10,
     Condition::NotCarry11,
     Condition::NotCarry12,
     Condition::NotCarry5,
     Condition::NotCarry6,
     Condition::NotCarry7,
     Condition::NotCarry8,
     Condition::NotCarry9,
     Condition::NotOverflow,
     Condition::NotZero,
     Condition::Overflow,
     Condition::PositiveOrNull,
     Condition::SourceEven,
     Condition::SourceNegative,
     Condition::SourceNotZero,
     Condition::SourceOdd,
     Condition::SourcePositiveOrNull,
     Condition::SourceZero,
     Condition::True,
     Condition::Zero},
    {Condition::Carry,
     Condition::ExtendedNotZero,
     Condition::ExtendedZero,
     Condition::Negative,
     Condition::NotCarry,
     Condition::NotCarry10,
     Condition::NotCarry11,
     Condition::NotCarry12,
     Condition::NotCarry5,
     Condition::NotCarry6,
     Condition::NotCarry7,
     Condition::NotCarry8,
     Condition::NotCarry9,
     Condition::NotOverflow,
     Condition::NotZero,
     Condition::Overflow,
     Condition::PositiveOrNull,
     Condition::SourceEven,
     Condition::SourceNegative,
     Condition::SourceNotZero,
     Condition::SourceOdd,
     Condition::SourcePositiveOrNull,
     Condition::SourceZero,
     Condition::True,
     Condition::Zero},
    {Condition::False, Condition::SourceEven, Condition::SourceNegative,
     Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True},
    {Condition::SourceEven, Condition::SourceNegative, Condition::SourceNotZero,
     Condition::SourceOdd, Condition::SourcePositiveOrNull,
     Condition::SourceZero, Condition::True},
    {Condition::PositiveOrNull},
    {Condition::GreaterOrEqualUnsigned},
    {Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::False,
     Condition::Maximum, Condition::Negative, Condition::NotMaximum,
     Condition::NotZero, Condition::PositiveOrNull, Condition::SourceEven,
     Condition::SourceNegative, Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::Maximum,
     Condition::Negative, Condition::NotMaximum, Condition::NotZero,
     Condition::PositiveOrNull, Condition::SourceEven,
     Condition::SourceNegative, Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::False,
     Condition::NotZero, Condition::SourceEven, Condition::SourceNegative,
     Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::NotZero,
     Condition::SourceEven, Condition::SourceNegative, Condition::SourceNotZero,
     Condition::SourceOdd, Condition::SourcePositiveOrNull,
     Condition::SourceZero, Condition::True, Condition::Zero},
    {Condition::Carry,
     Condition::Equal,
     Condition::ExtendedGreaterThanSigned,
     Condition::ExtendedGreaterThanUnsigned,
     Condition::ExtendedLessOrEqualSigned,
     Condition::ExtendedLessOrEqualUnsigned,
     Condition::ExtendedNotZero,
     Condition::ExtendedZero,
     Condition::GreaterOrEqualSigned,
     Condition::GreaterOrEqualUnsigned,
     Condition::GreaterThanSigned,
     Condition::GreaterThanUnsigned,
     Condition::LessOrEqualSigned,
     Condition::LessOrEqualUnsigned,
     Condition::LessThanSigned,
     Condition::LessThanUnsigned,
     Condition::Negative,
     Condition::NotCarry,
     Condition::NotEqual,
     Condition::NotOverflow,
     Condition::NotZero,
     Condition::Overflow,
     Condition::PositiveOrNull,
     Condition::SourceNegative,
     Condition::SourceNotZero,
     Condition::SourcePositiveOrNull,
     Condition::SourceZero,
     Condition::True,
     Condition::Zero},
    {Condition::False},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::False,
     Condition::Negative, Condition::NotShift32, Condition::NotZero,
     Condition::PositiveOrNull, Condition::Shift32, Condition::SourceEven,
     Condition::SourceNegative, Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::Negative,
     Condition::NotShift32, Condition::NotZero, Condition::PositiveOrNull,
     Condition::Shift32, Condition::SourceEven, Condition::SourceNegative,
     Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::False,
     Condition::Negative, Condition::NotZero, Condition::PositiveOrNull,
     Condition::SourceEven, Condition::SourceNegative, Condition::SourceNotZero,
     Condition::SourceOdd, Condition::SourcePositiveOrNull,
     Condition::SourceZero, Condition::True, Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::Negative,
     Condition::NotZero, Condition::PositiveOrNull, Condition::SourceEven,
     Condition::SourceNegative, Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::NotZero,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::False,
     Condition::Large, Condition::Negative, Condition::NotZero,
     Condition::PositiveOrNull, Condition::Small, Condition::SourceEven,
     Condition::SourceNegative, Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::Large,
     Condition::Negative, Condition::NotZero, Condition::PositiveOrNull,
     Condition::Small, Condition::SourceEven, Condition::SourceNegative,
     Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::False,
     Condition::Negative, Condition::NotShift32, Condition::NotZero,
     Condition::PositiveOrNull, Condition::Shift32, Condition::SourceEven,
     Condition::SourceNegative, Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::ExtendedNotZero, Condition::ExtendedZero, Condition::Negative,
     Condition::NotShift32, Condition::NotZero, Condition::PositiveOrNull,
     Condition::Shift32, Condition::SourceEven, Condition::SourceNegative,
     Condition::SourceNotZero, Condition::SourceOdd,
     Condition::SourcePositiveOrNull, Condition::SourceZero, Condition::True,
     Condition::Zero},
    {Condition::Carry,
     Condition::Equal,
     Condition::ExtendedGreaterThanSigned,
     Condition::ExtendedGreaterThanUnsigned,
     Condition::ExtendedLessOrEqualSigned,
     Condition::ExtendedLessOrEqualUnsigned,
     Condition::ExtendedNotZero,
     Condition::ExtendedZero,
     Condition::False,
     Condition::GreaterOrEqualSigned,
     Condition::GreaterOrEqualUnsigned,
     Condition::GreaterThanSigned,
     Condition::GreaterThanUnsigned,
     Condition::LessOrEqualSigned,
     Condition::LessOrEqualUnsigned,
     Condition::LessThanSigned,
     Condition::LessThanUnsigned,
     Condition::Negative,
     Condition::NotCarry,
     Condition::NotEqual,
     Condition::NotOverflow,
     Condition::NotZero,
     Condition::Overflow,
     Condition::PositiveOrNull,
     Condition::SourceEven,
     Condition::SourceNegative,
     Condition::SourceNotZero,
     Condition::SourceOdd,
     Condition::SourcePositiveOrNull,
     Condition::SourceZero,
     Condition::True,
     Condition::Zero},
    {Condition::Carry,
     Condition::Equal,
     Condition::ExtendedGreaterThanSigned,
     Condition::ExtendedGreaterThanUnsigned,
     Condition::ExtendedLessOrEqualSigned,
     Condition::ExtendedLessOrEqualUnsigned,
     Condition::ExtendedNotZero,
     Condition::ExtendedZero,
     Condition::GreaterOrEqualSigned,
     Condition::GreaterOrEqualUnsigned,
     Condition::GreaterThanSigned,
     Condition::GreaterThanUnsigned,
     Condition::LessOrEqualSigned,
     Condition::LessOrEqualUnsigned,
     Condition::LessThanSigned,
     Condition::LessThanUnsigned,
     Condition::Negative,
     Condition::NotCarry,
     Condition::NotEqual,
     Condition::NotOverflow,
     Condition::NotZero,
     Condition::Overflow,
     Condition::PositiveOrNull,
     Condition::SourceEven,
     Condition::SourceNegative,
     Condition::SourceNotZero,
     Condition::SourceOdd,
     Condition::SourcePositiveOrNull,
     Condition::SourceZero,
     Condition::True,
     Condition::Zero},
    {Condition::Equal, Condition::ExtendedNotZero, Condition::ExtendedZero,
     Condition::NotEqual, Condition::NotZero, Condition::Zero},
    {Condition::True},
    {Condition::False, Condition::True},
};

const int64_t ConditionEncodings[NR_CONDITION_CLASSES][NR_CONDITIONS] = {
    {
        21, 0, 0, 0, 0,  0,  0,  5,  4,  0,  0,  0,  0,  0,  0, 0,
        0,  0, 0, 0, 8,  20, 29, 30, 31, 24, 25, 26, 27, 28, 0, 0,
        11, 0, 3, 0, 10, 9,  0,  0,  7,  14, 13, 6,  15, 12, 1, 2,
    },
    {
        21, 0, 0, 0, 0,  0,  0,  5,  4,  0,  0,  0,  0,  0,  0, 0,
        0,  0, 0, 0, 8,  20, 29, 30, 31, 24, 25, 26, 27, 28, 0, 0,
        11, 0, 3, 0, 10, 9,  0,  0,  7,  14, 13, 6,  15, 12, 1, 2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 7, 14, 13, 6, 15, 12, 1, 0,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 7, 14, 13, 6, 15, 12, 1, 0,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    },
    {
        0, 0, 0, 0,  0, 0, 0, 5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 10, 8, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 11,
        0, 0, 3, 0,  0, 9, 0, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0, 0, 0,  0, 0, 0, 5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 10, 8, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 11,
        0, 0, 3, 0,  0, 9, 0, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 3, 0, 0, 0, 0, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 3, 0, 0, 0, 0, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        53, 6,  0,  61, 63, 60, 62, 11, 10, 0,  55, 53, 57, 59, 0,  56,
        58, 54, 52, 0,  41, 52, 0,  0,  0,  0,  0,  0,  0,  0,  7,  0,
        51, 0,  7,  0,  50, 40, 0,  0,  0,  47, 45, 0,  46, 44, 33, 6,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    },
    {
        0, 0,  0, 0, 0, 0, 0,  5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0,  0, 0, 8, 0, 0,  0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 11, 3, 0, 0, 9, 10, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0,  0, 0, 0, 0, 0,  5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0,  0, 0, 8, 0, 0,  0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 11, 3, 0, 0, 9, 10, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 8, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 3, 0, 0, 9, 0, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 0, 0, 8, 0, 0, 0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 0, 3, 0, 0, 9, 0, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 11, 10, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0, 0, 0, 0, 0, 0,
        0, 0, 7, 0, 0, 0, 0, 0,  0,  0, 0, 0, 0, 0, 0, 6,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 5,  4, 0,  0,  0, 0,  0,  11, 0,
        0, 0, 0, 0, 8, 0, 0, 0,  0, 0,  0,  0, 0,  0,  0,  0,
        0, 0, 3, 0, 0, 9, 0, 10, 7, 14, 13, 6, 15, 12, 1,  2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 5,  4, 0,  0,  0, 0,  0,  11, 0,
        0, 0, 0, 0, 8, 0, 0, 0,  0, 0,  0,  0, 0,  0,  0,  0,
        0, 0, 3, 0, 0, 9, 0, 10, 7, 14, 13, 6, 15, 12, 1,  2,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    },
    {
        0, 0,  0, 0, 0, 0, 0,  5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0,  0, 0, 8, 0, 0,  0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 11, 3, 0, 0, 9, 10, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        0, 0,  0, 0, 0, 0, 0,  5, 4, 0,  0,  0, 0,  0,  0, 0,
        0, 0,  0, 0, 8, 0, 0,  0, 0, 0,  0,  0, 0,  0,  0, 0,
        0, 11, 3, 0, 0, 9, 10, 0, 7, 14, 13, 6, 15, 12, 1, 2,
    },
    {
        21, 2,  0,  29, 31, 28, 30, 5, 4, 0,  23, 21, 25, 27, 0, 24,
        26, 22, 20, 0,  8,  20, 0,  0, 0, 0,  0,  0,  0,  0,  3, 0,
        11, 0,  3,  0,  10, 9,  0,  0, 7, 14, 13, 6,  15, 12, 1, 2,
    },
    {
        21, 2,  0,  29, 31, 28, 30, 5, 4, 0,  23, 21, 25, 27, 0, 24,
        26, 22, 20, 0,  8,  20, 0,  0, 0, 0,  0,  0,  0,  0,  3, 0,
        11, 0,  3,  0,  10, 9,  0,  0, 7, 14, 13, 6,  15, 12, 1, 2,
    },
    {
        0, 6, 0, 0, 0, 0, 0, 11, 10, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,  0,  0, 0, 0, 0, 0, 7, 0,
        0, 0, 7, 0, 0, 0, 0, 0,  0,  0, 0, 0, 0, 0, 0, 6,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
    },
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
    },
};
const int64_t
    ConditionDecodings[NR_CONDITION_CLASSES][DPUAsmCondition::nrEncodingValue] =
        {
            {Condition::False,          Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Overflow,       Condition::NotOverflow,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::NotCarry,       Condition::Carry,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NotCarry5,      Condition::NotCarry6,
             Condition::NotCarry7,      Condition::NotCarry8,
             Condition::NotCarry9,      Condition::NotCarry10,
             Condition::NotCarry11,     Condition::NotCarry12,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Overflow,       Condition::NotOverflow,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::NotCarry,       Condition::Carry,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NotCarry5,      Condition::NotCarry6,
             Condition::NotCarry7,      Condition::NotCarry8,
             Condition::NotCarry9,      Condition::NotCarry10,
             Condition::NotCarry11,     Condition::NotCarry12,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::False,          Condition::True,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::PositiveOrNull, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::GreaterOrEqualUnsigned, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,          Condition::NR_CONDITIONS},
            {Condition::Zero,          Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS},
            {Condition::False,          Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Maximum,        Condition::NotMaximum,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Maximum,        Condition::NotMaximum,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::False,          Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::Zero,
             Condition::NotZero,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::ExtendedZero,
             Condition::ExtendedNotZero,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::True,
             Condition::Zero,
             Condition::NotZero,
             Condition::ExtendedZero,
             Condition::ExtendedNotZero,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::PositiveOrNull,
             Condition::Negative,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::SourceZero,
             Condition::SourceNotZero,
             Condition::SourcePositiveOrNull,
             Condition::SourceNegative,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::Overflow,
             Condition::NotOverflow,
             Condition::LessThanUnsigned,
             Condition::GreaterOrEqualUnsigned,
             Condition::LessThanSigned,
             Condition::GreaterOrEqualSigned,
             Condition::LessOrEqualSigned,
             Condition::GreaterThanSigned,
             Condition::LessOrEqualUnsigned,
             Condition::GreaterThanUnsigned,
             Condition::ExtendedLessOrEqualSigned,
             Condition::ExtendedGreaterThanSigned,
             Condition::ExtendedLessOrEqualUnsigned,
             Condition::ExtendedGreaterThanUnsigned},
            {Condition::False,         Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS},
            {Condition::False,          Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Shift32,        Condition::NotShift32,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Shift32,        Condition::NotShift32,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::False,          Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::Zero,          Condition::NotZero,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::ExtendedZero,  Condition::ExtendedNotZero,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS},
            {Condition::False,          Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Small,          Condition::Large,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Small,          Condition::Large,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS},
            {Condition::False,          Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Shift32,        Condition::NotShift32,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,  Condition::True,
             Condition::Zero,           Condition::NotZero,
             Condition::ExtendedZero,   Condition::ExtendedNotZero,
             Condition::SourceOdd,      Condition::SourceEven,
             Condition::Negative,       Condition::PositiveOrNull,
             Condition::Shift32,        Condition::NotShift32,
             Condition::SourceZero,     Condition::SourceNotZero,
             Condition::SourceNegative, Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,  Condition::NR_CONDITIONS},
            {Condition::False,
             Condition::True,
             Condition::Zero,
             Condition::NotZero,
             Condition::ExtendedZero,
             Condition::ExtendedNotZero,
             Condition::SourceOdd,
             Condition::SourceEven,
             Condition::Negative,
             Condition::PositiveOrNull,
             Condition::Overflow,
             Condition::NotOverflow,
             Condition::SourceZero,
             Condition::SourceNotZero,
             Condition::SourceNegative,
             Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,
             Condition::True,
             Condition::Zero,
             Condition::NotZero,
             Condition::LessThanUnsigned,
             Condition::GreaterOrEqualUnsigned,
             Condition::LessThanSigned,
             Condition::GreaterOrEqualSigned,
             Condition::LessOrEqualSigned,
             Condition::GreaterThanSigned,
             Condition::LessOrEqualUnsigned,
             Condition::GreaterThanUnsigned,
             Condition::ExtendedLessOrEqualSigned,
             Condition::ExtendedGreaterThanSigned,
             Condition::ExtendedLessOrEqualUnsigned,
             Condition::ExtendedGreaterThanUnsigned,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS,
             Condition::True,
             Condition::Zero,
             Condition::NotZero,
             Condition::ExtendedZero,
             Condition::ExtendedNotZero,
             Condition::SourceOdd,
             Condition::SourceEven,
             Condition::Negative,
             Condition::PositiveOrNull,
             Condition::Overflow,
             Condition::NotOverflow,
             Condition::SourceZero,
             Condition::SourceNotZero,
             Condition::SourceNegative,
             Condition::SourcePositiveOrNull,
             Condition::NR_CONDITIONS,
             Condition::True,
             Condition::Zero,
             Condition::NotZero,
             Condition::LessThanUnsigned,
             Condition::GreaterOrEqualUnsigned,
             Condition::LessThanSigned,
             Condition::GreaterOrEqualSigned,
             Condition::LessOrEqualSigned,
             Condition::GreaterThanSigned,
             Condition::LessOrEqualUnsigned,
             Condition::GreaterThanUnsigned,
             Condition::ExtendedLessOrEqualSigned,
             Condition::ExtendedGreaterThanSigned,
             Condition::ExtendedLessOrEqualUnsigned,
             Condition::ExtendedGreaterThanUnsigned,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::Zero,          Condition::NotZero,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::ExtendedZero,  Condition::ExtendedNotZero,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS},
            {Condition::NR_CONDITIONS, Condition::True,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS},
            {Condition::False,         Condition::True,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS,
             Condition::NR_CONDITIONS, Condition::NR_CONDITIONS},
};

bool fromString(const std::string &string, Condition &Cond) {
  const std::string string_no_alias = ConditionStringsAliases[string];
  const std::string *cond =
      std::find(std::begin(ConditionStrings), std::end(ConditionStrings),
                string_no_alias);

  if (cond == std::end(ConditionStrings)) {
    return true;
  }

  Cond = static_cast<Condition>(std::distance(ConditionStrings, cond));

  return false;
}

StringRef toString(Condition Cond) {
  assert((Cond < Condition::NR_CONDITIONS) && "invalid condition value");
  return StringRef(ConditionStrings[Cond]);
}

bool isInConditionClass(Condition Cond, ConditionClass CondClass) {
  assert((CondClass < ConditionClass::NR_CONDITION_CLASSES) &&
         "invalid condition class value");
  std::set<Condition> Conditions = ConditionClassSets[CondClass];
  return Conditions.find(Cond) != Conditions.end();
}

int64_t getEncoding(Condition Cond, ConditionClass CondClass) {
  assert((CondClass < ConditionClass::NR_CONDITION_CLASSES) &&
         "invalid condition class value");
  assert((Cond < Condition::NR_CONDITIONS) && "invalid condition value");

  return ConditionEncodings[CondClass][Cond];
}

int64_t getDecoding(uint64_t Cond, ConditionClass CondClass) {
  assert((CondClass < ConditionClass::NR_CONDITION_CLASSES) &&
         "invalid condition class value");
  assert((Cond < DPUAsmCondition::nrEncodingValue) &&
         "invalid condition value");

  return ConditionDecodings[CondClass][Cond];
}

ConditionClass findConditionClassForInstruction(unsigned InstOpcode) {
  switch (InstOpcode) {
  default:
    llvm_unreachable("unknown instruction");
  case DPU::SUBC_Urrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::NANDrric:
    return ConditionClass::Log_nzCC;
  case DPU::XORzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_SH_SLzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::OR_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::NAND_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::SUB_Srirci:
    return ConditionClass::Sub_nzCC;
  case DPU::AND_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ANDN_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1Xrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1zrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBCrirci:
    return ConditionClass::Sub_nzCC;
  case DPU::MUL_SH_ULrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::NAND_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::LSLXrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::CLO_Srrci:
    return ConditionClass::Count_nzCC;
  case DPU::NOR_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::CLSrrci:
    return ConditionClass::Count_nzCC;
  case DPU::LSRzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::BYTESWAP_Srrci:
    return ConditionClass::Log_nzCC;
  case DPU::ASRrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::AND_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUB_Srirc:
    return ConditionClass::Sub_nzCC;
  case DPU::ORN_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::LSLXzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::AND_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::NOR_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ROLrric:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1rrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::SATS_Urrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSL1rric:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SH_UH_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ROR_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SL_SHrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::SUBrrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::ROL_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::CLO_Urrci:
    return ConditionClass::Count_nzCC;
  case DPU::SUBrirci:
    return ConditionClass::Sub_nzCC;
  case DPU::MAIL1ric:
    return ConditionClass::LogCC;
  case DPU::ORNrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::NANDrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ASR_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1rrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ROLrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ADD_Srrrc:
    return ConditionClass::Add_nzCC;
  case DPU::ORNrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::RSUBC_Srrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::LSL1zrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::ANDN_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::NORrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSL_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::EXTSHzrci:
    return ConditionClass::Log_nzCC;
  case DPU::ASR_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::ADDC_Urrici:
    return ConditionClass::Add_nzCC;
  case DPU::ORrrici:
    return ConditionClass::Log_nzCC;
  case DPU::LSLX_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::CMPB4rrrci:
    return ConditionClass::Log_nzCC;
  case DPU::MOVE_Urrci:
    return ConditionClass::Log_nzCC;
  case DPU::NANDzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSL1_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SL_SH_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::RSUB_Srrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::NAND_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ROR_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::ORNzrici:
    return ConditionClass::Log_nzCC;
  case DPU::EXTSHrrci:
    return ConditionClass::Log_nzCC;
  case DPU::NXOR_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_UL_UL_Urrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ANDzrici:
    return ConditionClass::Log_nzCC;
  case DPU::ASR_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRX_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ASRzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBC_Urirf:
    return ConditionClass::FalseCC;
  case DPU::EXTUBrrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUBC_Srirci:
    return ConditionClass::Sub_nzCC;
  case DPU::ROL_ADD_Urrrici:
    return ConditionClass::BootCC;
  case DPU::ADDC_Urrrc:
    return ConditionClass::Add_nzCC;
  case DPU::MUL_SH_UL_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSL_SUBrrrici:
    return ConditionClass::BootCC;
  case DPU::CLOrrci:
    return ConditionClass::Count_nzCC;
  case DPU::LSR1_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::CLZrrci:
    return ConditionClass::Count_nzCC;
  case DPU::ROL_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::EXTSBrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSRX_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::CLZ_Srrci:
    return ConditionClass::Count_nzCC;
  case DPU::LSRXrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBC_Srirc:
    return ConditionClass::Sub_nzCC;
  case DPU::NXOR_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::RORrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::CMPB4zrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1X_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1Xrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::MOVErici:
    return ConditionClass::Log_nzCC;
  case DPU::RORrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::XOR_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::LSRX_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1Xzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::BITSWAPzrci:
    return ConditionClass::Log_nzCC;
  case DPU::ASR_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::CLSzrci:
    return ConditionClass::Count_nzCC;
  case DPU::NXORrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::ASRrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::CLZzrci:
    return ConditionClass::Count_nzCC;
  case DPU::MUL_UH_UHrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSR_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::AND_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::LSL1zrici:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBzirci:
    return ConditionClass::Sub_nzCC;
  case DPU::SUBCzirci:
    return ConditionClass::Sub_nzCC;
  case DPU::ADDCzrif:
    return ConditionClass::FalseCC;
  case DPU::XOR_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ORrric:
    return ConditionClass::Log_nzCC;
  case DPU::LSL_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::RELEASE2ci:
    return ConditionClass::Boot_nzCC;
  case DPU::LSR1X_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::AND_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::LSL1X_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::NXORzrici:
    return ConditionClass::Log_nzCC;
  case DPU::ADDC_Urrrci:
    return ConditionClass::Add_nzCC;
  case DPU::LSL_ADD_Srrrici:
    return ConditionClass::BootCC;
  case DPU::ADDC_Srrrci:
    return ConditionClass::Add_nzCC;
  case DPU::RORrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_UL_ULzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::MUL_SH_UHzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::CAOrrci:
    return ConditionClass::Count_nzCC;
  case DPU::NOTrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ROL_ADDzrrici:
    return ConditionClass::BootCC;
  case DPU::MUL_STEPrrrici:
    return ConditionClass::LogCC;
  case DPU::MUL_UH_UHzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSL1X_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::NAND_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::EXTSB_Srrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1X_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::ORN_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::LSLX_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_UH_UL_Urrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSRXrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1Xrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ADDzrrci:
    return ConditionClass::Add_nzCC;
  case DPU::LSR_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SH_SH_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::AND_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSLrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::ORNrrici:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1rrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1rrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::CLS_Urrci:
    return ConditionClass::Count_nzCC;
  case DPU::EXTUH_Urrci:
    return ConditionClass::Log_nzCC;
  case DPU::NXORrrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUB_Srrif:
    return ConditionClass::FalseCC;
  case DPU::ADDC_Srrici:
    return ConditionClass::Add_nzCC;
  case DPU::LSL_SUB_Srrrici:
    return ConditionClass::BootCC;
  case DPU::SUBrirc:
    return ConditionClass::Sub_nzCC;
  case DPU::MUL_SH_SL_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::SUBCrric:
    return ConditionClass::Sub_nzCC;
  case DPU::NANDrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::OR_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ORN_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::SUB_Urirc:
    return ConditionClass::Sub_nzCC;
  case DPU::SUBCzrici:
    return ConditionClass::Sub_nzCC;
  case DPU::SUBC_Urric:
    return ConditionClass::Sub_nzCC;
  case DPU::ADD_Urrif:
    return ConditionClass::FalseCC;
  case DPU::NANDrrici:
    return ConditionClass::Log_nzCC;
  case DPU::ANDN_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1X_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ADDC_Srrif:
    return ConditionClass::FalseCC;
  case DPU::RSUBCrrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::SUB_Urrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::RORrric:
    return ConditionClass::Shift_nzCC;
  case DPU::ROR_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::ASRrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::MOVDrrci:
    return ConditionClass::True_falseCC;
  case DPU::NXOR_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ASR_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLX_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::CLS_Srrci:
    return ConditionClass::Count_nzCC;
  case DPU::ORN_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUBC_Urirc:
    return ConditionClass::Sub_nzCC;
  case DPU::LSL1_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ADDC_Urric:
    return ConditionClass::Add_nzCC;
  case DPU::LSR1X_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRX_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::CMPB4_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ANDNzrici:
    return ConditionClass::Log_nzCC;
  case DPU::ROLrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::NAND_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::MOVE_Urici:
    return ConditionClass::Log_nzCC;
  case DPU::LSL_ADDzrrici:
    return ConditionClass::BootCC;
  case DPU::RSUBCzrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::LSR1X_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBCrrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::NAND_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSL_SUB_Urrrici:
    return ConditionClass::BootCC;
  case DPU::ROL_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1X_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::OR_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::SUBC_Urrici:
    return ConditionClass::Sub_nzCC;
  case DPU::ADDC_Srric:
    return ConditionClass::Add_nzCC;
  case DPU::MUL_SL_UHzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ORN_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::MOVE_Srrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUB_Urrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::ROL_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::BITSWAPrrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUB_Srirf:
    return ConditionClass::FalseCC;
  case DPU::ROL_ADDrrrici:
    return ConditionClass::BootCC;
  case DPU::SUBCzrif:
    return ConditionClass::FalseCC;
  case DPU::BYTESWAPrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR_ADD_Srrrici:
    return ConditionClass::BootCC;
  case DPU::OR_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::LSR_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL_ADDrrrici:
    return ConditionClass::BootCC;
  case DPU::LSL_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::ANDzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_UH_ULrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::MOVE_Srici:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ANDrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::NOR_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::ACQUIRE2ci:
    return ConditionClass::Boot_nzCC;
  case DPU::XOR_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::AND_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUBCzirf:
    return ConditionClass::FalseCC;
  case DPU::SUB_Urirci:
    return ConditionClass::Sub_nzCC;
  case DPU::MUL_SL_SLzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::MUL_SL_UH_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::XORrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ADD_Srric:
    return ConditionClass::Add_nzCC;
  case DPU::BYTESWAPzrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSRX_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::EXTUHzrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUB_Urirf:
    return ConditionClass::FalseCC;
  case DPU::DIV_STEPrrrici:
    return ConditionClass::LogCC;
  case DPU::ORzrici:
    return ConditionClass::Log_nzCC;
  case DPU::CAO_Srrci:
    return ConditionClass::Count_nzCC;
  case DPU::LSRXzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1X_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRXrric:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLX_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::ANDNrric:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_SH_UHrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSL1X_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SL_SHzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ORN_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ANDN_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUBC_Srirf:
    return ConditionClass::FalseCC;
  case DPU::SUBCrrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::ADDCrrrci:
    return ConditionClass::Add_nzCC;
  case DPU::NAND_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::OR_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::NORrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ORzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1X_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::NXORrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::LSRXzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::RSUB_Urrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::ORNzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::NOR_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::ADDC_Urrif:
    return ConditionClass::FalseCC;
  case DPU::ADD_Urrici:
    return ConditionClass::Add_nzCC;
  case DPU::SWAPDrrci:
    return ConditionClass::True_falseCC;
  case DPU::BYTESWAP_Urrci:
    return ConditionClass::Log_nzCC;
  case DPU::RSUBC_Urrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::XOR_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::LSL1Xrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::ADD_Srrici:
    return ConditionClass::Add_nzCC;
  case DPU::ROL_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::NORzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUBCrirc:
    return ConditionClass::Sub_nzCC;
  case DPU::LSR_ADDrrrici:
    return ConditionClass::BootCC;
  case DPU::MAIL2ic:
    return ConditionClass::LogCC;
  case DPU::LSR1Xrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::ROLrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::XOR_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUBCrirf:
    return ConditionClass::FalseCC;
  case DPU::SUBC_Srrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::XORrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1Xrric:
    return ConditionClass::Shift_nzCC;
  case DPU::EXTUBzrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUBrric:
    return ConditionClass::Sub_nzCC;
  case DPU::LSL1Xzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::EXTUHrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBC_Srrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::NOTzrci:
    return ConditionClass::Log_nzCC;
  case DPU::ROL_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ASR_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::CLZ_Urrci:
    return ConditionClass::Count_nzCC;
  case DPU::RSUBzrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::ANDrrici:
    return ConditionClass::Log_nzCC;
  case DPU::NXOR_Srric:
    return ConditionClass::Log_nzCC;
  case DPU::UCODE2ic:
    return ConditionClass::LogCC;
  case DPU::LSL1_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SH_SHzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSL1X_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SL_ULrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSLrric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBzirf:
    return ConditionClass::FalseCC;
  case DPU::MUL_SL_SL_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::SATSrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSLXzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::XOR_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ADDCrrici:
    return ConditionClass::Add_nzCC;
  case DPU::SUBC_Srrici:
    return ConditionClass::Sub_nzCC;
  case DPU::SUBC_Srrif:
    return ConditionClass::FalseCC;
  case DPU::ADDCzrrci:
    return ConditionClass::Add_nzCC;
  case DPU::LSL1_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::SATS_Srrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSRX_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::NOR_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::EXTSBzrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR_ADDzrrici:
    return ConditionClass::BootCC;
  case DPU::MUL_UL_UHzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ROL_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::MERGErrric:
    return ConditionClass::LogCC;
  case DPU::SUBCrrif:
    return ConditionClass::FalseCC;
  case DPU::MUL_SH_ULzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::AND_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::LSLX_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::RSUBrrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::LSL1X_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::RSUBC_Urrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::LSLXrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRX_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::SUB_Srrici:
    return ConditionClass::Sub_nzCC;
  case DPU::OR_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::ANDNrrici:
    return ConditionClass::Log_nzCC;
  case DPU::ANDN_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::LSLzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::RORzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ROR_Urrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR_ADD_Urrrici:
    return ConditionClass::BootCC;
  case DPU::OR_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ADDCrric:
    return ConditionClass::Add_nzCC;
  case DPU::SUB_Srrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::MUL_SL_UL_Srrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ADD_Srrrci:
    return ConditionClass::Add_nzCC;
  case DPU::MUL_UL_UHrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ROR_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::EXTSH_Srrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUBC_Urrif:
    return ConditionClass::FalseCC;
  case DPU::RESUMErici:
    return ConditionClass::Boot_nzCC;
  case DPU::NXOR_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::ADDrrrci:
    return ConditionClass::Add_nzCC;
  case DPU::ROR_Urrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1X_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::ADD_Srrif:
    return ConditionClass::FalseCC;
  case DPU::LSLXrric:
    return ConditionClass::Shift_nzCC;
  case DPU::ROLzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLXrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRX_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBC_Urrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::LSLX_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBCzrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::ANDN_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ORN_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::XOR_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::NOR_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::SUBrrici:
    return ConditionClass::Sub_nzCC;
  case DPU::SUB_Urric:
    return ConditionClass::Sub_nzCC;
  case DPU::LSL1Xrric:
    return ConditionClass::Shift_nzCC;
  case DPU::BITSWAP_Urrci:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_SH_SHrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSL1rrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ORN_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::RSUBC_Srrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::ADDC_Srrrc:
    return ConditionClass::Add_nzCC;
  case DPU::NXOR_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ASRzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::NXORrric:
    return ConditionClass::Log_nzCC;
  case DPU::LSRrric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBC_Urirci:
    return ConditionClass::Sub_nzCC;
  case DPU::LSR1Xzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::ANDrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ADDrrici:
    return ConditionClass::Add_nzCC;
  case DPU::UCODE1ric:
    return ConditionClass::LogCC;
  case DPU::ADDCrrif:
    return ConditionClass::FalseCC;
  case DPU::SUBzrici:
    return ConditionClass::Sub_nzCC;
  case DPU::ANDN_Urrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1rric:
    return ConditionClass::Shift_nzCC;
  case DPU::NEGrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::SUBCrrici:
    return ConditionClass::Sub_nzCC;
  case DPU::CLOzrci:
    return ConditionClass::Count_nzCC;
  case DPU::ASRrric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUB_Srrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::BITSWAP_Srrci:
    return ConditionClass::Log_nzCC;
  case DPU::NXOR_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLX_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::CAOzrci:
    return ConditionClass::Count_nzCC;
  case DPU::CMPB4_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::RSUBrrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::STOPci:
    return ConditionClass::Boot_nzCC;
  case DPU::LSRrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::NORrric:
    return ConditionClass::Log_nzCC;
  case DPU::ADDCzrici:
    return ConditionClass::Add_nzCC;
  case DPU::CAO_Urrci:
    return ConditionClass::Count_nzCC;
  case DPU::RSUBCrrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::ADD_Urrrc:
    return ConditionClass::Add_nzCC;
  case DPU::RSUB_Srrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::MUL_UL_UH_Urrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::MUL_SH_SLrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::ASR_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::ADD_Urrrci:
    return ConditionClass::Add_nzCC;
  case DPU::MUL_UL_ULrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::XORzrici:
    return ConditionClass::Log_nzCC;
  case DPU::NOR_Srrrc:
    return ConditionClass::Log_nzCC;
  case DPU::NORzrici:
    return ConditionClass::Log_nzCC;
  case DPU::NXOR_Urrici:
    return ConditionClass::Log_nzCC;
  case DPU::ANDNrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::ORNrric:
    return ConditionClass::Log_nzCC;
  case DPU::LSL_ADD_Urrrici:
    return ConditionClass::BootCC;
  case DPU::ADDrrif:
    return ConditionClass::FalseCC;
  case DPU::ANDN_Srrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSL_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::ROL_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1Xzrici:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBrrif:
    return ConditionClass::FalseCC;
  case DPU::MOVErrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSR1_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::OR_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::ANDNzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSL1Xrrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1_Srrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::ASR_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBzrif:
    return ConditionClass::FalseCC;
  case DPU::ADD_Urric:
    return ConditionClass::Add_nzCC;
  case DPU::SUB_Urrici:
    return ConditionClass::Sub_nzCC;
  case DPU::ROR_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::MUL_SL_UHrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::NAND_Urrrc:
    return ConditionClass::Log_nzCC;
  case DPU::XORrrici:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_SL_SLrrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::LSL1_Urrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBrirf:
    return ConditionClass::FalseCC;
  case DPU::ANDNrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::NXORzrrci:
    return ConditionClass::Log_nzCC;
  case DPU::ROLzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL_SUBzrrici:
    return ConditionClass::BootCC;
  case DPU::ADDCrrrc:
    return ConditionClass::Add_nzCC;
  case DPU::NOR_Srrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUB_Urrif:
    return ConditionClass::FalseCC;
  case DPU::SUBC_Srric:
    return ConditionClass::Sub_nzCC;
  case DPU::ADDrrrc:
    return ConditionClass::Add_nzCC;
  case DPU::LSL_Srrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1rrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSLX_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::ADDzrici:
    return ConditionClass::Add_nzCC;
  case DPU::LSRrrrc:
    return ConditionClass::Shift_nzCC;
  case DPU::NORrrici:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_SL_ULzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::MUL_UH_ULzrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::SUB_Srric:
    return ConditionClass::Sub_nzCC;
  case DPU::LSL_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::ROR_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::EXTUB_Urrci:
    return ConditionClass::Log_nzCC;
  case DPU::XOR_Urric:
    return ConditionClass::Log_nzCC;
  case DPU::ADDzrif:
    return ConditionClass::FalseCC;
  case DPU::ANDrric:
    return ConditionClass::Log_nzCC;
  case DPU::ADDrric:
    return ConditionClass::Add_nzCC;
  case DPU::ORrrrc:
    return ConditionClass::Log_nzCC;
  case DPU::NANDzrici:
    return ConditionClass::Log_nzCC;
  case DPU::SUBrrrc:
    return ConditionClass::Sub_nzCC;
  case DPU::ORrrrci:
    return ConditionClass::Log_nzCC;
  case DPU::LSL1X_Srrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSRXrrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::LSL1_Srric:
    return ConditionClass::Shift_nzCC;
  case DPU::SUBzrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::LSR1zrici:
    return ConditionClass::Shift_nzCC;
  case DPU::LSR1_Urric:
    return ConditionClass::Shift_nzCC;
  case DPU::ROL_ADD_Srrrici:
    return ConditionClass::BootCC;
  case DPU::RORzrrci:
    return ConditionClass::Shift_nzCC;
  case DPU::XORrric:
    return ConditionClass::Log_nzCC;
  case DPU::MUL_UH_UH_Urrrci:
    return ConditionClass::Mul_nzCC;
  case DPU::RSUB_Urrrci:
    return ConditionClass::Sub_nzCC;
  case DPU::SATSzrci:
    return ConditionClass::Log_nzCC;
  }
}
} // namespace DPUAsmCondition
} // namespace llvm
