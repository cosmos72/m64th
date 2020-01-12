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

#include "m4th.h"

#include <errno.h>  /* errno */
#include <stdio.h>  /* fprintf() */
#include <stdlib.h> /* exit(), free(), malloc() */
#include <string.h> /* memset() */

enum {
    dstack_n = 256,
    rstack_n = 64,
    code_n = 1024,
};

void *m4th_alloc(size_t bytes) {
    void *ret;
    if (bytes == 0) {
        return NULL;
    }
    ret = malloc(bytes);
    if (ret == NULL) {
        fprintf(stderr, "failed to allocate %lu bytes: %s\n", (unsigned long)bytes,
                strerror(errno));
        exit(1);
    }
    memset(ret, '\xFF', bytes);
    return ret;
}

m4th *m4th_new() {
    m4th *m = (m4th *)m4th_alloc(sizeof(m4th));
    m->dstack.end = dstack_n - 1 + (m4int *)m4th_alloc(dstack_n * sizeof(m4int));
    m->rstack.end = rstack_n - 1 + (m4int *)m4th_alloc(rstack_n * sizeof(m4int));
    m->code.begin = m->ip = (m4int *)m4th_alloc(code_n * sizeof(m4int));

    m->dstack.begin = m->dstack.end;
    m->rstack.begin = m->rstack.end;
    m->code.end = m->code.begin + code_n;

    m->c_stack = NULL;
    return m;
}

void m4th_del(m4th *m) {
    free(m->code.begin);
    free(m->rstack.end - (rstack_n - 1));
    free(m->dstack.end - (dstack_n - 1));
    free(m);
}

void m4th_clear(m4th *m) {
    m->dstack.begin = m->dstack.end;
    m->rstack.begin = m->rstack.end;
    m->ip = m->code.begin;
    m->c_stack = NULL;
}

void m4th_stack_print(const m4span *stack, FILE *out) {
    m4int *lo = stack->begin;
    m4int *hi = stack->end;
    fprintf(out, "<%ld> ", (long)(hi - lo));
    while (hi != lo) {
        fprintf(out, "%ld ", (long)*--hi);
    }
    fputc('\n', out);
}
