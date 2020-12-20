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

#ifndef M64TH_T_TESTCOMPILE_C
#define M64TH_T_TESTCOMPILE_C

#include "../impl.h"
#include "../include/m64th.h"
#include "../include/word_fwd.h"
#include "../include/wordlist_fwd.h"
#include "testcommon.h"

#define XT(name) CELL(DXT(name))

/* control stack contents for a word being compiled: tell optimizer not to compile to ASM */
#define COLON_SYS M6FLAG_NOASM, m6colon

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */
#include <string.h> /* memcpy()          */

/* -------------- m6testcompile -------------- */

static const m6testcompile testcompile_a[] = {
    /* ------------------------------- numbers ------------------------------ */
    {"", {}, {}, {}},
    {"0", {}, {}, {1, {m6zero}}},
    {"1 2", {}, {}, {2, {m6one, m6two}}},
    {"3 4 8", {}, {}, {3, {m6three, m6four, m6eight}}},
    {"-1 5", {}, {}, {2, {m6minus_one, m6five}}},
    {"-3 9", {}, {}, {4, {m6_lit_, T(-3), m6_lit_, T(9)}}},
    {"'!'", {}, {}, {2, {m6_lit_, T('!')}}},
    {"'4'", {}, {}, {2, {m6_lit_, T('4')}}},
    {"'@'", {}, {}, {2, {m6_lit_, T('@')}}},
    {"'k'", {}, {}, {2, {m6_lit_, T('k')}}},
    {"'~'", {}, {}, {2, {m6_lit_, T('~')}}},
    {"#1234", {}, {}, {2, {m6_lit_, T(1234)}}},
    {"#-4321", {}, {}, {2, {m6_lit_, T(-4321)}}},
    {"$99", {}, {}, {2, {m6_lit_, T(0x99)}}},
    {"$-7def", {}, {}, {2, {m6_lit_, T(-0x7def)}}},
    {"$-7DEF", {}, {}, {2, {m6_lit_, T(-0x7def)}}},
    {"%1011", {}, {}, {2, {m6_lit_, T(0xb)}}},
#if SZ >= 4
    {"12345678", {}, {}, {3, {m6_lit4s_, INT(12345678)}}},
    {"$12abcdef", {}, {}, {3, {m6_lit4s_, INT(0x12abcdef)}}},
    {"$12FEDCBA", {}, {}, {3, {m6_lit4s_, INT(0x12fedcba)}}},
#endif
#if SZ >= 8
    {"$7fffffffffffffff", {}, {}, {5, {m6_lit8s_, CELL(0x7fffffffffffffffl)}}},
#endif
#if SZ == 8
    {"$ffffffffffffffff", {}, {}, {1, {m6minus_one}}},
#endif
    /* ------------------------------- literal ------------------------------ */
    {"LITERAL", {1, {0}}, {}, {1, {m6zero}}},
    {"LiTeRaL", {1, {0}}, {}, {1, {m6zero}}},
    {"literal", {1, {-3}}, {}, {2, {m6_lit_, T(-3)}}},
    {"literal", {1, {-2}}, {}, {1, {m6minus_two}}},
    {"literal", {1, {-1}}, {}, {1, {m6minus_one}}},
    {"literal", {1, {0}}, {}, {1, {m6zero}}},
    {"literal", {1, {1}}, {}, {1, {m6one}}},
    {"literal", {1, {2}}, {}, {1, {m6two}}},
    {"literal", {1, {3}}, {}, {1, {m6three}}},
    {"literal", {1, {4}}, {}, {1, {m6four}}},
    {"literal", {1, {5}}, {}, {1, {m6five}}},
    {"literal", {1, {8}}, {}, {1, {m6eight}}},
    {"literal", {1, {11}}, {}, {2, {m6_lit_, 11}}},
    {"literal", {1, {0x7fff}}, {}, {2, {m6_lit_, 0x7fff}}},
    {"literal", {1, {-0x8000}}, {}, {2, {m6_lit_, T(-0x8000)}}},
#if SZ >= 4
    {"literal", {1, {0x8000}}, {}, {3, {m6_lit4s_, INT(0x8000)}}},
    {"literal", {1, {-0x8001}}, {}, {3, {m6_lit4s_, INT(-0x8001)}}},
    {"literal", {1, {(m6cell)0x7fffffffl}}, {}, {3, {m6_lit4s_, INT(0x7fffffffl)}}},
    {"literal", {1, {(m6cell)-0x80000000l}}, {}, {3, {m6_lit4s_, INT(-0x80000000l)}}},
#endif
#if SZ >= 8
    {"literal", {1, {0x80000000l}}, {}, {5, {m6_lit8s_, CELL(0x80000000l)}}},
    {"literal", {1, {-0x80000001l}}, {}, {5, {m6_lit8s_, CELL(-0x80000001l)}}},
    {"literal",
     {1, {(m6cell)0x7fffffffffffffffl}},
     {},
     {5, {m6_lit8s_, CELL(0x7fffffffffffffffl)}}},
    {"literal",
     {1, {(m6cell)-0x8000000000000000l}},
     {},
     {5, {m6_lit8s_, CELL(-0x8000000000000000l)}}},
#endif
    /* ------------------------------- tokens ------------------------------- */
    {"! * + - /", {}, {}, {5, {m6store, m6times, m6plus, m6minus, m6div}}},
    {"<> = 0<> 0=", {}, {}, {4, {m6ne, m6equal, m6zero_ne, m6zero_equal}}},
    {"< <= > >=", {}, {}, {4, {m6less, m6less_equal, m6more, m6more_equal}}},
    {"u< u<= u> u>=", {}, {}, {4, {m6u_less, m6u_less_equal, m6u_more, m6u_more_equal}}},
    {"0< 0<= 0> 0>=",
     {},
     {},
     {4, {m6zero_less, m6zero_less_equal, m6zero_more, m6zero_more_equal}}},
    {"/mod drop false true", {}, {}, {4, {m6div_mod, m6drop, m6false, m6true}}},
    {"?dup dup exit", {}, {}, {3, {m6question_dup, m6dup, m6exit}}},
    {"string=", {}, {}, {1, {m6string_equal}}},
    {"string<>", {}, {}, {2, {m6string_equal, m6zero_equal}}},
    {"STRING-CI=", {}, {}, {1, {m6string_ci_equal}}},
    {"sTrInG-CI<>", {}, {}, {2, {m6string_ci_equal, m6zero_equal}}},
    {"c, short, int, ,", {}, {}, {4, {m6c_comma, m6short_comma, m6int_comma, m6comma}}},
    /* ------------------------------- immediate words ---------------------- */
    {"s\"  fubar\"", {}, {}, {3, {LIT_STRING(6, " fubar")}}},
    {".\"  abcde\"", {}, {}, {4, {LIT_STRING(6, " abcde"), m6type}}},
    /* ------------------------------- words -------------------------------- */
    {"compile,", {}, {}, {1 + nCALLt, {CALL(compile_comma)}}},
    {"valid-base?", {}, {}, {4, {/*inlined*/ m6two, m6_lit_, T(37), m6within}}},
};

typedef struct m6named_word_s {
    /* use a single struct to prevent compiler and linker from placing them too apart: */
    /* the distance between 'str' and 'word' must fit the uint16_t 'm6word.name_off' */
    m6countedstring str;
    m6char name[15];
    m6word word;
    m6token code[2 + nCALLt];
} m6named_word;

static m6named_word test_defer = {
    {10, {}}, /* addr[] is initialized below */
    "test_defer",
    {
        0,            /* prev_off          */
        16,           /* name_off          */
        {-1, 0},      /* eff  stackeffects */
        {0, 0},       /* jump stackeffects */
        -1,           /* asm_len           */
        m6flag_defer, /* flags             */
        3 + nCALLt,   /* code_n            */
        0,            /* data_n            */
        {},           /* code[] is initialized below */
    },
    {m6_call_, CELL(0), m6exit},
};

static m6named_word test_value = {
    {10, {}}, /* addr[] is initialized below */
    "test_value",
    {
        0,            /* prev_off          */
        16,           /* name_off          */
        {0x10, 0},    /* eff  stackeffects */
        {0, 0},       /* jump stackeffects */
        -1,           /* asm_len           */
        m6flag_value, /* flags             */
        3 + nCALLt,   /* code_n            */
        0,            /* data_n            */
        {},           /* code is initialized below */
    },
    {m6_ip_to_data_addr_, m6fetch, m6exit},
};

static const m6testcompile testcompile_b[] = {
    /* ------------------------------- defining words ----------------------- */
    /* we must exit compilation state first... hence '[' */
    {"[ 0 constant zero", {}, {}, {2, {m6zero, m6exit}}},
    {"[ 4 constant four", {}, {}, {2, {m6four, m6exit}}},
    {"[ $7eef constant my-number", {}, {}, {3, {m6_lit_, T(0x7eef), m6exit}}},
    {"[ create w", {}, {}, {3 + nCALLt, {m6_ip_to_data_addr_, CALL(noop), m6exit}}},
    {"[ :noname 1", {}, {2, {M6FLAG_NONAME, m6colon}}, {1, {m6one}}},
    {"[ :noname 2 ; execute", {}, {1, {2}}, {2, {m6two, m6exit}}},
    {"[ defer df", {}, {}, {2 + nCALLt, {CALL(_defer_uninitialized_), m6exit}}},
    {"[ defer dg ' dg defer@", {}, {1, {0}}, {2 + nCALLt, {CALL(_defer_uninitialized_), m6exit}}},
    {"[ defer dh ' dh ' min over defer! defer@",
     {},
     {1, {XT(min)}},
     {2 + nCALLt, {CALL(min), m6exit}}},
    {"[ defer di action-of di", {}, {1, {0}}, {2 + nCALLt, {CALL(_defer_uninitialized_), m6exit}}},
    {"[ defer dj ' depth is dj action-of dj",
     {},
     {1, {XT(depth)}},
     {2 + nCALLt, {CALL(depth), m6exit}}},
    {"action-of test_defer",
     {},
     {},
     {2 + 2 * nCALLt, {m6_lit_xt_, CELL(test_defer.code), CALL(defer_fetch)}}},
    {"[ variable x", {}, {}, {2, {m6_ip_to_data_addr_, m6exit}}},
    {"[ 3 value y ] ;", {}, {}, {3, {m6_ip_to_data_addr_, m6fetch, m6exit}}},
    {"[ 2 value z 1 to z z", {}, {1, {1}}, {3, {m6_ip_to_data_addr_, m6fetch, m6exit}}},
    {"to test_value", {}, {}, {2 + nCALLt, {m6_lit_nt_body_, CELL(&test_value.word), m6store}}},
};

static const m6testcompile testcompile_c[] = {
    /* ------------------------------- compile-only words ------------------- */
    /* ------------------------------- '  ['] ------------------------------- */
    {"[ ' true", {}, {1, {XT(true)}}, {}},
    {"['] true", {}, {}, {1 + nCALLt, {m6_lit_xt_, XT(true)}}},
    /* ------------------------------- if else then ------------------------- */
    {"if", {}, {2, {2, m6_if_}}, {2, {m6_if_, T(-1)}}},
    {"if then", {}, {}, {3, {m6_if_, T(1), m6then}}},
    {"if 1 then", {}, {}, {4, {m6_if_, T(2), m6one, m6then}}},
    {"if dup then", {}, {}, {4, {m6_if_, T(2), m6dup, m6then}}},
    {"if else", {}, {2, {4, m6_else_}}, {4, {m6_if_, T(2), m6_else_, T(-1)}}},
    {"if else then", {}, {}, {5, {m6_if_, T(2), m6_else_, T(1), m6then}}},
    {"if 1 else 2 then", {}, {}, {7, {m6_if_, T(3), m6one, m6_else_, T(2), m6two, m6then}}},
    {"if + else - then", {}, {}, {7, {m6_if_, T(3), m6plus, m6_else_, T(2), m6minus, m6then}}},
    {"if + if * else / then else - then",
     {},
     {},
     {14,
      {m6_if_, T(10), m6plus, m6_if_, T(3), m6times, m6_else_, T(2), m6div, m6then, m6_else_, T(2),
       m6minus, m6then}}},
    /* ------------------------------- ahead -------------------------------- */
    {"ahead", {}, {2, {2, m6_ahead_}}, {2, {m6_ahead_, T(-1)}}},
    {"ahead then", {}, {}, {3, {m6_ahead_, T(1), m6then}}},
    {"ahead 1 then", {}, {}, {4, {m6_ahead_, T(2), m6one, m6then}}},
    /* ------------------------------- do loop ------------------------------ */
    {"do", {}, {2, {2, m6_do_}}, {2, {m6_do_, T(-1)}}},
    {"?do", {}, {2, {2, m6_do_}}, {2, {m6_q_do_, T(-1)}}},
    {"do loop", {}, {}, {4, {m6_do_, T(2), m6_loop_, T(-2)}}},
    {"do 1 +loop", {}, {}, {5, {m6_do_, T(3), m6one, m6_plus_loop_, T(-3)}}},
    {"do i +loop", {}, {}, {5, {m6_do_, T(3), m6i, m6_plus_loop_, T(-3)}}},
    {"do i . loop",
     {},
     {},
     {6 + nCALLt, {m6_do_, T(4 + nCALLt), m6i, CALL(dot), m6_loop_, T(-4 - nCALLt)}}},
    {"?do i . loop",
     {},
     {},
     {6 + nCALLt, {m6_q_do_, T(4 + nCALLt), m6i, CALL(dot), m6_loop_, T(-4 - nCALLt)}}},
    {"do leave", {}, {4, {2, m6_do_, 4, m6_leave_}}, {4, {m6_do_, -1, m6_leave_, T(-1)}}},
    {"do leave loop", {}, {}, {6, {m6_do_, T(4), m6_leave_, T(2), m6_loop_, T(-4)}}},
    {"?do leave loop", {}, {}, {6, {m6_q_do_, T(4), m6_leave_, T(2), m6_loop_, T(-4)}}},
    {"do if ", {}, {4, {2, m6_do_, 4, m6_if_}}, {4, {m6_do_, T(-1), m6_if_, T(-1), T(-1)}}},
    {"do if leave",
     {},
     {6, {2, m6_do_, 6, m6_leave_, 4, m6_if_}},
     {6, {m6_do_, T(-1), m6_if_, T(-1), m6_leave_, T(-1)}}},
    {"do if leave then",
     {},
     {4, {2, m6_do_, 6, m6_leave_}},
     {7, {m6_do_, T(-1), m6_if_, T(3), m6_leave_, T(-1), m6then}}},
    {"do if leave then loop",
     {},
     {},
     {9, {m6_do_, T(7), m6_if_, T(3), m6_leave_, T(3), m6then, m6_loop_, T(-7)}}},
    /* ------------------------------- begin ... ---------------------------- */
    {"begin", {}, {2, {1, m6begin}}, {1, {m6begin}}},
    {"begin again", {}, {}, {3, {m6begin, m6_again_, T(-2)}}},
    {"begin 1+ again", {}, {}, {4, {m6begin, m6one_plus, m6_again_, T(-3)}}},
    {"begin if", {}, {4, {1, m6begin, 3, m6_if_}}, {3, {m6begin, m6_if_, T(-1)}}},
    {"begin if then", {}, {2, {1, m6begin}}, {4, {m6begin, m6_if_, T(1), m6then}}},
    {"begin if then again", {}, {}, {6, {m6begin, m6_if_, T(1), m6then, m6_again_, T(-5)}}},
    {"begin 1 until", {}, {}, {4, {m6begin, m6one, m6_until_, T(-3)}}},
    {"begin while", {}, {4, {3, m6_while_, 1, m6begin}}, {3, {m6begin, m6_while_, T(-1)}}},
    {"begin while again",
     {},
     {2, {3, m6_while_}},
     {5, {m6begin, m6_while_, T(-1), m6_again_, T(-4)}}},
    {"begin while again then", {}, {}, {6, {m6begin, m6_while_, T(3), m6_again_, T(-4), m6then}}},
    {"begin while repeat", {}, {}, {5, {m6begin, m6_while_, T(2), m6_repeat_, T(-4)}}},
    /* ------------------------------- case of endof endcase ---------------- */
    {"case", {}, {2, {1, m6case}}, {1, {m6case}}},
    {"case 1 of", {}, {4, {1, m6case, 4, m6_of_}}, {4, {m6case, m6one, m6_of_, T(-1)}}},
    {"case 1 of 2 endof",
     {},
     {4, {1, m6case, 7, m6_endof_}},
     {7, {m6case, m6one, m6_of_, T(3), m6two, m6_endof_, T(-1)}}},
    {"case 2 of 3 endof 4 of 5 endof",
     {},
     {6, {1, m6case, 7, m6_endof_, 13, m6_endof_}},
     {13,
      {m6case, m6two, m6_of_, T(3), m6three, m6_endof_, T(-1), m6four, m6_of_, T(3), m6five,
       m6_endof_, T(-1)}}},
    {"case endcase", {}, {}, {2, {m6case, m6endcase}}},
    {"case 3 of 4 endof 5 of 6 endof 7 endcase",
     {},
     {},
     {15,
      {m6case, m6three, m6_of_, T(3), m6four, m6_endof_, T(8), m6five, m6_of_, T(3), m6six,
       m6_endof_, T(2), m6seven, m6endcase}}},
    /* ------------------------------- case of fallthrough ------------------ */
    {"case 1 of fallthrough",
     {},
     {4, {1, m6case, 6, m6_fallthrough_}},
     {6, {m6case, m6one, m6_of_, T(2), m6_fallthrough_, T(-1)}}},
    {"case 1 of fallthrough 2 of fallthrough",
     {},
     {4, {1, m6case, 11, m6_fallthrough_}},
     {11,
      {m6case, m6one, m6_of_, T(2), m6_fallthrough_, T(3), m6two, m6_of_, T(2), m6_fallthrough_,
       T(-1)}}},
    {"case 1 of fallthrough endcase",
     {},
     {},
     {7, {m6case, m6one, m6_of_, T(2), m6_fallthrough_, T(0), m6endcase}}},
    /* ------------------------------- does> -------------------------------- */
    {"does> ;", {2, {COLON_SYS}}, {}, {3 + nCALLt, {CALL(_does_), m6_does_exit_, m6exit}}},
    {"does> 1+ ;",
     {2, {COLON_SYS}},
     {},
     {4 + nCALLt, {CALL(_does_), m6_does_exit_, m6one_plus, m6exit}}},
    /* ------------------------------- postpone ----------------------------- */
    {"postpone then ;", {2, {COLON_SYS}}, {}, {2 + nCALLt, {CALL(then), m6exit}}},
    {"postpone and ;",
     {2, {COLON_SYS}},
     {},
     {3 + 2 * nCALLt, {m6_lit_xt_, XT(and), CALL(compile_comma), m6exit}}},
    /* ------------------------------- recurse ------------------------------ */
    {"recurse ;", {2, {COLON_SYS}}, {}, {3, {m6_recurse_, T(-2), m6exit}}},
    /* exception while compiling: must stop compiling and discard rest of line */
    {"non-existent-name 1", {4, {COLON_SYS, -1, -1}}, {}, {}},
};

static const m6testcompile testcompile_d[] = {
    /* ------------------------------- (optimize-1token) -------------------- */
    {"cell+ ;", {2, {COLON_SYS}}, {}, {2, {m6_SZ_plus, m6exit}}},
    {"cells ;", {2, {COLON_SYS}}, {}, {2, {m6_SZ_times, m6exit}}},
    {"char+ ;", {2, {COLON_SYS}}, {}, {2, {m6one_plus, m6exit}}},
    {"chars ;", {2, {COLON_SYS}}, {}, {1, {m6exit}}},
    {"false ;", {2, {COLON_SYS}}, {}, {2, {m6zero, m6exit}}},
    {"noop ;", {2, {COLON_SYS}}, {}, {1, {m6exit}}},
    {"true ;", {2, {COLON_SYS}}, {}, {2, {m6minus_one, m6exit}}},
    /* ------------------------------- (optimize-2token) -------------------- */
    {"1+ 1- ;", {2, {COLON_SYS}}, {}, {1, {m6exit}}},
    {"1+ 1+ ;", {2, {COLON_SYS}}, {}, {2, {m6two_plus, m6exit}}},
    {"1+ noop 1+ ;", {2, {COLON_SYS}}, {}, {2, {m6two_plus, m6exit}}},
    {"swap drop ;", {2, {COLON_SYS}}, {}, {2, {m6nip, m6exit}}},
    {"1 rshift ;", {2, {COLON_SYS}}, {}, {2, {m6u_two_div, m6exit}}},
    {"2 / ;", {2, {COLON_SYS}}, {}, {2, {m6two_sm_div, m6exit}}},
    {"2 u/ ;", {2, {COLON_SYS}}, {}, {2, {m6u_two_div, m6exit}}},
    /* ------------------------------- (optimize-2token-lowprio) ------------ */
    {"drop drop ;", {2, {COLON_SYS}}, {}, {2, {m6two_drop, m6exit}}},
    /* ------------------------------- [recompile] -------------------------- */
    /* test [recompile] to correctly update jump offsets after optimization */
    {"if noop 1+ then ;", {2, {COLON_SYS}}, {}, {5, {m6_if_, T(2), m6one_plus, m6then, m6exit}}},
    {"if 1+ 1+ then ;", {2, {COLON_SYS}}, {}, {5, {m6_if_, T(2), m6two_plus, m6then, m6exit}}},
    {"if recurse then ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6_if_, T(3), m6_recurse_, T(-4), m6then, m6exit}}},
    /* ------------------------------- [optimize-3jump] --------------------- */
    {"if then ;", {2, {COLON_SYS}}, {}, {2, {m6drop, m6exit}}},
    {"if chars then ;", {2, {COLON_SYS}}, {}, {2, {m6drop, m6exit}}},
    {"if 1+ 1- then ;", {2, {COLON_SYS}}, {}, {2, {m6drop, m6exit}}},
    {"if else 1 then ;", {2, {COLON_SYS}}, {}, {5, {m6_if0_, T(2), m6one, m6then, m6exit}}},
    {"0= if then ;", {2, {COLON_SYS}}, {}, {2, {m6drop, m6exit}}},
    {"0= if 1 then ;", {2, {COLON_SYS}}, {}, {5, {m6_if0_, T(2), m6one, m6then, m6exit}}},
    {"0= if else 1 then ;", {2, {COLON_SYS}}, {}, {5, {m6_if_, T(2), m6one, m6then, m6exit}}},
    {"dup if then ;", {2, {COLON_SYS}}, {}, {1, {m6exit}}},
    {"dup if dup then ;", {2, {COLON_SYS}}, {}, {2, {m6question_dup, m6exit}}},
    {"dup if noop then ;", {2, {COLON_SYS}}, {}, {1, {m6exit}}},
    {"dup if 1+ 1- then ;", {2, {COLON_SYS}}, {}, {1, {m6exit}}},
    {"dup if 1 then ;", {2, {COLON_SYS}}, {}, {5, {m6_q_if_, T(2), m6one, m6then, m6exit}}},
    {"dup if else 1 then ;", {2, {COLON_SYS}}, {}, {5, {m6_q_if0_, T(2), m6one, m6then, m6exit}}},
    {"dup 0= if 2 then ;", {2, {COLON_SYS}}, {}, {5, {m6_q_if0_, T(2), m6two, m6then, m6exit}}},
    {"dup 0= if else 3 then ;",
     {2, {COLON_SYS}},
     {},
     {5, {m6_q_if_, T(2), m6three, m6then, m6exit}}},
    /* ------------------------------- [optimize-3token] --------------------- */
    {"256 * ;", {2, {COLON_SYS}}, {}, {2, {m6eight_lshift, m6exit}}},
    {"$ff and ;", {2, {COLON_SYS}}, {}, {2, {m6to_char, m6exit}}},
    {"3 + c@ ;", {2, {COLON_SYS}}, {}, {2, {m6char_fetch_3, m6exit}}},
    /* ------------------------------- (optimize-4token) -------------------- */
    {"over over < choose ;", {2, {COLON_SYS}}, {}, {2, {m6min, m6exit}}},
    /* ------------------------------- [optimize] case ---------------------- */
    {"case endcase ;", {2, {COLON_SYS}}, {}, {2, {m6drop, m6exit}}},
    /* ------------------------------- [optimize] begin --------------------- */
    {"begin noop again ;", {2, {COLON_SYS}}, {}, {4, {m6begin, m6_again_, T(-2), m6exit}}},
    {"begin while noop repeat ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6begin, m6_while_, T(2), m6_repeat_, T(-4), m6exit}}},
    {"begin dup while noop repeat ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6begin, m6_q_while_, T(2), m6_repeat_, T(-4), m6exit}}},
    {"begin dup while dup if then repeat ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6begin, m6_q_while_, T(2), m6_repeat_, T(-4), m6exit}}},
    {"begin dup 0<> while noop repeat ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6begin, m6_q_while_, T(2), m6_repeat_, T(-4), m6exit}}},
    {"begin dup 0= while noop repeat ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6begin, m6_q_while0_, T(2), m6_repeat_, T(-4), m6exit}}},
    {"begin dup 0= while dup if then repeat ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6begin, m6_q_while0_, T(2), m6_repeat_, T(-4), m6exit}}},
    {"begin until ;", {2, {COLON_SYS}}, {}, {4, {m6begin, m6_until_, T(-2), m6exit}}},
    {"begin 0= until ;", {2, {COLON_SYS}}, {}, {4, {m6begin, m6_until0_, T(-2), m6exit}}},
    {"begin 0<> until ;", {2, {COLON_SYS}}, {}, {4, {m6begin, m6_until_, T(-2), m6exit}}},
    {"begin dup until ;", {2, {COLON_SYS}}, {}, {4, {m6begin, m6_q_until_, T(-2), m6exit}}},
    {"begin dup 0= until ;", {2, {COLON_SYS}}, {}, {4, {m6begin, m6_q_until0_, T(-2), m6exit}}},
    /* ------------------------------- [optimize] --------------------------- */
    {"dup dup dup dup drop drop drop drop ;", {2, {COLON_SYS}}, {}, {1, {m6exit}}},
    {"drop dup dup dup drop drop drop drop ;", {2, {COLON_SYS}}, {}, {2, {m6two_drop, m6exit}}},
    {"if drop else nip then ;", {2, {COLON_SYS}}, {}, {2, {m6choose, m6exit}}},
    {"if nip else drop then ;", {2, {COLON_SYS}}, {}, {3, {m6zero_equal, m6choose, m6exit}}},
    {"2dup < if drop else nip then ;", {2, {COLON_SYS}}, {}, {2, {m6min, m6exit}}},
    {"2dup <= if nip else drop then ;", {2, {COLON_SYS}}, {}, {2, {m6max, m6exit}}},
};

static const m6testcompile testcompile_e[] = {
    /* ------------------------------- local variables ---------------------- */
    {"{: :}", {2, {COLON_SYS}}, {2, {COLON_SYS}}, {/* optimized away */}},
    {"{: :} ;", {2, {COLON_SYS}}, {}, {1, {/* optimized away */ m6exit}}},
    {"{: -- a b c :}", {2, {COLON_SYS}}, {2, {COLON_SYS}}, {/* optimized away */}},
    {"{: a :}", {2, {COLON_SYS}}, {2, {COLON_SYS}}, {4, {m6_lenter_x_, T(1), m6_to_lx_, T(0)}}},
    {"{: | c :}", {2, {COLON_SYS}}, {2, {COLON_SYS}}, {2, {m6_lenter_x_, T(1)}}},
    {"{: | c d -- e f :}", {2, {COLON_SYS}}, {2, {COLON_SYS}}, {2, {m6_lenter_x_, T(2)}}},
    {"{: a b c | d -- e f g :}",
     {2, {COLON_SYS}},
     {2, {COLON_SYS}},
     {8, {m6_lenter_x_, T(4), m6_to_lx_, T(1), m6_to_lx_, T(2), m6_to_lx_, T(3)}}},
    {"{: a b | c d -- e f g h :} ;",
     {2, {COLON_SYS}},
     {},
     {5, {m6_lenter_4_, m6_to_l2_, m6_to_l3_, m6_lexit_4_, m6exit}}},
    /* ------------------------------- 'to' local variables ----------------- */
    {"{: | foo :} 7 to foo ;",
     {2, {COLON_SYS}},
     {},
     {5, {m6_lenter_1_, m6seven, m6_to_l0_, m6_lexit_1_, m6exit}}},
    {"{: foo | bar :} 5 dup to bar ;",
     {2, {COLON_SYS}},
     {},
     {6, {m6_lenter_2_, m6_to_l1_, m6five, m6_dup_to_l0_, m6_lexit_2_, m6exit}}},
};

static m6code m6testcompile_init(const m6testcompile *t, m6countedcode *codegen_buf) {
    m6slice t_codegen_in = {(m6cell *)t->codegen.data, t->codegen.n};
    m6code t_codegen = {codegen_buf->data, N_OF(codegen_buf->data)};

    m6slice_copy_to_code(t_codegen_in, &t_codegen);
    return t_codegen;
}

static void m6testcompile_wordlist_add(m6wordlist *wid, m6named_word *nw) {
    if (m6wordlist_find(wid, m6string_count(&nw->str))) {
        return;
    }
    m6wordlist_add_word(wid, &nw->word);
}

static void m6testcompile_fix(m64th *m) {
    m6wordlist *wid = m->searchorder.addr[m->searchorder.n - 1];
    m6testcompile_wordlist_add(wid, &test_defer);
    m6testcompile_wordlist_add(wid, &test_value);
}

static m6cell m6testcompile_run(m64th *m, const m6testcompile *t, m6code t_codegen) {
    m6word *w;
    m6ucell input_n = strlen(t->input);
    const m6countedstack empty = {};

#undef M64TH_TEST_VERBOSE
#ifdef M64TH_TEST_VERBOSE
    printf("%s\n", t->input);
#endif

    m64th_clear(m);

    w = m->lastw = (m6word *)m->mem.start;
    memset(w, '\0', sizeof(m6word));
    m->xt = m6word_xt(w);

    assert(input_n <= m->in->max);
    m->in->pos = 0;
    m->in->end = input_n;
    memcpy(m->in->addr, t->input, input_n);

    m->mem.curr = (m6char *)(w + 1);
    m6countedstack_copy(&t->dbefore, &m->dstack);

    m6testcompile_fix(m);

    m64th_repl(m);

    m64th_sync_lastw(m);

    return m6countedstack_equal(&t->dafter, &m->dstack) &&
           m6countedstack_equal(&empty, &m->rstack) /**/ &&
           m6code_equal(t_codegen, m6word_code(m->lastw));
}

static void m6testcompile_print(const m6testcompile *t, FILE *out) {
    fputs(t->input, out);
    fputc(' ', out);
}

static void m6testcompile_failed(m64th *m, const m6testcompile *t, m6code t_codegen, FILE *out) {
    const m6countedstack empty = {};
    if (out == NULL) {
        return;
    }
    fputs("\ncompile test  failed: ", out);
    m6testcompile_print(t, out);
    fputs("\n    initial   data  stack ", out);
    m6countedstack_print(&t->dbefore, out);
    fputs("\n    expected    codegen   ", out);
    m6code_print(t_codegen, m6mode_user, out);
    fputs("\n      actual    codegen   ", out);
    m6code_print(m6word_code(m->lastw), m6mode_user, out);
    if (t->dafter.len == 0 && m->dstack.curr == m->dstack.end /*__________*/ &&
        m->rstack.curr == m->rstack.end) {
        fputc('\n', out);
        return;
    }
    fputs("\n... expected  data  stack ", out);
    m6countedstack_print(&t->dafter, out);
    fputs("\n      actual  data  stack ", out);
    m6stack_print(&m->dstack, m6mode_user, out);

    fputs("\n... expected return stack ", out);
    m6countedstack_print(&empty, out);
    fputs("\n      actual return stack ", out);
    m6stack_print(&m->rstack, m6mode_user, out);
    fputc('\n', out);
}

m6cell m64th_testcompile(m64th *m, FILE *out) {
    const m6testcompile *t[] = {testcompile_a, testcompile_b, testcompile_c, testcompile_d,
                                testcompile_e};
    const m6cell n[] = {N_OF(testcompile_a), N_OF(testcompile_b), N_OF(testcompile_c),
                        N_OF(testcompile_d), N_OF(testcompile_e)};

    m6countedcode codegen_buf;
    m6cell i, j, run = 0, fail = 0;

    if (!m64th_knows(m, &m6wordlist_m64th_core)) {
        m64th_also(m, &m6wordlist_m64th_core);
    }
    if (!m64th_knows(m, &m6wordlist_m64th_asm)) {
        m64th_also(m, &m6wordlist_m64th_asm);
    }

    for (i = 0; i < (m6cell)N_OF(t); i++) {
        for (j = 0; j < n[i]; j++) {
            const m6testcompile *tc = &t[i][j];
            m6code t_codegen = m6testcompile_init(tc, &codegen_buf);

            if (!m6testcompile_run(m, tc, t_codegen)) {
                fail++, m6testcompile_failed(m, tc, t_codegen, out);
            }
            m6test_forget_all(m);
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

#endif /* M64TH_T_TESTCOMPILE_C */
