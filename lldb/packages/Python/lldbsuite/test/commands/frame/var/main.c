#include <stdio.h>

int g_var = 200;

int
__main(int argc, char **argv)
{
  int test_var = 10;
  printf ("Set a breakpoint here: %d %d.\n", test_var, g_var);
  return 0;
}

int main() {
  return __main(0, (char **)0);
}
