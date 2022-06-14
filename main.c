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
#include "c/c_std.h"
#include "impl.h"
#include "include/m64th.h"
#include "include/word_fwd.h"

#include <errno.h>
#include <stdio.h>
#include <string.h>

static m6cell eval_file(m64th *m, const char *path) {
    FILE *f = fopen(path, "r");
    m6cell ret = 0;
    if (f == NULL) {
        fprintf(stdout, "error opening file \"%s\": %s", path, strerror(errno));
        return ret;
    }
    m->in->func = WORD_SYM(c_fread).code;
    m->in->handle = (m6cell)f;
    ret = m64th_repl(m);

    fclose(f);
    return ret;
}

static m6cell eval_stdin(m64th *m) {
    m6cell ret;

    m->in->func = WORD_SYM(c_linenoise).code;
    m->in->handle = (m6cell) "m64th> "; /* prompt */
    linenoiseSetCompletionCallback(m64th_c_complete_word, m);

    ret = m64th_repl(m);
    m64th_c_fwrite_fflush(stdout, "\n", 1);
    return ret;
}

int main(int argc, char *argv[]) {
    m64th *m = m64th_new(m6opt_return_stack_is_c_stack);
    m6cell ret;
    int i;

    m->out->func = WORD_SYM(c_fwrite_fflush).code;
    m->out->handle = (m6cell)stdout;

    for (i = 1; i < argc; i++) {
        const char *path = argv[i];
        if (path[0] == '-' && path[1] == '\0') {
            ret = eval_stdin(m);
        } else {
            ret = eval_file(m, path);
        }
    }
    if (argc == 1) {
        ret = eval_stdin(m);
    }
    m64th_del(m);

    return ret | 0;
}
