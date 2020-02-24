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

#ifndef M4TH_T_TESTIO_C
#define M4TH_T_TESTIO_C

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

/* -------------- m4testio -------------- */

static m4testio testio_a[] = {
    {"cr", {CALL(cr), m4bye}, {{}, {}}, {{}, {}}, {"", ""}, {"", "\n"}},
};

static m4code m4testio_init(m4testio *t, m4countedcode *code_buf) {
    m4slice t_code_in = {(m4cell *)t->code, m4test_code_n};
    m4code t_code = {code_buf->data, code_buf->n};
    m4slice_copy_to_code(t_code_in, &t_code);
    return t_code;
}

static m4cell m4testio_run(m4th *m, m4testio *t, const m4code *code) {
    m4th_clear(m);

    m4countedstack_copy(&t->before.d, &m->dstack);
    m4countedstack_copy(&t->before.r, &m->rstack);
#if 0
    m->in->handle = (m4cell)stdin;
    m->in->func = m4word_code(&WORD_SYM(c_fread)).addr;
#endif /* 0 */
    m->ip = code->addr;
    m4th_run(m);

    return m4countedstack_equal(&t->after.d, &m->dstack) &&
           m4countedstack_equal(&t->after.r, &m->rstack);
}

static void m4testio_failed(m4th *m, const m4testio *t, FILE *out) {
    if (out == NULL) {
        return;
    }
    fprintf(out, "  I/O   test failed: %s", t->name);
    fputs("\n    expected  data  stack ", out);
    m4countedstack_print(&t->after.d, out);
    fputs("\n      actual  data  stack ", out);
    m4stack_print(&m->dstack, out);

    fputs("\n... expected return stack ", out);
    m4countedstack_print(&t->after.r, out);
    fputs("\n      actual return stack ", out);
    m4stack_print(&m->rstack, out);
    fputc('\n', out);
}

static void m4th_testio_bunch(m4th *m, m4testio bunch[], m4cell n, m4testcount *count, FILE *out) {
    m4countedcode countedcode = {m4test_code_n, {}};
    m4cell i, fail = 0;
    for (i = 0; i < n; i++) {
        m4code code = m4testio_init(&bunch[i], &countedcode);
        if (!m4testio_run(m, &bunch[i], &code)) {
            fail++, m4testio_failed(m, &bunch[i], out);
        }
    }
    count->failed += fail;
    count->total += n;
}

m4cell m4th_testio(m4th *m, FILE *out) {
    m4testcount count = {};
    m4th_testio_bunch(m, testio_a, N_OF(testio_a), &count, out);

    if (out != NULL) {
        if (count.failed == 0) {
            fprintf(out, "all %3u   I/O   tests passed\n", (unsigned)count.total);
        } else {
            fprintf(out, "\n  I/O   tests failed: %3u of %3u\n", (unsigned)count.failed,
                    (unsigned)count.total);
        }
    }
    return count.failed;
}

#endif /* M4TH_T_TESTIO_C */
