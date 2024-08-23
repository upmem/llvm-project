/* Copyright 2024 UPMEM. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#include <stdint.h>

/* extern int64_t __div32(int32_t dividend, int32_t divider); */
extern void __div32(int32_t dividend, int32_t divider, int32_t *q, int32_t *rem);

#include "int_lib.h"

COMPILER_RT_ABI si_int
__divsi3(si_int a, si_int b)
{
  /* int64_t res = __div32(a, b); */
  /* return (si_int) (res >> 32); */
  
  int32_t q;
  int32_t rem;
  __div32(a, b, &q, &rem);
  return q;
}
