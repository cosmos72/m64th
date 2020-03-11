#include <stddef.h>
#include <stdint.h>

int32_t add(int32_t a, int32_t b) {
    return a + b;
}

int32_t add_shift1(int32_t a, int32_t b) {
    return a + (b << 1);
}

int32_t add_shift2(int32_t a, int32_t b) {
    return a + (b << 2);
}

int32_t add_shift3(int32_t a, int32_t b) {
    return a + (b << 3);
}

int32_t less(int32_t a, int32_t b) {
    return a < b ? -1 : 0;
}
