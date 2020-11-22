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
#include "../include/m4th.h"
#include "../include/m4th.mh" /* M4TH_PIC_MAXSIZE */
#include "../include/token.h"
#include "../include/word_fwd.h"
#include "testcommon.h"

#include <assert.h> /* assert()                    */
#include <string.h> /* memcpy() memmove() memset() */

/* -------------- m4testio -------------- */

static const char s_foobarbaz[] = "foobarbaz";

static const m4testio testio_a[] = {
    /* ------------------------- iobuf -------------------------------------- */
    {"iobuf>data>n",
     {m4in_to_ibuf, m4iobuf_data_n, m4bye},
     {{}, {}},
     {{1, {0}}, {}},
     {"", ""},
     {"", ""}},
    {"\"foo\" iobuf>data>n",
     {m4in_to_ibuf, m4iobuf_data_n, m4bye},
     {{}, {}},
     {{1, {3}}, {}},
     {"foo", ""},
     {"foo", ""}},
    {"iobuf-empty?",
     {m4in_to_ibuf, m4iobuf_empty_query, m4bye},
     {{}, {}},
     {{1, {ttrue}}, {}},
     {"", ""},
     {"", ""}},
    {"\" \" iobuf-empty?",
     {m4in_to_ibuf, m4iobuf_empty_query, m4bye},
     {{}, {}},
     {{1, {tfalse}}, {}},
     {" ", ""},
     {" ", ""}},
    /* ------------------------- ibuf --------------------------------------- */
    {"ibuf-skip-blanks",
     {m4in_to_ibuf, CALL(ibuf_skip_blanks), m4bye},
     {{}, {}},
     {{}, {}},
     {"\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r # ", ""},
     {"# ", ""}},
    {"'\"' ibuf-find-char",
     {m4in_to_ibuf, m4swap, CALL(ibuf_find_char), m4type, m4bye},
     {{1, {'"'}}, {}},
     {{}, {}},
     {" foo\"x", ""},
     {"x", " foo"}},
    {"'z' ibuf-find-char",
     {m4in_to_ibuf, m4swap, CALL(ibuf_find_char), m4type, m4bye},
     {{1, {'z'}}, {}},
     {{}, {}},
     {"  x y \n", ""},
     {"", "  x y \n"}},
    /* ------------------------- obuf --------------------------------------- */
    {"obuf-flush",
     {m4out_to_obuf, CALL(obuf_flush), m4bye},
     {{}, {}},
     {{1, {0}}, {}},
     {"", "="},
     {"", "="}},
    {"(obuf-overflow)",
     {m4out_to_obuf, m4minus_rot, CALL(_obuf_overflow_), m4bye},
     {{2, {(m4cell)s_foobarbaz, 9}}, {}},
     {{3, {(m4cell)s_foobarbaz + 9, 0, 0}}, {}},
     {"", "x"},
     {"", "foobarbazx"}}, /* 'x' remains at obuf.addr[0] */
    {"(obuf-flush-write-char)",
     {m4out_to_obuf, m4swap, CALL(_obuf_flush_write_char_), m4bye},
     {{1, {'b'}}, {}},
     {{1, {0}}, {}},
     {"", "a"},
     {"", "ab"}},
    {"\"d\" (obuf-flush-write-string)",
     {m4out_to_obuf, m4minus_rot, CALL(_obuf_flush_write_string_), m4bye},
     {{2, {(m4cell) "d", 1}}, {}},
     {{1, {0}}, {}},
     {"", "c"},
     {"", "cd"}},
    {"\"foobarbaz\" (obuf-flush-write-string)",
     {m4out_to_obuf, m4minus_rot, CALL(_obuf_flush_write_string_), m4bye},
     {{2, {(m4cell)s_foobarbaz, 9}}, {}},
     {{1, {0}}, {}},
     {"", "x"},
     {"", "xfoobarbaz"}},
    {"cr", {CALL(cr), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n"}},
    {"space", {CALL(space), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", " "}},
    {"cr space", {CALL(cr), CALL(space), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n "}},
    {"3 spaces", {CALL(spaces), m4bye}, {{1, {3}}, {}}, {{}, {}}, {"", ""}, {"", "   "}},
    {"emit", {m4emit, m4bye}, {{1, {'#'}}, {}}, {{}, {}}, {"", ""}, {"", "#"}},
    {"emit emit", {m4emit, m4emit, m4bye}, {{2, {')', '('}}, {}}, {{}, {}}, {"", ""}, {"", "()"}},
    {"\"k\" type", {m4type, m4bye}, {{2, {(m4cell) "k", 1}}, {}}, {{}, {}}, {"", ""}, {"", "k"}},
    {"\"pq\" type",
     {m4type, m4bye},
     {{2, {(m4cell) "pq", 2}}, {}},
     {{}, {}},
     {"", "o"},
     {"", "opq"}},
    {"\"foobarbaz\" type",
     {m4type, m4bye},
     {{2, {(m4cell)s_foobarbaz, 9}}, {}},
     {{}, {}},
     {"", "e"},
     {"", "efoobarbaz"}},
    /* ------------------------- emit, type --------------------------------- */
    {"'x' emit 'y' emit",
     {m4emit, m4emit, m4bye},
     {{2, {'y', 'x'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "xy"}},
    {"cr space", {CALL(cr), CALL(space), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n "}},
    {"\" x \" type",
     {m4type, m4bye},
     {{2, {(m4cell) " x ", 3}}, {}},
     {{}, {}},
     {"", ""},
     {"", " x "}},
    {"\"a\" type 'b' emit",
     {m4type, m4emit, m4bye},
     {{3, {'b', (m4cell) "a", 1}}, {}},
     {{}, {}},
     {"", ""},
     {"", "ab"}},
    {"\'p' emit \"q\" type",
     {m4emit, m4type, m4bye},
     {{3, {(m4cell) "q", 1, 'p'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "pq"}},
};

/* these require higher obuf capacity */
static const m4testio testio_b[] = {
    /* ------------------------- pictured numeric output -------------------- */
    {"<# #>",
     {m4num_start, m4num_end, m4type, m4bye},
     {{2, {0, 0}}, {}},
     {{}, {}},
     {"", ""},
     {"", ""}},
    {"<# char a hold #>",
     {m4num_start, m4hold, m4num_end, m4type, m4bye},
     {{3, {0, 0, 'a'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "a"}},
    {"<# char b char c hold #>",
     {m4num_start, m4hold, m4hold, m4num_end, m4type, m4bye},
     {{4, {0, 0, 'c', 'b'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "cb"}},
    {"<# 3 # #>",
     {m4num_start, m4u_to_d, CALL(num), m4num_end, m4type, m4bye},
     {{1, {3}}, {}},
     {{}, {}},
     {"", ""},
     {"", "3"}},
    {"<# 123 #s #>",
     {m4num_start, m4u_to_d, CALL(num_s), m4num_end, m4type, m4bye},
     {{1, {123}}, {}},
     {{}, {}},
     {"", ""},
     {"", "123"}},
};

static const m4testio testio_c[] = {
    /* ------------------------- dot ---------------------------------------- */
    {"9 .", {CALL(dot), m4bye}, {{1, {9}}, {}}, {{}, {}}, {"", ""}, {"", "9 "}},
    /* ------------------------- parse-name --------------------------------- */
    {"\"   \" parse-name",
     {CALL(parse_name), m4type, m4bye},
     {{}, {}},
     {{}, {}},
     {"   ", ""},
     {"", ""}},
    {"\" a \" parse-name",
     {CALL(parse_name), m4type, m4bye},
     {{}, {}},
     {{}, {}},
     {" a ", ""},
     {" ", "a"}},
    {"\" a \" parse-name parse-name",
     {CALL(parse_name), m4type, CALL(parse_name), m4type, m4bye},
     {{}, {}},
     {{}, {}},
     {" a ", ""},
     {"", "a"}},
    {"\" a b \" parse-name",
     {CALL(parse_name), m4type, m4bye},
     {{}, {}},
     {{}, {}},
     {" a b ", ""},
     {" b ", "a"}},
    {"\" a b \" parse-name parse-name",
     {CALL(parse_name), m4type, CALL(parse_name), m4type, m4bye},
     {{}, {}},
     {{}, {}},
     {" a b ", ""},
     {" ", "ab"}},
    {"\"  11    22\" parse-name",
     {CALL(parse_name), m4type, m4bye},
     {{}, {}},
     {{}, {}},
     {"  11   22", ""},
     {"   22", "11"}},
    {"\" foobarbaz qwertyuiop\" parse-name",
     {CALL(parse_name), m4type, m4bye},
     {{}, {}},
     {{}, {}},
     {" foobarbaz qwertyuiop", ""},
     {" qwertyuiop", "foobarbaz"}},

    /* ------------------------- ' ------------------------------------------ */
    {"' and ", {CALL(tick), m4bye}, {{}, {}}, {{1, {DXT(and)}}, {}}, {" and ", ""}, {" ", ""}},
    /* ------------------------- s" ----------------------------------------- */
    {"s\"", {CALL(s_quote), m4bye}, {{}, {}}, {{}, {}}, {" fubar\"", ""}, {"", ""}},
};

/* these require higher ibuf capacity */
static const m4testio testio_d[] = {
    {"\"123\" iobuf>data 'a' fill",
     {m4in_to_ibuf, m4iobuf_data, m4_lit_, T('a'), m4fill, m4bye},
     {{}, {}},
     {{}, {}},
     {"123", ""},
     {"aaa", ""}},
    {"\"123456789012345\" iobuf>data 'b' fill",
     {m4in_to_ibuf, m4iobuf_data, m4_lit_, T('b'), m4fill, m4bye},
     {{}, {}},
     {{}, {}},
     {"123456789012345", ""},
     {"bbbbbbbbbbbbbbb", ""}},
    {"\"1234567890123456\" iobuf>data 'c' fill",
     {m4in_to_ibuf, m4iobuf_data, m4_lit_, T('c'), m4fill, m4bye},
     {{}, {}},
     {{}, {}},
     {"1234567890123456", ""},
     {"cccccccccccccccc", ""}},
    {"\"12345678901234567890123456789012345678901234567890123456789012345\" iobuf>data 'd' fill",
     {m4in_to_ibuf, m4iobuf_data, m4_lit_, T('d'), m4fill, m4bye},
     {{}, {}},
     {{}, {}},
     {"12345678901234567890123456789012345678901234567890123456789012345", ""},
     {"ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd", ""}},
};

static const m4testio testio_e[] = {
    /* ------------------------- interpret ---------------------------------- */
    {"interpret", {CALL(interpret), m4bye}, {{}, {}}, {{1, {3}}, {}}, {" 3 2", ""}, {" 2", ""}},
    /* ------------------------- repl --------------------------------------- */
    {"repl", {CALL(repl), m4bye}, {{}, {}}, {{1, {56}}, {}}, {"7 8 *", ""}, {"", " ok\n"}},
};

/* -------------- m4cstr -------------- */

static void m4cstr_print_escape(const char *cstr, FILE *out) {
    if (cstr) {
        m4ucell len = (m4ucell)strlen(cstr);
        fprintf(out, "<%ld> [", (unsigned long)len);
        m4string_print_escape(m4string_make(cstr, len), out);
        fputc(']', out);
    } else {
        fputs("<0> []", out);
    }
}

static m4ucell m4cstr_len(const char *cstr) {
    return cstr ? strlen(cstr) : 0;
}

/* -------------- m4ibuf_with_counteddata -------------- */

static m4pair m4ibuf_with_counteddata_read_c(m4counteddata *src, m4char *dst, m4ucell n) {
    m4ucell chunk = src->n < n ? src->n : n;
    m4pair ret = {{chunk}, chunk ? 0 : m4err_unexpected_eof};
    memcpy(dst, src->addr, chunk);
    if ((src->n -= chunk) != 0) {
        memmove(src->addr + chunk, src->addr, src->n);
    }
    return ret;
}

/* ( io c-addr u -- u' err ) */
static const m4cell m4ibuf_with_counteddata_read_w[m4test_code_n] = {
    m4_c_arg_3_, m4_c_call_, CELL(m4ibuf_with_counteddata_read_c), m4_c_ret_2_, m4exit,
};

static m4token m4ibuf_with_counteddata_read[m4test_code_n];

static void m4ibuf_with_counteddata_init(m4iobuf *in, m4ucell capacity) {
    /* reuse part of in->addr buffer as m4counteddata */
    m4counteddata *d = (m4counteddata *)(in->addr + capacity);
    d->n = 0;
    in->handle = (m4cell)d;
    in->func = m4ibuf_with_counteddata_read;
    in->max = capacity; /* reduced capacity is used to trigger iobuf refill */
}

static m4cell m4ibuf_with_counteddata_equal(const m4iobuf *io, const char *cstr) {
    const m4counteddata *d = (m4counteddata *)io->handle;
    const m4ucell n = m4cstr_len(cstr);
    const m4ucell nd = d ? d->n : 0;
    const m4ucell nio = io->end - io->pos;
    return nio + nd == n && (nio == 0 || !memcmp(io->addr + io->pos, cstr, nio)) &&
           (nd == 0 || !memcmp(d->addr, cstr + nio, nd));
}

static void m4ibuf_with_counteddata_fill(m4iobuf *io, const char *cstr) {
    m4counteddata *d = (m4counteddata *)io->handle;
    m4ucell n = m4cstr_len(cstr);
    m4ucell max = io->max;
    io->pos = 0;
    if (max >= n) {
        memcpy(io->addr, cstr, n);
        io->end = n;
        d->n = 0;
    } else {
        n -= max;
        memcpy(io->addr, cstr, max);
        memcpy(d->addr, cstr + max, n);
        io->end = max;
        d->n = n;
    }
}

static void m4ibuf_with_counteddata_print(const m4iobuf *io, FILE *out) {
    const m4counteddata *d = (m4counteddata *)io->handle;
    const m4ucell nd = d ? d->n : 0;
    const m4ucell nio = io->end - io->pos;
    fprintf(out, "<%lu> [", (unsigned long)(nd + nio));
    if (io->end >= io->pos && nio) {
        m4string_print_escape(m4string_make(io->addr + io->pos, nio), out);
    }
    if (nd) {
        m4string_print_escape(m4string_make(d->addr, nd), out);
    }
    fputc(']', out);
}

/* -------------- m4obuf_with_counteddata -------------- */

static m4pair m4obuf_with_counteddata_write_c(m4counteddata *dst, const m4char *src, m4ucell n) {
    m4pair ret = {{n}, 0};
    memcpy(dst->addr + dst->n, src, n);
    dst->n += n;
    return ret;
}

/* ( io c-addr u -- u' err ) */
static const m4cell m4obuf_with_counteddata_write_w[m4test_code_n] = {
    m4_c_arg_3_, m4_c_call_, CELL(m4obuf_with_counteddata_write_c), m4_c_ret_2_, m4exit,
};

static m4token m4obuf_with_counteddata_write[m4test_code_n];

static void m4obuf_with_counteddata_init(m4iobuf *out) {
    /* reuse part of out->addr buffer as m4counteddata */
    m4counteddata *d = (m4counteddata *)(out->addr + SZ);
    d->n = 0;
    out->handle = (m4cell)d;
    out->func = m4obuf_with_counteddata_write;
    out->max = 2; /* reduce capacity to trigger iobuf flush */
}

static m4cell m4obuf_with_counteddata_equal(const m4iobuf *io, const char *cstr) {
    const m4counteddata *d = (m4counteddata *)io->handle;
    const m4ucell n = m4cstr_len(cstr);
    const m4ucell nd = d ? d->n : 0;
    const m4ucell nio = io->end - io->pos;
    return nd + nio == n && (nd == 0 || !memcmp(d->addr, cstr, nd)) &&
           (nio == 0 || !memcmp(io->addr + io->pos, cstr + nd, nio));
}

static void m4obuf_with_counteddata_fill(m4iobuf *io, const char *cstr) {
    m4counteddata *d = (m4counteddata *)io->handle;
    m4ucell n = m4cstr_len(cstr);
    m4ucell max = io->max;
    io->pos = 0;
    if (max >= n) {
        memcpy(io->addr, cstr, n);
        io->end = n;
        if (d) {
            d->n = 0;
        }
    } else {
        n -= max;
        if (d) {
            memcpy(d->addr, cstr, n);
            d->n = n;
        }
        memcpy(io->addr, cstr + n, max);
        io->end = max;
    }
}

static void m4obuf_with_counteddata_print(const m4iobuf *io, FILE *out) {
    const m4counteddata *d = (m4counteddata *)io->handle;
    const m4ucell nd = d ? d->n : 0;
    const m4ucell nio = io->end - io->pos;
    fprintf(out, "<%lu> [", (unsigned long)(nd + nio));
    if (nd) {
        m4string_print_escape(m4string_make(d->addr, nd), out);
    }
    if (io->end >= io->pos && nio) {
        m4string_print_escape(m4string_make(io->addr + io->pos, nio), out);
    }
    fputc(']', out);
}

/* -------------- m4testio -------------- */

static void m4testio_global_init() {
    {
        m4slice code_in = {(m4cell *)m4ibuf_with_counteddata_read_w, m4test_code_n};
        m4code code = {m4ibuf_with_counteddata_read, m4test_code_n};
        m4slice_copy_to_code(code_in, &code);
    }
    {
        m4slice code_in = {(m4cell *)m4obuf_with_counteddata_write_w, m4test_code_n};
        m4code code = {m4obuf_with_counteddata_write, m4test_code_n};
        m4slice_copy_to_code(code_in, &code);
    }
}

static m4code m4testio_init(const m4testio *t, m4countedcode *code_buf) {
    m4slice t_code_in = {(m4cell *)t->code, m4test_code_n};
    m4code t_code = {code_buf->data, code_buf->n};
    m4slice_copy_to_code(t_code_in, &t_code);
    return t_code;
}

static m4cell m4testio_run(m4th *m, const m4testio *t, const m4code *code) {
    m4th_clear(m);

    m4countedstack_copy(&t->before.d, &m->dstack);
    m4countedstack_copy(&t->before.r, &m->rstack);
    m4ibuf_with_counteddata_fill(m->in, t->iobefore.in);
    m4obuf_with_counteddata_fill(m->out, t->iobefore.out);

    m->ip = code->addr;
    m4th_run(m);

    return m4countedstack_equal(&t->after.d, &m->dstack) &&
           m4countedstack_equal(&t->after.r, &m->rstack) &&
           m4ibuf_with_counteddata_equal(m->in, t->ioafter.in) &&
           m4obuf_with_counteddata_equal(m->out, t->ioafter.out);
}

static void m4testio_failed(const m4th *m, const m4testio *t, FILE *out) {
    if (out == NULL) {
        return;
    }
    fprintf(out, "  I/O   test failed: %s", t->name);
    fputs("\n    expected  data  stack ", out);
    m4countedstack_print(&t->after.d, out);
    fputs("\n      actual  data  stack ", out);
    m4stack_print(&m->dstack, m4mode_user, out);

    fputs("\n... expected return stack ", out);
    m4countedstack_print(&t->after.r, out);
    fputs("\n      actual return stack ", out);
    m4stack_print(&m->rstack, m4mode_user, out);

    fputs("\n... expected  in   buffer ", out);
    m4cstr_print_escape(t->ioafter.in, out);
    fputs("\n      actual  in   buffer ", out);
    m4ibuf_with_counteddata_print(m->in, out);

    fputs("\n... expected  out  buffer ", out);
    m4cstr_print_escape(t->ioafter.out, out);
    fputs("\n      actual  out  buffer ", out);
    m4obuf_with_counteddata_print(m->out, out);
    fputc('\n', out);
}

static void m4testio_bunch(m4th *m, const m4testio bunch[], m4cell n, m4testcount *count, FILE *out,
                           m4ucell ibuf_capacity) {
    const m4iobuf ibuf = *m->in, obuf = *m->out;
    m4countedcode countedcode = {m4test_code_n, {}};
    m4cell i, fail = 0;

    m4ibuf_with_counteddata_init(m->in, ibuf_capacity);
    m4obuf_with_counteddata_init(m->out);

    for (i = 0; i < n; i++) {
        m4code code = m4testio_init(&bunch[i], &countedcode);
        if (!m4testio_run(m, &bunch[i], &code)) {
            fail++, m4testio_failed(m, &bunch[i], out);
        }
    }
    count->failed += fail;
    count->total += n;
    /* restore m->in and m->out */
    *m->in = ibuf;
    *m->out = obuf;
}

m4cell m4th_testio(m4th *m, FILE *out) {
    m4testcount count = {};
    m4testio_global_init();
    m4testio_bunch(m, testio_a, N_OF(testio_a), &count, out, SZ2);
    m4testio_bunch(m, testio_b, N_OF(testio_b), &count, out, M4TH_PIC_MAXSIZE);
    m4testio_bunch(m, testio_c, N_OF(testio_c), &count, out, SZ2);
    m4testio_bunch(m, testio_d, N_OF(testio_d), &count, out, 80);
    m4testio_bunch(m, testio_e, N_OF(testio_e), &count, out, SZ2);

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
