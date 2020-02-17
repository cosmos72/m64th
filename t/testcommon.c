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

#ifndef M4TH_T_TESTCOMMON_C
#define M4TH_T_TESTCOMMON_C

#include "testcommon.h"

#include <stdio.h>  /* fprintf() fputc() */
#include <stdlib.h> /* exit()            */
#include <string.h> /* memcpy()          */

extern const m4word *wtable[]; /* from m4th.c */

/* -------------- m4countedstack -------------- */

void m4countedstack_copy(const m4countedstack *src, m4buf *dst) {
    m4cell i, len = src->len;
    dst->curr = dst->end - len;
    for (i = 0; i < len; i++) {
        dst->end[-i - 1] = src->data[i];
    }
}

m4cell m4countedstack_equal(const m4countedstack *src, const m4buf *dst) {
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

void m4countedstack_print(const m4countedstack *src, FILE *out) {
    m4cell i;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < src->len; i++) {
        long x = (long)src->data[i];
        if (x > -1024 && x < 1024) {
            fprintf(out, "%ld ", x);
        } else {
            fprintf(out, "0x%lx ", x);
        }
    }
}

#endif /* M4TH_T_TESTCOMMON_C */
