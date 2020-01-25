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

#include "../common/enum.h"
#include "../common/word_fwd.h"
#include "../impl.h"
#include "../m4th.h"
#include "testcommon.h"

#include <assert.h> /* assert()          */

typedef m4long m4test_code_array[m4test_code_n];

typedef struct m4testexecute_s {
    const char *name;
    m4test_code_array code;
    m4test_stacks before, after;
    m4test_code codegen;
} m4testexecute;

/* -------------- crc -------------- */

static m4long crctable[256];

static void crcfill(m4long table[256]) {
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

#if 0
static uint32_t crc1byte(uint32_t crc, unsigned char byte) {
    assert(crctable[0xff]);
    return (crc >> 8) ^ crctable[(crc & 0xff) ^ byte];
}
#endif /* 0 */

/**
 * compiled forth version of crc1byte above. forth source would be
 * : crc+ ( crc char -- crc' )
 *   over xor 0xff and  cells crctable + @  swap 8 rshift xor
 * ;
 */
static const m4long test_func_crc1byte[] = {
    m4over, m4xor,   m4_literal2s_, 0xff,          m4and, m4cells,  m4_lit_cell_, CELL(crctable),
    m4plus, m4fetch, m4swap,        m4_literal2s_, 8,     m4rshift, m4xor,        m4exit,
};

/* -------------- m4test -------------- */

static const m4testexecute testexecute[] = {
#if 0
    {"1G 0 (do) (loop)", {m4_do_, m4_loop_, (m4enum)0, m4bye}, {{2, {1e9, 0}}, {}}, {{}, {}}, {}},
#else
    {"0 0 (?do)", {m4_question_do_, (m4enum)2, m4bye}, {{2, {0, 0}}, {}}, {{}, {}}, {}},
    {"1 0 (?do)", {m4_question_do_, (m4enum)2, m4bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"(call) (inline)", {CALLXT(_inline_), m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(call) (optimize)", {CALLXT(_optimize_), m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(call) false", {CALLXT(false), m4bye}, {{}, {}}, {{1, {}}, {}}, {}},
#if 0
    {"(call) noop", {CALLXT(noop), m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(call) true", {CALLXT(true), m4bye}, {{}, {}}, {{1, {-1}}, {}}, {}},
    {"(call) crc+",
     {m4_call_, (m4enum)test_func_crc1byte, m4bye},
     {{2, {0xffffffff, 't'}}, {}},
     {{1, {0x7a95a557 /* crc1byte(0xffffffff, 't') */}}, {}},
     {}},
    {"0x123 (compile,)",
     {m4_compile_comma_, m4bye},
     {{1, {0x123}}, {}},
     {{}, {}},
     {1, {(m4enum)0x123}}},
    {"0 1 (do)", {m4_do_, m4bye}, {{2, {0, 1}}, {}}, {{}, {2, {0, 1}}}, {}},
    {"1 0 (do)", {m4_do_, m4bye}, {{2, {1, 0}}, {}}, {{}, {2, {1, 0}}}, {}},
    {"0 (else)", {m4_else_, (m4enum)3, m4two, m4bye}, {{1, {}}, {}}, {{1, {2}}, {}}, {}},
    {"1 (else)", {m4_else_, (m4enum)3, m4four, m4bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"0 (if)", {m4_if_, (m4enum)3, m4two, m4bye}, {{1, {}}, {}}, {{}, {}}, {}},
    {"1 (if)", {m4_if_, (m4enum)3, m4four, m4bye}, {{1, {1}}, {}}, {{1, {4}}, {}}, {}},
    {"(jump)", {m4_jump_, (m4enum)2, m4bye}, {{}, {}}, {{}, {}}, {}},
    {"(leave)", {m4_leave_, (m4enum)2, m4bye}, {{}, {2, {0, 1}}}, {{}, {}}, {}},
    {"(lit)", {m4_lit_, (m4enum)7, m4bye}, {{}, {}}, {{1, {7}}, {}}, {}},
    {"0 0 (loop)", {m4_loop_, (m4enum)2, m4bye}, {{}, {2, {0, 0}}}, {{}, {2, {0, 1}}}, {}},
    {"0 1 (loop)", {m4_loop_, (m4enum)2, m4bye}, {{}, {2, {0, 1}}}, {{}, {2, {0, 2}}}, {}},
    {"1 0 (loop)", {m4_loop_, (m4enum)2, m4bye}, {{}, {2, {1, 0}}}, {{}, {}}, {}},
    {"10 0 (do) (loop)", {m4_do_, m4_loop_, (m4enum)0, m4bye}, {{2, {10, 0}}, {}}, {{}, {}}, {}},
    {"5 0 (do) i (loop)",
     {m4_do_, m4i, m4_loop_, (m4enum)-1, m4bye},
     {{2, {5, 0}}, {}},
     {{5, {0, 1, 2, 3, 4}}, {}},
     {}},
    {"0 1M 0 (do) i + (loop)",
     {m4_do_, m4i, m4plus, m4_loop_, (m4enum)-2, m4bye},
     {{3, {0, (m4long)1e6, 0}}, {}},
     {{1, {499999500000l}}, {}},
     {}},
#endif
    {"*", {m4times, m4bye}, {{2, {20, 7}}, {}}, {{1, {140}}, {}}, {}},
    {"-3 2 +", {m4plus, m4bye}, {{2, {-3, 2}}, {}}, {{1, {-1}}, {}}, {}},
    {"3 4 -", {m4minus, m4bye}, {{2, {3, 4}}, {}}, {{1, {-1}}, {}}, {}},
    {"-20 7 /", {m4div, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-2}}, {}}, {}},
    {"20 7 /", {m4div, m4bye}, {{2, {20, 7}}, {}}, {{1, {2}}, {}}, {}},
    {"-20 7 /mod", {m4div_mod, m4bye}, {{2, {-20, 7}}, {}}, {{2, {-6, -2}}, {}}, {}},
    {"20 7 /mod", {m4div_mod, m4bye}, {{2, {20, 7}}, {}}, {{2, {6, 2}}, {}}, {}},
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
    {"-1", {m4minus_one, m4bye}, {{}, {}}, {{1, {-1}}, {}}, {}},
    {"0", {m4zero, m4bye}, {{}, {}}, {{1, {}}, {}}, {}},
    {"1", {m4one, m4bye}, {{}, {}}, {{1, {1}}, {}}, {}},
    {"1-", {m4one_minus, m4bye}, {{1, {-3}}, {}}, {{1, {-4}}, {}}, {}},
    {"1+", {m4one_plus, m4bye}, {{1, {-6}}, {}}, {{1, {-5}}, {}}, {}},
    {"2", {m4two, m4bye}, {{}, {}}, {{1, {2}}, {}}, {}},
    {"2-", {m4two_minus, m4bye}, {{1, {-3}}, {}}, {{1, {-5}}, {}}, {}},
    {"2+", {m4two_plus, m4bye}, {{1, {-6}}, {}}, {{1, {-4}}, {}}, {}},
    {"2*", {m4two_times, m4bye}, {{1, {-6}}, {}}, {{1, {-12}}, {}}, {}},
    {"2/", {m4two_div, m4bye}, {{1, {-5}}, {}}, {{1, {-2}}, {}}, {}},
    {"3", {m4three, m4bye}, {{}, {}}, {{1, {3}}, {}}, {}},
    {"4", {m4four, m4bye}, {{}, {}}, {{1, {4}}, {}}, {}},
    {"4+", {m4four_plus, m4bye}, {{1, {-7}}, {}}, {{1, {-3}}, {}}, {}},
    {"4*", {m4four_times, m4bye}, {{1, {-7}}, {}}, {{1, {-28}}, {}}, {}},
    {"8", {m4eight, m4bye}, {{}, {}}, {{1, {8}}, {}}, {}},
    {"8+", {m4eight_plus, m4bye}, {{1, {-3}}, {}}, {{1, {5}}, {}}, {}},
    {"8*", {m4eight_times, m4bye}, {{1, {-3}}, {}}, {{1, {-24}}, {}}, {}},
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
    {">r", {m4to_r, m4bye}, {{1, {99}}, {}}, {{}, {1, {99}}}, {}},
    {"0 ?dup", {m4question_dup, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"1 ?dup", {m4question_dup, m4bye}, {{1, {1}}, {}}, {{2, {1, 1}}, {}}, {}},
    {"0 abs", {m4abs, m4bye}, {{1, {}}, {}}, {{1, {}}, {}}, {}},
    {"11 abs", {m4abs, m4bye}, {{1, {11}}, {}}, {{1, {11}}, {}}, {}},
    {"-3 abs", {m4abs, m4bye}, {{1, {-3}}, {}}, {{1, {3}}, {}}, {}},
    {"-7 14 and", {m4and, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 & 14}}, {}}, {}},
    {"bl", {m4bl, m4bye}, {{}, {}}, {{1, {' '}}, {}}, {}},
    {"cell+", {m4cell_plus, m4bye}, {{1, {12}}, {}}, {{1, {SZ + 12}}, {}}, {}},
    {"cells", {m4cells, m4bye}, {{1, {3}}, {}}, {{1, {SZ * 3}}, {}}, {}},
    {"char+", {m4char_plus, m4bye}, {{1, {6}}, {}}, {{1, {7}}, {}}, {}},
    {"chars", {m4chars, m4bye}, {{1, {8}}, {}}, {{1, {8}}, {}}, {}},
    {"depth", {m4depth, m4bye}, {{}, {}}, {{1, {}}, {}}, {}},
    {"_ depth", {m4depth, m4bye}, {{1, {3}}, {}}, {{2, {3, 1}}, {}}, {}},
    {"_ _ depth", {m4depth, m4bye}, {{2, {3, 4}}, {}}, {{3, {3, 4, 2}}, {}}, {}},
    {"drop", {m4drop, m4bye}, {{1, {1}}, {}}, {{}, {}}, {}},
    {"dup", {m4dup, m4bye}, {{1, {-5}}, {}}, {{2, {-5, -5}}, {}}, {}},
    {"false", {m4false, m4bye}, {{}, {}}, {{1, {tfalse}}, {}}, {}},
    {"i", {m4i, m4bye}, {{}, {1, {9}}}, {{1, {9}}, {1, {9}}}, {}},
    {"i*", {m4i_times, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {18}}, {1, {9}}}, {}},
    {"i+", {m4i_plus, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {11}}, {1, {9}}}, {}},
    {"i-", {m4i_minus, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {-7}}, {1, {9}}}, {}},
    {"i'", {m4i_prime, m4bye}, {{}, {2, {10, 11}}}, {{1, {10}}, {2, {10, 11}}}, {}},
    {"j", {m4j, m4bye}, {{}, {3, {12, 13, 14}}}, {{1, {12}}, {3, {12, 13, 14}}}, {}},
    {"lshift", {m4lshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 << 3}}, {}}, {}},
    {"max", {m4max, m4bye}, {{2, {1, 2}}, {}}, {{1, {2}}, {}}, {}},
    {"min", {m4min, m4bye}, {{2, {3, 4}}, {}}, {{1, {3}}, {}}, {}},
    {"20 7 mod", {m4mod, m4bye}, {{2, {20, 7}}, {}}, {{1, {6}}, {}}, {}},
    {"-20 7 mod", {m4mod, m4bye}, {{2, {-20, 7}}, {}}, {{1, {-6}}, {}}, {}},
    {"negate", {m4negate, m4bye}, {{1, {-12}}, {}}, {{1, {12}}, {}}, {}},
    {"nip", {m4nip, m4bye}, {{1, {5}}, {}}, {{}, {}}, {}},
    {"noop", {m4noop, m4bye}, {{}, {}}, {{}, {}}, {}},
    {"-7 14 or", {m4or, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 | 14}}, {}}, {}},
    {"over", {m4over, m4bye}, {{2, {1, 0}}, {}}, {{3, {1, 0, 1}}, {}}, {}},
    {"r>", {m4r_from, m4bye}, {{}, {1, {99}}}, {{1, {99}}, {}}, {}},
    {"rot", {m4rot, m4bye}, {{3, {1, 2, 3}}, {}}, {{3, {2, 3, 1}}, {}}, {}},
    {"rshift", {m4rshift, m4bye}, {{2, {99, 3}}, {}}, {{1, {99 >> 3}}, {}}, {}},
    {"swap", {m4swap, m4bye}, {{2, {4, 5}}, {}}, {{2, {5, 4}}, {}}, {}},
    {"true", {m4true, m4bye}, {{}, {}}, {{1, {ttrue}}, {}}, {}},
    {"unloop", {m4unloop, m4bye}, {{}, {3, {1, 2, 3}}}, {{}, {1, {1}}}, {}},
    {"-7 14 xor", {m4xor, m4bye}, {{2, {-7, 14}}, {}}, {{1, {-7 ^ 14}}, {}}, {}},
#endif
};

enum { testexecute_n = sizeof(testexecute) / sizeof(testexecute[0]) };

static m4long m4testexecute_run(m4th *m, const m4testexecute *t, m4test_word *w) {
    memset(w, '\0', sizeof(m4test_word));
    m4th_clear(m);
    m4test_stack_copy(&t->before.d, &m->dstack);
    m4test_stack_copy(&t->before.r, &m->rstack);
    m4test_code_copy(t->code, m4test_code_n, &w->impl);
    m->w = &w->impl;
    m->ip = w->code;
    m4th_run(m);
    return m4test_stack_equal(&t->after.d, &m->dstack) &&
           m4test_stack_equal(&t->after.r, &m->rstack) &&
           /**/ m4test_code_equal(&t->codegen, m->w, m4test_code_n);
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

    if (t->codegen.len == 0 && m->w->code_n == 0) {
        return;
    }
    fputs("... expected    codegen   ", out);
    m4test_code_print(&t->codegen, out);
    fputs("      actual    codegen   ", out);
    m4word_code_print(m->w, m4test_code_n, out);
}

m4long m4th_testexecute(m4th *m, FILE *out) {
    m4test_word w;
    m4long i, fail = 0;
    enum { n = testexecute_n };

    crcfill(crctable);

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
