#include <stddef.h>
#include <stdint.h>

typedef struct pair_s {
    size_t *addr;
    size_t val;
} pair;

pair pop(size_t *addr) {
    pair ret = {NULL, *addr++};
    ret.addr = addr;
    return ret;
}

size_t *push(size_t *addr, size_t val) {
    *--addr = val;
    return addr;
}

// ld_s*
int8_t ld_sb(int8_t *addr, int32_t i) {
    return addr[i];
}

int16_t ld_sh(int16_t *addr, int32_t i) {
    return addr[i];
}

int32_t ld_sw(int32_t *addr, int32_t i) {
    return addr[i];
}

// ld_u*
uint8_t ld_ub(uint8_t *addr, int32_t i) {
    return addr[i];
}

uint16_t ld_uh(uint16_t *addr, int32_t i) {
    return addr[i];
}

uint32_t ld_uw(uint32_t *addr, int32_t i) {
    return addr[i];
}

// stor*
void storb(int8_t *addr, int8_t val, int32_t i) {
    addr[i] = val;
}

void storh(int16_t *addr, int16_t val, int32_t i) {
    addr[i] = val;
}

void storw(int32_t *addr, int32_t val, int32_t i) {
    addr[i] = val;
}
