#include <stdint.h>

extern int32_t __mul32(int32_t a, int32_t b);

int32_t __mulsi3(int32_t a, int32_t b)
{
  return __mul32(a, b);
}
