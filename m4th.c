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

#include "m4th.h"
#include "include/dict_all.mh"
#include "include/dict_fwd.h"
#include "include/func.mh"
#include "include/func_fwd.h"
#include "include/macro.mh"
#include "include/word_fwd.h"
#include "include/wordlist_fwd.h"

#include <assert.h> /* assert()  */
#include <errno.h>  /* errno     */
#include <stdio.h>  /* fprintf() */
#include <stdlib.h> /* exit(), free(), malloc() */
#include <string.h> /* memset()  */

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
    dataspace_n = 4096,
    tfalse = 0,
    ttrue = (m4cell)-1,
};

typedef char m4th_assert_sizeof_m4token_equal_SZt[(sizeof(m4token) == SZt) ? 1 : -1];
typedef char m4th_assert_sizeof_m4cell_equal_SZ[(sizeof(m4cell) == SZ) ? 1 : -1];

/* ----------------------- m4mem ----------------------- */

static void m4mem_oom(size_t bytes) {
    fprintf(stderr, "failed to allocate %lu bytes: %s\n", (unsigned long)bytes, strerror(errno));
    exit(1);
}

#ifdef __unix__
static size_t m4mem_page = 0;

static size_t m4mem_getpagesize() {
    if (m4mem_page == 0) {
        m4mem_page =
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
    return m4mem_page;
}

static size_t m4mem_round_to_page(size_t bytes) {
    const size_t page = m4mem_getpagesize();
    return (bytes + page - 1) / page * page;
}

void *m4mem_map(size_t bytes) {
    void *ptr = NULL;
    if (bytes != 0) {
        bytes = m4mem_round_to_page(bytes);
        if ((ptr = mmap(NULL, bytes, PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS
#ifdef MAP_STACK
                            | MAP_STACK /* for BSD */
#endif
                        ,
                        -1, 0)) == (void *)-1) {
            m4mem_oom(bytes);
        }
        memset(ptr, '\xFF', bytes);
    }
    return ptr;
}

void m4mem_unmap(void *ptr, size_t bytes) {
    if (bytes != 0) {
        bytes = m4mem_round_to_page(bytes);
        munmap(ptr, bytes);
    }
}
#else /* ! __unix__ */
void *m4mem_map(size_t bytes) {
    return m4mem_allocate(bytes);
}
void m4mem_unmap(void *ptr, size_t bytes) {
    m4mem_free(ptr);
}
#endif

void *m4mem_allocate(size_t bytes) {
    void *ptr = NULL;
    if (bytes != 0) {
        if ((ptr = malloc(bytes)) == NULL) {
            m4mem_oom(bytes);
        }
        memset(ptr, '\xFF', bytes);
    }
    return ptr;
}

void m4mem_free(void *ptr) {
    free(ptr);
}

void *m4mem_resize(void *ptr, size_t bytes) {
    if (bytes == 0) {
        free(ptr);
        return NULL;
    } else if (ptr == NULL) {
        return m4mem_allocate(bytes);
    }
    if ((ptr = realloc(ptr, bytes)) == NULL) {
        m4mem_oom(bytes);
    }
    return ptr;
}

/* ----------------------- m4flags ----------------------- */

/** return how many bytes of code are consumed by token or word marked with given flags */
m4cell m4flags_consume_ip(m4flags fl) {
    fl &= m4flag_consumes_ip_mask;
    if (fl == m4flag_consumes_ip_2) {
        return 2;
    } else if (fl == m4flag_consumes_ip_4) {
        return 4;
    } else if (fl == m4flag_consumes_ip_8) {
        return 8;
    } else {
        return 0;
    }
}

void m4flags_print(m4flags fl, FILE *out) {
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
    switch (m4flags_consume_ip(fl)) {
    case 2:
        fputs(printed++ ? "|consumes_ip_2" : "consumes_ip_2", out);
        break;
    case 4:
        fputs(printed++ ? "|consumes_ip_4" : "consumes_ip_4", out);
        break;
    case 8:
        fputs(printed++ ? "|consumes_ip_8" : "consumes_ip_8", out);
        break;
    }
    if (fl & m4flag_inline_always) {
        fputs(printed++ ? "|inline_always" : "inline_always", out);
    } else if (fl & m4flag_inline) {
        fputs(printed++ ? "|inline" : "inline", out);
    }
    if ((fl & m4flag_jump_mask) == m4flag_jump) {
        fputs(printed++ ? "|jump" : "jump", out);
    } else if ((fl & m4flag_jump_mask) == m4flag_may_jump) {
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
    if (fl & m4flag_immediate) {
        fputs(printed++ ? "|immediate" : "immediate", out);
    }
    if (fl & m4flag_data_tokens) {
        fputs(printed++ ? "|data_tokens" : "data_tokens", out);
    }
}

/* ----------------------- m4token ----------------------- */

#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 199901L
#warning "ftable[] initialization currently requires C99"
#endif

/* initialize the whole m4token -> m4func conversion table in one fell swoop */
#define FTABLE_ENTRY(strlen, str, name) [M4TOKEN_VAL(name)] = FUNC_SYM(name),
static m4func ftable[] = {
    DICT_TOKENS_ALL(FTABLE_ENTRY) /**/[M4____end] = FUNC_SYM(_missing_),
};
#undef FTABLE_ENTRY

/* initialize the whole m4token -> m4word conversion table in one fell swoop */
#define WTABLE_ENTRY(strlen, str, name) [M4TOKEN_VAL(name)] = &WORD_SYM(name),
const m4word *wtable[] = {
    DICT_TOKENS_ALL(WTABLE_ENTRY) /**/[M4____end] = NULL,
};
#undef WTABLE_ENTRY

enum { wtable_n = sizeof(wtable) / sizeof(wtable[0]) };

/** return how many bytes of code are skipped by executing token */
m4cell m4token_consumes_ip(m4token tok) {
    const m4word *w = m4token_to_word(tok);
    if (w != NULL) {
        return m4flags_consume_ip((m4flags)w->flags);
    }
    return 0;
}

/** try to find the m4word that describes given token */
const m4word *m4token_to_word(m4token tok) {
    if (/*tok >= 0 &&*/ tok < M4____end) {
        return wtable[tok];
    }
    return NULL;
}

void m4token_print(m4token tok, FILE *out) {
    const m4word *w = m4token_to_word(tok);
    if (w != NULL) {
        const m4string name = m4word_name(w);
        if (name.addr != NULL && name.n != 0) {
            m4string_print(name, out);
            fputc(' ', out);
            return;
        }
    }
    fprintf(out, "T(%d) ", (int)(int16_t)tok);
}

static m4cell m4token_print_int16(const m4token *code, FILE *out) {
    int16_t val;
    memcpy(&val, code, sizeof(val));
    fprintf(out, "%s(%d) ", (sizeof(val) == sizeof(m4token) ? "E" : "SHORT"), (int)val);
    return sizeof(val) / sizeof(m4token);
}

static m4cell m4token_print_int32(const m4token *code, FILE *out) {
    int32_t val;
    memcpy(&val, code, sizeof(val));
    fprintf(out, "INT(%ld) ", (long)val);
    return sizeof(val) / sizeof(m4token);
}

static m4cell m4token_print_int64(const m4token *code, FILE *out) {
    int64_t val;
    memcpy(&val, code, sizeof(val));
    if (val >= -1000 && val <= 1000) {
        fprintf(out, "CELL(%ld) ", (long)val);
    } else {
        fprintf(out, "CELL(0x%lx) ", (unsigned long)val);
    }
    return sizeof(val) / sizeof(m4token);
}

static m4cell m4token_print_word(const m4token *code, FILE *out) {
    m4cell val;
    memcpy(&val, code, sizeof(val));
    if (val > 4096) {
        const m4word *w = (const m4word *)val;
        const m4string name = m4word_name(w);
        if (name.addr && name.n > 0) {
            fputs("WADDR(", out);
            m4string_print(name, out);
            fputs(") ", out);
            return sizeof(val) / sizeof(m4token);
        }
    }
    return m4token_print_int64(code, out);
}

static m4cell m4token_print_xt(const m4token *code, FILE *out) {
    m4cell val;
    memcpy(&val, code, sizeof(val));
    if (val > 4096) {
        const m4word *w = m4code_addr_to_word((const m4token *)val);
        const m4string name = m4word_name(w);
        if (name.addr && name.n > 0) {
            fputs("XT(", out);
            m4string_print(name, out);
            fputs(") ", out);
            return sizeof(val) / sizeof(m4token);
        }
    }
    return m4token_print_int64(code, out);
}

m4cell m4token_print_consumed_ip(m4token tok, const m4token *code, m4cell maxn, FILE *out) {
    const m4cell nbytes = m4token_consumes_ip(tok);
    if (nbytes == 0 || nbytes / SZt > maxn) {
        return 0;
    } else if (nbytes == SZt) {
        fputc('\'', out);
        m4token_print(code[0], out);
        return 1;
    } else if (tok == m4_compile_unresolved_jump_ && nbytes == 2 * SZt) {
        fputc('\'', out);
        m4token_print(code[0], out);
        fputc('\'', out);
        m4token_print(code[1], out);
        return 2;
    } else if (tok == m4_call_ && nbytes == SZ) {
        return m4token_print_word(code, out);
    } else if (tok == m4_call_xt_ && nbytes == SZ) {
        return m4token_print_xt(code, out);
    }
    switch (nbytes) {
    case 2:
        return m4token_print_int16(code, out);
    case 4:
        return m4token_print_int32(code, out);
    case 8:
        return m4token_print_int64(code, out);
    default:
        return 0;
    }
}

/* ----------------------- m4cbuf ----------------------- */

static m4cbuf m4cbuf_alloc(m4cell_u size) {
    m4char *p = (m4char *)m4mem_allocate(size * sizeof(m4char));
    m4cbuf ret = {p, p, p + size};
    return ret;
}

static void m4cbuf_free(m4cbuf *arg) {
    if (arg) {
        m4mem_free(arg->start);
    }
}

/* ----------------------- m4addr ----------------------- */

/* align address to next m4cell */
const m4char *m4addr_align_cell(const void *addr) {
    m4cell x = (m4cell)addr;
    return (const m4char *)((x + SZ - 1) & (m4cell)-SZ); /* -SZ == ~(SZ-1) */
}

/* align address to next uint32 */
const m4char *m4addr_align_4(const void *addr) {
    m4cell x = (m4cell)addr;
    return (const m4char *)((x + 4 - 1) & (m4cell)-4);
}

/* ----------------------- m4code ----------------------- */

m4cell m4code_equal(m4code src, m4code dst) {
    m4cell_u i, n = src.n;
    if (dst.n != n) {
        return tfalse;
    }
    for (i = 0; i < n; i++) {
        if (src.addr[i] != dst.addr[i]) {
            return tfalse;
        }
    }
    return ttrue;
}

void m4code_print(m4code src, FILE *out) {
    const m4token *const code = src.addr;
    m4cell_u i, n = src.n;
    if (code == NULL || out == NULL) {
        return;
    }
    fprintf(out, "<%ld> ", (long)n);
    for (i = 0; i < n;) {
        const m4token tok = code[i++];
        m4token_print(tok, out);
        i += m4token_print_consumed_ip(tok, code + i, n - i, out);
    }
}

/* ----------------------- m4dict ----------------------- */

const m4word *m4dict_lastword(const m4dict *d) {
    if (d == NULL || d->lastword_off == 0) {
        return NULL;
    }
    return (const m4word *)((const m4char *)d - d->lastword_off);
}

m4string m4dict_name(const m4dict *d) {
    m4string ret = {};
    if (d == NULL || d->name_off == 0) {
        return ret;
    }
    const m4countedstring *name = (const m4countedstring *)((const m4char *)d - d->name_off);
    ret.addr = name->addr;
    ret.n = name->n;
    return ret;
}

static void m4word_print_fwd_recursive(const m4word *w, FILE *out);

void m4dict_print(const m4dict *dict, FILE *out) {
    fputs("/* -------- ", out);
    m4string_print(m4dict_name(dict), out);
    fputs(" -------- */\n", out);

    m4word_print_fwd_recursive(m4dict_lastword(dict), out);
}

/* ----------------------- m4slice ----------------------- */

static m4cell m4_2bytes_copy_to_token(uint16_t src, m4token *dst) {
    memcpy(dst, &src, sizeof(src));
    return sizeof(src) / SZt;
}
static m4cell m4_4bytes_copy_to_token(uint32_t src, m4token *dst) {
    memcpy(dst, &src, sizeof(src));
    return sizeof(src) / SZt;
}
static m4cell m4_8bytes_copy_to_token(uint64_t src, m4token *dst) {
    memcpy(dst, &src, sizeof(src));
    return sizeof(src) / SZt;
}

void m4slice_copy_to_code(const m4slice src, m4code *dst) {
    if (src.addr == NULL || src.n == 0) {
        if (dst != NULL) {
            dst->n = 0;
        }
        return;
    }
    if (dst == NULL || dst->addr == NULL || dst->n < src.n) {
        fputs(" m4slice_copy_to_code(): invalid args, dst is smaller than src", stderr);
        return;
    }
    m4cell i = 0, n = src.n;
    const m4cell *sdata = src.addr;
    m4token *ddata = dst->addr;

    while (i < n) {
        m4cell x = sdata[i];
        const m4word *w;
        ddata[i++] = (m4token)x;
        if (x < 0 || x >= M4____end || (w = wtable[x]) == NULL) {
            continue;
        }
        switch (w->flags & M4FLAG_CONSUMES_IP_MASK) {
        case M4FLAG_CONSUMES_IP_2:
            i += m4_2bytes_copy_to_token((uint16_t)sdata[i], ddata + i);
            break;
        case M4FLAG_CONSUMES_IP_4:
            i += m4_4bytes_copy_to_token((uint32_t)sdata[i], ddata + i);
            break;
        case M4FLAG_CONSUMES_IP_8:
            i += m4_8bytes_copy_to_token((uint64_t)sdata[i], ddata + i);
            break;
        }
    }
    dst->n = n;
}

/* ----------------------- m4iobuf ----------------------- */

static m4iobuf m4iobuf_alloc(m4cell_u size) {
    m4char *p = (m4char *)m4mem_allocate(size * sizeof(m4char));
    m4iobuf ret = {p, size, 0};
    return ret;
}

static void m4iobuf_free(m4iobuf *arg) {
    if (arg) {
        m4mem_free(arg->addr);
    }
}

/* ----------------------- m4stack ----------------------- */

static m4stack m4stack_alloc(m4cell size) {
    m4cell *p = (m4cell *)m4mem_map(size * sizeof(m4cell));
    m4stack ret = {p, p + size - 1, p + size - 1};
    return ret;
}

static void m4stack_free(m4stack *arg) {
    if (arg) {
        m4mem_unmap(arg->start, (arg->end - arg->start + 1) / sizeof(m4cell));
    }
}

void m4stack_print(const m4stack *stack, FILE *out) {
    const m4cell *lo = stack->curr;
    const m4cell *hi = stack->end;
    fprintf(out, "<%ld> ", (long)(hi - lo));
    while (hi > lo) {
        long x = (long)*--hi;
        if (x > -1000 && x < 1000) {
            fprintf(out, "%ld ", x);
        } else {
            fprintf(out, "0x%lx ", x);
        }
    }
}

/* ----------------------- m4stackeffect ----------------------- */

void m4stackeffect_print(m4stackeffect eff, FILE *out) {
    uint8_t n = eff & 0xF;
    if (out == NULL) {
        return;
    } else if (n == 0xF) {
        fputc('?', out);
    } else {
        fprintf(out, "%u", (unsigned)n);
    }
    n = eff >> 4;
    if (n == 0xF) {
        fputs(" -> ?", out);
    } else {
        fprintf(out, " -> %u", (unsigned)n);
    }
}

/* ----------------------- m4stackeffects ----------------------- */

void m4stackeffects_print(m4stackeffects effs, const char *suffix, FILE *out) {
    fprintf(out, " \n\tdata_stack%s: \t", suffix);
    m4stackeffect_print(effs.dstack, out);
    fprintf(out, " \n\treturn_stack%s:\t", suffix);
    m4stackeffect_print(effs.rstack, out);
}

/* ----------------------- m4string ----------------------- */

void m4string_print(m4string str, FILE *out) {
    if (out == NULL || str.addr == NULL || str.n == 0) {
        return;
    }
    fwrite(str.addr, 1, str.n, out);
}

void m4string_print_hex(m4string str, FILE *out) {
    static const char hexdigits[] = "0123456789abcdef";
    const m4char *data = str.addr;
    m4cell i, n = str.n;
    if (out == NULL || data == NULL) {
        return;
    }
    for (i = 0; i < n; i++) {
        fputc(hexdigits[(data[i] >> 4) & 0xF], out);
        fputc(hexdigits[(data[i] >> 0) & 0xF], out);
        fputc(' ', out);
    }
}

m4cell m4string_equals(m4string a, m4string b) {
    if (a.addr == NULL || b.addr == NULL || a.n != b.n) {
        return tfalse;
    }
    if (a.addr == b.addr || a.n == 0) {
        return ttrue;
    }
    return memcmp(a.addr, b.addr, a.n) ? tfalse : ttrue;
}

/* ----------------------- m4word ----------------------- */

m4code m4word_code(const m4word *w) {
    m4code ret = {(m4token *)((m4cell)w + w->code_off), w->code_n};
    return ret;
}

const m4word *m4code_addr_to_word(const m4token *xt) {
    const uint32_t data_off = *(const uint32_t *)((m4cell)xt - sizeof(uint32_t));
    return (const m4word *)((m4cell)xt - data_off - WORD_OFF_DATA);
}

m4string m4word_data(const m4word *w, m4cell data_start_n) {
    m4string ret = {};
    if (w->data_n != 0 && w->data_n >= data_start_n) {
        ret.addr = w->data + data_start_n;
        ret.n = (m4cell)w->data_n - data_start_n;
    }
    return ret;
}

void m4word_code_print(const m4word *w, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    m4code_print(m4word_code(w), out);
}

void m4word_data_print(const m4word *w, m4cell data_start_n, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    m4string data = m4word_data(w, data_start_n);
    if (w->flags & m4flag_data_tokens) {
        m4code code = {(m4token *)data.addr, data.n / (m4cell)sizeof(m4token)};
        m4code_print(code, out);
    } else {
        fprintf(out, "<%ld> ", (long)data.n);
        m4string_print_hex(data, out);
    }
}

void m4word_print(const m4word *w, FILE *out) {
    m4flags jump_flags = (m4flags)(w->flags & m4flag_jump_mask);
    if (w == NULL || out == NULL) {
        return;
    }
    m4string_print(m4word_name(w), out);
    fputs(" {\n\tflags:\t", out);
    m4flags_print((m4flags)w->flags, out);
    if (jump_flags != m4flag_jump) {
        m4stackeffects_print(w->eff, "", out);
    }
    if (jump_flags == m4flag_jump || jump_flags == m4flag_may_jump) {
        m4stackeffects_print(w->jump, "_jump", out);
    }
    if (w->native_len != (uint16_t)-1) {
        fprintf(out, "\n\tnative_len:  \t%d", (int)w->native_len);
    }
    if (w->data_n != 0) {
        fputs((w->flags & m4flag_data_tokens) ? "\n\tdata_tokens: \t" : "\n\tdata:        \t", out);
        m4word_data_print(w, 0, out);
    }
    fputs("\n\tcode:        \t", out);
    m4word_code_print(w, out);
    fputs("\n}\n", out);
}

static void m4word_print_fwd_recursive(const m4word *w, FILE *out) {
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
    ret.addr = name->addr;
    ret.n = name->n;
    return ret;
}

const m4word *m4word_prev(const m4word *w) {
    if (w == NULL || w->prev_off == 0) {
        return NULL;
    }
    return (const m4word *)((const m4char *)w - w->prev_off);
}

/* ----------------------- m4wordlist ----------------------- */

m4wordlist m4wordlist_forth = {&m4dict_forth};
m4wordlist m4wordlist_m4th_user = {&m4dict_m4th_user};
m4wordlist m4wordlist_m4th_core = {&m4dict_m4th_core};
m4wordlist m4wordlist_m4th_impl = {&m4dict_m4th_impl};

const m4word *m4wordlist_lastword(const m4wordlist *wid) {
    if (wid == NULL) {
        return NULL;
    }
    return m4dict_lastword(wid->dict);
}

m4string m4wordlist_name(const m4wordlist *wid) {
    if (wid == NULL) {
        m4string ret = {};
        return ret;
    }
    return m4dict_name(wid->dict);
}

void m4wordlist_print(const m4wordlist *wid, FILE *out) {
    if (out == NULL || wid == NULL) {
        return;
    }
    m4dict_print(wid->dict, out);
}

/* ----------------------- m4th ----------------------- */

m4th *m4th_new() {
    m4th *m = (m4th *)m4mem_allocate(sizeof(m4th));
    m->dstack = m4stack_alloc(dstack_n);
    m->rstack = m4stack_alloc(rstack_n);
    m->ip = NULL;
    m->ftable = ftable;
    m->in = m4iobuf_alloc(inbuf_n);
    m->in.next = m->in.size;
    m->out = m4iobuf_alloc(outbuf_n);
    m->state = m4th_state_interpret;
    memset(m->c_regs, '\0', sizeof(m->c_regs));
    m->user_size = ((m4cell)&m->user_var[0] - (m4cell)&m->user_size) / SZ;
    m->user_next = m->user_size;
    m->w = NULL;
    m->mem = m4cbuf_alloc(dataspace_n);
    m->base = 10;
    memset(&m->searchorder, '\0', sizeof(m->searchorder));
    m4th_also(m, &m4wordlist_forth);
    m4th_also(m, &m4wordlist_m4th_user);
    m->quit = m4fbye;
    m->err = 0;
    return m;
}

void m4th_del(m4th *m) {
    if (m) {
        m4cbuf_free(&m->mem);
        m4iobuf_free(&m->out);
        m4iobuf_free(&m->in);
        m4stack_free(&m->rstack);
        m4stack_free(&m->dstack);
        m4mem_free(m);
    }
}

/* does NOT modify m->state and user variables as m->base, m->searchorder... */
void m4th_clear(m4th *m) {
    m->dstack.curr = m->dstack.end;
    m->rstack.curr = m->rstack.end;
    m->w = NULL;
    m->ip = NULL;
    memset(m->c_regs, '\0', sizeof(m->c_regs));
    m->in.next = m->in.size;
    m->out.next = 0;
    m->mem.curr = m->mem.start;
    m->err = 0;
}

void m4th_also(m4th *m, m4wordlist *wid) {
    m4searchorder *s = &m->searchorder;
    if (wid != NULL && s->n < m4searchorder_max) {
        s->addr[s->n++] = wid;
    }
}

m4cell m4th_knows(const m4th *m, const m4wordlist *wid) {
    const m4searchorder *s = &m->searchorder;
    m4cell_u i, n = s->n;
    if (wid == NULL) {
        return tfalse;
    }
    for (i = 0; i < n; i++) {
        if (s->addr[i] == wid) {
            return ttrue;
        }
    }
    return tfalse;
}

m4cell m4th_execute_word(m4th *m, const m4word *w) {
    m4token code[2 + SZ / SZt];
    const m4token *save_ip = m->ip;
    m4cell ret;
    {
        m4cell cell = (m4cell)w;
        code[0] = m4_call_;
        memcpy(code + 1, &cell, SZ);
        code[1 + SZ / SZt] = m4bye;
    }
    m->ip = code;
    ret = m4th_run(m);
    m->ip = save_ip;
    return ret;
}
