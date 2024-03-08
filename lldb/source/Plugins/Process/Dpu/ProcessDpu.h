//===-- ProcessDpu.h ---------------------------------- -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef liblldb_ProcessDpu_H_
#define liblldb_ProcessDpu_H_

#include <csignal>
#include <unordered_set>

#include "lldb/Host/Debug.h"
#include "lldb/Host/HostThread.h"
#include "lldb/Host/linux/Support.h"
#include "lldb/Target/MemoryRegionInfo.h"
#include "lldb/Utility/ArchSpec.h"
#include "lldb/Utility/FileSpec.h"
#include "lldb/lldb-forward.h" // for IOObjectSP
#include "lldb/lldb-types.h"

#include "ThreadDpu.h"
#include "lldb/Host/common/NativeProcessProtocol.h"

namespace lldb_private {
class Status;
class Scalar;

namespace dpu {
class Dpu;
class DpuRank;
class DpuContext;

const ArchSpec k_dpu_arch("dpu-upmem-dpurte");

constexpr lldb::addr_t k_dpu_wram_base = 0x00000000;
constexpr lldb::addr_t k_dpu_mram_base = 0x08000000;
constexpr lldb::addr_t k_dpu_iram_base = 0x80000000;
} // namespace dpu

namespace process_dpu {
/// @class ProcessDpu
/// Manages communication with the inferior (debugee) process.
///
/// Changes in the inferior process state are broadcasted.
class ProcessDpu : public NativeProcessProtocol {
public:
  class Factory : public NativeProcessProtocol::Factory {
  public:
    llvm::Expected<std::unique_ptr<NativeProcessProtocol>>
    Launch(ProcessLaunchInfo &launch_info, NativeDelegate &native_delegate,
           MainLoop &mainloop) const override;

    llvm::Expected<std::unique_ptr<NativeProcessProtocol>>
    Attach(lldb::pid_t pid, NativeDelegate &native_delegate,
           MainLoop &mainloop) const override;
  };

  static lldb::ProcessSP
  CreateInstance(lldb::TargetSP target_sp, lldb::ListenerSP listener_sp,
                 const lldb_private::FileSpec *crash_file_path,
                 bool can_connect);

  static void Initialize();

  static void Terminate();

  static lldb_private::ConstString GetPluginNameStatic();

  static const char *GetPluginDescriptionStatic();

  // ---------------------------------------------------------------------
  // NativeProcessProtocol Interface
  // ---------------------------------------------------------------------
  Status Resume(const ResumeActionList &resume_actions) override;

  Status Halt() override;

  Status Detach() override;

  Status Signal(int signo) override;

  Status Interrupt() override;

  Status Kill() override;

  Status GetMemoryRegionInfo(lldb::addr_t load_addr,
                             MemoryRegionInfo &range_info) override;

  Status ReadMemory(lldb::addr_t addr, void *buf, size_t size,
                    size_t &bytes_read) override;

  Status WriteMemory(lldb::addr_t addr, const void *buf, size_t size,
                     size_t &bytes_written) override;

  virtual llvm::Expected<lldb::addr_t>
  AllocateMemory(size_t size, uint32_t permissions) override;

  virtual llvm::Error DeallocateMemory(lldb::addr_t addr) override;

  lldb::addr_t GetSharedLibraryInfoAddress() override;

  size_t UpdateThreads() override;

  const ArchSpec &GetArchitecture() const override { return m_arch; }

  Status SetBreakpoint(lldb::addr_t addr, uint32_t size,
                       bool hardware) override;

  Status RemoveBreakpoint(lldb::addr_t addr, bool hardware = false) override;

  Status GetLoadedModuleFileSpec(const char *module_path,
                                 FileSpec &file_spec) override;

  Status GetFileLoadAddress(const llvm::StringRef &file_name,
                            lldb::addr_t &load_addr) override;

  ThreadDpu *GetThreadByID(lldb::tid_t id);

  llvm::ErrorOr<std::unique_ptr<llvm::MemoryBuffer>>
  GetAuxvData() const override {
    return getProcFile(GetID(), "auxv");
  }

  // ---------------------------------------------------------------------
  // Interface used by RegisterContext-derived classes.
  // ---------------------------------------------------------------------
  bool SupportHardwareSingleStepping() const;

  // ---------------------------------------------------------------------
  // Other methods
  // ---------------------------------------------------------------------
  void GetThreadContext(int thread_index, uint32_t *&regs, uint16_t *&pc,
                        bool *&zf, bool *&cf,
                        bool *&registers_has_been_modified);

  lldb::StateType GetThreadState(int thread_index, std::string &description,
                                 lldb::StopReason &stop_reason, bool stepping);

  bool StepThread(uint32_t thread_id);

  void SaveCore(const char *save_core_filename, const char *executable_path,
                Status &error) override;

  void SetDpuPrintInfo(const uint32_t open_print_sequence_addr,
                       const uint32_t close_print_sequence_addr,
                       const uint32_t print_buffer_addr,
                       const uint32_t print_buffer_size,
                       const uint32_t print_buffer_var_addr,
                       Status &error) override;

private:
  ProcessDpu(::pid_t pid, int terminal_fd, NativeDelegate &delegate,
             const ArchSpec &arch, MainLoop &mainloop, dpu::DpuRank *rank,
             dpu::Dpu *dpu);

  void InterfaceTimerCallback();

  Status DpuErrorStatus(const char *message);

  ArchSpec m_arch;
  lldb::IOObjectSP m_timer_fd;
  MainLoop::ReadHandleUP m_timer_handle;
  dpu::Dpu *m_dpu;
  dpu::DpuRank *m_rank;
  MemoryRegionInfo m_iram_region;
  MemoryRegionInfo m_mram_region;
  MemoryRegionInfo m_wram_region;

  lldb::addr_t m_iram_size;
  lldb::addr_t m_mram_size;
  lldb::addr_t m_wram_size;
};

} // namespace process_dpu
} // namespace lldb_private

#endif // #ifndef liblldb_ProcessDpu_H_
