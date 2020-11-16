#include <stdatomic.h>

long atomic_inc(volatile long *addr) {
    return atomic_fetch_add(addr, 1);
}

long atomic_dec(volatile long *addr) {
    return atomic_fetch_add(addr, -1);
}

int main() {
}
