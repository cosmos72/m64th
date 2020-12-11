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

#include "c/c_liblinenoise.h"
#include "impl.h"
#include "include/m64th.h"
#include "include/word_fwd.h"

#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    m64th *m = m64th_new(m6opt_return_stack_is_c_stack);
    m6cell ret;

    m->in->func = WORD_SYM(c_linenoise).code;
    m->in->handle = (m6cell) "m64th> "; /* prompt */
    m->out->func = WORD_SYM(c_fwrite_fflush).code;
    m->out->handle = (m6cell)stdout;
    linenoiseSetCompletionCallback(m64th_c_complete_word, m);

    ret = m64th_repl(m);
    m64th_del(m);

    putchar('\n');

    /* suppress 'unused parameter' warning */
    return ret | (0 & argc & (m6cell)argv);
}
