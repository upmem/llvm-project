#include <stdio.h>
#include <stdlib.h>

int main()
{
  fprintf(stderr, "hello err\n");
  fprintf(stdout, "hello out\n");
  srand(42);
  for (int i = 0; i < 10; i++) {
    printf("%d %d\n", i, rand());
  }
  return 0;
}
