/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m4th.
 *
 * m4th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m4th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m4th.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "impl.h"
#include "include/err.h"
#include "include/token.h"
#include "include/word_fwd.h"

#include <assert.h> /* assert()                   */
#include <errno.h>  /* errno                      */
#include <stdlib.h> /* strtol()                   */
#include <string.h> /* memcmp() memcpy() strlen() */

/** wrapper around REPL */
m4cell m4th_repl(m4th *m) {
    return m4th_execute_word(m, &m4w_repl);
}

/** temporary C implementation of '.' */
void m4th_dot(m4cell n, m4iobuf *io) {
    m4cell_u len;
    enum { N = SZ * 3 + 2 }; /* large enough also for sign and final space */
    char buf[N];
    char *addr = buf + N;

    *--addr = ' ';

    if (n == 0) {
        *--addr = '0';
    } else {
        m4cell negative = n < 0;
        m4cell_u u = (m4cell_u)(negative ? -n : n);

        while (u != 0) {
            *--addr = (u % 10) + '0';
            u /= 10;
        }
        if (negative) {
            *--addr = '-';
        }
    }
    len = buf + N - addr;
    if (io->max - io->end >= len) {
        memcpy(io->addr + io->end, addr, len);
        io->end += len;
        return;
    }
}

/* temporary C implementation of CRC32c */
m4cell m4th_crctable[256];

void m4th_crcinit(m4cell table[256]) {
    int i, j;

    if (table[255] != 0) {
        return;
    }
    for (i = 0; i < 256; i++) {
        uint32_t val = i;
        for (j = 0; j < 8; j++) {
            if (val & 1) {
                val >>= 1;
                /* 0x82f63b78 is crc-32c (Castagnoli). Use 0xedb88320 for vanilla crc-32. */
                val ^= 0x82f63b78;
            } else {
                val >>= 1;
            }
        }
        table[i] = val;
    }
}

uint32_t m4th_crc1byte(uint32_t crc, unsigned char byte) {
    return (crc >> 8) ^ m4th_crctable[(crc & 0xff) ^ byte];
}

uint32_t m4th_crcstring(m4string str) {
    assert(m4th_crctable[0xff]);
    uint32_t crc = ~(uint32_t)0;
    for (size_t i = 0; i < str.n; i++) {
        crc = m4th_crc1byte(crc, str.addr[i]);
    }
    return ~crc;
}

#if defined(__x86_64__)

#include <cpuid.h>

/* C implementation of cpuid() */
static void m4th_cpuid(unsigned level, unsigned count, unsigned ret[4]) {
    unsigned max_level = __get_cpuid_max(level & 0x80000000ul, NULL);
    ret[0] = ret[1] = ret[2] = ret[3] = count & 0;
    if (max_level != 0 && level <= max_level) {
        __cpuid_count(level, count, ret[0], ret[1], ret[2], ret[3]);
    }
}

/* C implementation of cpu_has_crc32c_asm_instructions() */
m4cell m4th_crc_simd_detect(void) {
    unsigned ret[4];
    m4th_cpuid(1, 0, ret);
    return (ret[2] & bit_SSE4_2) ? ttrue : tfalse;
}

#elif defined(__aarch64__) && defined(__linux__)

#include <asm/hwcap.h>
#include <sys/auxv.h>
/* Linux/Android specific: use getauxval(AT_HWCAP) to detect CRC32c CPU instructions */
m4cell m4th_crc_simd_detect(void) {
    unsigned long hwcap = getauxval(AT_HWCAP);
    return (hwcap & HWCAP_CRC32) ? ttrue : tfalse;
}

#else

/* no support to detect CRC32c CPU instructions on this arch/OS pair */
m4cell m4th_crc_simd_detect(void) {
    return 1; /* unknown */
}

#endif

void m4th_crc_simd_auto() {
    m4th_crc_simd_enable(m4th_crc_simd_detect());
}
