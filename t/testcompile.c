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

#ifndef M4TH_T_TESTCOMPILE_C
#define M4TH_T_TESTCOMPILE_C

#include "../impl.h"
#include "../include/word_fwd.h"
#include "../m4th.h"
#include "testcommon.h"

#include <stdio.h>  /* fprintf() fputs() */
#include <string.h> /* memcpy()          */

typedef struct m4testcompile_s {
    const char *input[8];
    m4test_stack dbefore, dafter;
    m4test_code codegen;
} m4testcompile;

/* -------------- m4testcompile -------------- */

static const m4testcompile testcompile[] = {
#if 0
#else
    {{"0"}, {}, {}, {callsz, {CALLXT(zero)}}},
    {{"1", "2", "+"}, {}, {}, {3 * callsz, {CALLXT(one), CALLXT(two), CALLXT(plus)}}},
    {{"if"}, {}, {1, {2}}, {2, {m4_if_, T(-1)}}},
    {{"if", "then"}, {}, {}, {3, {m4_if_, T(1), m4_then_}}},
    {{"if", "1", "then"}, {}, {}, {3 + callsz, {m4_if_, T(1 + callsz), CALLXT(one), m4_then_}}},
    {{"if", "else"}, {}, {1, {4}}, {4, {m4_if_, T(2), m4_else_, T(-1)}}},
    {{"if", "else", "then"}, {}, {}, {5, {m4_if_, T(2), m4_else_, T(1), m4_then_}}},
    {{"if", "1", "else", "2", "then"},
     {},
     {},
     {5 + 2 * callsz,
      {m4_if_, T(2 + callsz), CALLXT(one), m4_else_, T(1 + callsz), CALLXT(two), m4_then_}}},
    {{"literal"}, {1, {0}}, {}, {1, {m4zero}}},
    {{"literal"}, {1, {1}}, {}, {1, {m4one}}},
    {{"literal"}, {1, {-1}}, {}, {1, {m4minus_one}}},
    {{"literal"}, {1, {2}}, {}, {1, {m4two}}},
    {{"literal"}, {1, {3}}, {}, {1, {m4three}}},
    {{"literal"}, {1, {4}}, {}, {1, {m4four}}},
    {{"literal"}, {1, {5}}, {}, {2, {m4_literal2s_, 5}}},
    {{"literal"}, {1, {8}}, {}, {1, {m4eight}}},
    {{"literal"}, {1, {11}}, {}, {2, {m4_literal2s_, 11}}},
    {{"literal"}, {1, {-2}}, {}, {2, {m4_literal2s_, -2}}},
    {{"literal"}, {1, {0x7fff}}, {}, {2, {m4_literal2s_, 0x7fff}}},
    {{"literal"}, {1, {-0x8000}}, {}, {2, {m4_literal2s_, -0x8000}}},
#if SZ >= 4
    {{"literal"}, {1, {0x8000}}, {}, {3, {m4_literal4s_, INT(0x8000)}}},
    {{"literal"}, {1, {-0x8001}}, {}, {3, {m4_literal4s_, INT(-0x8001)}}},
    {{"literal"}, {1, {0x7fffffffl}}, {}, {3, {m4_literal4s_, INT(0x7fffffffl)}}},
    {{"literal"}, {1, {-0x80000000l}}, {}, {3, {m4_literal4s_, INT(-0x80000000l)}}},
#endif
#if SZ >= 8
    {{"literal"}, {1, {0x80000000l}}, {}, {5, {m4_literal8s_, CELL(0x80000000l)}}},
    {{"literal"}, {1, {-0x80000001l}}, {}, {5, {m4_literal8s_, CELL(-0x80000001l)}}},
    {{"literal"}, {1, {0x7fffffffffffffffl}}, {}, {5, {m4_literal8s_, CELL(0x7fffffffffffffffl)}}},
    {{"literal"},
     {1, {-0x8000000000000000l}},
     {},
     {5, {m4_literal8s_, CELL(-0x8000000000000000l)}}},
#endif
    {{"drop"}, {}, {}, {callsz, {CALLXT(drop)}}},
    {{"false"}, {}, {}, {callsz, {CALLXT(false)}}},
    {{"true"}, {}, {}, {callsz, {CALLXT(true)}}},
#endif
};

enum { testcompile_n = sizeof(testcompile) / sizeof(testcompile[0]) };

static void m4testcompile_fill_codegen(const m4testcompile *t, m4code *t_codegen) {
    m4slice t_codegen_in = {(m4cell *)t->codegen.data, t->codegen.n};
    m4slice_copy_to_code(t_codegen_in, t_codegen);
}

static m4cell m4testcompile_run(m4th *m, const m4testcompile *t, m4code t_codegen,
                                m4test_word *out) {
    const m4test_stack empty = {};

    m4th_clear(m);
    memset(out, '\0', sizeof(m4test_word));
    m4test_stack_copy(&t->dbefore, &m->dstack);
    m->w = &out->impl;
    m->flags &= ~m4th_flag_status_mask;
    m->flags |= m4th_flag_compile;
    m->in_cstr = t->input;
    m4th_repl(m);

    return m4test_stack_equal(&t->dafter, &m->dstack) && m4test_stack_equal(&empty, &m->rstack) &&
           m4code_equal(t_codegen, m4word_code(m->w, 0));
}

static void m4testcompile_print(const m4testcompile *t, FILE *out) {
    const char *const *cstr = t->input;
    for (; *cstr != NULL; cstr++) {
        fputs(*cstr, out);
        fputc(' ', out);
    }
    fputc('\n', out);
}

static void m4testcompile_failed(m4th *m, const m4testcompile *t, m4code t_codegen, FILE *out) {
    const m4test_stack empty = {};
    if (out == NULL) {
        return;
    }
    fputs("\ncompile test  failed: ", out);
    m4testcompile_print(t, out);
    fputs("    initial   data  stack ", out);
    m4test_stack_print(&t->dbefore, out);
    fputs("    expected    codegen   ", out);
    m4code_print(t_codegen, out);
    fputs("\n      actual    codegen   ", out);
    m4word_code_print(m->w, 0, out);

    if (m->dstack.curr == m->dstack.end && m->rstack.curr == m->rstack.end) {
        return;
    }
    fputs("... expected  data  stack ", out);
    m4test_stack_print(&t->dafter, out);
    fputs("      actual  data  stack ", out);
    m4stack_print(&m->dstack, out);

    fputs("... expected return stack ", out);
    m4test_stack_print(&empty, out);
    fputs("      actual return stack ", out);
    m4stack_print(&m->rstack, out);
}

m4cell m4th_testcompile(m4th *m, FILE *out) {
    m4test_word w;
    m4cell i, fail = 0;
    enum { n = testcompile_n };

    m4token buf[m4test_code_n];

    for (i = 0; i < n; i++) {
        const m4testcompile *t = &testcompile[i];

        m4code t_codegen = {buf, m4test_code_n};
        m4testcompile_fill_codegen(t, &t_codegen);

        if (!m4testcompile_run(m, t, t_codegen, &w)) {
            fail++, m4testcompile_failed(m, t, t_codegen, out);
        }
    }
    if (out != NULL) {
        if (fail == 0) {
            fprintf(out, "all %3u compile tests passed\n", (unsigned)n);
        } else {
            fprintf(out, "\ncompile tests failed: %3u of %3u\n", (unsigned)fail, (unsigned)n);
        }
    }
    return fail;
}

#endif /* M4TH_T_TESTCOMPILE_C */
