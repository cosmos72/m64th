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

#ifndef M64TH_T_TESTLOCAL_C
#define M64TH_T_TESTLOCAL_C

#include "../include/m64th.h"
#include "testcommon.h"

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */

static void testlocal_fillstr(m6char seed, m6cell i, m6char out[255]) {
    m6cell j;
    m6char ch;
    seed = seed + i - 'A';
    for (j = 0; j < 255; j++) {
        ch = 'A' + (seed + j) % 52;
        if (ch > 'Z') {
            ch += 'a' - 'Z' - 1;
        }
        out[j] = ch;
    }
}

/* -------------- m64th_testlocal -------------- */

m6cell m64th_testlocal(m64th *m, FILE *out) {
    m6testcount count = {};
    m6cell i, n = 16;
    m6char buf[255];
    for (i = 0; i < n; i++) {
        m6string str = {buf, sizeof(buf)};
        testlocal_fillstr('A', i, buf);
        if (!m64th_local(m, str)) {
            count.failed++;
            if (out != NULL) {
                fprintf(out, "local   test failed: %d", (int)count.total);
                fputs("\n    failed to add  local variable ", out);
                m6string_print(str, m6mode_c_disasm, out);
                fputc('\n', out);
            }
        }
        count.total++;
    }
    /* end of locals */
    m64th_local(m, m6string_make(NULL, 0));
    for (i = 0; i < n; i++) {
        m6string str = {buf, sizeof(buf)};
        testlocal_fillstr('A' + 26, i, buf);
        if (m6locals_find(m->locals, str) != n - i - 1) {
            count.failed++;
            if (out != NULL) {
                fprintf(out, "local   test failed: %d", (int)count.total);
                fputs("\n    failed to find local variable ", out);
                m6string_print(str, m6mode_c_disasm, out);
                fputc('\n', out);
            }
        }
        count.total++;
    }

    if (out != NULL) {
        if (count.failed == 0) {
            fprintf(out, "all %3u  local  tests passed\n", (unsigned)count.total);
        } else {
            fprintf(out, "\n local  tests failed: %3u of %3u\n", (unsigned)count.failed,
                    (unsigned)count.total);
        }
    }
    return count.failed;
}

#endif /* M64TH_T_TESTLOCAL_C */
