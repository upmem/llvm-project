#include <stdint.h>

int32_t __mulsi3(int32_t a, int32_t b)
{
    int32_t dest;

    int32_t temp0;
    uint64_t temp1;

    this is not working yet ...
      temp1.hi/temp1.lo is not yet supported
      
    __asm__ volatile("  jgtu %[b], %[a], 1f\n"
                     "  move %[temp0], %[a]\n"
                     "  move %[temp1.hi], %[b], true, 2f\n"
                     "1:\n"
                     "  move %[temp0], %[b]\n"
                     "  move %[temp1.hi], %[a]\n"
                     "2:\n"
                     "  move r1, zero\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 0 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 1 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 2 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 3 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 4 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 5 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 6 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 7 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 8 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 9 , z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 10, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 11, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 12, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 13, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 14, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 15, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 16, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 17, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 18, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 19, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 20, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 21, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 22, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 23, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 24, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 25, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 26, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 27, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 28, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 29, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 30, z, 3f\n"
                     "  mul_step %[temp1], %[temp0], %[temp1], 31, z, 3f\n"
                     "3:\n"
                     "  move %[dest], %[temp1.lo]\n"
                     : [dest] "=&r"(dest), [temp0] "=&r"(temp0), [temp1] "=&r"(temp1)
                     : [a]"r"(a), [b]"r"(b)
                     : );
    return dest;
}
