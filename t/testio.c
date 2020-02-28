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

#ifndef M4TH_T_TESTIO_C
#define M4TH_T_TESTIO_C

#include "../impl.h"
#include "../include/err.h"
#include "../include/func_fwd.h"
#include "../include/iobuf.mh"
#include "../include/token.h"
#include "../include/word_fwd.h"
#include "../m4th.h"
#include "testcommon.h"

#include <assert.h> /* assert()          */
#include <string.h> /* memset()          */

/* -------------- m4testio_counteddata -------------- */

static m4pair m4testio_counteddata_append_c(m4counteddata *dst, const m4char *src, m4cell_u n) {
    m4pair ret = {{n}, 0};
    memcpy(dst->addr + dst->n, src, n);
    dst->n += n;
    return ret;
}

/* ( io c-addr u -- u' err ) */
static const m4cell m4testio_counteddata_append_w[m4test_code_n] = {
    m4_c_arg_3_, m4_c_call_, CELL(m4testio_counteddata_append_c), m4_c_ret_2_, m4exit,
};

static m4token m4testio_counteddata_append[m4test_code_n];

/* -------------- m4cstr -------------- */

static void m4cstr_print(const char *cstr, FILE *out) {
    if (cstr) {
        fprintf(out, "<%lu> [%s]", (unsigned long)strlen(cstr), cstr);
    } else {
        fputs("<0> []", out);
    }
}

static m4cell_u m4cstr_len(const char *cstr) {
    return cstr ? strlen(cstr) : 0;
}

/* -------------- m4iobuf -------------- */

static void m4iobuf_fill(m4iobuf *io, const char *cstr) {
    io->pos = 0;
    if ((io->size = m4cstr_len(cstr))) {
        memcpy(io->addr, cstr, io->size);
    }
}

static void m4iobuf_print(const m4iobuf *io, FILE *out) {
    const m4cell_u n = io->size - io->pos;
    fprintf(out, "<%lu> [", (unsigned long)n);
    fwrite(io->addr + io->pos, 1, n, out);
    fputc(']', out);
}

static m4cell m4iobuf_with_counteddata_equal(const m4iobuf *io, const char *cstr) {
    const m4counteddata *d = (m4counteddata *)io->handle;
    const m4cell_u n0 = d->n;
    const m4cell_u n1 = io->size - io->pos;
    const m4cell_u n2 = m4cstr_len(cstr);
    return n0 + n1 == n2 && !memcmp(d->addr, cstr, n0) &&
           !memcmp(io->addr + io->pos, cstr + n0, n1);
}

static void m4iobuf_with_counteddata_print(const m4iobuf *io, FILE *out) {
    const m4counteddata *d = (m4counteddata *)io->handle;
    const m4cell_u nd = d->n;
    const m4cell_u nio = io->size - io->pos;
    fprintf(out, "<%lu> [", (unsigned long)(nd + nio));
    fwrite(d->addr, 1, nd, out);
    fwrite(io->addr + io->pos, 1, nio, out);
    fputc(']', out);
}

/* -------------- m4testio -------------- */

static const char s_foobar[] = "foobar";

static m4testio testio_a[] = {
    /* ------------------------- obuf --------------------------------------- */
    {"obuf-flush",
     {m4out_to_obuf, CALL(obuf_flush), m4bye},
     {{}, {}},
     {{1, {0}}, {}},
     {"", "="},
     {"", "="}},
    {"(obuf-overflow)",
     {m4out_to_obuf, m4minus_rot, CALL(_obuf_overflow_), m4bye},
     {{2, {(m4cell)s_foobar, 6}}, {}},
     {{3, {(m4cell)s_foobar + 6, 0, 0}}, {}},
     {"", "x"},
     {"", "foobarx"}}, /* 'x' remains at obuf.addr[0] */
    {"(obuf-flush-write-char)",
     {m4out_to_obuf, m4swap, CALL(_obuf_flush_write_char_), m4bye},
     {{1, {'b'}}, {}},
     {{1, {0}}, {}},
     {"", "a"},
     {"", "ab"}},
    {"(obuf-flush-write-string)",
     {m4out_to_obuf, m4minus_rot, CALL(_obuf_flush_write_string_), m4bye},
     {{2, {(m4cell)s_foobar, 6}}, {}},
     {{1, {0}}, {}},
     {"", "x"},
     {"", "xfoobar"}},
    {"cr", {CALL(cr), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n"}},
    {"space", {CALL(space), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", " "}},
    {"cr space", {CALL(cr), CALL(space), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n "}},
    /* ------------------------- ibuf --------------------------------------- */
    {"parse-name",
     {CALL(parse_name), /*CALL(type),*/ m4two_drop, m4bye},
     {{}, {}},
     {{}, {}},
     {" a b", ""},
     {" b", ""}},
};

static void m4testio_global_init() {
    m4slice code_in = {(m4cell *)m4testio_counteddata_append_w, m4test_code_n};
    m4code code = {m4testio_counteddata_append, m4test_code_n};
    m4slice_copy_to_code(code_in, &code);
}

static m4code m4testio_init(m4testio *t, m4countedcode *code_buf) {
    m4slice t_code_in = {(m4cell *)t->code, m4test_code_n};
    m4code t_code = {code_buf->data, code_buf->n};
    m4slice_copy_to_code(t_code_in, &t_code);
    return t_code;
}

static m4cell m4testio_run(m4th *m, m4testio *t, const m4code *code) {
    m4counteddata *d;
    m4th_clear(m);

    m4countedstack_copy(&t->before.d, &m->dstack);
    m4countedstack_copy(&t->before.r, &m->rstack);
    m4iobuf_fill(m->in, t->iobefore.in);
    m4iobuf_fill(m->out, t->iobefore.out);

    /* reuse part of m->out->addr buffer as m4counteddata */
    d = (m4counteddata *)(m->out->addr + SZ);
    d->n = 0;
    m->out->handle = (m4cell)d;
    m->out->func = m4testio_counteddata_append;
    m->out->max = 1; /* reduce capacity to trigger iobuf flush */

    m->ip = code->addr;
    m4th_run(m);

    return m4countedstack_equal(&t->after.d, &m->dstack) &&
           m4countedstack_equal(&t->after.r, &m->rstack) /* ______________________ */ &&
           m4iobuf_equal(m->in, t->ioafter.in) /* ______________________ */ &&
           m4iobuf_with_counteddata_equal(m->out, t->ioafter.out);
}

static void m4testio_failed(const m4th *m, const m4testio *t, FILE *out) {
    if (out == NULL) {
        return;
    }
    fprintf(out, "  I/O   test failed: %s", t->name);
    fputs("\n    expected  data  stack ", out);
    m4countedstack_print(&t->after.d, out);
    fputs("\n      actual  data  stack ", out);
    m4stack_print(&m->dstack, out);

    fputs("\n... expected return stack ", out);
    m4countedstack_print(&t->after.r, out);
    fputs("\n      actual return stack ", out);
    m4stack_print(&m->rstack, out);

    fputs("\n... expected  in   buffer ", out);
    m4cstr_print(t->ioafter.in, out);
    fputs("\n      actual  in   buffer ", out);
    m4iobuf_print(m->in, out);

    fputs("\n... expected  out  buffer ", out);
    m4cstr_print(t->ioafter.out, out);
    fputs("\n      actual  out  buffer ", out);
    m4iobuf_with_counteddata_print(m->out, out);
    fputc('\n', out);
}

static void m4testio_bunch(m4th *m, m4testio bunch[], m4cell n, m4testcount *count, FILE *out) {
    m4countedcode countedcode = {m4test_code_n, {}};
    m4cell i, fail = 0;
    for (i = 0; i < n; i++) {
        m4code code = m4testio_init(&bunch[i], &countedcode);
        if (!m4testio_run(m, &bunch[i], &code)) {
            fail++, m4testio_failed(m, &bunch[i], out);
        }
    }
    count->failed += fail;
    count->total += n;
}

m4cell m4th_testio(m4th *m, FILE *out) {
    m4testcount count = {};
    m4testio_global_init();
    m4testio_bunch(m, testio_a, N_OF(testio_a), &count, out);

    if (out != NULL) {
        if (count.failed == 0) {
            fprintf(out, "all %3u   I/O   tests passed\n", (unsigned)count.total);
        } else {
            fprintf(out, "\n  I/O   tests failed: %3u of %3u\n", (unsigned)count.failed,
                    (unsigned)count.total);
        }
    }
    return count.failed;
}

#endif /* M4TH_T_TESTIO_C */
