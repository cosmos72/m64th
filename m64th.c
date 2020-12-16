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

#include "include/m64th.h"
#include "impl.h" /* tfalse, ttrue */
#include "include/dict_all.mh"
#include "include/dict_fwd.h"
#include "include/func.mh"
#include "include/func_fwd.h"
#include "include/m64th.mh" /* M64TH_PICT_MAXSIZE */
#include "include/macro.mh"
#include "include/token.h"
#include "include/word_fwd.h"
#include "include/wordlist_fwd.h"

#include <assert.h> /* assert()  */
#include <errno.h>  /* errno     */
#include <stdio.h>  /* printf() */
#include <stdlib.h> /* exit(), free(), malloc() */
#include <string.h> /* memset()  */

#if defined(__unix__)
#include <sys/mman.h> /* mmap(), munmap() */
#include <unistd.h>   /* sysconf(), Android cacheflush() */

#elif defined(_WIN32)
#include <windows.h> /* GetCurrentProcess(), FlushInstructionCache() */
#endif

enum {
    dstack_n = 256,
    rstack_n = 64,
    code_n = 1024,
    inbuf_n = 1024,
    outbuf_n = 1024,
    dataspace_n = 65536,
    asm_n = 16384,
};

typedef char m64th_assert_sizeof_m6token_equal_SZt[(sizeof(m6token) == SZt) ? 1 : -1];
typedef char m64th_assert_sizeof_m6cell_equal_SZ[(sizeof(m6cell) == SZ) ? 1 : -1];

typedef char
    m64th_assert_sizeof_enum_m6token_e[(sizeof(enum m6token_e) == sizeof(m6token_e)) ? 1 : -1];
typedef char m64th_assert_sizeof_m6token_e[(sizeof(m6token_e) >= sizeof(m6token)) ? 1 : -1];
typedef char m64th_assert_m6_missing_equal_0[((m6token_e)m6_missing_ == 0) ? 1 : -1];

static inline void dpush(m64th *m, m6cell x) {
    *--m->dstack.curr = x;
}

#if 0  /* unused */
static inline m6cell dpop(m64th *m) {
    return *m->dstack.curr++;
}
#endif /* 0 */

/* -------------- m6char -------------- */

static void m6char_print_escape(const m6char ch, FILE *out) {
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
        fprintf(out, "\\%03o", (unsigned)ch);
    }
}

/* ----------------------- m6mem ----------------------- */

static inline m6char *m6_aligned_at(const void *addr, m6ucell power_of_two) {
    return (m6char *)(((m6cell)addr + power_of_two - 1) & ~(m6cell)(power_of_two - 1));
}

static void m6mem_oom(size_t bytes) {
    fprintf(stderr, "failed to allocate %lu bytes: %s\n", (unsigned long)bytes, strerror(errno));
    exit(1);
}

#ifdef __unix__

/**
 * for some reason, this function *must* be static when compiling on arm64
 * with clang and one of the options -Os -O -O1 -O2
 *
 * otherwise strange things happen and some tests fail, see issue
 * https://github.com/cosmos72/m64th/issues/2
 */
static size_t get_pagesize(void) {
    static size_t ret = 0;
    if (ret == 0) {
        ret =
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
    return ret;
}

size_t m6mem_pagesize(void) {
    return get_pagesize();
}

/* round up 'bytes' to a multiple of page size */
static size_t m6mem_pagesize_ceil(size_t bytes) {
    const size_t page = get_pagesize();
    return (bytes + page - 1) / page * page;
}

/* align up addr to a multiple of funcalign = SZ */
static m6char *m6mem_funcalign_up(m6char *addr) {
    const size_t SZm1 = SZ - 1;
    return (m6char *)(((size_t)addr + SZm1) & ~SZm1);
}

int m6protect_to_mmap_prot(m6protect prot) {
    return (prot & m6protect_read ? PROT_READ : 0) |   /* ___________________ */
           (prot & m6protect_write ? PROT_WRITE : 0) | /* ___________________ */
           (prot & m6protect_exec ? PROT_EXEC : 0);
}

void *m6mem_map(size_t bytes, m6protect prot) {
    void *ptr = NULL;
    if (bytes != 0) {
        bytes = m6mem_pagesize_ceil(bytes);
        if ((ptr = mmap(NULL, bytes, m6protect_to_mmap_prot(prot),
                        MAP_PRIVATE | MAP_ANONYMOUS
#ifdef MAP_STACK
                            | MAP_STACK /* for BSD */
#endif
                        ,
                        -1, 0)) == (void *)-1) {
            m6mem_oom(bytes);
        }
        memset(ptr, '\xFF', bytes);
    }
    return ptr;
}

void m6mem_unmap(void *ptr, size_t bytes) {
    if (bytes != 0) {
        bytes = m6mem_pagesize_ceil(bytes);
        munmap(ptr, bytes);
    }
}
void m6mem_protect(void *ptr, size_t bytes, m6protect prot) {
    if (bytes != 0) {
        mprotect(ptr, bytes, m6protect_to_mmap_prot(prot));
    }
}

#else /* ! __unix__ */
void *m6mem_map(size_t bytes, m6protect prot) {
    (void)prot;
    return m6mem_allocate(bytes);
}
void m6mem_unmap(void *ptr, size_t bytes) {
    (void)bytes;
    m6mem_free(ptr);
}
void m6mem_protect(void *ptr, size_t bytes, m6protect prot) {
    (void)ptr;
    (void)bytes;
    (void)prot;
}
#endif

void *m6mem_allocate(size_t bytes) {
    void *ptr = NULL;
    if (bytes != 0) {
        if ((ptr = malloc(bytes)) == NULL) {
            m6mem_oom(bytes);
        }
        memset(ptr, '\xFF', bytes);
    }
    return ptr;
}

void m6mem_free(void *ptr) {
    free(ptr);
}

void *m6mem_resize(void *ptr, size_t bytes) {
    if (bytes == 0) {
        free(ptr);
        return NULL;
    } else if (ptr == NULL) {
        return m6mem_allocate(bytes);
    }
    if ((ptr = realloc(ptr, bytes)) == NULL) {
        m6mem_oom(bytes);
    }
    return ptr;
}

/* ----------------------- m6flags ----------------------- */

/** return how many bytes of code are consumed by token or word marked with given flags */
m6cell m6flags_consume_ip(m6flags fl) {
    fl &= m6flag_consumes_ip_mask;
    if (fl == m6flag_consumes_ip_2) {
        return 2;
    } else if (fl == m6flag_consumes_ip_4) {
        return 4;
    } else if (fl == m6flag_consumes_ip_8) {
        return 8;
    } else if (fl == m6flag_consumes_ip_10) {
        return 10;
    } else {
        return 0;
    }
}

void m6flags_print(m6flags fl, m6printmode mode, FILE *out) {
    m6char printed = 0;
    m6char skip;
    if (out == NULL) {
        return;
    } else if (!fl) {
        fputc('0', out);
        return;
    } else if (fl & m6flag_compile_only) {
        fputs((mode == m6mode_user ? "compile_only" : "M6FLAG_COMPILE_ONLY"), out);
        printed++;
    }
    switch (m6flags_consume_ip(fl)) {
    case 2:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|consumes_ip_2" : "|M6FLAG_CONSUMES_IP_2") + skip, out);
        break;
    case 4:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|consumes_ip_4" : "|M6FLAG_CONSUMES_IP_4") + skip, out);
        break;
    case 8:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|consumes_ip_8" : "|M6FLAG_CONSUMES_IP_8") + skip, out);
        break;
    case 10:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|consumes_ip_10" : "|M6FLAG_CONSUMES_IP_10") + skip, out);
        break;
    }
    switch (fl & m6flag_inline_mask) {
    case m6flag_inline:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|inline" : "|M6FLAG_INLINE") + skip, out);
        break;
    case m6flag_inline_always:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|inline_always" : "|M6FLAG_INLINE_ALWAYS") + skip, out);
        break;
    case m6flag_inline_asm:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|inline_asm" : "|M6FLAG_INLINE_ASM") + skip, out);
        break;
    }
    if ((fl & m6flag_jump_mask) == m6flag_jump) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|jump" : "|M6FLAG_JUMP") + skip, out);
    } else if ((fl & m6flag_jump_mask) == m6flag_may_jump) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|may_jump" : "|M6FLAG_MAY_JUMP") + skip, out);
    }
    if ((fl & m6flag_pure_mask) == m6flag_pure) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|pure" : "|M6FLAG_PURE") + skip, out);
    }
    if (fl & m6flag_mem_fetch) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|mem_fetch" : "|M6FLAG_MEM_FETCH") + skip, out);
    }
    if (fl & m6flag_mem_store) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|mem_store" : "|M6FLAG_MEM_STORE") + skip, out);
    }
    if (fl & m6flag_immediate) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|immediate" : "|M6FLAG_IMMEDIATE") + skip, out);
    }
    if (fl & m6flag_data_tokens) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|data_tokens" : "|M6FLAG_DATA_TOKENS") + skip, out);
    }
    switch (fl & m6flag_opt_mask) {
    case m6flag_asm:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|asm" : "|M6FLAG_ASM") + skip, out);
        break;
    case m6flag_noasm:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|noasm" : "|M6FLAG_NOASM") + skip, out);
        break;
    case m6flag_create:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|create" : "|M6FLAG_CREATE") + skip, out);
        break;
    case m6flag_defer:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|defer" : "|M6FLAG_DEFER") + skip, out);
        break;
    case m6flag_value:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|value" : "|M6FLAG_VALUE") + skip, out);
        break;
    case m6flag_var:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|var" : "|M6FLAG_VAR") + skip, out);
        break;
    case m6flag_noopt:
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|noopt" : "|M6FLAG_NOOPT") + skip, out);
        break;
    }
    if (fl & m6flag_reexec_after_optimize) {
        skip = printed++ ? 0 : 1;
        fputs((mode == m6mode_user ? "|reexec_after_optimize" : "|M6FLAG_REEXEC_AFTER_OPTIMIZE") +
                  skip,
              out);
    }
}

/* ----------------------- m6string ---------------------- */

/* convert m6countedstring to m6string */
m6string m6string_count(const m6countedstring *cstr) {
    m6string ret = {(m6char *)cstr->addr, cstr->n};
    return ret;
}

m6string m6string_make(const void *addr, const m6ucell n) {
    m6string ret = {(m6char *)addr, n};
    return ret;
}

void m6string_print_escape(m6string str, FILE *out) {
    m6ucell i;
    for (i = 0; i < str.n; i++) {
        m6char_print_escape(str.addr[i], out);
    }
}

/* ----------------------- m6token ----------------------- */

#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 199901L
#warning "ftable[] initialization currently requires C99"
#endif

/* initialize the whole m6token -> m6func conversion table in one fell swoop */
#define FTABLE_ENTRY(strlen, str, name) [M6TOKEN_VAL(name)] = FUNC(name),
static m6func ftable[] = {
    DICT_TOKENS_ALL(FTABLE_ENTRY) /**/[M6____end] = FUNC(_missing_),
};
#undef FTABLE_ENTRY

/* initialize the whole m6token -> m6word conversion table in one fell swoop */
#define WTABLE_ENTRY(strlen, str, name) [M6TOKEN_VAL(name)] = &WORD_SYM(name),
static const m6word *wtable[] = {
    DICT_TOKENS_ALL(WTABLE_ENTRY) /**/[M6____end] = NULL,
};
#undef WTABLE_ENTRY

enum { wtable_n = sizeof(wtable) / sizeof(wtable[0]) };

/** return how many bytes of code are skipped by executing token */
m6cell m6token_consumes_ip(m6token tok) {
    const m6word *w = m6token_to_word(tok);
    if (w != NULL) {
        return m6flags_consume_ip((m6flags)w->flags);
    }
    return 0;
}

/** try to find the m6word that describes given token */
const m6word *m6token_to_word(m6token tok) {
    if (/*tok >= 0 &&*/ tok < M6____end) {
        return wtable[tok];
    }
    return NULL;
}

static m6cell m6token_print_int16(const m6token *code, m6printmode mode, FILE *out) {
    int16_t val;
    memcpy(&val, code, sizeof(val));
    if (mode == m6mode_user) {
        fprintf(out, "%d", (int)val);
    } else {
        fprintf(out, (sizeof(val) == SZt ? "T(%d)" : "SHORT(%d)"), (int)val);
    }
    return sizeof(val) / SZt;
}

static m6cell m6token_print_int32(const m6token *code, m6printmode mode, FILE *out) {
    int32_t val;
    memcpy(&val, code, sizeof(val));
    if (val >= -1024 && val <= 1024) {
        fprintf(out, (mode == m6mode_user ? "%d" : "INT(%d)"), (int)val);
    } else if (val > 0) {
        fprintf(out, (mode == m6mode_user ? "$%x" : "INT(0x%x)"), (unsigned)val);
    } else {
        fprintf(out, (mode == m6mode_user ? "$-%x" : "INT(-0x%x)"), (unsigned)-val);
    }
    return sizeof(val) / SZt;
}

static m6cell m6token_print_int64(const m6token *code, m6printmode mode, FILE *out) {
    int64_t val;
    memcpy(&val, code, sizeof(val));
    if (val >= -1024 && val <= 1024) {
        fprintf(out, (mode == m6mode_user ? "%ld" : "CELL(%ld)"), (long)val);
    } else if (val > 0) {
        fprintf(out, (mode == m6mode_user ? "$%lx" : "CELL(0x%lx)"), (unsigned long)val);
    } else {
        fprintf(out, (mode == m6mode_user ? "$-%lx" : "CELL(-0x%lx)"), (unsigned long)-val);
    }
    return sizeof(val) / SZt;
}

typedef enum { m6kind_nt, m6kind_xt } m6namekind;

static m6cell m6token_print_word(const m6token *code, m6printmode mode, m6namekind kind,
                                 FILE *out) {
    const void *val;
    const m6word *w;
    memcpy(&val, code, sizeof(val));
    if (val == NULL) {
        w = &WORD_SYM(_missing_);
    } else if (kind == m6kind_nt) {
        w = (const m6word *)val;
    } else {
        w = m6xt_word((m6xt)val);
    }
    if (mode == m6mode_user) {
        m6string_print(m6word_name(w), m6mode_user, out);
    } else {
        fputs((kind == m6kind_nt ? "NT(" : "XT("), out);
        m6string_print(m6word_ident(w), m6mode_user, out);
        fputc(')', out);
    }
    return sizeof(val) / SZt;
}

static m6cell m6token_print_nt(const m6token *code, m6printmode mode, FILE *out) {
    return m6token_print_word(code, mode, m6kind_nt, out);
}

static m6cell m6token_print_xt(const m6token *code, m6printmode mode, FILE *out) {
    return m6token_print_word(code, mode, m6kind_xt, out);
}

static m6cell m6token_print_lit_nt(const m6token *code, m6printmode mode, FILE *out) {
    m6cell ret;
    fputs((mode == m6mode_user ? "[ parse-name " : "_lit_nt_, "), out);
    ret = m6token_print_nt(code, mode, out);
    fputs((mode == m6mode_user ? " ]" : ""), out);
    return ret;
}

static m6cell m6token_print_lit_xt(const m6token *code, m6printmode mode, FILE *out) {
    fputs((mode == m6mode_user ? "['] " : "_lit_xt_, "), out);
    return m6token_print_xt(code, mode, out);
}

static m6cell m6token_print_lit_string(const m6string str, m6printmode mode, FILE *out) {
    if (mode == m6mode_user) {
        fputs("s\\\" ", out);
        m6string_print_escape(str, out);
        fputc('"', out);
    } else {
        fprintf(out, "LIT_STRING(%lu, \"", (unsigned long)str.n);
        m6string_print_escape(str, out);
        fputs("\")", out);
    }
    return 1 + (str.n + SZt - 1) / SZt;
}

static m6cell m6token_print_call(const m6token *code, m6printmode mode, FILE *out) {
    m6cell val, ret = 0;
    memcpy(&val, code, sizeof(val));
    if (mode != m6mode_user) {
        fputs("CALL(", out);
    }
    if (val > 4096) {
        const m6word *w = (const m6word *)(val - WORD_OFF_XT);
        const m6string name = (mode == m6mode_user ? m6word_name(w) : m6word_ident(w));
        if (name.addr && name.n > 0) {
            m6string_print(name, m6mode_user, out);
            ret = sizeof(val) / SZt;
        }
    }
    if (ret == 0) {
        ret = m6token_print_int64(code, mode, out);
    }
    if (mode != m6mode_user) {
        fputc(')', out);
    }
    return ret;
}

static m6cell m6token_print_catch(m6token catch_end, m6printmode mode, FILE *out) {
    if (mode == m6mode_user && catch_end == m6_catch_end_) {
        fputs("catch", out);
    } else {
        m6token_print(m6_catch_beg_, mode, out);
        fputs((mode == m6mode_user ? " " : ", "), out);
        m6token_print(catch_end, mode, out);
    }
    return 1;
}

void m6token_print(m6token tok, m6printmode mode, FILE *out) {
    const m6word *w = m6token_to_word(tok);
    if (w != NULL) {
        const m6string name = (mode == m6mode_user ? m6word_name(w) : m6word_ident(w));
        if (name.addr != NULL && name.n != 0) {
            m6string_print(name, m6mode_user, out);
            return;
        }
    }
#if SZt == 2
    m6token_print_int16(&tok, mode, out);
#elif SZt == 4
    m6token_print_int32(&tok, mode, out);
#elif SZt == 8
    m6token_print_int64(&tok, mode, out);
#else
#error unsupported sizeof(m6token): expecting 2, 4 or 8
#endif
}

static m6cell m6token_print_consumed_ip(m6token tok, const m6token *code, m6cell maxn,
                                        const char *separator, m6printmode mode, FILE *out) {
    m6cell nbytes = m6token_consumes_ip(tok);
    if (nbytes == 0 || nbytes / SZt > maxn) {
        return 0;
    } else if (nbytes == SZt &&
               (tok == m6_lit_tok_ || tok == m6_lit_comma_ || tok == m6_check_lit_tok_)) {
        fputs(separator, out);
        if (mode == m6mode_user) {
            fputc('\'', out);
        }
        m6token_print(code[0], mode, out);
        return 1;
    } else if (nbytes == 2 * SZt && tok == m6_compile_jump_lit_) {
        fputs(separator, out);
        if (mode == m6mode_user) {
            fputc('\'', out);
        }
        m6token_print(code[0], mode, out);
        fputs(separator, out);
        if (mode == m6mode_user) {
            fputc('\'', out);
        }
        m6token_print(code[1], mode, out);
        return 2;
    } else if (nbytes == SZ && (tok == m6_lit_nt_ || tok == m6_lit_nt_to_body_)) {
        fputs(separator, out);
        return m6token_print_nt(code, mode, out);
    } else if (nbytes == SZ && tok == m6_lit_xt_) {
        fputs(separator, out);
        return m6token_print_xt(code, mode, out);
    }
    switch (nbytes) {
    case 2:
        fputs(separator, out);
        return m6token_print_int16(code, mode, out);
    case 4:
        fputs(separator, out);
        return m6token_print_int32(code, mode, out);
    case 8:
        fputs(separator, out);
        return m6token_print_int64(code, mode, out);
    case 10:
        fputs(separator, out);
        nbytes = m6token_print_int64(code, mode, out);
        fputs(separator, out);
        nbytes += m6token_print_int16(code + 8 / SZt, mode, out);
        return nbytes;
    default:
        return 0;
    }
}

static m6cell m6token_print_lit(m6token tok, const m6token *code, m6cell maxn,
                                /**/ m6printmode mode, FILE *out) {
    const char *separator = "";
    if (mode != m6mode_user) {
        m6token_print(tok, mode, out);
        separator = ", ";
    }
    return m6token_print_consumed_ip(tok, code, maxn, separator, mode, out);
}

/* ----------------------- m6cbuf ----------------------- */

static m6cbuf m6cbuf_alloc(m6ucell size) {
    m6char *p = (m6char *)m6mem_allocate(size * sizeof(m6char));
    m6cbuf ret = {p, p, p + size};
    return ret;
}

static void m6cbuf_free(m6cbuf *arg) {
    if (arg) {
        m6mem_free(arg->start);
        arg->end = arg->curr = arg->start = NULL;
    }
}

static m6cbuf m6cbuf_map(m6ucell size, m6protect prot) {
    m6ucell bytes = m6mem_pagesize_ceil(size);
    m6char *p = (m6char *)m6mem_map(bytes, prot);
    m6cbuf ret = {p, p, p + bytes};
    return ret;
}

static void m6cbuf_unmap(m6cbuf *arg) {
    if (arg) {
        if (arg->end > arg->start) {
            m6mem_unmap(arg->start, arg->end - arg->start);
        }
        arg->end = arg->curr = arg->start = NULL;
    }
}

static void m6cbuf_protect(m6cbuf *arg, m6protect prot) {
    if (arg) {
        m6mem_protect(arg->start, arg->end - arg->start, prot);
    }
}

/* ----------------------- m6addr ----------------------- */

/* align address to next m6cell */
const m6char *m6addr_align_cell(const void *addr) {
    m6cell x = (m6cell)addr;
    return (const m6char *)((x + SZ - 1) & (m6cell)-SZ); /* -SZ == ~(SZ-1) */
}

/* align address to next uint32 */
const m6char *m6addr_align_4(const void *addr) {
    m6cell x = (m6cell)addr;
    return (const m6char *)((x + 4 - 1) & (m6cell)-4);
}

/* ----------------------- m6code ----------------------- */

m6cell m6code_equal(m6code src, m6code dst) {
    m6ucell i, n = src.n;
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

void m6code_print(m6code src, m6printmode mode, FILE *out) {
    const m6token *const code = src.addr;
    m6ucell i, n = src.n;
    const char *separator = "";
    const char *next_separator = (mode == m6mode_user ? " " : ", ");
    if (code == NULL || out == NULL) {
        return;
    }
    fprintf(out, (mode == m6mode_user ? "<%lu> " : "/*%lu*/ "), (unsigned long)n);
    for (i = 0; i < n;) {
        const m6token tok = code[i++];
        fputs(separator, out);
        separator = next_separator;
        if (tok == m6_call_ && n - i >= SZ / SZt) {
            i += m6token_print_call(code + i, mode, out);
        } else if (tok == m6_catch_beg_ && i < n) {
            i += m6token_print_catch(code[i], mode, out);
        } else if (tok == m6_lit_nt_ && n - i >= SZ / SZt) {
            i += m6token_print_lit_nt(code + i, mode, out);
        } else if (tok == m6_lit_xt_ && n - i >= SZ / SZt) {
            i += m6token_print_lit_xt(code + i, mode, out);
        } else if (tok == m6_lit_string_ && n - i >= 2 + (m6ucell)(code[i] + SZt - 1) / SZt) {
            i += m6token_print_lit_string(m6string_make(&code[i + 1], code[i]), mode, out);
        } else if (tok == m6_lit2s_ || tok == m6_lit4s_ || tok == m6_lit8s_) {
            i += m6token_print_lit(tok, code + i, n - i, mode, out);
        } else {
            m6token_print(tok, mode, out);
            i += m6token_print_consumed_ip(tok, code + i, n - i, separator, mode, out);
        }
    }
}

/* ----------------------- m6dict ----------------------- */

const m6word *m6dict_lastword(const m6dict *d) {
    if (d == NULL || d->lastword_off == 0) {
        return NULL;
    }
    return (const m6word *)((const m6char *)d - d->lastword_off);
}

m6string m6dict_name(const m6dict *d) {
    m6string ret = {};
    if (d == NULL || d->name_off == 0) {
        return ret;
    }
    const m6countedstring *name = (const m6countedstring *)((const m6char *)d - d->name_off);
    ret.addr = name->addr;
    ret.n = name->n;
    return ret;
}

static void m6word_print_fwd_recursive(const m6word *w, m6printmode mode, FILE *out);

void m6dict_print(const m6dict *dict, const m6word *lastw, m6printmode mode, FILE *out) {
    fputs("/* -------- ", out);
    m6string_print(m6dict_name(dict), mode, out);
    fputs(" -------- */\n", out);

    m6word_print_fwd_recursive(lastw ? lastw : m6dict_lastword(dict), mode, out);
}

/* ----------------------- m6slice ----------------------- */

static m6cell m6_copy_bytes_to_token(const void *src, m6token *dst, m6cell nbytes) {
    memcpy(dst, src, nbytes);
    return nbytes / SZt;
}

void m6slice_copy_to_code(const m6slice src, m6code *dst) {
    if (src.addr == NULL || src.n == 0) {
        if (dst != NULL) {
            dst->n = 0;
        }
        return;
    }
    if (dst == NULL || dst->addr == NULL) {
        fputs(" m6slice_copy_to_code(): invalid args, dst.addr is NULL", stderr);
        return;
    }
    m6ucell i = 0, j = 0, delta, sn = src.n, dn = dst->n;
    const m6cell *sdata = src.addr;
    m6token *ddata = dst->addr;

    while (i < sn && j < dn) {
        const m6word *w;
        m6cell x = sdata[i++];
        ddata[j++] = (m6token)x;
        if (x < 0 || x >= M6____end || (w = wtable[x]) == NULL) {
            continue;
        }
        if (x == m6bye) {
            sn = i;
            break;
        }
        if (x == m6_lit_string_) {
            uint16_t len = (uint16_t)sdata[i];
            if (j + 1 + (len + SZt - 1) / SZt > dn) {
                goto fail;
            }
            delta = m6_copy_bytes_to_token(sdata + i, ddata + j, 2);
            i += delta, j += delta;
            memcpy(ddata + j, (const char *)sdata[i++], len);
            j += (len + SZt - 1) / SZt;
            continue;
        }
        switch (w->flags & M6FLAG_CONSUMES_IP_MASK) {
        case M6FLAG_CONSUMES_IP_2:
            if (j + 2 / SZt > dn) {
                goto fail;
            }
            delta = m6_copy_bytes_to_token(sdata + i, ddata + j, 2);
            i += delta, j += delta;
            break;
        case M6FLAG_CONSUMES_IP_4:
            if (j + 4 / SZt > dn) {
                goto fail;
            }
            delta = m6_copy_bytes_to_token(sdata + i, ddata + j, 4);
            i += delta, j += delta;
            break;
        case M6FLAG_CONSUMES_IP_8:
            if (j + 8 / SZt >= dn) {
                goto fail;
            }
            delta = m6_copy_bytes_to_token(sdata + i, ddata + j, 8);
            i += delta, j += delta;
            break;
        case M6FLAG_CONSUMES_IP_10:
            if (j + 10 / SZt >= dn) {
                goto fail;
            }
            delta = m6_copy_bytes_to_token(sdata + i, ddata + j, 10);
            i += delta, j += delta;
            break;
        }
    }
    if (i == sn) {
        dst->n = j;
        return;
    }
fail:
    fputs(" m6slice_copy_to_code(): invalid args, dst is too small\n", stderr);
    dst->n = 0;
}

void m6slice_print(m6slice slice, m6cell direction, m6printmode mode, FILE *out) {
    const m6cell *addr = slice.addr;
    const char *dots = "";
    m6cell n = slice.n;
    m6cell step = 1;
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
        } else if (x > 0) {
            fprintf(out, "$%lx ", x);
        } else {
            fprintf(out, "$-%lx ", -x);
        }
    }
    fputs(dots, out);
}
void m6slice_print_stdout(m6slice slice, m6cell direction, m6printmode mode) {
    m6slice_print(slice, direction, mode, stdout);
}

/* ----------------------- m6iobuf ----------------------- */

static m6iobuf *m6iobuf_new(m6ucell capacity) {
    m6iobuf *io = (m6iobuf *)m6mem_allocate(sizeof(m6iobuf) + capacity * sizeof(m6char));
    memset(io, '\0', sizeof(m6iobuf));
    io->func = WORD_SYM(always_eof).code;
    io->max = capacity;
    io->addr = ((m6char *)io) + sizeof(m6iobuf);
    return io;
}

static void m6iobuf_del(m6iobuf *arg) {
    m6mem_free(arg);
}

/* ----------------------- m6stack ----------------------- */

m6stack m6stack_alloc(m6ucell size) {
    m6cell *p = (m6cell *)m6mem_map(size * sizeof(m6cell), m6protect_read_write);
    m6stack ret = {p, p + size - 1, p + size - 1};
    return ret;
}

void m6stack_free(m6stack *arg) {
    if (arg && arg->start) {
        m6mem_unmap(arg->start, (arg->end - arg->start + 1) / sizeof(m6cell));
    }
}

void m6stack_print(const m6stack *stack, m6printmode mode, FILE *out) {
    m6cell *addr = stack->curr;
    const m6ucell n = stack->end - addr;
    if (addr < stack->start) {
        fprintf(out, "<%ld> ", (long)n);
    } else {
        const m6slice slice = {addr, n};
        m6slice_print(slice, -1, mode, out);
    }
}

/* ----------------------- m6stackeffect ----------------------- */

void m6stackeffect_print(m6stackeffect eff, m6printmode mode, FILE *out) {
    uint8_t n = eff & 0xF;
    if (out == NULL) {
        return;
    } else if (n == 0xF) {
        fputs((mode == m6mode_user ? "?" : "-1"), out);
    } else {
        fprintf(out, "%u", (unsigned)n);
    }
    n = eff >> 4;
    if (n == 0xF) {
        fputs((mode == m6mode_user ? " -> ?" : ",-1"), out);
    } else {
        fprintf(out, (mode == m6mode_user ? " -> %u" : ",%u"), (unsigned)n);
    }
}

/* ----------------------- m6stackeffects ----------------------- */

void m6stackeffects_print(m6stackeffects effs, const char *suffix, m6printmode mode, FILE *out) {
    if (mode == m6mode_user) {
        fprintf(out, "    data_stack%s: \t", suffix);
        m6stackeffect_print(effs.dstack, mode, out);
        fprintf(out, "\n    return_stack%s:\t", suffix);
        m6stackeffect_print(effs.rstack, mode, out);
    } else if (effs.dstack == 0 && effs.rstack == 0) {
        fputs("    WORD_STACK_NONE()", out);
    } else if (effs.dstack == (m6stackeffect)-1 && effs.rstack == (m6stackeffect)-1) {
        fputs("    WORD_STACK_ANY()", out);
    } else {
        fputs("    WORD_DSTACK(", out);
        m6stackeffect_print(effs.dstack, mode, out);
        fputs(")\n    WORD_RSTACK(", out);
        m6stackeffect_print(effs.rstack, mode, out);
        fputc(')', out);
    }
}

/* ----------------------- m6string ----------------------- */

void m6string_print(m6string str, m6printmode mode, FILE *out) {
    if (out == NULL) {
        /**/
    } else if (mode != m6mode_user) {
        fputc('"', out);
        m6string_print_escape(str, out);
        fputc('"', out);
    } else if (str.addr != NULL && str.n != 0) {
        fwrite(str.addr, 1, str.n, out);
    }
}

static m6char hexdigit(m6ucell u) {
    static const char hexdigits[] = "0123456789abcdef";
    return hexdigits[u & 0xF];
}

void m6string_print_hex(m6string str, m6printmode mode, FILE *out) {
    const m6char *data = str.addr;
    const char *separator = (mode == m6mode_user ? "$" : "0x");
    m6cell i, n = str.n;
    if (out == NULL || data == NULL) {
        return;
    }
    for (i = 0; i < n; i++) {
        if (mode == m6mode_user && data[i] == 0) {
            fputs(separator[0] == ' ' ? " 0" : separator[0] == ',' ? ", 0" : "0", out);
        } else {
            fputs(separator, out);
            fputc(hexdigit(data[i] >> 4), out);
            fputc(hexdigit(data[i] >> 0), out);
        }
        separator = (mode == m6mode_user ? " $" : ", 0x");
    }
}

/* case insensitive comparison */
m6cell m6string_ci_equals(m6string a, m6string b) {
    m6ucell i, n;
    if (a.n != b.n || (a.addr == NULL) != (b.addr == NULL)) {
        return tfalse;
    }
    if (a.addr == b.addr || a.n == 0) {
        return ttrue;
    }
    for (i = 0, n = a.n; i < n; i++) {
        m6char ai = a.addr[i];
        m6char bi = b.addr[i];
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

m6cell m6string_equals(m6string a, m6string b) {
    if (a.n != b.n || (a.addr == NULL) != (b.addr == NULL)) {
        return tfalse;
    }
    if (a.addr == b.addr || a.n == 0) {
        return ttrue;
    }
    return memcmp(a.addr, b.addr, a.n) ? tfalse : ttrue;
}

/* ----------------------- m6word ----------------------- */

m6code m6word_code(const m6word *w) {
    m6code ret = {};
    if (w != NULL) {
        ret.addr = (m6token *)w->code;
        ret.n = w->code_n;
    }
    return ret;
}

m6string m6word_data(const m6word *w, m6cell data_offset_n) {
    m6string ret = {};
    if (w->data_n != 0 && w->data_n >= data_offset_n) {
        ret.addr = m6_aligned_at(w->code + w->code_n, SZ) + data_offset_n;
        ret.n = (m6cell)w->data_n - data_offset_n;
    }
    return ret;
}

m6xt m6word_xt(const m6word *w) {
    m6xt ret = NULL;
    if (w != NULL) {
        ret = (m6token *)w->code;
    }
    return ret;
}

const m6word *m6xt_word(m6xt xt) {
    return (const m6word *)((m6cell)xt - WORD_OFF_XT);
}

static void m6word_print_flags(const m6word *w, m6printmode mode, FILE *out);

static void m6word_print_header(const m6word *w, m6printmode mode, FILE *out) {
    m6string w_ident = m6word_ident(w);
    if (mode == m6mode_user) {
        m6string_print(m6word_name(w), mode, out);
        fputs("    /* ", out);
        m6string_print(w_ident, mode, out);
        fputs(" */ {", out);
        m6word_print_flags(w, mode, out);
    } else {
        const m6word *prev = m6word_prev(w);
        fputs("WORD_START(", out);
        m6string_print(w_ident, m6mode_user, out);
        fputs(", ", out);
        m6string_print(prev ? m6word_ident(prev) : w_ident, m6mode_user, out);
        fputc(')', out);
    }
}

static void m6word_print_flags(const m6word *w, m6printmode mode, FILE *out) {
    fputs((mode == m6mode_user ? "\n    flags:\t" : "\n    WORD_FLAGS("), out);
    m6flags_print((m6flags)w->flags, mode, out);
    fputs((mode == m6mode_user ? "" : ")"), out);
}

void m6word_print_code(const m6word *w, m6printmode mode, FILE *out) {
    m6code code;
    if (w == NULL || out == NULL || w->code_n == 0) {
        return;
    }
    code = m6word_code(w);
    if (mode == m6mode_user) {
        if (w->code_n != 0) {
            fputs("\n    code:        \t", out);
            m6code_print(code, mode, out);
        }
    } else {
        fputs("\n        WORD_CODE_TOKENS(\n            ", out);
        m6code_print(code, mode, out);
        fputs("\n        )", out);
    }
}

void m6word_data_print(const m6word *w, m6cell data_offset_n, m6printmode mode, FILE *out) {
    m6string data;
    if (w == NULL || out == NULL || w->data_n == 0) {
        return;
    }
    data = m6word_data(w, data_offset_n);
    if (mode == m6mode_user) {
        fputs((w->flags & m6flag_data_tokens) ? "\n    data_tokens: \t" : "\n    data:        \t",
              out);
    } else {
        if (w->flags & m6flag_data_tokens) {
            fputs(" WORD_DATA_TOKENS(\n            ", out);
        } else {
            fputs(" WORD_DATA_BYTES(\n            ", out);
        }
    }
    if (w->flags & m6flag_data_tokens) {
        m6code code = {(m6token *)data.addr, data.n / (m6cell)SZt};
        m6code_print(code, mode, out);
    } else {
        fprintf(out, (mode == m6mode_user ? "<%lu> " : "/*%lu*/ "), (long)data.n);
        m6string_print_hex(data, mode, out);
    }
    if (mode != m6mode_user) {
        fputs("\n        )", out);
    }
}

static void m6word_codeanddata_print(const m6word *w, m6printmode mode, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    if (mode != m6mode_user) {
        fputs("\n    WORD_CODE_AND_DATA(", out);
        m6string_print(m6word_ident(w), m6mode_user, out);
        fputc(',', out);
    }
    if (w->code_n != 0) {
        m6word_print_code(w, mode, out);
    }
    if (mode != m6mode_user) {
        fputc(',', out);
    }
    if (w->data_n != 0) {
        m6word_data_print(w, 0, mode, out);
    }
    if (mode != m6mode_user) {
        fputs("\n    )", out);
    }
}

static void m6asmlen_print(const m6word *w, m6printmode mode, FILE *out) {
    if (mode == m6mode_user) {
        if (w->asm_len != (uint16_t)-1) {
            fprintf(out, "\n    asm_len:     \t%d", (int)w->asm_len);
        }
    } else if (w->asm_len == (uint16_t)-1) {
        fputs("\n    WORD_ASM_NONE()", out);
    } else if (w->asm_len == 0) {
        fputs("\n    WORD_ASM_LEN_0()", out);
    } else {
        fputs("\n    WORD_ASM_LEN(", out);
        m6string_print(m6word_ident(w), m6mode_user, out);
        fputc(')', out);
    }
}

static void m6word_footer_print(const m6word *w, m6printmode mode, FILE *out) {
    if (mode == m6mode_user) {
        fputs("\n}\n", out);
    } else {
        fputs("\nWORD_END(", out);
        m6string_print(m6word_ident(w), m6mode_user, out);
        fputs(")\n", out);
    }
}

void m6word_print_stdout(const m6word *w, m6printmode mode) {
    putchar('\n');
    m6word_print(w, mode, stdout);
}

void m6word_print(const m6word *w, m6printmode mode, FILE *out) {
    m6flags jump_flags;
    if (w == NULL || out == NULL) {
        return;
    }
    jump_flags = (m6flags)(w->flags & m6flag_jump_mask);
    m6word_print_header(w, mode, out);
    if (mode != m6mode_user || jump_flags != m6flag_jump) {
        fputc('\n', out);
        m6stackeffects_print(w->eff, "", mode, out);
    }
    if (mode != m6mode_user || jump_flags == m6flag_jump || jump_flags == m6flag_may_jump) {
        fputc('\n', out);
        m6stackeffects_print(w->jump, "_jump", mode, out);
    }
    m6asmlen_print(w, mode, out);
    if (mode != m6mode_user) {
        m6word_print_flags(w, mode, out);
    }
    m6word_codeanddata_print(w, mode, out);
    m6word_footer_print(w, mode, out);
}

static void m6word_print_fwd_recursive(const m6word *w, m6printmode mode, FILE *out) {
    if (w == NULL || out == NULL) {
        return;
    }
    m6word_print_fwd_recursive(m6word_prev(w), mode, out);
    m6word_print(w, mode, out);
}

m6string m6word_name(const m6word *w) {
    m6string ret = {};
    if (w == NULL || w->name_off == 0) {
        return ret;
    }
    const m6countedstring *name = (const m6countedstring *)((const m6char *)w - w->name_off);
    ret.addr = name->addr;
    ret.n = name->n;
    return ret;
}

m6string m6word_ident(const m6word *w) {
    m6string ret = {};
    m6string name = m6word_name(w);
    if (name.addr == NULL) {
        return ret;
    }
    /* ident is stored immediately after name */
    const m6countedstring *ident = (const m6countedstring *)(name.addr + name.n);
    ret.addr = ident->addr;
    ret.n = ident->n;
    return ret;
}

const m6word *m6word_prev(const m6word *w) {
    if (w == NULL || w->prev_off == 0) {
        return NULL;
    }
    return (const m6word *)((const m6char *)w - w->prev_off);
}

/* ----------------------- m6wordlist ----------------------- */

m6wordlist *m6wordlist_new(void) {
    typedef struct {
        m6char name_n; /**< # of characters                  */
        m6char name[15];
        m6dict dict;
        m6wordlist wid;
    } m6tuple;
    m6tuple *t;
    m6cell i;
    uint32_t crc;

    /* allocate m6countedstring + m6dict + m6wordlist in a single call */
    t = (m6tuple *)malloc(sizeof(m6tuple));
    if (t == NULL) {
        return NULL;
    }
    memset(t, 0, sizeof(m6tuple));
    crc = m64th_crc_cell((m6cell)t);
    t->name_n = 12;
    memcpy(t->name, "wid-", 4);
    for (i = 0; i < 8; i++) {
        t->name[i + 4] = hexdigit(crc);
        crc >>= 4;
    }
    t->dict.lastword_off = 0; /* no words in m6dict */
    t->dict.name_off = (m6char *)&t->dict - (m6char *)&t->name_n;
    t->wid.dict = &t->dict;
    t->wid.last = NULL;

    return &t->wid;
}

void m6wordlist_add_word(m6wordlist *wid, m6word *w) {
    const m6word *prev = m6wordlist_last_word(wid);
    w->prev_off = prev ? (size_t)w - (size_t)prev : 0;
    wid->last = w;
}

const m6word *m6wordlist_find(const m6wordlist *wid, m6string str) {
    const m6word *w = m6wordlist_last_word(wid);
    while (w != NULL) {
        if (m6string_ci_equals(str, m6word_name(w))) {
            break;
        }
        w = m6word_prev(w);
    }
    return w;
}

const m6word *m6wordlist_last_word(const m6wordlist *wid) {
    if (wid == NULL) {
        return NULL;
    } else if (wid->last) {
        return wid->last;
    }
    return m6dict_lastword(wid->dict);
}

m6string m6wordlist_name(const m6wordlist *wid) {
    if (wid == NULL) {
        m6string ret = {};
        return ret;
    }
    return m6dict_name(wid->dict);
}

void m6wordlist_print(const m6wordlist *wid, m6printmode mode, FILE *out) {
    if (out == NULL || wid == NULL) {
        return;
    }
    m6dict_print(wid->dict, wid->last, mode, out);
}

/* ----------------------- m64th ----------------------- */

void m64th_init(void) {
    static m6cell initialized = 0;
    if (!initialized) {
        m64th_cpu_features_autoenable();
        m64th_crcinit(m64th_crctable);
        initialized = ttrue;
    }
}

m64th *m64th_new(m64th_opt options) {
    extern void m6f_vm_(m6arg _);
    m64th *m;

    m64th_init();

    m = (m64th *)m6mem_allocate(sizeof(m64th));
    m->dstack = m6stack_alloc(dstack_n);
    if (options & m6opt_return_stack_is_private) {
        m->rstack = m6stack_alloc(rstack_n);
    } else {
        memset(&m->rstack, '\0', sizeof(m->rstack));
    }
    m->lstack = NULL;
    m->ip = NULL;
    m->ftable = ftable;
    m->wtable = wtable;
    m->in = m6iobuf_new(inbuf_n);
    m->out = m6iobuf_new(outbuf_n);
    m->vm = m6f_vm_;
    memset(m->c_regs, '\0', sizeof(m->c_regs));
    m->user_size = ((m6cell)&m->user_var[0] - (m6cell)&m->user_size) / SZ;
    m->user_next = m->user_size;
    m->pict_start = M64TH_PICT_MAXSIZE;
    memset(m->unused0, 0, sizeof(m->unused0));
    m->lastw = NULL;
    m->xt = NULL;
    m->locals = NULL;
    m->mem = m6cbuf_alloc(dataspace_n);
    /* m->asm_ is allocated on demand */
    memset(&m->asm_, 0, sizeof(m->asm_));
    m->asm_here = m->asm_.curr;
    m->base = 10;
    m->handler = m->ex = 0;
    m->ex_message.addr = NULL;
    m->ex_message.n = 0;
    /* by forth 2012 specs, initial compilation wordlist must be 'forth' */
    /* see https://forth-standard.org/standard/search/FORTH-WORDLIST */
    m->compile_wid = &m6wordlist_forth;
    memset(&m->searchorder, '\0', sizeof(m->searchorder));
    /* put 'm64th-user' wordlist at lower priority:                        */
    /* compilation wordlist is initially 'forth' and newly-defined words  */
    /* should shadow existing ones in either wordlist                     */
    m64th_also(m, &m6wordlist_m64th_user);
    m64th_also(m, &m6wordlist_forth);
    /* redundancy: help users against removing 'forth' wordlist accidentally */
    m64th_also(m, &m6wordlist_forth);

    return m;
}

void m64th_del(m64th *m) {
    if (m) {
        m6cbuf_unmap(&m->asm_);
        m6cbuf_free(&m->mem);
        m6iobuf_del(m->out);
        m6iobuf_del(m->in);
        m6stack_free(&m->rstack);
        m6stack_free(&m->dstack);
        m6mem_free(m->locals);
        m6mem_free(m);
    }
}

/* does NOT modify m->state and user variables as m->base, m->searchorder... */
void m64th_clear(m64th *m) {
    extern void m6f_vm_(m6arg _);

    m->dstack.curr = m->dstack.end;
    m->rstack.curr = m->rstack.end;
    m->lstack = NULL;
    m->vm = m6f_vm_;
    memset(m->c_regs, '\0', sizeof(m->c_regs));
    m->in->err = m->in->pos = m->in->end = 0;
    m->out->err = m->out->pos = m->out->end = 0;
    m->ip = NULL;
    m->lastw = NULL;
    m->xt = NULL;
    if (m->locals) {
        m->locals->end = m->locals->n = 0;
    }
    m->mem.curr = m->mem.start;
    m->asm_here = m->asm_.curr = m->asm_.start;
    m->handler = m->ex = 0;
    m->ex_message.addr = NULL;
    m->ex_message.n = 0;
}

const m6cell *m64th_state(const m64th *m) {
    return (const m6cell *)&m->xt;
}

void m64th_also(m64th *m, m6wordlist *wid) {
    m6searchorder *s = &m->searchorder;
    if (wid != NULL && s->n < m6searchorder_max) {
        s->addr[s->n++] = wid;
    }
}

/* get local variable at specified byte offset */
const m6local *m6locals_at(const m6locals *ls, m6ucell byte_offset) {
    return (const m6local *)(((const m6char *)ls->vec) + byte_offset);
}

/* get first local variable */
static const m6local *m6locals_first(const m6locals *ls) {
    return ls && ls->n && ls->end ? ls->vec : NULL;
}

/* get next local variable */
static const m6local *m6locals_next(const m6locals *ls, const m6local *l) {
    l = (const m6local *)(l->str.addr + l->str.n);
    return (const m6char *)l < (const m6char *)ls->vec + ls->end ? l : NULL;
}

/* initialize local variable */
static void m6local_init(m6local *l, m6string localname) {
    const m6char len = (m6char)localname.n;
    l->idx = 0;
    l->str.n = len;
    memcpy(l->str.addr, localname.addr, len);
}

/* set all indexes of local variables. return ttrue */
static m6cell m6locals_set_indexes(m6locals *ls) {
    m6local *l = (m6local *)m6locals_first(ls);
    if (l) {
        m6ucell i;
        for (i = ls->n - 1; l; i--) {
            l->idx = i;
            l = (m6local *)m6locals_next(ls, l);
        }
    }
    return ttrue;
}

/* try to add a new local variable to m->locals. return ttrue if successful. */
/* empty localname means 'end of local variables' */
m6cell m64th_local(m64th *m, m6string localname) {
    m6locals *ls = m->locals;
    m6local *l;
    m6ucell len = localname.n;
    if (len == 0) {
        /* end-of-locals marker: set all indexes */
        return m6locals_set_indexes(ls);
    }
    if (!ls) {
        /* allow at least 16 local variables, each with a name 255 bytes long */
        const m6ucell capacity = 16 * (sizeof(m6local) + 255);
        m->locals = ls = m6mem_allocate(sizeof(m6locals) + capacity);
        ls->end = ls->n = 0;
        ls->capacity = capacity;
    }
    if (ls->n == (m6char)-1 || len != (m6char)len ||
        len + sizeof(m6local) > ls->capacity - ls->end) {
        /* too many local variables, or localname is too long */
        return tfalse;
    }
    l = (m6local *)m6locals_at(ls, ls->end);
    m6local_init(l, localname);
    ls->n++;
    ls->end = l->str.addr + len - (m6char *)ls->vec;
    return ttrue;
}

/* return index of local variable if found, else -1 */
/* use case-insensitive string comparison m6string_ci_equals() */
m6cell m6locals_find(const m6locals *ls, m6string localname) {
    const m6local *l = m6locals_first(ls);
    while (l) {
        const m6string str = m6string_count(&l->str);
        if (m6string_ci_equals(localname, str)) {
            return l->idx;
        }
        l = m6locals_next(ls, l);
    }
    return -1;
}

/**
 * C implementation of asm-reserve.
 * reserves space for at least 'len' bytes in ASM buffer
 * and protects it as READ+WRITE+EXEC
 */
void m64th_asm_reserve(m64th *m, m6ucell len) {
    if (len <= (m6ucell)(m->asm_.end - m->asm_.curr)) {
        m6cbuf_protect(&m->asm_, m6protect_read_write_exec);
        return;
    }
    if (m->asm_.curr == m->asm_.start) {
        /* old buffer is empty, unmap it */
        m6cbuf_unmap(&m->asm_);
    } else {
        /* old buffer is still in use, cannot be unmapped */
    }
    m->asm_ = m6cbuf_map(len >= asm_n ? len : asm_n, m6protect_read_write_exec);
    m->asm_here = m->asm_.curr;
}

/* clear CPU instruction cache in the range beg..end */
static void m6mem_clear_icache(void *beg, void *end) {
#if defined(__GNUC__) /* also catches __clang__ */
    __builtin___clear_cache(beg, end);
#elif defined(__ANDROID__)
    cacheflush((uintptr_t)beg, (uintptr_t)end, 0);
#elif defined(_WIN32)
    FlushInstructionCache(GetCurrentProcess(), beg, (size_t)(end - beg));
#else
#warning unsupported system, please fix m6mem_clear_icache()
#endif
}

/**
 * C implementation of asm-make-func:
 * 1. protect the ASM buffer as READ+EXEC
 * 2. set m64th.asm_.curr = m6mem_funcalign_up(m->asm_here).
 * 3. return original value of m64th.asm_.curr
 */
m6string m64th_asm_make_func(m64th *m) {
    m6char *beg = m->asm_.start;
    m6char *func_beg = m->asm_.curr;
    m6char *func_end = m->asm_here;
    m6char *end = m->asm_.end;
    if (func_end <= func_beg || func_end > end) {
        return m6string_make(NULL, 0);
    }
    m6mem_protect(beg, (size_t)(end - beg), m6protect_read_exec);
    m6mem_clear_icache(func_beg, func_end);
    m->asm_here = m->asm_.curr = m6mem_funcalign_up(func_end);
    return m6string_make(func_beg, (m6ucell)(func_end - func_beg));
}

/* C implementation of ':' i.e. start compiling a new word */
void m64th_colon(m64th *m, m6string name) {
    m6char *here = m->mem.curr;
    m6word *w;
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
    here = m6_aligned_at(here, SZ);
    w = (m6word *)here;
    memset(w, '\0', sizeof(m6word));
    w->name_off = name.n ? here - m->mem.start : 0;
    m->lastw = w;
    m->mem.curr = (m6char *)(m->xt = m6word_xt(w));
    /*
     * reproduce behaviour of forth word ':'
     * also push to dstack colon-sys i.e. 0 m6colon
     *
     * Note: most tests overwrite dstack at initialization,
     * discarding these values.
     */
    dpush(m, 0);
    dpush(m, m6colon);
}

/* C implementation of ';' i.e. finish compiling a new word */
void m64th_semi(m64th *m) {
    m6token *here = (m6token *)m6_aligned_at(m->mem.curr, SZt);
    if (m->lastw == NULL) {
        return;
    }
    *here++ = m6exit;
    m->lastw->code_n = here - m->xt;
    m->xt = NULL;
    m->mem.curr = (m6char *)here;
}

/* compute m->lastw->data_n (if not compiling) or m->lastw->code_n (if compiling) from HERE */
void m64th_sync_lastw(m64th *m) {
    m6word *w = m->lastw;
    if (w == NULL) {
        ;
    } else if (m->xt) {
        /* compiling */
        m6char *here = m->mem.curr = m6_aligned_at(m->mem.curr, SZt);
        w->code_n = (m6token *)here - w->code;
    } else {
        /* not compiling */
        w->data_n = m->mem.curr - m6_aligned_at(w->code + w->code_n, SZ);
    }
}

m6cell m64th_knows(const m64th *m, const m6wordlist *wid) {
    const m6searchorder *s = &m->searchorder;
    m6ucell i, n = s->n;
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

m6cell m64th_execute_word(m64th *m, const m6word *w) {
    m6token code[2 + SZ / SZt];
    const m6token *save_ip = m->ip;
    m6cell ret;
    {
        m6cell cell = (m6cell)w->code;
        code[0] = m6_call_;
        memcpy(code + 1, &cell, SZ);
        code[1 + SZ / SZt] = m6bye;
    }
    m->ip = code;
    ret = m64th_run(m);
    m->ip = save_ip;
    return ret;
}

/** wrapper around REPL */
m6cell m64th_repl(m64th *m) {
    return m64th_execute_word(m, &m6w_repl);
}

/* ----------------------- optional cpu features ----------------------- */
extern void m6fcrc_cell(m6arg _);
extern void m6fcrc_cell_simd(m6arg _);
extern void m6fcrc_string(m6arg _);
extern void m6fcrc_string_simd(m6arg _);

m6cell m64th_cpu_features_enabled(void) {
    m6cell mask = 0;
    if (ftable[m6crc_cell] == m6fcrc_cell_simd || ftable[m6crc_string] == m6fcrc_string_simd) {
        mask |= m64th_cpu_feature_crc32c;
    }
    return mask;
}

void m64th_cpu_features_enable(m6cell mask) {
    if (mask & m64th_cpu_feature_crc32c) {
        ftable[m6crc_cell] = m6fcrc_cell_simd;
        ftable[m6crc_string] = m6fcrc_string_simd;
    }
}

void m64th_cpu_features_disable(m6cell mask) {
    if (mask & m64th_cpu_feature_crc32c) {
        ftable[m6crc_cell] = m6fcrc_cell;
        ftable[m6crc_string] = m6fcrc_string;
    }
}
