#include <stdint.h>

extern uint64_t __udiv32(uint32_t dividend, uint32_t divider);

#include "../int_lib.h"

typedef su_int fixuint_t;
typedef si_int fixint_t;

// Returns: a / b

COMPILER_RT_ABI su_int __udivsi3(su_int a, su_int b) {
  uint64_t res = __udiv32(a, b);
  return (su_int) (res >> 32);
}
