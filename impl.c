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

inline void dpush(m4th *m, m4cell val) {
    *--m->dstack.curr = val;
}

inline m4cell dpop(m4th *m) {
    return *m->dstack.curr++;
}

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
    if (io->max - io->size >= len) {
        memcpy(io->addr + io->size, addr, len);
        io->size += len;
        return;
    }
}
