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
#include "../include/m4th.h"
#include "../include/word_fwd.h"
#include "../include/wordlist_fwd.h"
#include "testcommon.h"

#define XT(name) CELL(DXT(name))

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */
#include <string.h> /* memcpy()          */

/* -------------- m4testcompile -------------- */

static const m4testcompile testcompile_a[] = {
    /* ------------------------------- numbers ------------------------------ */
    {"", {}, {}, {}},
    {"0", {}, {}, {1, {m4zero}}},
    {"1 2", {}, {}, {2, {m4one, m4two}}},
    {"3 4 8", {}, {}, {3, {m4three, m4four, m4eight}}},
    {"-1 5", {}, {}, {2, {m4minus_one, m4five}}},
    {"-3 9", {}, {}, {4, {m4_lit_, T(-3), m4_lit_, T(9)}}},
    {"'!'", {}, {}, {2, {m4_lit_, T('!')}}},
    {"'4'", {}, {}, {2, {m4_lit_, T('4')}}},
    {"'@'", {}, {}, {2, {m4_lit_, T('@')}}},
    {"'k'", {}, {}, {2, {m4_lit_, T('k')}}},
    {"'~'", {}, {}, {2, {m4_lit_, T('~')}}},
    {"#1234", {}, {}, {2, {m4_lit_, T(1234)}}},
    {"#-4321", {}, {}, {2, {m4_lit_, T(-4321)}}},
    {"$99", {}, {}, {2, {m4_lit_, T(0x99)}}},
    {"$-7def", {}, {}, {2, {m4_lit_, T(-0x7def)}}},
    {"$-7DEF", {}, {}, {2, {m4_lit_, T(-0x7def)}}},
    {"%1011", {}, {}, {2, {m4_lit_, T(0xb)}}},
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
    {"literal", {1, {-3}}, {}, {2, {m4_lit_, T(-3)}}},
    {"literal", {1, {-2}}, {}, {1, {m4minus_two}}},
    {"literal", {1, {-1}}, {}, {1, {m4minus_one}}},
    {"literal", {1, {0}}, {}, {1, {m4zero}}},
    {"literal", {1, {1}}, {}, {1, {m4one}}},
    {"literal", {1, {2}}, {}, {1, {m4two}}},
    {"literal", {1, {3}}, {}, {1, {m4three}}},
    {"literal", {1, {4}}, {}, {1, {m4four}}},
    {"literal", {1, {5}}, {}, {1, {m4five}}},
    {"literal", {1, {8}}, {}, {1, {m4eight}}},
    {"literal", {1, {11}}, {}, {2, {m4_lit_, 11}}},
    {"literal", {1, {0x7fff}}, {}, {2, {m4_lit_, 0x7fff}}},
    {"literal", {1, {-0x8000}}, {}, {2, {m4_lit_, T(-0x8000)}}},
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
    {"s\"  fubar\"", {}, {}, {3, {LIT_STRING(6, " fubar")}}},
    /* ------------------------------- words -------------------------------- */
    {"compile,", {}, {}, {callsz, {CALL(compile_comma)}}},
    {"valid-base?", {}, {}, {4, {/*inlined*/ m4two, m4_lit_, T(37), m4within}}},
    /* ------------------------------- defining words ----------------------- */
    /* we must exit compilation state first... hence '[' */
    {"[ 0 constant zero", {}, {}, {2, {m4zero, m4exit}}},
    {"[ 4 constant four", {}, {}, {2, {m4four, m4exit}}},
    {"[ $7eef constant my-number", {}, {}, {3, {m4_lit_, T(0x7eef), m4exit}}},
    {"[ create w", {}, {}, {3 + nCALLt, {m4_ip_to_data_addr_, CALL(noop), m4exit}}},
    {"[ variable x", {}, {}, {2, {m4_ip_to_data_addr_, m4exit}}},
    /* ------------------------------- '  ['] ------------------------------- */
    {"[ ' true", {}, {1, {XT(true)}}, {}},
    {"['] true", {}, {}, {1 + nCALLt, {m4_lit_xt_, XT(true)}}},
    /* ------------------------------- if else then ------------------------- */
    {"if", {}, {2, {2, m4_if_}}, {2, {m4_if_, T(-1)}}},
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
    {"do 1 +loop", {}, {}, {5, {m4_do_, T(3), m4one, m4_plus_loop_, T(-3)}}},
    {"do i +loop", {}, {}, {5, {m4_do_, T(3), m4i, m4_plus_loop_, T(-3)}}},
    {"do i . loop",
     {},
     {},
     {6 + nCALLt, {m4_do_, T(4 + nCALLt), m4i, CALL(dot), m4_loop_, T(-4 - nCALLt)}}},
    {"?do i . loop",
     {},
     {},
     {6 + nCALLt, {m4_q_do_, T(4 + nCALLt), m4i, CALL(dot), m4_loop_, T(-4 - nCALLt)}}},
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
    {"begin 1 until", {}, {}, {4, {m4begin, m4one, m4_until_, T(-3)}}},
    {"begin while", {}, {4, {3, m4_while_, 1, m4begin}}, {3, {m4begin, m4_while_, T(-1)}}},
    {"begin while again",
     {},
     {2, {3, m4_while_}},
     {5, {m4begin, m4_while_, T(-1), m4_again_, T(-4)}}},
    {"begin while again then", {}, {}, {6, {m4begin, m4_while_, T(3), m4_again_, T(-4), m4then}}},
    {"begin while repeat", {}, {}, {5, {m4begin, m4_while_, T(2), m4_repeat_, T(-4)}}},
    /* ------------------------------- case of endof endcase ---------------- */
    {"case", {}, {2, {1, m4case}}, {1, {m4case}}},
    {"case 1 of", {}, {4, {1, m4case, 4, m4_of_}}, {4, {m4case, m4one, m4_of_, T(-1)}}},
    {"case 1 of 2 endof",
     {},
     {4, {1, m4case, 7, m4_endof_}},
     {7, {m4case, m4one, m4_of_, T(3), m4two, m4_endof_, T(-1)}}},
    {"case 2 of 3 endof 4 of 5 endof",
     {},
     {6, {1, m4case, 7, m4_endof_, 13, m4_endof_}},
     {13,
      {m4case, m4two, m4_of_, T(3), m4three, m4_endof_, T(-1), m4four, m4_of_, T(3), m4five,
       m4_endof_, T(-1)}}},
    {"case endcase", {}, {}, {2, {m4case, m4endcase}}},
    {"case 3 of 4 endof 5 of 6 endof 7 endcase",
     {},
     {},
     {15,
      {m4case, m4three, m4_of_, T(3), m4four, m4_endof_, T(8), m4five, m4_of_, T(3), m4six,
       m4_endof_, T(2), m4seven, m4endcase}}},
    /* ------------------------------- case of fallthrough ------------------ */
    {"case 1 of fallthrough",
     {},
     {4, {1, m4case, 6, m4_fallthrough_}},
     {6, {m4case, m4one, m4_of_, T(2), m4_fallthrough_, T(-1)}}},
    {"case 1 of fallthrough 2 of fallthrough",
     {},
     {4, {1, m4case, 11, m4_fallthrough_}},
     {11,
      {m4case, m4one, m4_of_, T(2), m4_fallthrough_, T(3), m4two, m4_of_, T(2), m4_fallthrough_,
       T(-1)}}},
    {"case 1 of fallthrough endcase",
     {},
     {},
     {7, {m4case, m4one, m4_of_, T(2), m4_fallthrough_, T(0), m4endcase}}},
    /* ------------------------------- does> -------------------------------- */
    {"does> ;", {2, {0, m4colon}}, {}, {3 + nCALLt, {CALL(_does_), m4_does_exit_, m4exit}}},
    {"does> 1+ ;",
     {2, {0, m4colon}},
     {},
     {4 + nCALLt, {CALL(_does_), m4_does_exit_, m4one_plus, m4exit}}},
    /* ------------------------------- postpone ----------------------------- */
    {"postpone then ;", {2, {0, m4colon}}, {}, {2 + nCALLt, {CALL(then), m4exit}}},
    {"postpone and ;",
     {2, {0, m4colon}},
     {},
     {3 + 2 * nCALLt, {m4_lit_xt_, XT(and), CALL(compile_comma), m4exit}}},
};

static const m4testcompile testcompile_b[] = {
    /* ------------------------------- (optimize-1) ------------------------- */
    {"2drop ;", {2, {0, m4colon}}, {}, {3, {m4drop, m4drop, m4exit}}},
    {"cell+ ;", {2, {0, m4colon}}, {}, {2, {m4_SZ_plus, m4exit}}},
    {"cells ;", {2, {0, m4colon}}, {}, {2, {m4_SZ_times, m4exit}}},
    {"char+ ;", {2, {0, m4colon}}, {}, {2, {m4one_plus, m4exit}}},
    {"chars ;", {2, {0, m4colon}}, {}, {1, {m4exit}}},
    {"false ;", {2, {0, m4colon}}, {}, {2, {m4zero, m4exit}}},
    {"noop ;", {2, {0, m4colon}}, {}, {1, {m4exit}}},
    {"true ;", {2, {0, m4colon}}, {}, {2, {m4minus_one, m4exit}}},
    /* ------------------------------- (optimize-2) ------------------------- */
    {"1+ 1- ;", {2, {0, m4colon}}, {}, {1, {m4exit}}},
    {"1+ 1+ ;", {2, {0, m4colon}}, {}, {2, {m4two_plus, m4exit}}},
    {"1+ noop 1+ ;", {2, {0, m4colon}}, {}, {2, {m4two_plus, m4exit}}},
    {"swap drop ;", {2, {0, m4colon}}, {}, {2, {m4nip, m4exit}}},
    /* ------------------------------- [recompile] -------------------------- */
    /* test [recompile] to correctly update jump offsets after optimization */
    {"if noop 1+ then ;", {2, {0, m4colon}}, {}, {5, {m4_if_, T(2), m4one_plus, m4then, m4exit}}},
    {"if 1+ 1+ then ;", {2, {0, m4colon}}, {}, {5, {m4_if_, T(2), m4two_plus, m4then, m4exit}}},
    /* ------------------------------- [optimize] if ------------------------ */
    {"if then ;", {2, {0, m4colon}}, {}, {2, {m4drop, m4exit}}},
    {"if chars then ;", {2, {0, m4colon}}, {}, {2, {m4drop, m4exit}}},
    {"if 1+ 1- then ;", {2, {0, m4colon}}, {}, {2, {m4drop, m4exit}}},
    {"if else 1 then ;", {2, {0, m4colon}}, {}, {5, {m4_if0_, T(2), m4one, m4then, m4exit}}},
    {"0= if then ;", {2, {0, m4colon}}, {}, {2, {m4drop, m4exit}}},
    {"0= if 1 then ;", {2, {0, m4colon}}, {}, {5, {m4_if0_, T(2), m4one, m4then, m4exit}}},
    {"0= if else 1 then ;", {2, {0, m4colon}}, {}, {5, {m4_if_, T(2), m4one, m4then, m4exit}}},
    {"dup if then ;", {2, {0, m4colon}}, {}, {1, {m4exit}}},
    {"dup if dup then ;", {2, {0, m4colon}}, {}, {2, {m4question_dup, m4exit}}},
    {"dup if nop then ;", {2, {0, m4colon}}, {}, {1, {m4exit}}},
    {"dup if 1+ 1- then ;", {2, {0, m4colon}}, {}, {1, {m4exit}}},
    {"dup if 1 then ;", {2, {0, m4colon}}, {}, {5, {m4_q_if_, T(2), m4one, m4then, m4exit}}},
    {"dup if else 1 then ;", {2, {0, m4colon}}, {}, {5, {m4_q_if0_, T(2), m4one, m4then, m4exit}}},
    {"dup 0= if 2 then ;", {2, {0, m4colon}}, {}, {5, {m4_q_if0_, T(2), m4two, m4then, m4exit}}},
    {"dup 0= if else 3 then ;",
     {2, {0, m4colon}},
     {},
     {5, {m4_q_if_, T(2), m4three, m4then, m4exit}}},
    /* ------------------------------- [optimize] case ---------------------- */
    {"case endcase ;", {2, {0, m4colon}}, {}, {2, {m4drop, m4exit}}},
    /* ------------------------------- [optimize] begin --------------------- */
    {"begin nop again ;", {2, {0, m4colon}}, {}, {4, {m4begin, m4_again_, T(-2), m4exit}}},
    {"begin while nop repeat ;",
     {2, {0, m4colon}},
     {},
     {6, {m4begin, m4_while_, T(2), m4_repeat_, T(-4), m4exit}}},
    {"begin dup while nop repeat ;",
     {2, {0, m4colon}},
     {},
     {6, {m4begin, m4_q_while_, T(2), m4_repeat_, T(-4), m4exit}}},
    {"begin dup while dup if then repeat ;",
     {2, {0, m4colon}},
     {},
     {6, {m4begin, m4_q_while_, T(2), m4_repeat_, T(-4), m4exit}}},
    {"begin dup 0<> while nop repeat ;",
     {2, {0, m4colon}},
     {},
     {6, {m4begin, m4_q_while_, T(2), m4_repeat_, T(-4), m4exit}}},
    {"begin dup 0= while nop repeat ;",
     {2, {0, m4colon}},
     {},
     {6, {m4begin, m4_q_while0_, T(2), m4_repeat_, T(-4), m4exit}}},
    {"begin dup 0= while dup if then repeat ;",
     {2, {0, m4colon}},
     {},
     {6, {m4begin, m4_q_while0_, T(2), m4_repeat_, T(-4), m4exit}}},
    {"begin until ;", {2, {0, m4colon}}, {}, {4, {m4begin, m4_until_, T(-2), m4exit}}},
    {"begin 0= until ;", {2, {0, m4colon}}, {}, {4, {m4begin, m4_until0_, T(-2), m4exit}}},
    {"begin 0<> until ;", {2, {0, m4colon}}, {}, {4, {m4begin, m4_until_, T(-2), m4exit}}},
    {"begin dup until ;", {2, {0, m4colon}}, {}, {4, {m4begin, m4_q_until_, T(-2), m4exit}}},
    {"begin dup 0= until ;", {2, {0, m4colon}}, {}, {4, {m4begin, m4_q_until0_, T(-2), m4exit}}},
    /* ------------------------------- [optimize] --------------------- */
    {"dup dup dup dup drop drop drop drop ;", {2, {0, m4colon}}, {}, {1, {m4exit}}},
};

static m4code m4testcompile_init(const m4testcompile *t, m4countedcode *codegen_buf) {
    m4slice t_codegen_in = {(m4cell *)t->codegen.data, t->codegen.n};
    m4code t_codegen = {codegen_buf->data, N_OF(codegen_buf->data)};

    m4slice_copy_to_code(t_codegen_in, &t_codegen);
    return t_codegen;
}

static m4cell m4testcompile_run(m4th *m, const m4testcompile *t, m4code t_codegen) {
    m4word *w;
    m4ucell input_n = strlen(t->input);
    const m4countedstack empty = {};

#undef M4TH_TEST_VERBOSE
#ifdef M4TH_TEST_VERBOSE
    printf("%s\n", t->input);
#endif

    m4th_clear(m);

    w = m->lastw = (m4word *)m->mem.start;
    memset(w, '\0', sizeof(m4word));
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
    m4code_print(t_codegen, m4mode_user, out);
    fputs("\n      actual    codegen   ", out);
    m4code_print(m4word_code(m->lastw), m4mode_user, out);
    if (t->dafter.len == 0 && m->dstack.curr == m->dstack.end /*__________*/ &&
        m->rstack.curr == m->rstack.end) {
        fputc('\n', out);
        return;
    }
    fputs("\n... expected  data  stack ", out);
    m4countedstack_print(&t->dafter, out);
    fputs("\n      actual  data  stack ", out);
    m4stack_print(&m->dstack, m4mode_user, out);

    fputs("\n... expected return stack ", out);
    m4countedstack_print(&empty, out);
    fputs("\n      actual return stack ", out);
    m4stack_print(&m->rstack, m4mode_user, out);
    fputc('\n', out);
}

m4cell m4th_testcompile(m4th *m, FILE *out) {
    const m4testcompile *t[] = {testcompile_a, testcompile_b};
    const m4cell n[] = {N_OF(testcompile_a), N_OF(testcompile_b)};

    m4countedcode codegen_buf;
    m4cell i, j, run = 0, fail = 0;

    if (!m4th_knows(m, &m4wordlist_m4th_core)) {
        m4th_also(m, &m4wordlist_m4th_core);
    }

    for (i = 0; i < (m4cell)N_OF(t); i++) {
        for (j = 0; j < n[i]; j++) {
            const m4testcompile *tc = &t[i][j];
            m4code t_codegen = m4testcompile_init(tc, &codegen_buf);

            if (!m4testcompile_run(m, tc, t_codegen)) {
                fail++, m4testcompile_failed(m, tc, t_codegen, out);
            }
            m4test_forget_all(m);
            run++;
        }
    }
    if (out != NULL) {
        if (fail == 0) {
            fprintf(out, "all %3u compile tests passed\n", (unsigned)run);
        } else {
            fprintf(out, "\ncompile tests failed: %3u of %3u\n", (unsigned)fail, (unsigned)run);
        }
    }
    return fail;
}

#endif /* M4TH_T_TESTCOMPILE_C */
