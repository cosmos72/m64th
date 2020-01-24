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

#include "test.h"
#include "t/testcommon.c"
#include "t/testcompile.c"
#include "t/testexecute.c"

int main(int argc, char *argv[]) {
    m4th *m = m4th_new();

    m4long fail1 = m4th_testexecute(m, stdout);
    m4long fail2 = 0; // m4th_testcompile(m, stdout);

    m4th_del(m);

    /* suppress 'unused parameter' warning */
    return (fail1 + fail2) || (0 & argc & (m4long)argv);
}
