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
#include "dispatch/sz.mh" /* SZ SZt preprocessor macros */
#include "include/asm.mh"
#include "include/token.h"
#include "include/word_fwd.h"

#include <assert.h> /* assert()                   */
#include <errno.h>  /* errno                      */
#include <stdlib.h> /* strtol()                   */
#include <string.h> /* memcmp() memcpy() strlen() */

enum {
    m4token_per_m4cell = SZ / SZt, /* # of m4token needed to store an m4cell */
};

static inline void dpush(m4th *m, m4cell val) {
    *--m->dstack.curr = val;
}

static inline m4token *vec_ipush_m4cell(m4token *code, m4cell val) {
    /* store an m4cell in consecutive m4token. layout depends on endianness */
    memcpy(code, &val, sizeof(m4cell));
    return code + m4token_per_m4cell;
}

static inline void ipush_m4cell(m4th *m, m4cell val) {
    m4word *w = m->w;
    vec_ipush_m4cell(w->code + w->code_n, val);
    w->code_n += m4token_per_m4cell;
}

static inline void ipush(m4th *m, m4token val) {
    m->w->code[m->w->code_n++] = val;
}

enum {
    tsuccess = 0,
    teof = -1,
    tsyntax_error = -2,
#ifdef EFAULT
    tbad_addr = EFAULT,
#else
    tbad_addr = -3,
#endif
#ifdef EINVAL
    tint_invalid_digit = EINVAL,
#else
    tint_invalid_digit = -4,
#endif
};

m4cell m4char_to_base(m4char ch) {
    switch (ch) {
    case '#':
        return 10;
    case '$':
        return 16;
    case '%':
        return 2;
    default:
        return 0;
    }
}

/** temporary C implementation of (number) */
m4pair m4string_to_int(m4string str) {
    m4pair ret = {};
    const m4char *s = str.data;
    m4cell i = 0, n = str.n, base;
    m4char negative = 0;
    if (s == NULL || n == 0) {
        ret.err = teof;
        return ret;
    }
    base = m4char_to_base(s[i]);
    if (base > 0) {
        i++;
    } else {
        base = 10;
        if (n == 3 && s[0] == '\'' && s[2] == '\'') {
            ret.num = s[1];
            return ret;
        }
    }
    if (s[i] == '-') {
        negative = 1;
        i++;
    }
    for (; i < n; i++) {
        const m4char ch = s[i];
        if (ch < '0' || ch > '9') {
            break;
        }
        ret.num = ret.num * base + (ch - '0');
        /* TODO check overflow */
    }
    if (i != n) {
        ret.err = tint_invalid_digit;
    }
    if (negative) {
        ret.num = -ret.num;
        /* TODO check overflow */
    }
    return ret;
}

/** temporary C implementation of (read) */
m4string m4th_read(m4th *m) {
    m4string s = {};
    const char *cstr = NULL;
    assert(m);
    if (m->in_cstr != NULL && (cstr = *m->in_cstr) != NULL) {
        m->in_cstr++;
        s.data = (const m4char *)cstr;
        s.n = strlen(cstr);
    }
    return s;
}

/** temporary C implementation of (wordlist-lookup-word) */
static const m4word *m4wordlist_lookup_word(const m4wordlist *d, m4string key) {
    const m4word *w;
    assert(d);
    assert(key.data);
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
    assert(key.data);
    for (i = 0; i < m4th_wordlist_n && w == NULL; i++) {
        if ((l = m->wordlist[i]) != NULL) {
            w = m4wordlist_lookup_word(l, key);
        }
    }
    return w;
}

/** temporary C implementation of (parse) */
m4eval_arg m4th_parse(m4th *m, m4string key) {
    m4eval_arg arg = {};
    if (key.data == NULL) {
        arg.pair.err = teof;
    } else if ((arg.w = m4th_lookup_word(m, key)) != NULL) {
    } else {
        arg.pair = m4string_to_int(key);
    }
    return arg;
}

/** temporary C implementation of (compile-word) */
static m4cell m4th_compile_word(m4th *m, const m4word *w) {
    dpush(m, (m4cell)w->code);
    return m4th_execute_word(m, &m4word_compile_comma);
}

/** temporary C implementation of (compile-number) */
static m4cell m4th_compile_number(m4th *m, m4cell num) {
    dpush(m, num);
    return m4th_execute_word(m, &m4word_literal);
}

/** temporary C implementation of (eval) */
m4cell m4th_eval(m4th *m, m4eval_arg arg) {
    const m4char is_interpreting = (m->flags & m4th_flag_status_mask) == m4th_flag_interpret;

    if (arg.pair.err != 0) {
        return arg.pair.err;
    } else if (arg.w != NULL) {
        if (is_interpreting || (arg.w->flags & m4flag_immediate)) {
            if (is_interpreting && (arg.w->flags & m4flag_compile_only)) {
                FILE *out = stderr;
                fputs("cannot execute compile-only word while interpreting: ", out);
                m4string_print(m4word_name(arg.w), out);
                fputc('\n', out);
                return tsyntax_error;
            }
            return m4th_execute_word(m, arg.w);
        } else {
            return m4th_compile_word(m, arg.w);
        }
    } else {
        if (is_interpreting) {
            dpush(m, arg.pair.num);
            return tsuccess;
        } else {
            return m4th_compile_number(m, arg.pair.num);
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
    if (ret != 0 && arg.pair.err == ret && arg.w == NULL && str.data != NULL) {
        m4string_print(str, stderr);
        fputs(" ?", stderr);
    }
    return ret;
}
