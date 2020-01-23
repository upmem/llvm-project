#include <stdio.h>

void bar(unsigned i)
{
  printf("%d\n", i);
}

void foo(unsigned j)
{
  unsigned i = j;
  bar(i);
  i = 10;
  bar(i); // Set break point at this line.
}

int main() { int argc = 0; char **argv = (char **)0;

  foo(argc);
}
