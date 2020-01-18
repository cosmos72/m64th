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

#ifndef M4TH_T_TESTCOMPILE_H
#define M4TH_T_TESTCOMPILE_H

#include "../common/func_fwd.h"
#include "../common/word_fwd.h"
#include "../impl.h"
#include "../m4th.h"
#include "../test.h"

#include <stdio.h>  /* fprintf() fputs() */
#include <string.h> /* memcpy()          */

enum { m4testcompile_code_n = 6 };

typedef struct m4testcompile_code_s {
    m4int len;
    m4instr data[m4testcompile_code_n];
} m4testcompile_code;

typedef struct m4testcompile_s {
    const char *input[8];
    m4testcompile_code generated;
} m4testcompile;

/* -------------- m4testcompile_code -------------- */

static void m4testcompile_code_print(const m4testcompile_code *src, FILE *out) {
    m4int i, n = src->len;
    for (i = 0; i < n; i++) {
        fprintf(out, "0x%lx ", (unsigned long)src->data[i]);
    }
    fputc('\n', out);
}

static m4int m4testcompile_code_equals(const m4testcompile_code *src, const m4code *dst) {
    if (src->len != dst->curr - dst->start) {
        return tfalse;
    }
    return memcmp(src->data, dst->start, src->len * sizeof(m4instr)) == 0;
}

/* -------------- m4testcompile -------------- */

static const m4testcompile testcompile[] = {
    {{"0"}, {2, {m4_lit_, (m4instr)0}}},
    {{"1", "2", "+"},
     {6, {m4_lit_, (m4instr)1, m4_lit_, (m4instr)2, m4_call_, (m4instr)m4word_plus.code}}},
};

enum { testcompile_n = sizeof(testcompile) / sizeof(testcompile[0]) };

static m4int m4testcompile_run(m4th *m, const m4testcompile *t) {
    m4th_clear(m);
    m->flags &= ~m4th_flag_status_mask;
    m->flags |= m4th_flag_compile;
    m->in_cstr = t->input;
    m4th_repl(m);
    return m4testcompile_code_equals(&t->generated, &m->code);
}

static void m4testcompile_print(const m4testcompile *t, FILE *out) {
    const char *const *cstr = t->input;
    for (; *cstr != NULL; cstr++) {
        fputs(*cstr, out);
        fputc(' ', out);
    }
    fputc('\n', out);
}

static void m4testcompile_failed(m4th *m, const m4testcompile *t, FILE *out) {
    if (out == NULL) {
        return;
    }
    fputs("compile test failed: ", out);
    m4testcompile_print(t, out);
    fputs("    expected code ", out);
    m4testcompile_code_print(&t->generated, out);
    fputs("    actual   code ", out);
    m4th_code_print(&m->code, out);
}

m4int m4th_testcompile(m4th *m, FILE *out) {
    m4int i, fail = 0;
    enum { n = testcompile_n };

    for (i = 0; i < n; i++) {
        if (!m4testcompile_run(m, &testcompile[i])) {
            fail++, m4testcompile_failed(m, &testcompile[i], out);
        }
    }
    if (out != NULL) {
        if (fail == 0) {
            fprintf(out, "all % 3ld compile tests passed\n", (long)n);
        } else {
            fprintf(out, "\ncompile tests failed: % 3ld of % 3ld\n", (long)fail, (long)n);
        }
    }
    return fail;
}

#endif /* M4TH_T_TESTCOMPILE_H */
