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

#include "decl.h"
#include "m4th.h"

#include <stdio.h>  /* fprintf(), fputs() */
#include <string.h> /* memcpy() */

enum { m4test_code_n = 3 };
enum { m4test_stack_n = 3 };
enum { tfalse = (m4int)0, ttrue = (m4int)-1 };

typedef struct m4test_stack_s {
    m4int len;
    m4int data[m4test_stack_n];
} m4test_stack;

typedef struct m4test_stacks_s {
    m4test_stack d, r;
} m4test_stacks;

typedef struct m4test_s {
    const char *name;
    m4int code[m4test_code_n];
    m4test_stacks before, after;
} m4test;

static const m4test test[] = {
    {
        "0 abs",
        {(m4int)m4abs, (m4int)m4bye},
        {{1, {0}}, {0}}, /* d, r before */
        {{1, {0}}, {0}}, /* d, r after  */
    },
    {
        "11 abs",
        {(m4int)m4abs, (m4int)m4bye},
        {{1, {11}}, {0}},
        {{1, {11}}, {0}},
    },
    {
        "-3 abs",
        {(m4int)m4abs, (m4int)m4bye},
        {{1, {-3}}, {0}},
        {{1, {3}}, {0}},
    },
    {
        "drop",
        {(m4int)m4drop, (m4int)m4bye},
        {{1, {1}}, {0}},
        {{0}, /**/ {0}},
    },
    {
        "dup",
        {(m4int)m4dup, (m4int)m4bye},
        {{1, {-5}}, /**/ {0}},
        {{2, {-5, -5}}, {0}},
    },
    {
        "1 2 =",
        {(m4int)m4equal, (m4int)m4bye},
        {{2, {1, 2}}, /*  */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "3 3 =",
        {(m4int)m4equal, (m4int)m4bye},
        {{2, {3, 3}}, /* */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "1 2 >=",
        {(m4int)m4greater_equal_than, (m4int)m4bye},
        {{2, {1, 2}}, /*  */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "3 3 >=",
        {(m4int)m4greater_equal_than, (m4int)m4bye},
        {{2, {3, 3}}, /* */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "5 4 >=",
        {(m4int)m4greater_equal_than, (m4int)m4bye},
        {{2, {5, 4}}, /* */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "2 1 >",
        {(m4int)m4greater_than, (m4int)m4bye},
        {{2, {2, 1}}, /**/ {0}},
        {{1, {ttrue}}, /*   */ {0}},
    },
    {
        "3 3 >",
        {(m4int)m4greater_than, (m4int)m4bye},
        {{2, {3, 3}}, /*  */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "1 2 <=",
        {(m4int)m4less_equal_than, (m4int)m4bye},
        {{2, {1, 2}}, /* */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "3 3 <=",
        {(m4int)m4less_equal_than, (m4int)m4bye},
        {{2, {3, 3}}, /* */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "5 4 <=",
        {(m4int)m4less_equal_than, (m4int)m4bye},
        {{2, {5, 4}}, /**/ {0}},
        {{1, {0}}, /*   */ {0}},
    },
    {
        "1 2 <",
        {(m4int)m4less_than, (m4int)m4bye},
        {{2, {1, 2}}, /**/ {0}},
        {{1, {ttrue}}, /*   */ {0}},
    },
    {
        "3 3 <",
        {(m4int)m4less_than, (m4int)m4bye},
        {{2, {3, 3}}, /*  */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "literal",
        {(m4int)m4literal, 7, (m4int)m4bye},
        {{0}, /**/ {0}},
        {{1, {7}}, {0}},
    },
    {
        "literal_1",
        {(m4int)m4literal_1, (m4int)m4bye},
        {{0}, /* */ {0}},
        {{1, {-1}}, {0}},
    },
    {
        "literal0",
        {(m4int)m4literal0, (m4int)m4bye},
        {{0}, /**/ {0}},
        {{1, {0}}, {0}},
    },
    {
        "literal1",
        {(m4int)m4literal1, (m4int)m4bye},
        {{0}, /**/ {0}},
        {{1, {1}}, {0}},
    },
    {
        "i",
        {(m4int)m4i, (m4int)m4bye},
        {{0}, /**/ {1, {9}}},
        {{1, {9}}, {1, {9}}},
    },
    {
        "i'",
        {(m4int)m4i_prime, (m4int)m4bye},
        {{0}, /* */ {2, {10, 11}}},
        {{1, {10}}, {2, {10, 11}}},
    },
    {
        "j",
        {(m4int)m4j, (m4int)m4bye},
        {{0}, /* */ {3, {12, 13, 14}}},
        {{1, {12}}, {3, {12, 13, 14}}},
    },
    {
        "max",
        {(m4int)m4max, (m4int)m4bye},
        {{2, {1, 2}}, /**/ {0}},
        {{1, {2}}, /*   */ {0}},
    },
    {
        "min",
        {(m4int)m4min, (m4int)m4bye},
        {{2, {3, 4}}, /**/ {0}},
        {{1, {3}}, /*   */ {0}},
    },
    {
        "minus",
        {(m4int)m4minus, (m4int)m4bye},
        {{2, {3, 4}}, /**/ {0}},
        {{1, {-1}}, /*  */ {0}},
    },
    {
        "20 7 mod",
        {(m4int)m4mod, (m4int)m4bye},
        {{2, {20, 7}}, {0}},
        {{1, {6}}, /**/ {0}},
    },
    {
        "-20 7 mod", /* symmetric division rounds toward 0 => remainder is -6 */
        {(m4int)m4mod, (m4int)m4bye},
        {{2, {-20, 7}}, {0}},
        {{1, {-6}}, /**/ {0}},
    },
    {
        "negate",
        {(m4int)m4negate, (m4int)m4bye},
        {{1, {-12}}, {0}},
        {{1, {12}}, {0}},
    },
    {
        "noop",
        {(m4int)m4noop, (m4int)m4bye},
        {{0}, {0}},
        {{0}, {0}},
    },
    {
        "1 2 <>",
        {(m4int)m4not_equal, (m4int)m4bye},
        {{2, {1, 2}}, /* */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "3 3 <>",
        {(m4int)m4not_equal, (m4int)m4bye},
        {{2, {3, 3}}, /*  */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "1-",
        {(m4int)m4one_minus, (m4int)m4bye},
        {{1, {-3}}, {0}},
        {{1, {-4}}, {0}},
    },
    {
        "1+",
        {(m4int)m4one_plus, (m4int)m4bye},
        {{1, {-6}}, {0}},
        {{1, {-5}}, {0}},
    },
    {
        "over",
        {(m4int)m4over, (m4int)m4bye},
        {{2, {1, 0}}, /*   */ {0}},
        {{3, {1, 0, 1}}, /**/ {0}},
    },
    {
        "plus",
        {(m4int)m4plus, (m4int)m4bye},
        {{2, {-3, 2}}, /**/ {0}},
        {{1, {-1}}, /*   */ {0}},
    },
    {
        "r>",
        {(m4int)m4r_from, (m4int)m4bye},
        {{0}, /* */ {1, {99}}},
        {{1, {99}}, {0}},
    },
    {
        "rot",
        {(m4int)m4rot, (m4int)m4bye},
        {{3, {1, 2, 3}}, {0}},
        {{3, {2, 3, 1}}, {0}},
    },
    {
        "20 7 /",
        {(m4int)m4slash, (m4int)m4bye},
        {{2, {20, 7}}, {0}},
        {{1, {2}}, /**/ {0}},
    },
    {
        "-20 7 /",
        {(m4int)m4slash, (m4int)m4bye},
        {{2, {-20, 7}}, {0}},
        {{1, {-2}}, /**/ {0}},
    },
    {
        "20 7 /mod",
        {(m4int)m4slash_mod, (m4int)m4bye},
        {{2, {20, 7}}, {0}},
        {{2, {6, 2}}, {0}},
    },
    {
        "-20 7 /",
        {(m4int)m4slash_mod, (m4int)m4bye},
        {{2, {-20, 7}}, {0}},
        {{2, {-6, -2}}, {0}},
    },
    {
        "*",
        {(m4int)m4star, (m4int)m4bye},
        {{2, {20, 7}}, /**/ {0}},
        {{1, {140}}, /*  */ {0}},
    },
    {
        "swap",
        {(m4int)m4swap, (m4int)m4bye},
        {{2, {4, 5}}, {0}},
        {{2, {5, 4}}, {0}},
    },
    {
        ">r",
        {(m4int)m4to_r, (m4int)m4bye},
        {{1, {99}}, {0}},
        {{0}, {1, {99}}},
    },
    {
        "2-",
        {(m4int)m4two_minus, (m4int)m4bye},
        {{1, {-3}}, {0}},
        {{1, {-5}}, {0}},
    },
    {
        "2+",
        {(m4int)m4two_plus, (m4int)m4bye},
        {{1, {-6}}, {0}},
        {{1, {-4}}, {0}},
    },
    {
        "2*",
        {(m4int)m4two_star, (m4int)m4bye},
        {{1, {-6}}, {0}},
        {{1, {-12}}, {0}},
    },
    {
        "2/",
        {(m4int)m4two_slash, (m4int)m4bye},
        {{1, {-5}}, {0}},
        {{1, {-2}}, {0}},
    },
    {
        "unloop",
        {(m4int)m4unloop, (m4int)m4bye},
        {{0}, /* */ {3, {1, 2, 3}}},
        {{0}, /* */ {1, {1}}},
    },
    {
        "-7 14 xor",
        {(m4int)m4xor, (m4int)m4bye},
        {{2, {-7, 14}}, /* */ {0}},
        {{1, {-7 ^ 14}}, /**/ {0}},
    },
    {
        "0 0<",
        {(m4int)m4zero_less_than, (m4int)m4bye},
        {{1, {0}}, /**/ {0}},
        {{1, {tfalse}}, {0}},
    },
    {
        "-1 0<",
        {(m4int)m4zero_less_than, (m4int)m4bye},
        {{1, {-1}}, /*   */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "0 0>",
        {(m4int)m4zero_greater_than, (m4int)m4bye},
        {{1, {0}}, /**/ {0}},
        {{1, {tfalse}}, {0}},
    },
    {
        "1 0>",
        {(m4int)m4zero_greater_than, (m4int)m4bye},
        {{1, {1}}, /*    */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "-1 0=",
        {(m4int)m4zero_equal, (m4int)m4bye},
        {{1, {-1}}, /*    */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "0 0=",
        {(m4int)m4zero_equal, (m4int)m4bye},
        {{1, {0}}, /*    */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "1 0=",
        {(m4int)m4zero_equal, (m4int)m4bye},
        {{1, {1}}, /*     */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "-1 0=",
        {(m4int)m4zero_not_equal, (m4int)m4bye},
        {{1, {-1}}, /*   */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
    {
        "0 0=",
        {(m4int)m4zero_not_equal, (m4int)m4bye},
        {{1, {0}}, /*     */ {0}},
        {{1, {tfalse}}, /**/ {0}},
    },
    {
        "1 0=",
        {(m4int)m4zero_not_equal, (m4int)m4bye},
        {{1, {1}}, /*    */ {0}},
        {{1, {ttrue}}, /**/ {0}},
    },
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

static m4int m4test_stack_equal(const m4test_stack *src, const m4span *dst) {
    m4int i, len = src->len;
    if (len != dst->end - dst->begin) {
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
    dst->begin = dst->end - len;
    for (i = 0; i < len; i++) {
        dst->end[-i - 1] = src->data[i];
    }
}

static void m4test_code_copy(const m4int src[m4test_code_n], m4span *dst) {
    dst->end = dst->begin + m4test_code_n;
    memcpy(dst->begin, src, m4test_code_n * sizeof(m4int));
}

static m4int m4test_run(m4th *m, const m4test *t) {
    m4th_clear(m);
    m4test_code_copy(t->code, &m->code);
    m4test_stack_copy(&t->before.d, &m->dstack);
    m4test_stack_copy(&t->before.r, &m->rstack);
    m4th_enter(m);
    return m4test_stack_equal(&t->after.d, &m->dstack) &&
           m4test_stack_equal(&t->after.r, &m->rstack);
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
    m4th *m = m4th_new();

    m4int err = m4th_test(m, stdout);
    m4th_del(m);

    /* suppress 'unused parameter' warning */
    return err || (0 & argc & (m4int)argv);
}
