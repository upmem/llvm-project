/* ===-- modsi3.c - Implement __modsi3 -------------------------------------===
 *
 *                     The LLVM Compiler Infrastructure
 *
 * This file is dual licensed under the MIT and the University of Illinois Open
 * Source Licenses. See LICENSE_LLVM.TXT for details.
 *
 * ===----------------------------------------------------------------------===
 *
 * This file implements __modsi3 for the compiler_rt library.
 *
 * ===----------------------------------------------------------------------===
 */

#include <stdint.h>

/* extern int64_t __div32(int32_t dividend, int32_t divider); */
extern void __div32(int32_t dividend, int32_t divider, int32_t *q, int32_t *rem);

#include "int_lib.h"

/* Returns: a % b */

COMPILER_RT_ABI si_int
__modsi3(si_int a, si_int b)
{
    /* int64_t res = __div32(a, b); */
    /* return (si_int) res; */
  
  int32_t q;
  int32_t rem;
  __div32(a, b, &q, &rem);
  return rem;
}
