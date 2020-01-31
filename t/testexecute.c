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

#ifndef M4TH_T_TESTEXECUTE_C
#define M4TH_T_TESTEXECUTE_C

#include "../impl.h"
#include "../include/func_fwd.h"
#include "../include/token.h"
#include "../include/word_fwd.h"
#include "../m4th.h"
#include "testcommon.h"

#include <assert.h> /* assert()          */
#include <string.h> /* memset()          */

typedef m4cell m4test_code_array[m4test_code_n];

typedef struct m4testexecute_s {
    const char *name;
    m4test_code_array code;
    m4test_stacks before, after;
    m4test_code codegen;
} m4testexecute;

/* -------------- m4cell[] -> m4token[] conversion -------------- */

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

#define m4array_copy_to_tarray(array, tarray)                                                      \
    m4array_n_copy_to_tarray_n(array, N_OF(array), tarray, N_OF(tarray))

void m4array_n_copy_to_tarray_n(const m4cell array[], const m4cell array_n /*               */,
                                m4token tarray[], const m4cell tarray_n) {
    m4slice src = {(m4cell *)array, array_n};
    m4code dst = {tarray, tarray_n};
    m4slice_copy_to_code(src, &dst);
}

/* -------------- crc -------------- */

static m4cell crctable[256];

static void crcfill(m4cell table[256]) {
    int i, j;

    for (i = 0; i < 256; i++) {
        uint32_t val = i;
        for (j = 0; j < 8; j++) {
            if (val & 1) {
                val >>= 1;
                val ^= 0xedb88320;
            } else {
                val >>= 1;
            }
        }
        table[i] = val;
    }
}

/* -------------- crc1byte -------------- */

uint32_t crc1byte(uint32_t crc, unsigned char byte) {
    assert(crctable[0xff]);
    return (crc >> 8) ^ crctable[(crc & 0xff) ^ byte];
}

/**
 * compiled forth version of crc1byte above. forth source would be
 * : crc+ ( crc char -- crc' )
 *   over xor 0xff and  cells crctable + @  swap 8 rshift xor
 * ;
 */
static const m4cell crc1byte_array[] = {
    m4over, m4xor,   m4_lit_token_, T(0xff),       m4and, m4cells,  m4_lit_cell_, CELL(crctable),
    m4plus, m4fetch, m4swap,        m4_lit_token_, T(8),  m4rshift, m4xor,        m4exit,
};
/* initialized by m4th_testexecute() */
static m4token crc1byte_tarray[N_OF(crc1byte_array)];

/* -------------- [any-token-gives-cell?] -------------- */

static const m4token testdata_any_token_gives_cell_q_[] = {
    m4zero, m4one, m4minus_one, m4two, m4four, m4eight,
};

/* -------------- m4test -------------- */

static m4testexecute testexecute[] = {
#if 0
    {"1e9 0 (do) (loop)", {m4_do_, m4_loop_, T(-2), m4bye}, {{2, {1e9, 0}}, {}}, {{}, {}}, {}},
#else
    /* ----------------------------- arithmetic ----------------------------- */
    {"*", {m4times, m4bye}, {{2, {20, 7}}, {}}, {{1, {140}}, {}}, {}},
    {"-3 2 +", {m4plus, m4bye}, {{2, {-3, 2}}, {}}, {{1, {-1}}, {}}, {}},
    {"3 4 -", {m4minus, m4bye}, {{2, {3, 4}}, {}}, {{1, {-1}}, {}}, {}},
    {"-20 7 /", {m4div, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-2}}, {}}, {}},
    {"20 7 /", {m4div, m4bye}, {{2, {20, 7}}, {}}, {{1, {2}}, {}}, {}},
    {"-20 7 /mod", {m4div_mod, m4bye}, {{2, {-20, 7}}, {}}, {{2, {-6, -2}}, {}}, {}},
    {"20 7 /mod", {m4div_mod, m4bye}, {{2, {20, 7}}, {}}, {{2, {6, 2}}, {}}, {}},
    {"/byte", {m4div_byte, m4bye}, {{1, {-13}}, {}}, {{1, {-13}}, {}}, {}},
    {"/char", {m4div_char, m4bye}, {{1, {-14}}, {}}, {{1, {-14}}, {}}, {}},
    {"n /short", {m4div_short, m4bye}, {{1, {-15}}, {}}, {{1, {-15 / 2}}, {}}, {}},
    {"u /short", {m4div_short, m4bye}, {{1, {15}}, {}}, {{1, {15 / 2}}, {}}, {}},
    {"n /ushort", {m4div_ushort, m4bye}, {{1, {-15}}, {}}, {{1, {-15 / 2}}, {}}, {}},
    {"u /ushort", {m4div_ushort, m4bye}, {{1, {15}}, {}}, {{1, {15 / 2}}, {}}, {}},
    {"n /int", {m4div_int, m4bye}, {{1, {-15}}, {}}, {{1, {-15 / 4}}, {}}, {}},
    {"u /int", {m4div_int, m4bye}, {{1, {15}}, {}}, {{1, {15 / 4}}, {}}, {}},
    {"n /uint", {m4div_uint, m4bye}, {{1, {-15}}, {}}, {{1, {-15 / 4}}, {}}, {}},
    {"u /uint", {m4div_uint, m4bye}, {{1, {15}}, {}}, {{1, {15 / 4}}, {}}, {}},
    {"n /cell", {m4div_cell, m4bye}, {{1, {-13}}, {}}, {{1, {-13 / SZ}}, {}}, {}},
    {"u /cell", {m4div_cell, m4bye}, {{1, {13}}, {}}, {{1, {13 / SZ}}, {}}, {}},
    {"n /token", {m4div_token, m4bye}, {{1, {-13}}, {}}, {{1, {-13 / SZt}}, {}}, {}},
    {"u /token", {m4div_token, m4bye}, {{1, {13}}, {}}, {{1, {13 / SZt}}, {}}, {}},
    {"-1", {m4minus_one, m4bye}, {{}, {}}, {{1, {-1}}, {}}, {}},
    {"0", {m4zero, m4bye}, {{}, {}}, {{1, {}}, {}}, {}},
    {"1", {m4one, m4bye}, {{}, {}}, {{1, {1}}, {}}, {}},
    {"1-", {m4one_minus, m4bye}, {{1, {-3}}, {}}, {{1, {-4}}, {}}, {}},
    {"1+", {m4one_plus, m4bye}, {{1, {-6}}, {}}, {{1, {-5}}, {}}, {}},
    {"2", {m4two, m4bye}, {{}, {}}, {{1, {2}}, {}}, {}},
    {"2-", {m4two_minus, m4bye}, {{1, {-3}}, {}}, {{1, {-5}}, {}}, {}},
    {"2+", {m4two_plus, m4bye}, {{1, {-6}}, {}}, {{1, {-4}}, {}}, {}},
    {"2*", {m4two_times, m4bye}, {{1, {-6}}, {}}, {{1, {-12}}, {}}, {}},
    {"n 2/", {m4two_div, m4bye}, {{1, {-5}}, {}}, {{1, {-2}}, {}}, {}},
    {"u 2/", {m4two_div, m4bye}, {{1, {5}}, {}}, {{1, {2}}, {}}, {}},
    {"3", {m4three, m4bye}, {{}, {}}, {{1, {3}}, {}}, {}},
    {"4", {m4four, m4bye}, {{}, {}}, {{1, {4}}, {}}, {}},
    {"4+", {m4four_plus, m4bye}, {{1, {-7}}, {}}, {{1, {-3}}, {}}, {}},
    {"4*", {m4four_times, m4bye}, {{1, {-7}}, {}}, {{1, {-28}}, {}}, {}},
    {"n 4/", {m4four_div, m4bye}, {{1, {-27}}, {}}, {{1, {-6}}, {}}, {}},
    {"u 4/", {m4four_div, m4bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"8", {m4eight, m4bye}, {{}, {}}, {{1, {8}}, {}}, {}},
    {"8+", {m4eight_plus, m4bye}, {{1, {-3}}, {}}, {{1, {5}}, {}}, {}},
    {"8*", {m4eight_times, m4bye}, {{1, {-3}}, {}}, {{1, {-24}}, {}}, {}},
    {"n 8/", {m4eight_div, m4bye}, {{1, {-25}}, {}}, {{1, {-3}}, {}}, {}},
    {"u 8/", {m4eight_div, m4bye}, {{1, {31}}, {}}, {{1, {3}}, {}}, {}},
    {">r", {m4to_r, m4bye}, {{1, {99}}, {}}, {{}, {1, {99}}}, {}},
    {"0 ?dup", {m4question_dup, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"1 ?dup", {m4question_dup, m4bye}, {{1, {1}}, {}}, {{2, {1, 1}}, {}}, {}},
    {"0 abs", {m4abs, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"11 abs", {m4abs, m4bye}, {{1, {11}}, {}}, {{1, {11}}, {}}, {}},
    {"-3 abs", {m4abs, m4bye}, {{1, {-3}}, {}}, {{1, {3}}, {}}, {}},
    {"-7 14 and", {m4and, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 & 14}}, {}}, {}},
    {"bl", {m4bl, m4bye}, {{}, {}}, {{1, {' '}}, {}}, {}},
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
    {"depth", {m4depth, m4bye}, {{}, {}}, {{1, {}}, {}}, {}},
    {"_ depth", {m4depth, m4bye}, {{1, {3}}, {}}, {{2, {3, 1}}, {}}, {}},
    {"_ _ depth", {m4depth, m4bye}, {{2, {3, 4}}, {}}, {{3, {3, 4, 2}}, {}}, {}},
    {"drop", {m4drop, m4bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"dup", {m4dup, m4bye}, {{1, {-5}}, {}}, {{2, {-5, -5}}, {}}, {}},
    {"false", {m4false, m4bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"lshift", {m4lshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 << 3}}, {}}, {}},
    {"max", {m4max, m4bye}, {{2, {1, 2}}, {}}, {{1, {2}}, {}}, {}},
    {"min", {m4min, m4bye}, {{2, {3, 4}}, {}}, {{1, {3}}, {}}, {}},
    {"20 7 mod", {m4mod, m4bye}, {{2, {20, 7}}, {}}, {{1, {6}}, {}}, {}},
    {"-20 7 mod", {m4mod, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-6}}, {}}, {}},
    {"negate", {m4negate, m4bye}, {{1, {-12}}, {}}, {{1, {12}}, {}}, {}},
    {"nip", {m4nip, m4bye}, {{2, {3, 4}}, {}}, {{1, {4}}, {}}, {}},
    {"noop", {m4noop, m4bye}, {{}, {}}, {{}, {}}, {}},
    {"-7 14 or", {m4or, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 | 14}}, {}}, {}},
    {"over", {m4over, m4bye}, {{2, {1, 0}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"rot", {m4rot, m4bye}, {{3, {1, 2, 3}}, {}}, {{3, {2, 3, 1}}, {}}, {}},
    {"rshift", {m4rshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 >> 3}}, {}}, {}},
    {"swap", {m4swap, m4bye}, {{2, {4, 5}}, {}}, {{2, {5, 4}}, {}}, {}},
    /*                                                                          */
    {"-261 to-byte", {m4to_byte, m4bye}, {{1, {-261}}, {}}, {{1, {(int8_t)-261}}, {}}, {}},
    {"-128 to-byte", {m4to_byte, m4bye}, {{1, {-128}}, {}}, {{1, {-128}}, {}}, {}},
    {"127 to-byte", {m4to_byte, m4bye}, {{1, {127}}, {}}, {{1, {127}}, {}}, {}},
    {"259 to-byte", {m4to_byte, m4bye}, {{1, {259}}, {}}, {{1, {(int8_t)259}}, {}}, {}},
    {"-54321 to-short", {m4to_short, m4bye}, {{1, {-54321}}, {}}, {{1, {(int16_t)-54321}}, {}}, {}},
    {"-32768 to-short", {m4to_short, m4bye}, {{1, {-32768}}, {}}, {{1, {-32768}}, {}}, {}},
    {"32767 to-short", {m4to_short, m4bye}, {{1, {32767}}, {}}, {{1, {32767}}, {}}, {}},
    {"54321 to-short", {m4to_short, m4bye}, {{1, {54321}}, {}}, {{1, {(int16_t)54321}}, {}}, {}},
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
    {"-261 to-char", {m4to_char, m4bye}, {{1, {-261}}, {}}, {{1, {(uint8_t)-261}}, {}}, {}},
    {"-7 to-char", {m4to_char, m4bye}, {{1, {-7}}, {}}, {{1, {(uint8_t)-7}}, {}}, {}},
    {"0 to-char", {m4to_char, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"255 to-char", {m4to_char, m4bye}, {{1, {255}}, {}}, {{1, {255}}, {}}, {}},
    {"259 to-char", {m4to_char, m4bye}, {{1, {259}}, {}}, {{1, {(uint8_t)259}}, {}}, {}},
    {"-76543 to-ushort",
     {m4to_ushort, m4bye},
     {{1, {-76543}}, {}},
     {{1, {(uint16_t)-76543}}, {}},
     {}},
    {"-11 to-ushort", {m4to_ushort, m4bye}, {{1, {-11}}, {}}, {{1, {(uint16_t)-11}}, {}}, {}},
    {"0 to-ushort", {m4to_ushort, m4bye}, {{1, {0}}, {}}, {{1, {0}}, {}}, {}},
    {"65535 to-ushort", {m4to_ushort, m4bye}, {{1, {65535}}, {}}, {{1, {65535}}, {}}, {}},
    {"76543 to-ushort", {m4to_ushort, m4bye}, {{1, {76543}}, {}}, {{1, {(uint16_t)76543}}, {}}, {}},
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
    {"true", {m4true, m4bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"unloop", {m4unloop, m4bye}, {{}, {3, {1, 2, 3}}}, {{}, {1, {1}}}, {}},
    {"-7 14 xor", {m4xor, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 ^ 14}}, {}}, {}},
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
    /* ----------------------------- return stack ------------------ */
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
    /* ----------------------------- if, exec, jump, loop ------------------ */
    {"0 1 (do)", {m4_do_, m4bye}, {{2, {0, 1}}, {}}, {{}, {2, {0, 1}}}, {}},
    {"1 0 (do)", {m4_do_, m4bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"0 0 (?do)", {m4_question_do_, T(0), m4bye}, {{2, {0, 0}}, {}}, {{}, {}}, {}},
    {"1 0 (?do)", {m4_question_do_, T(0), m4bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"one (exec-native)",
     {m4_exec_native_, m4bye},
     {{1, {(m4cell)m4fone}}, {}},
     {{1, {1}}, {}},
     {}},
    {"noop (exec-native)", {m4_exec_native_, m4bye}, {{1, {(m4cell)m4fnoop}}, {}}, {{}, {}}, {}},
    {"one (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4one}}, {}}, {{1, {1}}, {}}, {}},
    {"noop (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4noop}}, {}}, {{}, {}}, {}},
    {"0 (if)", {m4_if_, T(1), m4two, m4bye}, {{1, {}}, {}}, {{}, {}}, {}},
    {"1 (if)", {m4_if_, T(1), m4four, m4bye}, {{1, {1}}, {}}, {{1, {4}}, {}}, {}},
    {"0 (if-zero)", {m4_if_zero_, T(1), m4two, m4bye}, {{1, {0}}, {}}, {{1, {2}}, {}}, {}},
    {"1 (if-zero)", {m4_if_zero_, T(1), m4three, m4bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"0 1 (if<)", {m4_if_less_, T(1), m4two, m4bye}, {{2, {0, 1}}, {}}, {{1, {2}}, {}}, {}},
    {"2 2 (if<)", {m4_if_less_, T(1), m4one, m4bye}, {{2, {2, 2}}, {}}, {{}, {}}, {}},
    {"4 3 (if<)", {m4_if_less_, T(1), m4zero, m4bye}, {{2, {4, 3}}, {}}, {{}, {}}, {}},
    {"0 1 (if<=)", {m4_if_less_equal_, T(1), m4two, m4bye}, {{2, {0, 1}}, {}}, {{1, {2}}, {}}, {}},
    {"2 2 (if<=)", {m4_if_less_equal_, T(1), m4one, m4bye}, {{2, {2, 2}}, {}}, {{1, {1}}, {}}, {}},
    {"4 3 (if<=)", {m4_if_less_equal_, T(1), m4zero, m4bye}, {{2, {4, 3}}, {}}, {{}, {}}, {}},
    {"0 1 (if<>)", {m4_if_ne_, T(1), m4two, m4bye}, {{2, {0, 1}}, {}}, {{1, {2}}, {}}, {}},
    {"2 2 (if<>)", {m4_if_ne_, T(1), m4one, m4bye}, {{2, {2, 2}}, {}}, {{}, {}}, {}},
    {"4 3 (if<>)", {m4_if_ne_, T(1), m4zero, m4bye}, {{2, {4, 3}}, {}}, {{1, {0}}, {}}, {}},
    {"0 1 (if=)", {m4_if_equal_, T(1), m4two, m4bye}, {{2, {0, 1}}, {}}, {{}, {}}, {}},
    {"2 2 (if=)", {m4_if_equal_, T(1), m4one, m4bye}, {{2, {2, 2}}, {}}, {{1, {1}}, {}}, {}},
    {"4 3 (if=)", {m4_if_equal_, T(1), m4zero, m4bye}, {{2, {4, 3}}, {}}, {{}, {}}, {}},
    {"0 1 (if>)", {m4_if_more_, T(1), m4two, m4bye}, {{2, {0, 1}}, {}}, {{}, {}}, {}},
    {"2 2 (if>)", {m4_if_more_, T(1), m4one, m4bye}, {{2, {2, 2}}, {}}, {{}, {}}, {}},
    {"4 3 (if>)", {m4_if_more_, T(1), m4zero, m4bye}, {{2, {4, 3}}, {}}, {{1, {0}}, {}}, {}},
    {"0 1 (if>=)", {m4_if_more_equal_, T(1), m4two, m4bye}, {{2, {0, 1}}, {}}, {{}, {}}, {}},
    {"2 2 (if>=)", {m4_if_more_equal_, T(1), m4one, m4bye}, {{2, {2, 2}}, {}}, {{1, {1}}, {}}, {}},
    {"4 3 (if>=)", {m4_if_more_equal_, T(1), m4zero, m4bye}, {{2, {4, 3}}, {}}, {{1, {0}}, {}}, {}},
    {"(jump) T(0)", {m4_jump_, T(0), m4bye, m4_missing_}, {{}, {}}, {{}, {}}, {}},
    {"(jump) T(1)", {m4_jump_, T(1), m4true, m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(leave)", {m4_leave_, T(0), m4bye}, {{}, {2, {0, 1}}}, {{}, {}}, {}},
    {"0 0 (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {0, 0}}}, {{}, {2, {0, 1}}}, {}},
    {"0 1 (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {0, 1}}}, {{}, {2, {0, 2}}}, {}},
    {"1 0 (loop)", {m4_loop_, T(0), m4bye}, {{}, {2, {1, 0}}}, {{}, {}}, {}},
    {"10 0 (do) (loop)", {m4_do_, m4_loop_, T(-2), m4bye}, {{2, {10, 0}}, {}}, {{}, {}}, {}},
    {"5 0 (do) i (loop)",
     {m4_do_, m4i, m4_loop_, T(-3), m4bye},
     {{2, {5, 0}}, {}},
     {{5, {0, 1, 2, 3, 4}}, {}},
     {}},
    {"0 1M 0 (do) i + (loop)",
     {m4_do_, m4i, m4plus, m4_loop_, T(-4), m4bye},
     {{3, {0, (m4cell)1e6, 0}}, {}},
     {{1, {499999500000l}}, {}},
     {}},
    /* ----------------------------- literal, compile ----------------------- */
    {"(lit-token) T(7)", {m4_lit_token_, T(7), m4bye}, {{}, {}}, {{1, {7}}, {}}, {}},
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
    {"0x123 (compile-token,)",
     {m4_compile_token_, m4bye},
     {{1, {0x123}}, {}},
     {{}, {}},
     {1, {0x123}}},
    {"(compile-lit-token,) T(500)",
     {m4_compile_lit_token_, T(500), m4bye},
     {{}, {}},
     {{}, {}},
     {1, {500}}},
    /* ----------------------------- call ----------------------------------- */
    {"(call) XT(false)", {m4_call_, XT(false), m4bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"(call) XT(noop)", {m4_call_, XT(noop), m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(call) XT(true)", {m4_call_, XT(true), m4bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"(call) XT(crc+)",
     {m4_call_, CELL(crc1byte_tarray), m4bye},
     {{2, {0xffffffff, 't'}}, {}},
     {{1, {2056627543 /* crc1byte(0xffffffff, 't')*/}}, {}},
     {}},
    {"(ip)", {m4_ip_, m4bye}, {{}, {}}, {{1, {-1 /* fixed by m4testexecute_fix() */}}, {}}, {}},
    /* ----------------------------- [token-gives-cell?] -------------------- */
    {"0 'zero [token-gives-cell?]",
     {m4_call_, XT(_token_gives_cell_q_), m4bye},
     {{2, {0, m4zero}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"1 'zero [token-gives-cell?]",
     {m4_call_, XT(_token_gives_cell_q_), m4bye},
     {{2, {1, m4zero}}, {}},
     {{2, {1, tfalse}}, {}},
     {}},
    {"1 'one [token-gives-cell?]",
     {m4_call_, XT(_token_gives_cell_q_), m4bye},
     {{2, {1, m4one}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"3 'three [token-gives-cell?]",
     {m4_call_, XT(_token_gives_cell_q_), m4bye},
     {{2, {3, m4three}}, {}},
     {{2, {m4three, ttrue}}, {}},
     {}},
    {"7 'eight [token-gives-cell?]",
     {m4_call_, XT(_token_gives_cell_q_), m4bye},
     {{2, {7, m4eight}}, {}},
     {{2, {7, tfalse}}, {}},
     {}},
    {"8 'eight [token-gives-cell?]",
     {m4_call_, XT(_token_gives_cell_q_), m4bye},
     {{2, {8, m4eight}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    {"8 'eight [token-gives-cell?]",
     {m4_call_, XT(_token_gives_cell_q_), m4bye},
     {{2, {8, m4eight}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    {"8 NULL 0 [any-token-gives-cell?]",
     {m4_call_, XT(_any_token_gives_cell_q_), m4bye},
     {{3, {8, (m4cell)NULL, 0}}, {}},
     {{2, {8, tfalse}}, {}},
     {}},
#if 0     
    {"8 tarray tn [any-token-gives-cell?]",
     {m4_call_, XT(_any_token_gives_cell_q_), m4bye},
     {{3, {8, (m4cell)testdata_any_token_gives_cell_q_, 1}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
#endif
#endif
};

enum { testexecute_n = sizeof(testexecute) / sizeof(testexecute[0]) };

static void m4testexecute_fix(m4testexecute *t, m4test_word *w) {
    switch (t->code[0]) {
    case m4_ip_:
        t->after.d.data[0] = (m4cell)w->code;
        break;
    }
}

static m4cell m4testexecute_run(m4th *m, m4testexecute *t, m4test_word *w) {
    m4slice t_code = {(m4cell *)t->code, m4test_code_n};
    m4slice t_codegen_in = {(m4cell *)t->codegen.data, t->codegen.n};
    m4token buf[m4test_code_n];
    m4code t_codegen = {buf, m4test_code_n};

    m4testexecute_fix(t, w);

    memset(w, '\0', sizeof(m4test_word));
    m4th_clear(m);
    m4slice_copy_to_word_code(t_code, &w->impl);
    m4slice_copy_to_code(t_codegen_in, &t_codegen);
    m4test_stack_copy(&t->before.d, &m->dstack);
    m4test_stack_copy(&t->before.r, &m->rstack);

    m->w = &w->impl;
    m->ip = w->code;
    m4th_run_vm(m);

    return m4test_stack_equal(&t->after.d, &m->dstack) &&
           m4test_stack_equal(&t->after.r, &m->rstack) &&
           /**/ m4code_equal(t_codegen, m4word_code(m->w, m4test_code_n));
}

static void m4testexecute_failed(m4th *m, const m4testexecute *t, FILE *out) {
    if (out == NULL) {
        return;
    }
    fprintf(out, "execute test failed: %s\n", t->name);
    fputs("    expected  data  stack ", out);
    m4test_stack_print(&t->after.d, out);
    fputs("      actual  data  stack ", out);
    m4stack_print(&m->dstack, out);

    fputs("... expected return stack ", out);
    m4test_stack_print(&t->after.r, out);
    fputs("      actual return stack ", out);
    m4stack_print(&m->rstack, out);

    if (t->codegen.n == 0 && m->w->code_n == 0) {
        return;
    }
    fputs("... expected    codegen   ", out);
    m4test_code_print(&t->codegen, out);
    fputs("      actual    codegen   ", out);
    m4word_code_print(m->w, m4test_code_n, out);
}

m4cell m4th_testexecute(m4th *m, FILE *out) {
    m4test_word w;
    m4cell i, fail = 0;
    enum { n = testexecute_n };

    crcfill(crctable);

    /* printf("crc('t') = %u\n", (unsigned)crc1byte(0xffffffff, 't')); */

    m4array_copy_to_tarray(crc1byte_array, crc1byte_tarray);

    for (i = 0; i < n; i++) {
        if (!m4testexecute_run(m, &testexecute[i], &w)) {
            fail++, m4testexecute_failed(m, &testexecute[i], out);
        }
    }
    if (out != NULL) {
        if (fail == 0) {
            fprintf(out, "all %3u execute tests passed\n", (unsigned)n);
        } else {
            fprintf(out, "\nexecute tests failed: %3u of %3u\n", (unsigned)fail, (unsigned)n);
        }
    }
    return fail;
}

#endif /* M4TH_T_TESTEXECUTE_C */
