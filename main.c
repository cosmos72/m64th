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

#include "impl.h"
#include "include/dict_fwd.h" /* m4dict_... */
#include "m4th.h"

#include <stdio.h>

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

const char license[] = "/**\n\
 * Copyright (C) 2020 Massimiliano Ghilardi\n\
 *\n\
 * This file is part of m4th.\n\
 *\n\
 * m4th is free software: you can redistribute it and/or modify\n\
 * it under the terms of the GNU Lesser General Public License\n\
 * as published by the Free Software Foundation, either version 3\n\
 * of the License, or (at your option) any later version.\n\
 *\n\
 * m4th is distributed in the hope that it will be useful,\n\
 * but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
 * GNU Lesser General Public License for more details.\n\
 *\n\
 * You should have received a copy of the GNU Lesser General Public License\n\
 * along with m4th.  If not, see <https://www.gnu.org/licenses/>.\n\
 */\n\n\
\n\
/**\n\
 * For the curious: this output has the same copyright and license\n\
 * as the program m4th, because it's an extract of m4th sources.\n\
 */\n\n";

int main(int argc, char *argv[]) {
    fputs(license, stdout);

    m4th_crcinit(m4th_crctable);

    m4th *m = m4th_new();
    const m4dict *dict[] = {
        &m4dict_forth, &m4dict_m4th_user, &m4dict_m4th_c, &m4dict_m4th_core, &m4dict_m4th_impl,
    };
    m4cell i;

    for (i = 0; i < (m4cell)N_OF(dict); i++) {
        m4dict_print(dict[i], stdout);
    }

    m4th_del(m);

    /* suppress 'unused parameter' warning */
    return 0 & argc & (m4cell)argv;
}
