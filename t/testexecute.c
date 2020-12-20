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

#ifndef M64TH_T_TESTEXECUTE_C
#define M64TH_T_TESTEXECUTE_C

#include "../impl.h"
#include "../include/err.h"
#include "../include/func_fwd.h"
#include "../include/hashmap_number.h"
#include "../include/iobuf.mh"
#include "../include/m64th.h"
#include "../include/m64th.mh"
#include "../include/token.h"
#include "../include/word_fwd.h"
#include "testcommon.h"

#include <assert.h> /* assert()          */
#include <endian.h> /* __BYTE_ORDER      */
#include <string.h> /* memset()          */

/* -------------- m6cell[] -> m6token[] conversion -------------- */

void m6array_n_copy_to_tarray_n(const m6cell array[], const m6cell array_n /*               */,
                                m6token tarray[], const m6cell tarray_n) {
    m6slice src = {(m6cell *)array, array_n};
    m6code dst = {tarray, tarray_n};
    m6slice_copy_to_code(src, &dst);
}

/* -------------- crc1byte -------------- */

/**
 * compiled forth version of m64th_crc1byte (see ../impl.c). forth source would be
 *
 * : crc+ ( crc char -- crc' )
 *   over xor >char cells m64th_crctable + @ swap 8 rshift xor
 * ;
 */
static const m6cell crc1byte_array[] = {
    m6over, m6xor,   m6to_char, m6cells, m6_lit_cell_, CELL(m64th_crctable), m6plus, m6fetch,
    m6swap, m6eight, m6rshift,  m6xor,   m6exit,
};
/* initialized by m64th_testexecute() */
static m6token crc1byte_code[N_OF(crc1byte_array)];

/* -------------- [any-token-gives-cell?] -------------- */

static const m6token testdata_any[] = {
    m6zero, m6one, m6minus_one, m6two, m6four, m6eight,
};

/* -------------- m6test -------------- */

void m6ftest_crc_plus_native_forth(m6arg _); /* implemented in generic_asm/test.S */
void m6ftest_catch_xt_from_native(m6arg _);  /* implemented in generic_asm/test.S */
void m6ftest_exec_xt_from_native(m6arg _);   /* implemented in generic_asm/test.S */

#define _1e9 ((m6cell)1000000000)

static m6testexecute testexecute_a[] = {
#if 0
    {"1e9 0 do i+ loop",
     {m6do, m6i_plus, m6_loop_, T(-3), m6bye},
     {{3, {0, _1e9, 0}}, {}},
     {{1, {_1e9 * (_1e9 - 1) / 2}}, {}},
     {}},
#elif 0
    {"1e9 0 do-i+-loop",
     {m6do_i_plus_loop, m6bye},
     {{3, {0, _1e9, 0}}, {}},
     {{1, {_1e9 * (_1e9 - 1) / 2}}, {}},
     {}},
#elif 0
    {"1e6 0 do wordlist-find loop",
     {m6do, m6j, CALL(wordlist_find), m6_loop_, T(-4 - nCALLt), m6bye},
     {{4, {(m6cell) "dup", 3, 1e6, 0}}, {1, {(m6cell)&m6wordlist_forth}}},
     {{2, {(m6cell) "dup", 3}}, {1, {(m6cell)&m6wordlist_forth}}},
     {}},
#elif 0
    {"1e8 0 do over crc+ loop nip",
     {m6do, m6over, m6_call_, CELL(crc1byte_code), m6_loop_, T(-4 - nCALLt), m6nip, m6bye},
     {{4, {'t', 0xffffffff, 1e8, 0}}, {}},
     {{1, {0x773edc4e}}, {}},
     {}},
#elif 0
    {"1e8 0 do over crc+-native-forth loop nip",
     {m6do, m6over, m6_call_asm_, CELL(m6ftest_crc_plus_native_forth), m6_loop_, T(-4 - nCALLt),
      m6nip, m6bye},
     {{4, {'t', 0xffffffff, 1e8, 0}}, {}},
     {{1, {0x773edc4e}}, {}},
     {}},
#else
    /* ----------------------------- arithmetic ----------------------------- */
    {"*", {m6times, m6bye}, {{2, {20, 7}}, {}}, {{1, {140}}, {}}, {}},
    {"+", {m6plus, m6bye}, {{2, {-3, 2}}, {}}, {{1, {-1}}, {}}, {}},
    {"-", {m6minus, m6bye}, {{2, {3, 5}}, {}}, {{1, {-2}}, {}}, {}},
    {"-20 7 /", {m6div, m6bye}, {{2, {-20, 7}}, {}}, {{1, {-2}}, {}}, {}},
    {"20 7 /", {m6div, m6bye}, {{2, {20, 7}}, {}}, {{1, {2}}, {}}, {}},
    {"-20 7 /mod", {m6div_mod, m6bye}, {{2, {-20, 7}}, {}}, {{2, {-6, -2}}, {}}, {}},
    {"20 7 /mod", {m6div_mod, m6bye}, {{2, {20, 7}}, {}}, {{2, {6, 2}}, {}}, {}},
    {"-1", {m6minus_one, m6bye}, {{}, {}}, {{1, {-1}}, {}}, {}},
    {"0", {m6zero, m6bye}, {{}, {}}, {{1, {}}, {}}, {}},
    {"1", {m6one, m6bye}, {{}, {}}, {{1, {1}}, {}}, {}},
    {"1-", {m6one_minus, m6bye}, {{1, {-3}}, {}}, {{1, {-4}}, {}}, {}},
    {"1+", {m6one_plus, m6bye}, {{1, {-6}}, {}}, {{1, {-5}}, {}}, {}},
    {"2", {m6two, m6bye}, {{}, {}}, {{1, {2}}, {}}, {}},
    {"2*", {m6two_times, m6bye}, {{1, {-6}}, {}}, {{1, {-12}}, {}}, {}},
    {"2+", {m6two_plus, m6bye}, {{1, {-6}}, {}}, {{1, {-4}}, {}}, {}},
    {"2-", {m6two_minus, m6bye}, {{1, {-3}}, {}}, {{1, {-5}}, {}}, {}},
    {"n 2/", {m6two_div, m6bye}, {{1, {-5}}, {}}, {{1, {-3}}, {}}, {}},
    {"u 2/", {m6two_div, m6bye}, {{1, {5}}, {}}, {{1, {2}}, {}}, {}},
    {"2>r", {m6two_to_r, m6bye}, {{3, {7, 8, 9}}, {1, {0}}}, {{1, {7}}, {3, {0, 8, 9}}}, {}},
    {"2drop", {m6two_drop, m6bye}, {{2, {0, 5}}, {}}, {{}, {}}, {}},
    {"_ 2drop", {m6two_drop, m6bye}, {{3, {-3, -2, -1}}, {}}, {{1, {-3}}, {}}, {}},
    {"2dup", {m6two_dup, m6bye}, {{2, {8, 9}}, {}}, {{4, {8, 9, 8, 9}}, {}}, {}},
    {"2dup2>r", {m6two_dup_two_to_r, m6bye}, {{2, {8, 9}}, {}}, {{2, {8, 9}}, {2, {8, 9}}}, {}},
    {"2nip", {m6two_nip, m6bye}, {{4, {1, 2, 3, 4}}, {}}, {{2, {3, 4}}, {}}, {}},
    {"2over", {m6two_over, m6bye}, {{4, {1, 2, 3, 4}}, {}}, {{6, {1, 2, 3, 4, 1, 2}}, {}}, {}},
    {"2r>", {m6two_r_from, m6bye}, {{1, {0}}, {2, {5, 6}}}, {{3, {0, 5, 6}}, {}}, {}},
    {"2r>2drop", {m6two_r_from_two_drop, m6bye}, {{1, {0}}, {2, {7, 8}}}, {{1, {0}}, {}}, {}},
    {"2r@", {m6two_r_fetch, m6bye}, {{1, {0}}, {2, {9, 10}}}, {{3, {0, 9, 10}}, {2, {9, 10}}}, {}},
    {"2swap", {m6two_swap, m6bye}, {{4, {1, 2, 3, 4}}, {}}, {{4, {3, 4, 1, 2}}, {}}, {}},
    {"2tuck", {m6two_tuck, m6bye}, {{4, {1, 2, 3, 4}}, {}}, {{6, {3, 4, 1, 2, 3, 4}}, {}}, {}},
    {"3", {m6three, m6bye}, {{}, {}}, {{1, {3}}, {}}, {}},
    {"4", {m6four, m6bye}, {{}, {}}, {{1, {4}}, {}}, {}},
    {"4*", {m6four_times, m6bye}, {{1, {-7}}, {}}, {{1, {-28}}, {}}, {}},
    {"4+", {m6four_plus, m6bye}, {{1, {-7}}, {}}, {{1, {-3}}, {}}, {}},
    {"n 4/", {m6four_div, m6bye}, {{1, {-27}}, {}}, {{1, {-7}}, {}}, {}},
    {"u 4/", {m6four_div, m6bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"5", {m6five, m6bye}, {{}, {}}, {{1, {5}}, {}}, {}},
    {"6", {m6six, m6bye}, {{}, {}}, {{1, {6}}, {}}, {}},
    {"7", {m6seven, m6bye}, {{}, {}}, {{1, {7}}, {}}, {}},
    {"8", {m6eight, m6bye}, {{}, {}}, {{1, {8}}, {}}, {}},
    {"8*", {m6eight_times, m6bye}, {{1, {-3}}, {}}, {{1, {-24}}, {}}, {}},
    {"8+", {m6eight_plus, m6bye}, {{1, {-3}}, {}}, {{1, {5}}, {}}, {}},
    {"n 8/", {m6eight_div, m6bye}, {{1, {-25}}, {}}, {{1, {-4}}, {}}, {}},
    {"u 8/", {m6eight_div, m6bye}, {{1, {31}}, {}}, {{1, {3}}, {}}, {}},
    /*                                                                          */
    {"0 ?dup", {m6question_dup, m6bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"1 ?dup", {m6question_dup, m6bye}, {{1, {1}}, {}}, {{2, {1, 1}}, {}}, {}},
    {"0 abs", {m6abs, m6bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"11 abs", {m6abs, m6bye}, {{1, {11}}, {}}, {{1, {11}}, {}}, {}},
    {"-3 abs", {m6abs, m6bye}, {{1, {-3}}, {}}, {{1, {3}}, {}}, {}},
    {"0 aligned", {m6aligned, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 aligned", {m6aligned, m6bye}, {{1, {1}}, {}}, {{1, {SZ}}, {}}, {}},
    {"SZ 1- aligned", {m6aligned, m6bye}, {{1, {SZ - 1}}, {}}, {{1, {SZ}}, {}}, {}},
    {"0 short-aligned", {m6short_aligned, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 short-aligned", {m6short_aligned, m6bye}, {{1, {1}}, {}}, {{1, {2}}, {}}, {}},
    {"3 short-aligned", {m6short_aligned, m6bye}, {{1, {3}}, {}}, {{1, {4}}, {}}, {}},
    {"0 int-aligned", {m6int_aligned, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 int-aligned", {m6int_aligned, m6bye}, {{1, {1}}, {}}, {{1, {4}}, {}}, {}},
    {"3 int-aligned", {m6int_aligned, m6bye}, {{1, {3}}, {}}, {{1, {4}}, {}}, {}},
    {"and", {m6and, m6bye}, {{2, {-7, 14}}, {}}, {{1, {-7 & 14}}, {}}, {}},
    {"bl", {m6bl, m6bye}, {{}, {}}, {{1, {' '}}, {}}, {}},
    {"bounds", {m6bounds, m6bye}, {{2, {5, 6}}, {}}, {{2, {11, 5}}, {}}, {}},
    {"1 2 flag choose", {m6choose, m6bye}, {{3, {1, 2, -3}}, {}}, {{1, {1}}, {}}, {}},
    {"1 2 false choose", {m6choose, m6bye}, {{3, {1, 2, 0}}, {}}, {{1, {2}}, {}}, {}},
    /*                                                                          */
    {"depth", {m6depth, m6bye}, {{}, {}}, {{1, {0}}, {}}, {}},
    {"_ depth", {m6depth, m6bye}, {{1, {3}}, {}}, {{2, {3, 1}}, {}}, {}},
    {"_ _ depth", {m6depth, m6bye}, {{2, {3, 4}}, {}}, {{3, {3, 4, 2}}, {}}, {}},
    {"_ drop", {m6drop, m6bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"_ _ drop", {m6drop, m6bye}, {{2, {1, 2}}, {}}, {{1, {1}}, {}}, {}},
    {"dup", {m6dup, m6bye}, {{1, {-5}}, {}}, {{2, {-5, -5}}, {}}, {}},
    {"false", {m6false, m6bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"hop", {m6hop, m6bye}, {{3, {-3, -2, -1}}, {}}, {{4, {-3, -2, -1, -3}}, {}}, {}},
    {"lshift", {m6lshift, m6bye}, {{2, {99, 3}}, {}}, {{1, {99 << 3}}, {}}, {}},
    {"max", {m6max, m6bye}, {{2, {1, 2}}, {}}, {{1, {2}}, {}}, {}},
    {"min", {m6min, m6bye}, {{2, {3, 4}}, {}}, {{1, {3}}, {}}, {}},
    {"mod", {m6mod, m6bye}, {{2, {20, 7}}, {}}, {{1, {6}}, {}}, {}},
    {"-20 7 mod", {m6mod, m6bye}, {{2, {-20, 7}}, {}}, {{1, {-6}}, {}}, {}},
    {"0 n>drop", {m6n_to_drop, m6bye}, {{1, {0}}, {}}, {{}, {}}, {}},
    {"_ 1 n>drop", {m6n_to_drop, m6bye}, {{2, {-1, 1}}, {}}, {{}, {}}, {}},
    {"_ _ 2 n>drop", {m6n_to_drop, m6bye}, {{3, {-2, -1, 2}}, {}}, {{}, {}}, {}},
    {"negate", {m6negate, m6bye}, {{1, {-12}}, {}}, {{1, {12}}, {}}, {}},
    {"nip", {m6nip, m6bye}, {{2, {3, 4}}, {}}, {{1, {4}}, {}}, {}},
    {"noop", {m6noop, m6drop, m6bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"-7 14 or", {m6or, m6bye}, {{2, {-7, 14}}, {}}, {{1, {-7 | 14}}, {}}, {}},
    {"over", {m6over, m6bye}, {{2, {1, 0}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"0 pick", {m6pick, m6bye}, {{2, {-1, 0}}, {}}, {{2, {-1, -1}}, {}}, {}},
    {"1 pick", {m6pick, m6bye}, {{3, {-2, -1, 1}}, {}}, {{3, {-2, -1, -2}}, {}}, {}},
    {"2 pick", {m6pick, m6bye}, {{4, {-3, -2, -1, 2}}, {}}, {{4, {-3, -2, -1, -3}}, {}}, {}},
    {"0 2pick", {m6two_pick, m6bye}, {{3, {-2, -1, 0}}, {}}, {{4, {-2, -1, -2, -1}}, {}}, {}},
    {"1 2pick",
     {m6two_pick, m6bye},
     {{5, {-4, -3, -2, -1, 1}}, {}},
     {{6, {-4, -3, -2, -1, -4, -3}}, {}},
     {}},
    {"2 2pick",
     {m6two_pick, m6bye},
     {{7, {-6, -5, -4, -3, -2, -1, 2}}, {}},
     {{8, {-6, -5, -4, -3, -2, -1, -6, -5}}, {}},
     {}},
    {"0 roll", {m6roll, m6bye}, {{2, {-1, 0}}, {}}, {{1, {-1}}, {}}, {}},
    {"1 roll", {m6roll, m6bye}, {{3, {-2, -1, 1}}, {}}, {{2, {-1, -2}}, {}}, {}},
    {"2 roll", {m6roll, m6bye}, {{4, {-3, -2, -1, 2}}, {}}, {{3, {-2, -1, -3}}, {}}, {}},
    {"3 roll", {m6roll, m6bye}, {{5, {-4, -3, -2, -1, 3}}, {}}, {{4, {-3, -2, -1, -4}}, {}}, {}},
    {"8 roll",
     {m6roll, m6bye},
     {{10, {-9, -8, -7, -6, -5, -4, -3, -2, -1, 8}}, {}},
     {{9, {-8, -7, -6, -5, -4, -3, -2, -1, -9}}, {}},
     {}},
    {"0 -roll", {m6minus_roll, m6bye}, {{2, {-1, 0}}, {}}, {{1, {-1}}, {}}, {}},
    {"1 -roll", {m6minus_roll, m6bye}, {{3, {-2, -1, 1}}, {}}, {{2, {-1, -2}}, {}}, {}},
    {"2 -roll", {m6minus_roll, m6bye}, {{4, {-3, -2, -1, 2}}, {}}, {{3, {-1, -3, -2}}, {}}, {}},
    {"3 -roll",
     {m6minus_roll, m6bye},
     {{5, {-4, -3, -2, -1, 3}}, {}},
     {{4, {-1, -4, -3, -2}}, {}},
     {}},
    {"8 -roll",
     {m6minus_roll, m6bye},
     {{10, {-9, -8, -7, -6, -5, -4, -3, -2, -1, 8}}, {}},
     {{9, {-1, -9, -8, -7, -6, -5, -4, -3, -2}}, {}},
     {}},
    {"0 2roll", {m6two_roll, m6bye}, {{3, {-2, -1, 0}}, {}}, {{2, {-2, -1}}, {}}, {}},
    {"1 2roll",
     {m6two_roll, m6bye},
     {{5, {-4, -3, -2, -1, 1}}, {}},
     {{4, {-2, -1, -4, -3}}, {}},
     {}},
    {"2 2roll",
     {m6two_roll, m6bye},
     {{7, {-6, -5, -4, -3, -2, -1, 2}}, {}},
     {{6, {-4, -3, -2, -1, -6, -5}}, {}},
     {}},
    {"0 -2roll", {m6minus_two_roll, m6bye}, {{3, {-2, -1, 0}}, {}}, {{2, {-2, -1}}, {}}, {}},
    {"1 -2roll",
     {m6minus_two_roll, m6bye},
     {{5, {-4, -3, -2, -1, 1}}, {}},
     {{4, {-2, -1, -4, -3}}, {}},
     {}},
    {"2 -2roll",
     {m6minus_two_roll, m6bye},
     {{7, {-6, -5, -4, -3, -2, -1, 2}}, {}},
     {{6, {-2, -1, -6, -5, -4, -3}}, {}},
     {}},
    {"rot", {m6rot, m6bye}, {{3, {1, 2, 3}}, {}}, {{3, {2, 3, 1}}, {}}, {}},
    {"-rot", {m6minus_rot, m6bye}, {{3, {1, 2, 3}}, {}}, {{3, {3, 1, 2}}, {}}, {}},
    {"2rot", {m6two_rot, m6bye}, {{6, {1, 2, 3, 4, 5, 6}}, {}}, {{6, {3, 4, 5, 6, 1, 2}}, {}}, {}},
    {"-2rot",
     {m6minus_two_rot, m6bye},
     {{6, {1, 2, 3, 4, 5, 6}}, {}},
     {{6, {5, 6, 1, 2, 3, 4}}, {}},
     {}},
    {"rshift", {m6rshift, m6bye}, {{2, {99, 3}}, {}}, {{1, {99 >> 3}}, {}}, {}},
    {"squared", {m6squared, m6bye}, {{1, {-3}}, {}}, {{1, {9}}, {}}, {}},
    {"sub", {m6sub, m6bye}, {{2, {3, 5}}, {}}, {{1, {2}}, {}}, {}},
    {"swap", {m6swap, m6bye}, {{2, {4, 5}}, {}}, {{2, {5, 4}}, {}}, {}},
    {"trail", {m6trail, m6bye}, {{2, {4, 5}}, {}}, {{3, {4, 4, 5}}, {}}, {}},
    {"true", {m6true, m6bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"tuck", {m6tuck, m6bye}, {{2, {0, 1}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"unloop", {m6unloop, m6bye}, {{}, {3, {1, 2, 3}}}, {{}, {1, {1}}}, {}},
    {"xor", {m6xor, m6bye}, {{2, {-7, 14}}, {}}, {{1, {-7 ^ 14}}, {}}, {}},
#endif
};

static m6testexecute testexecute_b[] = {
    /*                                                                          */
    {"byte+", {m6byte_plus, m6bye}, {{1, {6}}, {}}, {{1, {7}}, {}}, {}},
    {"char+", {m6char_plus, m6bye}, {{1, {6}}, {}}, {{1, {7}}, {}}, {}},
    {"short+", {m6short_plus, m6bye}, {{1, {12}}, {}}, {{1, {12 + 2}}, {}}, {}},
    {"ushort+", {m6ushort_plus, m6bye}, {{1, {12}}, {}}, {{1, {12 + 2}}, {}}, {}},
    {"int+", {m6int_plus, m6bye}, {{1, {12}}, {}}, {{1, {12 + 4}}, {}}, {}},
    {"uint+", {m6uint_plus, m6bye}, {{1, {12}}, {}}, {{1, {12 + 4}}, {}}, {}},
    {"cell+", {m6cell_plus, m6bye}, {{1, {12}}, {}}, {{1, {12 + SZ}}, {}}, {}},
    {"token+", {m6token_plus, m6bye}, {{1, {12}}, {}}, {{1, {12 + SZt}}, {}}, {}},
    /*                                                                          */
    {"bytes", {m6bytes, m6bye}, {{1, {8}}, {}}, {{1, {8}}, {}}, {}},
    {"chars", {m6chars, m6bye}, {{1, {8}}, {}}, {{1, {8}}, {}}, {}},
    {"shorts", {m6shorts, m6bye}, {{1, {8}}, {}}, {{1, {8 * 2}}, {}}, {}},
    {"ushorts", {m6ushorts, m6bye}, {{1, {8}}, {}}, {{1, {8 * 2}}, {}}, {}},
    {"ints", {m6ints, m6bye}, {{1, {8}}, {}}, {{1, {8 * 4}}, {}}, {}},
    {"uints", {m6uints, m6bye}, {{1, {8}}, {}}, {{1, {8 * 4}}, {}}, {}},
    {"cells", {m6cells, m6bye}, {{1, {3}}, {}}, {{1, {3 * SZ}}, {}}, {}},
    {"tokens", {m6tokens, m6bye}, {{1, {3}}, {}}, {{1, {3 * SZt}}, {}}, {}},
    /*                                                                          */
    {"/byte", {m6div_byte, m6bye}, {{1, {-13}}, {}}, {{1, {-13}}, {}}, {}},
    {"/char", {m6div_char, m6bye}, {{1, {-14}}, {}}, {{1, {-14}}, {}}, {}},
    {"n /short", {m6div_short, m6bye}, {{1, {-15}}, {}}, {{1, {-8}}, {}}, {}},
    {"u /short", {m6div_short, m6bye}, {{1, {15}}, {}}, {{1, {7}}, {}}, {}},
    {"n /ushort", {m6div_ushort, m6bye}, {{1, {-15}}, {}}, {{1, {-8}}, {}}, {}},
    {"u /ushort", {m6div_ushort, m6bye}, {{1, {15}}, {}}, {{1, {7}}, {}}, {}},
    {"n /int", {m6div_int, m6bye}, {{1, {-15}}, {}}, {{1, {-4}}, {}}, {}},
    {"u /int", {m6div_int, m6bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"n /uint", {m6div_uint, m6bye}, {{1, {-15}}, {}}, {{1, {-4}}, {}}, {}},
    {"u /uint", {m6div_uint, m6bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"n /cell", {m6div_cell, m6bye}, {{1, {-13}}, {}}, {{1, {(-13 - SZ + 1) / SZ}}, {}}, {}},
    {"u /cell", {m6div_cell, m6bye}, {{1, {13}}, {}}, {{1, {13 / SZ}}, {}}, {}},
    {"n /token", {m6div_token, m6bye}, {{1, {-13}}, {}}, {{1, {(-13 - SZt + 1) / SZt}}, {}}, {}},
    {"u /token", {m6div_token, m6bye}, {{1, {13}}, {}}, {{1, {13 / SZt}}, {}}, {}},
    /*                                                                          */
    {"n /string",
     {m6div_string, m6bye},
     {{3, {0x7ff123, 1000, -11}}, {}},
     {{2, {0x7ff123 - 11, 1000 + 11}}, {}},
     {}},
    {"u /string",
     {m6div_string, m6bye},
     {{3, {0x8ee321, 1000, 13}}, {}},
     {{2, {0x8ee321 + 13, 1000 - 13}}, {}},
     {}},
    /*                                                                          */
    {"-261 >byte", {m6to_byte, m6bye}, {{1, {-261}}, {}}, {{1, {(int8_t)-261}}, {}}, {}},
    {"-128 >byte", {m6to_byte, m6bye}, {{1, {-128}}, {}}, {{1, {-128}}, {}}, {}},
    {"127 >byte", {m6to_byte, m6bye}, {{1, {127}}, {}}, {{1, {127}}, {}}, {}},
    {"259 >byte", {m6to_byte, m6bye}, {{1, {259}}, {}}, {{1, {(int8_t)259}}, {}}, {}},
    {"-261 >char", {m6to_char, m6bye}, {{1, {-261}}, {}}, {{1, {(uint8_t)-261}}, {}}, {}},
    {"-7 >char", {m6to_char, m6bye}, {{1, {-7}}, {}}, {{1, {(uint8_t)-7}}, {}}, {}},
    {"0 >char", {m6to_char, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"255 >char", {m6to_char, m6bye}, {{1, {255}}, {}}, {{1, {255}}, {}}, {}},
    {"259 >char", {m6to_char, m6bye}, {{1, {259}}, {}}, {{1, {(uint8_t)259}}, {}}, {}},
    {"-54321 >short", {m6to_short, m6bye}, {{1, {-54321}}, {}}, {{1, {(int16_t)-54321}}, {}}, {}},
    {"-32768 >short", {m6to_short, m6bye}, {{1, {-32768}}, {}}, {{1, {-32768}}, {}}, {}},
    {"32767 >short", {m6to_short, m6bye}, {{1, {32767}}, {}}, {{1, {32767}}, {}}, {}},
    {"54321 >short", {m6to_short, m6bye}, {{1, {54321}}, {}}, {{1, {(int16_t)54321}}, {}}, {}},
    {"-76543 >ushort",
     {m6to_ushort, m6bye},
     {{1, {-76543}}, {}},
     {{1, {(uint16_t)-76543}}, {}},
     {}},
    {"-11 >ushort", {m6to_ushort, m6bye}, {{1, {-11}}, {}}, {{1, {(uint16_t)-11}}, {}}, {}},
    {"0 >ushort", {m6to_ushort, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"65535 >ushort", {m6to_ushort, m6bye}, {{1, {65535}}, {}}, {{1, {65535}}, {}}, {}},
    {"76543 >ushort", {m6to_ushort, m6bye}, {{1, {76543}}, {}}, {{1, {(uint16_t)76543}}, {}}, {}},
    {"-9876543210 >int",
     {m6to_int, m6bye},
     {{1, {-9876543210l}}, {}},
     {{1, {(int32_t)-9876543210l}}, {}},
     {}},
    {"9876543210 >int",
     {m6to_int, m6bye},
     {{1, {9876543210l}}, {}},
     {{1, {(int32_t)9876543210l}}, {}},
     {}},
    {"-9876543210 >uint",
     {m6to_uint, m6bye},
     {{1, {-9876543210}}, {}},
     {{1, {(uint32_t)-9876543210l}}, {}},
     {}},
    {"-76543 >uint", {m6to_uint, m6bye}, {{1, {-76543}}, {}}, {{1, {(uint32_t)-76543}}, {}}, {}},
    {"0 >uint", {m6to_uint, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"65536 >uint", {m6to_uint, m6bye}, {{1, {65536}}, {}}, {{1, {65536}}, {}}, {}},
    {"4294967295 >uint",
     {m6to_uint, m6bye},
     {{1, {4294967295u}}, {}},
     {{1, {4294967295u}}, {}},
     {}},
    {"9876543210 >uint",
     {m6to_uint, m6bye},
     {{1, {9876543210l}}, {}},
     {{1, {(uint32_t)9876543210l}}, {}},
     {}},
    /* ----------------------------- atomic --------------------------------- */
    {"atomic1+!",
     {m6sp_fetch, m6atomic_one_plus_store, m6bye},
     {{1, {7}}, {}},
     {{2, {8, 7}}, {}},
     {}},
    {"atomic+!",
     {m6sp_fetch, m6two, m6swap, m6atomic_plus_store, m6bye},
     {{1, {7}}, {}},
     {{2, {9, 7}}, {}},
     {}},
};

static m6testexecute testexecute_c[] = {
    /* ----------------------------- 0<=> ----------------------------------- */
    {"-1 0<", {m6zero_less, m6bye}, {{1, {-1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 0<", {m6zero_less, m6bye}, {{1, {}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0<=", {m6zero_less_equal, m6bye}, {{1, {}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"1 0<=", {m6zero_less_equal, m6bye}, {{1, {1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 0<>", {m6zero_ne, m6bye}, {{1, {-1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 0<>", {m6zero_ne, m6bye}, {{1, {}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 0<>", {m6zero_ne, m6bye}, {{1, {1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 0=", {m6zero_equal, m6bye}, {{1, {-1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0=", {m6zero_equal, m6bye}, {{1, {}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"1 0=", {m6zero_equal, m6bye}, {{1, {1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0>", {m6zero_more, m6bye}, {{1, {}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 0>", {m6zero_more, m6bye}, {{1, {1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 0>=", {m6zero_more_equal, m6bye}, {{1, {-1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0>=", {m6zero_more_equal, m6bye}, {{1, {}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- <=> ------------------------------------ */
    {"-1 0 <", {m6less, m6bye}, {{2, {-1, 0}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"1 2 <", {m6less, m6bye}, {{2, {1, 2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 3 <", {m6less, m6bye}, {{2, {3, 3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"4 4 <=", {m6less_equal, m6bye}, {{2, {4, 4}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"5 4 <=", {m6less_equal, m6bye}, {{2, {5, 4}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 2 <>", {m6ne, m6bye}, {{2, {1, 2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 3 <>", {m6ne, m6bye}, {{2, {3, 3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 2 =", {m6equal, m6bye}, {{2, {1, 2}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"3 3 =", {m6equal, m6bye}, {{2, {3, 3}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"2 1 >", {m6more, m6bye}, {{2, {2, 1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 3 >", {m6more, m6bye}, {{2, {3, 3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -1 >=", {m6more_equal, m6bye}, {{2, {-2, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -2 >=", {m6more_equal, m6bye}, {{2, {-2, -2}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- u<=> ----------------------------------- */
    {"-1 0 u<", {m6u_less, m6bye}, {{2, {-1, 0}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 -1 u<", {m6u_less, m6bye}, {{2, {0, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -2 u<", {m6u_less, m6bye}, {{2, {-1, -2}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -1 u<", {m6u_less, m6bye}, {{2, {-2, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-3 -3 u<", {m6u_less, m6bye}, {{2, {-3, -3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 0 u<=", {m6u_less_equal, m6bye}, {{2, {-1, 0}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 -1 u<=", {m6u_less_equal, m6bye}, {{2, {0, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -2 u<=", {m6u_less_equal, m6bye}, {{2, {-1, -2}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -1 u<=", {m6u_less_equal, m6bye}, {{2, {-2, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-3 -3 u<=", {m6u_less_equal, m6bye}, {{2, {-3, -3}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 0 u>", {m6u_more, m6bye}, {{2, {-1, 0}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 -1 u>", {m6u_more, m6bye}, {{2, {0, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 -2 u>", {m6u_more, m6bye}, {{2, {-1, -2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-2 -1 u>", {m6u_more, m6bye}, {{2, {-2, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-3 -3 u>", {m6u_more, m6bye}, {{2, {-3, -3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 0 u>=", {m6u_more_equal, m6bye}, {{2, {-1, 0}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 -1 u>=", {m6u_more_equal, m6bye}, {{2, {0, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 -2 u>=", {m6u_more_equal, m6bye}, {{2, {-1, -2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-2 -1 u>=", {m6u_more_equal, m6bye}, {{2, {-2, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-3 -3 u>=", {m6u_more_equal, m6bye}, {{2, {-3, -3}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- within --------------------------------- */
    {"0 1 4 within", {m6within, m6bye}, {{3, {0, 1, 4}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 1 4 within", {m6within, m6bye}, {{3, {1, 1, 4}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 1 4 within", {m6within, m6bye}, {{3, {3, 1, 4}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"4 1 4 within", {m6within, m6bye}, {{3, {4, 1, 4}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-6 -5 -1 within", {m6within, m6bye}, {{3, {-6, -5, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-5 -5 -1 within", {m6within, m6bye}, {{3, {-5, -5, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-2 -5 -1 within", {m6within, m6bye}, {{3, {-2, -5, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -5 -1 within", {m6within, m6bye}, {{3, {-1, -5, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-9 -2 -8 within", {m6within, m6bye}, {{3, {-9, -2, -8}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-8 -2 -8 within", {m6within, m6bye}, {{3, {-8, -2, -8}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-7 -2 -8 within", {m6within, m6bye}, {{3, {-7, -2, -8}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-3 -2 -8 within", {m6within, m6bye}, {{3, {-3, -2, -8}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -2 -8 within", {m6within, m6bye}, {{3, {-2, -2, -8}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -2 -8 within", {m6within, m6bye}, {{3, {-1, -2, -8}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- return stack --------------------------- */
    {">r", {m6to_r, m6bye}, {{1, {99}}, {}}, {{}, {1, {99}}}, {}},
    {"i", {m6i, m6bye}, {{}, {1, {9}}}, {{1, {9}}, {1, {9}}}, {}},
    {"i*", {m6i_times, m6bye}, {{1, {2}}, {1, {9}}}, {{1, {18}}, {1, {9}}}, {}},
    {"i+", {m6i_plus, m6bye}, {{1, {2}}, {1, {9}}}, {{1, {11}}, {1, {9}}}, {}},
    {"i-", {m6i_minus, m6bye}, {{1, {2}}, {1, {9}}}, {{1, {-7}}, {1, {9}}}, {}},
    {"i'", {m6i_prime, m6bye}, {{}, {2, {10, 11}}}, {{1, {10}}, {2, {10, 11}}}, {}},
    {"j", {m6j, m6bye}, {{}, {3, {12, 13, 14}}}, {{1, {12}}, {3, {12, 13, 14}}}, {}},
    {"r@", {m6r_fetch, m6bye}, {{}, {1, {4}}}, {{1, {4}}, {1, {4}}}, {}},
    {"r!", {m6r_store, m6bye}, {{1, {11}}, {1, {0}}}, {{}, {1, {11}}}, {}},
    {"r+!", {m6r_plus_store, m6bye}, {{1, {30}}, {1, {4}}}, {{}, {1, {34}}}, {}},
    {"r>", {m6r_from, m6bye}, {{}, {1, {99}}}, {{1, {99}}, {}}, {}},
    {"dup>r", {m6dup_to_r, m6bye}, {{1, {33}}, {}}, {{1, {33}}, {1, {33}}}, {}},
    {"r>drop", {m6r_from_drop, m6bye}, {{}, {1, {99}}}, {{}, {}}, {}},
    /* ----------------------------- if else -------------------------------- */
    {"0 1 do", {m6do, m6bye}, {{2, {0, 1}}, {}}, {{}, {2, {0, 1}}}, {}},
    {"1 0 do", {m6do, m6bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"0 0 (?do)", {m6_q_do_, T(0), m6bye}, {{2, {0, 0}}, {}}, {{}, {}}, {}},
    {"1 0 (?do)", {m6_q_do_, T(0), m6bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"0 (?if)", {m6_q_if_, T(1), m6one, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 (?if)", {m6_q_if_, T(1), m6two, m6bye}, {{1, {1}}, {}}, {{2, {1, 2}}, {}}, {}},
    {"0 (?if0)", {m6_q_if0_, T(1), m6three, m6bye}, {{1, {0}}, {}}, {{2, {0, 3}}, {}}, {}},
    {"1 (?if0)", {m6_q_if0_, T(1), m6four, m6bye}, {{1, {1}}, {}}, {{1, {1}}, {}}, {}},
    {"0 (if)", {m6_if_, T(1), m6two, m6bye}, {{1, {0}}, {}}, {{}, {}}, {}},
    {"1 (if)", {m6_if_, T(1), m6four, m6bye}, {{1, {1}}, {}}, {{1, {4}}, {}}, {}},
    {"0 (if0)", {m6_if0_, T(1), m6two, m6bye}, {{1, {0}}, {}}, {{1, {2}}, {}}, {}},
    {"1 (if0)", {m6_if0_, T(1), m6three, m6bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"(else) T(0)", {m6_else_, T(0), m6bye, m6_missing_}, {{}, {}}, {{}, {}}, {}},
    {"(else) T(1)", {m6_else_, T(1), m6true, m6bye}, {{}, {}}, {{}, {}}, {}},
    /* ----------------------------- do leave loop -------------------------- */
    {"(leave)", {m6_leave_, T(0), m6bye}, {{}, {2, {0, 1}}}, {{}, {}}, {}},
    {"0 0 2>r 2 (+loop)",
     {m6_plus_loop_, T(0), m6bye},
     {{1, {2}}, {2, {0, 0}}},
     {{}, {2, {0, 2}}},
     {}},
    {"0 0 2>r -1 (+loop)", {m6_plus_loop_, T(0), m6bye}, {{1, {-1}}, {2, {0, 0}}}, {{}, {}}, {}},
    {"0 1 2>r -1 (+loop)",
     {m6_plus_loop_, T(0), m6bye},
     {{1, {-1}}, {2, {0, 1}}},
     {{}, {2, {0, 0}}},
     {}},
    {"1 0 2>r 1 (+loop)", {m6_plus_loop_, T(0), m6bye}, {{1, {1}}, {2, {1, 0}}}, {{}, {}}, {}},
    {"0 0 2>r (loop)", {m6_loop_, T(0), m6bye}, {{}, {2, {0, 0}}}, {{}, {2, {0, 1}}}, {}},
    {"0 1 2>r (loop)", {m6_loop_, T(0), m6bye}, {{}, {2, {0, 1}}}, {{}, {2, {0, 2}}}, {}},
    {"1 0 2>r (loop)", {m6_loop_, T(0), m6bye}, {{}, {2, {1, 0}}}, {{}, {}}, {}},
    {"10 0 do loop", {m6do, m6_loop_, T(-2), m6bye}, {{2, {10, 0}}, {}}, {{}, {}}, {}},
    {"5 0 do i loop",
     {m6do, m6i, m6_loop_, T(-3), m6bye},
     {{2, {5, 0}}, {}},
     {{5, {0, 1, 2, 3, 4}}, {}},
     {}},
    {"0 1M 0 do i+ loop",
     {m6do, m6i_plus, m6_loop_, T(-3), m6bye},
     {{3, {0, (m6cell)1e6, 0}}, {}},
     {{1, {499999500000l}}, {}},
     {}},
    /* ----------------------------- case of endof endcase ------------------ */
    {"case", {m6case, m6bye}, {{}, {}}, {{}, {}}, {}},
    {"0 1 (of) T(1) 2", {m6_of_, T(1), m6two, m6bye}, {{2, {0, 1}}, {}}, {{1, {0}}, {}}, {}},
    {"1 1 (of) T(1) 3", {m6_of_, T(1), m6three, m6bye}, {{2, {1, 1}}, {}}, {{1, {3}}, {}}, {}},
    {"(endof) T(0) 4", {m6_endof_, T(0), m6four, m6bye}, {{}, {}}, {{1, {4}}, {}}, {}},
    {"(endof) T(1) 5", {m6_endof_, T(1), m6five, m6bye}, {{}, {}}, {{}, {}}, {}},
    {"6 endcase", {m6endcase, m6bye}, {{1, {6}}, {}}, {{}, {}}, {}},
    {"1 case 1 (of) T(3) -1 (endof) T(3) 2* 0 endcase",
     {m6case, m6one, m6_of_, T(3), m6minus_one, m6_endof_, T(3), m6two_times, m6zero, m6endcase,
      m6bye},
     {{1, {1}}, {}},
     {{1, {-1}}, {}},
     {}},
    {"3 case 1 (of) T(3) -1 (endof) T(3) 2* 0 endcase",
     {m6case, m6one, m6_of_, T(3), m6minus_one, m6_endof_, T(3), m6two_times, m6zero, m6endcase,
      m6bye},
     {{1, {3}}, {}},
     {{1, {6}}, {}},
     {}},
    /* ----------------------------- line  ---------------------------------- */
    {"\"abc\" 'c' line-find-char",
     {m6line_find_char, m6bye},
     {{3, {(m6cell) "abc\nd", 3, 'c'}}, {}},
     {{1, {2}}, {}},
     {}},
    {"\"abc\" 'd' line-find-char",
     {m6line_find_char, m6bye},
     {{3, {(m6cell) "abc\nd", 3, 'd'}}, {}},
     {{1, {3}}, {}},
     {}},
    {"\"abc\\nd\" 'd' line-find-char",
     {m6line_find_char, m6bye},
     {{3, {(m6cell) "abc\nd", 5, 'd'}}, {}},
     {{1, {3}}, {}},
     {}},
    /* ----------------------------- iobuf ---------------------------------- */
    {"iobuf>pos",
     {m6iobuf_pos, m6bye},
     {{1, {0x1000}}, {}},
     {{1, {0x1000 + IOBUF_OFF_POS}}, {}},
     {}},
    {"iobuf>end",
     {m6iobuf_end, m6bye},
     {{1, {0x3000}}, {}},
     {{1, {0x3000 + IOBUF_OFF_END}}, {}},
     {}},
    {"iobuf-refill",
     {m6in_to_ibuf, CALL(ibuf_refill), m6bye},
     {{}, {}},
     {{1, {m6err_unexpected_eof}}, {}},
     {}},
    {"iobuf-find-nonblanks",
     {m6in_to_ibuf, CALL(ibuf_find_nonblanks), m6zero_equal, m6swap, m6in_to_ibuf, m6iobuf_addr,
      m6equal, m6bye},
     {{}, {}},
     {{2, {ttrue, ttrue}}, {}},
     {}},
    {"parse-name",
     {CALL(parse_name), m6zero_equal, m6swap, m6in_to_ibuf, m6iobuf_addr, m6equal, m6bye},
     {{}, {}},
     {{2, {ttrue, ttrue}}, {}},
     {}},
};

#define SH(x, n) ((m6cell)(x) << ((n)*8))

static m6testexecute testexecute_d[] = {
    /* ----------------------------- literal -------------------------------- */
    {"(lit-short) SHORT(7)", {m6_lit_short_, SHORT(7), m6bye}, {{}, {}}, {{1, {7}}, {}}, {}},
    {"(lit-int) INT(0x10000)",
     {m6_lit_int_, INT(0x10000), m6bye},
     {{}, {}},
     {{1, {0x10000}}, {}},
     {}},
    {"(lit-cell) CELL(0x100000000)",
     {m6_lit_cell_, CELL(0x100000000), m6bye},
     {{}, {}},
     {{1, {0x100000000}}, {}},
     {}},
    /* ----------------------------- execute, call -------------------------- */
    {"(call) 'false", {CALL(false), m6bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"(call) 'noop", {CALL(noop), m6bye}, {{}, {}}, {{}, {}}, {}},
    {"(call) 'true", {CALL(true), m6bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"crc+",
     {m6_call_, CELL(crc1byte_code), m6bye},
     {{2, {0xffffffff, 't'}}, {}},
     {{1, {0x1b806fbc /* m64th_crc1byte(0xffffffff, 't')*/}}, {}},
     {}},
    {"crc-cell",
     {m6crc_cell, m6bye},
     {{1,
       {'c' | SH('o', 1) | SH('n', 2) | SH('s', 3) | SH('t', 4) | SH('a', 5) | SH('n', 6) |
        SH('t', 7)}},
      {}},
     {{1, {0x92cfc8c9 /* m64th_crc_string("constant", 8)*/}}, {}},
     {}},
    {"\"constant\" crc-string",
     {m6crc_string, m6bye},
     {{2, {(m6cell) "constant", 8}}, {}},
     {{1, {0x92cfc8c9 /* m64th_crc_string("constant", 8)*/}}, {}},
     {}},
    {"\"immediate\" crc-string",
     {m6crc_string, m6bye},
     {{2, {(m6cell) "immediate", 9}}, {}},
     {{1, {0x5ecabe1c /* m64th_crc_string("immediate", 9)*/}}, {}},
     {}},
    {"(call-asm) crc+-native-forth",
     {m6_call_asm_, CELL(m6ftest_crc_plus_native_forth), m6bye},
     {{2, {0xffffffff, 't'}}, {}},
     {{1, {0x1b806fbc}}, {}},
     {}},
    {"' one (exec-token)", {m6_exec_token_, m6bye}, {{1, {m6one}}, {}}, {{1, {1}}, {}}, {}},
    {"' noop (exec-token)", {m6_exec_token_, m6bye}, {{1, {m6noop}}, {}}, {{}, {}}, {}},
    {"(exec-xt-from-native)",
     {m6_call_asm_, CELL(m6ftest_exec_xt_from_native), m6bye},
     {{1, {DXT(three)}}, {}},
     {{1, {3}}, {}},
     {}},
    {"' 5 (catch-xt-from-native)",
     {m6_call_asm_, CELL(m6ftest_catch_xt_from_native), m6bye},
     {{1, {DXT(five)}}, {}},
     {{2, {5, 0}}, {}},
     {}},
    {"-2 ' throw (catch-xt-from-native)",
     {m6_call_asm_, CELL(m6ftest_catch_xt_from_native), m6bye},
     {{2, {-2, DXT(throw)}}, {}},
     {{2, {-1 /*argument of executed word: clobbered*/, -2}}, {}},
     {}},
    /* test that execute on empty stack calls abort */
    {"execute", {m6execute}, {{}, {}}, {{}, {}}, {}},
    /* test that execute detects obviously invalid XT */
    {"0 execute", {m6execute, m6bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"SZ execute", {m6execute, m6bye}, {{1, {SZ}}, {}}, {{1, {SZ}}, {}}, {}},
    {"-SZ execute", {m6execute, m6bye}, {{1, {-SZ}}, {}}, {{1, {-SZ}}, {}}, {}},
    {"0xffff8 execute", {m6execute, m6bye}, {{1, {0xffff8}}, {}}, {{1, {0xffff8}}, {}}, {}},
    {"' ! 1+ execute",
     {m6execute, m6bye},
     {{1, {DXT(store) + 1}}, {}},
     {{1, {DXT(store) + 1}}, {}},
     {}},
    /* test execute of simple words */
    {"' noop execute", {m6execute, m6bye}, {{1, {DXT(noop)}}, {}}, {{}, {}}, {}},
    {"' eight execute", {m6execute, m6bye}, {{1, {DXT(eight)}}, {}}, {{1, {8}}, {}}, {}},
    {"6 7 ' plus execute", {m6execute, m6bye}, {{3, {6, 7, DXT(plus)}}, {}}, {{1, {13}}, {}}, {}},
    {"... ' store execute",
     {m6sp_fetch, m6cell_plus, /* ( 3 d1=7 store &d1 ) */
      m6cell_plus,             /* ( d0=3 7 store &d0 ) */
      m6swap,                  /* ( d0=3 7 &d0 store ) */
      m6execute, m6bye},       /* ( 7                ) */
     {{3, {3, 7, DXT(store)}}, {}},
     {{1, {7}}, {}},
     {}},
    {"(ip)", {m6_ip_, m6bye}, {{}, {}}, {{1, {-1 /* fixed by m6testexecute_fix() */}}, {}}, {}},
    {"(lit-string)",
     {m6_ip_, LIT_STRING(3, "abc"), m6minus_rot, m6minus, m6bye},
     {{}, {}},
     {{2, {3, -3 * SZt /*distance between the tokens (ip) and "abc"*/}}, {}},
     {}},
    /* ----------------------------- catch, throw --------------------------- */
    {"' bye catch",
     {m6_catch_beg_, m6_catch_end_},
     {{2, {7, DXT(bye)}}, {1, {0xfed0}}},
     /* inspect return stack filled by 'catch'. */
     {{1, {7}}, {5, {0xfed0, 0, 0, 0, 0x7fffffff /* fixed by m6testexecute_fix() */}}},
     {}},
    {"' noop catch",
     {m6_catch_beg_, m6_catch_end_, m6bye},
     {{2, {23, DXT(noop)}}, {1, {0xfed1}}},
     {{2, {23, 0}}, {1, {0xfed1}}},
     {}},
    {"' + catch",
     {m6_catch_beg_, m6_catch_end_, m6bye},
     {{4, {13, 15, 17, DXT(plus)}}, {1, {0xfed2}}},
     {{3, {13, 15 + 17, 0}}, {1, {0xfed2}}},
     {}},
    {"0 ' throw catch",
     {m6_catch_beg_, m6_catch_end_, m6bye},
     {{3, {19, 0, DXT(throw)}}, {1, {0xfed3}}},
     {{2, {19, 0}}, {1, {0xfed3}}},
     {}},
    {"1 ' throw catch",
     {m6_catch_beg_, m6_catch_end_, m6bye},
     {{3, {19, 1, DXT(throw)}}, {1, {0xfed4}}},
     {{3, {19, -1 /*clobbered*/, 1}}, {1, {0xfed4}}},
     {}},
    /* ----------------------------- (optimize-literal) --------------------- */
    /* these also test (ip>data) and (ip>data>addr) */
    {"-3 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {-3}}, {}},
     {{2, {-3, tfalse}}, {}},
     {}},
    {"-2 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {-2}}, {}},
     {{2, {m6minus_two, ttrue}}, {}},
     {}},
    {"-1 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {-1}}, {}},
     {{2, {m6minus_one, ttrue}}, {}},
     {}},
    {"0 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {0}}, {}},
     {{2, {m6zero, ttrue}}, {}},
     {}},
    {"1 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {1}}, {}},
     {{2, {m6one, ttrue}}, {}},
     {}},
    {"2 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {2}}, {}},
     {{2, {m6two, ttrue}}, {}},
     {}},
    {"3 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {3}}, {}},
     {{2, {m6three, ttrue}}, {}},
     {}},
    {"4 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {4}}, {}},
     {{2, {m6four, ttrue}}, {}},
     {}},
    {"5 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {5}}, {}},
     {{2, {m6five, ttrue}}, {}},
     {}},
    {"8 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {8}}, {}},
     {{2, {m6eight, ttrue}}, {}},
     {}},
    {"9 (optimize-literal)",
     {CALL(_optimize_literal_), m6bye},
     {{1, {9}}, {}},
     {{2, {9, tfalse}}, {}},
     {}},
    /* ----------------------------- locals --------------------------------- */
    {"(lenter-x)",
     {m6_lenter_x_, T(3), m6rdepth, m6two_r_from_two_drop, m6two_r_from_two_drop, m6bye},
     {{}, {}},
     {{1, {4 /* rdepth*/}}, {}},
     {}},
    {"(lexit-x)",
     {m6_lexit_x_, T(3), m6bye},
     {{}, {4, {12, 11, 10 /*saved l2,l1,l0*/, 0 /*previous LOCL*/}}},
     {},
     {}},
    {"(lx)",
     {m6_lenter_x_, T(2), m6_to_l0_, m6_to_l1_, m6_l0_, m6_l1_, m6minus, m6_lexit_x_, T(2), m6bye},
     {{2, {8, 3}}, {}},
     {{1, {-5}}, {}},
     {}},
    {"(user-locals-allocate)",
     {CALL(_user_locals_allocate_), m6cell_fetch_2, m6bye},
     {{}, {}},
     {{1, {sizeof(m6locals) + 16 * (sizeof(m6local) + 255)}}, {}},
     {}},
    {"_ (local)",
     {CALL(_local_), m6user_var, T(M64TH_USER_VAR_LOCALS), m6fetch, m6dup, m6fetch, m6swap,
      m6cell_fetch_1, m6bye},
     {{2, {(m6cell) "ab3", 3}}, {}},
     {{2, {1 /*ls.n*/, 5 /*ls.end*/}}, {}},
     {}},
    {"_ string>local",
     {CALL(_local_), CALL(_user_locals_set_idx_), CALL(string_to_local), m6bye},
     {{4, {(m6cell) "cd67", 4, (m6cell) "cd67", 3}}, {}},
     {{2, {-1, tfalse}}, {}},
     {}},
    {"s\" cd67\" string>local",
     {CALL(_local_), CALL(_user_locals_set_idx_), CALL(string_to_local), m6bye},
     {{4, {(m6cell) "cd67", 4, (m6cell) "cd67", 4}}, {}},
     {{2, {0, ttrue}}, {}},
     {}},
    {"0 0 [compile-lenter]",
     {CALL(_compile_lenter_), m6bye},
     {{2, {0, 0}}, {}},
     {{}, {}},
     {}}, /* optimized away */
    {"0 1 [compile-lenter]",
     {CALL(_compile_lenter_), m6bye},
     {{2, {0, 1}}, {}},
     {{}, {}},
     {2, {m6_lenter_x_, T(1)}}},
    {"1 0 [compile-lenter]",
     {CALL(_compile_lenter_), m6bye},
     {{2, {1, 0}}, {}},
     {{}, {}},
     {4, {m6_lenter_x_, T(1), m6_to_lx_, T(0)}}},
    {"2 3 [compile-lenter]",
     {CALL(_compile_lenter_), m6bye},
     {{2, {2, 3}}, {}},
     {{}, {}},
     {6, {m6_lenter_x_, T(5), m6_to_lx_, T(3), m6_to_lx_, T(4)}}},
};

static const m6token testoptimize_noop[] = {m6noop};
static const m6token testoptimize_zero[] = {m6zero, m6noop};
static const m6token testoptimize_nip_dup[] = {m6nip, m6dup, m6noop};

/* ---------------------- test data for hashmap/cell -------------------- */

static const m6hashmap_cell test_hashmap_cell0 = {
    0 /*size*/, 31 /*lcap*/, NULL /*vec*/
};
static const m6hashmap_entry_cell test_hash_entry_cell0[2] = {
    {2 /*val*/, 1 /*key*/, 3 /*next*/},
    {5 /*val*/, 4 /*key*/, 6 /*next*/},
};
static const m6hashmap_entry_cell test_hash_entry_cell1[8] = {
    {0 /*val*/, 0 /*key*/, -1 /*next*/},    {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {456 /*val*/, -1 /*key*/, -2 /*next*/}, {123 /*val*/, 1 /*key*/, -2 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},    {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},    {0 /*val*/, 0 /*key*/, -1 /*next*/},
};
static const m6hashmap_cell test_hashmap_cell1 = {
    2 /*size*/, 2 /*lcap*/, (m6hashmap_entry_cell *)test_hash_entry_cell1 /*vec*/
};

/* ---------------------- test data for hashmap/int --------------------- */

static const m6hashmap_int test_hashmap_int0 = {
    0 /*size*/, 31 /*lcap*/, NULL /*vec*/
};
static const m6hashmap_entry_int test_hash_entry_int0[2] = {
    {2 /*val*/, 1 /*key*/, 3 /*next*/},
    {5 /*val*/, 4 /*key*/, 6 /*next*/},
};
static const m6hashmap_entry_int test_hash_entry_int1[8] = {
    {654 /*val*/, 3 /*key*/, -2 /*next*/}, {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},   {987 /*val*/, 1 /*key*/, -2 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},   {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},   {0 /*val*/, 0 /*key*/, -1 /*next*/},
};
static const m6hashmap_int test_hashmap_int1 = {
    2 /*size*/, 2 /*lcap*/, (m6hashmap_entry_int *)test_hash_entry_int1 /*vec*/
};

/* ---------------------- test data for (optimize-*) --------------------- */

static const m6token test_tokens__missing_[] = {m6_missing_};
static const m6token test_tokens_noop[] = {m6noop};
static const m6token test_tokens_two_drop[] = {m6two_drop};
static const m6token test_tokens_false[] = {m6false};
static const m6token test_tokens_one_plus[] = {m6one_plus};
static const m6token test_tokens_swap_drop[] = {m6swap, m6drop};
static const m6token test_tokens_ne_zero_more[] = {m6ne, m6zero_more};
static const m6token test_tokens_lx_t3[] = {m6_lx_, 3};
static const m6token test_tokens_drop_drop[] = {m6drop, m6drop};
static const m6token test_tokens_r_from_plus_to_r[] = {m6r_from, m6plus, m6to_r};
static const m6token test_tokens_if_t_then[] = {m6_if_, (m6token)-1, m6then};
static const m6token test_tokens_lx_t_drop[] = {m6_lx_, T(7), m6drop};
static const m6token test_tokens_if0_t_else[] = {m6_if0_, (m6token)-1, m6_else_};
static const m6token test_tokens__lit__0xffff_and[] = {m6_lit_, 0xffff, m6and};
static const m6token test_tokens_qif_t_dup_then[] = {m6_q_if_, -1, m6dup, m6then};
static const m6token test_tokens_qif_t_continue_t_then[] = {m6_q_if_, -1, m6_continue_, -1, m6then};
static const m6token test_tokens_qif_t_drop_else_t_nip_then[] =
    /**/ {m6_if_, -1, m6drop, m6_else_, -1, m6nip, m6then};
/**
 *
 */
static m6testexecute testexecute_e[] = {
    /* ---------------------- hashmap/cell --------------------- */
    {"(hashmap-indexof/cell)",
     {CALL(_hashmap_indexof_cell_), m6bye},
     {{2, {(m6cell)&test_hashmap_cell0, 0x12345678}}, {}},
     {{1, {(0xd45689e5ul ^ (0xd45689e5ul >> 31)) & ((1ul << 31) - 1)}}, {}},
     {}},
    {"(hashmap-entry@/cell)",
     {CALL(_hashmap_entry_fetch_cell_), m6swap, m6fetch, m6swap, m6bye},
     {{2, {(m6cell)&test_hash_entry_cell0, 1}}, {}},
     {{3, {4, 5, 6}}, {}},
     {}},
    {"{1:123, -1:456} 1 hashmap-find/cell",
     {CALL(hashmap_find_cell), m6fetch, m6bye},
     {{2, {(m6cell)&test_hashmap_cell1, 1}}, {}},
     {{2, {1, 123}}, {}},
     {}},
    {"{1:123, -1:456} -1 hashmap-find/cell",
     {CALL(hashmap_find_cell), m6fetch, m6bye},
     {{2, {(m6cell)&test_hashmap_cell1, -1}}, {}},
     {{2, {-1, 456}}, {}},
     {}},
    /* ---------------------- hashmap/int ---------------------- */
    {"(hashmap-indexof/int)",
     {CALL(_hashmap_indexof_int_), m6bye},
     {{2, {(m6cell)&test_hashmap_int0, 0x12345678}}, {}},
     {{1, {(0xd45689e5ul ^ (0xd45689e5ul >> 31)) & ((1ul << 31) - 1)}}, {}},
     {}},
    {"(hashmap-entry@/int)",
     {CALL(_hashmap_entry_fetch_int_), m6swap, m6fetch, m6swap, m6bye},
     {{2, {(m6cell)&test_hash_entry_int0, 1}}, {}},
     {{3, {4, 5, 6}}, {}},
     {}},
    {"{1:987, 3:654} 1 hashmap-find/int",
     {CALL(hashmap_find_int), m6fetch, m6bye},
     {{2, {(m6cell)&test_hashmap_int1, 1}}, {}},
     {{2, {1, 987}}, {}},
     {}},
    {"{1:987, 3:654} 3 hashmap-find/int",
     {CALL(hashmap_find_int), m6fetch, m6bye},
     {{2, {(m6cell)&test_hashmap_int1, 3}}, {}},
     {{2, {3, 654}}, {}},
     {}},
    {"{...} hashmap-find/int",
     {m6name_to_data, m6drop, m6swap, CALL(hashmap_find_int), m6fetch, m6bye},
     {{2, {M6two | (M6pick << 16), (m6cell)&WORD_SYM(_optimize_2token_)}}, {}},
     {{2, {M6two | (M6pick << 16), 1 | (M6hop << 16)}}, {}},
     {}},
    /* ---------------------- optimize* ---------------------- */
    {"{_missing_} (optimize-1token)",
     {CALL(_optimize_1token_), /* ( counted-tokens )                    */
      m6bye},                  /* ( 0 ) i.e. _missing_ is not optimized */
     {{1, {(m6cell)test_tokens__missing_}}, {}},
     {{1, {0}}, {}},
     {}},
    {"{noop} (optimize-1token)",
     {CALL(_optimize_1token_), /* ( counted-tokens )                       */
      m6token_fetch, m6bye},   /* ( 0 ) i.e. noop optimizes to zero tokens */
     {{1, {(m6cell)test_tokens_noop}}, {}},
     {{1, {0}}, {}},
     {}},
    {"{2drop} (optimize-1token)",
     {CALL(_optimize_1token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_two_drop}}, {}},
     {{}, {}},
     {2, {m6drop, m6drop}}},
    {"{false} (optimize-1token)",
     {CALL(_optimize_1token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_false}}, {}},
     {{}, {}},
     {1, {m6zero}}},
    {"{1+} (optimize-1token)",
     {CALL(_optimize_1token_), /* ( counted-tokens ) */
      m6bye},                  /* ( 0 ) i.e. 1+ is not optimized */
     {{1, {(m6cell)test_tokens_one_plus}}, {}},
     {{1, {0}}, {}},
     {}},
    {"{swap drop} (optimize-2token)",
     {CALL(_optimize_2token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_swap_drop}}, {}},
     {{}, {}},
     {1, {m6nip}}},
    {"{<> 0>} (optimize-2token)",
     {CALL(_optimize_2token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_ne_zero_more}}, {}},
     {{}, {}},
     {3, {m6drop, m6drop, m6zero}}},
    {"{(lx) T(3)} (optimize-2token-midprio)",
     {CALL(_optimize_2token_midprio_),   /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_lx_t3}}, {}},
     {{}, {}},
     {1, {m6_l3_}}},
    {"{drop drop} (optimize-2token-lowprio)",
     {CALL(_optimize_2token_lowprio_),   /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_drop_drop}}, {}},
     {{}, {}},
     {1, {m6two_drop}}},
    {"{r> + >r} (optimize-3token)",
     {CALL(_optimize_3token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_r_from_plus_to_r}}, {}},
     {{}, {}},
     {1, {m6r_plus_store}}},
    {"{(if0) T(_) (else)} (optimize-3jump)",
     {CALL(_optimize_3jump_),       /* ( counted-tokens ) */
      CALL(countedtokens_comma),    /* (                ) */
      m6one, m6token_comma, m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_if0_t_else}}, {}},
     {{}, {}},
     {2, {m6_if_, T(1)}}},
    {"{(if) T(_) then} (optimize-3jump)",
     {CALL(_optimize_3jump_),            /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_if_t_then}}, {}},
     {{}, {}},
     {1, {m6drop}}},
    {"{(lx) T(_) drop} (optimize-3local)",
     {CALL(_optimize_3local_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_lx_t_drop}}, {}},
     {{}, {}},
     {}},
    {"{(?if) T(_) dup then} (optimize-4token)",
     {CALL(_optimize_4jump_),            /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_qif_t_dup_then}}, {}},
     {{}, {}},
     {1, {m6question_dup}}},
    {"{(?if) T(_) (continue) T(_) then} (optimize-5token)",
     {CALL(_optimize_5token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_qif_t_continue_t_then}}, {}},
     {{}, {}},
     {2, {m6_q_continue_if_, m6_missing_}}},
    {"{(if) T(_) drop (else) T(_) nip then} (optimize-7token)",
     {CALL(_optimize_7token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m6bye}, /* (                ) */
     {{1, {(m6cell)test_tokens_qif_t_drop_else_t_nip_then}}, {}},
     {{}, {}},
     {1, {m6choose}}},
    {"{_missing_} 1 (optimize-tokens)",
     {CALL(_optimize_tokens_), m6bye}, /* ( counted-tokens u' ) */
     {{3, {(m6cell)test_tokens__missing_, 1, M6OPTS_PRIO_HIGH}}, {}},
     {{2, {0, 0}}, {}},
     {}},
    {"{false} 1 (optimize-tokens)",
     {CALL(_optimize_tokens_),                   /* ( counted-tokens u' ) */
      m6swap, CALL(countedtokens_comma), m6bye}, /* ( u'                ) */
     {{3, {(m6cell)test_tokens_false, 1, M6OPTS_PRIO_HIGH}}, {}},
     {{1, {1}}, {}},
     {1, {m6zero}}},
    {"{swap drop} 2 (optimize-tokens)",
     {CALL(_optimize_tokens_),                   /* ( counted-tokens u' ) */
      m6swap, CALL(countedtokens_comma), m6bye}, /* ( u'                ) */
     {{3, {(m6cell)test_tokens_swap_drop, 2, M6OPTS_PRIO_HIGH}}, {}},
     {{1, {2}}, {}},
     {1, {m6nip}}},
    {"{$ffff and} (optimize-tokens)",
     {CALL(_optimize_tokens_),                   /* ( counted-tokens u' ) */
      m6swap, CALL(countedtokens_comma), m6bye}, /* ( u'                ) */
     {{3, {(m6cell)test_tokens__lit__0xffff_and, 3, M6OPTS_PRIO_HIGH}}, {}},
     {{1, {3}}, {}},
     {1, {m6to_ushort}}},
    {"{1 -} (optimize-tokens,)",
     {m6token_comma, m6token_comma, m6state, m6fetch, m6two,            /* ( xt u    ) */
      m6_lit_, M6OPTS_PRIO_HIGH, CALL(_optimize_tokens_comma_), m6bye}, /* ( u' t|f  ) */
     {{2, {m6minus, m6one}}, {}},
     {{2, {2, ttrue}}, {}},
     {3, {m6one, m6minus, /* followed by optimized sequence */ m6one_minus}}},
    {"{2 * dup} [optimize-xt,]",
     {m6token_comma, m6token_comma, m6token_comma,                  /* (            ) */
      m6zero, m6three,                                              /* ( offset u   ) */
      m6_lit_, M6OPTS_PRIO_HIGH, CALL(_optimize_xt_comma_), m6bye}, /* ( t|f        ) */
     {{3, {m6dup, m6times, m6two}}, {}},
     {{1, {ttrue}}, {}},
     {5, {m6two, m6times, m6dup, /* followed by optimized sequence */ m6two_times, m6dup}}},
    {"{dup * exit} [optimize-xt,]",
     {m6token_comma, m6token_comma, m6token_comma, /* (               ) */
      m6zero, m6three, m6_lit_, M6OPTS_PRIO_HIGH,  /* ( offset u opts ) */
      CALL(_optimize_xt_comma_), m6bye},           /* ( t|f           ) */
     {{3, {m6exit, m6times, m6dup}}, {}},
     {{1, {ttrue}}, {}},
     {5, {m6dup, m6times, m6exit, /* followed by optimized sequence */ m6squared, m6exit}}},
    {"{4 * 2 *} [optimize-once]",
     {m6token_comma, m6token_comma, m6token_comma, m6token_comma, /* (            ) */
      m6_lit_, M6OPTS_PRIO_HIGH, CALL(_optimize_once_), m6bye},   /* ( t|f        ) */
     {{4, {m6times, m6two, m6times, m6four}}, {}},
     {{1, {ttrue}}, {}},
     {2, {/* optimized sequence: */ m6four_times, m6two_times}}},
    {"{dup * dup *} [optimize-once]",
     {m6token_comma, m6token_comma, m6token_comma, m6token_comma, /* (            ) */
      m6_lit_, M6OPTS_PRIO_HIGH, CALL(_optimize_once_), m6bye},   /* ( t|f        ) */
     {{4, {m6times, m6dup, m6times, m6dup}}, {}},
     {{1, {ttrue}}, {}},
     {2, {/* optimized sequence: */ m6squared, m6squared}}},
    {"{1 * 2 * 4 *} [optimize]",
     {m6token_comma, m6token_comma, m6token_comma,              /* ( _ _ _           ) */
      m6token_comma, m6token_comma, m6token_comma,              /* (                 ) */
      m6_lit_, M6OPTS_PRIO_HIGH, CALL(_optimize_opts_), m6bye}, /* (                 ) */
     {{6, {m6times, m6four, m6times, m6two, m6times, m6one}}, {}},
     {{}, {}},
     {1, {/* optimized sequence: */ m6eight_times}}},
    {"{1 - 1 - 4 +} [optimize]",
     {m6token_comma, m6token_comma, m6token_comma,              /* ( _ _ _           ) */
      m6token_comma, m6token_comma, m6token_comma,              /* (                 ) */
      m6_lit_, M6OPTS_PRIO_HIGH, CALL(_optimize_opts_), m6bye}, /* (                 ) */
     {{6, {m6plus, m6four, m6minus, m6one, m6minus, m6one}}, {}},
     {{}, {}},
     {1, {/* optimized sequence: */ m6two_plus}}},
};

static const char teststr_empty[] = "";
static const char teststr_hash[] = "#";
static const char teststr_dollar[] = "$";
static const char teststr_percent[] = "%";
static const char teststr_0[] = "0";
static const char teststr_quoted[] = "''";
static const char teststr_quoted_x[] = "'x'";
static const char teststr_lparen_y_quote[] = "(y'";
static const char teststr_quote_z_rparen[] = "'z)";
static const char teststr_quoted_00[] = "'00'";

static const char teststr_minus_123[] = "-123";

static const char teststr_abc[] = "abc";
static const char teststr_aBcDefGH[] = "aBcDefGH";
static const char teststr_z_[] = "z:";
static const char teststr_0az[] = "0az";
static const char teststr_percent_1011[] = "%1011";
static const char teststr_1234567890[] = "1234567890";
static const char teststr_4294967295[] = "4294967295";
static const char teststr_18446744073709551615[] = "18446744073709551615";
static const char teststr_dollar_12345a[] = "$12345a";
static const char teststr_dollar_123defg[] = "$123defg";
static const char teststr_dollar_ffffffff[] = "$ffffffff";
static const char teststr_dollar_ffffffffffffffff[] = "$ffffffffffffffff";

#define TESTSTR_n(name, n, ...) ((m6cell)(teststr##name + n)), (sizeof(teststr##name) - n - 1)
#define TESTSTR(...) TESTSTR_n(__VA_ARGS__, 0)

static m6testexecute testexecute_f[] = {
    /* ----------------------------- um/mod --------------------------------- */
    {"_ _ um/mod",
     {CALL(um_div_mod), m6bye},
     {{3, {3 /*dividend lo*/, 1 /*dividend hi*/, 2 /*divisor*/}}, {}},
     {{2, {1, 1 | (m6ucell)1 << (8 * SZ - 1)}}, {}},
     {}},
    /* ----------------------------- base ----------------------------------- */
    {"base @", {m6base, m6fetch, m6bye}, {{}, {}}, {{1, {10}}, {}}, {}},
    {"hex", {CALL(hex), m6base, m6fetch, m6bye}, {{}, {}}, {{1, {16}}, {}}, {}},
    {"decimal", {CALL(decimal), m6base, m6fetch, m6bye}, {{}, {}}, {{1, {10}}, {}}, {}},
    /* ----------------------------- char>base ------------------------------ */
    {"'#' char>base", {CALL(char_to_base), m6bye}, {{1, {'#'}}, {}}, {{1, {10}}, {}}, {}},
    {"'$' char>base", {CALL(char_to_base), m6bye}, {{1, {'$'}}, {}}, {{1, {16}}, {}}, {}},
    {"'%' char>base", {CALL(char_to_base), m6bye}, {{1, {'%'}}, {}}, {{1, {2}}, {}}, {}},
    {"'&' char>base", {CALL(char_to_base), m6bye}, {{1, {'&'}}, {}}, {{1, {0}}, {}}, {}},
    {"'\"' char>base", {CALL(char_to_base), m6bye}, {{1, {'"'}}, {}}, {{1, {0}}, {}}, {}},
    /* ----------------------------- string>base ---------------------------- */
    {"\"\" string>base",
     {CALL(string_to_base), m6bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{3, {TESTSTR(_empty), 10}}, {}},
     {}},
    {"\"#\" string>base",
     {CALL(string_to_base), m6bye},
     {{2, {TESTSTR(_hash)}}, {}},
     {{3, {TESTSTR(_hash, 1), 10}}, {}},
     {}},
    {"\"$\" string>base",
     {CALL(string_to_base), m6bye},
     {{2, {TESTSTR(_dollar)}}, {}},
     {{3, {TESTSTR(_dollar, 1), 16}}, {}},
     {}},
    {"\"%\" string>base",
     {CALL(string_to_base), m6bye},
     {{2, {TESTSTR(_percent)}}, {}},
     {{3, {TESTSTR(_percent, 1), 2}}, {}},
     {}},
    {"\"0\" string>base",
     {CALL(string_to_base), m6bye},
     {{2, {TESTSTR(_0)}}, {}},
     {{3, {TESTSTR(_0), 10}}, {}},
     {}},
    /* ----------------------------- string>char ---------------------------- */
    {"\"''\" string>char",
     {CALL(string_to_char), m6bye},
     {{2, {TESTSTR(_quoted)}}, {}},
     {{3, {TESTSTR(_quoted), -1}}, {}},
     {}},
    {"\"'x'\" string>char",
     {CALL(string_to_char), m6bye},
     {{2, {TESTSTR(_quoted_x)}}, {}},
     {{3, {TESTSTR(_quoted_x, 3), 'x'}}, {}},
     {}},
    {"\"(y'\" string>char",
     {CALL(string_to_char), m6bye},
     {{2, {TESTSTR(_lparen_y_quote)}}, {}},
     {{3, {TESTSTR(_lparen_y_quote), -1}}, {}},
     {}},
    {"\"'z)\" string>char",
     {CALL(string_to_char), m6bye},
     {{2, {TESTSTR(_quote_z_rparen)}}, {}},
     {{3, {TESTSTR(_quote_z_rparen), -1}}, {}},
     {}},
    {"\"'00'\" string>char",
     {CALL(string_to_char), m6bye},
     {{2, {TESTSTR(_quoted_00)}}, {}},
     {{3, {TESTSTR(_quoted_00), -1}}, {}},
     {}},
    /* ----------------------------- string>lower --------------------------- */
    {"\"abc\" string>lower",
     {m6zero, m6minus_rot, m6sp_fetch, m6cell_plus, m6cell_plus, m6swap, m6string_to_lower,
      m6two_drop, m6bye},
     {{2, {TESTSTR(_abc)}}, {}},
#if __BYTE_ORDER == __BIG_ENDIAN
     {{1, {'a' << 16 | 'b' << 8 | 'c'}}, {}},
#else
     {{1, {'a' | 'b' << 8 | 'c' << 16}}, {}},
#endif /* __BYTE_ORDER */
     {}},
#if SZ >= 8
    {"\"aBcDefGH\" string>lower",
     {m6zero, m6minus_rot, m6sp_fetch, m6cell_plus, m6cell_plus, m6swap, m6string_to_lower,
      m6two_drop, m6bye},
     {{2, {TESTSTR(_aBcDefGH)}}, {}},
#if __BYTE_ORDER == __BIG_ENDIAN
     {{1,
       {(m6cell)('a' << 24 | 'b' << 16 | 'c' << 8 | 'd') << 32 |
        ('e' << 24 | 'f' << 16 | 'g' << 8 | 'h')}},
#else
     {{1,
       {'a' | 'b' << 8 | 'c' << 16 | 'd' << 24 |
        (m6cell)('e' | 'f' << 8 | 'g' << 16 | 'h' << 24) << 32}},
#endif /* __BYTE_ORDER */
      {}},
     {}},
#endif /* SZ */
    /* ----------------------------- string>sign ---------------------------- */
    {"\"\" string>sign",
     {CALL(string_to_sign), m6bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{3, {TESTSTR(_empty), 1}}, {}},
     {}},
    {"\"0\" string>sign",
     {CALL(string_to_sign), m6bye},
     {{2, {TESTSTR(_0)}}, {}},
     {{3, {TESTSTR(_0), 1}}, {}},
     {}},
    {"\"-123\" string>sign",
     {CALL(string_to_sign), m6bye},
     {{2, {TESTSTR(_minus_123)}}, {}},
     {{3, {TESTSTR(_minus_123, 1), -1}}, {}},
     {}},
    /* ----------------------------- char>u --------------------------------- */
    {"'/' char>u", {CALL(char_to_u), m6bye}, {{1, {'/'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'0' char>u", {CALL(char_to_u), m6bye}, {{1, {'0'}}, {}}, {{1, {0}}, {}}, {}},
    {"'9' char>u", {CALL(char_to_u), m6bye}, {{1, {'9'}}, {}}, {{1, {9}}, {}}, {}},
    {"':' char>u", {CALL(char_to_u), m6bye}, {{1, {':'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'@' char>u", {CALL(char_to_u), m6bye}, {{1, {'@'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'A' char>u", {CALL(char_to_u), m6bye}, {{1, {'A'}}, {}}, {{1, {10}}, {}}, {}},
    {"'Z' char>u", {CALL(char_to_u), m6bye}, {{1, {'Z'}}, {}}, {{1, {35}}, {}}, {}},
    {"'[' char>u", {CALL(char_to_u), m6bye}, {{1, {'['}}, {}}, {{1, {-1}}, {}}, {}},
    {"'`' char>u", {CALL(char_to_u), m6bye}, {{1, {'`'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'a' char>u", {CALL(char_to_u), m6bye}, {{1, {'a'}}, {}}, {{1, {10}}, {}}, {}},
    {"'z' char>u", {CALL(char_to_u), m6bye}, {{1, {'z'}}, {}}, {{1, {35}}, {}}, {}},
    {"'{' char>u", {CALL(char_to_u), m6bye}, {{1, {'{'}}, {}}, {{1, {-1}}, {}}, {}},
    /* ----------------------------- valid-base? ---------------------------- */
    {"0 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {0}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"2 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {3}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"10 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {10}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"16 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {16}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"35 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {35}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"36 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {36}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"37 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {37}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"38 valid-base?", {CALL(valid_base_q), m6bye}, {{1, {38}}, {}}, {{1, {tfalse}}, {}}, {}},
    /* ----------------------------- string&base>u -------------------------- */
    {"\"\" 10 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_empty), 10}}, {}},
     {{3, {TESTSTR(_empty), 0}}, {}},
     {}},
    {"\"1011\" 2 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_percent_1011, 1), 2}}, {}},
     {{3, {TESTSTR(_percent_1011, 5), 0xb}}, {}},
     {}},
    {"\"12345a\" 2 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_dollar_12345a, 1), 2}}, {}},
     {{3, {TESTSTR(_dollar_12345a, 2), 0x1}}, {}},
     {}},
    {"\"12345a\" 10 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_dollar_12345a, 1), 10}}, {}},
     {{3, {TESTSTR(_dollar_12345a, 6), 12345}}, {}},
     {}},
    {"\"1234567890\" 10 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_1234567890), 10}}, {}},
     {{3, {TESTSTR(_1234567890, 10), 1234567890}}, {}},
     {}},
    {"\"4294967295\" 10 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_4294967295), 10}}, {}},
     {{3, {TESTSTR(_4294967295, 10), (m6cell)4294967295ul}}, {}},
     {}},
    {"\"12345a\" 16 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_dollar_12345a, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_12345a, 7), 0x12345a}}, {}},
     {}},
    {"\"123defg\" 16 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_dollar_123defg, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_123defg, 7), 0x123def}}, {}},
     {}},
    {"\"ffffffff\" 16 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_dollar_ffffffff, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_ffffffff, 9), (m6cell)0xfffffffful}}, {}},
     {}},
#if SZ >= 8
    {"\"18446744073709551615\" 10 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_18446744073709551615), 10}}, {}},
     {{3, {TESTSTR(_18446744073709551615, 20), (m6cell)18446744073709551615ul}}, {}},
     {}},
    {"\"ffffffffffffffff\" 16 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_dollar_ffffffffffffffff, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_ffffffffffffffff, 17), (m6cell)0xfffffffffffffffful}}, {}},
     {}},
#endif /* SZ >= 8 */
    {"\"0az\" 36 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_0az), 36}}, {}},
     {{3, {TESTSTR(_0az, 3), 395}}, {}},
     {}},
    {"\"z:\" 36 string&base>u",
     {CALL(string_base_to_u), m6bye},
     {{3, {TESTSTR(_z_), 36}}, {}},
     {{3, {TESTSTR(_z_, 1), 35}}, {}},
     {}},
    /* ----------------------------- string>number -------------------------- */
    {"\"\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{2, {0, tfalse}}, {}},
     {}},
    {"\"12345a\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_dollar_12345a, 1)}}, {}},
     {{2, {12345, tfalse}}, {}},
     {}},
    {"\"1234567890\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_1234567890)}}, {}},
     {{2, {1234567890, ttrue}}, {}},
     {}},
    {"\"4294967295\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_4294967295)}}, {}},
     {{2, {(m6cell)4294967295ul, ttrue}}, {}},
     {}},
    {"\"%1011\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_percent_1011)}}, {}},
     {{2, {0xb, ttrue}}, {}},
     {}},
    {"\"$12345a\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_dollar_12345a)}}, {}},
     {{2, {0x12345a, ttrue}}, {}},
     {}},
    {"\"$123defg\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_dollar_123defg)}}, {}},
     {{2, {0x123def, tfalse}}, {}},
     {}},
    {"\"$ffffffff\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_dollar_ffffffff)}}, {}},
     {{2, {(m6cell)0xfffffffful, ttrue}}, {}},
     {}},
#if SZ >= 8
    {"\"18446744073709551615\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_18446744073709551615)}}, {}},
     {{2, {(m6cell)18446744073709551615ul, ttrue}}, {}},
     {}},
    {"\"$ffffffffffffffff\" string>number",
     {CALL(string_to_number), m6bye},
     {{2, {TESTSTR(_dollar_ffffffffffffffff), 16}}, {}},
     {{2, {(m6cell)0xfffffffffffffffful, ttrue}}, {}},
     {}},
#endif
    /* ----------------------------- string= -------------------------------- */
    {"\"abcdefg\" \"abcdefg\" string=",
     {CALL(string_equal), m6bye},
     {{3, {(m6cell) "abcdefgh0", (m6cell) "abcdefgh1", 7}}, {}},
     {{4, {(m6cell) "abcdefgh0", (m6cell) "abcdefgh1", 7, ttrue}}, {}},
     {}},
    {"\"abcdefgh\" \"abcdefgh\" string=",
     {CALL(string_equal), m6bye},
     {{3, {(m6cell) "abcdefgh0", (m6cell) "abcdefgh1", 8}}, {}},
     {{4, {(m6cell) "abcdefgh0", (m6cell) "abcdefgh1", 8, ttrue}}, {}},
     {}},
    {"\"abcdefgh0\" \"abcdefgh1\" string=",
     {CALL(string_equal), m6bye},
     {{3, {(m6cell) "abcdefgh0", (m6cell) "abcdefgh1", 9}}, {}},
     {{4, {(m6cell) "abcdefgh0", (m6cell) "abcdefgh1", 9, tfalse}}, {}},
     {}},
    /* ----------------------------- string-ci= ----------------------------- */
    {"\"ex-message@\" \"ex-message!\" string-ci=",
     {CALL(string_ci_equal), m6bye},
     {{3, {(m6cell) "ex-message@", (m6cell) "ex-message!", 11}}, {}},
     {{4, {(m6cell) "ex-message@", (m6cell) "ex-message!", 11, tfalse}}, {}},
     {}},
    {"\"abcdef@\" \"abcdef@\" string-ci=",
     {CALL(string_ci_equal), m6bye},
     {{3, {(m6cell) "abcdef@+", (m6cell) "abcdef@+ ", 8}}, {}},
     {{4, {(m6cell) "abcdef@+", (m6cell) "abcdef@+ ", 8, ttrue}}, {}},
     {}},
    {"\"abcdef@\" \"abCdeF@\" string-ci=",
     {CALL(string_ci_equal), m6bye},
     {{3, {(m6cell) "abcdef@+", (m6cell) "abCdeF@", 7}}, {}},
     {{4, {(m6cell) "abcdef@+", (m6cell) "abCdeF@", 7, ttrue}}, {}},
     {}},
    {"\"abcdef@+\" \"abCdeF`+\" string-ci=",
     {CALL(string_ci_equal), m6bye},
     {{3, {(m6cell) "abcdef@+", (m6cell) "abCdeF`+", 8}}, {}},
     {{4, {(m6cell) "abcdef@+", (m6cell) "abCdeF`+", 8, tfalse}}, {}},
     {}},
    {"NULL string-find-blank",
     {CALL(string_find_blank), m6bye},
     {{2, {(m6cell)NULL, 0}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" \" string-find-blank",
     {CALL(string_find_blank), m6bye},
     {{2, {(m6cell) " ", 1}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\"x\" string-find-blank",
     {CALL(string_find_blank), m6bye},
     {{2, {(m6cell) "x", 1}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\"yz \" string-find-blank",
     {CALL(string_find_blank), m6bye},
     {{2, {(m6cell) "yz =", 3}}, {}},
     {{1, {2}}, {}},
     {}},
    {"\"yz =\" string-find-blank",
     {CALL(string_find_blank), m6bye},
     {{2, {(m6cell) "yz =", 4}}, {}},
     {{1, {2}}, {}},
     {}},
    {"NULL '.' string-find-char",
     {CALL(string_find_char), m6bye},
     {{3, {(m6cell)NULL, 0, '.'}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" \" '.' string-find-char",
     {CALL(string_find_char), m6bye},
     {{3, {(m6cell) " ", 1, '.'}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\" yz \" 'z' string-find-char",
     {CALL(string_find_char), m6bye},
     {{3, {(m6cell) " yz =", 4, 'z'}}, {}},
     {{1, {2}}, {}},
     {}},
    {"\"\r\n \" bl string-find-char",
     {CALL(string_find_char), m6bye},
     {{3, {(m6cell) " \r\n " + 1, 3, ' '}}, {}},
     {{1, {2}}, {}},
     {}},
    {"NULL string-find-nonblank",
     {CALL(string_find_nonblank), m6bye},
     {{2, {(m6cell)0, 0}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" \" string-find-nonblank",
     {CALL(string_find_nonblank), m6bye},
     {{2, {(m6cell) " ", 1}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\"x\" string-find-nonblank",
     {CALL(string_find_nonblank), m6bye},
     {{2, {(m6cell) "x", 1}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" yz \" string-find-nonblank",
     {CALL(string_find_nonblank), m6bye},
     {{2, {(m6cell) " yz =", 4}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\" \r\n \" string-find-nonblank",
     {CALL(string_find_nonblank), m6bye},
     {{2, {(m6cell) " \r\n ", 4}}, {}},
     {{1, {4}}, {}},
     {}},
    /* ---------------------------- cmove, move ----------------------------- */
    {"cmove",
     {m6sp_fetch, m6one_plus, m6dup, m6cell_plus, m6two, m6cmove, m6bye},
     {{2, {0, 'a' | 'b' << 8 | 'c' << 16 | 'd' << 24}}, {}},
     {{2, {'b' << 8 | 'c' << 16, 'a' | 'b' << 8 | 'c' << 16 | 'd' << 24}}, {}},
     {}},
    {"cmove \\ with copy propagation",
     {m6sp_fetch, m6dup, m6one_plus, m6two, m6cmove, m6bye},
     {{1, {'w' | 'x' << 8 | 'y' << 16 | 'z' << 24}}, {}},
     {{1, {'w' | 'w' << 8 | 'w' << 16 | 'z' << 24}}, {}},
     {}},
    {"-cmove/count",
     {m6sp_fetch, m6dup, m6one_plus, m6cell_plus, m6swap, m6two, m6minus_cmove_count, m6two_drop,
      m6bye},
     {{2, {'a' | 'b' << 8 | 'c' << 16 | 'd' << 24, 0}}, {}},
     {{2, {'a' | 'b' << 8 | 'c' << 16 | 'd' << 24, 'b' | 'c' << 8}}, {}},
     {}},
    {"-cmove/count \\ with copy propagation",
     {m6sp_fetch, m6dup, m6one_plus, m6swap, m6two, m6minus_cmove_count, m6two_drop, m6bye},
     {{1, {'w' | 'x' << 8 | 'y' << 16 | 'z' << 24}}, {}},
     {{1, {'y' | 'y' << 8 | 'y' << 16 | 'z' << 24}}, {}},
     {}},
    {"move",
     {m6sp_fetch, m6dup, m6four, m6cells, m6plus, m6three, m6move, m6bye},
     {{8, {-4, -3, -2, -1, 0, 11, 12, 13}}, {}},
     {{8, {-4, 11, 12, 13, 0, 11, 12, 13}}, {}},
     {}},
    {"move \\ overlapping source and destination",
     {m6sp_fetch, m6cell_plus, m6dup, m6cell_plus, m6swap, m6_lit_, T(5), m6move, m6bye},
     {{8, {0, 1, 2, 3, 4, 5, 6, 7}}, {}},
     {{8, {0, 1, 1, 2, 3, 4, 5, 7}}, {}},
     {}},

};

static void test_noop(void) {
}

static m6cell test_negate(m6cell a) {
    return -a;
}

typedef struct {
    m6cell a, b;
} sum_triplets_ret;

static sum_triplets_ret test_sum_triplets(m6cell a, m6cell b, m6cell c, m6cell d, m6cell e,
                                          m6cell f) {
    sum_triplets_ret ret = {a + b + c, d + e + f};
    return ret;
}

static m6testexecute testexecute_g[] = {
    /* ----------------------------- (c-call) --------------------------------- */
    {"(c-call) test_noop",
     {m6_c_arg_0_, m6_c_call_, CELL(test_noop), m6_c_ret_0_, m6bye},
     {{}, {}},
     {{}, {}},
     {}},
    {"(c-call) test_negate",
     {m6_c_arg_1_, m6_c_call_, CELL(test_negate), m6_c_ret_1_, m6bye},
     {{1, {9}}, {}},
     {{1, {-9}}, {}},
     {}},
    {"(c-call) test_sum_triplets",
     {m6_c_arg_6_, m6_c_call_, CELL(test_sum_triplets), m6_c_ret_2_, m6bye},
     {{6, {1, 2, 3, 4, 5, 6}}, {}},
     {{2, {6, 15}}, {}},
     {}},
    /* ----------------------------- comma... ------------------------------- */
    {"0x123 token,", {m6token_comma, m6bye}, {{1, {0x123}}, {}}, {{}, {}}, {1, {0x123}}},
    {"(lit,) T(500) [#compiled]",
     {m6_num_compiled_, m6_lit_comma_, T(500), m6_num_compiled_, m6bye},
     {{}, {}},
     {{2, {0, 1}}, {}},
     {1, {500}}},
    {"0xcdef short,",
     {m6_num_compiled_, m6swap, m6short_comma, m6_num_compiled_, m6bye},
     {{1, {0xcdef}}, {}},
     {{2, {0, 1}}, {}},
     {1, {0xcdef}}},
#if __BYTE_ORDER == __LITTLE_ENDIAN
    {"1 c, 2 c,", {m6c_comma, m6c_comma, m6bye}, {{2, {2, 1}}, {}}, {{}, {}}, {1, {0x0201}}},
#if SZt == 2
    {"0x12345678 int,",
     {m6int_comma, m6bye},
     {{1, {0x12345678}}, {}},
     {{}, {}},
     {2, {0x5678, 0x1234}}},
#define P(a, b) ((a) | ((b) << 8))
    {"\"foo\" 3 countedstring,",
     {m6countedstring_comma, m6bye},
     {{2, {(m6cell) "foobarbaz", 3}}, {}},
     {{}, {}},
     {2, {P(3, 'f'), P('o', 'o')}}},
    {"\"foobarbaz\" 9 countedstring,",
     {m6countedstring_comma, m6bye},
     {{2, {(m6cell) "foobarbaz", 9}}, {}},
     {{}, {}},
     {5, {P(9, 'f'), P('o', 'o'), P('b', 'a'), P('r', 'b'), P('a', 'z')}}},
    {"\"foobar\" 6 compile-string,",
     {CALL(compile_string_comma), m6bye},
     {{2, {(m6cell) "foobarbaz", 6}}, {}},
     {{}, {}},
     {3, {LIT_STRING(6, "foobar")}}},
#undef P
#if SZ == 8
    {"0x08090a0b0c0d0e0f ,",
     {m6comma, m6_num_compiled_, m6bye},
     {{1, {0x08090a0b0c0d0e0f}}, {}},
     {{1, {SZ / SZt}}, {}},
     {4, {0x0e0f, 0x0c0d, 0x0a0b, 0x0809}}},
#elif SZ == 4
    {"0x0c0d0e0f ,", {m6comma, m6bye}, {{1, {0x0c0d0e0f}}, {}}, {{}, {}}, {2, {0x0e0f, 0x0c0d}}},
#endif /* SZ */
#endif /* SZt == 2 */
#endif /* __BYTE_ORDER */
    {"\"\" 0 name,",
     {m6name_comma, m6here, m6minus, m6bye},
     {{2, {(m6cell) "bar", 0}}, {}},
     {{1, {-WORD_OFF_XT}}, {}},
     {}},
    {";", {CALL(semi), m6bye}, {{2, {0, m6colon}}, {}}, {{}, {}}, {1, {m6exit}}},
    /* ----------------------------- search order --------------------------- */
    {"get-current", {m6get_current, m6bye}, {{}, {}}, {{1, {(m6cell)&m6wordlist_forth}}, {}}, {}},
    {"set-current",
     {m6get_current, m6swap, m6set_current, m6get_current, m6swap, m6set_current, m6bye},
     {{1, {(m6cell)&m6wordlist_m64th_impl}}, {}},
     {{1, {(m6cell)&m6wordlist_m64th_impl}}, {}},
     {}},
    /* ----------------------------- flags ---------------------------------- */
    {"ip_2 flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m6bye},
     {{1, {m6flag_consumes_ip_2}}, {}},
     {{1, {2 / SZt}}, {}},
     {}},
    {"ip_4 flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m6bye},
     {{1, {m6flag_consumes_ip_4}}, {}},
     {{1, {4 / SZt}}, {}},
     {}},
    {"ip_8 flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m6bye},
     {{1, {m6flag_consumes_ip_8}}, {}},
     {{1, {8 / SZt}}, {}},
     {}},
    {"_ flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m6bye},
     {{1, {m6flag_mem_fetch}}, {}},
     {{1, {0}}, {}},
     {}},
    /* ----------------------------- token ---------------------------------- */
    {"token>asm>addr",
     {m6token_to_asm_addr, m6bye},
     {{1, {m6dup}}, {}},
     {{1, {(m6cell)m6fdup}}, {}},
     {}},
    {"'then token>asm-replace",
     {m6sp_fetch, CALL(token_to_asm_replace), m6bye},
     {{1, {m6then}}, {}},
     {{2, {m6then, m6_asm_then_}}, {}},
     {}},
    {"'then token>asm>n",
     {m6sp_fetch, CALL(token_to_asm_n), m6bye},
     {{1, {m6then}}, {}},
     {{3, {m6then, 0, ttrue}}, {}},
     {}},
    {"'noop token>asm>n",
     {m6sp_fetch, CALL(token_to_asm_n), m6bye},
     {{1, {m6noop}}, {}},
     {{3, {m6noop, 0, ttrue}}, {}},
     {}},
    {"token>name",
     {m6token_to_name, m6bye},
     {{1, {m6dup}}, {}},
     {{1, {(m6cell)&WORD_SYM(dup)}}, {}},
     {}},
    {"' noop token>asm",
     {CALL(token_to_asm), m6bye},
     {{1, {m6noop}}, {}},
     {{2, {(m6cell)m6fnoop, 0}}, {}},
     {}},
#if defined(__x86_64__) || defined(__aarch64__)
    {"'nip token>asm",
     {CALL(token_to_asm), m6bye},
     {{1, {m6nip}}, {}},
     {{2, {(m6cell)m6fnip, 4}}, {}}, /* correct for both amd64 and arm64 */
     {}},
    {"'(if) token>asm-replace token>asm",
     {m6sp_fetch, CALL(token_to_asm_replace), CALL(token_to_asm), m6drop,
      m6bye}, /* ASM len varies, drop it */
     {{1, {m6_if_}}, {}},
     {{2, {m6_if_, (m6cell)m6f_asm_if_}}, {}},
     {}},
#endif
    /* ----------------------------- name ----------------------------------- */
    {"' noop name>asm>n",
     {m6name_to_asm_n, m6bye},
     {{1, {(m6cell)&WORD_SYM(noop)}}, {}},
     {{2, {0, ttrue}}, {}},
     {}},
    {"' repl name>asm>n",
     {m6name_to_asm_n, m6bye},
     {{1, {(m6cell)&WORD_SYM(repl)}}, {}},
     {{2, {0, tfalse}}, {}},
     {}},
    {"name>flags",
     {m6name_to_flags, m6bye},
     {{1, {(m6cell)&WORD_SYM(two_dup)}}, {}},
     {{1, {WORD_PURE}}, {}},
     {}},
    {"name>code",
     {m6name_to_code, m6bye},
     {{1, {(m6cell)&WORD_SYM(noop)}}, {}},
     {{2, {DXT(noop), 2}}, {}},
     {}},
    {"name>data",
     {m6name_to_data, m6bye},
     {{1, {(m6cell)&WORD_SYM(dup)}}, {}},
     {{2, {(m6cell)&WORD_SYM(dup) + 32, 0}}, {}},
     {}},
    {"name>string",
     {m6name_to_string, m6bye},
     {{1, {(m6cell)&WORD_SYM(mod)}}, {}},
     {{2, {(m6cell)NULL /* fixed by m6testexecute_fix() */, 3}}, {}},
     {}},
    {"name>prev",
     {m6name_to_prev, m6bye},
     {{1, {(m6cell)&WORD_SYM(plus_store)}}, {}},
     {{1, {(m6cell)&WORD_SYM(plus)}}, {}},
     {}},
    {"name>xt",
     {m6name_to_xt, m6bye},
     {{1, {(m6cell)&WORD_SYM(dup)}}, {}},
     {{1, {DXT(dup)}}, {}},
     {}},
    /* ----------------------------- xt ------------------------------------- */
    {"{1 exit} xt>asm>n",
     {m6token_comma, m6token_comma, CALL(xt_to_asm_n), m6nip, m6bye},
     {{2, {m6exit, m6one}}, {}},
     {{1, {ttrue}}, {}},
     {2, {m6one, m6exit}}},
    {"{(ip>data) exit} xt>asm>n",
     {m6token_comma, m6token_comma, CALL(xt_to_asm_n), m6nip, m6bye},
     {{2, {m6exit, m6_ip_to_data_}}, {}},
     {{1, {tfalse}}, {}},
     {2, {m6_ip_to_data_, m6exit}}},
    /* ----------------------------- wordlist ------------------------------- */
    {"wordlist>last",
     {m6wordlist_to_last, m6bye},
     {{1, {(m6cell)&m6wordlist_forth}}, {}},
     {{1, {(m6cell)&WORD_SYM(cmove)}}, {}},
     {}},
    {"\"dup\" wordlist-find",
     {CALL(wordlist_find), m6bye},
     {{3, {(m6cell) "dup", 3, (m6cell)&m6wordlist_forth}}, {}},
     {{2, {(m6cell)&WORD_SYM(dup), ttrue}}, {}},
     {}},
    {"\"0az\" wordlist-find",
     {CALL(wordlist_find), m6bye},
     {{3, {TESTSTR(_0az), (m6cell)&m6wordlist_forth}}, {}},
     {{2, {0, 0}}, {}},
     {}},
    {"\"ex-message!\" wordlist-find",
     {CALL(wordlist_find), m6bye},
     {{3, {(m6cell) "ex-message!", 11, (m6cell)&m6wordlist_m64th_user}}, {}},
     {{2, {(m6cell)&WORD_SYM(ex_message_store), ttrue}}, {}},
     {}},
    {"\"dup\" search-wordlist",
     {CALL(search_wordlist), m6bye},
     {{3, {(m6cell) "dup", 3, (m6cell)&m6wordlist_forth}}, {}},
     {{2, {DXT(dup), ttrue}}, {}},
     {}},
    {"\"if\" search-wordlist",
     {CALL(search_wordlist), m6bye},
     {{3, {(m6cell) "if", 2, (m6cell)&m6wordlist_forth}}, {}},
     {{2, {DXT(if), 1}}, {}},
     {}},
    {"\"0az\" search-wordlist",
     {CALL(search_wordlist), m6bye},
     {{3, {TESTSTR(_0az), (m6cell)&m6wordlist_forth}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\"?do\" string>name",
     {CALL(string_to_name), m6bye},
     {{2, {(m6cell) "?do", 3}}, {}},
     {{3, {(m6cell)&WORD_SYM(question_do), (m6cell)&m6wordlist_forth, 1}}, {}},
     {}},
    {"\"0az\" string>name",
     {CALL(string_to_name), m6bye},
     {{2, {TESTSTR(_0az)}}, {}},
     {{3, {0, 0, 0}}, {}},
     {}},
    /* --------------------------- search order ----------------------------- */
    {"get-order",
     {CALL(get_order), m6bye},
     {{}, {}},
     {{4,
       {(m6cell)&m6wordlist_m64th_user, (m6cell)&m6wordlist_forth, (m6cell)&m6wordlist_forth, 3}},
      {}},
     {}},
    {"' (if) name-inline?",
     {CALL(name_inline_query), m6bye},
     {{1, {(m6cell)&WORD_SYM(_if_)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' + name-inline?",
     {CALL(name_inline_query), m6bye},
     {{1, {(m6cell)&WORD_SYM(plus)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' if name-inline?",
     {CALL(name_inline_query), m6bye},
     {{1, {(m6cell)&WORD_SYM(if)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' noop name-inline?",
     {CALL(name_inline_query), m6bye},
     {{1, {(m6cell)&WORD_SYM(noop)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' literal name-inline?",
     {CALL(name_inline_query), m6bye},
     {{1, {(m6cell)&WORD_SYM(literal)}}, {}},
     {{1, {tfalse}}, {}},
     {}},
    {"' name-inline? name-inline?",
     {CALL(name_inline_query), m6bye},
     {{1, {(m6cell)&WORD_SYM(name_inline_query)}}, {}},
     {{1, {tfalse}}, {}},
     {}},
    {"' + [inline]",
     {CALL(_inline_), m6bye},
     {{1, {(m6cell)&WORD_SYM(plus)}}, {}},
     {{}, {}},
     {1, {m6plus}}},
    {"' 1 [inline] ' 3 [inline] ' + [inline]",
     {CALL(_inline_), CALL(_inline_), CALL(_inline_), m6bye},
     {{3, {(m6cell)&WORD_SYM(plus), (m6cell)&WORD_SYM(three), (m6cell)&WORD_SYM(one)}}, {}},
     {{}, {}},
     {3, {m6one, m6three, m6plus}}},
    /* ----------------------------- compile, ------------------------------- */
    {"' noop compile,",
     {CALL(compile_comma), m6bye},
     {{1, {DXT(noop)}}, {}},
     {{}, {}},
     {1, {m6noop}}},
    {"' 1+ compile, ' and compile,",
     {CALL(compile_comma), CALL(compile_comma), m6bye},
     {{2, {DXT(and), DXT(one_plus)}}, {}},
     {{}, {}},
     {2, {m6one_plus, m6and}}},
    /* ----------------------------- (eval...) -------------------------------- */
    {"0 (eval-number)",
     {CALL(_eval_number_), m6bye},
     {{1, {0}}, {}},
     {{1, {0}}, {}},
     {}}, /* state = interpret */
    {"0 (eval-number)",
     {CALL(_eval_number_), m6bye},
     {{1, {0}}, {}},
     {{}, {}},
     {1, {m6zero}}}, /* state = compile */
    {"' dup (eval-name)",
     {CALL(_eval_name_), m6bye},
     {{3, {7, (m6cell)&WORD_SYM(dup), ttrue}}, {}},
     {{2, {7, 7}}, {}},
     {}}, /* state = interpret */
    {"' dup (eval-name)",
     {CALL(_eval_name_), m6bye},
     {{2, {(m6cell)&WORD_SYM(dup), ttrue}}, {}},
     {{}, {}},
     {1, {m6dup}}}, /* state = compile */
};

static void m6testexecute_fix(m6testexecute *t, const m6code_pair *pair) {
    switch (t->code[0]) {
    case m6_ip_:
        if (t->code[1] == m6bye) {
            t->after.d.data[0] = (m6cell)pair->first.addr;
        }
        break;
    case m6_ip_to_data_addr_:
        /* TODO t->after.d.data[0] = (m6cell)w->data; */
        break;
    case m6name_to_string:
        t->after.d.data[0] = (m6cell)m6word_name((const m6word *)t->before.d.data[0]).addr;
        break;
    case m6_catch_beg_:
        if (t->code[1] == m6_catch_end_ && t->code[2] == m6_missing_) {
            /* testing "' bye catch" */
            t->after.r.data[4] = (m6cell)pair->first.addr + SZt;
        }
    }
}

static m6code_pair m6testexecute_init(m6testexecute *t, m6countedcode_pair *code_buf) {
    m6slice t_code_in = {(m6cell *)t->code, m6test_code_n};
    m6slice t_codegen_in = {(m6cell *)t->codegen.data, t->codegen.n};
    m6code_pair pair = {{code_buf->first.data, code_buf->first.n},
                        {code_buf->second.data, code_buf->second.n}};

    m6slice_copy_to_code(t_code_in, &pair.first);
    m6slice_copy_to_code(t_codegen_in, &pair.second);
    return pair;
}

static m6cell m6testexecute_run(m64th *m, m6testexecute *t, const m6code_pair *pair) {
    m64th_clear(m);
    if (t->codegen.n != 0) {
        m6string name = {};
        m64th_colon(m, name);
    }
    m6testexecute_fix(t, pair);

    m6countedstack_copy(&t->before.d, &m->dstack);
    m6countedstack_copy(&t->before.r, &m->rstack);
#if 0
    m->in->handle = (m6cell)stdin;
    m->in->func = m6word_code(&WORD_SYM(c_fread)).addr;
#endif /* 0 */
    m->ip = pair->first.addr;

    m64th_run(m);

    m64th_sync_lastw(m);

    return m6countedstack_equal(&t->after.d, &m->dstack) &&
           m6countedstack_equal(&t->after.r, &m->rstack) &&
           m6code_equal(pair->second, m6word_code(m->lastw));
}

static void m6testexecute_failed(m64th *m, const m6testexecute *t, const m6code_pair *pair,
                                 FILE *out) {
    if (out == NULL) {
        return;
    }
    fprintf(out, "execute test failed: %s", t->name);
    fputs("\n    expected  data  stack ", out);
    m6countedstack_print(&t->after.d, out);
    fputs("\n      actual  data  stack ", out);
    m6stack_print(&m->dstack, m6mode_user, out);

    fputs("\n... expected return stack ", out);
    m6countedstack_print(&t->after.r, out);
    fputs("\n      actual return stack ", out);
    m6stack_print(&m->rstack, m6mode_user, out);

    if (t->codegen.n == 0 && (!m->lastw || m->lastw->code_n == 0)) {
        fputc('\n', out);
        return;
    }
    fputs("\n... expected    codegen   ", out);
    m6code_print(pair->second, m6mode_user, out);
    fputs("\n      actual    codegen   ", out);
    m6code_print(m6word_code(m->lastw), m6mode_user, out);
    fputc('\n', out);
}

static void m64th_testexecute_bunch(m64th *m, m6testexecute bunch[], m6cell n, m6testcount *count,
                                    FILE *out) {
    m6countedcode_pair countedcode_pair = {{m6test_code_n, {}}, {m6test_code_n, {}}};
    m6cell i, fail = 0;
    for (i = 0; i < n; i++) {
        m6code_pair code_pair = m6testexecute_init(&bunch[i], &countedcode_pair);
#undef M64TH_TEST_VERBOSE
#ifdef M64TH_TEST_VERBOSE
        fprintf(out, "%s\n", bunch[i].name);
#endif
        if (!m6testexecute_run(m, &bunch[i], &code_pair)) {
            fail++, m6testexecute_failed(m, &bunch[i], &code_pair, out);
        }
        m6test_forget_all(m);
    }
    count->failed += fail;
    count->total += n;
}

void m64th_testbench_crc_c(FILE *out) {
    m6ucell i, n = 1e8;
    uint32_t crc = ~(uint32_t)0;
    const uint32_t expected = 0x773edc4e;
    for (i = 0; i < n; i++) {
        crc = m64th_crc1byte(crc, 't');
    }
    if (crc != expected) {
        fprintf(out, "m64th_testbench_crc_c mismatch: expected 0x%lx, got 0x%lx\n", (long)expected,
                (long)crc);
    }
}

m6cell m64th_testexecute(m64th *m, FILE *out) {
    m6testexecute *t[] = {
        testexecute_a, testexecute_b, testexecute_c, testexecute_d,
        testexecute_e, testexecute_f, testexecute_g,
    };
    const m6cell n[] = {
        N_OF(testexecute_a), N_OF(testexecute_b), N_OF(testexecute_c), N_OF(testexecute_d),
        N_OF(testexecute_e), N_OF(testexecute_f), N_OF(testexecute_g),
    };
    m6testcount count = {};
    m6cell i;

    m6array_copy_to_tarray(crc1byte_array, crc1byte_code);
    /* printf("crc('t') = %u\n", (unsigned)m64th_crc1byte(0xffffffff, 't')); */

    for (i = 0; i < (m6cell)N_OF(t); i++) {
        m64th_testexecute_bunch(m, t[i], n[i], &count, out);
    }

    if (out != NULL) {
        if (count.failed == 0) {
            fprintf(out, "all %3u execute tests passed\n", (unsigned)count.total);
        } else {
            fprintf(out, "\nexecute tests failed: %3u of %3u\n", (unsigned)count.failed,
                    (unsigned)count.total);
        }
    }
    return count.failed;
}

#endif /* M64TH_T_TESTEXECUTE_C */
