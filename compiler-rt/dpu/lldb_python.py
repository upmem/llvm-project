import sys
import os
import subprocess
import dpu
import lldb
import tempfile

binary = sys.argv[1]

debugger = lldb.SBDebugger().Create()
debugger.SetAsync(False)

target = debugger.CreateTarget(binary)
assert target.IsValid()

launch_info = lldb.SBLaunchInfo(None)
launch_info.SetWorkingDirectory(os.getcwd())

with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
    stdout_path = tmp_file.name

launch_info.AddOpenFileAction(1, stdout_path, False, True)

# process = target.Launch(debugger.GetListener(), None, None, ".",
#                         "stdout.txt", "stderr.txt", None, 0, False, error)
process = target.Launch(launch_info, lldb.SBError())
# process = target.LaunchSimple(None, None, ".")

# print(process)

assert process.IsValid()

with open(stdout_path, 'r') as file:
    stdout_data = file.read()

os.remove(stdout_path)

print(stdout_data)

# Cleanup LLDB
# lldb.SBDebugger.Terminate()
sys.exit(process.exit_state)
