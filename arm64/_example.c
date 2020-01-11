typedef unsigned long ulong;

typedef struct upair_s {
  ulong first, second;
} upair;
  


long one_plus(long a) {
  return a + 1;
}

long one_minus(long a) {
  return a - 1;
}

long zero(void) {
  return 0;
}

long neg(long a) {
  return -a;
}

long sub(long b, long a) {
  return a - b;
}

long mul(long a, long b) {
  return a * b;
}

ulong umul(ulong a, ulong b) {
  return a * b;
}

long div(long a, long b) {
  return a / b;
}

ulong udiv(ulong a, ulong b) {
  return a / b;
}

upair udiv_rem(ulong a, ulong b) {
  upair ret = { a/b, a%b };
  return ret;
}

long* push(long* addr, long val) {
  *--addr = val;
  return addr;
}

long* pop(long* addr, long *val) {
  *val = *addr++;
  return addr;
}

long get1(long* addr) {
  return addr[1];
}
