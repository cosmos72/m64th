/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef M64TH_T_TESTCOMMON_C
#define M64TH_T_TESTCOMMON_C

#include "testcommon.h"

#include <stdio.h>  /* fprintf() fputc() */
#include <stdlib.h> /* exit()            */
#include <string.h> /* memcpy()          */

/* -------------- m6countedstack -------------- */

void m6countedstack_copy(const m6countedstack *src, m6buf *dst) {
    m6cell i, len = src->len;
    dst->curr = dst->end - len;
    for (i = 0; i < len; i++) {
        dst->end[-i - 1] = src->data[i];
    }
}

m6cell m6countedstack_equal(const m6countedstack *src, const m6buf *dst) {
    m6cell i, len = src->len;
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

void m6countedstack_print(const m6countedstack *src, FILE *out) {
    m6cell i;
    fprintf(out, "<%ld> ", (long)src->len);
    for (i = 0; i < src->len; i++) {
        long x = (long)src->data[i];
        if (x > -1024 && x < 1024) {
            fprintf(out, "%ld ", x);
        } else {
            fprintf(out, "$%lx ", x);
        }
    }
}

/* -------------- m6countedstack -------------- */

/**
 * remove all user-defined words, for example defined by a test.
 * needed before executing the following test
 */
void m6test_forget_all(m64th *m) {
    m6wordlist *wid = m->compile_wid;
    if (wid && wid->last) {
        wid->last = NULL;
    }
}

#endif /* M64TH_T_TESTCOMMON_C */
