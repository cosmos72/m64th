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
#include "include/word_fwd.h"
#include "m4th.h"

#include <stdio.h>

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

int main(int argc, char *argv[]) {
    m4th *m = m4th_new();
    m4cell ret;

    m4th_crcinit(m4th_crctable);

    m->in->func = m4word_code(&WORD_SYM(c_linenoise)).addr;
    m->in->handle = (m4cell) "m4th> "; /* prompt */
    m->out->func = m4word_code(&WORD_SYM(c_fwrite_fflush)).addr;
    m->out->handle = (m4cell)stdout;

    ret = m4th_repl(m);
    m4th_del(m);

    putchar('\n');

    /* suppress 'unused parameter' warning */
    return ret | (0 & argc & (m4cell)argv);
}
