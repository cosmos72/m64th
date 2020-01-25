/**
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
#include "common/asm.mh"
#include "common/enum.h"
#include "dispatch/sz.mh" /* SZ SZe preprocessor macros */

#include <assert.h> /* assert()                   */
#include <errno.h>  /* errno                      */
#include <stdlib.h> /* strtol()                   */
#include <string.h> /* memcmp() memcpy() strlen() */

enum {
    m4enum_per_m4cell = SZ / SZe, /* # of m4enum needed to store an m4cell */
};

static inline void dpush(m4th *m, m4cell val) {
    *--m->dstack.curr = val;
}

static inline m4enum *vec_ipush_m4cell(m4enum *code, m4cell val) {
    /* store an m4cell in consecutive m4enum. layout depends on endianness */
    memcpy(code, &val, sizeof(m4cell));
    return code + m4enum_per_m4cell;
}

static inline void ipush_m4cell(m4th *m, m4cell val) {
    m4word *w = m->w;
    vec_ipush_m4cell(w->code + w->code_n, val);
    w->code_n += m4enum_per_m4cell;
}

static inline void ipush(m4th *m, m4enum val) {
    m->w->code[m->w->code_n++] = val;
}

enum {
    tsuccess = 0,
    teof = -1,
#ifdef EFAULT
    tbad_addr = EFAULT,
#else
    tbad_addr = -2,
#endif
#ifdef EINVAL
    tint_trailing_junk = EINVAL,
#else
    tint_trailing_junk = -3,
#endif
};

/* warning: str must end with '\0' */
m4cell m4string_to_int(m4string str, m4cell *out_n) {
    char *end = NULL;
    m4cell err = tsuccess;
    if (str.addr == NULL || str.len == 0) {
        return teof;
    }
    if (out_n == NULL) {
        return tbad_addr;
    }
    errno = 0;
    *out_n = strtol((const char *)str.addr, &end, 0 /*base*/);
    if ((err = errno) == 0 && end != (const char *)(str.addr + str.len)) {
        err = tint_trailing_junk;
    }
    return err;
}

/** temporary C implementation of (read) */
m4string m4th_read(m4th *m) {
    m4string s = {};
    const char *cstr = NULL;
    assert(m);
    if (m->in_cstr != NULL && (cstr = *m->in_cstr) != NULL) {
        m->in_cstr++;
        s.addr = (const m4char *)cstr;
        s.len = strlen(cstr);
    }
    return s;
}

/** temporary C implementation of (wordlist-lookup-word) */
static const m4word *m4wordlist_lookup_word(const m4wordlist *d, m4string key) {
    const m4word *w;
    assert(d);
    assert(key.addr);
    for (w = m4wordlist_lastword(d); w != NULL; w = m4word_prev(w)) {
        if (m4string_compare(key, m4word_name(w)) == 0) {
            return w;
        }
    }
    return NULL;
}

/** temporary C implementation of (lookup-word) */
static const m4word *m4th_lookup_word(m4th *m, m4string key) {
    m4wordlist *l;
    const m4word *w = NULL;
    m4cell i;
    assert(m);
    assert(key.addr);
    for (i = 0; i < m4th_wordlist_n && w == NULL; i++) {
        if ((l = m->wordlist[i]) != NULL) {
            w = m4wordlist_lookup_word(l, key);
        }
    }
    return w;
}

/** temporary C implementation of (parse) */
m4eval_arg m4th_parse(m4th *m, m4string key) {
    m4eval_arg arg = {NULL, 0, 0};
    if (key.addr == NULL) {
        arg.err = teof;
    } else if ((arg.w = m4th_lookup_word(m, key)) != NULL) {
    } else {
        arg.err = m4string_to_int(key, &arg.n);
    }
    return arg;
}

/** temporary C implementation of (compile-word) */
static m4cell m4th_compile_word(m4th *m, const m4word *w) {
    ipush(m, m4_call_);
    ipush_m4cell(m, (m4cell)w->code);
    return tsuccess;
}

/** temporary C implementation of (interpret-word) */
static m4cell m4th_interpret_word(m4th *m, const m4word *w) {
    const m4enum *ip_save = m->ip;
    m4enum torun[2 + m4enum_per_m4cell];
    {
        m4enum *p = torun;
        *p++ = m4_call_;
        p = vec_ipush_m4cell(p, (m4cell)w->code);
        *p++ = m4bye;
    }
    m->ip = torun;
    m4cell ret = m4th_run(m);
    m->ip = ip_save;
    return ret;
}

/** temporary C implementation of (compile-number) */
static m4cell m4th_compile_number(m4th *m, m4cell n) {
    ipush(m, m4_lit_cell_);
    ipush_m4cell(m, n);
    return tsuccess;
}

/** temporary C implementation of (eval) */
m4cell m4th_eval(m4th *m, m4eval_arg arg) {
    const m4char is_interpreting = (m->flags & m4th_flag_status_mask) == m4th_flag_interpret;

    if (arg.err != 0) {
        return arg.err;
    } else if (arg.w != NULL) {
        if (is_interpreting || (arg.w->flags & m4flag_immediate)) {
            return m4th_interpret_word(m, arg.w);
        } else {
            return m4th_compile_word(m, arg.w);
        }
    } else {
        if (is_interpreting) {
            dpush(m, arg.n);
            return tsuccess;
        } else {
            return m4th_compile_number(m, arg.n);
        }
    }
}

/** temporary C implementation of (repl) */
m4cell m4th_repl(m4th *m) {
    m4string str;
    m4eval_arg arg;
    m4cell ret;

    while ((ret = m4th_eval(m, arg = m4th_parse(m, str = m4th_read(m)))) == 0) {
    }
    if (ret != 0 && arg.err == ret && arg.w == NULL && str.addr != NULL) {
        m4string_print(str, stderr);
        fputs(" ?", stderr);
    }
    return ret;
}
