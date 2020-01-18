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

#include "func_fwd.h"

#include "impl.h"

#include <assert.h> /* assert()          */
#include <errno.h>  /* errno             */
#include <stdlib.h> /* strtol()          */
#include <string.h> /* memcmp() strlen() */

#define dpush(val) (*--m->dstack.curr = (val))
#define dpop(val) (*m->dstack.curr++)

#define ipush(val) (*m->code.curr++ = (val))

enum { tfalse = (m4int)0, ttrue = (m4int)-1 };

void m4th_string_print(m4string str, FILE *out) {
    if (out == NULL || str.addr == NULL || str.len == 0) {
        return;
    }
    fwrite(str.addr, sizeof(m4char), str.len, out);
}

m4int m4th_string_equals(m4string a, const m4countedstring *b) {
    if (a.addr == NULL || b == NULL || a.len != b->len) {
        return tfalse;
    }
    return memcmp(a.addr, b->chars, (size_t)a.len) ? tfalse : ttrue;
}

/* warning: str must end with '\0' */
m4int m4th_string_to_int(m4string str, m4int *out_n) {
    char *end = NULL;
    if (str.addr == NULL || str.len == 0 || out_n == NULL) {
        return tfalse;
    }
    errno = 0;
    *out_n = strtol(str.addr, &end, 0 /*base*/);
    if (errno != 0 || end != str.addr + str.len) {
        return tfalse;
    }
    return ttrue;
}

/** temporary C implementation of parse */
m4string m4th_parse(m4th *m) {
    m4string s = {NULL, 0};
    const char *word = NULL;
    assert(m);
    if (m->parsed != NULL && (word = *m->parsed) != NULL) {
        m->parsed++;
        s.addr = word;
        s.len = strlen(word);
    }
    return s;
}

/** temporary C implementation of (dict-lookup-word) */
const m4word *m4th_dict_lookup_word(const m4dict *d, m4string key) {
    const m4word *w = m4th_dict_lastword(d);
    assert(d);
    assert(key.addr);
    for (; w; w = m4th_word_prev(w)) {
        if (m4th_string_equals(key, m4th_word_name(w))) {
            return w;
        }
    }
    return NULL;
}

/** temporary C implementation of (lookup-word) */
const m4word *m4th_lookup_word(m4th *m, m4string key) {
    const m4dict *d;
    const m4word *w = NULL;
    enum { n = sizeof(m->dicts) / sizeof(m->dicts[0]) };
    m4int i;
    assert(m);
    assert(key.addr);
    for (i = 0; w == NULL && i < n; i++) {
        if ((d = m->dicts[i]) == NULL) {
            break;
        }
        w = m4th_dict_lookup_word(d, key);
    }
    return w;
}

/** temporary C implementation of (compile-word) */
m4int m4th_compile_word(m4th *m, const m4word *w) {
    ipush(m4_call_);
    ipush((m4instr)w->code);
    return ttrue;
}

/** temporary C implementation of (interpret-word) */
m4int m4th_interpret_word(m4th *m, const m4word *w) {
    const m4code code_save = m->code;
    m4int ret = m4th_compile_word(m, w);
    if (!ret) {
        return ret;
    }
    ipush(m4bye);
    ret = (m4th_enter(m) == 0) ? ttrue : tfalse;
    m->code = code_save;
    return ret;
}

/** temporary C implementation of (compile-number) */
m4int m4th_compile_number(m4th *m, m4int n) {
    ipush(m4_lit_);
    ipush((m4instr)n);
    return ttrue;
}

/** temporary C implementation of (interpret) */
m4int m4th_interpret(m4th *m) {
    m4string str = m4th_parse(m);
    const m4word *w = NULL;
    m4int n = 0;
    const m4char is_interpreting = (m->flags & m4th_flag_status_mask) == m4th_flag_interpret;

    if (str.addr == NULL) {
        return tfalse;
    }
    if ((w = m4th_lookup_word(m, str)) != NULL) {
        if (is_interpreting) {
            return m4th_interpret_word(m, w);
        } else {
            return m4th_compile_word(m, w);
        }
    } else if (m4th_string_to_int(str, &n)) {
        if (is_interpreting) {
            dpush(n);
        } else {
            m4th_compile_number(m, n);
        }
        return ttrue;
    } else {
        m4th_string_print(str, stderr);
        fputs(" ?", stderr);
        return tfalse;
    }
}

/** temporary C implementation of (interpret-loop) */
void m4th_interpret_loop(m4th *m) {
    while (m4th_interpret(m)) {
    }
}
