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
#include "../include/iobuf.mh"
#include "../include/token.h"
#include "../include/word_fwd.h"
#include "../m4th.h"
#include "testcommon.h"

#include <assert.h> /* assert()          */
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

static m4testexecute testexecute_a[] = {
#if 0
    {"1e9 0 do loop", {m4do, m4_loop_, T(-2), m4bye}, {{2, {1e9, 0}}, {}}, {{}, {}}, {}},
#elif 0
    {"1e6 0 do wordlist-find loop",
     {m4do, m4j, CALL(wordlist_find), m4_loop_, T(-3 - callsz), m4bye},
     {{4, {(m4cell) "foo", 3, 1e6, 0}}, {1, {(m4cell)&m4wordlist_forth}}},
     {{2, {(m4cell) "foo", 3}}, {1, {(m4cell)&m4wordlist_forth}}},
     {}},
#elif 0
    {"1e8 0 do crc+ loop",
     {m4do, m4over, m4_call_xt_, CELL(crc1byte_code), m4_loop_, T(-3 - callsz), m4nip, m4bye},
     {{4, {'t', 0xffffffff, 1e8, 0}}, {}},
     {{1, {0x773edc4e}}, {}},
     {}},
#elif 0
    {"1e8 0 do crc+-native-forth loop",
     {m4do, m4over, m4j, m4_exec_native_, m4_loop_, T(-5), m4nip, m4r_from_drop, m4bye},
     {{4, {'t', 0xffffffff, 1e8, 0}}, {1, {(m4cell)m4ftest_crc_plus_native_forth}}},
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
    {"lshift", {m4lshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 << 3}}, {}}, {}},
    {"max", {m4max, m4bye}, {{2, {1, 2}}, {}}, {{1, {2}}, {}}, {}},
    {"min", {m4min, m4bye}, {{2, {3, 4}}, {}}, {{1, {3}}, {}}, {}},
    {"mod", {m4mod, m4bye}, {{2, {20, 7}}, {}}, {{1, {6}}, {}}, {}},
    {"-20 7 mod", {m4mod, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-6}}, {}}, {}},
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
    {"r+", {m4r_plus, m4bye}, {{1, {30}}, {1, {4}}}, {{}, {1, {34}}}, {}},
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
    {"0 0 (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {0, 0}}}, {{}, {2, {0, 1}}}, {}},
    {"0 1 (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {0, 1}}}, {{}, {2, {0, 2}}}, {}},
    {"1 0 (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {1, 0}}}, {{}, {}}, {}},
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
    {"iobuf>addr",
     {m4iobuf_addr, m4bye},
     {{1, {0x1000}}, {}},
     {{1, {0x1000 + IOBUF_OFF_ADDR}}, {}},
     {}},
    {"iobuf>pos",
     {m4iobuf_pos, m4bye},
     {{1, {0x2000}}, {}},
     {{1, {0x2000 + IOBUF_OFF_POS}}, {}},
     {}},
    {"iobuf>size",
     {m4iobuf_size, m4bye},
     {{1, {0x3000}}, {}},
     {{1, {0x3000 + IOBUF_OFF_SIZE}}, {}},
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

static m4testexecute testexecute_d[] = {
    /* ----------------------------- literal, (call) ------------------------ */
    {"(lit-token) T(7)", {m4_lit_, T(7), m4bye}, {{}, {}}, {{1, {7}}, {}}, {}},
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
    {"' noop (exec-native)", {m4_exec_native_, m4bye}, {{1, {(m4cell)m4fnoop}}, {}}, {{}, {}}, {}},
    {"' two (exec-native)",
     {m4_exec_native_, m4bye},
     {{1, {(m4cell)m4ftwo}}, {}},
     {{1, {2}}, {}},
     {}},
    {"' crc+-native-forth (exec-native)",
     {m4_exec_native_, m4bye},
     {{3, {0xffffffff, 't', (m4cell)m4ftest_crc_plus_native_forth}}, {}},
     {{1, {0x1b806fbc}}, {}},
     {}},
    {"' one (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4one}}, {}}, {{1, {1}}, {}}, {}},
    {"' noop (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4noop}}, {}}, {{}, {}}, {}},
    {"(exec-xt-from-native)",
     {m4_exec_native_, m4bye},
     {{2, {DXT(three), (m4cell)m4ftest_exec_xt_from_native, m4bye}}, {}},
     {{1, {3}}, {}},
     {}},
    {"' noop execute", {m4execute, m4bye}, {{1, {DXT(noop)}}, {}}, {{}, {}}, {}},
    {"' eight execute", {m4execute, m4bye}, {{1, {DXT(eight)}}, {}}, {{1, {8}}, {}}, {}},
    {"6 7 ' plus execute", {m4execute, m4bye}, {{3, {6, 7, DXT(plus)}}, {}}, {{1, {13}}, {}}, {}},
    {"(ip)", {m4_ip_, m4bye}, {{}, {}}, {{1, {-1 /* fixed by m4testexecute_fix() */}}, {}}, {}},
#if 0 /* currently broken */
    {"(ip>data>addr)",
     {m4_ip_to_data_addr_, m4bye},
     {{}, {}},
     {{1, {-1 /* fixed by m4testexecute_fix() */}}, {}},
     {}},
#endif
    {"(lit-string)",
     {m4_ip_, m4_lit_string_, T(3), (m4cell) "abc", m4minus_rot, m4minus, m4bye},
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
     {{3, {19, 1, DXT(throw)}}, {1, {0xfed3}}},
     {{3, {19, -1 /*clobbered*/, 1}}, {1, {0xfed3}}},
     {}},
    /* ----------------------------- [token-gives-cell?] -------------------- */
    {"0 'zero [token-gives-cell?]",
     {CALL(_token_gives_cell_q_), m4bye},
     {{2, {0, m4zero}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"1 'zero [token-gives-cell?]",
     {CALL(_token_gives_cell_q_), m4bye},
     {{2, {1, m4zero}}, {}},
     {{2, {1, tfalse}}, {}},
     {}},
    {"1 'one [token-gives-cell?]",
     {CALL(_token_gives_cell_q_), m4bye},
     {{2, {1, m4one}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"3 'three [token-gives-cell?]",
     {CALL(_token_gives_cell_q_), m4bye},
     {{2, {3, m4three}}, {}},
     {{2, {m4three, ttrue}}, {}},
     {}},
    {"7 'eight [token-gives-cell?]",
     {CALL(_token_gives_cell_q_), m4bye},
     {{2, {7, m4eight}}, {}},
     {{2, {7, tfalse}}, {}},
     {}},
    {"8 'eight [token-gives-cell?]",
     {CALL(_token_gives_cell_q_), m4bye},
     {{2, {8, m4eight}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    {"8 'eight [token-gives-cell?]",
     {CALL(_token_gives_cell_q_), m4bye},
     {{2, {8, m4eight}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    /* ----------------------------- [any-token-gives-cell?] ---------------- */
    {"8 NULL 0 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {8, (m4cell)NULL, 0}}, {}},
     {{2, {8, tfalse}}, {}},
     {}},
    {"0 NULL 0 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {0, (m4cell)NULL, 0}}, {}},
     {{2, {0, tfalse}}, {}},
     {}},
    {"0 tarray 1 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {0, (m4cell)testdata_any, 1}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"0 tarray 2 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {0, (m4cell)testdata_any, 2}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"1 NULL 0 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)NULL, 0}}, {}},
     {{2, {1, tfalse}}, {}},
     {}},
    {"1 tarray 1 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)testdata_any, 1}}, {}},
     {{2, {1, tfalse}}, {}},
     {}},
    {"1 tarray 2 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)testdata_any, 2}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"1 tarray tn [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)testdata_any, N_OF(testdata_any)}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"-1 tarray 2 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {-1, (m4cell)testdata_any, 2}}, {}},
     {{2, {-1, tfalse}}, {}},
     {}},
    {"-1 tarray 3 [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {-1, (m4cell)testdata_any, 3}}, {}},
     {{2, {m4minus_one, ttrue}}, {}},
     {}},
    {"-1 tarray tn [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {-1, (m4cell)testdata_any, N_OF(testdata_any)}}, {}},
     {{2, {m4minus_one, ttrue}}, {}},
     {}},
    {"8 tarray tn [any-token-gives-cell?]",
     {CALL(_any_token_gives_cell_q_), m4bye},
     {{3, {8, (m4cell)testdata_any, N_OF(testdata_any)}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
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

static m4testexecute testexecute_e[] = {
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
    {"NULL string-first-blank",
     {CALL(string_first_blank), m4bye},
     {{2, {(m4cell)0, 0}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\" \" string-first-blank",
     {CALL(string_first_blank), m4bye},
     {{2, {(m4cell) " ", 1}}, {}},
     {{1, {0}}, {}},
     {}},
    {"\"x\" string-first-blank",
     {CALL(string_first_blank), m4bye},
     {{2, {(m4cell) "x", 1}}, {}},
     {{1, {1}}, {}},
     {}},
    {"\"yz \" string-first-blank",
     {CALL(string_first_blank), m4bye},
     {{2, {(m4cell) "yz =", 3}}, {}},
     {{1, {2}}, {}},
     {}},
    {"\"yz =\" string-first-blank",
     {CALL(string_first_blank), m4bye},
     {{2, {(m4cell) "yz =", 4}}, {}},
     {{1, {2}}, {}},
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

static m4testexecute testexecute_f[] = {
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
    {"[compile-lit,] T(500) [#compiled]",
     {m4_num_compiled_, m4_compile_lit_, T(500), m4_num_compiled_, m4bye},
     {{}, {}},
     {{2, {0, 1}}, {}},
     {1, {500}}},
    {"0xcdef short,",
     {m4_num_compiled_, m4swap, m4short_comma, m4_num_compiled_, m4bye},
     {{1, {0xcdef}}, {}},
     {{2, {0, 1}}, {}},
     {1, {0xcdef}}},
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
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
#endif /* __BYTE_ORDER__ */
    {"\"\" 0 name,",
     {m4name_comma, m4here, m4minus, m4bye},
     {{2, {(m4cell) "bar", 0}}, {}},
     {{1, {-WORD_OFF_DATA}}, {}},
     {}},
    {";", {CALL(semi), m4bye}, {{2, {0, m4right_bracket}}, {}}, {{}, {}}, {1, {m4exit}}},
    /* ----------------------------- search order --------------------------- */
    {"get-current",
     {m4get_current, m4bye},
     {{}, {}},
     {{1, {(m4cell)&m4wordlist_m4th_user}}, {}},
     {}},
    {"set-current",
     {m4get_current, m4swap, m4set_current, m4get_current, m4swap, m4set_current, m4bye},
     {{1, {(m4cell)&m4wordlist_m4th_impl}}, {}},
     {{1, {(m4cell)&m4wordlist_m4th_impl}}, {}},
     {}},
    /* ----------------------------- word.... ------------------------------- */
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
    {"name>string",
     {m4name_to_string, m4bye},
     {{1, {(m4cell)&WORD_SYM(mod)}}, {}},
     {{2, {(m4cell)NULL /* fixed by m4testexecute_fix() */, 3}}, {}},
     {}},
    {"name>prev",
     {m4name_to_prev, m4bye},
     {{1, {(m4cell)&WORD_SYM(times)}}, {}},
     {{1, {(m4cell)&WORD_SYM(store)}}, {}},
     {}},
    {"name>xt",
     {m4name_to_xt, m4bye},
     {{1, {(m4cell)&WORD_SYM(dup)}}, {}},
     {{1, {DXT(dup)}}, {}},
     {}},
    {"wordlist-last",
     {m4wordlist_last, m4bye},
     {{1, {(m4cell)&m4wordlist_forth}}, {}},
     {{1, {(m4cell)&WORD_SYM(cmove)}}, {}},
     {}},
    {"wordlist-find",
     {CALL(wordlist_find), m4bye},
     {{3, {(m4cell) "dup", 3, (m4cell)&m4wordlist_forth}}, {}},
     {{2, {(m4cell)&WORD_SYM(dup), ttrue}}, {}},
     {}},
    {"wordlist-find",
     {CALL(wordlist_find), m4bye},
     {{3, {TESTSTR(_0az), (m4cell)&m4wordlist_forth}}, {}},
     {{2, {0, 0}}, {}},
     {}},
    {"search-wordlist",
     {CALL(search_wordlist), m4bye},
     {{3, {(m4cell) "dup", 3, (m4cell)&m4wordlist_forth}}, {}},
     {{2, {DXT(dup), ttrue}}, {}},
     {}},
    {"search-wordlist",
     {CALL(search_wordlist), m4bye},
     {{3, {(m4cell) "if", 2, (m4cell)&m4wordlist_forth}}, {}},
     {{2, {DXT(if), 1}}, {}},
     {}},
    {"search-wordlist",
     {CALL(search_wordlist), m4bye},
     {{3, {TESTSTR(_0az), (m4cell)&m4wordlist_forth}}, {}},
     {{1, {0}}, {}},
     {}},
    {"string>name",
     {CALL(string_to_name), m4bye},
     {{2, {(m4cell) "?do", 3}}, {}},
     {{2, {(m4cell)&WORD_SYM(question_do), 1}}, {}},
     {}},
    {"string>name",
     {CALL(string_to_name), m4bye},
     {{2, {TESTSTR(_0az)}}, {}},
     {{2, {0, 0}}, {}},
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

static void m4testexecute_cleanup(m4th *m) {
    /* the test may have defined some new words:
     * remove them before executing the following test */
    m4wordlist *wid = m->compile_wid;
    if (wid && wid->last) {
        wid->last = NULL;
    }
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
    m4stack_print(&m->dstack, out);

    fputs("\n... expected return stack ", out);
    m4countedstack_print(&t->after.r, out);
    fputs("\n      actual return stack ", out);
    m4stack_print(&m->rstack, out);

    if (t->codegen.n == 0 && (!m->lastw || m->lastw->code_n == 0)) {
        fputc('\n', out);
        return;
    }
    fputs("\n... expected    codegen   ", out);
    m4code_print(pair->second, out);
    fputs("\n      actual    codegen   ", out);
    m4word_code_print(m->lastw, out);
    fputc('\n', out);
}

static void m4th_testexecute_bunch(m4th *m, m4testexecute bunch[], m4cell n, m4testcount *count,
                                   FILE *out) {
    m4countedcode_pair countedcode_pair = {{m4test_code_n, {}}, {m4test_code_n, {}}};
    m4cell i, fail = 0;
    for (i = 0; i < n; i++) {
        m4code_pair code_pair = m4testexecute_init(&bunch[i], &countedcode_pair);
        if (!m4testexecute_run(m, &bunch[i], &code_pair)) {
            fail++, m4testexecute_failed(m, &bunch[i], &code_pair, out);
        }
        m4testexecute_cleanup(m);
    }

    count->failed += fail;
    count->total += n;
}

void m4th_testprint_wordlist_crc(const m4wordlist *wid, FILE *out) {
    const m4word *w = m4wordlist_lastword(wid);
    m4string name = m4wordlist_name(wid);

    fputs("\n---------------- ", out);
    m4string_print(name, out);
    fputs(" ----------------", out);

    while (w) {
        name = m4word_name(w);
        fprintf(out, "\n0x%08x    ", m4th_crcstring(name));
        m4string_print(name, out);
        w = m4word_prev(w);
    }
    fputc('\n', out);
}

void m4th_testprint_wordlists_crc(FILE *out) {
    const m4wordlist *wid[] = {&m4wordlist_forth, &m4wordlist_m4th_user, &m4wordlist_m4th_core,
                               &m4wordlist_m4th_impl};
    m4cell_u i;
    for (i = 0; i < N_OF(wid); i++) {
        m4th_testprint_wordlist_crc(wid[i], out);
    }
}

void m4th_testbench_crc_c(FILE *out) {
    m4cell_u i, n = 1e8;
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
        testexecute_a, testexecute_b, testexecute_c, testexecute_d, testexecute_e, testexecute_f,
    };
    const m4cell n[] = {
        N_OF(testexecute_a), N_OF(testexecute_b), N_OF(testexecute_c),
        N_OF(testexecute_d), N_OF(testexecute_e), N_OF(testexecute_f),
    };
    m4testcount count = {};
    m4cell i;
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
