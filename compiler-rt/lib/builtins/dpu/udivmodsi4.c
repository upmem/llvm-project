/*===-- udivmodsi4.c - Implement __udivmodsi4 ------------------------------===
 *
 *                    The LLVM Compiler Infrastructure
 *
 * This file is dual licensed under the MIT and the University of Illinois Open
 * Source Licenses. See LICENSE_LLVM.TXT for details.
 *
 * ===----------------------------------------------------------------------===
 *
 * This file implements __udivmodsi4 for the compiler_rt library.
 *
 * ===----------------------------------------------------------------------===
 */

#include <stdint.h>

extern uint64_t __udiv32(uint32_t dividend, uint32_t divider);

#include "int_lib.h"

/* Returns: a / b, *rem = a % b  */

COMPILER_RT_ABI su_int
__udivmodsi4(su_int a, su_int b, su_int *rem)
{
    uint64_t res = __udiv32(a, b);
    *rem = (su_int)res;
    return (su_int) (res >> 32);
}
