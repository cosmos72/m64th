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

#include "func_decl.h"
#include "m4th.h"
#include "word_decl.h"

#include <assert.h> /* assert()          */
#include <stdio.h>  /* fprintf() fputs() */
#include <string.h> /* memcpy()          */

enum { SZ = sizeof(m4int) };

enum { m4test_code_n = 6 };
enum { m4test_stack_n = 5 };
enum { tfalse = (m4int)0, ttrue = (m4int)-1 };

typedef m4instr m4test_code[m4test_code_n];

typedef struct m4test_stack_s {
    m4int len;
    m4int data[m4test_stack_n];
} m4test_stack;

typedef struct m4test_stacks_s {
    m4test_stack d, r;
} m4test_stacks;

typedef struct m4test_s {
    const char *name;
    m4test_code code;
    m4test_stacks before, after;
    m4test_code generated;
} m4test;

static m4int crctable[256];

static void crcfill(m4int table[256]) {
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

/*
 * compiled forth version of crc1byte above. forth source would be
 * : crc+ ( crc char -- crc' )
 *   over xor 0xff and  cells crctable + @  swap 8 rshift xor
 * ;
 */
static const m4instr test_func_crc1byte[] = {
    m4over, m4xor,   m4_lit_, (m4instr)0xff, m4and,      m4cells,  m4_lit_, (m4instr)crctable,
    m4plus, m4fetch, m4swap,  m4_lit_,       (m4instr)8, m4rshift, m4xor,   m4exit,
};

static const m4test test[] = {
    {"(1))", {m4_1_, m4bye}, {{0}, {0}}, {{1, {1}}, {0}}, {}},
    {"(call) noop", {m4_call_, (m4instr)m4word_noop.code, m4bye}, {{0}, {0}}, {{0}, {0}}, {}},
    {"(call) true", {m4_call_, (m4instr)m4word_true.code, m4bye}, {{0}, {0}}, {{1, {-1}}, {0}}, {}},
    {"(call) crc+",
     {m4_call_, (m4instr)test_func_crc1byte, m4bye},
     {{2, {0xffffffff, 't'}}, {0}},
     {{1, {0x7a95a557 /* crc1byte(0xffffffff, 't') */}}, {0}},
     {}},
    {"0 1 (do)", {m4_do_, m4bye}, {{2, {0, 1}}, {0}}, {{0}, {2, {0, 1}}}, {}},
    {"1 0 (do)", {m4_do_, m4bye}, {{2, {1, 0}}, {0}}, {{0}, {2, {1, 0}}}, {}},
    {"(leave)", {m4_leave_, (m4instr)2, m4bye}, {{0}, {2, {0, 1}}}, {{0}, {0}}, {}},
    {"(lit)", {m4_lit_, (m4instr)7, m4bye}, {{0}, {0}}, {{1, {7}}, {0}}, {}},
    {"0 0 (loop)", {m4_loop_, (m4instr)2, m4bye}, {{0}, {2, {0, 0}}}, {{0}, {2, {0, 1}}}, {}},
    {"0 1 (loop)", {m4_loop_, (m4instr)2, m4bye}, {{0}, {2, {0, 1}}}, {{0}, {2, {0, 2}}}, {}},
    {"1 0 (loop)", {m4_loop_, (m4instr)2, m4bye}, {{0}, {2, {1, 0}}}, {{0}, {0}}, {}},
    {"10 0 (do) (loop)",
     {m4_do_, m4_loop_, (m4instr)0, m4bye},
     {{2, {10, 0}}, {0}},
     {{0}, {0}},
     {}},
    {"5 0 (do) i (loop)",
     {m4_do_, m4i, m4_loop_, (m4instr)-1, m4bye},
     {{2, {5, 0}}, {0}},
     {{5, {0, 1, 2, 3, 4}}, {0}},
     {}},
    {"0 1M 0 (do) i + (loop)",
     {m4_do_, m4i, m4plus, m4_loop_, (m4instr)-2, m4bye},
     {{3, {0, (m4int)1e6, 0}}, {0}},
     {{1, {499999500000l}}, {0}},
     {}},
    {"*", {m4star, m4bye}, {{2, {20, 7}}, {0}}, {{1, {140}}, {0}}, {}},
    {"-3 2 +", {m4plus, m4bye}, {{2, {-3, 2}}, {0}}, {{1, {-1}}, {0}}, {}},
    {"3 4 -", {m4minus, m4bye}, {{2, {3, 4}}, {0}}, {{1, {-1}}, {0}}, {}},
    {"20 7 /", {m4slash, m4bye}, {{2, {20, 7}}, {0}}, {{1, {2}}, {0}}, {}},
    {"-20 7 /", {m4slash, m4bye}, {{2, {-20, 7}}, {0}}, {{1, {-2}}, {0}}, {}},
    {"20 7 /mod", {m4slash_mod, m4bye}, {{2, {20, 7}}, {0}}, {{2, {6, 2}}, {0}}, {}},
    {"-20 7 /", {m4slash_mod, m4bye}, {{2, {-20, 7}}, {0}}, {{2, {-6, -2}}, {0}}, {}},
    {"0 0<", {m4zero_less, m4bye}, {{1, {0}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"-1 0<", {m4zero_less, m4bye}, {{1, {-1}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"-1 0<>", {m4zero_not_equals, m4bye}, {{1, {-1}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"0 0<>", {m4zero_not_equals, m4bye}, {{1, {0}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"1 0<>", {m4zero_not_equals, m4bye}, {{1, {1}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"-1 0=", {m4zero_equals, m4bye}, {{1, {-1}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"0 0=", {m4zero_equals, m4bye}, {{1, {0}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"1 0=", {m4zero_equals, m4bye}, {{1, {1}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"0 0>", {m4zero_greater_than, m4bye}, {{1, {0}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"1 0>", {m4zero_greater_than, m4bye}, {{1, {1}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"1-", {m4one_minus, m4bye}, {{1, {-3}}, {0}}, {{1, {-4}}, {0}}, {}},
    {"1+", {m4one_plus, m4bye}, {{1, {-6}}, {0}}, {{1, {-5}}, {0}}, {}},
    {"2-", {m4two_minus, m4bye}, {{1, {-3}}, {0}}, {{1, {-5}}, {0}}, {}},
    {"2+", {m4two_plus, m4bye}, {{1, {-6}}, {0}}, {{1, {-4}}, {0}}, {}},
    {"2*", {m4two_star, m4bye}, {{1, {-6}}, {0}}, {{1, {-12}}, {0}}, {}},
    {"2/", {m4two_slash, m4bye}, {{1, {-5}}, {0}}, {{1, {-2}}, {0}}, {}},
    {"1 2 <", {m4less_than, m4bye}, {{2, {1, 2}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"3 3 <", {m4less_than, m4bye}, {{2, {3, 3}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"1 2 <>", {m4not_equals, m4bye}, {{2, {1, 2}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"3 3 <>", {m4not_equals, m4bye}, {{2, {3, 3}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"1 2 =", {m4equals, m4bye}, {{2, {1, 2}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"3 3 =", {m4equals, m4bye}, {{2, {3, 3}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"2 1 >", {m4greater_than, m4bye}, {{2, {2, 1}}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"3 3 >", {m4greater_than, m4bye}, {{2, {3, 3}}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {">r", {m4to_r, m4bye}, {{1, {99}}, {0}}, {{0}, {1, {99}}}, {}},
    {"0 ?dup", {m4question_dupe, m4bye}, {{1, {0}}, {0}}, {{1, {0}}, {0}}, {}},
    {"1 ?dup", {m4question_dupe, m4bye}, {{1, {1}}, {0}}, {{2, {1, 1}}, {0}}, {}},
    {"0 abs", {m4abs, m4bye}, {{1, {0}}, {0}}, {{1, {0}}, {0}}, {}},
    {"11 abs", {m4abs, m4bye}, {{1, {11}}, {0}}, {{1, {11}}, {0}}, {}},
    {"-3 abs", {m4abs, m4bye}, {{1, {-3}}, {0}}, {{1, {3}}, {0}}, {}},
    {"-7 14 and", {m4and, m4bye}, {{2, {-7, 14}}, {0}}, {{1, {-7 & 14}}, {0}}, {}},
    {"bl", {m4bl, m4bye}, {{0}, {0}}, {{1, {' '}}, {0}}, {}},
    {"cell+", {m4cell_plus, m4bye}, {{1, {12}}, {0}}, {{1, {SZ + 12}}, {0}}, {}},
    {"cells", {m4cells, m4bye}, {{1, {3}}, {0}}, {{1, {SZ * 3}}, {0}}, {}},
    {"char+", {m4char_plus, m4bye}, {{1, {6}}, {0}}, {{1, {7}}, {0}}, {}},
    {"chars", {m4chars, m4bye}, {{1, {8}}, {0}}, {{1, {8}}, {0}}, {}},
    {"depth", {m4depth, m4bye}, {{0}, {0}}, {{1, {0}}, {0}}, {}},
    {"_ depth", {m4depth, m4bye}, {{1, {3}}, {0}}, {{2, {3, 1}}, {0}}, {}},
    {"_ _ depth", {m4depth, m4bye}, {{2, {3, 4}}, {0}}, {{3, {3, 4, 2}}, {0}}, {}},
    {"drop", {m4drop, m4bye}, {{1, {1}}, {0}}, {{0}, {0}}, {}},
    {"dup", {m4dup, m4bye}, {{1, {-5}}, {0}}, {{2, {-5, -5}}, {0}}, {}},
    {"false", {m4false, m4bye}, {{0}, {0}}, {{1, {tfalse}}, {0}}, {}},
    {"i", {m4i, m4bye}, {{0}, {1, {9}}}, {{1, {9}}, {1, {9}}}, {}},
    {"i*", {m4i_star, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {18}}, {1, {9}}}, {}},
    {"i+", {m4i_plus, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {11}}, {1, {9}}}, {}},
    {"i-", {m4i_minus, m4bye}, {{1, {2}}, {1, {9}}}, {{1, {-7}}, {1, {9}}}, {}},
    {"i'", {m4i_prime, m4bye}, {{0}, {2, {10, 11}}}, {{1, {10}}, {2, {10, 11}}}, {}},
    {"j", {m4j, m4bye}, {{0}, {3, {12, 13, 14}}}, {{1, {12}}, {3, {12, 13, 14}}}, {}},
    {"lshift", {m4lshift, m4bye}, {{2, {99, 3}}, {0}}, {{1, {99 << 3}}, {0}}, {}},
    {"max", {m4max, m4bye}, {{2, {1, 2}}, {0}}, {{1, {2}}, {0}}, {}},
    {"min", {m4min, m4bye}, {{2, {3, 4}}, {0}}, {{1, {3}}, {0}}, {}},
    {"20 7 mod", {m4mod, m4bye}, {{2, {20, 7}}, {0}}, {{1, {6}}, {0}}, {}},
    {"-20 7 mod", {m4mod, m4bye}, {{2, {-20, 7}}, {0}}, {{1, {-6}}, {0}}, {}},
    {"negate", {m4negate, m4bye}, {{1, {-12}}, {0}}, {{1, {12}}, {0}}, {}},
    {"nip", {m4nip, m4bye}, {{1, {5}}, {0}}, {{0}, {0}}, {}},
    {"noop", {m4noop, m4bye}, {{0}, {0}}, {{0}, {0}}, {}},
    {"-7 14 or", {m4or, m4bye}, {{2, {-7, 14}}, {0}}, {{1, {-7 | 14}}, {0}}, {}},
    {"over", {m4over, m4bye}, {{2, {1, 0}}, {0}}, {{3, {1, 0, 1}}, {0}}, {}},
    {"r>", {m4r_from, m4bye}, {{0}, {1, {99}}}, {{1, {99}}, {0}}, {}},
    {"rot", {m4rot, m4bye}, {{3, {1, 2, 3}}, {0}}, {{3, {2, 3, 1}}, {0}}, {}},
    {"rshift", {m4rshift, m4bye}, {{2, {99, 3}}, {0}}, {{1, {99 >> 3}}, {0}}, {}},
    {"swap", {m4swap, m4bye}, {{2, {4, 5}}, {0}}, {{2, {5, 4}}, {0}}, {}},
    {"true", {m4true, m4bye}, {{0}, {0}}, {{1, {ttrue}}, {0}}, {}},
    {"unloop", {m4unloop, m4bye}, {{0}, {3, {1, 2, 3}}}, {{0}, {1, {1}}}, {}},
    {"-7 14 xor", {m4xor, m4bye}, {{2, {-7, 14}}, {0}}, {{1, {-7 ^ 14}}, {0}}, {}},
};

enum { test_n = sizeof(test) / sizeof(test[0]) };

static void m4test_stack_print(const m4test_stack *src, FILE *out) {
    m4int i;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < src->len; i++) {
        fprintf(out, "%ld ", (long)src->data[i]);
    }
    fputc('\n', out);
}

static m4int m4test_stack_equals(const m4test_stack *src, const m4span *dst) {
    m4int i, len = src->len;
    if (len != dst->end - dst->curr) {
        return 0;
    }
    for (i = 0; i < len; i++) {
        if (src->data[i] != dst->end[-i - 1]) {
            return 0;
        }
    }
    return 1;
}

static void m4test_stack_copy(const m4test_stack *src, m4span *dst) {
    m4int i, len = src->len;
    dst->curr = dst->end - len;
    for (i = 0; i < len; i++) {
        dst->end[-i - 1] = src->data[i];
    }
}

static void m4test_code_copy(const m4test_code *src, m4code *dst) {
    dst->end = dst->start + m4test_code_n;
    memcpy(dst->start, *src, m4test_code_n * sizeof(m4instr));
}

static m4int m4test_run(m4th *m, const m4test *t) {
    m4th_clear(m);
    m4test_code_copy(&t->code, &m->code);
    m4test_stack_copy(&t->before.d, &m->dstack);
    m4test_stack_copy(&t->before.r, &m->rstack);
    m4th_enter(m);
    return m4test_stack_equals(&t->after.d, &m->dstack) &&
           m4test_stack_equals(&t->after.r, &m->rstack);
}

static m4int m4test_failed(m4th *m, const m4test *t, FILE *out) {
    if (out != NULL) {
        fprintf(out, "test failed: %s\n", t->name);
        fputs("    expected data   stack ", out);
        m4test_stack_print(&t->after.d, out);
        fputs("    actual   data   stack ", out);
        m4th_stack_print(&m->dstack, out);

        fputs("... expected return stack ", out);
        m4test_stack_print(&t->after.r, out);
        fputs("    actual   return stack ", out);
        m4th_stack_print(&m->rstack, out);
    }
    return 1;
}

m4int m4th_test(m4th *m, FILE *out) {
    m4int i, err = 0;

    for (i = 0; i < test_n; i++) {
        if (!m4test_run(m, &test[i])) {
            err += m4test_failed(m, &test[i], out);
        }
    }
    if (out != NULL) {
        if (err == 0) {
            fprintf(out, "all %ld tests passed\n", (long)test_n);
        } else {
            fprintf(out, "\ntests failed: %ld of %ld\n", (long)err, (long)test_n);
        }
    }
    return err;
}

int main(int argc, char *argv[]) {
    crcfill(crctable);

    m4th *m = m4th_new();

    m4int err = m4th_test(m, stdout);
    m4th_del(m);

    /* suppress 'unused parameter' warning */
    return err || (0 & argc & (m4int)argv);
}
