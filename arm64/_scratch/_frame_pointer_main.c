#include <stdio.h>

extern int foo(void);

void bar(void) {
   fputs("bar\n", stdout);
}

int main(void) {
   return foo();
}
