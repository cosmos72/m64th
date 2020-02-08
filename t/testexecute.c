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
#include "../include/err.h"
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
    m4over, m4xor,   m4_lit_, T(0xff), m4and, m4cells,  m4_lit_cell_, CELL(crctable),
    m4plus, m4fetch, m4swap,  m4_lit_, T(8),  m4rshift, m4xor,        m4exit,
};
/* initialized by m4th_testexecute() */
static m4token crc1byte_tarray[N_OF(crc1byte_array)];

/* -------------- [any-token-gives-cell?] -------------- */

static const m4token testdata_any[] = {
    m4zero, m4one, m4minus_one, m4two, m4four, m4eight,
};

/* -------------- m4test -------------- */

/* static m4char testbuf_in[16] = "foobar", testbuf_out[16] = "###############"; */

static m4testexecute testexecute_a[] = {
#if 0
    {"cmove",
     {m4cmove, m4bye},
     {{3, {(m4cell)testbuf_in, (m4cell)testbuf_out, 6}}, {}},
     {{}, {}},
     {}},
    {"1e9 0 do loop", {m4do, m4_loop_, T(-2), m4bye}, {{2, {1e9, 0}}, {}}, {{}, {}}, {}},
#else
    /* ----------------------------- arithmetic ----------------------------- */
    {"*", {m4times, m4bye}, {{2, {20, 7}}, {}}, {{1, {140}}, {}}, {}},
    {"-3 2 +", {m4plus, m4bye}, {{2, {-3, 2}}, {}}, {{1, {-1}}, {}}, {}},
    {"3 4 -", {m4minus, m4bye}, {{2, {3, 4}}, {}}, {{1, {-1}}, {}}, {}},
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
    {"n 2/", {m4two_div, m4bye}, {{1, {-5}}, {}}, {{1, {-2}}, {}}, {}},
    {"u 2/", {m4two_div, m4bye}, {{1, {5}}, {}}, {{1, {2}}, {}}, {}},
    {"2drop", {m4two_drop, m4bye}, {{2, {0, 5}}, {}}, {{}, {}}, {}},
    {"_ 2drop", {m4two_drop, m4bye}, {{3, {-3, -2, -1}}, {}}, {{1, {-3}}, {}}, {}},
    {"2dup", {m4two_dup, m4bye}, {{2, {8, 9}}, {}}, {{4, {8, 9, 8, 9}}, {}}, {}},
    {"2nip", {m4two_nip, m4bye}, {{4, {1, 2, 3, 4}}, {}}, {{2, {3, 4}}, {}}, {}},
    {"2swap", {m4two_swap, m4bye}, {{4, {1, 2, 3, 4}}, {}}, {{4, {3, 4, 1, 2}}, {}}, {}},
    {"3", {m4three, m4bye}, {{}, {}}, {{1, {3}}, {}}, {}},
    {"4", {m4four, m4bye}, {{}, {}}, {{1, {4}}, {}}, {}},
    {"4*", {m4four_times, m4bye}, {{1, {-7}}, {}}, {{1, {-28}}, {}}, {}},
    {"4+", {m4four_plus, m4bye}, {{1, {-7}}, {}}, {{1, {-3}}, {}}, {}},
    {"n 4/", {m4four_div, m4bye}, {{1, {-27}}, {}}, {{1, {-6}}, {}}, {}},
    {"u 4/", {m4four_div, m4bye}, {{1, {15}}, {}}, {{1, {3}}, {}}, {}},
    {"8", {m4eight, m4bye}, {{}, {}}, {{1, {8}}, {}}, {}},
    {"8*", {m4eight_times, m4bye}, {{1, {-3}}, {}}, {{1, {-24}}, {}}, {}},
    {"8+", {m4eight_plus, m4bye}, {{1, {-3}}, {}}, {{1, {5}}, {}}, {}},
    {"n 8/", {m4eight_div, m4bye}, {{1, {-25}}, {}}, {{1, {-3}}, {}}, {}},
    {"u 8/", {m4eight_div, m4bye}, {{1, {31}}, {}}, {{1, {3}}, {}}, {}},
    /*                                                                          */
    {"0 ?dup", {m4question_dup, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"1 ?dup", {m4question_dup, m4bye}, {{1, {1}}, {}}, {{2, {1, 1}}, {}}, {}},
    {"0 abs", {m4abs, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"11 abs", {m4abs, m4bye}, {{1, {11}}, {}}, {{1, {11}}, {}}, {}},
    {"-3 abs", {m4abs, m4bye}, {{1, {-3}}, {}}, {{1, {3}}, {}}, {}},
    {"-7 14 and", {m4and, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 & 14}}, {}}, {}},
    {"bl", {m4bl, m4bye}, {{}, {}}, {{1, {' '}}, {}}, {}},
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
    {"20 7 mod", {m4mod, m4bye}, {{2, {20, 7}}, {}}, {{1, {6}}, {}}, {}},
    {"-20 7 mod", {m4mod, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-6}}, {}}, {}},
    {"negate", {m4negate, m4bye}, {{1, {-12}}, {}}, {{1, {12}}, {}}, {}},
    {"nip", {m4nip, m4bye}, {{2, {3, 4}}, {}}, {{1, {4}}, {}}, {}},
    {"noop", {m4noop, m4bye}, {{}, {}}, {{}, {}}, {}},
    {"-7 14 or", {m4or, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 | 14}}, {}}, {}},
    {"over", {m4over, m4bye}, {{2, {1, 0}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"rot", {m4rot, m4bye}, {{3, {1, 2, 3}}, {}}, {{3, {2, 3, 1}}, {}}, {}},
    {"-rot", {m4minus_rot, m4bye}, {{3, {1, 2, 3}}, {}}, {{3, {3, 1, 2}}, {}}, {}},
    {"rshift", {m4rshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 >> 3}}, {}}, {}},
    {"swap", {m4swap, m4bye}, {{2, {4, 5}}, {}}, {{2, {5, 4}}, {}}, {}},
    {"true", {m4true, m4bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"tuck", {m4tuck, m4bye}, {{2, {0, 1}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"unloop", {m4unloop, m4bye}, {{}, {3, {1, 2, 3}}}, {{}, {1, {1}}}, {}},
    {"-7 14 xor", {m4xor, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 ^ 14}}, {}}, {}},
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
    {"0 (?if0)", {m4_q_if_zero_, T(1), m4three, m4bye}, {{1, {0}}, {}}, {{2, {0, 3}}, {}}, {}},
    {"1 (?if0)", {m4_q_if_zero_, T(1), m4four, m4bye}, {{1, {1}}, {}}, {{1, {1}}, {}}, {}},
    {"0 (if)", {m4_if_, T(1), m4two, m4bye}, {{1, {0}}, {}}, {{}, {}}, {}},
    {"1 (if)", {m4_if_, T(1), m4four, m4bye}, {{1, {1}}, {}}, {{1, {4}}, {}}, {}},
    {"0 (if0)", {m4_if_zero_, T(1), m4two, m4bye}, {{1, {0}}, {}}, {{1, {2}}, {}}, {}},
    {"1 (if0)", {m4_if_zero_, T(1), m4three, m4bye}, {{1, {1}}, {}}, {{}, {}}, {}},
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

#define TESTSTR(name) ((m4cell)teststr##name), (sizeof(teststr##name) - 1)
#define TESTSTR_(name, delta) (m4cell)(teststr##name + delta), (sizeof(teststr##name) - delta - 1)
#define STRING(s) ((m4cell)(s)), (sizeof(s) - 1)

static m4testexecute testexecute_d[] = {
#if 1
    /* ----------------------------- literal, compile, (call) --------------- */
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
    {"0x123 (compile-token,)",
     {m4_compile_token_, m4bye},
     {{1, {0x123}}, {}},
     {{}, {}},
     {1, {0x123}}},
    {"[compile-lit,] T(500)", {m4_compile_lit_, T(500), m4bye}, {{}, {}}, {{}, {}}, {1, {500}}},
    /* ----------------------------- execute, call -------------------------- */
    {"(call) XT(false)", {CALLXT(false), m4bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"(call) XT(noop)", {CALLXT(noop), m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(call) XT(true)", {CALLXT(true), m4bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"(call) XT(crc+)",
     {m4_call_, CELL(crc1byte_tarray), m4bye},
     {{2, {0xffffffff, 't'}}, {}},
     {{1, {2056627543 /* crc1byte(0xffffffff, 't')*/}}, {}},
     {}},
    {"' one (exec-native)",
     {m4_exec_native_, m4bye},
     {{1, {(m4cell)m4fone}}, {}},
     {{1, {1}}, {}},
     {}},
    {"' noop (exec-native)", {m4_exec_native_, m4bye}, {{1, {(m4cell)m4fnoop}}, {}}, {{}, {}}, {}},
    {"' one (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4one}}, {}}, {{1, {1}}, {}}, {}},
    {"' noop (exec-token)", {m4_exec_token_, m4bye}, {{1, {m4noop}}, {}}, {{}, {}}, {}},
    {"' noop execute", {m4execute, m4bye}, {{1, {(m4cell)m4word_noop.code}}, {}}, {{}, {}}, {}},
    {"' eight execute",
     {m4execute, m4bye},
     {{1, {(m4cell)m4word_eight.code}}, {}},
     {{1, {8}}, {}},
     {}},
    {"6 7 ' plus execute",
     {m4execute, m4bye},
     {{3, {6, 7, (m4cell)m4word_plus.code}}, {}},
     {{1, {13}}, {}},
     {}},
    {"(ip)", {m4_ip_, m4bye}, {{}, {}}, {{1, {-1 /* fixed by m4testexecute_fix() */}}, {}}, {}},
    {"(ip>body)",
     {m4_ip_to_body_, m4bye},
     {{}, {}},
     {{1, {-1 /* fixed by m4testexecute_fix() */}}, {}},
     {}},
    /* ----------------------------- [token-gives-cell?] -------------------- */
    {"0 'zero [token-gives-cell?]",
     {CALLXT(_token_gives_cell_q_), m4bye},
     {{2, {0, m4zero}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"1 'zero [token-gives-cell?]",
     {CALLXT(_token_gives_cell_q_), m4bye},
     {{2, {1, m4zero}}, {}},
     {{2, {1, tfalse}}, {}},
     {}},
    {"1 'one [token-gives-cell?]",
     {CALLXT(_token_gives_cell_q_), m4bye},
     {{2, {1, m4one}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"3 'three [token-gives-cell?]",
     {CALLXT(_token_gives_cell_q_), m4bye},
     {{2, {3, m4three}}, {}},
     {{2, {m4three, ttrue}}, {}},
     {}},
    {"7 'eight [token-gives-cell?]",
     {CALLXT(_token_gives_cell_q_), m4bye},
     {{2, {7, m4eight}}, {}},
     {{2, {7, tfalse}}, {}},
     {}},
    {"8 'eight [token-gives-cell?]",
     {CALLXT(_token_gives_cell_q_), m4bye},
     {{2, {8, m4eight}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    {"8 'eight [token-gives-cell?]",
     {CALLXT(_token_gives_cell_q_), m4bye},
     {{2, {8, m4eight}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    /* ----------------------------- [any-token-gives-cell?] ---------------- */
    {"8 NULL 0 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {8, (m4cell)NULL, 0}}, {}},
     {{2, {8, tfalse}}, {}},
     {}},
    {"0 NULL 0 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {0, (m4cell)NULL, 0}}, {}},
     {{2, {0, tfalse}}, {}},
     {}},
    {"0 tarray 1 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {0, (m4cell)testdata_any, 1}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"0 tarray 2 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {0, (m4cell)testdata_any, 2}}, {}},
     {{2, {m4zero, ttrue}}, {}},
     {}},
    {"1 NULL 0 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)NULL, 0}}, {}},
     {{2, {1, tfalse}}, {}},
     {}},
    {"1 tarray 1 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)testdata_any, 1}}, {}},
     {{2, {1, tfalse}}, {}},
     {}},
    {"1 tarray 2 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)testdata_any, 2}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"1 tarray tn [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {1, (m4cell)testdata_any, N_OF(testdata_any)}}, {}},
     {{2, {m4one, ttrue}}, {}},
     {}},
    {"-1 tarray 2 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {-1, (m4cell)testdata_any, 2}}, {}},
     {{2, {-1, tfalse}}, {}},
     {}},
    {"-1 tarray 3 [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {-1, (m4cell)testdata_any, 3}}, {}},
     {{2, {m4minus_one, ttrue}}, {}},
     {}},
    {"-1 tarray tn [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {-1, (m4cell)testdata_any, N_OF(testdata_any)}}, {}},
     {{2, {m4minus_one, ttrue}}, {}},
     {}},
    {"8 tarray tn [any-token-gives-cell?]",
     {CALLXT(_any_token_gives_cell_q_), m4bye},
     {{3, {8, (m4cell)testdata_any, N_OF(testdata_any)}}, {}},
     {{2, {m4eight, ttrue}}, {}},
     {}},
    /* ----------------------------- char>... string>... -------------------- */
    {"'#' char>base", {CALLXT(char_to_base), m4bye}, {{1, {'#'}}, {}}, {{1, {10}}, {}}, {}},
    {"'$' char>base", {CALLXT(char_to_base), m4bye}, {{1, {'$'}}, {}}, {{1, {16}}, {}}, {}},
    {"'%' char>base", {CALLXT(char_to_base), m4bye}, {{1, {'%'}}, {}}, {{1, {2}}, {}}, {}},
    {"'&' char>base", {CALLXT(char_to_base), m4bye}, {{1, {'&'}}, {}}, {{1, {0}}, {}}, {}},
    {"'\"' char>base", {CALLXT(char_to_base), m4bye}, {{1, {'"'}}, {}}, {{1, {0}}, {}}, {}},
    {"\"\" string>base",
     {CALLXT(string_to_base), m4bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{3, {TESTSTR(_empty), 10}}, {}},
     {}},
    {"\"#\" string>base",
     {CALLXT(string_to_base), m4bye},
     {{2, {TESTSTR(_hash)}}, {}},
     {{3, {TESTSTR_(_hash, 1), 10}}, {}},
     {}},
    {"\"$\" string>base",
     {CALLXT(string_to_base), m4bye},
     {{2, {TESTSTR(_dollar)}}, {}},
     {{3, {TESTSTR_(_dollar, 1), 16}}, {}},
     {}},
    {"\"%\" string>base",
     {CALLXT(string_to_base), m4bye},
     {{2, {TESTSTR(_percent)}}, {}},
     {{3, {TESTSTR_(_percent, 1), 2}}, {}},
     {}},
    {"\"0\" string>base",
     {CALLXT(string_to_base), m4bye},
     {{2, {TESTSTR(_0)}}, {}},
     {{3, {TESTSTR(_0), 10}}, {}},
     {}},
    {"\"''\" string>char",
     {CALLXT(string_to_char), m4bye},
     {{2, {TESTSTR(_quoted)}}, {}},
     {{3, {TESTSTR(_quoted), -1}}, {}},
     {}},
    {"\"'x'\" string>char",
     {CALLXT(string_to_char), m4bye},
     {{2, {TESTSTR(_quoted_x)}}, {}},
     {{3, {TESTSTR_(_quoted_x, 3), 'x'}}, {}},
     {}},
    {"\"(y'\" string>char",
     {CALLXT(string_to_char), m4bye},
     {{2, {TESTSTR(_lparen_y_quote)}}, {}},
     {{3, {TESTSTR(_lparen_y_quote), -1}}, {}},
     {}},
    {"\"'z)\" string>char",
     {CALLXT(string_to_char), m4bye},
     {{2, {TESTSTR(_quote_z_rparen)}}, {}},
     {{3, {TESTSTR(_quote_z_rparen), -1}}, {}},
     {}},
    {"\"'00'\" string>char",
     {CALLXT(string_to_char), m4bye},
     {{2, {TESTSTR(_quoted_00)}}, {}},
     {{3, {TESTSTR(_quoted_00), -1}}, {}},
     {}},
#endif
    {"\"\" string>sign",
     {CALLXT(string_to_sign), m4bye},
     {{2, {TESTSTR(_empty)}}, {}},
     {{3, {TESTSTR(_empty), 1}}, {}},
     {}},
    /* ----------------------------- valid-base? ---------------------------- */
    {"0 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {0}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"1 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {1}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"2 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {2}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"3 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {3}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"10 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {10}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"16 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {16}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"35 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {35}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"36 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {36}}, {}}, {{1, {ttrue}}, {}}, {}},
    {"37 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {37}}, {}}, {{1, {tfalse}}, {}}, {}},
    {"38 valid-base?", {CALLXT(valid_base_q), m4bye}, {{1, {38}}, {}}, {{1, {tfalse}}, {}}, {}},
    /* ----------------------------- char>u --------------------------------- */
    {"'/' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'/'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'0' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'0'}}, {}}, {{1, {0}}, {}}, {}},
    {"'9' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'9'}}, {}}, {{1, {9}}, {}}, {}},
    {"':' char>u", {CALLXT(char_to_u), m4bye}, {{1, {':'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'@' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'@'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'A' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'A'}}, {}}, {{1, {10}}, {}}, {}},
    {"'Z' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'Z'}}, {}}, {{1, {35}}, {}}, {}},
    {"'[' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'['}}, {}}, {{1, {-1}}, {}}, {}},
    {"'`' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'`'}}, {}}, {{1, {-1}}, {}}, {}},
    {"'a' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'a'}}, {}}, {{1, {10}}, {}}, {}},
    {"'z' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'z'}}, {}}, {{1, {35}}, {}}, {}},
    {"'{' char>u", {CALLXT(char_to_u), m4bye}, {{1, {'{'}}, {}}, {{1, {-1}}, {}}, {}},
};

static const char teststr_z_[] = "z:";
static const char teststr_0az[] = "0az";
static const char teststr_1011[] = "1011";
static const char teststr_12345a[] = "12345a";
static const char teststr_123defg[] = "123defg";
static const char teststr_ffffffff[] = "ffffffff";
static const char teststr_1234567890[] = "1234567890";
static const char teststr_4294967295[] = "4294967295";
static const char teststr_ffffffffffffffff[] = "ffffffffffffffff";
static const char teststr_18446744073709551615[] = "18446744073709551615";

static m4testexecute testexecute_e[] = {
    /* ----------------------------- string&base>u -------------------------- */
    {"\"\" 10 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_empty), 10}}, {}},
     {{3, {TESTSTR(_empty), 0}}, {}},
     {}},
    {"\"1011\" 2 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_1011), 2}}, {}},
     {{3, {TESTSTR_(_1011, 4), 0xb}}, {}},
     {}},
    {"\"12345a\" 2 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_12345a), 2}}, {}},
     {{3, {TESTSTR_(_12345a, 1), 0x1}}, {}},
     {}},
    {"\"12345a\" 10 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_12345a), 10}}, {}},
     {{3, {TESTSTR_(_12345a, 5), 12345}}, {}},
     {}},
    {"\"1234567890\" 10 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_1234567890), 10}}, {}},
     {{3, {TESTSTR_(_1234567890, 10), 1234567890}}, {}},
     {}},
    {"\"4294967295\" 10 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_4294967295), 10}}, {}},
     {{3, {TESTSTR_(_4294967295, 10), (m4cell)4294967295ul}}, {}},
     {}},
    {"\"12345a\" 10 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_12345a), 16}}, {}},
     {{3, {TESTSTR_(_12345a, 6), 0x12345a}}, {}},
     {}},
    {"\"123defg\" 16 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_123defg), 16}}, {}},
     {{3, {TESTSTR_(_123defg, 6), 0x123def}}, {}},
     {}},
    {"\"ffffffff\" 16 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_ffffffff), 16}}, {}},
     {{3, {TESTSTR_(_ffffffff, 8), (m4cell)0xfffffffful}}, {}},
     {}},
#if SZ >= 8
    {"\"18446744073709551615\" 10 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_18446744073709551615), 10}}, {}},
     {{3, {TESTSTR_(_18446744073709551615, 20), (m4cell)18446744073709551615ul}}, {}},
     {}},
    {"\"ffffffffffffffff\" 16 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_ffffffffffffffff), 16}}, {}},
     {{3, {TESTSTR_(_ffffffffffffffff, 16), (m4cell)0xfffffffffffffffful}}, {}},
     {}},
#endif
    {"\"0az\" 36 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_0az), 36}}, {}},
     {{3, {TESTSTR_(_0az, 3), 395}}, {}},
     {}},
    {"\"z:\" 36 string&base>u",
     {CALLXT(string_base_to_u), m4bye},
     {{3, {TESTSTR(_z_), 36}}, {}},
     {{3, {TESTSTR_(_z_, 1), 35}}, {}},
     {}},
#if 0
    /* ----------------------------- >number -------------------------------- */
    {"\"\" >number",
     {CALLXT(to_number), m4bye},
     {{4, {0, 0, TESTSTR(_empty)}}, {}},
     {{4, {0, 0, TESTSTR(_empty)}}, {}},
     {}},
    {"\"12345a\" >number",
     {CALLXT(to_number), m4bye},
     {{4, {0, 0, TESTSTR(_12345a)}}, {}},
     {{4, {12345, 0, TESTSTR_(_12345a, 5)}}, {}},
     {}},
    {"\"1234567890\" >number",
     {CALLXT(to_number), m4bye},
     {{4, {0, 0, TESTSTR(_1234567890)}}, {}},
     {{4, {1234567890, 0, TESTSTR_(_1234567890, 10)}}, {}},
     {}},
    {"\"4294967295\" >number",
     {CALLXT(to_number), m4bye},
     {{4, {0, 0, TESTSTR(_4294967295)}}, {}},
     {{4, {(m4cell)4294967295ul, 0, TESTSTR_(_4294967295, 10)}}, {}},
     {}},
#if SZ >= 8
    {"\"18446744073709551615\" >number",
     {CALLXT(to_number), m4bye},
     {{4, {0, 0, TESTSTR(_18446744073709551615)}}, {}},
     {{4, {(m4cell)18446744073709551615ul, 0, TESTSTR_(_18446744073709551615, 20)}}, {}},
     {}},
#endif
#endif /* 0 */
};

static m4testexecute testexecute_f[] = {
    /* ----------------------------- compile, ------------------------------- */
    {"' noop xt>flags",
     {CALLXT(xt_to_flags), m4bye},
     {{1, {(m4cell)m4word_noop.code}}, {}},
     {{1, {WORD_PURE}}, {}},
     {}},
    {"' noop xt>code",
     {m4xt_to_code, m4bye},
     {{1, {(m4cell)m4word_noop.code}}, {}},
     {{2, {(m4cell)m4word_noop.code, 2}}, {}},
     {}},
    {"' (if) xt-inline?",
     {CALLXT(xt_inline_query), m4bye},
     {{1, {(m4cell)m4word__if_.code}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' + xt-inline?",
     {CALLXT(xt_inline_query), m4bye},
     {{1, {(m4cell)m4word_plus.code}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' if xt-inline?",
     {CALLXT(xt_inline_query), m4bye},
     {{1, {(m4cell)m4word_if.code}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' noop xt-inline?",
     {CALLXT(xt_inline_query), m4bye},
     {{1, {(m4cell)m4word_noop.code}}, {}},
     {{1, {ttrue}}, {}},
     {}},
    {"' literal xt-inline?",
     {CALLXT(xt_inline_query), m4bye},
     {{1, {(m4cell)m4word_literal.code}}, {}},
     {{1, {tfalse}}, {}},
     {}},
    {"' xt-inline? xt-inline?",
     {CALLXT(xt_inline_query), m4bye},
     {{1, {(m4cell)m4word_xt_inline_query.code}}, {}},
     {{1, {tfalse}}, {}},
     {}},
    {"' + [inline]",
     {CALLXT(_inline_), m4bye},
     {{1, {(m4cell)m4word_plus.code}}, {}},
     {{}, {}},
     {1, {m4plus}}},
    {"' 1 [inline] ' 3 [inline] ' + [inline]",
     {CALLXT(_inline_), CALLXT(_inline_), CALLXT(_inline_), m4bye},
     {{3, {(m4cell)m4word_plus.code, (m4cell)m4word_three.code, (m4cell)m4word_one.code}}, {}},
     {{}, {}},
     {3, {m4one, m4three, m4plus}}},
    {"' noop compile,",
     {CALLXT(compile_comma), m4bye},
     {{1, {(m4cell)m4word_noop.code}}, {}},
     {{}, {}},
     {1, {m4noop}}},
    {"' 1+ compile, ' and compile,",
     {CALLXT(compile_comma), CALLXT(compile_comma), m4bye},
     {{2, {(m4cell)m4word_and.code, (m4cell)m4word_one_plus.code}}, {}},
     {{}, {}},
     {2, {m4one_plus, m4and}}},
};

static void m4testexecute_fix(m4testexecute *t, m4test_word *w) {
    switch (t->code[0]) {
    case m4_ip_:
        t->after.d.data[0] = (m4cell)w->code;
        break;
    case m4_ip_to_body_:
        t->after.d.data[0] = (m4cell)m4word_data(&w->impl, 0).data;
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
    m4th_run(m);

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

typedef struct m4testcount_s {
    m4cell failed;
    m4cell total;
} m4testcount;

void m4th_testexecute_bunch(m4th *m, m4testexecute bunch[], m4cell n, m4testcount *count,
                            FILE *out) {
    m4test_word w;
    m4cell i, fail = 0;
    for (i = 0; i < n; i++) {
        if (!m4testexecute_run(m, &bunch[i], &w)) {
            fail++, m4testexecute_failed(m, &bunch[i], out);
        }
    }
    count->failed += fail;
    count->total += n;
}

m4cell m4th_testexecute(m4th *m, FILE *out) {
    m4testcount count = {};
    crcfill(crctable);
    m4array_copy_to_tarray(crc1byte_array, crc1byte_tarray);
    /* printf("crc('t') = %u\n", (unsigned)crc1byte(0xffffffff, 't')); */

#if 1
    m4th_testexecute_bunch(m, testexecute_a, N_OF(testexecute_a), &count, out);
    m4th_testexecute_bunch(m, testexecute_b, N_OF(testexecute_b), &count, out);
    m4th_testexecute_bunch(m, testexecute_c, N_OF(testexecute_c), &count, out);
#endif
    m4th_testexecute_bunch(m, testexecute_d, N_OF(testexecute_d), &count, out);
    m4th_testexecute_bunch(m, testexecute_e, N_OF(testexecute_e), &count, out);
    m4th_testexecute_bunch(m, testexecute_f, N_OF(testexecute_f), &count, out);

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
