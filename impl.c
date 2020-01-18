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

void m4th_string_print(m4string str, FILE *out) {
    if (out == NULL || str.addr == NULL || str.len == 0) {
        return;
    }
    fwrite(str.addr, sizeof(m4char), str.len, out);
}

m4int m4th_string_compare(m4string a, const m4countedstring *b) {
    if (a.addr == NULL || b == NULL || a.len != b->len) {
        return 1;
    }
    return memcmp(a.addr, b->chars, (size_t)a.len);
}

/* warning: str must end with '\0' */
m4int m4th_string_to_int(m4string str, m4int *out_n) {
    char *end = NULL;
    m4int err = tsuccess;
    if (str.addr == NULL || str.len == 0) {
        return teof;
    }
    if (out_n == NULL) {
        return tbad_addr;
    }
    errno = 0;
    *out_n = strtol(str.addr, &end, 0 /*base*/);
    if ((err = errno) == 0 && end != str.addr + str.len) {
        err = tint_trailing_junk;
    }
    return err;
}

/** temporary C implementation of (read) */
m4string m4th_read(m4th *m) {
    m4string s = {NULL, 0};
    const char *cstr = NULL;
    assert(m);
    if (m->in_cstr != NULL && (cstr = *m->in_cstr) != NULL) {
        m->in_cstr++;
        s.addr = cstr;
        s.len = strlen(cstr);
    }
    return s;
}

/** temporary C implementation of (dict-lookup-word) */
static const m4word *m4th_dict_lookup_word(const m4dict *d, m4string key) {
    const m4word *w = m4th_dict_lastword(d);
    assert(d);
    assert(key.addr);
    for (; w; w = m4th_word_prev(w)) {
        if (m4th_string_compare(key, m4th_word_name(w)) == 0) {
            return w;
        }
    }
    return NULL;
}

/** temporary C implementation of (lookup-word) */
static const m4word *m4th_lookup_word(m4th *m, m4string key) {
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

/** temporary C implementation of (parse) */
m4eval_arg m4th_parse(m4th *m, m4string key) {
    m4eval_arg arg = {NULL, 0, -1 /*EOF*/};
    if (key.addr != NULL) {
        if ((arg.w = m4th_lookup_word(m, key)) == NULL) {
            arg.err = m4th_string_to_int(key, &arg.n);
        }
    }
    return arg;
}

/** temporary C implementation of (compile-word) */
static m4int m4th_compile_word(m4th *m, const m4word *w) {
    ipush(m4_call_);
    ipush((m4instr)w->code);
    return tsuccess;
}

/** temporary C implementation of (interpret-word) */
static m4int m4th_interpret_word(m4th *m, const m4word *w) {
    const m4code code_save = m->code;
    m4int ret = m4th_compile_word(m, w);
    if (ret != tsuccess) {
        return ret;
    }
    ipush(m4bye);
    ret = m4th_run(m);
    m->code = code_save;
    return ret;
}

/** temporary C implementation of (compile-number) */
static m4int m4th_compile_number(m4th *m, m4int n) {
    ipush(m4_lit_);
    ipush((m4instr)n);
    return tsuccess;
}

/** temporary C implementation of (eval) */
m4int m4th_eval(m4th *m, m4eval_arg arg) {
    const m4char is_interpreting = (m->flags & m4th_flag_status_mask) == m4th_flag_interpret;

    if (arg.err != 0) {
        return arg.err;
    } else if (arg.w != NULL) {
        if (is_interpreting) {
            return m4th_interpret_word(m, arg.w);
        } else {
            return m4th_compile_word(m, arg.w);
        }
    } else {
        if (is_interpreting) {
            dpush(arg.n);
            return tsuccess;
        } else {
            return m4th_compile_number(m, arg.n);
        }
    }
}

/** temporary C implementation of (repl) */
m4int m4th_repl(m4th *m) {
    m4string str;
    m4eval_arg arg;
    m4int ret;

    while ((ret = m4th_eval(m, arg = m4th_parse(m, str = m4th_read(m)))) == 0) {
    }
    if (ret != 0 && arg.err == ret && arg.w == NULL && str.addr != NULL) {
        m4th_string_print(str, stderr);
        fputs(" ?", stderr);
    }
    return ret;
}
