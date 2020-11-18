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

#ifndef M4TH_T_TESTEXECUTE_C
#define M4TH_T_TESTEXECUTE_C

#include "../impl.h"
#include "../include/err.h"
#include "../include/func_fwd.h"
#include "../include/hashmap_number.h"
#include "../include/iobuf.mh"
#include "../include/token.h"
#include "../include/word_fwd.h"
#include "../m4th.h"
#include "testcommon.h"

#include <assert.h> /* assert()          */
#include <endian.h> /* __BYTE_ORDER      */
#include <string.h> /* memset()          */

/* -------------- m4cell[] -> m4token[] conversion -------------- */

void m4array_n_copy_to_tarray_n(const m4cell array[], const m4cell array_n /*               */,
                                m4token tarray[], const m4cell tarray_n) {
    m4slice src = {(m4cell *)array, array_n};
    m4code dst = {tarray, tarray_n};
    m4slice_copy_to_code(src, &dst);
}

/* -------------- crc1byte -------------- */

/**
 * compiled forth version of m4th_crc1byte (see ../impl.c). forth source would be
 *
 * : crc+ ( crc char -- crc' )
 *   over xor to-char cells m4th_crctable + @ swap 8 rshift xor
 * ;
 */
static const m4cell crc1byte_array[] = {
    m4over, m4xor,   m4to_char, m4cells, m4_lit_cell_, CELL(m4th_crctable), m4plus, m4fetch,
    m4swap, m4eight, m4rshift,  m4xor,   m4exit,
};
/* initialized by m4th_testexecute() */
static m4token crc1byte_code[N_OF(crc1byte_array)];

/* -------------- [any-token-gives-cell?] -------------- */

static const m4token testdata_any[] = {
    m4zero, m4one, m4minus_one, m4two, m4four, m4eight,
};

/* -------------- m4test -------------- */

void m4ftest_crc_plus_native_forth(m4arg _); /* implemented in generic_asm/test.S */
void m4ftest_exec_xt_from_native(m4arg _);   /* implemented in generic_asm/test.S */

#define _1e9 ((m4cell)1000000000)

static m4testexecute testexecute_a[] = {
#if 0
    {"1e9 0 do i+ loop",
     {m4do, m4i_plus, m4_loop_, T(-3), m4bye},
     {{3, {0, _1e9, 0}}, {}},
     {{1, {_1e9 * (_1e9 - 1) / 2}}, {}},
     {}},
#elif 0
    {"1e9 0 do-i+-loop",
     {m4do_i_plus_loop, m4bye},
     {{3, {0, _1e9, 0}}, {}},
     {{1, {_1e9 * (_1e9 - 1) / 2}}, {}},
     {}},
#elif 0
    {"1e6 0 do wordlist-find loop",
     {m4do, m4j, CALL(wordlist_find), m4_loop_, T(-3 - callsz), m4bye},
     {{4, {(m4cell) "dup", 3, 1e6, 0}}, {1, {(m4cell)&m4wordlist_forth}}},
     {{2, {(m4cell) "dup", 3}}, {1, {(m4cell)&m4wordlist_forth}}},
     {}},
#elif 0
    {"1e8 0 do over crc+ loop nip",
     {m4do, m4over, m4_call_xt_, CELL(crc1byte_code), m4_loop_, T(-3 - callsz), m4nip, m4bye},
     {{4, {'t', 0xffffffff, 1e8, 0}}, {}},
     {{1, {0x773edc4e}}, {}},
     {}},
#elif 0
    {"1e8 0 do over crc+-native-forth loop nip",
     {m4do, m4over, m4_call_native_, CELL(m4ftest_crc_plus_native_forth), m4_loop_, T(-3 - callsz),
      m4nip, m4bye},
     {{4, {'t', 0xffffffff, 1e8, 0}}, {}},
     {{1, {0x773edc4e}}, {}},
     {}},
#else
    /* ----------------------------- arithmetic ----------------------------- */
    {"*", {m4times, m4bye}, {{2, {20, 7}}, {}}, {{1, {140}}, {}}, {}},
    {"+", {m4plus, m4bye}, {{2, {-3, 2}}, {}}, {{1, {-1}}, {}}, {}},
    {"-", {m4minus, m4bye}, {{2, {3, 5}}, {}}, {{1, {-2}}, {}}, {}},
    {"-20 7 /", {m4div, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-2}}, {}}, {}},
    {"20 7 /", {m4div, m4bye}, {{2, {20, 7}}, {}}, {{1, {2}}, {}}, {}},
    {"-20 7 /mod", {m4div_mod, m4bye}, {{2, {-20, 7}}, {}}, {{2, {-6, -2}}, {}}, {}},
    {"20 7 /mod", {m4div_mod, m4bye}, {{2, {20, 7}}, {}}, {{2, {6, 2}}, {}}, {}},
    {"-1", {m4minus_one, m4bye}, {{}, {}}, {{1, {-1}}, {}}, {}},
    {"0", {m4zero, m4bye}, {{}, {}}, {{1, {}}, {}}, {}},
    {"1", {m4one, m4bye}, {{}, {}}, {{1, {1}}, {}}, {}},
    {"1-", {m4one_minus, m4bye}, {{1, {-3}}, {}}, {{1, {-4}}, {}}, {}},
    {"1+", {m4one_plus, m4bye}, {{1, {-6}}, {}}, {{1, {-5}}, {}}, {}},
    {"2", {m4two, m4bye}, {{}, {}}, {{1, {2}}, {}}, {}},
    {"2*", {m4two_times, m4bye}, {{1, {-6}}, {}}, {{1, {-12}}, {}}, {}},
    {"2+", {m4two_plus, m4bye}, {{1, {-6}}, {}}, {{1, {-4}}, {}}, {}},
    {"2-", {m4two_minus, m4bye}, {{1, {-3}}, {}}, {{1, {-5}}, {}}, {}},
    {"n 2/", {m4two_div, m4bye}, {{1, {-5}}, {}}, {{1, {-3}}, {}}, {}},
    {"u 2/", {m4two_div, m4bye}, {{1, {5}}, {}}, {{1, {2}}, {}}, {}},
    {"2>r", {m4two_to_r, m4bye}, {{3, {7, 8, 9}}, {1, {0}}}, {{1, {7}}, {3, {0, 8, 9}}}, {}},
    {"2drop", {m4two_drop, m4bye}, {{2, {0, 5}}, {}}, {{}, {}}, {}},
    {"_ 2drop", {m4two_drop, m4bye}, {{3, {-3, -2, -1}}, {}}, {{1, {-3}}, {}}, {}},
    {"2dup", {m4two_dup, m4bye}, {{2, {8, 9}}, {}}, {{4, {8, 9, 8, 9}}, {}}, {}},
    {"2dup2>r", {m4two_dup_two_to_r, m4bye}, {{2, {8, 9}}, {}}, {{2, {8, 9}}, {2, {8, 9}}}, {}},
    {"2nip", {m4two_nip, m4bye}, {{4, {1, 2, 3, 4}}, {}}, {{2, {3, 4}}, {}}, {}},
    {"2over", {m4two_over, m4bye}, {{4, {1, 2, 3, 4}}, {}}, {{6, {1, 2, 3, 4, 1, 2}}, {}}, {}},
    {"2r>", {m4two_r_from, m4bye}, {{1, {0}}, {2, {5, 6}}}, {{3, {0, 5, 6}}, {}}, {}},
    {"2r>2drop", {m4two_r_from_two_drop, m4bye}, {{1, {0}}, {2, {7, 8}}}, {{1, {0}}, {}}, {}},
    {"2r@", {m4two_r_fetch, m4bye}, {{1, {0}}, {2, {9, 10}}}, {{3, {0, 9, 10}}, {2, {9, 10}}}, {}},
    {"2swap", {m4two_swap, m4bye}, {{4, {1, 2, 3, 4}}, {}}, {{4, {3, 4, 1, 2}}, {}}, {}},
    {"3", {m4three, m4bye}, {{}, {}}, {{1, {3}}, {}}, {}},
    {"4", {m4four, m4bye}, {{}, {}}, {{1, {4}}, {}}, {}},
    {"4*", {m4four_times, m4bye}, {{1, {-7}}, {}}, {{1, {-28}}, {}}, {}},
    {"4+", {m4four_plus, m4bye}, {{1, {-7}}, {}}, {{1, {-3}}, {}}, {}},
    {"n 4/", {m4four_div, m4bye}, {{1, {-27}}, {}}, {{1, {-7}}, {}}, {}},
    {"u 4/", {m4four_div, m4bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"5", {m4five, m4bye}, {{}, {}}, {{1, {5}}, {}}, {}},
    {"6", {m4six, m4bye}, {{}, {}}, {{1, {6}}, {}}, {}},
    {"7", {m4seven, m4bye}, {{}, {}}, {{1, {7}}, {}}, {}},
    {"8", {m4eight, m4bye}, {{}, {}}, {{1, {8}}, {}}, {}},
    {"8*", {m4eight_times, m4bye}, {{1, {-3}}, {}}, {{1, {-24}}, {}}, {}},
    {"8+", {m4eight_plus, m4bye}, {{1, {-3}}, {}}, {{1, {5}}, {}}, {}},
    {"n 8/", {m4eight_div, m4bye}, {{1, {-25}}, {}}, {{1, {-4}}, {}}, {}},
    {"u 8/", {m4eight_div, m4bye}, {{1, {31}}, {}}, {{1, {3}}, {}}, {}},
    /*                                                                          */
    {"0 ?dup", {m4question_dup, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"1 ?dup", {m4question_dup, m4bye}, {{1, {1}}, {}}, {{2, {1, 1}}, {}}, {}},
    {"0 abs", {m4abs, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"11 abs", {m4abs, m4bye}, {{1, {11}}, {}}, {{1, {11}}, {}}, {}},
    {"-3 abs", {m4abs, m4bye}, {{1, {-3}}, {}}, {{1, {3}}, {}}, {}},
    {"0 aligned", {m4aligned, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 aligned", {m4aligned, m4bye}, {{1, {1}}, {}}, {{1, {SZ}}, {}}, {}},
    {"SZ 1- aligned", {m4aligned, m4bye}, {{1, {SZ - 1}}, {}}, {{1, {SZ}}, {}}, {}},
    {"0 short-aligned", {m4short_aligned, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 short-aligned", {m4short_aligned, m4bye}, {{1, {1}}, {}}, {{1, {2}}, {}}, {}},
    {"3 short-aligned", {m4short_aligned, m4bye}, {{1, {3}}, {}}, {{1, {4}}, {}}, {}},
    {"0 int-aligned", {m4int_aligned, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 int-aligned", {m4int_aligned, m4bye}, {{1, {1}}, {}}, {{1, {4}}, {}}, {}},
    {"3 int-aligned", {m4int_aligned, m4bye}, {{1, {3}}, {}}, {{1, {4}}, {}}, {}},
    {"and", {m4and, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 & 14}}, {}}, {}},
    {"bl", {m4bl, m4bye}, {{}, {}}, {{1, {' '}}, {}}, {}},
    {"bounds", {m4bounds, m4bye}, {{2, {5, 6}}, {}}, {{2, {11, 5}}, {}}, {}},
    /*                                                                          */
    {"depth", {m4depth, m4bye}, {{}, {}}, {{1, {}}, {}}, {}},
    {"_ depth", {m4depth, m4bye}, {{1, {3}}, {}}, {{2, {3, 1}}, {}}, {}},
    {"_ _ depth", {m4depth, m4bye}, {{2, {3, 4}}, {}}, {{3, {3, 4, 2}}, {}}, {}},
    {"_ drop", {m4drop, m4bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"_ _ drop", {m4drop, m4bye}, {{2, {1, 2}}, {}}, {{1, {1}}, {}}, {}},
    {"dup", {m4dup, m4bye}, {{1, {-5}}, {}}, {{2, {-5, -5}}, {}}, {}},
    {"false", {m4false, m4bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"hop", {m4hop, m4bye}, {{3, {-3, -2, -1}}, {}}, {{4, {-3, -2, -1, -3}}, {}}, {}},
    {"lshift", {m4lshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 << 3}}, {}}, {}},
    {"max", {m4max, m4bye}, {{2, {1, 2}}, {}}, {{1, {2}}, {}}, {}},
    {"min", {m4min, m4bye}, {{2, {3, 4}}, {}}, {{1, {3}}, {}}, {}},
    {"mod", {m4mod, m4bye}, {{2, {20, 7}}, {}}, {{1, {6}}, {}}, {}},
    {"-20 7 mod", {m4mod, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-6}}, {}}, {}},
    {"0 n>drop", {m4n_to_drop, m4bye}, {{1, {0}}, {}}, {{}, {}}, {}},
    {"_ 1 n>drop", {m4n_to_drop, m4bye}, {{2, {-1, 1}}, {}}, {{}, {}}, {}},
    {"_ _ 2 n>drop", {m4n_to_drop, m4bye}, {{3, {-2, -1, 2}}, {}}, {{}, {}}, {}},
    {"negate", {m4negate, m4bye}, {{1, {-12}}, {}}, {{1, {12}}, {}}, {}},
    {"nip", {m4nip, m4bye}, {{2, {3, 4}}, {}}, {{1, {4}}, {}}, {}},
    {"noop", {m4noop, m4bye}, {{}, {}}, {{}, {}}, {}},
    {"-7 14 or", {m4or, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 | 14}}, {}}, {}},
    {"over", {m4over, m4bye}, {{2, {1, 0}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"0 pick", {m4pick, m4bye}, {{2, {-1, 0}}, {}}, {{2, {-1, -1}}, {}}, {}},
    {"1 pick", {m4pick, m4bye}, {{3, {-2, -1, 1}}, {}}, {{3, {-2, -1, -2}}, {}}, {}},
    {"2 pick", {m4pick, m4bye}, {{4, {-3, -2, -1, 2}}, {}}, {{4, {-3, -2, -1, -3}}, {}}, {}},
    {"0 2pick", {m4two_pick, m4bye}, {{3, {-2, -1, 0}}, {}}, {{4, {-2, -1, -2, -1}}, {}}, {}},
    {"1 2pick",
     {m4two_pick, m4bye},
     {{5, {-4, -3, -2, -1, 1}}, {}},
     {{6, {-4, -3, -2, -1, -4, -3}}, {}},
     {}},
    {"2 2pick",
     {m4two_pick, m4bye},
     {{7, {-6, -5, -4, -3, -2, -1, 2}}, {}},
     {{8, {-6, -5, -4, -3, -2, -1, -6, -5}}, {}},
     {}},
    {"0 roll", {m4roll, m4bye}, {{2, {-1, 0}}, {}}, {{1, {-1}}, {}}, {}},
    {"1 roll", {m4roll, m4bye}, {{3, {-2, -1, 1}}, {}}, {{2, {-1, -2}}, {}}, {}},
    {"2 roll", {m4roll, m4bye}, {{4, {-3, -2, -1, 2}}, {}}, {{3, {-2, -1, -3}}, {}}, {}},
    {"3 roll", {m4roll, m4bye}, {{5, {-4, -3, -2, -1, 3}}, {}}, {{4, {-3, -2, -1, -4}}, {}}, {}},
    {"8 roll",
     {m4roll, m4bye},
     {{10, {-9, -8, -7, -6, -5, -4, -3, -2, -1, 8}}, {}},
     {{9, {-8, -7, -6, -5, -4, -3, -2, -1, -9}}, {}},
     {}},
    {"0 -roll", {m4minus_roll, m4bye}, {{2, {-1, 0}}, {}}, {{1, {-1}}, {}}, {}},
    {"1 -roll", {m4minus_roll, m4bye}, {{3, {-2, -1, 1}}, {}}, {{2, {-1, -2}}, {}}, {}},
    {"2 -roll", {m4minus_roll, m4bye}, {{4, {-3, -2, -1, 2}}, {}}, {{3, {-1, -3, -2}}, {}}, {}},
    {"3 -roll",
     {m4minus_roll, m4bye},
     {{5, {-4, -3, -2, -1, 3}}, {}},
     {{4, {-1, -4, -3, -2}}, {}},
     {}},
    {"8 -roll",
     {m4minus_roll, m4bye},
     {{10, {-9, -8, -7, -6, -5, -4, -3, -2, -1, 8}}, {}},
     {{9, {-1, -9, -8, -7, -6, -5, -4, -3, -2}}, {}},
     {}},
    {"0 2roll", {m4two_roll, m4bye}, {{3, {-2, -1, 0}}, {}}, {{2, {-2, -1}}, {}}, {}},
    {"1 2roll",
     {m4two_roll, m4bye},
     {{5, {-4, -3, -2, -1, 1}}, {}},
     {{4, {-2, -1, -4, -3}}, {}},
     {}},
    {"2 2roll",
     {m4two_roll, m4bye},
     {{7, {-6, -5, -4, -3, -2, -1, 2}}, {}},
     {{6, {-4, -3, -2, -1, -6, -5}}, {}},
     {}},
    {"0 -2roll", {m4minus_two_roll, m4bye}, {{3, {-2, -1, 0}}, {}}, {{2, {-2, -1}}, {}}, {}},
    {"1 -2roll",
     {m4minus_two_roll, m4bye},
     {{5, {-4, -3, -2, -1, 1}}, {}},
     {{4, {-2, -1, -4, -3}}, {}},
     {}},
    {"2 -2roll",
     {m4minus_two_roll, m4bye},
     {{7, {-6, -5, -4, -3, -2, -1, 2}}, {}},
     {{6, {-2, -1, -6, -5, -4, -3}}, {}},
     {}},
    {"rot", {m4rot, m4bye}, {{3, {1, 2, 3}}, {}}, {{3, {2, 3, 1}}, {}}, {}},
    {"-rot", {m4minus_rot, m4bye}, {{3, {1, 2, 3}}, {}}, {{3, {3, 1, 2}}, {}}, {}},
    {"2rot", {m4two_rot, m4bye}, {{6, {1, 2, 3, 4, 5, 6}}, {}}, {{6, {3, 4, 5, 6, 1, 2}}, {}}, {}},
    {"-2rot",
     {m4minus_two_rot, m4bye},
     {{6, {1, 2, 3, 4, 5, 6}}, {}},
     {{6, {5, 6, 1, 2, 3, 4}}, {}},
     {}},
    {"rshift", {m4rshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 >> 3}}, {}}, {}},
    {"squared", {m4squared, m4bye}, {{1, {-3}}, {}}, {{1, {9}}, {}}, {}},
    {"sub", {m4sub, m4bye}, {{2, {3, 5}}, {}}, {{1, {2}}, {}}, {}},
    {"swap", {m4swap, m4bye}, {{2, {4, 5}}, {}}, {{2, {5, 4}}, {}}, {}},
    {"trail", {m4trail, m4bye}, {{2, {4, 5}}, {}}, {{3, {4, 4, 5}}, {}}, {}},
    {"true", {m4true, m4bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"tuck", {m4tuck, m4bye}, {{2, {0, 1}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"unloop", {m4unloop, m4bye}, {{}, {3, {1, 2, 3}}}, {{}, {1, {1}}}, {}},
    {"xor", {m4xor, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 ^ 14}}, {}}, {}},
#endif
};

static m4testexecute testexecute_b[] = {
    /*                                                                          */
    {"byte+", {m4byte_plus, m4bye}, {{1, {6}}, {}}, {{1, {7}}, {}}, {}},
    {"char+", {m4char_plus, m4bye}, {{1, {6}}, {}}, {{1, {7}}, {}}, {}},
    {"short+", {m4short_plus, m4bye}, {{1, {12}}, {}}, {{1, {12 + 2}}, {}}, {}},
    {"ushort+", {m4ushort_plus, m4bye}, {{1, {12}}, {}}, {{1, {12 + 2}}, {}}, {}},
    {"int+", {m4int_plus, m4bye}, {{1, {12}}, {}}, {{1, {12 + 4}}, {}}, {}},
    {"uint+", {m4uint_plus, m4bye}, {{1, {12}}, {}}, {{1, {12 + 4}}, {}}, {}},
    {"cell+", {m4cell_plus, m4bye}, {{1, {12}}, {}}, {{1, {12 + SZ}}, {}}, {}},
    {"token+", {m4token_plus, m4bye}, {{1, {12}}, {}}, {{1, {12 + SZt}}, {}}, {}},
    /*                                                                          */
    {"bytes", {m4bytes, m4bye}, {{1, {8}}, {}}, {{1, {8}}, {}}, {}},
    {"chars", {m4chars, m4bye}, {{1, {8}}, {}}, {{1, {8}}, {}}, {}},
    {"shorts", {m4shorts, m4bye}, {{1, {8}}, {}}, {{1, {8 * 2}}, {}}, {}},
    {"ushorts", {m4ushorts, m4bye}, {{1, {8}}, {}}, {{1, {8 * 2}}, {}}, {}},
    {"ints", {m4ints, m4bye}, {{1, {8}}, {}}, {{1, {8 * 4}}, {}}, {}},
    {"uints", {m4uints, m4bye}, {{1, {8}}, {}}, {{1, {8 * 4}}, {}}, {}},
    {"cells", {m4cells, m4bye}, {{1, {3}}, {}}, {{1, {3 * SZ}}, {}}, {}},
    {"tokens", {m4tokens, m4bye}, {{1, {3}}, {}}, {{1, {3 * SZt}}, {}}, {}},
    /*                                                                          */
    {"/byte", {m4div_byte, m4bye}, {{1, {-13}}, {}}, {{1, {-13}}, {}}, {}},
    {"/char", {m4div_char, m4bye}, {{1, {-14}}, {}}, {{1, {-14}}, {}}, {}},
    {"n /short", {m4div_short, m4bye}, {{1, {-15}}, {}}, {{1, {-8}}, {}}, {}},
    {"u /short", {m4div_short, m4bye}, {{1, {15}}, {}}, {{1, {7}}, {}}, {}},
    {"n /ushort", {m4div_ushort, m4bye}, {{1, {-15}}, {}}, {{1, {-8}}, {}}, {}},
    {"u /ushort", {m4div_ushort, m4bye}, {{1, {15}}, {}}, {{1, {7}}, {}}, {}},
    {"n /int", {m4div_int, m4bye}, {{1, {-15}}, {}}, {{1, {-4}}, {}}, {}},
    {"u /int", {m4div_int, m4bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"n /uint", {m4div_uint, m4bye}, {{1, {-15}}, {}}, {{1, {-4}}, {}}, {}},
    {"u /uint", {m4div_uint, m4bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"n /cell", {m4div_cell, m4bye}, {{1, {-13}}, {}}, {{1, {(-13 - SZ + 1) / SZ}}, {}}, {}},
    {"u /cell", {m4div_cell, m4bye}, {{1, {13}}, {}}, {{1, {13 / SZ}}, {}}, {}},
    {"n /token", {m4div_token, m4bye}, {{1, {-13}}, {}}, {{1, {(-13 - SZt + 1) / SZt}}, {}}, {}},
    {"u /token", {m4div_token, m4bye}, {{1, {13}}, {}}, {{1, {13 / SZt}}, {}}, {}},
    /*                                                                          */
    {"n /string",
     {m4div_string, m4bye},
     {{3, {0x7ff123, 1000, -11}}, {}},
     {{2, {0x7ff123 - 11, 1000 + 11}}, {}},
     {}},
    {"u /string",
     {m4div_string, m4bye},
     {{3, {0x8ee321, 1000, 13}}, {}},
     {{2, {0x8ee321 + 13, 1000 - 13}}, {}},
     {}},
    /*                                                                          */
    {"-261 to-byte", {m4to_byte, m4bye}, {{1, {-261}}, {}}, {{1, {(int8_t)-261}}, {}}, {}},
    {"-128 to-byte", {m4to_byte, m4bye}, {{1, {-128}}, {}}, {{1, {-128}}, {}}, {}},
    {"127 to-byte", {m4to_byte, m4bye}, {{1, {127}}, {}}, {{1, {127}}, {}}, {}},
    {"259 to-byte", {m4to_byte, m4bye}, {{1, {259}}, {}}, {{1, {(int8_t)259}}, {}}, {}},
    {"-261 to-char", {m4to_char, m4bye}, {{1, {-261}}, {}}, {{1, {(uint8_t)-261}}, {}}, {}},
    {"-7 to-char", {m4to_char, m4bye}, {{1, {-7}}, {}}, {{1, {(uint8_t)-7}}, {}}, {}},
    {"0 to-char", {m4to_char, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"255 to-char", {m4to_char, m4bye}, {{1, {255}}, {}}, {{1, {255}}, {}}, {}},
    {"259 to-char", {m4to_char, m4bye}, {{1, {259}}, {}}, {{1, {(uint8_t)259}}, {}}, {}},
    {"-54321 to-short", {m4to_short, m4bye}, {{1, {-54321}}, {}}, {{1, {(int16_t)-54321}}, {}}, {}},
    {"-32768 to-short", {m4to_short, m4bye}, {{1, {-32768}}, {}}, {{1, {-32768}}, {}}, {}},
    {"32767 to-short", {m4to_short, m4bye}, {{1, {32767}}, {}}, {{1, {32767}}, {}}, {}},
    {"54321 to-short", {m4to_short, m4bye}, {{1, {54321}}, {}}, {{1, {(int16_t)54321}}, {}}, {}},
    {"-76543 to-ushort",
     {m4to_ushort, m4bye},
     {{1, {-76543}}, {}},
     {{1, {(uint16_t)-76543}}, {}},
     {}},
    {"-11 to-ushort", {m4to_ushort, m4bye}, {{1, {-11}}, {}}, {{1, {(uint16_t)-11}}, {}}, {}},
    {"0 to-ushort", {m4to_ushort, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"65535 to-ushort", {m4to_ushort, m4bye}, {{1, {65535}}, {}}, {{1, {65535}}, {}}, {}},
    {"76543 to-ushort", {m4to_ushort, m4bye}, {{1, {76543}}, {}}, {{1, {(uint16_t)76543}}, {}}, {}},
    {"-9876543210 to-int",
     {m4to_int, m4bye},
     {{1, {-9876543210l}}, {}},
     {{1, {(int32_t)-9876543210l}}, {}},
     {}},
    {"9876543210 to-int",
     {m4to_int, m4bye},
     {{1, {9876543210l}}, {}},
     {{1, {(int32_t)9876543210l}}, {}},
     {}},
    {"-9876543210 to-uint",
     {m4to_uint, m4bye},
     {{1, {-9876543210}}, {}},
     {{1, {(uint32_t)-9876543210l}}, {}},
     {}},
    {"-76543 to-uint", {m4to_uint, m4bye}, {{1, {-76543}}, {}}, {{1, {(uint32_t)-76543}}, {}}, {}},
    {"0 to-uint", {m4to_uint, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"65536 to-uint", {m4to_uint, m4bye}, {{1, {65536}}, {}}, {{1, {65536}}, {}}, {}},
    {"4294967295 to-uint",
     {m4to_uint, m4bye},
     {{1, {4294967295u}}, {}},
     {{1, {4294967295u}}, {}},
     {}},
    {"9876543210 to-uint",
     {m4to_uint, m4bye},
     {{1, {9876543210l}}, {}},
     {{1, {(uint32_t)9876543210l}}, {}},
     {}},
    /* ----------------------------- atomic --------------------------------- */
    {"atomic1+!", {m4dp0, m4atomic_one_plus_store, m4bye}, {{1, {7}}, {}}, {{2, {8, 7}}, {}}, {}},
    {"atomic+!",
     {m4dp0, m4two, m4swap, m4atomic_plus_store, m4bye},
     {{1, {7}}, {}},
     {{2, {9, 7}}, {}},
     {}},
    /* ----------------------------- local ---------------------------------- */
    {"(local-alloc)",
     {m4_local_alloc_, T(3), m4_to_local_0_, m4_to_local_1_, m4_to_local_2_, m4bye},
     {{3, {7, 8, 9}}, {}},
     {{}, {5, {0, 7, 8, 9, 3}}},
     {}},
    {"(local-free)", {m4_local_free_, m4bye}, {{}, {3, {99, 11, 1}}}, {}, {}},
    {"locals",
     {m4_local_alloc_, T(2), m4_to_local_0_, m4_to_local_1_, m4_local_0_, m4_local_1_, m4minus,
      m4_local_free_, m4bye},
     {{2, {8, 3}}, {}},
     {{1, {-5}}, {}},
     {}},
};

static m4testexecute testexecute_c[] = {
    /* ----------------------------- 0<=> ----------------------------------- */
    {"-1 0<", {m4zero_less, m4bye}, {{1, {-1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 0<", {m4zero_less, m4bye}, {{1, {}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0<=", {m4zero_less_equal, m4bye}, {{1, {}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"1 0<=", {m4zero_less_equal, m4bye}, {{1, {1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 0<>", {m4zero_ne, m4bye}, {{1, {-1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 0<>", {m4zero_ne, m4bye}, {{1, {}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 0<>", {m4zero_ne, m4bye}, {{1, {1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 0=", {m4zero_equal, m4bye}, {{1, {-1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0=", {m4zero_equal, m4bye}, {{1, {}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"1 0=", {m4zero_equal, m4bye}, {{1, {1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0>", {m4zero_more, m4bye}, {{1, {}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 0>", {m4zero_more, m4bye}, {{1, {1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 0>=", {m4zero_more_equal, m4bye}, {{1, {-1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 0>=", {m4zero_more_equal, m4bye}, {{1, {}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- <=> ------------------------------------ */
    {"-1 0 <", {m4less, m4bye}, {{2, {-1, 0}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"1 2 <", {m4less, m4bye}, {{2, {1, 2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 3 <", {m4less, m4bye}, {{2, {3, 3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"4 4 <=", {m4less_equal, m4bye}, {{2, {4, 4}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"5 4 <=", {m4less_equal, m4bye}, {{2, {5, 4}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 2 <>", {m4ne, m4bye}, {{2, {1, 2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 3 <>", {m4ne, m4bye}, {{2, {3, 3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 2 =", {m4equal, m4bye}, {{2, {1, 2}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"3 3 =", {m4equal, m4bye}, {{2, {3, 3}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"2 1 >", {m4more, m4bye}, {{2, {2, 1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 3 >", {m4more, m4bye}, {{2, {3, 3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -1 >=", {m4more_equal, m4bye}, {{2, {-2, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -2 >=", {m4more_equal, m4bye}, {{2, {-2, -2}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- u<=> ----------------------------------- */
    {"-1 0 u<", {m4u_less, m4bye}, {{2, {-1, 0}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 -1 u<", {m4u_less, m4bye}, {{2, {0, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -2 u<", {m4u_less, m4bye}, {{2, {-1, -2}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -1 u<", {m4u_less, m4bye}, {{2, {-2, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-3 -3 u<", {m4u_less, m4bye}, {{2, {-3, -3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 0 u<=", {m4u_less_equal, m4bye}, {{2, {-1, 0}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"0 -1 u<=", {m4u_less_equal, m4bye}, {{2, {0, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -2 u<=", {m4u_less_equal, m4bye}, {{2, {-1, -2}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -1 u<=", {m4u_less_equal, m4bye}, {{2, {-2, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-3 -3 u<=", {m4u_less_equal, m4bye}, {{2, {-3, -3}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 0 u>", {m4u_more, m4bye}, {{2, {-1, 0}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 -1 u>", {m4u_more, m4bye}, {{2, {0, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 -2 u>", {m4u_more, m4bye}, {{2, {-1, -2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-2 -1 u>", {m4u_more, m4bye}, {{2, {-2, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-3 -3 u>", {m4u_more, m4bye}, {{2, {-3, -3}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 0 u>=", {m4u_more_equal, m4bye}, {{2, {-1, 0}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"0 -1 u>=", {m4u_more_equal, m4bye}, {{2, {0, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-1 -2 u>=", {m4u_more_equal, m4bye}, {{2, {-1, -2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-2 -1 u>=", {m4u_more_equal, m4bye}, {{2, {-2, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-3 -3 u>=", {m4u_more_equal, m4bye}, {{2, {-3, -3}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- within --------------------------------- */
    {"0 1 4 within", {m4within, m4bye}, {{3, {0, 1, 4}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 1 4 within", {m4within, m4bye}, {{3, {1, 1, 4}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 1 4 within", {m4within, m4bye}, {{3, {3, 1, 4}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"4 1 4 within", {m4within, m4bye}, {{3, {4, 1, 4}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-6 -5 -1 within", {m4within, m4bye}, {{3, {-6, -5, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-5 -5 -1 within", {m4within, m4bye}, {{3, {-5, -5, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-2 -5 -1 within", {m4within, m4bye}, {{3, {-2, -5, -1}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -5 -1 within", {m4within, m4bye}, {{3, {-1, -5, -1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-9 -2 -8 within", {m4within, m4bye}, {{3, {-9, -2, -8}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-8 -2 -8 within", {m4within, m4bye}, {{3, {-8, -2, -8}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-7 -2 -8 within", {m4within, m4bye}, {{3, {-7, -2, -8}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-3 -2 -8 within", {m4within, m4bye}, {{3, {-3, -2, -8}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"-2 -2 -8 within", {m4within, m4bye}, {{3, {-2, -2, -8}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"-1 -2 -8 within", {m4within, m4bye}, {{3, {-1, -2, -8}}, {}}, {{1, {ttrue}}, {}}, {}},
    /* ----------------------------- return stack --------------------------- */
    {">r", {m4to_r, m4bye}, {{1, {99}}, {}}, {{}, {1, {99}}}, {}},
    {"i", {m4i, m4bye}, {{}, {1, {9}}}, {{1, {9}}, {1, {9}}}, {}},
    {"i*", {m4i_times, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {18}}, {1, {9}}}, {}},
    {"i+", {m4i_plus, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {11}}, {1, {9}}}, {}},
    {"i-", {m4i_minus, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {-7}}, {1, {9}}}, {}},
    {"i'", {m4i_prime, m4bye}, {{}, {2, {10, 11}}}, {{1, {10}}, {2, {10, 11}}}, {}},
    {"j", {m4j, m4bye}, {{}, {3, {12, 13, 14}}}, {{1, {12}}, {3, {12, 13, 14}}}, {}},
    {"r@", {m4r_fetch, m4bye}, {{}, {1, {4}}}, {{1, {4}}, {1, {4}}}, {}},
    {"r!", {m4r_store, m4bye}, {{1, {11}}, {1, {0}}}, {{}, {1, {11}}}, {}},
    {"r+!", {m4r_plus_store, m4bye}, {{1, {30}}, {1, {4}}}, {{}, {1, {34}}}, {}},
    {"r>", {m4r_from, m4bye}, {{}, {1, {99}}}, {{1, {99}}, {}}, {}},
    {"dup>r", {m4dup_to_r, m4bye}, {{1, {33}}, {}}, {{1, {33}}, {1, {33}}}, {}},
    {"r>drop", {m4r_from_drop, m4bye}, {{}, {1, {99}}}, {{}, {}}, {}},
    /* ----------------------------- if, else, do, loop --------------------- */
    {"0 1 do", {m4do, m4bye}, {{2, {0, 1}}, {}}, {{}, {2, {0, 1}}}, {}},
    {"1 0 do", {m4do, m4bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"0 0 (?do)", {m4_q_do_, T(0), m4bye}, {{2, {0, 0}}, {}}, {{}, {}}, {}},
    {"1 0 (?do)", {m4_q_do_, T(0), m4bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"0 (?if)", {m4_q_if_, T(1), m4one, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"1 (?if)", {m4_q_if_, T(1), m4two, m4bye}, {{1, {1}}, {}}, {{2, {1, 2}}, {}}, {}},
    {"0 (?if0)", {m4_q_if0_, T(1), m4three, m4bye}, {{1, {0}}, {}}, {{2, {0, 3}}, {}}, {}},
    {"1 (?if0)", {m4_q_if0_, T(1), m4four, m4bye}, {{1, {1}}, {}}, {{1, {1}}, {}}, {}},
    {"0 (if)", {m4_if_, T(1), m4two, m4bye}, {{1, {0}}, {}}, {{}, {}}, {}},
    {"1 (if)", {m4_if_, T(1), m4four, m4bye}, {{1, {1}}, {}}, {{1, {4}}, {}}, {}},
    {"0 (if0)", {m4_if0_, T(1), m4two, m4bye}, {{1, {0}}, {}}, {{1, {2}}, {}}, {}},
    {"1 (if0)", {m4_if0_, T(1), m4three, m4bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"(else) T(0)", {m4_else_, T(0), m4bye, m4_missing_}, {{}, {}}, {{}, {}}, {}},
    {"(else) T(1)", {m4_else_, T(1), m4true, m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(leave)", {m4_leave_, T(0), m4bye}, {{}, {2, {0, 1}}}, {{}, {}}, {}},
    {"0 0 2>r 2 (+loop)",
     {m4_plus_loop_, T(0), m4bye},
     {{1, {2}}, {2, {0, 0}}},
     {{}, {2, {0, 2}}},
     {}},
    {"0 0 2>r -1 (+loop)", {m4_plus_loop_, T(0), m4bye}, {{1, {-1}}, {2, {0, 0}}}, {{}, {}}, {}},
    {"0 1 2>r -1 (+loop)",
     {m4_plus_loop_, T(0), m4bye},
     {{1, {-1}}, {2, {0, 1}}},
     {{}, {2, {0, 0}}},
     {}},
    {"1 0 2>r 1 (+loop)", {m4_plus_loop_, T(0), m4bye}, {{1, {1}}, {2, {1, 0}}}, {{}, {}}, {}},
    {"0 0 2>r (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {0, 0}}}, {{}, {2, {0, 1}}}, {}},
    {"0 1 2>r (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {0, 1}}}, {{}, {2, {0, 2}}}, {}},
    {"1 0 2>r (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {1, 0}}}, {{}, {}}, {}},
    {"10 0 do loop", {m4do, m4_loop_, T(-2), m4bye}, {{2, {10, 0}}, {}}, {{}, {}}, {}},
    {"5 0 do i loop",
     {m4do, m4i, m4_loop_, T(-3), m4bye},
     {{2, {5, 0}}, {}},
     {{5, {0, 1, 2, 3, 4}}, {}},
     {}},
    {"0 1M 0 do i+ loop",
     {m4do, m4i_plus, m4_loop_, T(-3), m4bye},
     {{3, {0, (m4cell)1e6, 0}}, {}},
     {{1, {499999500000l}}, {}},
     {}},
    /* ----------------------------- line  ---------------------------------- */
    {"\"abc\" 'c' line-find-char",
     {m4line_find_char, m4bye},
     {{3, {(m4cell) "abc\nd", 3, 'c'}}, {}},
     {{1, {2}}, {}},
     {}},
    {"\"abc\" 'd' line-find-char",
     {m4line_find_char, m4bye},
     {{3, {(m4cell) "abc\nd", 3, 'd'}}, {}},
     {{1, {3}}, {}},
     {}},
    {"\"abc\\nd\" 'd' line-find-char",
     {m4line_find_char, m4bye},
     {{3, {(m4cell) "abc\nd", 5, 'd'}}, {}},
     {{1, {3}}, {}},
     {}},
    /* ----------------------------- iobuf ---------------------------------- */
    {"iobuf>pos",
     {m4iobuf_pos, m4bye},
     {{1, {0x1000}}, {}},
     {{1, {0x1000 + IOBUF_OFF_POS}}, {}},
     {}},
    {"iobuf>end",
     {m4iobuf_end, m4bye},
     {{1, {0x3000}}, {}},
     {{1, {0x3000 + IOBUF_OFF_END}}, {}},
     {}},
    {"iobuf-refill",
     {m4in_to_ibuf, CALL(ibuf_refill), m4bye},
     {{}, {}},
     {{1, {m4err_unexpected_eof}}, {}},
     {}},
    {"iobuf-find-nonblanks",
     {m4in_to_ibuf, CALL(ibuf_find_nonblanks), m4zero_equal, m4swap, m4in_to_ibuf, m4iobuf_addr,
      m4equal, m4bye},
     {{}, {}},
     {{2, {ttrue, ttrue}}, {}},
     {}},
    {"parse-name",
     {CALL(parse_name), m4zero_equal, m4swap, m4in_to_ibuf, m4iobuf_addr, m4equal, m4bye},
     {{}, {}},
     {{2, {ttrue, ttrue}}, {}},
     {}},
};

#define SH(x, n) ((m4cell)(x) << ((n)*8))

static m4testexecute testexecute_d[] = {
    /* ----------------------------- literal -------------------------------- */
    {"(lit-short) SHORT(7)", {m4_lit_short_, SHORT(7), m4bye}, {{}, {}}, {{1, {7}}, {}}, {}},
    {"(lit-int) INT(0x10000)",
     {m4_lit_int_, INT(0x10000), m4bye},
     {{}, {}},
     {{1, {0x10000}}, {}},
     {}},
    {"(lit-cell) CELL(0x100000000)",
     {m4_lit_cell_, CELL(0x100000000), m4bye},
     {{}, {}},
     {{1, {0x100000000}}, {}},
     {}},
    /* ----------------------------- execute, call -------------------------- */
    {"(call) 'false", {CALL(false), m4bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"(call) 'noop", {CALL(noop), m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(call) 'true", {CALL(true), m4bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"crc+",
     {m4_call_xt_, CELL(crc1byte_code), m4bye},
     {{2, {0xffffffff, 't'}}, {}},
     {{1, {0x1b806fbc /* m4th_crc1byte(0xffffffff, 't')*/}}, {}},
     {}},
    {"crc-cell",
     {m4crc_cell, m4bye},
     {{1,
       {'c' | SH('o', 1) | SH('n', 2) | SH('s', 3) | SH('t', 4) | SH('a', 5) | SH('n', 6) |
        SH('t', 7)}},
      {}},
     {{1, {0x92cfc8c9 /* m4th_crc_string("constant", 8)*/}}, {}},
     {}},
    {"\"constant\" crc-string",
     {m4crc_string, m4bye},
     {{2, {(m4cell) "constant", 8}}, {}},
     {{1, {0x92cfc8c9 /* m4th_crc_string("constant", 8)*/}}, {}},
     {}},
    {"\"immediate\" crc-string",
     {m4crc_string, m4bye},
     {{2, {(m4cell) "immediate", 9}}, {}},
     {{1, {0x5ecabe1c /* m4th_crc_string("immediate", 9)*/}}, {}},
     {}},
    {"(call-native) crc+-native-forth",
     {m4_call_native_, CELL(m4ftest_crc_plus_native_forth), m4bye},
     {{2, {0xffffffff, 't'}}, {}},
     {{1, {0x1b806fbc}}, {}},
     {}},
    {"' one (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4one}}, {}}, {{1, {1}}, {}}, {}},
    {"' noop (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4noop}}, {}}, {{}, {}}, {}},
    {"(exec-xt-from-native)",
     {m4_call_native_, CELL(m4ftest_exec_xt_from_native), m4bye},
     {{1, {DXT(three)}}, {}},
     {{1, {3}}, {}},
     {}},
    /* test that execute on empty stack calls abort */
    {"execute", {m4execute}, {{}, {}}, {{}, {}}, {}},
    /* test that execute detects obviously invalid XT */
    {"0 execute", {m4execute, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"SZ execute", {m4execute, m4bye}, {{1, {SZ}}, {}}, {{1, {SZ}}, {}}, {}},
    {"-SZ execute", {m4execute, m4bye}, {{1, {-SZ}}, {}}, {{1, {-SZ}}, {}}, {}},
    {"0xffff8 execute", {m4execute, m4bye}, {{1, {0xffff8}}, {}}, {{1, {0xffff8}}, {}}, {}},
    {"' ! 1+ execute",
     {m4execute, m4bye},
     {{1, {DXT(store) + 1}}, {}},
     {{1, {DXT(store) + 1}}, {}},
     {}},
    /* test execute of simple words */
    {"' noop execute", {m4execute, m4bye}, {{1, {DXT(noop)}}, {}}, {{}, {}}, {}},
    {"' eight execute", {m4execute, m4bye}, {{1, {DXT(eight)}}, {}}, {{1, {8}}, {}}, {}},
    {"6 7 ' plus execute", {m4execute, m4bye}, {{3, {6, 7, DXT(plus)}}, {}}, {{1, {13}}, {}}, {}},
    {"... ' store execute",
     {m4dp0, m4cell_plus, /* ( 3 d1=7 store &d1 ) */
      m4cell_plus,        /* ( d0=3 7 store &d0 ) */
      m4swap,             /* ( d0=3 7 &d0 store ) */
      m4execute, m4bye},  /* ( 7                ) */
     {{3, {3, 7, DXT(store)}}, {}},
     {{1, {7}}, {}},
     {}},
    {"(ip)", {m4_ip_, m4bye}, {{}, {}}, {{1, {-1 /* fixed by m4testexecute_fix() */}}, {}}, {}},
    {"(lit-string)",
     {m4_ip_, LIT_STRING(3, "abc"), m4minus_rot, m4minus, m4bye},
     {{}, {}},
     {{2, {3, -3 * SZt /*distance between the tokens (ip) and "abc"*/}}, {}},
     {}},
    /* ----------------------------- catch, throw --------------------------- */
    {"' noop catch",
     {m4_catch_beg_, m4_catch_end_, m4bye},
     {{2, {23, DXT(noop)}}, {1, {0xfed1}}},
     {{2, {23, 0}}, {1, {0xfed1}}},
     {}},
    {"' + catch",
     {m4_catch_beg_, m4_catch_end_, m4bye},
     {{4, {13, 15, 17, DXT(plus)}}, {1, {0xfed2}}},
     {{3, {13, 15 + 17, 0}}, {1, {0xfed2}}},
     {}},
    {"0 ' throw catch",
     {m4_catch_beg_, m4_catch_end_, m4bye},
     {{3, {19, 0, DXT(throw)}}, {1, {0xfed3}}},
     {{2, {19, 0}}, {1, {0xfed3}}},
     {}},
    {"1 ' throw catch",
     {m4_catch_beg_, m4_catch_end_, m4bye},
     {{3, {19, 1, DXT(throw)}}, {1, {0xfed4}}},
     {{3, {19, -1 /*clobbered*/, 1}}, {1, {0xfed4}}},
     {}},
    /* ----------------------------- (optimize-literal) --------------------- */
    /* these also test (ip>data) and (ip>data>addr) */
    {"-3 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {-3}}, {}},
     {{2, {-3, tfalse}}, {}},
     {}},
    {"-2 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {-2}}, {}},
     {{2, {m4minus_two, ttrue}}, {}},
     {}},
    {"-1 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {-1}}, {}},
     {{2, {m4minus_one, ttrue}}, {}},
     {}},
    {"0 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {0}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"1 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {1}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"2 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {2}}, {}},
     {{2, {m4two, ttrue}}, {}},
     {}},
    {"3 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {3}}, {}},
     {{2, {m4three, ttrue}}, {}},
     {}},
    {"4 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {4}}, {}},
     {{2, {m4four, ttrue}}, {}},
     {}},
    {"5 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {5}}, {}},
     {{2, {m4five, ttrue}}, {}},
     {}},
    {"8 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {8}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    {"9 (optimize-literal)",
     {CALL(_optimize_literal_), m4bye},
     {{1, {9}}, {}},
     {{2, {9, tfalse}}, {}},
     {}},
};

static const m4token testoptimize_noop[] = {m4noop};
static const m4token testoptimize_zero[] = {m4zero, m4noop};
static const m4token testoptimize_nip_dup[] = {m4nip, m4dup, m4noop};

/* ---------------------- test data for hashmap/cell -------------------- */

static const m4hashmap_cell test_hashmap_cell0 = {
    0 /*size*/, 31 /*lcap*/, NULL /*vec*/
};
static const m4hashmap_entry_cell test_hash_entry_cell0[2] = {
    {2 /*val*/, 1 /*key*/, 3 /*next*/},
    {5 /*val*/, 4 /*key*/, 6 /*next*/},
};
static const m4hashmap_entry_cell test_hash_entry_cell1[8] = {
    {0 /*val*/, 0 /*key*/, -1 /*next*/},    {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {456 /*val*/, -1 /*key*/, -2 /*next*/}, {123 /*val*/, 1 /*key*/, -2 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},    {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},    {0 /*val*/, 0 /*key*/, -1 /*next*/},
};
static const m4hashmap_cell test_hashmap_cell1 = {
    2 /*size*/, 2 /*lcap*/, (m4hashmap_entry_cell *)test_hash_entry_cell1 /*vec*/
};

/* ---------------------- test data for hashmap/int --------------------- */

static const m4hashmap_int test_hashmap_int0 = {
    0 /*size*/, 31 /*lcap*/, NULL /*vec*/
};
static const m4hashmap_entry_int test_hash_entry_int0[2] = {
    {2 /*val*/, 1 /*key*/, 3 /*next*/},
    {5 /*val*/, 4 /*key*/, 6 /*next*/},
};
static const m4hashmap_entry_int test_hash_entry_int1[8] = {
    {654 /*val*/, 3 /*key*/, -2 /*next*/}, {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},   {987 /*val*/, 1 /*key*/, -2 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},   {0 /*val*/, 0 /*key*/, -1 /*next*/},
    {0 /*val*/, 0 /*key*/, -1 /*next*/},   {0 /*val*/, 0 /*key*/, -1 /*next*/},
};
static const m4hashmap_int test_hashmap_int1 = {
    2 /*size*/, 2 /*lcap*/, (m4hashmap_entry_int *)test_hash_entry_int1 /*vec*/
};

/* ---------------------- test data for (optimize-*) --------------------- */

static const m4token tokens__missing_[] = {m4_missing_};
static const m4token tokens_noop[] = {m4noop};
static const m4token tokens_two_drop[] = {m4two_drop};
static const m4token tokens_false[] = {m4false};
static const m4token tokens_one_plus[] = {m4one_plus};
static const m4token tokens_swap_drop[] = {m4swap, m4drop};
static const m4token tokens_ne_zero_more[] = {m4ne, m4zero_more};
static const m4token tokens_r_from_plus_to_r[] = {m4r_from, m4plus, m4to_r};
static const m4token tokens__lit__0xffff_and[] = {m4_lit_, 0xffff, m4and};
/*
 */
static m4testexecute testexecute_e[] = {
    /* ---------------------- hashmap/cell --------------------- */
    {"(hashmap-indexof/cell)",
     {CALL(_hashmap_indexof_cell_), m4bye},
     {{2, {(m4cell)&test_hashmap_cell0, 0x12345678}}, {}},
     {{1, {(0xd45689e5ul ^ (0xd45689e5ul >> 31)) & ((1ul << 31) - 1)}}, {}},
     {}},
    {"(hashmap-entry@/cell)",
     {CALL(_hashmap_entry_fetch_cell_), m4swap, m4fetch, m4swap, m4bye},
     {{2, {(m4cell)&test_hash_entry_cell0, 1}}, {}},
     {{3, {4, 5, 6}}, {}},
     {}},
    {"{1:123, -1:456} 1 hashmap-find/cell",
     {CALL(hashmap_find_cell), m4fetch, m4bye},
     {{2, {(m4cell)&test_hashmap_cell1, 1}}, {}},
     {{2, {1, 123}}, {}},
     {}},
    {"{1:123, -1:456} -1 hashmap-find/cell",
     {CALL(hashmap_find_cell), m4fetch, m4bye},
     {{2, {(m4cell)&test_hashmap_cell1, -1}}, {}},
     {{2, {-1, 456}}, {}},
     {}},
    /* ---------------------- hashmap/int ---------------------- */
    {"(hashmap-indexof/int)",
     {CALL(_hashmap_indexof_int_), m4bye},
     {{2, {(m4cell)&test_hashmap_int0, 0x12345678}}, {}},
     {{1, {(0xd45689e5ul ^ (0xd45689e5ul >> 31)) & ((1ul << 31) - 1)}}, {}},
     {}},
    {"(hashmap-entry@/int)",
     {CALL(_hashmap_entry_fetch_int_), m4swap, m4fetch, m4swap, m4bye},
     {{2, {(m4cell)&test_hash_entry_int0, 1}}, {}},
     {{3, {4, 5, 6}}, {}},
     {}},
    {"{1:987, 3:654} 1 hashmap-find/int",
     {CALL(hashmap_find_int), m4fetch, m4bye},
     {{2, {(m4cell)&test_hashmap_int1, 1}}, {}},
     {{2, {1, 987}}, {}},
     {}},
    {"{1:987, 3:654} 3 hashmap-find/int",
     {CALL(hashmap_find_int), m4fetch, m4bye},
     {{2, {(m4cell)&test_hashmap_int1, 3}}, {}},
     {{2, {3, 654}}, {}},
     {}},
    {"{...} hashmap-find/int",
     {m4name_to_data, m4drop, m4swap, CALL(hashmap_find_int), m4fetch, m4bye},
     {{2, {M4two | (M4pick << 16), (m4cell)&WORD_SYM(_optimize_2token_)}}, {}},
     {{2, {M4two | (M4pick << 16), 1 | (M4hop << 16)}}, {}},
     {}},
    /* ---------------------- optimize* ---------------------- */
    {"{_missing_} (optimize-1token)",
     {CALL(_optimize_1token_), /* ( counted-tokens )                    */
      m4bye},                  /* ( 0 ) i.e. _missing_ is not optimized */
     {{1, {(m4cell)tokens__missing_}}, {}},
     {{1, {0}}, {}},
     {}},
    {"{noop} (optimize-1token)",
     {CALL(_optimize_1token_), /* ( counted-tokens )                       */
      m4token_fetch, m4bye},   /* ( 0 ) i.e. noop optimizes to zero tokens */
     {{1, {(m4cell)tokens_noop}}, {}},
     {{1, {0}}, {}},
     {}},
    {"{2drop} (optimize-1token)",
     {CALL(_optimize_1token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m4bye}, /* (                ) */
     {{1, {(m4cell)tokens_two_drop}}, {}},
     {{}, {}},
     {2, {m4drop, m4drop}}},
    {"{false} (optimize-1token)",
     {CALL(_optimize_1token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m4bye}, /* (                ) */
     {{1, {(m4cell)tokens_false}}, {}},
     {{}, {}},
     {1, {m4zero}}},
    {"{1+} (optimize-1token)",
     {CALL(_optimize_1token_), /* ( counted-tokens ) */
      m4bye},                  /* ( 0 ) i.e. 1+ is not optimized */
     {{1, {(m4cell)tokens_one_plus}}, {}},
     {{1, {0}}, {}},
     {}},
    {"{swap drop} (optimize-2token)",
     {CALL(_optimize_2token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m4bye}, /* (                ) */
     {{1, {(m4cell)tokens_swap_drop}}, {}},
     {{}, {}},
     {1, {m4nip}}},
    {"{<> 0>} (optimize-2token)",
     {CALL(_optimize_2token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m4bye}, /* (                ) */
     {{1, {(m4cell)tokens_ne_zero_more}}, {}},
     {{}, {}},
     {3, {m4drop, m4drop, m4zero}}},
    {"{r> + >r} (optimize-3token)",
     {CALL(_optimize_3token_),           /* ( counted-tokens ) */
      CALL(countedtokens_comma), m4bye}, /* (                ) */
     {{1, {(m4cell)tokens_r_from_plus_to_r}}, {}},
     {{}, {}},
     {1, {m4r_plus_store}}},
    {"{_missing_} 1 (optimize-tokens)",
     {CALL(_optimize_tokens_), m4bye}, /* ( counted-tokens u' ) */
     {{2, {(m4cell)tokens__missing_, 1}}, {}},
     {{2, {0, 0}}, {}},
     {}},
    {"{false} 1 (optimize-tokens)",
     {CALL(_optimize_tokens_),                   /* ( counted-tokens u' ) */
      m4swap, CALL(countedtokens_comma), m4bye}, /* ( u'                ) */
     {{2, {(m4cell)tokens_false, 1}}, {}},
     {{1, {1}}, {}},
     {1, {m4zero}}},
    {"{swap drop} 2 (optimize-tokens)",
     {CALL(_optimize_tokens_),                   /* ( counted-tokens u' ) */
      m4swap, CALL(countedtokens_comma), m4bye}, /* ( u'                ) */
     {{2, {(m4cell)tokens_swap_drop, 2}}, {}},
     {{1, {2}}, {}},
     {1, {m4nip}}},
    {"{$ffff and} (optimize-tokens)",
     {CALL(_optimize_tokens_),                   /* ( counted-tokens u' ) */
      m4swap, CALL(countedtokens_comma), m4bye}, /* ( u'                ) */
     {{2, {(m4cell)tokens__lit__0xffff_and, 3}}, {}},
     {{1, {3}}, {}},
     {1, {m4to_ushort}}},
    {"(optimize-tokens,)",
     {m4token_comma, m4token_comma, m4state, m4fetch, m4dup, m4two, /* ( xt xt  u  ) */
      CALL(_optimize_tokens_comma_),                                /* ( xt xt' u' ) */
      m4minus_rot, m4sub, m4bye},                                   /* ( u' xt'-xt ) */
     {{2, {m4minus, m4one}}, {}},
     {{2, {0, 4}}, {}},
     {3, {m4one, m4minus, /* followed by optimized sequence */ m4one_minus}}},
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

#define TESTSTR_n(name, n, ...) ((m4cell)(teststr##name + n)), (sizeof(teststr##name) - n - 1)
#define TESTSTR(...) TESTSTR_n(__VA_ARGS__, 0)

static m4testexecute testexecute_f[] = {
    /* ----------------------------- base ----------------------------------- */
    {"base @", {m4base, m4fetch, m4bye}, {{}, {}}, {{1, {10}}, {}}, {}},
    {"hex", {CALL(hex), m4base, m4fetch, m4bye}, {{}, {}}, {{1, {16}}, {}}, {}},
    {"decimal", {CALL(decimal), m4base, m4fetch, m4bye}, {{}, {}}, {{1, {10}}, {}}, {}},
    /* ----------------------------- char>base ------------------------------ */
    {"'#' char>base", {CALL(char_to_base), m4bye}, {{1, {'#'}}, {}}, {{1, {10}}, {}}, {}},
    {"'$' char>base", {CALL(char_to_base), m4bye}, {{1, {'$'}}, {}}, {{1, {16}}, {}}, {}},
    {"'%' char>base", {CALL(char_to_base), m4bye}, {{1, {'%'}}, {}}, {{1, {2}}, {}}, {}},
    {"'&' char>base", {CALL(char_to_base), m4bye}, {{1, {'&'}}, {}}, {{1, {0}}, {}}, {}},
    {"'\"' char>base", {CALL(char_to_base), m4bye}, {{1, {'"'}}, {}}, {{1, {0}}, {}}, {}},
    /* ----------------------------- string>base ---------------------------- */
    {"\"\" string>base",
     {CALL(string_to_base), m4bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{3, {TESTSTR(_empty), 10}}, {}},
     {}},
    {"\"#\" string>base",
     {CALL(string_to_base), m4bye},
     {{2, {TESTSTR(_hash)}}, {}},
     {{3, {TESTSTR(_hash, 1), 10}}, {}},
     {}},
    {"\"$\" string>base",
     {CALL(string_to_base), m4bye},
     {{2, {TESTSTR(_dollar)}}, {}},
     {{3, {TESTSTR(_dollar, 1), 16}}, {}},
     {}},
    {"\"%\" string>base",
     {CALL(string_to_base), m4bye},
     {{2, {TESTSTR(_percent)}}, {}},
     {{3, {TESTSTR(_percent, 1), 2}}, {}},
     {}},
    {"\"0\" string>base",
     {CALL(string_to_base), m4bye},
     {{2, {TESTSTR(_0)}}, {}},
     {{3, {TESTSTR(_0), 10}}, {}},
     {}},
    /* ----------------------------- string>char ---------------------------- */
    {"\"''\" string>char",
     {CALL(string_to_char), m4bye},
     {{2, {TESTSTR(_quoted)}}, {}},
     {{3, {TESTSTR(_quoted), -1}}, {}},
     {}},
    {"\"'x'\" string>char",
     {CALL(string_to_char), m4bye},
     {{2, {TESTSTR(_quoted_x)}}, {}},
     {{3, {TESTSTR(_quoted_x, 3), 'x'}}, {}},
     {}},
    {"\"(y'\" string>char",
     {CALL(string_to_char), m4bye},
     {{2, {TESTSTR(_lparen_y_quote)}}, {}},
     {{3, {TESTSTR(_lparen_y_quote), -1}}, {}},
     {}},
    {"\"'z)\" string>char",
     {CALL(string_to_char), m4bye},
     {{2, {TESTSTR(_quote_z_rparen)}}, {}},
     {{3, {TESTSTR(_quote_z_rparen), -1}}, {}},
     {}},
    {"\"'00'\" string>char",
     {CALL(string_to_char), m4bye},
     {{2, {TESTSTR(_quoted_00)}}, {}},
     {{3, {TESTSTR(_quoted_00), -1}}, {}},
     {}},
    /* ----------------------------- string>lower --------------------------- */
    {"\"abc\" string>lower",
     {m4zero, m4minus_rot, m4dp0, m4cell_plus, m4cell_plus, m4swap, m4string_to_lower, m4two_drop,
      m4bye},
     {{2, {TESTSTR(_abc)}}, {}},
#if __BYTE_ORDER == __BIG_ENDIAN
     {{1, {'a' << 16 | 'b' << 8 | 'c'}}, {}},
#else
     {{1, {'a' | 'b' << 8 | 'c' << 16}}, {}},
#endif /* __BYTE_ORDER */
     {}},
#if SZ >= 8
    {"\"aBcDefGH\" string>lower",
     {m4zero, m4minus_rot, m4dp0, m4cell_plus, m4cell_plus, m4swap, m4string_to_lower, m4two_drop,
      m4bye},
     {{2, {TESTSTR(_aBcDefGH)}}, {}},
#if __BYTE_ORDER == __BIG_ENDIAN
     {{1,
       {(m4cell)('a' << 24 | 'b' << 16 | 'c' << 8 | 'd') << 32 |
        ('e' << 24 | 'f' << 16 | 'g' << 8 | 'h')}},
#else
     {{1,
       {'a' | 'b' << 8 | 'c' << 16 | 'd' << 24 |
        (m4cell)('e' | 'f' << 8 | 'g' << 16 | 'h' << 24) << 32}},
#endif /* __BYTE_ORDER */
      {}},
     {}},
#endif /* SZ */
    /* ----------------------------- string>sign ---------------------------- */
    {"\"\" string>sign",
     {CALL(string_to_sign), m4bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{3, {TESTSTR(_empty), 1}}, {}},
     {}},
    {"\"0\" string>sign",
     {CALL(string_to_sign), m4bye},
     {{2, {TESTSTR(_0)}}, {}},
     {{3, {TESTSTR(_0), 1}}, {}},
     {}},
    {"\"-123\" string>sign",
     {CALL(string_to_sign), m4bye},
     {{2, {TESTSTR(_minus_123)}}, {}},
     {{3, {TESTSTR(_minus_123, 1), -1}}, {}},
     {}},
    /* ----------------------------- char>u --------------------------------- */
    {"'/' char>u", {CALL(char_to_u), m4bye}, {{1, {'/'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'0' char>u", {CALL(char_to_u), m4bye}, {{1, {'0'}}, {}}, {{1, {0}}, {}}, {}},
    {"'9' char>u", {CALL(char_to_u), m4bye}, {{1, {'9'}}, {}}, {{1, {9}}, {}}, {}},
    {"':' char>u", {CALL(char_to_u), m4bye}, {{1, {':'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'@' char>u", {CALL(char_to_u), m4bye}, {{1, {'@'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'A' char>u", {CALL(char_to_u), m4bye}, {{1, {'A'}}, {}}, {{1, {10}}, {}}, {}},
    {"'Z' char>u", {CALL(char_to_u), m4bye}, {{1, {'Z'}}, {}}, {{1, {35}}, {}}, {}},
    {"'[' char>u", {CALL(char_to_u), m4bye}, {{1, {'['}}, {}}, {{1, {-1}}, {}}, {}},
    {"'`' char>u", {CALL(char_to_u), m4bye}, {{1, {'`'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'a' char>u", {CALL(char_to_u), m4bye}, {{1, {'a'}}, {}}, {{1, {10}}, {}}, {}},
    {"'z' char>u", {CALL(char_to_u), m4bye}, {{1, {'z'}}, {}}, {{1, {35}}, {}}, {}},
    {"'{' char>u", {CALL(char_to_u), m4bye}, {{1, {'{'}}, {}}, {{1, {-1}}, {}}, {}},
    /* ----------------------------- valid-base? ---------------------------- */
    {"0 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {0}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"2 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {3}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"10 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {10}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"16 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {16}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"35 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {35}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"36 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {36}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"37 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {37}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"38 valid-base?", {CALL(valid_base_q), m4bye}, {{1, {38}}, {}}, {{1, {tfalse}}, {}}, {}},
    /* ----------------------------- string&base>u -------------------------- */
    {"\"\" 10 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_empty), 10}}, {}},
     {{3, {TESTSTR(_empty), 0}}, {}},
     {}},
    {"\"1011\" 2 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_percent_1011, 1), 2}}, {}},
     {{3, {TESTSTR(_percent_1011, 5), 0xb}}, {}},
     {}},
    {"\"12345a\" 2 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_dollar_12345a, 1), 2}}, {}},
     {{3, {TESTSTR(_dollar_12345a, 2), 0x1}}, {}},
     {}},
    {"\"12345a\" 10 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_dollar_12345a, 1), 10}}, {}},
     {{3, {TESTSTR(_dollar_12345a, 6), 12345}}, {}},
     {}},
    {"\"1234567890\" 10 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_1234567890), 10}}, {}},
     {{3, {TESTSTR(_1234567890, 10), 1234567890}}, {}},
     {}},
    {"\"4294967295\" 10 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_4294967295), 10}}, {}},
     {{3, {TESTSTR(_4294967295, 10), (m4cell)4294967295ul}}, {}},
     {}},
    {"\"12345a\" 16 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_dollar_12345a, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_12345a, 7), 0x12345a}}, {}},
     {}},
    {"\"123defg\" 16 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_dollar_123defg, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_123defg, 7), 0x123def}}, {}},
     {}},
    {"\"ffffffff\" 16 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_dollar_ffffffff, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_ffffffff, 9), (m4cell)0xfffffffful}}, {}},
     {}},
#if SZ >= 8
    {"\"18446744073709551615\" 10 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_18446744073709551615), 10}}, {}},
     {{3, {TESTSTR(_18446744073709551615, 20), (m4cell)18446744073709551615ul}}, {}},
     {}},
    {"\"ffffffffffffffff\" 16 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_dollar_ffffffffffffffff, 1), 16}}, {}},
     {{3, {TESTSTR(_dollar_ffffffffffffffff, 17), (m4cell)0xfffffffffffffffful}}, {}},
     {}},
#endif /* SZ >= 8 */
    {"\"0az\" 36 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_0az), 36}}, {}},
     {{3, {TESTSTR(_0az, 3), 395}}, {}},
     {}},
    {"\"z:\" 36 string&base>u",
     {CALL(string_base_to_u), m4bye},
     {{3, {TESTSTR(_z_), 36}}, {}},
     {{3, {TESTSTR(_z_, 1), 35}}, {}},
     {}},
    /* ----------------------------- string>number -------------------------- */
    {"\"\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{2, {0, tfalse}}, {}},
     {}},
    {"\"12345a\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_dollar_12345a, 1)}}, {}},
     {{2, {12345, tfalse}}, {}},
     {}},
    {"\"1234567890\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_1234567890)}}, {}},
     {{2, {1234567890, ttrue}}, {}},
     {}},
    {"\"4294967295\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_4294967295)}}, {}},
     {{2, {(m4cell)4294967295ul, ttrue}}, {}},
     {}},
    {"\"%1011\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_percent_1011)}}, {}},
     {{2, {0xb, ttrue}}, {}},
     {}},
    {"\"$12345a\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_dollar_12345a)}}, {}},
     {{2, {0x12345a, ttrue}}, {}},
     {}},
    {"\"$123defg\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_dollar_123defg)}}, {}},
     {{2, {0x123def, tfalse}}, {}},
     {}},
    {"\"$ffffffff\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_dollar_ffffffff)}}, {}},
     {{2, {(m4cell)0xfffffffful, ttrue}}, {}},
     {}},
#if SZ >= 8
    {"\"18446744073709551615\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_18446744073709551615)}}, {}},
     {{2, {(m4cell)18446744073709551615ul, ttrue}}, {}},
     {}},
    {"\"$ffffffffffffffff\" string>number",
     {CALL(string_to_number), m4bye},
     {{2, {TESTSTR(_dollar_ffffffffffffffff), 16}}, {}},
     {{2, {(m4cell)0xfffffffffffffffful, ttrue}}, {}},
     {}},
#endif
    /* ----------------------------- string= -------------------------------- */
    {"\"abcdefg\" \"abcdefg\" string=",
     {CALL(string_equal), m4bye},
     {{3, {(m4cell) "abcdefgh0", (m4cell) "abcdefgh1", 7}}, {}},
     {{4, {(m4cell) "abcdefgh0", (m4cell) "abcdefgh1", 7, ttrue}}, {}},
     {}},
    {"\"abcdefgh\" \"abcdefgh\" string=",
     {CALL(string_equal), m4bye},
     {{3, {(m4cell) "abcdefgh0", (m4cell) "abcdefgh1", 8}}, {}},
     {{4, {(m4cell) "abcdefgh0", (m4cell) "abcdefgh1", 8, ttrue}}, {}},
     {}},
    {"\"abcdefgh0\" \"abcdefgh1\" string=",
     {CALL(string_equal), m4bye},
     {{3, {(m4cell) "abcdefgh0", (m4cell) "abcdefgh1", 9}}, {}},
     {{4, {(m4cell) "abcdefgh0", (m4cell) "abcdefgh1", 9, tfalse}}, {}},
     {}},
    /* ----------------------------- string-ci= ----------------------------- */
    {"\"ex-message@\" \"ex-message!\" string-ci=",
     {CALL(string_ci_equal), m4bye},
     {{3, {(m4cell) "ex-message@", (m4cell) "ex-message!", 11}}, {}},
     {{4, {(m4cell) "ex-message@", (m4cell) "ex-message!", 11, tfalse}}, {}},
     {}},
    {"\"abcdef@\" \"abcdef@\" string-ci=",
     {CALL(string_ci_equal), m4bye},
     {{3, {(m4cell) "abcdef@+", (m4cell) "abcdef@+ ", 8}}, {}},
     {{4, {(m4cell) "abcdef@+", (m4cell) "abcdef@+ ", 8, ttrue}}, {}},
     {}},
    {"\"abcdef@\" \"abCdeF@\" string-ci=",
     {CALL(string_ci_equal), m4bye},
     {{3, {(m4cell) "abcdef@+", (m4cell) "abCdeF@", 7}}, {}},
     {{4, {(m4cell) "abcdef@+", (m4cell) "abCdeF@", 7, ttrue}}, {}},
     {}},
    {"\"abcdef@+\" \"abCdeF`+\" string-ci=",
     {CALL(string_ci_equal), m4bye},
     {{3, {(m4cell) "abcdef@+", (m4cell) "abCdeF`+", 8}}, {}},
     {{4, {(m4cell) "abcdef@+", (m4cell) "abCdeF`+", 8, tfalse}}, {}},
     {}},
    {"NULL string-find-blank",
     {CALL(string_find_blank), m4bye},
     {{2, {(m4cell)NULL, 0}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" \" string-find-blank",
     {CALL(string_find_blank), m4bye},
     {{2, {(m4cell) " ", 1}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\"x\" string-find-blank",
     {CALL(string_find_blank), m4bye},
     {{2, {(m4cell) "x", 1}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\"yz \" string-find-blank",
     {CALL(string_find_blank), m4bye},
     {{2, {(m4cell) "yz =", 3}}, {}},
     {{1, {2}}, {}},
     {}},
    {"\"yz =\" string-find-blank",
     {CALL(string_find_blank), m4bye},
     {{2, {(m4cell) "yz =", 4}}, {}},
     {{1, {2}}, {}},
     {}},
    {"NULL '.' string-find-char",
     {CALL(string_find_char), m4bye},
     {{3, {(m4cell)NULL, 0, '.'}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" \" '.' string-find-char",
     {CALL(string_find_char), m4bye},
     {{3, {(m4cell) " ", 1, '.'}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\" yz \" 'z' string-find-char",
     {CALL(string_find_char), m4bye},
     {{3, {(m4cell) " yz =", 4, 'z'}}, {}},
     {{1, {2}}, {}},
     {}},
    {"\"\r\n \" bl string-find-char",
     {CALL(string_find_char), m4bye},
     {{3, {(m4cell) " \r\n " + 1, 3, ' '}}, {}},
     {{1, {2}}, {}},
     {}},
    {"NULL string-find-nonblank",
     {CALL(string_find_nonblank), m4bye},
     {{2, {(m4cell)0, 0}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" \" string-find-nonblank",
     {CALL(string_find_nonblank), m4bye},
     {{2, {(m4cell) " ", 1}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\"x\" string-find-nonblank",
     {CALL(string_find_nonblank), m4bye},
     {{2, {(m4cell) "x", 1}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" yz \" string-find-nonblank",
     {CALL(string_find_nonblank), m4bye},
     {{2, {(m4cell) " yz =", 4}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\" \r\n \" string-find-nonblank",
     {CALL(string_find_nonblank), m4bye},
     {{2, {(m4cell) " \r\n ", 4}}, {}},
     {{1, {4}}, {}},
     {}},
    /* ---------------------------- cmove, move ----------------------------- */
    {"cmove",
     {m4dp0, m4one_plus, m4dup, m4cell_plus, m4two, m4cmove, m4bye},
     {{2, {0, 'a' | 'b' << 8 | 'c' << 16 | 'd' << 24}}, {}},
     {{2, {'b' << 8 | 'c' << 16, 'a' | 'b' << 8 | 'c' << 16 | 'd' << 24}}, {}},
     {}},
    {"cmove \\ with copy propagation",
     {m4dp0, m4dup, m4one_plus, m4two, m4cmove, m4bye},
     {{1, {'w' | 'x' << 8 | 'y' << 16 | 'z' << 24}}, {}},
     {{1, {'w' | 'w' << 8 | 'w' << 16 | 'z' << 24}}, {}},
     {}},
    {"move",
     {m4dp0, m4dup, m4four, m4cells, m4plus, m4three, m4move, m4bye},
     {{8, {-4, -3, -2, -1, 0, 11, 12, 13}}, {}},
     {{8, {-4, 11, 12, 13, 0, 11, 12, 13}}, {}},
     {}},
    {"move \\ overlapping source and destination",
     {m4dp0, m4cell_plus, m4dup, m4cell_plus, m4swap, m4_lit_, T(5), m4move, m4bye},
     {{8, {0, 1, 2, 3, 4, 5, 6, 7}}, {}},
     {{8, {0, 1, 1, 2, 3, 4, 5, 7}}, {}},
     {}},

};

static void test_noop(void) {
}

static m4cell test_negate(m4cell a) {
    return -a;
}

typedef struct {
    m4cell a, b;
} sum_triplets_ret;

static sum_triplets_ret test_sum_triplets(m4cell a, m4cell b, m4cell c, m4cell d, m4cell e,
                                          m4cell f) {
    sum_triplets_ret ret = {a + b + c, d + e + f};
    return ret;
}

static m4testexecute testexecute_g[] = {
    /* ----------------------------- (c-call) --------------------------------- */
    {"(c-call) test_noop",
     {m4_c_arg_0_, m4_c_call_, CELL(test_noop), m4_c_ret_0_, m4bye},
     {{}, {}},
     {{}, {}},
     {}},
    {"(c-call) test_negate",
     {m4_c_arg_1_, m4_c_call_, CELL(test_negate), m4_c_ret_1_, m4bye},
     {{1, {9}}, {}},
     {{1, {-9}}, {}},
     {}},
    {"(c-call) test_sum_triplets",
     {m4_c_arg_6_, m4_c_call_, CELL(test_sum_triplets), m4_c_ret_2_, m4bye},
     {{6, {1, 2, 3, 4, 5, 6}}, {}},
     {{2, {6, 15}}, {}},
     {}},
    /* ----------------------------- comma... ------------------------------- */
    {"0x123 token,", {m4token_comma, m4bye}, {{1, {0x123}}, {}}, {{}, {}}, {1, {0x123}}},
    {"(lit,) T(500) [#compiled]",
     {m4_num_compiled_, m4_lit_comma_, T(500), m4_num_compiled_, m4bye},
     {{}, {}},
     {{2, {0, 1}}, {}},
     {1, {500}}},
    {"0xcdef short,",
     {m4_num_compiled_, m4swap, m4short_comma, m4_num_compiled_, m4bye},
     {{1, {0xcdef}}, {}},
     {{2, {0, 1}}, {}},
     {1, {0xcdef}}},
#if __BYTE_ORDER == __LITTLE_ENDIAN
    {"1 c, 2 c,", {m4c_comma, m4c_comma, m4bye}, {{2, {2, 1}}, {}}, {{}, {}}, {1, {0x0201}}},
#if SZt == 2
    {"0x12345678 int,",
     {m4int_comma, m4bye},
     {{1, {0x12345678}}, {}},
     {{}, {}},
     {2, {0x5678, 0x1234}}},
#define P(a, b) ((a) | ((b) << 8))
    {"\"foo\" 3 countedstring,",
     {m4countedstring_comma, m4bye},
     {{2, {(m4cell) "foobarbaz", 3}}, {}},
     {{}, {}},
     {2, {P(3, 'f'), P('o', 'o')}}},
    {"\"foobarbaz\" 9 countedstring,",
     {m4countedstring_comma, m4bye},
     {{2, {(m4cell) "foobarbaz", 9}}, {}},
     {{}, {}},
     {5, {P(9, 'f'), P('o', 'o'), P('b', 'a'), P('r', 'b'), P('a', 'z')}}},
    {"\"foobar\" 6 compile-string,",
     {CALL(compile_string_comma), m4bye},
     {{2, {(m4cell) "foobarbaz", 6}}, {}},
     {{}, {}},
     {3, {LIT_STRING(6, "foobar")}}},
#undef P
#if SZ == 8
    {"0x08090a0b0c0d0e0f ,",
     {m4comma, m4_num_compiled_, m4bye},
     {{1, {0x08090a0b0c0d0e0f}}, {}},
     {{1, {SZ / SZt}}, {}},
     {4, {0x0e0f, 0x0c0d, 0x0a0b, 0x0809}}},
#elif SZ == 4
    {"0x0c0d0e0f ,", {m4comma, m4bye}, {{1, {0x0c0d0e0f}}, {}}, {{}, {}}, {2, {0x0e0f, 0x0c0d}}},
#endif /* SZ */
#endif /* SZt == 2 */
#endif /* __BYTE_ORDER */
    {"\"\" 0 name,",
     {m4name_comma, m4here, m4minus, m4bye},
     {{2, {(m4cell) "bar", 0}}, {}},
     {{1, {-WORD_OFF_XT}}, {}},
     {}},
    {";", {CALL(semi), m4bye}, {{2, {0, m4colon}}, {}}, {{}, {}}, {1, {m4exit}}},
    /* ----------------------------- search order --------------------------- */
    {"get-current", {m4get_current, m4bye}, {{}, {}}, {{1, {(m4cell)&m4wordlist_forth}}, {}}, {}},
    {"set-current",
     {m4get_current, m4swap, m4set_current, m4get_current, m4swap, m4set_current, m4bye},
     {{1, {(m4cell)&m4wordlist_m4th_impl}}, {}},
     {{1, {(m4cell)&m4wordlist_m4th_impl}}, {}},
     {}},
    /* ----------------------------- flags ---------------------------------- */
    {"ip_2 flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m4bye},
     {{1, {m4flag_consumes_ip_2}}, {}},
     {{1, {2 / SZt}}, {}},
     {}},
    {"ip_4 flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m4bye},
     {{1, {m4flag_consumes_ip_4}}, {}},
     {{1, {4 / SZt}}, {}},
     {}},
    {"ip_8 flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m4bye},
     {{1, {m4flag_consumes_ip_8}}, {}},
     {{1, {8 / SZt}}, {}},
     {}},
    {"_ flags>consumed-tokens",
     {CALL(flags_to_consumed_tokens), m4bye},
     {{1, {m4flag_mem_fetch}}, {}},
     {{1, {0}}, {}},
     {}},
    /* ----------------------------- name ------------------------------- */
    {"name>flags",
     {CALL(name_to_flags), m4bye},
     {{1, {(m4cell)&WORD_SYM(noop)}}, {}},
     {{1, {WORD_PURE}}, {}},
     {}},
    {"name>code",
     {m4name_to_code, m4bye},
     {{1, {(m4cell)&WORD_SYM(noop)}}, {}},
     {{2, {DXT(noop), 2}}, {}},
     {}},
    {"name>data",
     {m4name_to_data, m4bye},
     {{1, {(m4cell)&WORD_SYM(dup)}}, {}},
     {{2, {(m4cell)&WORD_SYM(dup) + 32, 0}}, {}},
     {}},
    {"name>string",
     {m4name_to_string, m4bye},
     {{1, {(m4cell)&WORD_SYM(mod)}}, {}},
     {{2, {(m4cell)NULL /* fixed by m4testexecute_fix() */, 3}}, {}},
     {}},
    {"name>prev",
     {m4name_to_prev, m4bye},
     {{1, {(m4cell)&WORD_SYM(plus_store)}}, {}},
     {{1, {(m4cell)&WORD_SYM(plus)}}, {}},
     {}},
    {"name>xt",
     {m4name_to_xt, m4bye},
     {{1, {(m4cell)&WORD_SYM(dup)}}, {}},
     {{1, {DXT(dup)}}, {}},
     {}},
    {"token>name",
     {m4token_to_name, m4bye},
     {{1, {m4dup}}, {}},
     {{1, {(m4cell)&WORD_SYM(dup)}}, {}},
     {}},
    /* ----------------------------- wordlist ------------------------------- */
    {"wordlist-last-name",
     {m4wordlist_last_name, m4bye},
     {{1, {(m4cell)&m4wordlist_forth}}, {}},
     {{1, {(m4cell)&WORD_SYM(cmove)}}, {}},
     {}},
    {"\"dup\" wordlist-find",
     {CALL(wordlist_find), m4bye},
     {{3, {(m4cell) "dup", 3, (m4cell)&m4wordlist_forth}}, {}},
     {{2, {(m4cell)&WORD_SYM(dup), ttrue}}, {}},
     {}},
    {"\"0az\" wordlist-find",
     {CALL(wordlist_find), m4bye},
     {{3, {TESTSTR(_0az), (m4cell)&m4wordlist_forth}}, {}},
     {{2, {0, 0}}, {}},
     {}},
    {"\"ex-message!\" wordlist-find",
     {CALL(wordlist_find), m4bye},
     {{3, {(m4cell) "ex-message!", 11, (m4cell)&m4wordlist_m4th_user}}, {}},
     {{2, {(m4cell)&WORD_SYM(ex_message_store), ttrue}}, {}},
     {}},
    {"\"dup\" search-wordlist",
     {CALL(search_wordlist), m4bye},
     {{3, {(m4cell) "dup", 3, (m4cell)&m4wordlist_forth}}, {}},
     {{2, {DXT(dup), ttrue}}, {}},
     {}},
    {"\"if\" search-wordlist",
     {CALL(search_wordlist), m4bye},
     {{3, {(m4cell) "if", 2, (m4cell)&m4wordlist_forth}}, {}},
     {{2, {DXT(if), 1}}, {}},
     {}},
    {"\"0az\" search-wordlist",
     {CALL(search_wordlist), m4bye},
     {{3, {TESTSTR(_0az), (m4cell)&m4wordlist_forth}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\"?do\" string>name",
     {CALL(string_to_name), m4bye},
     {{2, {(m4cell) "?do", 3}}, {}},
     {{3, {(m4cell)&WORD_SYM(question_do), (m4cell)&m4wordlist_forth, 1}}, {}},
     {}},
    {"\"0az\" string>name",
     {CALL(string_to_name), m4bye},
     {{2, {TESTSTR(_0az)}}, {}},
     {{3, {0, 0, 0}}, {}},
     {}},
    /* --------------------------- search order ----------------------------- */
    {"get-order",
     {CALL(get_order), m4bye},
     {{}, {}},
     {{4, {(m4cell)&m4wordlist_m4th_user, (m4cell)&m4wordlist_forth, (m4cell)&m4wordlist_forth, 3}},
      {}},
     {}},
    {"' (if) name-inline?",
     {CALL(name_inline_query), m4bye},
     {{1, {(m4cell)&WORD_SYM(_if_)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' + name-inline?",
     {CALL(name_inline_query), m4bye},
     {{1, {(m4cell)&WORD_SYM(plus)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' if name-inline?",
     {CALL(name_inline_query), m4bye},
     {{1, {(m4cell)&WORD_SYM(if)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' noop name-inline?",
     {CALL(name_inline_query), m4bye},
     {{1, {(m4cell)&WORD_SYM(noop)}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' literal name-inline?",
     {CALL(name_inline_query), m4bye},
     {{1, {(m4cell)&WORD_SYM(literal)}}, {}},
     {{1, {tfalse}}, {}},
     {}},
    {"' name-inline? name-inline?",
     {CALL(name_inline_query), m4bye},
     {{1, {(m4cell)&WORD_SYM(name_inline_query)}}, {}},
     {{1, {tfalse}}, {}},
     {}},
    {"' + [inline]",
     {CALL(_inline_), m4bye},
     {{1, {(m4cell)&WORD_SYM(plus)}}, {}},
     {{}, {}},
     {1, {m4plus}}},
    {"' 1 [inline] ' 3 [inline] ' + [inline]",
     {CALL(_inline_), CALL(_inline_), CALL(_inline_), m4bye},
     {{3, {(m4cell)&WORD_SYM(plus), (m4cell)&WORD_SYM(three), (m4cell)&WORD_SYM(one)}}, {}},
     {{}, {}},
     {3, {m4one, m4three, m4plus}}},
    /* ----------------------------- compile, ------------------------------- */
    {"' noop compile,",
     {CALL(compile_comma), m4bye},
     {{1, {DXT(noop)}}, {}},
     {{}, {}},
     {1, {m4noop}}},
    {"' 1+ compile, ' and compile,",
     {CALL(compile_comma), CALL(compile_comma), m4bye},
     {{2, {DXT(and), DXT(one_plus)}}, {}},
     {{}, {}},
     {2, {m4one_plus, m4and}}},
    /* ----------------------------- (eval...) -------------------------------- */
    {"0 (eval-number)",
     {CALL(_eval_number_), m4bye},
     {{1, {0}}, {}},
     {{1, {0}}, {}},
     {}}, /* state = interpret */
    {"0 (eval-number)",
     {CALL(_eval_number_), m4bye},
     {{1, {0}}, {}},
     {{}, {}},
     {1, {m4zero}}}, /* state = compile */
    {"' dup (eval-name)",
     {CALL(_eval_name_), m4bye},
     {{3, {7, (m4cell)&WORD_SYM(dup), ttrue}}, {}},
     {{2, {7, 7}}, {}},
     {}}, /* state = interpret */
    {"' dup (eval-name)",
     {CALL(_eval_name_), m4bye},
     {{2, {(m4cell)&WORD_SYM(dup), ttrue}}, {}},
     {{}, {}},
     {1, {m4dup}}}, /* state = compile */
};

static void m4testexecute_fix(m4testexecute *t, const m4code_pair *pair) {
    switch (t->code[0]) {
    case m4_ip_:
        if (t->code[1] == m4bye) {
            t->after.d.data[0] = (m4cell)pair->first.addr;
        }
        break;
    case m4_ip_to_data_addr_:
        /* TODO t->after.d.data[0] = (m4cell)w->data; */
        break;
    case m4name_to_string:
        t->after.d.data[0] = (m4cell)m4word_name((const m4word *)t->before.d.data[0]).addr;
        break;
    }
}

static m4code_pair m4testexecute_init(m4testexecute *t, m4countedcode_pair *code_buf) {
    m4slice t_code_in = {(m4cell *)t->code, m4test_code_n};
    m4slice t_codegen_in = {(m4cell *)t->codegen.data, t->codegen.n};
    m4code_pair pair = {{code_buf->first.data, code_buf->first.n},
                        {code_buf->second.data, code_buf->second.n}};

    m4slice_copy_to_code(t_code_in, &pair.first);
    m4slice_copy_to_code(t_codegen_in, &pair.second);
    return pair;
}

static m4cell m4testexecute_run(m4th *m, m4testexecute *t, const m4code_pair *pair) {
    m4th_clear(m);
    if (t->codegen.n != 0) {
        m4string name = {};
        m4th_colon(m, name);
    }
    m4testexecute_fix(t, pair);

    m4countedstack_copy(&t->before.d, &m->dstack);
    m4countedstack_copy(&t->before.r, &m->rstack);
#if 0
    m->in->handle = (m4cell)stdin;
    m->in->func = m4word_code(&WORD_SYM(c_fread)).addr;
#endif /* 0 */
    m->ip = pair->first.addr;

    m4th_run(m);

    m4th_sync_lastw(m);

    return m4countedstack_equal(&t->after.d, &m->dstack) &&
           m4countedstack_equal(&t->after.r, &m->rstack) &&
           m4code_equal(pair->second, m4word_code(m->lastw));
}

static void m4testexecute_failed(m4th *m, const m4testexecute *t, const m4code_pair *pair,
                                 FILE *out) {
    if (out == NULL) {
        return;
    }
    fprintf(out, "execute test failed: %s", t->name);
    fputs("\n    expected  data  stack ", out);
    m4countedstack_print(&t->after.d, out);
    fputs("\n      actual  data  stack ", out);
    m4stack_print(&m->dstack, m4mode_user, out);

    fputs("\n... expected return stack ", out);
    m4countedstack_print(&t->after.r, out);
    fputs("\n      actual return stack ", out);
    m4stack_print(&m->rstack, m4mode_user, out);

    if (t->codegen.n == 0 && (!m->lastw || m->lastw->code_n == 0)) {
        fputc('\n', out);
        return;
    }
    fputs("\n... expected    codegen   ", out);
    m4code_print(pair->second, m4mode_user, out);
    fputs("\n      actual    codegen   ", out);
    m4code_print(m4word_code(m->lastw), m4mode_user, out);
    fputc('\n', out);
}

static void m4th_testexecute_bunch(m4th *m, m4testexecute bunch[], m4cell n, m4testcount *count,
                                   FILE *out) {
    m4countedcode_pair countedcode_pair = {{m4test_code_n, {}}, {m4test_code_n, {}}};
    m4cell i, fail = 0;
    for (i = 0; i < n; i++) {
        m4code_pair code_pair = m4testexecute_init(&bunch[i], &countedcode_pair);
#undef M4TH_TEST_VERBOSE
#ifdef M4TH_TEST_VERBOSE
        fprintf(out, "%s\n", bunch[i].name);
#endif
        if (!m4testexecute_run(m, &bunch[i], &code_pair)) {
            fail++, m4testexecute_failed(m, &bunch[i], &code_pair, out);
        }
        m4test_forget_all(m);
    }
    count->failed += fail;
    count->total += n;
}

void m4th_testbench_crc_c(FILE *out) {
    m4ucell i, n = 1e8;
    uint32_t crc = ~(uint32_t)0;
    const uint32_t expected = 0x773edc4e;
    for (i = 0; i < n; i++) {
        crc = m4th_crc1byte(crc, 't');
    }
    if (crc != expected) {
        fprintf(out, "m4th_testbench_crc_c mismatch: expected 0x%lx, got 0x%lx\n", (long)expected,
                (long)crc);
    }
}

m4cell m4th_testexecute(m4th *m, FILE *out) {
    m4testexecute *t[] = {
        testexecute_a, testexecute_b, testexecute_c, testexecute_d,
        testexecute_e, testexecute_f, testexecute_g,
    };
    const m4cell n[] = {
        N_OF(testexecute_a), N_OF(testexecute_b), N_OF(testexecute_c), N_OF(testexecute_d),
        N_OF(testexecute_e), N_OF(testexecute_f), N_OF(testexecute_g),
    };
    m4testcount count = {};
    m4cell i;
#if 0
    extern m4wordlist m4wordlist_m4th_user;
    m4wordlist_find(&m4wordlist_m4th_user, m4string_make("ex-message!", 11));
#endif
    m4array_copy_to_tarray(crc1byte_array, crc1byte_code);
    /* printf("crc('t') = %u\n", (unsigned)m4th_crc1byte(0xffffffff, 't')); */

    for (i = 0; i < (m4cell)N_OF(t); i++) {
        m4th_testexecute_bunch(m, t[i], n[i], &count, out);
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

#endif /* M4TH_T_TESTEXECUTE_C */
