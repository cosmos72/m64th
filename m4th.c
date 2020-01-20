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
#include "common/dict_fwd.h"

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

void *m4mem_mmap(size_t bytes) {
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

void m4mem_munmap(void *ptr, size_t bytes) {
    if (bytes != 0) {
        bytes = m4th_round_to_page(bytes);
        munmap(ptr, bytes);
    }
}
#else /* ! __unix__ */
void *m4mem_mmap(size_t bytes) {
    return m4mem_alloc(bytes);
}
void m4mem_munmap(void *ptr, size_t bytes) {
    m4mem_free(ptr);
}
#endif

void *m4mem_alloc(size_t bytes) {
    void *ptr = NULL;
    if (bytes != 0) {
        if ((ptr = malloc(bytes)) == NULL) {
            m4th_oom(bytes);
        }
        memset(ptr, '\xFF', bytes);
    }
    return ptr;
}

void m4mem_free(void *ptr) {
    free(ptr);
}

static m4stack m4stack_alloc(m4int size) {
    m4int *p = (m4int *)m4mem_mmap(size * sizeof(m4int));
    m4stack ret = {p, p + size - 1, p + size - 1};
    return ret;
}

static void m4stack_free(m4stack *arg) {
    if (arg) {
        m4mem_munmap(arg->start, (arg->end - arg->start + 1) / sizeof(m4int));
    }
}

static m4cspan m4th_cspan_alloc(m4int size) {
    m4char *p = (m4char *)m4mem_alloc(size * sizeof(m4char));
    m4cspan ret = {p, p, p + size};
    return ret;
}

static void m4th_cspan_free(m4cspan *arg) {
    if (arg) {
        m4mem_free(arg->start);
    }
}

void m4stack_print(const m4stack *stack, FILE *out) {
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
    if (fl & m4flag_compile_only) {
        fputs("compile_only", out);
        printed++;
    }
    if (fl & m4flag_consumes_ip_mask) {
        m4char ch = 0;
        switch (fl & m4flag_consumes_ip_mask) {
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
    if ((fl & m4flag_jump_mask) == m4flag_jump) {
        fputs(printed++ ? "|jump" : "jump", out);
    }
    if ((fl & m4flag_jump_mask) == m4flag_may_jump) {
        fputs(printed++ ? "|may_jump" : "may_jump", out);
    }
    if (fl & m4flag_mem_fetch) {
        fputs(printed++ ? "|mem_fetch" : "mem_fetch", out);
    }
    if (fl & m4flag_mem_store) {
        fputs(printed++ ? "|mem_store" : "mem_store", out);
    }
    if ((fl & m4flag_pure_mask) == m4flag_pure) {
        fputs(printed++ ? "|pure" : "pure", out);
    }
}

/* ----------------------- m4string ----------------------- */

void m4string_print(m4string str, FILE *out) {
    if (out == NULL || str.addr == NULL || str.len == 0) {
        return;
    }
    fwrite(str.addr, 1, str.len, out);
}

m4int m4string_compare(m4string a, m4string b) {
    if (a.addr == NULL || b.addr == NULL || a.len != b.len || a.len < 0) {
        return 1;
    }
    if (a.addr == b.addr || a.len == 0) {
        return 0;
    }
    return memcmp(a.addr, b.addr, (size_t)a.len);
}

/* ----------------------- m4word ----------------------- */

void m4word_stack_print(uint8_t stack_in_out, FILE *out) {
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

void m4word_print(const m4word *w, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    m4string_print(m4word_name(w), out);
    fputs(" {\n\tflags:\t", out);
    m4th_flags_print((m4flags)w->flags, out);
    fputs(" \n\tdata_stack: \t", out);
    m4word_stack_print(w->dstack, out);
    fputs(" \n\treturn_stack:\t", out);
    m4word_stack_print(w->rstack, out);
    fprintf(out, "\n\tnative_len:  \t%u\n\tcode_n:      \t%u\n\tdata_len:    \t%u\n}\n",
            (unsigned)w->native_len, (unsigned)w->code_n, (unsigned)w->data_len);
}

void m4word_print_fwd_recursive(const m4word *w, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    m4word_print_fwd_recursive(m4word_prev(w), out);
    m4word_print(w, out);
}

m4string m4word_name(const m4word *w) {
    m4string ret = {};
    if (w == NULL || w->name_off == 0) {
        return ret;
    }
    const m4countedstring *name = (const m4countedstring *)((const m4char *)w - w->name_off);
    ret.addr = name->chars;
    ret.len = name->len;
    return ret;
}

const m4word *m4word_prev(const m4word *w) {
    if (w == NULL || w->prev_off == 0) {
        return NULL;
    }
    return (const m4word *)((const m4char *)w - w->prev_off);
}

/* ----------------------- m4dict ----------------------- */

static m4string m4dict_name(const m4dict *d) {
    m4string ret = {};
    if (d == NULL || d->name_off == 0) {
        return ret;
    }
    const m4countedstring *name = (const m4countedstring *)((const m4char *)d - d->name_off);
    ret.addr = name->chars;
    ret.len = name->len;
    return ret;
}

static const m4word *m4dict_lastword(const m4dict *d) {
    if (d == NULL || d->word_off == 0) {
        return NULL;
    }
    return (const m4word *)((const m4char *)d - d->word_off);
}

/* ----------------------- m4wordlist ----------------------- */

static m4wordlist *m4wordlist_new(const m4dict *impl) {
    m4wordlist *l = (m4wordlist *)m4mem_alloc(sizeof(m4wordlist));
    l->impl = impl;
    return l;
}

static void m4wordlist_new_vec(m4wordlist *l[m4th_wordlist_n]) {
    static const m4dict *dict[] = {
        &m4dict_forth,
        &m4dict_m4th_user,
        &m4dict_m4th_impl,
    };
    enum { dict_n = sizeof(dict) / sizeof(dict[0]) };
    m4int i;
    if (l == NULL) {
        return;
    }
    for (i = 0; i < m4th_wordlist_n; i++) {
        if (i < dict_n) {
            l[i] = m4wordlist_new(dict[i]);
        } else {
            l[i] = NULL;
        }
    }
}

static void m4wordlist_del(m4wordlist *l) {
    m4mem_free(l);
}

static void m4wordlist_del_vec(m4wordlist *l[m4th_wordlist_n]) {
    m4int i;
    if (l == NULL) {
        return;
    }
    for (i = 0; i < m4th_wordlist_n; i++) {
        m4wordlist_del(l[i]);
        l[i] = NULL;
    }
}

const m4word *m4wordlist_lastword(const m4wordlist *d) {
    if (d == NULL) {
        return NULL;
    }
    return m4dict_lastword(d->impl);
}

m4string m4wordlist_name(const m4wordlist *d) {
    if (d == NULL) {
        m4string ret = {};
        return ret;
    }
    return m4dict_name(d->impl);
}

void m4wordlist_print(const m4wordlist *l, FILE *out) {
    if (out == NULL || l == NULL) {
        return;
    }
    fputs("/* -------- ", out);
    m4string_print(m4wordlist_name(l), out);
    fputs(" -------- */\n", out);

    m4word_print_fwd_recursive(m4wordlist_lastword(l), out);
}

/* ----------------------- m4th ----------------------- */

m4th *m4th_new() {

    m4th *m = (m4th *)m4mem_alloc(sizeof(m4th));
    m->dstack = m4stack_alloc(dstack_n);
    m->rstack = m4stack_alloc(rstack_n);
    m->w = NULL;
    m->ip = NULL;
    m->c_sp = NULL;
    m->in = m4th_cspan_alloc(inbuf_n);
    m->out = m4th_cspan_alloc(outbuf_n);
    m->flags = m4th_flag_interpret;
    m4wordlist_new_vec(m->wordlist);
    m->in_cstr = NULL;
    return m;
}

void m4th_del(m4th *m) {
    if (m) {
        m4wordlist_del_vec(m->wordlist);
        m4th_cspan_free(&m->out);
        m4th_cspan_free(&m->in);
        m4stack_free(&m->rstack);
        m4stack_free(&m->dstack);
        m4mem_free(m);
    }
}

void m4th_clear(m4th *m) {
    m->dstack.curr = m->dstack.end;
    m->rstack.curr = m->rstack.end;
    m->w = NULL;
    m->ip = NULL;
    m->c_sp = NULL;
    m->in.curr = m->in.start;
    m->out.curr = m->out.start;
}
