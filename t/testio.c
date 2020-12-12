/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef M64TH_T_TESTIO_C
#define M64TH_T_TESTIO_C

#include "../impl.h"
#include "../include/err.h"
#include "../include/func_fwd.h"
#include "../include/iobuf.mh"
#include "../include/m64th.h"
#include "../include/m64th.mh" /* M64TH_PICT_MAXSIZE */
#include "../include/token.h"
#include "../include/word_fwd.h"
#include "testcommon.h"

#include <assert.h> /* assert()                    */
#include <string.h> /* memcpy() memmove() memset() */

/* -------------- m6testio -------------- */

static const char s_foobarbaz[] = "foobarbaz";

static const m6testio testio_a[] = {
    /* ------------------------- iobuf -------------------------------------- */
    {"iobuf>data>n",
     {m6in_to_ibuf, m6iobuf_data_n, m6bye},
     {{}, {}},
     {{1, {0}}, {}},
     {"", ""},
     {"", ""}},
    {"\"foo\" iobuf>data>n",
     {m6in_to_ibuf, m6iobuf_data_n, m6bye},
     {{}, {}},
     {{1, {3}}, {}},
     {"foo", ""},
     {"foo", ""}},
    {"iobuf-empty?",
     {m6in_to_ibuf, m6iobuf_empty_query, m6bye},
     {{}, {}},
     {{1, {ttrue}}, {}},
     {"", ""},
     {"", ""}},
    {"\" \" iobuf-empty?",
     {m6in_to_ibuf, m6iobuf_empty_query, m6bye},
     {{}, {}},
     {{1, {tfalse}}, {}},
     {" ", ""},
     {" ", ""}},
    /* ------------------------- ibuf --------------------------------------- */
    {"ibuf-skip-blanks",
     {m6in_to_ibuf, CALL(ibuf_skip_blanks), m6bye},
     {{}, {}},
     {{}, {}},
     {"\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r # ", ""},
     {"# ", ""}},
    {"'\"' ibuf-find-char",
     {m6in_to_ibuf, m6swap, CALL(ibuf_find_char), m6type, m6bye},
     {{1, {'"'}}, {}},
     {{}, {}},
     {" foo\"x", ""},
     {"x", " foo"}},
    {"'z' ibuf-find-char",
     {m6in_to_ibuf, m6swap, CALL(ibuf_find_char), m6type, m6bye},
     {{1, {'z'}}, {}},
     {{}, {}},
     {"  x y \n", ""},
     {"", "  x y \n"}},
    /* ------------------------- obuf --------------------------------------- */
    {"obuf-flush",
     {m6out_to_obuf, CALL(obuf_flush), m6bye},
     {{}, {}},
     {{1, {0}}, {}},
     {"", "="},
     {"", "="}},
    {"(obuf-overflow)",
     {m6out_to_obuf, m6minus_rot, CALL(_obuf_overflow_), m6bye},
     {{2, {(m6cell)s_foobarbaz, 9}}, {}},
     {{3, {(m6cell)s_foobarbaz + 9, 0, 0}}, {}},
     {"", "x"},
     {"", "foobarbazx"}}, /* 'x' remains at obuf.addr[0] */
    {"(obuf-flush-write-char)",
     {m6out_to_obuf, m6swap, CALL(_obuf_flush_write_char_), m6bye},
     {{1, {'b'}}, {}},
     {{1, {0}}, {}},
     {"", "a"},
     {"", "ab"}},
    {"\"d\" (obuf-flush-write-string)",
     {m6out_to_obuf, m6minus_rot, CALL(_obuf_flush_write_string_), m6bye},
     {{2, {(m6cell) "d", 1}}, {}},
     {{1, {0}}, {}},
     {"", "c"},
     {"", "cd"}},
    {"\"foobarbaz\" (obuf-flush-write-string)",
     {m6out_to_obuf, m6minus_rot, CALL(_obuf_flush_write_string_), m6bye},
     {{2, {(m6cell)s_foobarbaz, 9}}, {}},
     {{1, {0}}, {}},
     {"", "x"},
     {"", "xfoobarbaz"}},
    {"cr", {CALL(cr), m6bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n"}},
    {"space", {CALL(space), m6bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", " "}},
    {"cr space", {CALL(cr), CALL(space), m6bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n "}},
    {"3 spaces", {CALL(spaces), m6bye}, {{1, {3}}, {}}, {{}, {}}, {"", ""}, {"", "   "}},
    {"emit", {m6emit, m6bye}, {{1, {'#'}}, {}}, {{}, {}}, {"", ""}, {"", "#"}},
    {"emit emit", {m6emit, m6emit, m6bye}, {{2, {')', '('}}, {}}, {{}, {}}, {"", ""}, {"", "()"}},
    {"\"k\" type", {m6type, m6bye}, {{2, {(m6cell) "k", 1}}, {}}, {{}, {}}, {"", ""}, {"", "k"}},
    {"\"pq\" type",
     {m6type, m6bye},
     {{2, {(m6cell) "pq", 2}}, {}},
     {{}, {}},
     {"", "o"},
     {"", "opq"}},
    {"\"foobarbaz\" type",
     {m6type, m6bye},
     {{2, {(m6cell)s_foobarbaz, 9}}, {}},
     {{}, {}},
     {"", "e"},
     {"", "efoobarbaz"}},
    /* ------------------------- emit, type --------------------------------- */
    {"'x' emit 'y' emit",
     {m6emit, m6emit, m6bye},
     {{2, {'y', 'x'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "xy"}},
    {"cr space", {CALL(cr), CALL(space), m6bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n "}},
    {"\" x \" type",
     {m6type, m6bye},
     {{2, {(m6cell) " x ", 3}}, {}},
     {{}, {}},
     {"", ""},
     {"", " x "}},
    {"\"a\" type 'b' emit",
     {m6type, m6emit, m6bye},
     {{3, {'b', (m6cell) "a", 1}}, {}},
     {{}, {}},
     {"", ""},
     {"", "ab"}},
    {"\'p' emit \"q\" type",
     {m6emit, m6type, m6bye},
     {{3, {(m6cell) "q", 1, 'p'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "pq"}},
    {"( foo)", {CALL(paren), m6bye}, {{}, {}}, {{}, {}}, {" foo)", ""}, {"", ""}},
    {".( bar)", {CALL(dot_paren), m6bye}, {{}, {}}, {{}, {}}, {" bar)", ""}, {"", "bar"}},
};

/* these require higher obuf capacity */
static const m6testio testio_b[] = {
    /* ------------------------- pictured numeric output -------------------- */
    {"<# #>",
     {m6num_start, m6num_end, m6type, m6bye},
     {{2, {0, 0}}, {}},
     {{}, {}},
     {"", ""},
     {"", ""}},
    {"<# char a hold #>",
     {m6num_start, m6hold, m6num_end, m6type, m6bye},
     {{3, {0, 0, 'a'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "a"}},
    {"<# char b char c hold #>",
     {m6num_start, m6hold, m6hold, m6num_end, m6type, m6bye},
     {{4, {0, 0, 'c', 'b'}}, {}},
     {{}, {}},
     {"", ""},
     {"", "cb"}},
    {"<# _ holds #>",
     {m6num_start, m6holds, m6num_end, m6type, m6bye},
     {{4, {0, 0, (m6cell) "fubar", 5}}, {}},
     {{}, {}},
     {"", ""},
     {"", "fubar"}},
    {"<# 3 # #>",
     {m6num_start, m6u_to_d, CALL(num), m6num_end, m6type, m6bye},
     {{1, {3}}, {}},
     {{}, {}},
     {"", ""},
     {"", "3"}},
    {"<# 123 #s #>",
     {m6num_start, m6u_to_d, CALL(num_s), m6num_end, m6type, m6bye},
     {{1, {123}}, {}},
     {{}, {}},
     {"", ""},
     {"", "123"}},
#if SZ >= 8
    {"<# 123456789012345678 #s #>",
     {m6num_start, m6u_to_d, CALL(num_s), m6num_end, m6type, m6bye},
     {{1, {123456789012345678}}, {}},
     {{}, {}},
     {"", ""},
     {"", "123456789012345678"}},
    {"<# 123456789012345678901234567890123456789 #s #>",
     {m6num_start, CALL(num_s), m6num_end, m6type, m6bye},
     {{2, {0xaadfa328ae398115ul /*lo*/, 0x5ce0e9a56015fec5ul /*hi*/}}, {}},
     {{}, {}},
     {"", ""},
     {"", "123456789012345678901234567890123456789"}},
#endif
};

static const m6testio testio_c[] = {
    /* ------------------------- dot ---------------------------------------- */
    {"12348 .", {CALL(dot), m6bye}, {{1, {12348}}, {}}, {{}, {}}, {"", ""}, {"", "12348 "}},
    {"-97003 .", {CALL(dot), m6bye}, {{1, {-97003}}, {}}, {{}, {}}, {"", ""}, {"", "-97003 "}},
#if SZ == 4
    /* ------------------------- u_dot -------------------------------------- */
    {"-1 u.", {CALL(u_dot), m6bye}, {{1, {-1}}, {}}, {{}, {}}, {"", ""}, {"", "4294967295 "}},
#elif SZ == 8
    {"-1 u.",
     {CALL(u_dot), m6bye},
     {{1, {-1}}, {}},
     {{}, {}},
     {"", ""},
     {"", "18446744073709551615 "}},
#endif
    /* ------------------------- parse-name --------------------------------- */
    {"\"   \" parse-name",
     {CALL(parse_name), m6type, m6bye},
     {{}, {}},
     {{}, {}},
     {"   ", ""},
     {"", ""}},
    {"\" a \" parse-name",
     {CALL(parse_name), m6type, m6bye},
     {{}, {}},
     {{}, {}},
     {" a ", ""},
     {" ", "a"}},
    {"\" a \" parse-name parse-name",
     {CALL(parse_name), m6type, CALL(parse_name), m6type, m6bye},
     {{}, {}},
     {{}, {}},
     {" a ", ""},
     {"", "a"}},
    {"\" a b \" parse-name",
     {CALL(parse_name), m6type, m6bye},
     {{}, {}},
     {{}, {}},
     {" a b ", ""},
     {" b ", "a"}},
    {"\" a b \" parse-name parse-name",
     {CALL(parse_name), m6type, CALL(parse_name), m6type, m6bye},
     {{}, {}},
     {{}, {}},
     {" a b ", ""},
     {" ", "ab"}},
    {"\"  11    22\" parse-name",
     {CALL(parse_name), m6type, m6bye},
     {{}, {}},
     {{}, {}},
     {"  11   22", ""},
     {"   22", "11"}},
    {"\" foobarbaz qwertyuiop\" parse-name",
     {CALL(parse_name), m6type, m6bye},
     {{}, {}},
     {{}, {}},
     {" foobarbaz qwertyuiop", ""},
     {" qwertyuiop", "foobarbaz"}},

    /* ------------------------- ' ------------------------------------------ */
    {"' and ", {CALL(tick), m6bye}, {{}, {}}, {{1, {DXT(and)}}, {}}, {" and ", ""}, {" ", ""}},
    /* ------------------------- s" ----------------------------------------- */
    {"s\"", {CALL(s_quote), m6bye}, {{}, {}}, {{}, {}}, {" fubar\"", ""}, {"", ""}},
};

/* these require higher ibuf capacity */
static const m6testio testio_d[] = {
    {"\"123\" iobuf>data 'a' fill",
     {m6in_to_ibuf, m6iobuf_data, m6_lit_, T('a'), m6fill, m6bye},
     {{}, {}},
     {{}, {}},
     {"123", ""},
     {"aaa", ""}},
    {"\"123456789012345\" iobuf>data 'b' fill",
     {m6in_to_ibuf, m6iobuf_data, m6_lit_, T('b'), m6fill, m6bye},
     {{}, {}},
     {{}, {}},
     {"123456789012345", ""},
     {"bbbbbbbbbbbbbbb", ""}},
    {"\"1234567890123456\" iobuf>data 'c' fill",
     {m6in_to_ibuf, m6iobuf_data, m6_lit_, T('c'), m6fill, m6bye},
     {{}, {}},
     {{}, {}},
     {"1234567890123456", ""},
     {"cccccccccccccccc", ""}},
    {"\"12345678901234567890123456789012345678901234567890123456789012345\" iobuf>data 'd' fill",
     {m6in_to_ibuf, m6iobuf_data, m6_lit_, T('d'), m6fill, m6bye},
     {{}, {}},
     {{}, {}},
     {"12345678901234567890123456789012345678901234567890123456789012345", ""},
     {"ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd", ""}},
};

static const m6testio testio_e[] = {
    /* ------------------------- interpret ---------------------------------- */
    {"interpret", {CALL(interpret), m6bye}, {{}, {}}, {{1, {3}}, {}}, {" 3 2", ""}, {" 2", ""}},
    /* ------------------------- repl --------------------------------------- */
    {"repl", {CALL(repl), m6bye}, {{}, {}}, {{1, {56}}, {}}, {"7 8 *", ""}, {"", " ok\n"}},
};

/* -------------- m6cstr -------------- */

static void m6cstr_print_escape(const char *cstr, FILE *out) {
    if (cstr) {
        m6ucell len = (m6ucell)strlen(cstr);
        fprintf(out, "<%ld> [", (unsigned long)len);
        m6string_print_escape(m6string_make(cstr, len), out);
        fputc(']', out);
    } else {
        fputs("<0> []", out);
    }
}

static m6ucell m6cstr_len(const char *cstr) {
    return cstr ? strlen(cstr) : 0;
}

/* -------------- m6ibuf_with_counteddata -------------- */

static m6pair m6ibuf_with_counteddata_read_c(m6counteddata *src, m6char *dst, m6ucell n) {
    m6ucell chunk = src->n < n ? src->n : n;
    m6pair ret = {{chunk}, chunk ? 0 : m6err_unexpected_eof};
    memcpy(dst, src->addr, chunk);
    if ((src->n -= chunk) != 0) {
        memmove(src->addr + chunk, src->addr, src->n);
    }
    return ret;
}

/* ( io c-addr u -- u' err ) */
static const m6cell m6ibuf_with_counteddata_read_w[m6test_code_n] = {
    m6_c_arg_3_, m6_c_call_, CELL(m6ibuf_with_counteddata_read_c), m6_c_ret_2_, m6exit,
};

static m6token m6ibuf_with_counteddata_read[m6test_code_n];

static void m6ibuf_with_counteddata_init(m6iobuf *in, m6ucell capacity) {
    /* reuse part of in->addr buffer as m6counteddata */
    m6counteddata *d = (m6counteddata *)(in->addr + capacity);
    d->n = 0;
    in->handle = (m6cell)d;
    in->func = m6ibuf_with_counteddata_read;
    in->max = capacity; /* reduced capacity is used to trigger iobuf refill */
}

static m6cell m6ibuf_with_counteddata_equal(const m6iobuf *io, const char *cstr) {
    const m6counteddata *d = (m6counteddata *)io->handle;
    const m6ucell n = m6cstr_len(cstr);
    const m6ucell nd = d ? d->n : 0;
    const m6ucell nio = io->end - io->pos;
    return nio + nd == n && (nio == 0 || !memcmp(io->addr + io->pos, cstr, nio)) &&
           (nd == 0 || !memcmp(d->addr, cstr + nio, nd));
}

static void m6ibuf_with_counteddata_fill(m6iobuf *io, const char *cstr) {
    m6counteddata *d = (m6counteddata *)io->handle;
    m6ucell n = m6cstr_len(cstr);
    m6ucell max = io->max;
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

static void m6ibuf_with_counteddata_print(const m6iobuf *io, FILE *out) {
    const m6counteddata *d = (m6counteddata *)io->handle;
    const m6ucell nd = d ? d->n : 0;
    const m6ucell nio = io->end - io->pos;
    fprintf(out, "<%lu> [", (unsigned long)(nd + nio));
    if (io->end >= io->pos && nio) {
        m6string_print_escape(m6string_make(io->addr + io->pos, nio), out);
    }
    if (nd) {
        m6string_print_escape(m6string_make(d->addr, nd), out);
    }
    fputc(']', out);
}

/* -------------- m6obuf_with_counteddata -------------- */

static m6pair m6obuf_with_counteddata_write_c(m6counteddata *dst, const m6char *src, m6ucell n) {
    m6pair ret = {{n}, 0};
    memcpy(dst->addr + dst->n, src, n);
    dst->n += n;
    return ret;
}

/* ( io c-addr u -- u' err ) */
static const m6cell m6obuf_with_counteddata_write_w[m6test_code_n] = {
    m6_c_arg_3_, m6_c_call_, CELL(m6obuf_with_counteddata_write_c), m6_c_ret_2_, m6exit,
};

static m6token m6obuf_with_counteddata_write[m6test_code_n];

static void m6obuf_with_counteddata_init(m6iobuf *out) {
    /* reuse part of out->addr buffer as m6counteddata */
    m6counteddata *d = (m6counteddata *)(out->addr + SZ);
    d->n = 0;
    out->handle = (m6cell)d;
    out->func = m6obuf_with_counteddata_write;
    out->max = 2; /* reduce capacity to trigger iobuf flush */
}

static m6cell m6obuf_with_counteddata_equal(const m6iobuf *io, const char *cstr) {
    const m6counteddata *d = (m6counteddata *)io->handle;
    const m6ucell n = m6cstr_len(cstr);
    const m6ucell nd = d ? d->n : 0;
    const m6ucell nio = io->end - io->pos;
    return nd + nio == n && (nd == 0 || !memcmp(d->addr, cstr, nd)) &&
           (nio == 0 || !memcmp(io->addr + io->pos, cstr + nd, nio));
}

static void m6obuf_with_counteddata_fill(m6iobuf *io, const char *cstr) {
    m6counteddata *d = (m6counteddata *)io->handle;
    m6ucell n = m6cstr_len(cstr);
    m6ucell max = io->max;
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

static void m6obuf_with_counteddata_print(const m6iobuf *io, FILE *out) {
    const m6counteddata *d = (m6counteddata *)io->handle;
    const m6ucell nd = d ? d->n : 0;
    const m6ucell nio = io->end - io->pos;
    fprintf(out, "<%lu> [", (unsigned long)(nd + nio));
    if (nd) {
        m6string_print_escape(m6string_make(d->addr, nd), out);
    }
    if (io->end >= io->pos && nio) {
        m6string_print_escape(m6string_make(io->addr + io->pos, nio), out);
    }
    fputc(']', out);
}

/* -------------- m6testio -------------- */

static void m6testio_global_init() {
    {
        m6slice code_in = {(m6cell *)m6ibuf_with_counteddata_read_w, m6test_code_n};
        m6code code = {m6ibuf_with_counteddata_read, m6test_code_n};
        m6slice_copy_to_code(code_in, &code);
    }
    {
        m6slice code_in = {(m6cell *)m6obuf_with_counteddata_write_w, m6test_code_n};
        m6code code = {m6obuf_with_counteddata_write, m6test_code_n};
        m6slice_copy_to_code(code_in, &code);
    }
}

static m6code m6testio_init(const m6testio *t, m6countedcode *code_buf) {
    m6slice t_code_in = {(m6cell *)t->code, m6test_code_n};
    m6code t_code = {code_buf->data, code_buf->n};
    m6slice_copy_to_code(t_code_in, &t_code);
    return t_code;
}

static m6cell m6testio_run(m64th *m, const m6testio *t, const m6code *code) {
    m64th_clear(m);

    m6countedstack_copy(&t->before.d, &m->dstack);
    m6countedstack_copy(&t->before.r, &m->rstack);
    m6ibuf_with_counteddata_fill(m->in, t->iobefore.in);
    m6obuf_with_counteddata_fill(m->out, t->iobefore.out);

    m->ip = code->addr;
    m64th_run(m);

    return m6countedstack_equal(&t->after.d, &m->dstack) &&
           m6countedstack_equal(&t->after.r, &m->rstack) &&
           m6ibuf_with_counteddata_equal(m->in, t->ioafter.in) &&
           m6obuf_with_counteddata_equal(m->out, t->ioafter.out);
}

static void m6testio_failed(const m64th *m, const m6testio *t, FILE *out) {
    if (out == NULL) {
        return;
    }
    fprintf(out, "  I/O   test failed: %s", t->name);
    fputs("\n    expected  data  stack ", out);
    m6countedstack_print(&t->after.d, out);
    fputs("\n      actual  data  stack ", out);
    m6stack_print(&m->dstack, m6mode_user, out);

    fputs("\n... expected return stack ", out);
    m6countedstack_print(&t->after.r, out);
    fputs("\n      actual return stack ", out);
    m6stack_print(&m->rstack, m6mode_user, out);

    fputs("\n... expected  in   buffer ", out);
    m6cstr_print_escape(t->ioafter.in, out);
    fputs("\n      actual  in   buffer ", out);
    m6ibuf_with_counteddata_print(m->in, out);

    fputs("\n... expected  out  buffer ", out);
    m6cstr_print_escape(t->ioafter.out, out);
    fputs("\n      actual  out  buffer ", out);
    m6obuf_with_counteddata_print(m->out, out);
    fputc('\n', out);
}

static void m6testio_bunch(m64th *m, const m6testio bunch[], m6cell n, m6testcount *count, FILE *out,
                           m6ucell ibuf_capacity) {
    const m6iobuf ibuf = *m->in, obuf = *m->out;
    m6countedcode countedcode = {m6test_code_n, {}};
    m6cell i, fail = 0;

    m6ibuf_with_counteddata_init(m->in, ibuf_capacity);
    m6obuf_with_counteddata_init(m->out);

    for (i = 0; i < n; i++) {
        m6code code = m6testio_init(&bunch[i], &countedcode);
        if (!m6testio_run(m, &bunch[i], &code)) {
            fail++, m6testio_failed(m, &bunch[i], out);
        }
    }
    count->failed += fail;
    count->total += n;
    /* restore m->in and m->out */
    *m->in = ibuf;
    *m->out = obuf;
}

m6cell m64th_testio(m64th *m, FILE *out) {
    m6testcount count = {};
    m6testio_global_init();
    m6testio_bunch(m, testio_a, N_OF(testio_a), &count, out, SZ2);
    m6testio_bunch(m, testio_b, N_OF(testio_b), &count, out, M64TH_PICT_MAXSIZE);
    m6testio_bunch(m, testio_c, N_OF(testio_c), &count, out, SZ2);
    m6testio_bunch(m, testio_d, N_OF(testio_d), &count, out, 80);
    m6testio_bunch(m, testio_e, N_OF(testio_e), &count, out, SZ2);

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

#endif /* M64TH_T_TESTIO_C */
