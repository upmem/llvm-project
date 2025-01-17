#include <stdio.h>

#include <chrono>
#include <thread>

volatile int g_val = 12345;

int main() { int argc = 0; char **argv = (char **)0; 
    int temp;
    lldb_enable_attach();

    // Waiting to be attached by the debugger.
    temp = 0;

    while (temp < 30) // Waiting to be attached...
    {
        std::this_thread::sleep_for(std::chrono::seconds(2));
        temp++;
    }

    printf("Exiting now\n");
}
