#include <stdio.h>
#include <unistd.h>

int main() { int argc = 0; char **argv = (char **)0;

    lldb_enable_attach();

    printf("pid = %i\n", getpid());
    sleep(10);
    return 0; // breakpoint 1
}
