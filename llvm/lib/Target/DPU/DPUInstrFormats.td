//===-- DPUInstrFormats.td - DPU Instruction Formats -----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Describe DPU instructions format
//
//===----------------------------------------------------------------------===//


class DPUInstruction : Instruction {
  field bits<48> Inst;

  field dag OutOperandList;
  field dag InOperandList;

  field string AsmString;

  field list<dag> Pattern;

  let Namespace = "DPU";
  let DecoderNamespace = "DPU";
  let Size = 6;
  field bits<48> SoftFail = 0;
}

class PseudoDPUInstruction<dag outs, dag ins, string asmstr, list<dag> pattern> : DPUInstruction {
  dag OutOperandList = outs;
  dag InOperandList  = ins;
  let AsmString      = asmstr;
  let Pattern        = pattern;
  let isPseudo       = 1;
  let isCodeGenOnly  = 1;
}

class ConditionClassAsmOperand<string cc> : AsmOperandClass {
  let Name = cc;
  let RenderMethod = "addConditionOperands";
  let ParserMethod = "parseAnyConditionAs" # cc;
  let PredicateMethod = "is" # cc;
}

class ImmAsmOperandClass<int nr_bits, string signedness> : AsmOperandClass {
  let Name = signedness # "Imm" # nr_bits;
  let RenderMethod = "addImmOperands";
  let ParserMethod = "parseAnyImmediate";
  let PredicateMethod = "is" # signedness # "Imm<" # nr_bits # ">";
}

class ConditionClassOperand<string cc> : Operand<i32> {
  let PrintMethod = "printCondition";
  let ParserMatchClass = ConditionClassAsmOperand<cc>;
  let EncoderMethod = "getConditionEncoding";
}

class ImmOperand<int nr_bits, string signedness, ValueType super_op> : Operand<super_op> {
  let PrintMethod = "print" # signedness # "Imm<" # nr_bits # ">";
  let ParserMatchClass = ImmAsmOperandClass<nr_bits, signedness>;
}

class InvImmOperand<int nr_bits, string signedness, ValueType super_op> : Operand<super_op> {
  let PrintMethod = "print" # signedness # "Imm<" # nr_bits # ">";
  let ParserMatchClass = ImmAsmOperandClass<nr_bits, signedness>;
  let EncoderMethod = "getInvImmEncoding";
}

class SImmOperand<int nr_bits, ValueType super_op> : ImmOperand<nr_bits, "S", super_op>, ImmLeaf<super_op, !strconcat("return (Imm >= -(1L << (", !cast<string>(nr_bits), " - 1))) && (Imm < (1L << (", !cast<string>(nr_bits), " - 1)));")>;
class UImmOperand<int nr_bits, ValueType super_op> : ImmOperand<nr_bits, "U", super_op>, ImmLeaf<super_op, !strconcat("return (Imm >= 0) && (Imm < (1L << ", !cast<string>(nr_bits), "));")>;
class SUImmOperand<int nr_bits, ValueType super_op> : ImmOperand<nr_bits, "SU", super_op>, ImmLeaf<super_op, !strconcat("return (Imm >= -(1L << (", !cast<string>(nr_bits), " - 1))) && (Imm < (1L << ", !cast<string>(nr_bits), "));")>;
class PCImmOperand<int nr_bits, ValueType super_op> : ImmOperand<nr_bits, "PC", super_op>, ImmLeaf<super_op, !strconcat("return (Imm >= -(1L << (", !cast<string>(nr_bits), " - 1))) && (Imm < (1L << ", !cast<string>(nr_bits), "));")>;
class UInvImmOperand<int nr_bits, ValueType super_op> : InvImmOperand<nr_bits, "U", super_op>, ImmLeaf<super_op, !strconcat("return (Imm >= 0) && (Imm < (1L << ", !cast<string>(nr_bits), "));")>;

def  s8_imm : SImmOperand< 8, i32>;
def s12_imm : SImmOperand<12, i32>;
def s13_imm : SImmOperand<13, i32>;
def s14_imm : SImmOperand<14, i32>;
def s16_imm : SImmOperand<16, i32>;
def s22_imm : SImmOperand<22, i32>;
def s24_imm : SImmOperand<24, i32>;

def  su8_imm : SUImmOperand< 8, i32>;
def su16_imm : SUImmOperand<16, i32>;
def u32_imm : SUImmOperand<32, i32>;
def u4_imm  : UImmOperand< 4, i32>;
def u5_imm  : UImmOperand< 5, i32>;
def u8_imm  : UImmOperand< 8, i32>;
def u5_inv_imm  : UInvImmOperand< 5, i32>;

def s8_i64_imm : SImmOperand<8, i64>;
def s16_i64_imm : SImmOperand<16, i64>;
def s32_i64_imm : SImmOperand<32, i64>;
def u32_i64_imm : UImmOperand<32, i64>;

def pc14 : PCImmOperand<14, OtherVT> {
}
def pcbb : PCImmOperand<24, OtherVT>;

def add_cc          : ConditionClassOperand<"Add_cc">;
def add_nz_cc       : ConditionClassOperand<"Add_nz_cc">;
def boot_cc         : ConditionClassOperand<"Boot_cc">;
def boot_nz_cc      : ConditionClassOperand<"Boot_nz_cc">;
def const_cc_ge0    : ConditionClassOperand<"Const_cc_ge0">;
def const_cc_geu    : ConditionClassOperand<"Const_cc_geu">;
def const_cc_zero   : ConditionClassOperand<"Const_cc_zero">;
def count_cc        : ConditionClassOperand<"Count_cc">;
def count_nz_cc     : ConditionClassOperand<"Count_nz_cc">;
def div_cc          : ConditionClassOperand<"Div_cc">;
def div_nz_cc       : ConditionClassOperand<"Div_nz_cc">;
def ext_sub_set_cc  : ConditionClassOperand<"Ext_sub_set_cc">;
def false_cc        : ConditionClassOperand<"False_cc">;
def imm_shift_cc    : ConditionClassOperand<"Imm_shift_cc">;
def imm_shift_nz_cc : ConditionClassOperand<"Imm_shift_nz_cc">;
def log_cc          : ConditionClassOperand<"Log_cc">;
def log_nz_cc       : ConditionClassOperand<"Log_nz_cc">;
def log_set_cc      : ConditionClassOperand<"Log_set_cc">;
def mul_cc          : ConditionClassOperand<"Mul_cc">;
def mul_nz_cc       : ConditionClassOperand<"Mul_nz_cc">;
def no_cc           : ConditionClassOperand<"No_cc">;
def shift_cc        : ConditionClassOperand<"Shift_cc">;
def shift_nz_cc     : ConditionClassOperand<"Shift_nz_cc">;
def sub_cc          : ConditionClassOperand<"Sub_cc">;
def sub_nz_cc       : ConditionClassOperand<"Sub_nz_cc">;
def sub_set_cc      : ConditionClassOperand<"Sub_set_cc">;
def true_cc         : ConditionClassOperand<"True_cc">;
def true_false_cc   : ConditionClassOperand<"True_false_cc">;

def ACODEri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "acode $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110010000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00110110;
}

def ACQUIRE1_Hri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "acquire1_h $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111100001;
}

def ACQUIRE2ci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins boot_nz_cc:$cc, pc14:$pc);
	let AsmString        = "acquire2 $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{47-22} = 0b00110110101100011000011000;
}

def ADDrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u32_imm:$imm);
	let AsmString        = "add $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (add SimpleRegOrCst:$ra, u32_imm:$imm))];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<32> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0000;
}

def ADDrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, add_nz_cc:$cc);
	let AsmString        = "add $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<22> off; bits<5> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDrrif: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "add $rc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "add $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (add SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b100000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc);
	let AsmString        = "add $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<5> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "add $zero, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<32> imm; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = imm{31};
	let Inst{27-23} = 0b00000;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def ADDzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111000;
}

def ADDzrif: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "add $zero, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00111000;
}

def ADDzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "add $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011100000;
}

def ADDzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isAdd            = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111000;
}

def ADD_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "add.s $dc, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{27} = 0b0;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{44} = imm{31};
	let Inst{47-45} = 0b000;
}

def ADD_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, add_nz_cc:$cc);
	let AsmString        = "add.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Srrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "add.s $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "add.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b100000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc);
	let AsmString        = "add.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "add.u $dc, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{27} = 0b0;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{44} = imm{31};
	let Inst{47-45} = 0b000;
}

def ADD_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, add_nz_cc:$cc);
	let AsmString        = "add.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Urrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "add.u $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "add.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b100000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc);
	let AsmString        = "add.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADD_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "add.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDCrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u32_imm:$imm);
	let AsmString        = "addc $rc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0001;
}

def ADDCrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, add_nz_cc:$cc);
	let AsmString        = "addc $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDCrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDCrrif: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "addc $rc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDCrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "addc $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b100100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDCrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc);
	let AsmString        = "addc $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDCrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ADDCzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "addc $zero, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = imm{31};
	let Inst{27-23} = 0b00001;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def ADDCzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111001;
}

def ADDCzrif: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "addc $zero, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00111001;
}

def ADDCzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "addc $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011100100;
}

def ADDCzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111001;
}

def ADDC_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, add_nz_cc:$cc);
	let AsmString        = "addc.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Srrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "addc.s $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "addc.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b100100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc);
	let AsmString        = "addc.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, add_nz_cc:$cc);
	let AsmString        = "addc.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Urrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "addc.u $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "addc.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b100100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc);
	let AsmString        = "addc.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ADDC_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, add_nz_cc:$cc, pc14:$pc);
	let AsmString        = "addc.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$ra, u32_imm:$imm);
	let AsmString        = "and $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (and SimpleReg:$ra, u32_imm:$imm))];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0101;
}

def ANDrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "and $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "and $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (and SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "and $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "and $zero, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = imm{31};
	let Inst{27-23} = 0b00101;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def ANDzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100010;
}

def ANDzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "and $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000100;
}

def ANDzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000100;
}

def AND_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "and.s $dc, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{27} = 0b0;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{44} = imm{31};
	let Inst{47-45} = 0b001;
}

def AND_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "and.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "and.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "and.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "and.u $dc, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{27} = 0b0;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{44} = imm{31};
	let Inst{47-45} = 0b001;
}

def AND_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "and.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "and.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "and.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def AND_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "and.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDNrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "andn $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (and (not SimpleRegOrCst:$ra), s24_imm:$imm))];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDNrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "andn $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDNrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDNrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "andn $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (and (not SimpleRegOrCst:$ra), SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDNrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "andn $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDNrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ANDNzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "andn $zero, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00110000;
}

def ANDNzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100100;
}

def ANDNzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "andn $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001000;
}

def ANDNzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001000;
}

def ANDN_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "andn.s $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "andn.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "andn.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "andn.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "andn.u $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "andn.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "andn.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "andn.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ANDN_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "andn.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASRrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "asr $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (sra SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ASRrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "asr $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ASRrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ASRrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "asr $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (sra SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000001000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ASRrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "asr $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b001011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ASRrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ASRzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "asr $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def ASRzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def ASRzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "asr $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000001000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def ASRzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def ASR_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "asr.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "asr.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "asr.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000001000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "asr.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b001011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "asr.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "asr.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11001;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "asr.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000001000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "asr.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b001011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ASR_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "asr.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BITSWAPrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "bitswap $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (bitreverse SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11000111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def BITSWAPrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "bitswap $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11000111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def BITSWAPzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "bitswap $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110001110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def BITSWAPzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "bitswap $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11000111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def BITSWAP_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "bitswap.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BITSWAP_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "bitswap.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BITSWAP_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "bitswap.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BITSWAP_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "bitswap.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BKP: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "bkp";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b001101010011000110011110000000001000000000000000;
}

def BYTESWAPrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "byteswap $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (bswap SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11001011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def BYTESWAPrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "byteswap $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11001011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def BYTESWAPzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "byteswap $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110010110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def BYTESWAPzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "byteswap $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11001011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def BYTESWAP_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "byteswap.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11001011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BYTESWAP_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "byteswap.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11001011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BYTESWAP_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "byteswap.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11001011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def BYTESWAP_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "byteswap.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11001011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CALLri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s24_imm:$off);
	let AsmString        = "call $rc, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isCall           = 1;
	bits<24> off; bits<5> rc;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{37-31} = 0b1100011;
	let Inst{39-38} = off{23-22};
	let Inst{43-40} = 0b0110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CALLrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "call $rc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isCall           = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CALLrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$off);
	let AsmString        = "call $rc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isCall           = 1;
	bits<24> off; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = off{23-22};
	let Inst{43-40} = 0b0110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CALLrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "call $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isCall           = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CALLzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$off);
	let AsmString        = "call $zero, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isBarrier        = 1;
	let isTerminator     = 1;
	bits<24> off; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = off{23-22};
	let Inst{47-40} = 0b00110110;
}

def CALLzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "call $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isCall           = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011000;
}

def CAOrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "cao $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (ctpop SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CAOrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cao $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CAOzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "cao $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110100110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CAOzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cao $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11010011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CAO_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "cao.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CAO_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cao.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CAO_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "cao.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CAO_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cao.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLEAR_COUNT: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "clear_count";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100000011000110000000000000000000000000000000;
}

def CLEAR_COUNTr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "clear_count $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100000011000110001;
}

def CLEAR_COUNT_X: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_X";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100000111000110000000000000000000000000000000;
}

def CLEAR_COUNT_Xr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_X $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100000111000110001;
}

def CLEAR_COUNT_ALL: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_all";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100010011000110000000000000000000000000000000;
}

def CLEAR_COUNT_ALLr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_all $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100010011000110001;
}

def CLEAR_COUNT_ALL_X: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_all_X";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100010111000110000000000000000000000000000000;
}

def CLEAR_COUNT_ALL_Xr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_all_X $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100010111000110001;
}

def CLEAR_COUNT_MASK: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_mask";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100011011000110000000000000000000000000000000;
}

def CLEAR_COUNT_MASKr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "clear_count_mask $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100011011000110001;
}

def CLEAR_TIME: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "clear_time";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100100011000110000000000000000000000000000000;
}

def CLEAR_TIMEr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "clear_time $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100100011000110001;
}

def CLEAR_TIME_X: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "clear_time_X";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100100111000110000000000000000000000000000000;
}

def CLEAR_TIME_Xr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "clear_time_X $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100100111000110001;
}

def CLOrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "clo $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Clo SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11010111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CLOrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clo $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11010111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CLOzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "clo $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110101110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CLOzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clo $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11010111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CLO_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "clo.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLO_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clo.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLO_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "clo.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLO_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clo.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLSrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "cls $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Cls SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11011011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CLSrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cls $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11011011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CLSzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "cls $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110110110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CLSzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cls $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11011011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CLS_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "cls.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLS_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cls.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLS_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "cls.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLS_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cls.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLZrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "clz $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (ctlz SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11011111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CLZrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clz $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11011111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CLZzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "clz $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110111110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CLZzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clz $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11011111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def CLZ_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "clz.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLZ_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clz.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLZ_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "clz.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CLZ_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, count_nz_cc:$cc, pc14:$pc);
	let AsmString        = "clz.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11011111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CMPB4rrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "cmpb4 $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000110000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CMPB4rrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cmpb4 $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1100;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def CMPB4zrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "cmpb4 $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000110000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def CMPB4zrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cmpb4 $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1100;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def CMPB4_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "cmpb4.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000110000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CMPB4_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cmpb4.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1100;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CMPB4_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "cmpb4.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000110000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def CMPB4_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "cmpb4.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1100;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def DIV_STEPrrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, DoubleReg:$db, u5_imm:$shift);
	let AsmString        = "div_step $dc, $ra, $db, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> db; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def DIV_STEPrrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, DoubleReg:$db, u5_imm:$shift, log_cc:$cc, pc14:$pc);
	let AsmString        = "div_step $dc, $ra, $db, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> db; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ENTER_FAULT: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "enter_fault";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b001101001111100110000110000000000000000000000000;
}

def ENTER_STOP: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "enter_stop";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b001101001011100110000110010000000000000000000000;
}

def EXTSBrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extsb $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (sext_inreg SimpleRegOrCst:$ra, i8))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11100111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTSBrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extsb $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11100111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTSBzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "extsb $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b111001110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTSBzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extsb $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11100111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTSB_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extsb.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11100111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def EXTSB_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extsb.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11100111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def EXTSHrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extsh $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (sext_inreg SimpleRegOrCst:$ra, i16))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11101111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTSHrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extsh $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11101111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTSHzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "extsh $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b111011110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTSHzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extsh $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11101111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTSH_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extsh.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11101111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def EXTSH_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extsh.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11101111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def EXTUBrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extub $rc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11100011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTUBrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extub $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11100011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTUBzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "extub $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b111000110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTUBzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extub $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11100011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTUB_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extub.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11100011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def EXTUB_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extub.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11100011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def EXTUHrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extuh $rc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11101011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTUHrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extuh $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11101011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def EXTUHzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "extuh $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b111010110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTUHzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extuh $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11101011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def EXTUH_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "extuh.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11101011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def EXTUH_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "extuh.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11101011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def FAULT: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "fault";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b001101001111100110000110000000000000000000000000;
}

def FAULTi: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins s14_imm:$off);
	let AsmString        = "fault $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> off;
	let Inst{13-0} = off{13-0};
	let Inst{47-14} = 0b0011010100110001100111100000000010;
}

def GET_COUNT: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "get_count";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100011111000110000000000000000000000000000000;
}

def GET_COUNTr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "get_count $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100011111000110001;
}

def GET_SYSTEMr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "get_system $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100111111000110001;
}

def GET_TIME: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "get_time";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100110011000110000000000000000000000000000000;
}

def GET_TIMEr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "get_time $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100110011000110001;
}

def IDMAriri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s14_imm:$off, SimpleReg:$rb, u8_imm:$immDma);
	let AsmString        = "idma $ra, $off, $rb, $immDma";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let hasSideEffects   = 1;
	bits<13> off; bits<8> immDma; bits<5> rb;
	let Inst{4-0} = off{12-8};
	let Inst{12-5} = immDma{7-0};
	let Inst{13} = 0b0;
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{47-33} = 0b011101001111000;
}

def JEQrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jeq $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0010;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111000;
}

def JEQrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jeq $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100000100000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110000;
}

def JGESrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jges $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0111;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JGESrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jges $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100001110000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JGEUrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jgeu $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0101;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JGEUrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jgeu $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100001010000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JGTSrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jgts $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b1001;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JGTSrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jgts $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100010010000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JGTUrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jgtu $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b1011;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JGTUrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jgtu $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100010110000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JLESrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jles $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b1000;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JLESrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jles $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100010000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JLEUrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jleu $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b1010;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JLEUrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jleu $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100010100000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JLTSrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jlts $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0110;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JLTSrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jlts $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100001100000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JLTUrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jltu $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0100;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111001;
}

def JLTUrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jltu $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100001000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110010;
}

def JNEQrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s12_imm:$imm, pc14:$pc);
	let AsmString        = "jneq $ra, $imm, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0011;
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001111000;
}

def JNEQrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc);
	let AsmString        = "jneq $ra, $rb, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{27-14} = 0b01100000110000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110000;
}

def JNZri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, pc14:$pc);
	let AsmString        = "jnz $ra, $pc";
	let Pattern          = [(brcond SimpleRegOrCst:$ra, bb:$pc)];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{32-14} = 0b1100001100000110000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110000;
}

def JUMPi: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins pcbb:$off);
	let AsmString        = "jump $off";
	let Pattern          = [(br bb:$off)];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isBarrier        = 1;
	let isTerminator     = 1;
	bits<24> off;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = off{7-4};
	let Inst{37-31} = 0b1100011;
	let Inst{39-38} = off{23-22};
	let Inst{47-40} = 0b00110110;
}

def JUMPr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "jump $ra";
	let Pattern          = [(brind SimpleRegOrCst:$ra)];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isBarrier        = 1;
	let isTerminator     = 1;
	let isIndirectBranch = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110000110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011000;
}

def JUMPri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$off);
	let AsmString        = "jump $ra, $off";
	let Pattern          = [(brind (add SimpleRegOrCst:$ra, s24_imm:$off))];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isBarrier        = 1;
	let isTerminator     = 1;
	let isIndirectBranch = 1;
	bits<24> off; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = off{23-22};
	let Inst{47-40} = 0b00110110;
}

def JZri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, pc14:$pc);
	let AsmString        = "jz $ra, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{32-14} = 0b1100001100000100000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110000;
}

def LBSrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lbs $rc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b110001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000000;
}

def LBS_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lbs.s $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000000;
}

def LBS_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lbs.u $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000000;
}

def LBUrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lbu $rc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b110000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000000;
}

def LBU_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lbu.s $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000000;
}

def LBU_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lbu.u $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000000;
}

def LDrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "ld $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{26-22} = dc{4-0};
	let Inst{32-27} = 0b110000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000011;
}

def LDMAriri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, SimpleReg:$rb, u8_imm:$immDma);
	let AsmString        = "ldma $ra, $off, $rb, $immDma";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let hasSideEffects   = 1;
	bits<13> off; bits<8> immDma; bits<5> rb; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{12-5} = immDma{7-0};
	let Inst{13} = 0b0;
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111010000;
}

def LDMArri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, u8_imm:$immDma);
	let AsmString        = "ldma $ra, $rb, $immDma";
	let Pattern          = [(SDT_Ldma SimpleRegOrCst:$ra, SimpleReg:$rb, u8_imm:$immDma)];
	let isAsCheapAsAMove = 1;
	let hasSideEffects   = 1;
	bits<8> immDma; bits<5> rb; bits<5> ra;
	let Inst{4-0} = 0b00000;
	let Inst{12-5} = immDma{7-0};
	let Inst{27-13} = 0b011000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111010000;
}

def LDMAIriri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, SimpleReg:$rb, u8_imm:$immDma);
	let AsmString        = "ldmai $ra, $off, $rb, $immDma";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<8> immDma; bits<5> rb; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{12-5} = immDma{7-0};
	let Inst{13} = 0b0;
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111010001;
}

def LDMAIrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, u8_imm:$immDma);
	let AsmString        = "ldmai $ra, $rb, $immDma";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<8> immDma; bits<5> rb; bits<5> ra;
	let Inst{4-0} = 0b00000;
	let Inst{12-5} = immDma{7-0};
	let Inst{27-13} = 0b011000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111010001;
}

def LHSrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lhs $rc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b110001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000001;
}

def LHS_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lhs.s $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000001;
}

def LHS_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lhs.u $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111001;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000001;
}

def LHUrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lhu $rc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b110000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000001;
}

def LHU_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lhu.s $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000001;
}

def LHU_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lhu.u $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000001;
}

def LSLrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (shl SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (shl SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000010000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b010011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSLzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSLzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000010000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSLzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000010000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b010011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000010000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b010011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1rri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1 $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsl1 SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1rric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl1 $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1rrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1 $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1rrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1 $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsl1 SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000100000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1rrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl1 $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b100011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1rrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1 $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1zri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1 $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1zrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1 $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1zrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1 $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000100000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1zrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1 $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl1.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000100000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl1.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b100011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl1.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000100000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl1.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b100011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1Xrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1x $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsl1x SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1Xrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl1x $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1Xrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1Xrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1x $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsl1x SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000101000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1Xrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl1x $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b101011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1Xrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL1Xzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1x $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1Xzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1Xzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1x $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000101000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1Xzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSL1X_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1x.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl1x.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1x.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000101000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl1x.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b101011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl1x.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsl1x.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsl1x.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000101000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsl1x.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b101011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL1X_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsl1x.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_ADDrrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_add $rc, $rb, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (add SimpleReg:$rb, (shl SimpleRegOrCst:$ra, u5_imm:$shift)))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL_ADDrrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_add $rc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL_ADDzrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_add $zero, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{27-18} = 0b0110000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101010;
}

def LSL_ADDzrrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_add $zero, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101010;
}

def LSL_ADD_Srrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_add.s $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_ADD_Srrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_add.s $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_ADD_Urrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_add.u $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_ADD_Urrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_add.u $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_SUBrrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_sub $rc, $rb, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (sub SimpleReg:$rb, (shl SimpleRegOrCst:$ra, u5_imm:$shift)))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL_SUBrrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_sub $rc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSL_SUBzrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_sub $zero, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{27-18} = 0b0110000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101011;
}

def LSL_SUBzrrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_sub $zero, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101011;
}

def LSL_SUB_Srrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_sub.s $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_SUB_Srrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_sub.s $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_SUB_Urrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsl_sub.u $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSL_SUB_Urrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsl_sub.u $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLXrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lslx $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lslx SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLXrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lslx $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLXrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLXrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lslx $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lslx SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000011000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLXrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lslx $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b011011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLXrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSLXzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lslx $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSLXzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSLXzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lslx $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000011000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSLXzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def LSLX_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lslx.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lslx.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lslx.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000011000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lslx.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b011011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lslx.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lslx.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lslx.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000011000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lslx.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b011011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSLX_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lslx.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (srl SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (srl SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000010000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b010011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSRzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSRzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000010000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSRzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000010000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b010011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11010;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000010000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b010011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1rri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1 $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsr1 SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1rric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr1 $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1rrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1 $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1rrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1 $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsr1 SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000100000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1rrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr1 $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b100011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1rrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1 $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1zri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1 $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1zrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1 $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1zrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1 $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000100000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1zrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1 $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr1.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000100000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr1.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b100011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr1.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11100;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000100000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr1.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b100011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1Xrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1x $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsr1x SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1Xrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr1x $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1Xrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1Xrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1x $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsr1x SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000101000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1Xrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr1x $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b101011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1Xrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR1Xzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1x $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1Xzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1Xzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1x $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000101000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1Xzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSR1X_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1x.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr1x.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1x.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000101000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr1x.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b101011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsr1x.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsr1x.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11101;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsr1x.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000101000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsr1x.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b101011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR1X_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsr1x.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_ADDrrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift);
	let AsmString        = "lsr_add $rc, $rb, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (add SimpleReg:$rb, (srl SimpleRegOrCst:$ra, u5_inv_imm:$shift)))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR_ADDrrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsr_add $rc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSR_ADDzrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift);
	let AsmString        = "lsr_add $zero, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{27-18} = 0b0110000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101000;
}

def LSR_ADDzrrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsr_add $zero, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101000;
}

def LSR_ADD_Srrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift);
	let AsmString        = "lsr_add.s $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_ADD_Srrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsr_add.s $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_ADD_Urrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift);
	let AsmString        = "lsr_add.u $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSR_ADD_Urrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_inv_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "lsr_add.u $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRXrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsrx $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsrx SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRXrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsrx $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRXrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRXrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsrx $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Lsrx SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000011000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRXrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsrx $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b011011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRXrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def LSRXzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsrx $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSRXzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSRXzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsrx $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000011000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSRXzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def LSRX_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsrx.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsrx.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsrx.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000011000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsrx.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b011011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "lsrx.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "lsrx.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "lsrx.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000011000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "lsrx.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b011011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LSRX_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "lsrx.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def LWrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lw $rc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b110000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000010;
}

def LW_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lw.s $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000010;
}

def LW_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "lw.u $dc, $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{32-27} = 0b111000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000010;
}

def MAIL1ric: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleReg:$rb, pc14:$pc, log_cc:$cc);
	let AsmString        = "mail1 $rb, $pc, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> pc; bits<4> cc; bits<5> rb;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0001;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{47-33} = 0b001101101111000;
}

def MAIL2ic: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins pc14:$pc, log_cc:$cc);
	let AsmString        = "mail2 $pc, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0011;
	let Inst{21-18} = cc{3-0};
	let Inst{47-22} = 0b00110110111100000000011000;
}

def MERGErrric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, pc14:$pc, log_cc:$cc);
	let AsmString        = "merge $dc, $ra, $rb, $pc, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVDrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins DoubleReg:$db);
	let AsmString        = "movd $dc, $db";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> db;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{43-33} = 0b01001011000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVDrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins DoubleReg:$db, true_false_cc:$cc, pc14:$pc);
	let AsmString        = "movd $dc, $db, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> db;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{43-33} = 0b01001011000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVEri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins u32_imm:$imm);
	let AsmString        = "move $rc, $imm";
	let Pattern          = [(set SimpleReg:$rc, u32_imm:$imm)];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rc;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{37-31} = 0b1100011;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def MOVErici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "move $rc, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{43-31} = 0b0001101100011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MOVErr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "move $rc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b110000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0110000000;
}

def MOVErrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "move $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MOVE_Sri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s32_i64_imm:$imm);
	let AsmString        = "move.s $dc, $imm";
	let Pattern          = [(set DoubleReg:$dc, s32_i64_imm:$imm)];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{30-27} = imm{31-28};
	let Inst{37-31} = 0b1101011;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0101;
}

def MOVE_Srici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s8_i64_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "move.s $dc, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<8> imm; bits<4> cc; bits<5> dc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{43-31} = 0b0001101100011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVE_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "move.s $dc, $ra";
	let Pattern          = [(set DoubleReg:$dc, (sext SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVE_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "move.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVE_Uri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins u32_i64_imm:$imm);
	let AsmString        = "move.u $dc, $imm";
	let Pattern          = [(set DoubleReg:$dc, u32_i64_imm:$imm)];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{30-27} = imm{31-28};
	let Inst{37-31} = 0b1101011;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0101;
}

def MOVE_Urici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "move.u $dc, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<8> imm; bits<4> cc; bits<5> dc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{43-31} = 0b0001101100011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVE_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "move.u $dc, $ra";
	let Pattern          = [(set DoubleReg:$dc, (zext SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11010011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MOVE_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "move.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_SHrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_sh $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000011100000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_SHrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_sh $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_SHzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_sh $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000011100000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_SHzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_sh $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0111;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_SH_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_sh.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000011100000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_SH_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_sh.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_SLrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_sl $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000011000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_SLrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_sl $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_SLzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_sl $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000011000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_SLzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_sl $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_SL_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_sl.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000011000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_SL_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_sl.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0110;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_UHrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_uh $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000101100000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_UHrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_uh $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1011;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_UHzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_uh $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000101100000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_UHzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_uh $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1011;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_UH_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_uh.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000101100000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_UH_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_uh.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1011;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_ULrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_ul $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000101000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_ULrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_ul $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SH_ULzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_ul $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000101000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_ULzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_ul $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SH_UL_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sh_ul.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000101000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SH_UL_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sh_ul.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_SHrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_sh $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000010100000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_SHrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_sh $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0101;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_SHzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_sh $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000010100000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_SHzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_sh $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0101;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_SH_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_sh.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000010100000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_SH_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_sh.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0101;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_SLrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_sl $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Mul8SS SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000010000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_SLrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_sl $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_SLzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_sl $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000010000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_SLzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_sl $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_SL_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_sl.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000010000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_SL_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_sl.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0100;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_UHrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_uh $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000100100000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_UHrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_uh $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1001;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_UHzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_uh $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000100100000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_UHzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_uh $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1001;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_UH_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_uh.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000100100000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_UH_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_uh.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1001;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_ULrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_ul $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Mul8SU SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000100000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_ULrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_ul $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_SL_ULzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_ul $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000100000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_ULzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_ul $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_SL_UL_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_sl_ul.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000100000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_SL_UL_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_sl_ul.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_STEPrrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, DoubleReg:$db, u5_imm:$shift);
	let AsmString        = "mul_step $dc, $ra, $db, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> db; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_STEPrrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, DoubleReg:$db, u5_imm:$shift, log_cc:$cc, pc14:$pc);
	let AsmString        = "mul_step $dc, $ra, $db, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> db; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UH_UHrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_uh_uh $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000001100000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UH_UHrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_uh_uh $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0011;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UH_UHzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_uh_uh $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000001100000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UH_UHzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_uh_uh $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0011;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UH_UH_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_uh_uh.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000001100000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UH_UH_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_uh_uh.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0011;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UH_ULrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_uh_ul $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000001000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UH_ULrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_uh_ul $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UH_ULzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_uh_ul $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000001000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UH_ULzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_uh_ul $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UH_UL_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_uh_ul.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000001000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UH_UL_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_uh_ul.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UL_UHrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_ul_uh $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000100000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UL_UHrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_ul_uh $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0001;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UL_UHzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_ul_uh $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000100000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UL_UHzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_ul_uh $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0001;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UL_UH_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_ul_uh.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000100000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UL_UH_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_ul_uh.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0001;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UL_ULrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_ul_ul $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (SDT_Mul8UU SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UL_ULrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_ul_ul $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def MUL_UL_ULzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_ul_ul $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UL_ULzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_ul_ul $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011001;
}

def MUL_UL_UL_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "mul_ul_ul.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def MUL_UL_UL_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, mul_nz_cc:$cc, pc14:$pc);
	let AsmString        = "mul_ul_ul.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b011001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NANDrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nand $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (not (and SimpleRegOrCst:$ra, s24_imm:$imm)))];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NANDrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nand $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001111;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NANDrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NANDrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nand $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (not (and SimpleRegOrCst:$ra, SimpleReg:$rb)))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NANDrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nand $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001111;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NANDrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NANDzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nand $zero, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00110011;
}

def NANDzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100111;
}

def NANDzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nand $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001110;
}

def NANDzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001110;
}

def NAND_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nand.s $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nand.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nand.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nand.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nand.u $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nand.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nand.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nand.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NAND_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nand.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NEGrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "neg $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (ineg SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b110000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0010000000;
}

def NEGrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "neg $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NOP: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "nop";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b001101010011000111100110000000000000000000000000;
}

def NORrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nor $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (not (or SimpleRegOrCst:$ra, s24_imm:$imm)))];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NORrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nor $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NORrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NORrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nor $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (not (or SimpleRegOrCst:$ra, SimpleReg:$rb)))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NORrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nor $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NORrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NORzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nor $zero, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00110001;
}

def NORzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100110;
}

def NORzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nor $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001100;
}

def NORzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001100;
}

def NOR_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nor.s $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nor.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nor.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nor.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "nor.u $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nor.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nor.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nor.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOR_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nor.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NOTrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "not $rc, $ra";
	let Pattern          = [(set SimpleReg:$rc, (not SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b1111111111111111111111;
	let Inst{26-22} = rc{4-0};
	let Inst{32-27} = 0b111111;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0100111111;
}

def NOTrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "not $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11111111;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NOTzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "not $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b1111;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11111111111;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000001;
}

def NXORrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nxor $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NXORrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NXORrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nxor $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (not (xor SimpleRegOrCst:$ra, SimpleReg:$rb)))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NXORrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nxor $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NXORrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def NXORzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100001;
}

def NXORzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nxor $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000010;
}

def NXORzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000010;
}

def NXOR_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nxor.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nxor.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nxor.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "nxor.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "nxor.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "nxor.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def NXOR_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "nxor.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u32_imm:$imm);
	let AsmString        = "or $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (or SimpleRegOrCst:$ra, u32_imm:$imm))];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def ORrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "or $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000111;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "or $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (or SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "or $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000111;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "or $zero, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = imm{31};
	let Inst{27-23} = 0b00110;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def ORzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100011;
}

def ORzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "or $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000110;
}

def ORzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000110;
}

def OR_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "or.s $dc, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b1;
	let Inst{26-23} = dc{4-1};
	let Inst{27} = 0b0;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{44} = imm{31};
	let Inst{47-45} = 0b010;
}

def OR_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "or.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "or.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "or.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "or.u $dc, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> dc; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = 0b0;
	let Inst{26-23} = dc{4-1};
	let Inst{27} = 0b0;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{44} = imm{31};
	let Inst{47-45} = 0b010;
}

def OR_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "or.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "or.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "or.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000111;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def OR_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "or.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000110;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORNrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "orn $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (or (not SimpleRegOrCst:$ra), s24_imm:$imm))];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORNrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "orn $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORNrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORNrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "orn $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (or (not SimpleRegOrCst:$ra), SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORNrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "orn $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORNrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ORNzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "orn $zero, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00110010;
}

def ORNzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100101;
}

def ORNzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "orn $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001010;
}

def ORNzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011001010;
}

def ORN_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "orn.s $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "orn.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "orn.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "orn.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "orn.u $dc, $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b0010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "orn.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "orn.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "orn.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ORN_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "orn.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b001010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RELEASE1_Hri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off);
	let AsmString        = "release1_h $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11001011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111100001;
}

def RELEASE2ci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins boot_nz_cc:$cc, pc14:$pc);
	let AsmString        = "release2 $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{47-22} = 0b00110110101100011000011001;
}

def RESUMErici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u4_imm:$imm, boot_nz_cc:$cc, pc14:$pc);
	let AsmString        = "resume $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010001;
}

def RESUME_MASKri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "resume_mask $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00110100;
}

def RETr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "ret $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isBarrier        = 1;
	let isTerminator     = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110000110000000000100000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011011000;
}

def RETI: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "reti";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b001101100011000110001111010000000000000000000000;
}

def ROLrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (rotl SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROLrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "rol $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROLrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROLrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rol $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (rotl SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROLrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "rol $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROLrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROLzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def ROLzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def ROLzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rol $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def ROLzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111000;
}

def ROL_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "rol.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rol.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "rol.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "rol.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rol.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "rol.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rol.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_ADDrrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol_add $rc, $rb, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (add SimpleReg:$rb, (rotl SimpleRegOrCst:$ra, u5_imm:$shift)))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROL_ADDrrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "rol_add $rc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def ROL_ADDzrri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol_add $zero, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{27-18} = 0b0110000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101001;
}

def ROL_ADDzrrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "rol_add $zero, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{47-39} = 0b001101001;
}

def ROL_ADD_Srrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol_add.s $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_ADD_Srrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "rol_add.s $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_ADD_Urrri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "rol_add.u $dc, $rb, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROL_ADD_Urrrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift, boot_cc:$cc, pc14:$pc);
	let AsmString        = "rol_add.u $dc, $rb, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = shift{4};
	let Inst{43-39} = 0b01001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RORrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "ror $rc, $ra, $shift";
	let Pattern          = [(set SimpleReg:$rc, (rotr SimpleRegOrCst:$ra, u5_imm:$shift))];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RORrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "ror $rc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RORrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror $rc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RORrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "ror $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (rotr SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RORrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "ror $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RORrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RORzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "ror $zero, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def RORzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror $zero, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> shift; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{26-22} = 0b11000;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def RORzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "ror $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def RORzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011111010;
}

def ROR_Srri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "ror.s $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "ror.s $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror.s $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "ror.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "ror.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Urri: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift);
	let AsmString        = "ror.u $dc, $ra, $shift";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b00000000000000;
	let Inst{17-14} = shift{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc);
	let AsmString        = "ror.u $dc, $ra, $shift, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> shift; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = 0b11111111111111;
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u5_imm:$shift, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror.u $dc, $ra, $shift, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> shift; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = shift{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{27} = shift{4};
	let Inst{32-28} = 0b11000;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "ror.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc);
	let AsmString        = "ror.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def ROR_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, shift_nz_cc:$cc, pc14:$pc);
	let AsmString        = "ror.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b111010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUBrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsub $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b101000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RSUBrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "rsub $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RSUBrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsub $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RSUBzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsub $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011101000;
}

def RSUBzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsub $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111010;
}

def RSUB_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsub.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b101000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUB_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "rsub.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUB_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsub.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUB_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsub.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b101000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUB_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "rsub.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUB_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsub.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUBCrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsubc $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b101100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RSUBCrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "rsubc $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RSUBCrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsubc $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def RSUBCzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsubc $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011101100;
}

def RSUBCzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsubc $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111011;
}

def RSUBC_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsubc.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b101100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUBC_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "rsubc.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUBC_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsubc.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUBC_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "rsubc.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b101100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUBC_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "rsubc.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def RSUBC_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "rsubc.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SATSrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "sats $rc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SATSrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sats $rc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SATSzr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra);
	let AsmString        = "sats $zero, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110000110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def SATSzrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sats $zero, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def SATS_Srr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "sats.s $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SATS_Srrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sats.s $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SATS_Urr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "sats.u $dc, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SATS_Urrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sats.u $dc, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{32-25} = 0b11000011;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b010100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SBrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, su8_imm:$imm);
	let AsmString        = "sb $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<8> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{12-5} = imm{7-0};
	let Inst{13} = 0b0;
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001000;
}

def SBrir: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, SimpleReg:$rb);
	let AsmString        = "sb $ra, $off, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rb; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000100;
}

def SB_IDri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off);
	let AsmString        = "sb_id $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = 0b000000000;
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001100;
}

def SB_IDrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, su8_imm:$imm);
	let AsmString        = "sb_id $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<8> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{12-5} = imm{7-0};
	let Inst{13} = 0b0;
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001100;
}

def SDrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, s16_i64_imm:$imm);
	let AsmString        = "sd $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<16> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = imm{8-0};
	let Inst{21-14} = off{7-0};
	let Inst{24-22} = imm{11-9};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{15-12};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001011;
}

def SDrir: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, DoubleReg:$db);
	let AsmString        = "sd $ra, $off, $db";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> db; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b111000;
	let Inst{32-28} = db{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000111;
}

def SD_IDri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off);
	let AsmString        = "sd_id $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = 0b000000000;
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001111;
}

def SD_IDrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, s16_i64_imm:$imm);
	let AsmString        = "sd_id $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<16> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = imm{8-0};
	let Inst{21-14} = off{7-0};
	let Inst{24-22} = imm{11-9};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{15-12};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001111;
}

def SDMAriri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, SimpleReg:$rb, u8_imm:$immDma);
	let AsmString        = "sdma $ra, $off, $rb, $immDma";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let hasSideEffects   = 1;
	bits<13> off; bits<8> immDma; bits<5> rb; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{12-5} = immDma{7-0};
	let Inst{13} = 0b0;
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111010010;
}

def SDMArri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, u8_imm:$immDma);
	let AsmString        = "sdma $ra, $rb, $immDma";
	let Pattern          = [(SDT_Sdma SimpleRegOrCst:$ra, SimpleReg:$rb, u8_imm:$immDma)];
	let isAsCheapAsAMove = 1;
	let hasSideEffects   = 1;
	bits<8> immDma; bits<5> rb; bits<5> ra;
	let Inst{4-0} = 0b00000;
	let Inst{12-5} = immDma{7-0};
	let Inst{27-13} = 0b011000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111010010;
}

def SET_ZCr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra);
	let AsmString        = "set_zc $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> ra;
	let Inst{32-0} = 0b110011110000000000000000000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def SHrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, su16_imm:$imm);
	let AsmString        = "sh $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<16> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = imm{8-0};
	let Inst{21-14} = off{7-0};
	let Inst{24-22} = imm{11-9};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{15-12};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001001;
}

def SHrir: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, SimpleReg:$rb);
	let AsmString        = "sh $ra, $off, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rb; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000101;
}

def SH_IDri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off);
	let AsmString        = "sh_id $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = 0b000000000;
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001101;
}

def SH_IDrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, su16_imm:$imm);
	let AsmString        = "sh_id $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<16> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = imm{8-0};
	let Inst{21-14} = off{7-0};
	let Inst{24-22} = imm{11-9};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{15-12};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001101;
}

def START_COUNT: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "start_count";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100001111000110000000000000000000000000000000;
}

def START_COUNTr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "start_count $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100001111000110001;
}

def START_TIME: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "start_time";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100101111000110000000000000000000000000000000;
}

def START_TIMEr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "start_time $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100101111000110001;
}

def STOPci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins boot_nz_cc:$cc, pc14:$pc);
	let AsmString        = "stop $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{47-22} = 0b00110100101110011000011000;
}

def STOP_COUNT: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "stop_count";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100001011000110000000000000000000000000000000;
}

def STOP_COUNTr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "stop_count $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100001011000110001;
}

def STOP_TIME: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins);
	let AsmString        = "stop_time";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let Inst{47-0} = 0b010100101011000110000000000000000000000000000000;
}

def STOP_TIMEr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins);
	let AsmString        = "stop_time $rc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{26-22} = rc{4-0};
	let Inst{47-27} = 0b010100101011000110001;
}

def SUBrir: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins u32_imm:$imm, SimpleRegOrCst:$ra);
	let AsmString        = "sub $rc, $imm, $ra";
	let Pattern          = [(set SimpleReg:$rc, (sub u32_imm:$imm, SimpleRegOrCst:$ra))];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0010;
}

def SUBrirc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s22_imm:$off, SimpleRegOrCst:$ra, sub_nz_cc:$cc);
	let AsmString        = "sub $rc, $off, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrirci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s8_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub $rc, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrirf: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "sub $rc, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, sub_nz_cc:$cc);
	let AsmString        = "sub $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrrif: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "sub $rc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "sub $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (sub SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b110000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "sub $rc, $ra, $rb, $cc";
	let Pattern          = [(set SimpleReg:$rc, (DPUSetCC (i32 imm:$cc), SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBzir: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, u32_imm:$imm, SimpleReg:$rb);
	let AsmString        = "sub $zero, $imm, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = imm{31};
	let Inst{27-23} = 0b00010;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def SUBzirci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, s12_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub $zero, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111010;
}

def SUBzirf: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "sub $zero, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00111010;
}

def SUBzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111100;
}

def SUBzrif: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "sub $zero, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00111100;
}

def SUBzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "sub $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110000;
}

def SUBzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111100;
}

def SUB_Srirc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s22_imm:$off, SimpleRegOrCst:$ra, sub_nz_cc:$cc);
	let AsmString        = "sub.s $dc, $off, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srirci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s8_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub.s $dc, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srirf: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "sub.s $dc, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, sub_nz_cc:$cc);
	let AsmString        = "sub.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "sub.s $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "sub.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b110000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "sub.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urirc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s22_imm:$off, SimpleRegOrCst:$ra, sub_nz_cc:$cc);
	let AsmString        = "sub.u $dc, $off, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urirci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s8_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub.u $dc, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urirf: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "sub.u $dc, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1010;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, sub_nz_cc:$cc);
	let AsmString        = "sub.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "sub.u $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "sub.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b110000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "sub.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUB_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "sub.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBCrir: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins u32_imm:$imm, SimpleRegOrCst:$ra);
	let AsmString        = "subc $rc, $imm, $ra";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0011;
}

def SUBCrirc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s22_imm:$off, SimpleRegOrCst:$ra, sub_nz_cc:$cc);
	let AsmString        = "subc $rc, $off, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrirci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s8_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc $rc, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrirf: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "subc $rc, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, sub_nz_cc:$cc);
	let AsmString        = "subc $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrrif: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "subc $rc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = 0b0000;
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "subc $rc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b110100;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "subc $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def SUBCzir: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, u32_imm:$imm, SimpleReg:$rb);
	let AsmString        = "subc $zero, $imm, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = imm{31};
	let Inst{27-23} = 0b00011;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def SUBCzirci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, s12_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc $zero, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111011;
}

def SUBCzirf: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "subc $zero, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00111011;
}

def SUBCzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<5> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111101;
}

def SUBCzrif: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "subc $zero, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110000000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00111101;
}

def SUBCzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "subc $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011110100;
}

def SUBCzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<5> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{47-40} = 0b00111101;
}

def SUBC_Srirc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s22_imm:$off, SimpleRegOrCst:$ra, sub_nz_cc:$cc);
	let AsmString        = "subc.s $dc, $off, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srirci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s8_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc.s $dc, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srirf: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "subc.s $dc, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, sub_nz_cc:$cc);
	let AsmString        = "subc.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "subc.s $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b10000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "subc.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b110100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "subc.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urirc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s22_imm:$off, SimpleRegOrCst:$ra, sub_nz_cc:$cc);
	let AsmString        = "subc.u $dc, $off, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urirci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s8_imm:$imm, SimpleRegOrCst:$ra, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc.u $dc, $imm, $ra, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urirf: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins s24_imm:$imm, SimpleRegOrCst:$ra, false_cc:$cc);
	let AsmString        = "subc.u $dc, $imm, $ra, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1011;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, sub_nz_cc:$cc);
	let AsmString        = "subc.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urrif: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm, false_cc:$cc);
	let AsmString        = "subc.u $dc, $ra, $imm, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> dc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{22-18} = 0b00000;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "subc.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b110100;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc);
	let AsmString        = "subc.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b1;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SUBC_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, sub_nz_cc:$cc, pc14:$pc);
	let AsmString        = "subc.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<5> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{38} = 0b0;
	let Inst{39} = cc{4};
	let Inst{43-40} = 0b1101;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SWrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, s16_imm:$imm);
	let AsmString        = "sw $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<16> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = imm{8-0};
	let Inst{21-14} = off{7-0};
	let Inst{24-22} = imm{11-9};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{15-12};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001010;
}

def SWrir: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, SimpleReg:$rb);
	let AsmString        = "sw $ra, $off, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<5> rb; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{21-14} = off{7-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111000110;
}

def SW_IDri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off);
	let AsmString        = "sw_id $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = 0b000000000;
	let Inst{21-14} = off{7-0};
	let Inst{32-22} = 0b11000011000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001110;
}

def SW_IDrii: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s13_imm:$off, s16_imm:$imm);
	let AsmString        = "sw_id $ra, $off, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<13> off; bits<16> imm; bits<5> ra;
	let Inst{4-0} = off{12-8};
	let Inst{13-5} = imm{8-0};
	let Inst{21-14} = off{7-0};
	let Inst{24-22} = imm{11-9};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{15-12};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0111001110;
}

def SWAPDrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins DoubleReg:$db);
	let AsmString        = "swapd $dc, $db";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> db;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{43-33} = 0b01000011000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def SWAPDrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins DoubleReg:$db, true_false_cc:$cc, pc14:$pc);
	let AsmString        = "swapd $dc, $db, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> dc; bits<5> db;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = dc{2-0};
	let Inst{27-25} = 0b111;
	let Inst{32-28} = db{4-0};
	let Inst{43-33} = 0b01000011000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def TELLri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleReg:$ra, s14_imm:$off);
	let AsmString        = "tell $ra, $off";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> off; bits<5> ra;
	let Inst{13-0} = off{13-0};
	let Inst{32-14} = 0b1111011100000000000;
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011010100;
}

def TWAIT_MASKri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s24_imm:$imm);
	let AsmString        = "twait_mask $ra, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<24> imm; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{17-14} = imm{3-0};
	let Inst{26-18} = 0b110010000;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{39-38} = imm{23-22};
	let Inst{47-40} = 0b00110100;
}

def UCODE1ric: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins SimpleReg:$rb, pc14:$pc, log_cc:$cc);
	let AsmString        = "ucode1 $rb, $pc, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> pc; bits<4> cc; bits<5> rb;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{47-33} = 0b001101101111000;
}

def UCODE2ic: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins pc14:$pc, log_cc:$cc);
	let AsmString        = "ucode2 $pc, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0010;
	let Inst{21-18} = cc{3-0};
	let Inst{47-22} = 0b00110110111100000000011000;
}

def XORrri: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, u32_imm:$imm);
	let AsmString        = "xor $rc, $ra, $imm";
	let Pattern          = [(set SimpleReg:$rc, (xor SimpleRegOrCst:$ra, u32_imm:$imm))];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rc; bits<5> ra;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{26-22} = rc{4-0};
	let Inst{30-27} = imm{31-28};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0100;
}

def XORrric: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "xor $rc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> rc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def XORrrici: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor $rc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def XORrrr: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "xor $rc, $ra, $rb";
	let Pattern          = [(set SimpleReg:$rc, (xor SimpleRegOrCst:$ra, SimpleReg:$rb))];
	let isAsCheapAsAMove = 1;
	bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{21-0} = 0b0000000000000000000000;
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def XORrrrc: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "xor $rc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> rc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000001;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def XORrrrci: DPUInstruction {
	let OutOperandList   = (outs SimpleReg:$rc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor $rc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc; bits<5> rc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = rc{2-0};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = rc{4-3};
	let Inst{47-46} = 0b00;
}

def XORzri: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleReg:$rb, u32_imm:$imm);
	let AsmString        = "xor $zero, $rb, $imm";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<32> imm; bits<5> rb;
	let Inst{13-0} = imm{21-8};
	let Inst{21-14} = imm{7-0};
	let Inst{22} = imm{31};
	let Inst{27-23} = 0b00100;
	let Inst{32-28} = rb{4-0};
	let Inst{35-33} = imm{30-28};
	let Inst{37-36} = 0b11;
	let Inst{43-38} = imm{27-22};
	let Inst{47-44} = 0b0110;
}

def XORzrici: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, s12_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor $zero, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<12> imm; bits<4> cc; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{24-22} = imm{10-8};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{38} = imm{11};
	let Inst{47-39} = 0b001100000;
}

def XORzrr: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "xor $zero, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> rb; bits<5> ra;
	let Inst{27-0} = 0b0110000000000000000000000000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000000;
}

def XORzrrci: DPUInstruction {
	let OutOperandList   = (outs);
	let InOperandList    = (ins ZeroRegister:$zero, SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor $zero, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<14> pc; bits<4> cc; bits<5> rb; bits<5> ra;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{27-22} = 0b011000;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{47-38} = 0b0011000000;
}

def XOR_Srric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "xor.s $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Srrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor.s $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Srrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "xor.s $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b10000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Srrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "xor.s $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Srrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor.s $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b1;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Urric: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s22_imm:$off, log_nz_cc:$cc);
	let AsmString        = "xor.u $dc, $ra, $off, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<22> off; bits<4> cc; bits<5> dc; bits<5> ra;
	let Inst{13-0} = off{21-8};
	let Inst{17-14} = off{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = off{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Urrici: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, s8_imm:$imm, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor.u $dc, $ra, $imm, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> ra; bits<14> pc; bits<8> imm; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = imm{3-0};
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{26-25} = 0b11;
	let Inst{30-27} = imm{7-4};
	let Inst{32-31} = 0b11;
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Urrr: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb);
	let AsmString        = "xor.u $dc, $ra, $rb";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{22-0} = 0b00000000000000000000000;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Urrrc: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc);
	let AsmString        = "xor.u $dc, $ra, $rb, $cc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	bits<4> cc; bits<5> dc; bits<5> rb; bits<5> ra;
	let Inst{17-0} = 0b000011111111111111;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000001;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

def XOR_Urrrci: DPUInstruction {
	let OutOperandList   = (outs DoubleReg:$dc);
	let InOperandList    = (ins SimpleRegOrCst:$ra, SimpleReg:$rb, log_nz_cc:$cc, pc14:$pc);
	let AsmString        = "xor.u $dc, $ra, $rb, $cc, $pc";
	let Pattern          = [];
	let isAsCheapAsAMove = 1;
	let isBranch         = 1;
	let isCompare        = 1;
	let isTerminator     = 1;
	bits<5> dc; bits<5> rb; bits<5> ra; bits<14> pc; bits<4> cc;
	let Inst{13-0} = pc{13-0};
	let Inst{17-14} = 0b0000;
	let Inst{21-18} = cc{3-0};
	let Inst{22} = 0b0;
	let Inst{24-23} = dc{2-1};
	let Inst{27-25} = 0b011;
	let Inst{32-28} = rb{4-0};
	let Inst{37-33} = ra{4-0};
	let Inst{43-38} = 0b000000;
	let Inst{45-44} = dc{4-3};
	let Inst{47-46} = 0b01;
}

