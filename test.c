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

#include "test.h"
#include "impl.h"
#include "t/testasm.c"
#include "t/testcommon.c"
#include "t/testcompile.c"
#include "t/testexecute.c"
#include "t/testhashmap.c"
#include "t/testio.c"
#include "t/testlocal.c"

int main(int argc, char *argv[]) {
    FILE *out = stdout;
    m64th *m = m64th_new(m6opt_return_stack_is_private);
    m6cell fail = 0;

    /* m64th_testbench_crc_c(out); */

    fail += m64th_testexecute(m, out);
    fail += m64th_testio(m, out);
    fail += m64th_testlocal(m, out);
    fail += m64th_testcompile(m, out);
    fail += m64th_testasm(m, out);
    fail += m64th_testhashmap_int(out);
    fail += m64th_testhashmap_string(out);

    m64th_del(m);

    /* suppress 'unused parameter' warning */
    return fail || (0 & argc & (m6cell)argv);
}
