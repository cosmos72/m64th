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
    inbuf_n = 1024,
    outbuf_n = 1024,
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

static m4stack m4stack_alloc(m4int size) {
    m4int *p = (m4int *)m4th_alloc(size * sizeof(m4int));
    m4stack ret = {p, p + size - 1, p + size - 1};
    return ret;
}

static void m4stack_free(m4stack *arg) {
    if (arg) {
        free(arg->start);
    }
}

static m4code m4code_alloc(m4int size) {
    m4int *p = (m4int *)m4th_alloc(size * sizeof(m4int));
    m4code ret = {p, p, p + size};
    return ret;
}

static void m4code_free(m4code *arg) {
    if (arg) {
        free(arg->start);
    }
}

static m4cspan m4cspan_alloc(m4int size) {
    m4char *p = (m4char *)m4th_alloc(size * sizeof(m4char));
    m4cspan ret = {p, p, p + size};
    return ret;
}

static void m4cspan_free(m4cspan *arg) {
    if (arg) {
        free(arg->start);
    }
}

m4th *m4th_new() {
    m4th *m = (m4th *)m4th_alloc(sizeof(m4th));
    m->dstack = m4stack_alloc(dstack_n);
    m->rstack = m4stack_alloc(rstack_n);
    m->code = m4code_alloc(code_n);
    m->ip = m->code.start;
    m->c_stack = NULL;
    m->in = m4cspan_alloc(inbuf_n);
    m->out = m4cspan_alloc(outbuf_n);
    return m;
}

void m4th_del(m4th *m) {
    if (m) {
        m4cspan_free(&m->out);
        m4cspan_free(&m->in);
        m4code_free(&m->code);
        m4stack_free(&m->rstack);
        m4stack_free(&m->dstack);
        free(m);
    }
}

void m4th_clear(m4th *m) {
    m->dstack.curr = m->dstack.end;
    m->rstack.curr = m->rstack.end;
    m->code.curr = m->code.start;
    m->ip = m->code.start;
    m->c_stack = NULL;
    m->in.curr = m->in.start;
    m->out.curr = m->out.start;
}

void m4th_stack_print(const m4stack *stack, FILE *out) {
    const m4int *lo = stack->curr;
    const m4int *hi = stack->end;
    fprintf(out, "<%ld> ", (long)(hi - lo));
    while (hi != lo) {
        fprintf(out, "%ld ", (long)*--hi);
    }
    fputc('\n', out);
}
