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

#ifndef M4TH_T_TESTLOCAL_C
#define M4TH_T_TESTLOCAL_C

#include "../include/m64th.h"
#include "testcommon.h"

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */

static void testlocal_fillstr(m4char seed, m4cell i, m4char out[255]) {
    m4cell j;
    m4char ch;
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

m4cell m64th_testlocal(m64th *m, FILE *out) {
    m4testcount count = {};
    m4cell i, n = 16;
    m4char buf[255];
    for (i = 0; i < n; i++) {
        m4string str = {buf, sizeof(buf)};
        testlocal_fillstr('A', i, buf);
        if (!m64th_local(m, str)) {
            count.failed++;
            if (out != NULL) {
                fprintf(out, "local   test failed: %d", (int)count.total);
                fputs("\n    failed to add  local variable ", out);
                m4string_print(str, m4mode_c_disasm, out);
                fputc('\n', out);
            }
        }
        count.total++;
    }
    /* end of locals */
    m64th_local(m, m4string_make(NULL, 0));
    for (i = 0; i < n; i++) {
        m4string str = {buf, sizeof(buf)};
        testlocal_fillstr('A' + 26, i, buf);
        if (m4locals_find(m->locals, str) != n - i - 1) {
            count.failed++;
            if (out != NULL) {
                fprintf(out, "local   test failed: %d", (int)count.total);
                fputs("\n    failed to find local variable ", out);
                m4string_print(str, m4mode_c_disasm, out);
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

#endif /* M4TH_T_TESTLOCAL_C */
