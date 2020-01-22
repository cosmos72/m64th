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

#include "../test.h"

#include <stdio.h>  /* fprintf() fputc() */
#include <string.h> /* memcpy()          */

/* -------------- m4test_code -------------- */

m4int m4test_code_equals(const m4test_code *src, const m4word *dst) {
    if (src->len != dst->code_n) {
        return tfalse;
    }
    return memcmp(src->data, dst->code, src->len * sizeof(m4instr)) == 0;
}

void m4test_code_print(const m4test_code *src, FILE *out) {
    m4int i, n = src->len;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < n; i++) {
        fprintf(out, "0x%lx ", (unsigned long)src->data[i]);
    }
    fputc('\n', out);
}

/* -------------- m4test_stack -------------- */

void m4test_stack_copy(const m4test_stack *src, m4span *dst) {
    m4int i, len = src->len;
    dst->curr = dst->end - len;
    for (i = 0; i < len; i++) {
        dst->end[-i - 1] = src->data[i];
    }
}

m4int m4test_stack_equals(const m4test_stack *src, const m4span *dst) {
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

void m4test_stack_print(const m4test_stack *src, FILE *out) {
    m4int i;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < src->len; i++) {
        fprintf(out, "%ld ", (long)src->data[i]);
    }
    fputc('\n', out);
}

#endif /* M4TH_T_TESTCOMMON_C */
