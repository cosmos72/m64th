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
#include "impl.h" /* tfalse, ttrue */
#include "include/dict_all.mh"
#include "include/dict_fwd.h"
#include "include/func.mh"
#include "include/func_fwd.h"
#include "include/macro.mh"
#include "include/word_fwd.h"
#include "include/wordlist_fwd.h"
#include <assert.h> /* assert()  */
#include <errno.h>  /* errno     */
#include <stdio.h>  /* printf() */
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
};

typedef char m4th_assert_sizeof_m4token_equal_SZt[(sizeof(m4token) == SZt) ? 1 : -1];
typedef char m4th_assert_sizeof_m4cell_equal_SZ[(sizeof(m4cell) == SZ) ? 1 : -1];

static inline void dpush(m4th *m, m4cell x) {
    *--m->dstack.curr = x;
}

#if 0  /* unused */
static inline m4cell dpop(m4th *m) {
    return *m->dstack.curr++;
}
#endif /* 0 */

/* -------------- m4char -------------- */

static void m4char_print_escape(const m4char ch, FILE *out) {
    const char *seq = NULL;
    if (ch >= ' ' && ch <= '~' && ch != '\\' && ch != '\'' && ch != '"') {
        fputc((char)ch, out);
        return;
    }
    switch (ch) {
    case '\a':
        seq = "\\a";
        break;
    case '\b':
        seq = "\\b";
        break;
    case '\t':
        seq = "\\t";
        break;
    case '\n':
        seq = "\\n";
        break;
    case '\v':
        seq = "\\v";
        break;
    case '\f':
        seq = "\\f";
        break;
    case '\r':
        seq = "\\r";
        break;
    case 27: /* escape */
        seq = "\\e";
        break;
    case '"':
        seq = "\\\"";
        break;
    case '\'':
        seq = "\\\'";
        break;
    case '\\':
        seq = "\\\\";
        break;
    }
    if (seq) {
        fputs(seq, out);
    } else {
        fprintf(out, "\\x%02x", (unsigned)ch);
    }
}

/* ----------------------- m4mem ----------------------- */

static inline m4char *m4_aligned_at(const void *addr, m4ucell power_of_two) {
    return (m4char *)(((m4cell)addr + power_of_two - 1) & ~(m4cell)(power_of_two - 1));
}

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

void m4flags_print(m4flags fl, m4printmode mode, FILE *out) {
    m4char printed = 0;
    m4char skip;
    if (out == NULL) {
        return;
    } else if (!fl) {
        fputc('0', out);
        return;
    } else if (fl & m4flag_compile_only) {
        fputs((mode == m4mode_user ? "compile_only" : "M4FLAG_COMPILE_ONLY"), out);
        printed++;
    }
    switch (m4flags_consume_ip(fl)) {
    case 2:
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|consumes_ip_2" : "|M4FLAG_CONSUMES_IP_2") + skip, out);
        break;
    case 4:
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|consumes_ip_4" : "|M4FLAG_CONSUMES_IP_4") + skip, out);
        break;
    case 8:
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|consumes_ip_8" : "|M4FLAG_CONSUMES_IP_8") + skip, out);
        break;
    }
    if (fl & m4flag_inline_always) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|inline_always" : "|M4FLAG_INLINE_ALWAYS") + skip, out);
    } else if (fl & m4flag_inline) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|inline" : "|M4FLAG_INLINE") + skip, out);
    }
    if ((fl & m4flag_jump_mask) == m4flag_jump) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|jump" : "|M4FLAG_JUMP") + skip, out);
    } else if ((fl & m4flag_jump_mask) == m4flag_may_jump) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|may_jump" : "|M4FLAG_MAY_JUMP") + skip, out);
    }
    if (fl & m4flag_mem_fetch) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|mem_fetch" : "|M4FLAG_MEM_FETCH") + skip, out);
    }
    if (fl & m4flag_mem_store) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|mem_store" : "|M4FLAG_MEM_STORE") + skip, out);
    }
    if ((fl & m4flag_pure_mask) == m4flag_pure) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|pure" : "|M4FLAG_PURE") + skip, out);
    }
    if (fl & m4flag_immediate) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|immediate" : "|M4FLAG_IMMEDIATE") + skip, out);
    }
    if (fl & m4flag_data_tokens) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|data_tokens" : "|M4FLAG_DATA_TOKENS") + skip, out);
    }
    switch (fl & m4flag_noopt_mask) {
    case m4flag_create:
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|create" : "|M4FLAG_CREATE") + skip, out);
        break;
    case m4flag_defer:
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|defer" : "|M4FLAG_DEFER") + skip, out);
        break;
    case m4flag_noopt:
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|noopt" : "|M4FLAG_NOOPT") + skip, out);
        break;
    }
    if (fl & m4flag_reexec_after_optimize) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m4mode_user ? "|reexec_after_optimize" : "|M4FLAG_REEXEC_AFTER_OPTIMIZE") +
                  skip,
              out);
    }
}

/* ----------------------- m4string ---------------------- */

m4string m4string_make(const void *addr, const m4ucell n) {
    m4string ret = {(m4char *)addr, n};
    return ret;
}

void m4string_print_escape(m4string str, FILE *out) {
    m4ucell i;
    for (i = 0; i < str.n; i++) {
        m4char_print_escape(str.addr[i], out);
    }
}

/* ----------------------- m4token ----------------------- */

#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 199901L
#warning "ftable[] initialization currently requires C99"
#endif

/* initialize the whole m4token -> m4func conversion table in one fell swoop */
#define FTABLE_ENTRY(strlen, str, name) [M4TOKEN_VAL(name)] = FUNC(name),
static m4func ftable[] = {
    DICT_TOKENS_ALL(FTABLE_ENTRY) /**/[M4____end] = FUNC(_missing_),
};
#undef FTABLE_ENTRY

/* initialize the whole m4token -> m4word conversion table in one fell swoop */
#define WTABLE_ENTRY(strlen, str, name) [M4TOKEN_VAL(name)] = &WORD_SYM(name),
static const m4word *wtable[] = {
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

static m4cell m4token_print_int16(const m4token *code, m4printmode mode, FILE *out) {
    int16_t val;
    memcpy(&val, code, sizeof(val));
    if (mode == m4mode_user) {
        fprintf(out, "%d", (int)val);
    } else {
        fprintf(out, (sizeof(val) == SZt ? "T(%d)" : "SHORT(%d)"), (int)val);
    }
    return sizeof(val) / SZt;
}

static m4cell m4token_print_int32(const m4token *code, m4printmode mode, FILE *out) {
    int32_t val;
    (void)mode;
    memcpy(&val, code, sizeof(val));
    if (val >= -1024 && val <= 1024) {
        fprintf(out, (mode == m4mode_user ? "%ld" : "INT(%ld)"), (long)val);
    } else {
        fprintf(out, (mode == m4mode_user ? "$%lx" : "INT(0x%lx)"), (unsigned long)val);
    }
    return sizeof(val) / SZt;
}

static m4cell m4token_print_int64(const m4token *code, m4printmode mode, FILE *out) {
    int64_t val;
    (void)mode;
    memcpy(&val, code, sizeof(val));
    if (val >= -1024 && val <= 1024) {
        fprintf(out, (mode == m4mode_user ? "%ld" : "CELL(%ld)"), (long)val);
    } else {
        fprintf(out, (mode == m4mode_user ? "$%lx" : "CELL(0x%lx)"), (unsigned long)val);
    }
    return sizeof(val) / SZt;
}

static m4cell m4token_print_xt(const m4token *code, m4printmode mode, FILE *out) {
    m4xt val;
    const m4word *w;
    memcpy(&val, code, sizeof(val));
    if (val != NULL) {
        w = m4xt_word(val);
    } else {
        w = &WORD_SYM(_missing_);
    }
    if (mode == m4mode_user) {
        m4string_print(m4word_name(w), m4mode_user, out);
    } else {
        fputs("XT(", out);
        m4string_print(m4word_ident(w), m4mode_user, out);
        fputc(')', out);
    }
    return sizeof(val) / SZt;
}

static m4cell m4token_print_lit_xt(const m4token *code, m4printmode mode, FILE *out) {
    fputs((mode == m4mode_user ? "['] " : "_lit_xt_, "), out);
    return m4token_print_xt(code, mode, out);
}

static m4cell m4token_print_lit_string(const m4string str, m4printmode mode, FILE *out) {
    if (mode == m4mode_user) {
        fputs("s\\\" ", out);
        m4string_print_escape(str, out);
        fputc('"', out);
    } else {
        fprintf(out, "LIT_STRING(%lu, \"", (unsigned long)str.n);
        m4string_print_escape(str, out);
        fputs("\")", out);
    }
    return 1 + (str.n + SZt - 1) / SZt;
}

static m4cell m4token_print_call(const m4token *code, m4printmode mode, FILE *out) {
    m4cell val, ret = 0;
    memcpy(&val, code, sizeof(val));
    if (mode != m4mode_user) {
        fputs("CALL(", out);
    }
    if (val > 4096) {
        const m4word *w = (const m4word *)(val - WORD_OFF_XT);
        const m4string name = (mode == m4mode_user ? m4word_name(w) : m4word_ident(w));
        if (name.addr && name.n > 0) {
            m4string_print(name, m4mode_user, out);
            ret = sizeof(val) / SZt;
        }
    }
    if (ret == 0) {
        ret = m4token_print_int64(code, mode, out);
    }
    if (mode != m4mode_user) {
        fputc(')', out);
    }
    return ret;
}

static m4cell m4token_print_catch(m4token catch_end, m4printmode mode, FILE *out) {
    if (mode == m4mode_user && catch_end == m4_catch_end_) {
        fputs("catch", out);
    } else {
        m4token_print(m4_catch_beg_, mode, out);
        fputs((mode == m4mode_user ? " " : ", "), out);
        m4token_print(catch_end, mode, out);
    }
    return 1;
}

void m4token_print(m4token tok, m4printmode mode, FILE *out) {
    const m4word *w = m4token_to_word(tok);
    if (w != NULL) {
        const m4string name = (mode == m4mode_user ? m4word_name(w) : m4word_ident(w));
        if (name.addr != NULL && name.n != 0) {
            m4string_print(name, m4mode_user, out);
            return;
        }
    }
    /* FIXME: this assumes sizeof(m4token) == 2 */
    m4token_print_int16(&tok, mode, out);
}

#if 0 /* unused */
static m4cell m4token_print_word(const m4token *code, m4printmode mode, FILE *out) {
    m4cell val;
    memcpy(&val, code, sizeof(val));
    if (val > 4096) {
        const m4word *w = (const m4word *)val;
        const m4string name = m4word_name(w);
        if (name.addr && name.n > 0) {
            fputs("WADDR(", out);
            m4string_print(name, mode, out);
            fputs(") ", out);
            return sizeof(val) / SZt;
        }
    }
    return m4token_print_int64(code, out);
}
#endif

static m4cell m4token_print_consumed_ip(m4token tok, const m4token *code, m4cell maxn,
                                        const char *separator, m4printmode mode, FILE *out) {
    const m4cell nbytes = m4token_consumes_ip(tok);
    if (nbytes == 0 || nbytes / SZt > maxn) {
        return 0;
    } else if (nbytes == SZt &&
               (tok == m4_lit_tok_ || tok == m4_lit_comma_ || tok == m4_check_lit_tok_)) {
        fputs(separator, out);
        if (mode == m4mode_user) {
            fputc('\'', out);
        }
        m4token_print(code[0], mode, out);
        return 1;
    } else if (nbytes == 2 * SZt && tok == m4_compile_jump_lit_) {
        fputs(separator, out);
        if (mode == m4mode_user) {
            fputc('\'', out);
        }
        m4token_print(code[0], mode, out);
        fputs(separator, out);
        if (mode == m4mode_user) {
            fputc('\'', out);
        }
        m4token_print(code[1], mode, out);
        return 2;
    } else if (nbytes == SZ && tok == m4_lit_xt_) {
        fputs(separator, out);
        return m4token_print_xt(code, mode, out);
    }
    switch (nbytes) {
    case 2:
        fputs(separator, out);
        return m4token_print_int16(code, mode, out);
    case 4:
        fputs(separator, out);
        return m4token_print_int32(code, mode, out);
    case 8:
        fputs(separator, out);
        return m4token_print_int64(code, mode, out);
    default:
        return 0;
    }
}

static m4cell m4token_print_lit(m4token tok, const m4token *code, m4cell maxn,
                                /**/ m4printmode mode, FILE *out) {
    const char *separator = "";
    if (mode != m4mode_user) {
        m4token_print(tok, mode, out);
        separator = ", ";
    }
    return m4token_print_consumed_ip(tok, code, maxn, separator, mode, out);
}

/* ----------------------- m4cbuf ----------------------- */

static m4cbuf m4cbuf_alloc(m4ucell size) {
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
    m4ucell i, n = src.n;
    if (dst.n != n || (n != 0 && (src.addr == NULL || dst.addr == NULL))) {
        return tfalse;
    }

    for (i = 0; i < n; i++) {
        if (src.addr[i] != dst.addr[i]) {
            return tfalse;
        }
    }
    return ttrue;
}

void m4code_print(m4code src, m4printmode mode, FILE *out) {
    const m4token *const code = src.addr;
    m4ucell i, n = src.n;
    const char *separator = "";
    const char *next_separator = (mode == m4mode_user ? " " : ", ");
    if (code == NULL || out == NULL) {
        return;
    }
    fprintf(out, (mode == m4mode_user ? "<%lu> " : "/*%lu*/ "), (unsigned long)n);
    for (i = 0; i < n;) {
        const m4token tok = code[i++];
        fputs(separator, out);
        separator = next_separator;
        if (tok == m4_call_xt_ && n - i >= SZ / SZt) {
            i += m4token_print_call(code + i, mode, out);
        } else if (tok == m4_catch_beg_ && i < n) {
            i += m4token_print_catch(code[i], mode, out);
        } else if (tok == m4_lit_xt_ && n - i >= SZ / SZt) {
            i += m4token_print_lit_xt(code + i, mode, out);
        } else if (tok == m4_lit_string_ && n - i >= 2 + (m4ucell)(code[i] + SZt - 1) / SZt) {
            i += m4token_print_lit_string(m4string_make(&code[i + 1], code[i]), mode, out);
        } else if (tok == m4_lit2s_ || tok == m4_lit4s_ || tok == m4_lit8s_) {
            i += m4token_print_lit(tok, code + i, n - i, mode, out);
        } else {
            m4token_print(tok, mode, out);
            i += m4token_print_consumed_ip(tok, code + i, n - i, separator, mode, out);
        }
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

static void m4word_print_fwd_recursive(const m4word *w, m4printmode mode, FILE *out);

void m4dict_print(const m4dict *dict, const m4word *lastw, m4printmode mode, FILE *out) {
    fputs("/* -------- ", out);
    m4string_print(m4dict_name(dict), mode, out);
    fputs(" -------- */\n", out);

    m4word_print_fwd_recursive(lastw ? lastw : m4dict_lastword(dict), mode, out);
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
    if (dst == NULL || dst->addr == NULL) {
        fputs(" m4slice_copy_to_code(): invalid args, dst.addr is NULL", stderr);
        return;
    }
    m4ucell i = 0, j = 0, delta, sn = src.n, dn = dst->n;
    const m4cell *sdata = src.addr;
    m4token *ddata = dst->addr;

    while (i < sn && j < dn) {
        const m4word *w;
        m4cell x = sdata[i++];
        ddata[j++] = (m4token)x;
        if (x < 0 || x >= M4____end || (w = wtable[x]) == NULL) {
            continue;
        }
        if (x == m4bye) {
            sn = i;
            break;
        }
        if (x == m4_lit_string_) {
            uint16_t len = (uint16_t)sdata[i];
            if (j + 1 + (len + SZt - 1) / SZt > dn) {
                goto fail;
            }
            delta = m4_2bytes_copy_to_token(len, ddata + j);
            i += delta, j += delta;
            memcpy(ddata + j, (const char *)sdata[i++], len);
            j += (len + SZt - 1) / SZt;
            continue;
        }
        switch (w->flags & M4FLAG_CONSUMES_IP_MASK) {
        case M4FLAG_CONSUMES_IP_2:
            if (j + 2 / SZt > dn) {
                goto fail;
            }
            delta = m4_2bytes_copy_to_token((uint16_t)sdata[i], ddata + j);
            i += delta, j += delta;
            break;
        case M4FLAG_CONSUMES_IP_4:
            if (j + 4 / SZt > dn) {
                goto fail;
            }
            delta = m4_4bytes_copy_to_token((uint32_t)sdata[i], ddata + j);
            i += delta, j += delta;
            break;
        case M4FLAG_CONSUMES_IP_8:
            if (j + 8 / SZt >= dn) {
                goto fail;
            }
            delta = m4_8bytes_copy_to_token((uint64_t)sdata[i], ddata + j);
            i += delta, j += delta;
            break;
        }
    }
    if (i == sn) {
        dst->n = j;
        return;
    }
fail:
    fputs(" m4slice_copy_to_code(): invalid args, dst is too small\n", stderr);
    dst->n = 0;
}

void m4slice_print(m4slice slice, m4cell direction, m4printmode mode, FILE *out) {
    const m4cell *addr = slice.addr;
    const char *dots = "";
    m4cell n = slice.n;
    m4cell step = 1;
    (void)mode;

    fprintf(out, "<%ld> ", (long)n);
    if (n <= 0) {
        return;
    }
    if (direction < 0) {
        addr += n - 1;
        step = -1;
    }
    if (n > 100) {
        n = 100;
        dots = "... ";
    }
    for (; n; n--, addr += step) {
        const long x = (long)*addr;
        if (x > -1024 && x < 1024) {
            fprintf(out, "%ld ", x);
        } else {
            fprintf(out, "$%lx ", x);
        }
    }
    fputs(dots, out);
}
void m4slice_print_stdout(m4slice slice, m4cell direction, m4printmode mode) {
    m4slice_print(slice, direction, mode, stdout);
}

/* ----------------------- m4iobuf ----------------------- */

static m4iobuf *m4iobuf_new(m4ucell capacity) {
    m4iobuf *io = (m4iobuf *)m4mem_allocate(sizeof(m4iobuf) + capacity * sizeof(m4char));
    memset(io, '\0', sizeof(m4iobuf));
    io->func = WORD_SYM(always_eof).code;
    io->max = capacity;
    io->addr = ((m4char *)io) + sizeof(m4iobuf);
    return io;
}

static void m4iobuf_del(m4iobuf *arg) {
    m4mem_free(arg);
}

/* ----------------------- m4stack ----------------------- */

m4stack m4stack_alloc(m4ucell size) {
    m4cell *p = (m4cell *)m4mem_map(size * sizeof(m4cell));
    m4stack ret = {p, p + size - 1, p + size - 1};
    return ret;
}

void m4stack_free(m4stack *arg) {
    if (arg && arg->start) {
        m4mem_unmap(arg->start, (arg->end - arg->start + 1) / sizeof(m4cell));
    }
}

void m4stack_print(const m4stack *stack, m4printmode mode, FILE *out) {
    m4cell *addr = stack->curr;
    const m4ucell n = stack->end - addr;
    if (addr < stack->start) {
        fprintf(out, "<%ld> ", (long)n);
    } else {
        const m4slice slice = {addr, n};
        m4slice_print(slice, -1, mode, out);
    }
}

/* ----------------------- m4stackeffect ----------------------- */

void m4stackeffect_print(m4stackeffect eff, m4printmode mode, FILE *out) {
    uint8_t n = eff & 0xF;
    if (out == NULL) {
        return;
    } else if (n == 0xF) {
        fputs((mode == m4mode_user ? "?" : "-1"), out);
    } else {
        fprintf(out, "%u", (unsigned)n);
    }
    n = eff >> 4;
    if (n == 0xF) {
        fputs((mode == m4mode_user ? " -> ?" : ",-1"), out);
    } else {
        fprintf(out, (mode == m4mode_user ? " -> %u" : ",%u"), (unsigned)n);
    }
}

/* ----------------------- m4stackeffects ----------------------- */

void m4stackeffects_print(m4stackeffects effs, const char *suffix, m4printmode mode, FILE *out) {
    if (mode == m4mode_user) {
        fprintf(out, "    data_stack%s: \t", suffix);
        m4stackeffect_print(effs.dstack, mode, out);
        fprintf(out, "\n    return_stack%s:\t", suffix);
        m4stackeffect_print(effs.rstack, mode, out);
    } else if (effs.dstack == 0 && effs.rstack == 0) {
        fputs("    WORD_STACK_NONE()", out);
    } else if (effs.dstack == (m4stackeffect)-1 && effs.rstack == (m4stackeffect)-1) {
        fputs("    WORD_STACK_ANY()", out);
    } else {
        fputs("    WORD_DSTACK(", out);
        m4stackeffect_print(effs.dstack, mode, out);
        fputs(")\n    WORD_RSTACK(", out);
        m4stackeffect_print(effs.rstack, mode, out);
        fputc(')', out);
    }
}

/* ----------------------- m4string ----------------------- */

void m4string_print(m4string str, m4printmode mode, FILE *out) {
    if (out == NULL) {
        /**/
    } else if (mode != m4mode_user) {
        fputc('"', out);
        m4string_print_escape(str, out);
        fputc('"', out);
    } else if (str.addr != NULL && str.n != 0) {
        fwrite(str.addr, 1, str.n, out);
    }
}

static m4char hexdigit(m4ucell u) {
    static const char hexdigits[] = "0123456789abcdef";
    return hexdigits[u & 0xF];
}

void m4string_print_hex(m4string str, m4printmode mode, FILE *out) {
    const m4char *data = str.addr;
    const char *separator = (mode == m4mode_user ? "" : "0x");
    m4cell i, n = str.n;
    if (out == NULL || data == NULL) {
        return;
    }
    for (i = 0; i < n; i++) {
        fputs(separator, out);
        fputc(hexdigit(data[i] >> 4), out);
        fputc(hexdigit(data[i] >> 0), out);
        separator = (mode == m4mode_user ? " " : ", 0x");
    }
}

/* case insensitive comparison */
m4cell m4string_ci_equals(m4string a, m4string b) {
    m4ucell i, n;
    if (a.n != b.n || (a.addr == NULL) != (b.addr == NULL)) {
        return tfalse;
    }
    if (a.addr == b.addr || a.n == 0) {
        return ttrue;
    }
    for (i = 0, n = a.n; i < n; i++) {
        m4char ai = a.addr[i];
        m4char bi = b.addr[i];
        if (ai != bi) {
            if (ai >= 'A' && ai <= 'Z') {
                ai += 'a' - 'A';
            }
            if (bi >= 'A' && bi <= 'Z') {
                bi += 'a' - 'A';
            }
            if (ai != bi) {
                return tfalse;
            }
        }
    }
    return ttrue;
}

m4cell m4string_equals(m4string a, m4string b) {
    if (a.n != b.n || (a.addr == NULL) != (b.addr == NULL)) {
        return tfalse;
    }
    if (a.addr == b.addr || a.n == 0) {
        return ttrue;
    }
    return memcmp(a.addr, b.addr, a.n) ? tfalse : ttrue;
}

/* ----------------------- m4word ----------------------- */

m4code m4word_code(const m4word *w) {
    m4code ret = {};
    if (w != NULL) {
        ret.addr = (m4token *)w->code;
        ret.n = w->code_n;
    }
    return ret;
}

m4string m4word_data(const m4word *w, m4cell data_offset_n) {
    m4string ret = {};
    if (w->data_n != 0 && w->data_n >= data_offset_n) {
        ret.addr = m4_aligned_at(w->code + w->code_n, SZ) + data_offset_n;
        ret.n = (m4cell)w->data_n - data_offset_n;
    }
    return ret;
}

m4xt m4word_xt(const m4word *w) {
    m4xt ret = NULL;
    if (w != NULL) {
        ret = (m4token *)w->code;
    }
    return ret;
}

const m4word *m4xt_word(m4xt xt) {
    return (const m4word *)((m4cell)xt - WORD_OFF_XT);
}

static void m4word_print_flags(const m4word *w, m4printmode mode, FILE *out);

static void m4word_print_header(const m4word *w, m4printmode mode, FILE *out) {
    m4string w_ident = m4word_ident(w);
    if (mode == m4mode_user) {
        m4string_print(m4word_name(w), mode, out);
        fputs("    /* ", out);
        m4string_print(w_ident, mode, out);
        fputs(" */ {", out);
        m4word_print_flags(w, mode, out);
    } else {
        const m4word *prev = m4word_prev(w);
        fputs("WORD_START(", out);
        m4string_print(w_ident, m4mode_user, out);
        fputs(", ", out);
        m4string_print(prev ? m4word_ident(prev) : w_ident, m4mode_user, out);
        fputc(')', out);
    }
}

static void m4word_print_flags(const m4word *w, m4printmode mode, FILE *out) {
    fputs((mode == m4mode_user ? "\n    flags:\t" : "\n    WORD_FLAGS("), out);
    m4flags_print((m4flags)w->flags, mode, out);
    fputs((mode == m4mode_user ? "" : ")"), out);
}

void m4word_print_code(const m4word *w, m4printmode mode, FILE *out) {
    m4code code;
    if (w == NULL || out == NULL || w->code_n == 0) {
        return;
    }
    code = m4word_code(w);
    if (mode == m4mode_user) {
        if (w->code_n != 0) {
            fputs("\n    code:        \t", out);
            m4code_print(code, mode, out);
        }
    } else {
        fputs("\n        WORD_CODE_TOKENS(\n            ", out);
        m4code_print(code, mode, out);
        fputs("\n        )", out);
    }
}

void m4word_data_print(const m4word *w, m4cell data_offset_n, m4printmode mode, FILE *out) {
    m4string data;
    if (w == NULL || out == NULL || w->data_n == 0) {
        return;
    }
    data = m4word_data(w, data_offset_n);
    if (mode == m4mode_user) {
        fputs((w->flags & m4flag_data_tokens) ? "\n    data_tokens: \t" : "\n    data:        \t",
              out);
    } else {
        if (w->flags & m4flag_data_tokens) {
            fputs(" WORD_DATA_TOKENS(\n            ", out);
        } else {
            fputs(" WORD_DATA_BYTES(\n            ", out);
        }
    }
    if (w->flags & m4flag_data_tokens) {
        m4code code = {(m4token *)data.addr, data.n / (m4cell)SZt};
        m4code_print(code, mode, out);
    } else {
        fprintf(out, (mode == m4mode_user ? "<%lu> " : "/*%lu*/ "), (long)data.n);
        m4string_print_hex(data, mode, out);
    }
    if (mode != m4mode_user) {
        fputs("\n        )", out);
    }
}

static void m4word_codeanddata_print(const m4word *w, m4printmode mode, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    if (mode != m4mode_user) {
        fputs("\n    WORD_CODE_AND_DATA(", out);
        m4string_print(m4word_ident(w), m4mode_user, out);
        fputc(',', out);
    }
    if (w->code_n != 0) {
        m4word_print_code(w, mode, out);
    }
    if (mode != m4mode_user) {
        fputc(',', out);
    }
    if (w->data_n != 0) {
        m4word_data_print(w, 0, mode, out);
    }
    if (mode != m4mode_user) {
        fputs("\n    )", out);
    }
}

static void m4nativelen_print(const m4word *w, m4printmode mode, FILE *out) {
    if (mode == m4mode_user) {
        if (w->native_len != (uint16_t)-1) {
            fprintf(out, "\n    native_len:  \t%d", (int)w->native_len);
        }
    } else if (w->native_len == (uint16_t)-1) {
        fputs("\n    WORD_NATIVE_NONE()", out);
    } else if (w->native_len == 0) {
        fputs("\n    WORD_NATIVE_LEN_0()", out);
    } else {
        fputs("\n    WORD_NATIVE_LEN(", out);
        m4string_print(m4word_ident(w), m4mode_user, out);
        fputc(')', out);
    }
}

static void m4word_footer_print(const m4word *w, m4printmode mode, FILE *out) {
    if (mode == m4mode_user) {
        fputs("\n}\n", out);
    } else {
        fputs("\nWORD_END(", out);
        m4string_print(m4word_ident(w), m4mode_user, out);
        fputs(")\n", out);
    }
}

void m4word_print_stdout(const m4word *w, m4printmode mode) {
    putchar('\n');
    m4word_print(w, mode, stdout);
}

void m4word_print(const m4word *w, m4printmode mode, FILE *out) {
    m4flags jump_flags;
    if (w == NULL || out == NULL) {
        return;
    }
    jump_flags = (m4flags)(w->flags & m4flag_jump_mask);
    m4word_print_header(w, mode, out);
    if (mode != m4mode_user || jump_flags != m4flag_jump) {
        fputc('\n', out);
        m4stackeffects_print(w->eff, "", mode, out);
    }
    if (mode != m4mode_user || jump_flags == m4flag_jump || jump_flags == m4flag_may_jump) {
        fputc('\n', out);
        m4stackeffects_print(w->jump, "_jump", mode, out);
    }
    m4nativelen_print(w, mode, out);
    if (mode != m4mode_user) {
        m4word_print_flags(w, mode, out);
    }
    m4word_codeanddata_print(w, mode, out);
    m4word_footer_print(w, mode, out);
}

static void m4word_print_fwd_recursive(const m4word *w, m4printmode mode, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    m4word_print_fwd_recursive(m4word_prev(w), mode, out);
    m4word_print(w, mode, out);
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

m4string m4word_ident(const m4word *w) {
    m4string ret = {};
    m4string name = m4word_name(w);
    if (name.addr == NULL) {
        return ret;
    }
    /* ident is stored immediately after name */
    const m4countedstring *ident = (const m4countedstring *)(name.addr + name.n);
    ret.addr = ident->addr;
    ret.n = ident->n;
    return ret;
}

const m4word *m4word_prev(const m4word *w) {
    if (w == NULL || w->prev_off == 0) {
        return NULL;
    }
    return (const m4word *)((const m4char *)w - w->prev_off);
}

/* ----------------------- m4wordlist ----------------------- */

m4wordlist *m4wordlist_new(void) {
    typedef struct {
        m4char name_n; /**< # of characters                  */
        m4char name[15];
        m4dict dict;
        m4wordlist wid;
    } m4tuple;
    m4tuple *t;
    m4cell i;
    uint32_t crc;

    /* allocate m4countedstring + m4dict + m4wordlist in a single call */
    t = (m4tuple *)malloc(sizeof(m4tuple));
    if (t == NULL) {
        return NULL;
    }
    memset(t, 0, sizeof(m4tuple));
    crc = m4th_crc_cell((m4cell)t);
    t->name_n = 12;
    memcpy(t->name, "wid-", 4);
    for (i = 0; i < 8; i++) {
        t->name[i + 4] = hexdigit(crc);
        crc >>= 4;
    }
    t->dict.lastword_off = 0; /* no words in m4dict */
    t->dict.name_off = (m4char *)&t->dict - (m4char *)&t->name_n;
    t->wid.dict = &t->dict;
    t->wid.last = NULL;

    return &t->wid;
}

const m4word *m4wordlist_find(const m4wordlist *wid, m4string str) {
    const m4word *w = m4wordlist_lastword(wid);
    while (w != NULL) {
        if (m4string_ci_equals(str, m4word_name(w))) {
            break;
        }
        w = m4word_prev(w);
    }
    return w;
}

const m4word *m4wordlist_lastword(const m4wordlist *wid) {
    if (wid == NULL) {
        return NULL;
    } else if (wid->last) {
        return wid->last;
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

void m4wordlist_print(const m4wordlist *wid, m4printmode mode, FILE *out) {
    if (out == NULL || wid == NULL) {
        return;
    }
    m4dict_print(wid->dict, wid->last, mode, out);
}

/* ----------------------- m4th ----------------------- */

void m4th_init(void) {
    static m4cell initialized = 0;
    if (!initialized) {
        m4th_cpu_features_autoenable();
        m4th_crcinit(m4th_crctable);
        initialized = ttrue;
    }
}

m4th *m4th_new(m4th_opt options) {
    extern void m4f_vm_(m4arg _);
    m4th *m;

    m4th_init();

    m = (m4th *)m4mem_allocate(sizeof(m4th));
    m->dstack = m4stack_alloc(dstack_n);
    if (options & m4opt_return_stack_is_private) {
        m->rstack = m4stack_alloc(rstack_n);
    } else {
        memset(&m->rstack, '\0', sizeof(m->rstack));
    }
    m->locals = NULL;
    m->ip = NULL;
    m->ftable = ftable;
    m->wtable = wtable;
    m->in = m4iobuf_new(inbuf_n);
    m->out = m4iobuf_new(outbuf_n);
    m->vm = m4f_vm_;
    memset(m->c_regs, '\0', sizeof(m->c_regs));
    m->user_size = ((m4cell)&m->user_var[0] - (m4cell)&m->user_size) / SZ;
    m->user_next = m->user_size;
    m->lastw = NULL;
    m->xt = NULL;
    m->localnames = NULL;
    m->mem = m4cbuf_alloc(dataspace_n);
    m->base = 10;
    m->handler = m->ex = 0;
    m->ex_message.addr = NULL;
    m->ex_message.n = 0;
    /* by forth 2012 specs, initial compilation wordlist must be 'forth' */
    /* see https://forth-standard.org/standard/search/FORTH-WORDLIST */
    m->compile_wid = &m4wordlist_forth;
    memset(&m->searchorder, '\0', sizeof(m->searchorder));
    /* put 'm4th-user' wordlist at lower priority:                        */
    /* compilation wordlist is initially 'forth' and newly-defined words  */
    /* should shadow existing ones in either wordlist                     */
    m4th_also(m, &m4wordlist_m4th_user);
    m4th_also(m, &m4wordlist_forth);
    /* redundancy: help users against removing 'forth' wordlist accidentally */
    m4th_also(m, &m4wordlist_forth);

    return m;
}

void m4th_del(m4th *m) {
    if (m) {
        m4cbuf_free(&m->mem);
        m4iobuf_del(m->out);
        m4iobuf_del(m->in);
        m4stack_free(&m->rstack);
        m4stack_free(&m->dstack);
        m4mem_free(m);
    }
}

/* does NOT modify m->state and user variables as m->base, m->searchorder... */
void m4th_clear(m4th *m) {
    extern void m4f_vm_(m4arg _);

    m->dstack.curr = m->dstack.end;
    m->rstack.curr = m->rstack.end;
    m->vm = m4f_vm_;
    memset(m->c_regs, '\0', sizeof(m->c_regs));
    m->in->err = m->in->pos = m->in->end = 0;
    m->out->err = m->out->pos = m->out->end = 0;
    m->ip = NULL;
    m->lastw = NULL;
    m->xt = NULL;
    m->localnames = NULL;
    m->mem.curr = m->mem.start;
    m->handler = m->ex = 0;
    m->ex_message.addr = NULL;
    m->ex_message.n = 0;
}

const m4cell *m4th_state(const m4th *m) {
    return (const m4cell *)&m->xt;
}

void m4th_also(m4th *m, m4wordlist *wid) {
    m4searchorder *s = &m->searchorder;
    if (wid != NULL && s->n < m4searchorder_max) {
        s->addr[s->n++] = wid;
    }
}

/* C implementation of ':' i.e. start compiling a new word */
void m4th_colon(m4th *m, m4string name) {
    m4char *here = m->mem.curr;
    m4word *w;
    if (!name.addr) {
        name.n = 0;
    } else if (name.n >= 0xff) {
        name.n = 0xff;
    }
    if (name.n) {
        *here++ = name.n;
        memcpy(here, name.addr, name.n);
        here += name.n;
    }
    here = m4_aligned_at(here, SZ);
    w = (m4word *)here;
    memset(w, '\0', sizeof(m4word));
    w->name_off = name.n ? here - m->mem.start : 0;
    m->lastw = w;
    m->mem.curr = (m4char *)(m->xt = m4word_xt(w));
    /*
     * reproduce behaviour of forth word ':'
     * also push to dstack colon-sys i.e. 0 m4colon
     *
     * Note: most tests overwrite dstack at initialization,
     * discarding these values.
     */
    dpush(m, 0);
    dpush(m, m4colon);
}

/* C implementation of ';' i.e. finish compiling a new word */
void m4th_semi(m4th *m) {
    m4token *here = (m4token *)m4_aligned_at(m->mem.curr, SZt);
    if (m->lastw == NULL) {
        return;
    }
    *here++ = m4exit;
    m->lastw->code_n = here - m->xt;
    m->xt = NULL;
    m->mem.curr = (m4char *)here;
}

/* compute m->lastw->data_n (if not compiling) or m->lastw->code_n (if compiling) from HERE */
void m4th_sync_lastw(m4th *m) {
    m4word *w = m->lastw;
    if (w == NULL) {
        ;
    } else if (m->xt) {
        /* compiling */
        m4char *here = m->mem.curr = m4_aligned_at(m->mem.curr, SZt);
        w->code_n = (m4token *)here - w->code;
    } else {
        /* not compiling */
        w->data_n = m->mem.curr - m4_aligned_at(w->code + w->code_n, SZ);
    }
}

m4cell m4th_knows(const m4th *m, const m4wordlist *wid) {
    const m4searchorder *s = &m->searchorder;
    m4ucell i, n = s->n;
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
        m4cell cell = (m4cell)w->code;
        code[0] = m4_call_xt_;
        memcpy(code + 1, &cell, SZ);
        code[1 + SZ / SZt] = m4bye;
    }
    m->ip = code;
    ret = m4th_run(m);
    m->ip = save_ip;
    return ret;
}

/** wrapper around REPL */
m4cell m4th_repl(m4th *m) {
    return m4th_execute_word(m, &m4w_repl);
}

/* ----------------------- optional cpu features ----------------------- */
extern void m4fcrc_cell(m4arg _);
extern void m4fcrc_cell_simd(m4arg _);
extern void m4fcrc_string(m4arg _);
extern void m4fcrc_string_simd(m4arg _);

m4cell m4th_cpu_features_enabled(void) {
    m4cell mask = 0;
    if (ftable[m4crc_cell] == m4fcrc_cell_simd || ftable[m4crc_string] == m4fcrc_string_simd) {
        mask |= m4th_cpu_feature_crc32c;
    }
    return mask;
}

void m4th_cpu_features_enable(m4cell mask) {
    if (mask & m4th_cpu_feature_crc32c) {
        ftable[m4crc_cell] = m4fcrc_cell_simd;
        ftable[m4crc_string] = m4fcrc_string_simd;
    }
}

void m4th_cpu_features_disable(m4cell mask) {
    if (mask & m4th_cpu_feature_crc32c) {
        ftable[m4crc_cell] = m4fcrc_cell;
        ftable[m4crc_string] = m4fcrc_string;
    }
}
