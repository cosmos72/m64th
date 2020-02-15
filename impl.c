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
                // 0x82f63b78 is crc-32c. Use 0xedb88320 for vanilla crc-32.
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

static inline void dpush(m4th *m, m4cell val) {
    *--m->dstack.curr = val;
}

static inline m4cell dpop(m4th *m) {
    return *m->dstack.curr++;
}

/** wrapper around string>number */
m4pair m4string_to_int(m4th *m, m4string str) {
    m4pair ret = {};
    dpush(m, (m4cell)str.addr);
    dpush(m, (m4cell)str.n);
    m4th_execute_word(m, &WORD_SYM(string_to_number));
    if (!dpop(m)) { /* t|f */
        ret.err = m4err_bad_number;
    }
    ret.num = dpop(m); /* number */
    return ret;
}

/** temporary C implementation of parse-name */
m4string m4th_parse_name(m4th *m) {
    m4string ret = {};
    m4char *s, *end;
    assert(m);
    s = &m->in.addr[m->in.curr];
    end = &m->in.addr[m->in.size];
    while (s < end && *s <= ' ') {
        s++;
    }
    ret.addr = s;
    while (s < end && (*s) > ' ') {
        s++;
    }
    ret.n = s - ret.addr;
    m->in.curr = s - m->in.addr;
    return ret;
}

/** wrapper around (string>word) */
static const m4word *m4th_string_to_word(m4th *m, m4string key) {
    dpush(m, (m4cell)key.addr);
    dpush(m, key.n);
    m4th_execute_word(m, &m4w_string_to_word);
    return (m4word *)dpop(m);
}

/** temporary C implementation of (resolve) */
m4pair m4th_resolve(m4th *m, m4string key) {
    m4pair ret = {};
    const m4word *w;
    if (key.addr == NULL || key.n == 0) {
        ret.err = m4err_eof;
    } else if ((w = m4th_string_to_word(m, key)) != NULL) {
        ret.w = w;
        ret.err = m4num_is_word;
    } else {
        ret = m4string_to_int(m, key);
    }
    return ret;
}

/** temporary C implementation of (compile-word) */
static m4cell m4th_compile_word(m4th *m, const m4word *w) {
    dpush(m, (m4cell)m4word_code(w).addr);
    return m4th_execute_word(m, &WORD_SYM(compile_comma));
}

/** temporary C implementation of (compile-number) */
static m4cell m4th_compile_number(m4th *m, m4cell num) {
    dpush(m, num);
    return m4th_execute_word(m, &WORD_SYM(literal));
}

/** temporary C implementation of (eval) */
m4cell m4th_eval(m4th *m, m4pair arg) {
    const m4char is_interpreting = (m->flags & m4th_flag_status_mask) == m4th_flag_interpret;

    if (arg.err == m4num_is_word && arg.num != 0) {
        const m4word *w = arg.w;
        if (is_interpreting || (w->flags & m4flag_immediate)) {
            if (is_interpreting && (w->flags & m4flag_compile_only)) {
                FILE *out = stderr;
                fputs("cannot execute compile-only word while interpreting: ", out);
                m4string_print(m4word_name(w), out);
                fputc('\n', out);
                return m4err_syntax;
            }
            return m4th_execute_word(m, w);
        } else {
            return m4th_compile_word(m, w);
        }
    } else if (arg.err != m4err_ok) {
        return arg.err;
    } else {
        if (is_interpreting) {
            dpush(m, arg.num);
            return m4err_ok;
        } else {
            return m4th_compile_number(m, arg.num);
        }
    }
}

/** temporary C implementation of (repl) */
m4cell m4th_repl(m4th *m) {
    m4string str;
    m4pair arg;
    m4cell ret;

    while ((ret = m4th_eval(m, arg = m4th_resolve(m, str = m4th_parse_name(m)))) == m4err_ok) {
    }
    if (ret != m4err_ok && arg.err == ret && str.n != 0) {
        m4string_print(str, stderr);
        fputs(" ?", stderr);
    }
    return ret;
}
