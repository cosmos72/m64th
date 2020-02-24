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

#include "test.h"
#include "impl.h"
#include "t/testcommon.c"
#include "t/testcompile.c"
#include "t/testexecute.c"
#include "t/testio.c"

int main(int argc, char *argv[]) {
    FILE *out = stdout;
    m4th *m = m4th_new();
    m4cell fail1, fail2, fail3;

    m4th_crcinit(m4th_crctable);

    /* m4th_testprint_dicts_crc(out); */
    /* m4th_testbench_crc_c(out); */

    fail1 = m4th_testexecute(m, out);
    fail2 = m4th_testcompile(m, out);
    fail3 = m4th_testio(m, out);

    m4th_del(m);

    /* suppress 'unused parameter' warning */
    return (fail1 + fail2 + fail3) || (0 & argc & (m4cell)argv);
}
