#include <stdint.h>
#include <stdio.h>

static uint32_t crc_make_table_element(uint32_t n) {
    uint32_t i;
    for (i = 0; i < 8; i++) {
        if (n & 1) {
            n = (n >> 1) ^ 0xedb88320;
        } else {
            n >>= 1;
        }
    }
    return n;
}

uint32_t crc_table[256];

static void crc_make_table(void) {
    uint32_t n;
    for (n = 0; n < 256; n++) {
        crc_table[n] = crc_make_table_element(n);
    }
}

#if 0 /* enable to use an assembly implementation of crc_add_byte() */
uint32_t crc_add_byte(uint32_t crc, uint8_t byte);
#else
uint32_t crc_add_byte(uint32_t crc, uint8_t byte) {
    return (crc >> 8) ^ crc_table[(crc & 0xff) ^ byte];
}
#endif /* 0 */

uint32_t crc_n_bytes(uint8_t byte, size_t n) {
    uint32_t crc = 0xffffffff;
    size_t i;
    for (i = 0; i < n; i++) {
        crc = crc_add_byte(crc, byte);
    }
    return crc;
}

int main(void) {
    crc_make_table();
    printf("%u\n", (unsigned)crc_n_bytes('t', 1000 * 1000 * 1000));
    return 0;
}
