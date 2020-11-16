#include <stdio.h>

struct m4th_s;
typedef struct m4th_s m4th;

__thread m4th * m;

m4th* get_m(void) {
  return m;
}

void set_m(m4th* new_m) {
  m = new_m;
}

int main(void) {
  printf("%p %p\n", get_m, set_m);
}

