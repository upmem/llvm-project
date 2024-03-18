//===-- UnwindDPU.cpp -------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "lldb/Core/Module.h"
#include "lldb/Symbol/FuncUnwinders.h"
#include "lldb/Symbol/Function.h"
#include "lldb/Symbol/UnwindPlan.h"
#include "lldb/Target/ABI.h"
#include "lldb/Target/Process.h"
#include "lldb/Target/RegisterContext.h"
#include "lldb/Target/Target.h"
#include "lldb/Target/Thread.h"
#include "lldb/Utility/Log.h"
#include "lldb/Utility/RegisterValue.h"

#include "RegisterContextDPU.h"
#include "UnwindDPU.h"

using namespace lldb;
using namespace lldb_private;

UnwindDPU::UnwindDPU(Thread &thread) : Unwind(thread), m_frames() {}

void UnwindDPU::DoClear() { m_frames.clear(); }

#define FORMAT_PC(pc) (0x80000000 | ((pc)*8))

bool UnwindDPU::SetFrame(CursorSP *prev_frame, lldb::addr_t cfa,
                         lldb::addr_t pc, Address &fct_base_addr) {
  constexpr std::size_t nb_frame_max = 256;
  if (m_frames.size() > nb_frame_max)
    return false;

  CursorSP new_frame(new Cursor());
  RegisterContextDPUSP prev_reg_ctx_sp =
      *prev_frame != NULL ? (*prev_frame)->reg_ctx_sp : NULL;
  RegisterContextDPUSP new_reg_ctx_sp(new RegisterContextDPU(
      m_thread, prev_reg_ctx_sp, cfa, pc, m_frames.size()));
  new_frame->cfa = cfa;
  new_frame->pc = pc;
  new_frame->reg_ctx_sp = new_reg_ctx_sp;
  m_frames.push_back(new_frame);
  *prev_frame = new_frame;

  // If the current function is __bootstrap, we can stop the unwinding
  if ((*prev_frame)->reg_ctx_sp->GetFunctionBaseAddress(fct_base_addr, pc) &&
      fct_base_addr.GetFileAddress() == FORMAT_PC(0)) {
    return false;
  }

  return true;
}

uint32_t UnwindDPU::DoGetFrameCount() {
  if (!m_frames.empty())
    return m_frames.size();

  lldb::RegisterContextSP reg_ctx_sp = m_thread.GetRegisterContext();

  RegisterValue reg_r22, reg_pc;
  reg_ctx_sp->ReadRegister(reg_ctx_sp->GetRegisterInfoByName("r22"), reg_r22);
  reg_ctx_sp->ReadRegister(reg_ctx_sp->GetRegisterInfoByName("pc"), reg_pc);

  CursorSP prev_frame = NULL;
  lldb::addr_t first_pc_addr = reg_pc.GetAsUInt32();
  lldb::addr_t first_r22_value = reg_r22.GetAsUInt32();

  Address fct_base_addr;
  if (!SetFrame(&prev_frame, first_r22_value, first_pc_addr, fct_base_addr))
    return m_frames.size();

  lldb::addr_t start_addr = fct_base_addr.GetFileAddress();
  int32_t cfa_offset = 1;
  if (start_addr != LLDB_INVALID_ADDRESS) {
    // Check if we have the stack size save in the cfi information.
    // If we have it, use it to set the cfa in order to have it set to the right
    // value from the beginning so that comparison between frame always give the
    // expected answer.
    UnwindPlanSP unwind_plan_sp(new UnwindPlan(lldb::eRegisterKindGeneric));
    if (prev_frame->reg_ctx_sp->GetUnwindPlanSP(fct_base_addr,
                                                unwind_plan_sp)) {
      if (unwind_plan_sp->IsValidRowIndex(0)) {
        UnwindPlan::RowSP row = unwind_plan_sp->GetRowAtIndex(0);
        UnwindPlan::Row::FAValue &CFAValue = row->GetCFAValue();
        if (!CFAValue.IsUnspecified())
          cfa_offset = -CFAValue.GetOffset();
      }
    }
  }
  // If we are in the 2 first instruction of the function, or in the return
  // instruction of the function, the information to get the next frame are not
  // the same as usual. r22 is already the good one. pc is in r23.
  // Also, if the cfa_offset is null, it means that we are a leaf, function,
  // apply same method to compute the frame (but add 1 to the cfa in order to
  // differenciate it from the previous frame (StackID comparison).
  if ((start_addr != LLDB_INVALID_ADDRESS) &&
      (((first_pc_addr >= start_addr) && (first_pc_addr < (start_addr + 16))) ||
       prev_frame->reg_ctx_sp->PCIsInstructionReturn(first_pc_addr) ||
       cfa_offset == 0)) {
    RegisterValue reg_r23;
    reg_ctx_sp->ReadRegister(reg_ctx_sp->GetRegisterInfoByName("r23"), reg_r23);
    prev_frame->cfa += (cfa_offset == 0 ? 1 : cfa_offset);
    if (!SetFrame(&prev_frame, first_r22_value,
                  FORMAT_PC(reg_r23.GetAsUInt32()), fct_base_addr))
      return m_frames.size();
  }

  while (true) {
    Status error;
    lldb::addr_t cfa_addr = 0;
    lldb::addr_t pc_addr = 0;
    const uint32_t reg_size_in_bytes = 4;
    if ((m_thread.GetProcess()->ReadMemory(prev_frame->cfa - 4, &cfa_addr,
                                           reg_size_in_bytes,
                                           error) != reg_size_in_bytes) ||
        (m_thread.GetProcess()->ReadMemory(prev_frame->cfa - 8, &pc_addr,
                                           reg_size_in_bytes,
                                           error) != reg_size_in_bytes) ||
        (!SetFrame(&prev_frame, cfa_addr, FORMAT_PC(pc_addr), fct_base_addr)))
      return m_frames.size();
  }

  return m_frames.size();
}

bool UnwindDPU::DoGetFrameInfoAtIndex(uint32_t frame_idx, lldb::addr_t &cfa,
                                      lldb::addr_t &pc, bool &behaves_like_zeroth_frame) {
  if (frame_idx >= DoGetFrameCount())
    return false;

  behaves_like_zeroth_frame = frame_idx == 0;
  cfa = m_frames[frame_idx]->cfa;
  pc = m_frames[frame_idx]->pc;

  Status error;
  lldb::addr_t overlay_start_address;
  // FIXME : try and fetch symbol instead of trusting overlay_start_address will always be stored at the same address in the elf
  if(m_thread.GetProcess()->ReadMemory(0x0000008, &overlay_start_address, 8, error) == 8) {
    overlay_start_address <<= 3;
    overlay_start_address += 0x80000000;
    if (pc >= overlay_start_address && overlay_start_address != 0x80000000) {
      uint32_t loaded_group_value;
      // FIXME : try and fetch symbol instead of trusting the loaded_group will always be stored at the same address in the elf
      if(m_thread.GetProcess()->ReadMemory(0x0000010, &loaded_group_value, 4, error) == 4) {
        pc += 0x00100000*(loaded_group_value+1);
      }
    }
  }

  return true;
}

lldb::RegisterContextSP
UnwindDPU::DoCreateRegisterContextForFrame(lldb_private::StackFrame *frame) {
  lldb::RegisterContextSP reg_ctx_sp;
  uint32_t frame_idx = frame->GetConcreteFrameIndex();

  if (frame_idx >= DoGetFrameCount())
    return reg_ctx_sp;

  Cursor *frame_cursor = m_frames[frame_idx].get();
  reg_ctx_sp = frame_cursor->reg_ctx_sp;
  return reg_ctx_sp;
}
