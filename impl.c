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
#include "include/err.h"
#include "include/token.h"
#include "include/word_fwd.h"

#include <assert.h> /* assert()                   */
#include <errno.h>  /* errno                      */
#include <stdlib.h> /* strtol()                   */
#include <string.h> /* memcmp() memcpy() strlen() */

static inline void dpush(m4th *m, m4cell val) {
    *--m->dstack.curr = val;
}

static inline m4cell dpop(m4th *m) {
    return *m->dstack.curr++;
}

/** wrapper around string>number */
m4pair m4string_to_int(m4th *m, m4string str) {
    m4pair ret = {};
    m4cell ok;
    dpush(m, (m4cell)str.addr);
    dpush(m, (m4cell)str.n);
    m4th_execute_word(m, &WORD_SYM(string_to_number));
    ok = dpop(m);      /* t|f */
    ret.num = dpop(m); /* number */
    if (ok) {
        dpop(m); /* # of unprocessed chars */
    } else {
        ret.err = dpop(m) ? m4err_bad_digit : m4err_eof;
    }
    dpop(m); /* address of unprocessed chars */
    return ret;
}

/** temporary C implementation of (read) */
m4string m4th_read(m4th *m) {
    m4string s = {};
    const char *cstr = NULL;
    assert(m);
    if (m->in_cstr != NULL && (cstr = *m->in_cstr) != NULL) {
        m->in_cstr++;
        s.addr = (const m4char *)cstr;
        s.n = strlen(cstr);
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
m4pair m4th_parse(m4th *m, m4string key) {
    m4pair ret = {};
    const m4word *w;
    if (key.addr == NULL) {
        ret.err = m4err_eof;
    } else if ((w = m4th_lookup_word(m, key)) != NULL) {
        ret.num = (m4cell)m4word_code(w, 0).addr;
        ret.err = m4num_is_xt;
    } else {
        ret = m4string_to_int(m, key);
    }
    return ret;
}

/** temporary C implementation of (compile-word) */
static m4cell m4th_compile_word(m4th *m, const m4word *w) {
    dpush(m, (m4cell)m4word_code(w, 0).addr);
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

    if (arg.err == m4num_is_xt && arg.num != 0) {
        const m4word *w = (const m4word *)(arg.num - WORD_OFF_XT);
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

    while ((ret = m4th_eval(m, arg = m4th_parse(m, str = m4th_read(m)))) == m4err_ok) {
    }
    if (ret != m4err_ok && arg.err == ret && str.addr != NULL) {
        m4string_print(str, stderr);
        fputs(" ?", stderr);
    }
    return ret;
}
