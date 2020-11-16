#include <stdatomic.h>
#include <stdint.h>

int64_t atomic_inc(volatile _Atomic int64_t *addr) {
    return atomic_fetch_add(addr, 1);
}

int64_t atomic_add(volatile _Atomic int64_t *addr, int64_t delta) {
    return atomic_fetch_add(addr, delta);
}

int main() {
}
