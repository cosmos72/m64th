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
#include "include/hashmap_number.h"
#include "include/token.h"
#include "include/word_fwd.h"
#include "linenoise/linenoise.h" /* linenoiseStrings */

#include <assert.h> /* assert()                   */
#include <errno.h>  /* errno                      */
#include <stdlib.h> /* strtol()                   */
#include <string.h> /* memcmp() memcpy() strlen() */

/** temporary C implementation of '.' */
void m4th_dot(m4cell n, m4iobuf *io) {
    m4ucell len;
    enum { N = SZ * 3 + 2 }; /* large enough also for sign and final space */
    char buf[N];
    char *addr = buf + N;

    *--addr = ' ';

    if (n == 0) {
        *--addr = '0';
    } else {
        m4cell negative = n < 0;
        m4ucell u = (m4ucell)(negative ? -n : n);

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

/**
 * temporary C implementation of 'du/mod' i.e. full 128bit unsigned division
 */
typedef unsigned __int128 uint128_t;
typedef struct {
    uint64_t hi, lo;
} uint128_forth_stack;

void m4th_ud_div_mod(uint128_forth_stack *dividend_in_remainder_out,
                     uint128_forth_stack *divisor_in_quotient_out) {
    const uint128_t dividend =
        (uint128_t)dividend_in_remainder_out->hi << 64 | dividend_in_remainder_out->lo;
    const uint128_t divisor =
        (uint128_t)divisor_in_quotient_out->hi << 64 | divisor_in_quotient_out->lo;
    const uint128_t remainder = dividend % divisor;
    const uint128_t quotient = dividend / divisor;
    dividend_in_remainder_out->hi = remainder >> 64;
    dividend_in_remainder_out->lo = remainder;
    divisor_in_quotient_out->hi = quotient >> 64;
    divisor_in_quotient_out->lo = quotient;
}

/******************************************************************************/
/* C implementation of CRC32c                                                 */
/******************************************************************************/
m4cell m4th_crctable[256];

void m4th_crcinit(m4cell table[256]) {
    uint32_t i, j;

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

uint32_t m4th_crc_array(const void *addr, const m4ucell nbytes) {
    assert(m4th_crctable[0xff]);
    const m4char *p = (const m4char *)addr;
    uint32_t crc = ~(uint32_t)0;
    for (size_t i = 0; i < nbytes; i++) {
        crc = m4th_crc1byte(crc, p[i]);
    }
    return ~crc;
}

uint32_t m4th_crc_cell(m4cell key) {
    return m4th_crc_array(&key, sizeof(key));
}

uint32_t m4th_crc_string(m4string str) {
    return m4th_crc_array(str.addr, str.n);
}

#if defined(__x86_64__)

#include <cpuid.h>

/* C wrapper for cpuid() */
static void m4th_cpuid(unsigned level, unsigned count, unsigned ret[4]) {
    unsigned max_level = __get_cpuid_max(level & 0x80000000ul, NULL);
    ret[0] = ret[1] = ret[2] = ret[3] = 0;
    if (max_level != 0 && level <= max_level) {
        __cpuid_count(level, count, ret[0], ret[1], ret[2], ret[3]);
    }
}

/* amd64: use cpuid to detect CRC32c CPU instructions - they are part of SSE4.2 */
m4cell m4th_cpu_features_detect(void) {
    unsigned ret[4];
    m4th_cpuid(1, 0, ret);
    return (ret[2] & bit_SSE4_2) ? m4th_cpu_feature_crc32c | m4th_cpu_feature_atomic_add
                                 : m4th_cpu_feature_atomic_add;
}

#elif defined(__aarch64__) && defined(__linux__)

#include <asm/hwcap.h>
#include <sys/auxv.h>
/*
 * arm64+Linux: use Linux specific getauxval(AT_HWCAP)
 * to detect CRC32c and atomic CPU instructions
 */
m4cell m4th_cpu_features_detect(void) {
    unsigned long hwcap = getauxval(AT_HWCAP);
    m4cell ret = 0;
    if (hwcap & HWCAP_CRC32) {
        ret |= m4th_cpu_feature_crc32c;
    }
    if (hwcap & HWCAP_ATOMICS) {
        ret |= m4th_cpu_feature_atomic_add;
    }
    return ret;
}

#elif defined(__aarch64__) && defined(__ANDROID__)

#include <cpu-features.h>
/* arm64+Android: use Android specific android_getCpuFeatures() to detect CRC32c CPU
   instructions */
m4cell m4th_cpu_features_detect(void) {
    uint64_t features = android_getCpuFeatures();
    return (features & ANDROID_CPU_ARM64_FEATURE_CRC32) ? m4th_cpu_feature_crc32c : 0;
}

#else

/* no support to detect CRC32c CPU instructions on this arch/OS pair */
m4cell m4th_cpu_features_detect(void) {
    return m4th_cpu_feature_cannot_detect;
}

#endif

void m4th_cpu_features_autoenable() {
    m4th_cpu_features_enable(m4th_cpu_features_detect());
}
