"""
Test basic commands.
"""

from __future__ import print_function

import lldb
from lldbsuite.test.decorators import *
from lldbsuite.test.lldbtest import *
from lldbsuite.test import lldbutil
from lldbsuite.test.lldbutil import get_stopped_thread


class BasicCommandsTestCase(TestBase):

    mydir = TestBase.compute_mydir(__file__)

    @add_test_categories(['pyapi'])
    def test_basic_commands(self):
        """Use Python APIs to check basic commands."""
        self.build()
        self.do_test_basic_commands()

    def setUp(self):
        # Call super's setUp().
        TestBase.setUp(self)
        self.main_first_line = line_number('main.c',
                                           '// Breakpoint location 1')
        self.fct1_call_line = line_number('main.c',
                                          '// Breakpoint location 2')
        self.step_1_line = line_number('main.c',
                                       ' // Step location 1')
        self.step_2_line = line_number('main.c',
                                       ' // Step location 2')
        self.step_in_entry_line = line_number('main.c',
                                              '// StepIn entry location')

    def do_test_basic_commands(self):
        exe = self.getBuildArtifact("a.out")
        filespec = lldb.SBFileSpec("main.c", False)

        target = self.dbg.CreateTarget(exe)
        self.assertTrue(target, VALID_TARGET)

        breakpoint = target.BreakpointCreateByLocation(filespec,
                                                       self.main_first_line)
        self.assertTrue(breakpoint and
                        breakpoint.GetNumLocations() == 1,
                        VALID_BREAKPOINT)

        breakpoint = target.BreakpointCreateByLocation(filespec,
                                                       self.fct1_call_line)
        self.assertTrue(breakpoint and
                        breakpoint.GetNumLocations() == 1,
                        VALID_BREAKPOINT)

        process = target.LaunchSimple(
            None, None, self.get_process_working_directory())
        self.assertTrue(process, PROCESS_IS_VALID)
        thread = get_stopped_thread(process, lldb.eStopReasonBreakpoint)
        self.assertTrue(thread.IsValid())
        frame0 = thread.GetFrameAtIndex(0)
        self.assertTrue(frame0.GetLineEntry().GetLine()
                        == self.main_first_line)
        ret_val = frame0.FindVariable('ret').GetValueAsUnsigned()
        self.assertTrue(frame0.FindVariable('arg').GetValueAsUnsigned() == 0)

        process.Continue()
        frame0 = thread.GetFrameAtIndex(0)
        self.assertTrue(frame0.GetLineEntry().GetLine() == self.fct1_call_line)
        self.assertTrue(frame0.FindVariable('ret').GetValueAsUnsigned()
                        == ret_val)
        self.assertTrue(frame0.FindVariable('arg').GetValueAsUnsigned() == 1)

        # step-inst
        while not re.search("->.*:[ ]*call", frame0.Disassemble()):
            thread.StepInstruction(False)
            frame0 = thread.GetFrameAtIndex(0)
        self.assertTrue(thread.GetNumFrames() == 2)
        self.assertTrue(frame0.GetFunction().GetName() == "main")
        self.assertTrue(frame0.FindVariable('ret').GetValueAsUnsigned()
                        == ret_val)
        self.assertTrue(frame0.FindVariable('arg').GetValueAsUnsigned() == 1)

        # step-inst
        thread.StepInstruction(False)
        self.assertTrue(thread.GetNumFrames() == 3)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-over
        frame0 = thread.GetFrameAtIndex(0)
        while frame0.GetLineEntry().GetLine() != self.step_1_line:
            thread.StepOver()
            frame0 = thread.GetFrameAtIndex(0)
            self.assertTrue(thread.GetNumFrames() == 3)

        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-into
        thread.StepInto()
        self.assertTrue(thread.GetNumFrames() == 4)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct2")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(2).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)
        frame0 = thread.GetFrameAtIndex(0)
        self.assertTrue(frame0.GetLineEntry().GetLine()
                        == self.step_in_entry_line)

        # step-over-inst
        while frame0.GetLineEntry().GetLine() != self.step_2_line:
            thread.StepInstruction(True)
            frame0 = thread.GetFrameAtIndex(0)
            self.assertTrue(thread.GetNumFrames() == 4)

        # step-inst
        while not re.search("->.*:[ ]*call", frame0.Disassemble()):
            thread.StepInstruction(False)
            frame0 = thread.GetFrameAtIndex(0)

        self.assertTrue(thread.GetNumFrames() == 4)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct2")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('val')
                        .GetValueAsUnsigned() == 142)
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(2).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)
        # step-inst
        thread.StepInstruction(False)
        self.assertTrue(thread.GetNumFrames() == 5)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct3")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('val')
                        .GetValueAsUnsigned() == 142)
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "fct2")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('val')
                        .GetValueAsUnsigned() == 142)
        self.assertTrue(thread.GetFrameAtIndex(2).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(3).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(3).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(3).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-inst
        frame0 = thread.GetFrameAtIndex(0)
        while not re.search("->.*: jump.*r23", frame0.Disassemble()):
            thread.StepInstruction(False)
            frame0 = thread.GetFrameAtIndex(0)
        self.assertTrue(thread.GetNumFrames() == 5)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct3")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('val')
                        .GetValueAsUnsigned() == 288)
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "fct2")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('val')
                        .GetValueAsUnsigned() == 142)
        self.assertTrue(thread.GetFrameAtIndex(2).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(3).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(3).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(3).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-out
        thread.StepOut()
        self.assertTrue(thread.GetNumFrames() == 4)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct2")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('val')
                        .GetValueAsUnsigned() == 142)
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(2).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(2).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-out
        thread.StepOut()
        self.assertTrue(thread.GetNumFrames() == 3)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('val')
                        .GetValueAsUnsigned() == 66)
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-inst
        frame0 = thread.GetFrameAtIndex(0)
        while not re.search("->.*: jump.*r23", frame0.Disassemble()):
            thread.StepInstruction(False)
            frame0 = thread.GetFrameAtIndex(0)
        self.assertTrue(thread.GetNumFrames() == 3)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "fct1")
        self.assertTrue(thread.GetFrameAtIndex(1).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(1).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-inst
        thread.StepInstruction(False)
        self.assertTrue(thread.GetNumFrames() == 2)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('ret')
                        .GetValueAsUnsigned() == ret_val)
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-over
        thread.StepOver()
        self.assertTrue(thread.GetNumFrames() == 2)
        self.assertTrue(thread.GetFrameAtIndex(0).GetFunction().GetName()
                        == "main")
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('ret')
                        .GetValueAsUnsigned() == 1445)
        self.assertTrue(thread.GetFrameAtIndex(0).FindVariable('arg')
                        .GetValueAsUnsigned() == 1)

        # step-out
        thread.StepOut()
        self.assertTrue(thread.GetNumFrames() == 1)

        process.Continue()
        self.assertTrue(process.GetState() == lldb.eStateExited)
        self.assertTrue(process.GetExitStatus() == 0xa5)
