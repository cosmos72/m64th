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

#ifndef M4TH_T_TESTCOMMON_C
#define M4TH_T_TESTCOMMON_C

#include "testcommon.h"

#include <stdio.h>  /* fprintf() fputc() */
#include <stdlib.h> /* exit()            */
#include <string.h> /* memcpy()          */

extern const m4word *wtable[]; /* from m4th.c */

/* -------------- m4slice -------------- */

static void m4slice_print_as_code(m4slice src, FILE *out) {
    const m4cell *addr = src.addr;
    m4cell i, n = src.n;
    if (addr == NULL || n < 0 || out == NULL) {
        return;
    }
    fprintf(out, "<%ld> ", (long)n);
    for (i = 0; i < n; i++) {
        const m4cell val = addr[i];
        if (val >= 0 && val < M4____end) {
            m4token_print((m4token)val, out);
        } else {
            fprintf(out, "%ld ", (long)val);
        }
    }
}

/* -------------- m4test_stack -------------- */

void m4test_stack_copy(const m4test_stack *src, m4buf *dst) {
    m4cell i, len = src->len;
    dst->curr = dst->end - len;
    for (i = 0; i < len; i++) {
        dst->end[-i - 1] = src->data[i];
    }
}

m4cell m4test_stack_equal(const m4test_stack *src, const m4buf *dst) {
    m4cell i, len = src->len;
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

void m4test_stack_print(const m4test_stack *src, FILE *out) {
    m4cell i;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < src->len; i++) {
        fprintf(out, "%ld ", (long)src->data[i]);
    }
}

/* -------------- m4test_code -------------- */

void m4test_code_print(const m4test_code *src, FILE *out) {
    if (src != NULL && out != NULL) {
        m4slice code = {(m4cell *)src->data, src->n};
        m4slice_print_as_code(code, out);
    }
}

void m4slice_copy_to_word_code(m4slice src, m4word *w) {
    m4code dst_code = {(m4token *)w->data + w->code_n, src.n};
    m4slice_copy_to_code(src, &dst_code);
    w->code_n += dst_code.n;
}

#endif /* M4TH_T_TESTCOMMON_C */
