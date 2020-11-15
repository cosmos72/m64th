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

typedef struct {
    m4short n; /* -1 if not optimized sequence was found */
    m4token tok[3];
} m4token3;

/* find optimized sequence for a single token */
m4token3 find_opt1(m4token tok) {
    m4string str = m4word_data(&WORD_SYM(_optimize_1token_), 0);
    const m4token3 *optv = (const m4token3 *)str.addr;
    m4token3 ret = {-1, {}};
    m4ucell i, n = str.n / sizeof(m4token3);
    for (i = 0; i < n; i++) {
        const m4token3 *opt = &optv[i];
        if (opt->tok[0] == tok) {
            ret.n = opt->n;
            ret.tok[0] = opt->tok[1];
            ret.tok[1] = opt->tok[2];
            break;
        }
    }
    return ret;
}

/* find optimized sequence for a token pair */
m4token3 find_opt2(const m4token tok[2]) {
    const m4hashmap_int *map =
        (const m4hashmap_int *)m4word_data(&WORD_SYM(_optimize_2token_), 0).addr;
    const m4int key = tok[0] | ((m4int)tok[1] << 16);
    const m4hashmap_entry_int *entry = m4hashmap_find_int(map, key);
    union {
        m4ucell val;
        m4token3 tok3;
    } ret;
    if (entry == NULL) {
        ret.tok3.n = -1;
    } else {
        ret.val = (m4ucell)entry->val;
    }
    return ret.tok3;
}

/* find optimized sequence for a token triple */
m4token3 find_opt3(const m4token tok[3]) {
    const m4hashmap_cell *map =
        (const m4hashmap_cell *)m4word_data(&WORD_SYM(_optimize_3token_), 0).addr;
    const m4cell key = tok[0] | ((m4cell)tok[1] << 16) | ((m4cell)tok[2] << 32);
    const m4hashmap_entry_cell *entry = m4hashmap_find_cell(map, key);
    union {
        m4ucell val;
        m4token3 tok3;
    } ret;
    if (entry == NULL) {
        ret.tok3.n = -1;
    } else {
        ret.val = (m4ucell)entry->val;
    }
    return ret.tok3;
}

typedef struct {
    m4token *start;
    m4token *end;
} m4code_range;

typedef struct {
    m4code_range code;
    m4ucell flag;
} m4code_range_flag;

static m4token *copy_tok3(m4token3 src, m4token *dst) {
    memcpy(dst, src.tok, src.n * sizeof(m4token));
    return dst + src.n;
}

static m4code_range_flag optimize_once(m4code_range in) {
    m4code_range out = {in.end, in.end};
    const m4token *p = in.start;
    m4cell n;
    m4ucell flag = tfalse;
    while (p < in.end) {
        m4token tok1 = *p;
        m4token3 opt;
        if ((opt = find_opt1(tok1)).n >= 0) {
            n = 1;
        } else if (p + 2 <= in.end && (opt = find_opt2(p)).n >= 0) {
            n = 2;
        } else if (p + 3 <= in.end && (opt = find_opt3(p)).n >= 0) {
            n = 3;
        } else {
            n = 0;
            /* no optimization found, just copy a single token */
            *out.end++ = tok1;
            p++;
        }
        if (n > 0) {
            p += n;
            out.end = copy_tok3(opt, out.end);
            flag = ttrue;
            if (opt.n == 0) {
                continue;
            }
            /* optimized sequence may end with '_if_' */
            /* or some other token that consumes IP */
            tok1 = out.end[-1];
        }
        n = m4token_consumes_ip(tok1) / sizeof(m4token);
        if (n) {
            memmove(out.end, p, n * sizeof(m4token));
            p += n;
            out.end += n;
        }
    }
    /* move back code to [in.start, ...] */
    n = out.end - out.start;
    memmove(in.start, out.start, n * sizeof(m4token));
    {
        const m4code_range_flag ret = {{in.start, in.start + n}, flag};
        return ret;
    }
}

/* temporary C implementation of [optimize] */
m4code_range m4th_c_optimize(m4token *xt, m4token *xt_end) {
    m4code_range_flag ret = {{xt, xt_end}, tfalse};
    for (;;) {
        ret = optimize_once(ret.code);
        if (!ret.flag) {
            break;
        }
    }
    return ret.code;
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
    return (ret[2] & bit_SSE4_2) ? m4th_cpu_feature_crc32c : 0;
}

#elif defined(__aarch64__) && defined(__linux__)

#include <asm/hwcap.h>
#include <sys/auxv.h>
/* arm64+Linux: use Linux specific getauxval(AT_HWCAP) to detect CRC32c CPU instructions */
m4cell m4th_cpu_features_detect(void) {
    unsigned long hwcap = getauxval(AT_HWCAP);
    return (hwcap & HWCAP_CRC32) ? m4th_cpu_feature_crc32c : 0;
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
