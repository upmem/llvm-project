/* Copyright 2024 UPMEM. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#include <stdint.h>

extern uint64_t __udiv32(uint32_t dividend, uint32_t divider);

/* int64_t */
void
__div32(int32_t dividend, int32_t divider
	, int32_t *p_q, int32_t *p_rem
	)
{
    uint64_t res;
    uint32_t q;
    uint32_t rem;

    __asm__ goto("clo zero, %[dividend], z, %l[__div32_pos_dividend]\n\t"
                 "clo zero, %[divider], z, %l[__div32_neg_dividend_pos_divider]\n\t"
                 :
                 : [dividend] "r"(dividend), [divider] "r"(divider)
                 :
                 : __div32_pos_dividend, __div32_neg_dividend_pos_divider);

    /* The quotient's sign depends on the sign of the dividend and divider... After few tries it sounds */
    /* like the quickest way to select the operators is to branch according to the cases. */

    /* __div32_neg_dividend_neg_divider: */
    /* As a result, the quotient is positive and the remainder negative */
    dividend = 0 - dividend;
    divider = 0 - divider;
    res = __udiv32(dividend, divider);
    q = (uint32_t)(res >> 32);
    rem = (uint32_t)res;
    rem = 0 - rem;
    goto recombine;

    /* *p_q = q; */
    /* *p_rem = rem; */
    /* return; */

    
__div32_neg_dividend_pos_divider:
    /* As a result, the quotient is negative and the remainder negative */
    dividend = 0 - dividend;
    res = __udiv32(dividend, divider);
    q = (uint32_t)(res >> 32);
    q = 0 - q;
    rem = (uint32_t)res;
    rem = 0 - rem;
    goto recombine;
    /* *p_q = q; */
    /* *p_rem = rem; */
    /* return; */

__div32_pos_dividend:
    __asm__ goto("clo zero, %[divider], z, %l[__div32_pos_dividend_pos_divider]"
                 :
                 : [divider] "r"(divider)
                 :
                 : __div32_pos_dividend_pos_divider);
    /* As a result, the quotient is negative and the remainder positive */
    divider = 0 - divider;
    res = __udiv32(dividend, divider);
    q = (uint32_t)(res >> 32);
    q = 0 - q;
    rem = (uint32_t)res;
    goto recombine;
    /* *p_q = q; */
    /* *p_rem = rem; */
    /* return; */

__div32_pos_dividend_pos_divider:
    /* The dividend and divider are both positive */
    res = __udiv32(dividend, divider);
    /* goto last_exit; */
    q = (uint32_t) (res >> 32);
    rem = (uint32_t) res;
    /* goto recombine; */

    /* *p_q = q; */
    /* *p_rem = rem; */
    
/* recombine: */
/*     res = q; */
/*     res <<= 32; */
/*     res |= rem; */
/* last_exit: */
/*     return res; */

 recombine:
    *p_q = q;
    *p_rem = rem;
    return;
}
