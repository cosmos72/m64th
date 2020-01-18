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
#include "dict_fwd.h"

#include <errno.h>  /* errno */
#include <stdio.h>  /* fprintf() */
#include <stdlib.h> /* exit(), free(), malloc() */
#include <string.h> /* memset() */

#ifdef __unix__
#include <sys/mman.h> /* mmap(), munmap() */
#include <unistd.h>   /* sysconf() */
#endif

enum {
    dstack_n = 256,
    rstack_n = 64,
    code_n = 1024,
    inbuf_n = 1024,
    outbuf_n = 1024,
};

static void m4th_oom(size_t bytes) {
    fprintf(stderr, "failed to allocate %lu bytes: %s\n", (unsigned long)bytes, strerror(errno));
    exit(1);
}

#ifdef __unix__
static size_t m4th_page = 0;

static size_t m4th_getpagesize() {
    if (m4th_page == 0) {
        m4th_page =
#if defined(_SC_PAGESIZE)
            sysconf(_SC_PAGESIZE);
#elif defined(_SC_PAGE_SIZE)
            sysconf(_SC_PAGE_SIZE);
#elif defined(PAGESIZE)
            PAGESIZE;
#elif defined(PAGE_SIZE)
            PAGE_SIZE;
#else
            4096;
#endif
    }
    return m4th_page;
}

static size_t m4th_round_to_page(size_t bytes) {
    const size_t page = m4th_getpagesize();
    return (bytes + page - 1) / page * page;
}

void *m4th_mmap(size_t bytes) {
    void *ptr = NULL;
    if (bytes != 0) {
        bytes = m4th_round_to_page(bytes);
        if ((ptr = mmap(NULL, bytes, PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS
#ifdef MAP_STACK
                            | MAP_STACK /* for BSD */
#endif
                        ,
                        -1, 0)) == (void *)-1) {
            m4th_oom(bytes);
        }
        memset(ptr, '\xFF', bytes);
    }
    return ptr;
}

void m4th_munmap(void *ptr, size_t bytes) {
    if (bytes != 0) {
        bytes = m4th_round_to_page(bytes);
        munmap(ptr, bytes);
    }
}
#else /* ! __unix__ */
void *m4th_mmap(size_t bytes) {
    return m4th_alloc(bytes);
}
void m4th_munmap(void *ptr, size_t bytes) {
    m4th_free(ptr);
}
#endif

void *m4th_alloc(size_t bytes) {
    void *ptr = NULL;
    if (bytes != 0) {
        if ((ptr = malloc(bytes)) == NULL) {
            m4th_oom(bytes);
        }
        memset(ptr, '\xFF', bytes);
    }
    return ptr;
}

void m4th_free(void *ptr) {
    free(ptr);
}

static m4stack m4th_stack_alloc(m4int size) {
    m4int *p = (m4int *)m4th_mmap(size * sizeof(m4int));
    m4stack ret = {p, p + size - 1, p + size - 1};
    return ret;
}

static void m4th_stack_free(m4stack *arg) {
    if (arg) {
        m4th_munmap(arg->start, (arg->end - arg->start + 1) / sizeof(m4int));
    }
}

static m4code m4th_code_alloc(m4int size) {
    m4instr *p = (m4instr *)m4th_alloc(size * sizeof(m4instr));
    m4code ret = {p, p, p + size};
    return ret;
}

static void m4th_code_free(m4code *arg) {
    if (arg) {
        m4th_free(arg->start);
    }
}

static m4cspan m4th_cspan_alloc(m4int size) {
    m4char *p = (m4char *)m4th_alloc(size * sizeof(m4char));
    m4cspan ret = {p, p, p + size};
    return ret;
}

static void m4th_cspan_free(m4cspan *arg) {
    if (arg) {
        m4th_free(arg->start);
    }
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

/* ----------------------- m4flags ----------------------- */

void m4th_flags_print(m4flags fl, FILE *out) {
    m4char printed = 0;
    if (out == NULL) {
        return;
    }
    if (!fl) {
        fputc('0', out);
    }
    if (fl & m4flag_addr_mask) {
        const char *s = NULL;
        switch (fl & m4flag_addr_mask) {
        case m4flag_addr_fetch:
            s = "addr_fetch";
            break;
        case m4flag_addr_store:
            s = "addr_store";
            break;
        }
        if (s != NULL) {
            if (printed++) {
                fputc('|', out);
            }
            fputs(s, out);
        }
    }
    if (fl & m4flag_compile_only) {
        fputs("compile_only", out);
        printed++;
    }
    if (fl & m4flag_consumes_ip_mask) {
        m4char ch = 0;
        switch (fl & m4flag_consumes_ip_mask) {
        case m4flag_consumes_ip_1:
            ch = '1';
            break;
        case m4flag_consumes_ip_2:
            ch = '2';
            break;
        case m4flag_consumes_ip_4:
            ch = '4';
            break;
        case m4flag_consumes_ip_8:
            ch = '8';
            break;
        }
        if (ch != 0) {
            if (printed++) {
                fputc('|', out);
            }
            fputs("consumes_ip_", out);
            fputc(ch, out);
        }
    }
    if (fl & m4flag_immediate) {
        fputs(printed++ ? "|immediate" : "immediate", out);
    }
    if (fl & m4flag_inline_mask) {
        if (printed++) {
            fputc('|', out);
        }
        switch (fl & m4flag_inline_mask) {
        case m4flag_inline:
        default:
            fputs("inline", out);
            break;
        case m4flag_inline_always:
            fputs("inline_always", out);
            break;
        case m4flag_inline_native:
            fputs("inline_native", out);
            break;
        }
    }
    if (fl & m4flag_jump) {
        fputs(printed++ ? "|jump" : "jump", out);
    }
    if ((fl & m4flag_pure_mask) == m4flag_pure) {
        fputs(printed++ ? "|pure" : "pure", out);
    }
}

/* ----------------------- m4countedstring ----------------------- */

void m4th_countedstring_print(const m4countedstring *n, FILE *out) {
    if (out == NULL || n == NULL || n->len == 0) {
        return;
    }
    fwrite(n->chars, 1, n->len, out);
}

/* ----------------------- m4word ----------------------- */

void m4th_word_stack_print(uint8_t stack_in_out, FILE *out) {
    uint8_t n = stack_in_out & 0xF;
    if (n == 0xF) {
        fputc('?', out);
    } else {
        fprintf(out, "%u", (unsigned)n);
    }
    n = stack_in_out >> 4;
    if (n == 0xF) {
        fputs(" -> ?", out);
    } else {
        fprintf(out, " -> %u", (unsigned)n);
    }
}

void m4th_word_print(const m4word *w, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    m4th_countedstring_print(m4th_word_name(w), out);
    fputs(" {\n\tflags:\t", out);
    m4th_flags_print((m4flags)w->flags, out);
    fputs(" \n\tdata_stack:\t", out);
    m4th_word_stack_print(w->dstack, out);
    fputs(" \n\treturn_stack:\t", out);
    m4th_word_stack_print(w->rstack, out);
    fprintf(out, "\n\tnative_len:\t%u\n\tcode_len:\t%u\n\tdata_len:\t%u\n}\n",
            (unsigned)w->native_len, (unsigned)w->code_len, (unsigned)w->data_len);
}

const m4countedstring *m4th_word_name(const m4word *w) {
    if (w == NULL || w->name_off == 0) {
        return NULL;
    }
    return (const m4countedstring *)((const m4char *)w - w->name_off);
}

const m4word *m4th_word_prev(const m4word *w) {
    if (w == NULL || w->prev_off == 0) {
        return NULL;
    }
    return (const m4word *)((const m4char *)w - w->prev_off);
}

/* ----------------------- m4dict ----------------------- */

void m4th_dict_print(const m4dict *d, FILE *out) {
    const m4word *w;
    if (out == NULL || d == NULL) {
        return;
    }
    fputs("/* -------- ", out);
    m4th_countedstring_print(m4th_dict_name(d), out);
    fputs(" -------- */\n", out);

    w = m4th_dict_lastword(d);
    while (w) {
        m4th_word_print(w, out);
        w = m4th_word_prev(w);
    }
}

const m4countedstring *m4th_dict_name(const m4dict *d) {
    if (d == NULL || d->name_off == 0) {
        return NULL;
    }
    return (const m4countedstring *)((const m4char *)d - d->name_off);
}

const m4word *m4th_dict_lastword(const m4dict *d) {
    if (d == NULL || d->word_off == 0) {
        return NULL;
    }
    return (const m4word *)((const m4char *)d - d->word_off);
}

/* ----------------------- m4th ----------------------- */

m4th *m4th_new() {
    m4th *m = (m4th *)m4th_alloc(sizeof(m4th));
    m->dstack = m4th_stack_alloc(dstack_n);
    m->rstack = m4th_stack_alloc(rstack_n);
    m->code = m4th_code_alloc(code_n);
    m->ip = m->code.start;
    m->c_sp = NULL;
    m->in = m4th_cspan_alloc(inbuf_n);
    m->out = m4th_cspan_alloc(outbuf_n);
    m->flags = m4th_flag_interpret;
    m->dicts[0] = &m4dict_core;
    m->dicts[1] = &m4dict_tools_ext;
    m->dicts[2] = &m4dict_m4th;
    m->dicts[3] = NULL;
    m->in_cstr = NULL;
    return m;
}

void m4th_del(m4th *m) {
    if (m) {
        m4th_cspan_free(&m->out);
        m4th_cspan_free(&m->in);
        m4th_code_free(&m->code);
        m4th_stack_free(&m->rstack);
        m4th_stack_free(&m->dstack);
        m4th_free(m);
    }
}

void m4th_clear(m4th *m) {
    m->dstack.curr = m->dstack.end;
    m->rstack.curr = m->rstack.end;
    m->code.curr = m->code.start;
    m->ip = m->code.start;
    m->c_sp = NULL;
    m->in.curr = m->in.start;
    m->out.curr = m->out.start;
}
