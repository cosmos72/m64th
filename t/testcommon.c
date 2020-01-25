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
#include <string.h> /* memcpy()          */

/* -------------- m4test_code -------------- */

void m4test_code_copy(const m4long *src, m4long n, m4enum *dst) {
    m4long i = 0;
    while (i < n) {
        m4long x = src[i];
        dst[i++] = (m4enum)x;
        if (x == m4_call_) {
            /* copy XT */
            x = src[i];
            memcpy(dst + i, &x, sizeof(m4long));
            i += m4enum_per_m4long;
        }
    }
}

void m4test_code_copy_to_word(const m4long *src, m4long n, m4word *dst) {
    m4test_code_copy(src, n, dst->code + dst->code_n);
    dst->code_n += n;
}

m4long m4test_code_equal(const m4test_code *src, const m4word *dst, m4long dst_code_start_n) {
    m4long i, n = src->len;
    const m4enum *dst_code;
    if (dst->code_n < dst_code_start_n || n != dst->code_n - dst_code_start_n) {
        return tfalse;
    }
    dst_code = dst->code + dst_code_start_n;
    for (i = 0; i < n; i++) {
        if ((m4enum)src->data[i] != dst_code[i]) {
            return tfalse;
        }
    }
    return ttrue;
}

void m4test_code_print(const m4test_code *src, FILE *out) {
    m4long i, n = src->len;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < n; i++) {
        fprintf(out, "0x%lx ", (unsigned long)src->data[i]);
    }
    fputc('\n', out);
}

/* -------------- m4test_stack -------------- */

void m4test_stack_copy(const m4test_stack *src, m4span *dst) {
    m4long i, len = src->len;
    dst->curr = dst->end - len;
    for (i = 0; i < len; i++) {
        dst->end[-i - 1] = src->data[i];
    }
}

m4long m4test_stack_equal(const m4test_stack *src, const m4span *dst) {
    m4long i, len = src->len;
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
    m4long i;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < src->len; i++) {
        fprintf(out, "%ld ", (long)src->data[i]);
    }
    fputc('\n', out);
}

#endif /* M4TH_T_TESTCOMMON_C */
