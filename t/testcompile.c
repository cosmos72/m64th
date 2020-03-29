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

#ifndef M4TH_T_TESTCOMPILE_C
#define M4TH_T_TESTCOMPILE_C

#include "../impl.h"
#include "../include/word_fwd.h"
#include "../include/wordlist_fwd.h"
#include "../m4th.h"
#include "testcommon.h"

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */
#include <string.h> /* memcpy()          */

/* -------------- m4testcompile -------------- */

static const m4testcompile testcompile[] = {
    /* ------------------------------- numbers ------------------------------ */
    {"", {}, {}, {}},
    {"0", {}, {}, {1, {m4zero}}},
    {"1 2", {}, {}, {2, {m4one, m4two}}},
    {"3 4 8", {}, {}, {3, {m4three, m4four, m4eight}}},
    {"-1 5", {}, {}, {3, {m4minus_one, m4_lit2s_, T(5)}}},
    {"-3", {}, {}, {2, {m4_lit2s_, T(-3)}}},
    {"'!'", {}, {}, {2, {m4_lit2s_, T('!')}}},
    {"'4'", {}, {}, {2, {m4_lit2s_, T('4')}}},
    {"'@'", {}, {}, {2, {m4_lit2s_, T('@')}}},
    {"'k'", {}, {}, {2, {m4_lit2s_, T('k')}}},
    {"'~'", {}, {}, {2, {m4_lit2s_, T('~')}}},
    {"#1234", {}, {}, {2, {m4_lit2s_, SHORT(1234)}}},
    {"#-4321", {}, {}, {2, {m4_lit2s_, SHORT(-4321)}}},
    {"$99", {}, {}, {2, {m4_lit2s_, SHORT(0x99)}}},
    {"$-7def", {}, {}, {2, {m4_lit2s_, SHORT(-0x7def)}}},
    {"$-7DEF", {}, {}, {2, {m4_lit2s_, SHORT(-0x7def)}}},
    {"%1011", {}, {}, {2, {m4_lit2s_, SHORT(0xb)}}},
#if SZ >= 4
    {"12345678", {}, {}, {3, {m4_lit4s_, INT(12345678)}}},
    {"$12abcdef", {}, {}, {3, {m4_lit4s_, INT(0x12abcdef)}}},
    {"$12FEDCBA", {}, {}, {3, {m4_lit4s_, INT(0x12fedcba)}}},
#endif
#if SZ >= 8
    {"$7fffffffffffffff", {}, {}, {5, {m4_lit8s_, CELL(0x7fffffffffffffffl)}}},
#endif
#if SZ == 8
    {"$ffffffffffffffff", {}, {}, {1, {m4minus_one}}},
#endif
    /* ------------------------------- literal ------------------------------ */
    {"LITERAL", {1, {0}}, {}, {1, {m4zero}}},
    {"LiTeRaL", {1, {0}}, {}, {1, {m4zero}}},
    {"literal", {1, {0}}, {}, {1, {m4zero}}},
    {"literal", {1, {1}}, {}, {1, {m4one}}},
    {"literal", {1, {-1}}, {}, {1, {m4minus_one}}},
    {"literal", {1, {2}}, {}, {1, {m4two}}},
    {"literal", {1, {3}}, {}, {1, {m4three}}},
    {"literal", {1, {4}}, {}, {1, {m4four}}},
    {"literal", {1, {5}}, {}, {2, {m4_lit2s_, 5}}},
    {"literal", {1, {8}}, {}, {1, {m4eight}}},
    {"literal", {1, {11}}, {}, {2, {m4_lit2s_, 11}}},
    {"literal", {1, {-2}}, {}, {2, {m4_lit2s_, -2}}},
    {"literal", {1, {0x7fff}}, {}, {2, {m4_lit2s_, 0x7fff}}},
    {"literal", {1, {-0x8000}}, {}, {2, {m4_lit2s_, -0x8000}}},
#if SZ >= 4
    {"literal", {1, {0x8000}}, {}, {3, {m4_lit4s_, INT(0x8000)}}},
    {"literal", {1, {-0x8001}}, {}, {3, {m4_lit4s_, INT(-0x8001)}}},
    {"literal", {1, {(m4cell)0x7fffffffl}}, {}, {3, {m4_lit4s_, INT(0x7fffffffl)}}},
    {"literal", {1, {(m4cell)-0x80000000l}}, {}, {3, {m4_lit4s_, INT(-0x80000000l)}}},
#endif
#if SZ >= 8
    {"literal", {1, {0x80000000l}}, {}, {5, {m4_lit8s_, CELL(0x80000000l)}}},
    {"literal", {1, {-0x80000001l}}, {}, {5, {m4_lit8s_, CELL(-0x80000001l)}}},
    {"literal",
     {1, {(m4cell)0x7fffffffffffffffl}},
     {},
     {5, {m4_lit8s_, CELL(0x7fffffffffffffffl)}}},
    {"literal",
     {1, {(m4cell)-0x8000000000000000l}},
     {},
     {5, {m4_lit8s_, CELL(-0x8000000000000000l)}}},
#endif
    /* ------------------------------- tokens ------------------------------- */
    {"! * + - /", {}, {}, {5, {m4store, m4times, m4plus, m4minus, m4div}}},
    {"<> = 0<> 0=", {}, {}, {4, {m4ne, m4equal, m4zero_ne, m4zero_equal}}},
    {"< <= > >=", {}, {}, {4, {m4less, m4less_equal, m4more, m4more_equal}}},
    {"u< u<= u> u>=", {}, {}, {4, {m4u_less, m4u_less_equal, m4u_more, m4u_more_equal}}},
    {"0< 0<= 0> 0>=",
     {},
     {},
     {4, {m4zero_less, m4zero_less_equal, m4zero_more, m4zero_more_equal}}},
    {"/mod drop false true", {}, {}, {4, {m4div_mod, m4drop, m4false, m4true}}},
    {"?dup dup exit", {}, {}, {3, {m4question_dup, m4dup, m4exit}}},
    {"string=", {}, {}, {1, {m4string_equal}}},
    {"string<>", {}, {}, {2, {m4string_equal, m4invert}}},
    {"STRING-CI=", {}, {}, {1, {m4string_ci_equal}}},
    {"sTrInG-CI<>", {}, {}, {2, {m4string_ci_equal, m4invert}}},
    {"c, short, int, ,", {}, {}, {4, {m4c_comma, m4short_comma, m4int_comma, m4comma}}},
    /* ------------------------------- immediate words ---------------------- */
    {"?do", {}, {2, {2, m4_do_}}, {2, {m4_q_do_, T(-1)}}},
    {"do", {}, {2, {2, m4_do_}}, {2, {m4_do_, T(-1)}}},
    {"s\"  fubar\"", {}, {}, {3, {LIT_STRING(6, " fubar")}}},
    /* ------------------------------- words -------------------------------- */
    {"compile,", {}, {}, {callsz, {CALLXT(compile_comma)}}},
    {"valid-base?", {}, {}, {4, {/*inlined*/ m4two, m4_lit2s_, T(37), m4within}}},
    /* ------------------------------- if else then ------------------------- */
    {"?if", {}, {2, {2, m4_if_}}, {2, {m4_q_if_, T(-1)}}},
    {"?if0", {}, {2, {2, m4_if_}}, {2, {m4_q_if0_, T(-1)}}},
    {"if", {}, {2, {2, m4_if_}}, {2, {m4_if_, T(-1)}}},
    {"if0", {}, {2, {2, m4_if_}}, {2, {m4_if0_, T(-1)}}},
    {"if then", {}, {}, {3, {m4_if_, T(1), m4then}}},
    {"if 1 then", {}, {}, {4, {m4_if_, T(2), m4one, m4then}}},
    {"if dup then", {}, {}, {4, {m4_if_, T(2), m4dup, m4then}}},
    {"if else", {}, {2, {4, m4_else_}}, {4, {m4_if_, T(2), m4_else_, T(-1)}}},
    {"if else then", {}, {}, {5, {m4_if_, T(2), m4_else_, T(1), m4then}}},
    {"if 1 else 2 then", {}, {}, {7, {m4_if_, T(3), m4one, m4_else_, T(2), m4two, m4then}}},
    {"if + else - then", {}, {}, {7, {m4_if_, T(3), m4plus, m4_else_, T(2), m4minus, m4then}}},
    {"if + if * else / then else - then",
     {},
     {},
     {14,
      {m4_if_, T(10), m4plus, m4_if_, T(3), m4times, m4_else_, T(2), m4div, m4then, m4_else_, T(2),
       m4minus, m4then}}},
    /* ------------------------------- do loop ------------------------------ */
    {"do", {}, {2, {2, m4_do_}}, {2, {m4_do_, T(-1)}}},
    {"?do", {}, {2, {2, m4_do_}}, {2, {m4_q_do_, T(-1)}}},
    {"do loop", {}, {}, {4, {m4_do_, T(2), m4_loop_, T(-2)}}},
    {"do i . loop",
     {},
     {},
     {6 + nCALLt, {m4_do_, T(4 + nCALLt), m4i, CALLXT(dot), m4_loop_, T(-4 - nCALLt)}}},
    {"?do i . loop",
     {},
     {},
     {6 + nCALLt, {m4_q_do_, T(4 + nCALLt), m4i, CALLXT(dot), m4_loop_, T(-4 - nCALLt)}}},
    {"do leave", {}, {4, {2, m4_do_, 4, m4_leave_}}, {4, {m4_do_, -1, m4_leave_, T(-1)}}},
    {"do leave loop", {}, {}, {6, {m4_do_, T(4), m4_leave_, T(2), m4_loop_, T(-4)}}},
    {"?do leave loop", {}, {}, {6, {m4_q_do_, T(4), m4_leave_, T(2), m4_loop_, T(-4)}}},
    {"do if ", {}, {4, {2, m4_do_, 4, m4_if_}}, {4, {m4_do_, T(-1), m4_if_, T(-1), T(-1)}}},
    {"do if leave",
     {},
     {6, {2, m4_do_, 6, m4_leave_, 4, m4_if_}},
     {6, {m4_do_, T(-1), m4_if_, T(-1), m4_leave_, T(-1)}}},
    {"do if leave then",
     {},
     {4, {2, m4_do_, 6, m4_leave_}},
     {7, {m4_do_, T(-1), m4_if_, T(3), m4_leave_, T(-1), m4then}}},
    {"do if leave then loop",
     {},
     {},
     {9, {m4_do_, T(7), m4_if_, T(3), m4_leave_, T(3), m4then, m4_loop_, T(-7)}}},
    /* ------------------------------- begin ... ---------------------------- */
    {"begin", {}, {2, {1, m4begin}}, {1, {m4begin}}},
    {"begin again", {}, {}, {3, {m4begin, m4_again_, T(-2)}}},
    {"begin 1+ again", {}, {}, {4, {m4begin, m4one_plus, m4_again_, T(-3)}}},
    {"begin if", {}, {4, {1, m4begin, 3, m4_if_}}, {3, {m4begin, m4_if_, T(-1)}}},
    {"begin if then", {}, {2, {1, m4begin}}, {4, {m4begin, m4_if_, T(1), m4then}}},
    {"begin if then again", {}, {}, {6, {m4begin, m4_if_, T(1), m4then, m4_again_, T(-5)}}},
};

static m4code m4testcompile_init(const m4testcompile *t, m4countedcode *codegen_buf) {
    m4slice t_codegen_in = {(m4cell *)t->codegen.data, t->codegen.n};
    m4code t_codegen = {codegen_buf->data, N_OF(codegen_buf->data)};

    m4slice_copy_to_code(t_codegen_in, &t_codegen);
    return t_codegen;
}

static m4cell m4testcompile_run(m4th *m, const m4testcompile *t, m4code t_codegen) {
    m4word *w;
    m4cell_u input_n = strlen(t->input);
    const m4countedstack empty = {};

    m4th_clear(m);

    w = m->lastw = (m4word *)m->mem.start;
    memset(w, '\0', sizeof(m4word));
    w->code_off = WORD_OFF_XT;
    m->xt = m4word_xt(w);

    assert(input_n <= m->in->max);
    m->in->pos = 0;
    m->in->end = input_n;
    memcpy(m->in->addr, t->input, input_n);

    m->mem.curr = (m4char *)(w + 1);
    m4countedstack_copy(&t->dbefore, &m->dstack);

    m4th_repl(m);

    m4th_sync_lastw(m);

    return m4countedstack_equal(&t->dafter, &m->dstack) &&
           m4countedstack_equal(&empty, &m->rstack) /**/ &&
           m4code_equal(t_codegen, m4word_code(m->lastw));
}

static void m4testcompile_print(const m4testcompile *t, FILE *out) {
    fputs(t->input, out);
    fputc(' ', out);
}

static void m4testcompile_failed(m4th *m, const m4testcompile *t, m4code t_codegen, FILE *out) {
    const m4countedstack empty = {};
    if (out == NULL) {
        return;
    }
    fputs("\ncompile test  failed: ", out);
    m4testcompile_print(t, out);
    fputs("\n    initial   data  stack ", out);
    m4countedstack_print(&t->dbefore, out);
    fputs("\n    expected    codegen   ", out);
    m4code_print(t_codegen, out);
    fputs("\n      actual    codegen   ", out);
    m4word_code_print(m->lastw, out);
    if (t->dafter.len == 0 && m->dstack.curr == m->dstack.end /*__________*/ &&
        m->rstack.curr == m->rstack.end) {
        fputc('\n', out);
        return;
    }
    fputs("\n... expected  data  stack ", out);
    m4countedstack_print(&t->dafter, out);
    fputs("\n      actual  data  stack ", out);
    m4stack_print(&m->dstack, out);

    fputs("\n... expected return stack ", out);
    m4countedstack_print(&empty, out);
    fputs("\n      actual return stack ", out);
    m4stack_print(&m->rstack, out);
    fputc('\n', out);
}

m4cell m4th_testcompile(m4th *m, FILE *out) {
    m4countedcode codegen_buf;
    m4cell i, fail = 0;

    if (!m4th_knows(m, &m4wordlist_m4th_core)) {
        m4th_also(m, &m4wordlist_m4th_core);
    }

    for (i = 0; i < (m4cell)N_OF(testcompile); i++) {
        const m4testcompile *t = &testcompile[i];
        m4code t_codegen = m4testcompile_init(t, &codegen_buf);

        if (!m4testcompile_run(m, t, t_codegen)) {
            fail++, m4testcompile_failed(m, t, t_codegen, out);
        }
    }
    if (out != NULL) {
        if (fail == 0) {
            fprintf(out, "all %3u compile tests passed\n", (unsigned)i);
        } else {
            fprintf(out, "\ncompile tests failed: %3u of %3u\n", (unsigned)fail, (unsigned)i);
        }
    }
    return fail;
}

#endif /* M4TH_T_TESTCOMPILE_C */
