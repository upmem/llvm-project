#include "../int_lib.h"

typedef su_int fixuint_t;
typedef si_int fixint_t;

/* extern void uint64_t __attribute__((used)) __udiv32(uint32_t dividend, uint32_t divider) */
#include "udiv32_stepper.c"

// Returns: a / b

COMPILER_RT_ABI su_int __udivsi3(su_int a, su_int b) {
  uint64_t res = __udiv32(a, b);
  return (su_int) (res >> 32);
  /* return 42; */
}
