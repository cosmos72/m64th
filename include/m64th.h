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

#ifndef M64TH_M64TH_H
#define M64TH_M64TH_H

#include "flag.mh"
#include "token.h" /* FIXME not a public header */

#include <stddef.h>    /* size_t    */
#include <stdint.h>    /* [u]int*_t */
#include <stdio.h>     /* FILE      */
#include <sys/types.h> /* ssize_t   */

typedef struct m6arg_s m6arg; /**< intentionally incomplete type, cannot be instantiated */

typedef int8_t m6byte;
typedef uint8_t m6ubyte;
typedef uint8_t m6char;
typedef int16_t m6short;
typedef uint16_t m6ushort;
typedef int32_t m6int;
typedef uint32_t m6uint;
typedef ssize_t m6cell; /**< main forth type: number or pointer */
typedef size_t m6ucell; /**< unsigned variant of m6cell         */
typedef m6cell m6err;   /**< error code, set by ABORT or THROW  */
/** forth instruction. uses forth calling convention, cannot be invoked from C */
typedef void (*m6func)(m6arg);
typedef uint8_t m6stackeffect; /**< stack # in and # out. 0xF if unknown or variable   */
typedef const m6token *m6xt;   /**< XT i.e. execution token            */

typedef char
    m64th_assert_sizeof_voidptr_less_equal_sizeof_m6cell[sizeof(void *) <= sizeof(m6cell) ? 1 : -1];

typedef char
    m64th_assert_sizeof_m6func_less_equal_sizeof_m6cell[sizeof(m6func) <= sizeof(m6cell) ? 1 : -1];

typedef char
    m64th_assert_sizeof_m6token_divides_sizeof_m6cell[(sizeof(m6cell) % sizeof(m6token) == 0) ? 1
                                                                                              : -1];

/** m6word flags */
typedef enum m6flags_e {
    m6flag_asm = M6FLAG_ASM,
    m6flag_compile_only = M6FLAG_COMPILE_ONLY,
    m6flag_consumes_ip_mask = M6FLAG_CONSUMES_IP_MASK,
    m6flag_consumes_ip_2 = M6FLAG_CONSUMES_IP_2,
    m6flag_consumes_ip_4 = M6FLAG_CONSUMES_IP_4,
    m6flag_consumes_ip_8 = M6FLAG_CONSUMES_IP_8,
    m6flag_consumes_ip_10 = M6FLAG_CONSUMES_IP_10,
    m6flag_data_tokens = M6FLAG_DATA_TOKENS,
    m6flag_immediate = M6FLAG_IMMEDIATE,
    m6flag_inline = M6FLAG_INLINE,
    m6flag_inline_always = M6FLAG_INLINE_ALWAYS,
    m6flag_jump_mask = M6FLAG_JUMP_MASK,
    m6flag_jump = M6FLAG_JUMP,
    m6flag_may_jump = M6FLAG_MAY_JUMP,
    m6flag_mem_fetch = M6FLAG_MEM_FETCH,
    m6flag_mem_store = M6FLAG_MEM_STORE,
    m6flag_noasm = M6FLAG_NOASM,
    m6flag_noname = M6FLAG_NONAME, /* does not fit m6word.flags, only used in ( colon-sys ) */
    m6flag_opt_mask = M6FLAG_OPT_MASK,
    m6flag_create = M6FLAG_CREATE,
    m6flag_defer = M6FLAG_DEFER,
    m6flag_noopt = M6FLAG_NOOPT,
    m6flag_pure_mask = M6FLAG_PURE_MASK,
    m6flag_pure = M6FLAG_PURE,
    m6flag_reexec_after_optimize = M6FLAG_REEXEC_AFTER_OPTIMIZE,
    m6flag_value = M6FLAG_VALUE,
} m6flags;

/** m64th state */
typedef enum m6_state_e {
    m6state_interpret = M6STATE_INTERPRET,
} m6_state;

typedef struct m6buf_s m6buf;
typedef struct m6cbuf_s m6cbuf;
typedef struct m6code_s m6code;
typedef struct m6counteddata_s m6counteddata;
typedef struct m6countedstring_s m6countedstring;
typedef struct m6dict_s m6dict;
typedef struct m6iobuf_s m6iobuf;
typedef struct m6local_s m6local;
typedef struct m6locals_s m6locals;
typedef struct m6slice_s m6slice;
typedef struct m6buf_s m6stack;
typedef struct m6pair_s m6pair;
typedef struct m6searchorder_s m6searchorder;
typedef struct m6stackeffects_s m6stackeffects;
typedef struct m6string_s m6string;
typedef struct m64th_s m64th;
typedef struct m6word_s m6word;
typedef struct m6wordlist_s m6wordlist;

/** array of m6cell, with current size and capacity */
struct m6buf_s {
    m6cell *start;
    m6cell *curr;
    m6cell *end;
};

/** array of m6char, with current size and capacity */
struct m6cbuf_s {
    m6char *start;
    m6char *curr;
    m6char *end;
};

struct m6code_s { /**< array of m6token, with size */
    m6token *addr;
    m6ucell n;
};

struct m6counteddata_s { /**< counted data                     */
    uint32_t n;          /**< # of bytes                       */
    m6char addr[];       /**< bytes                            */
};

struct m6countedstring_s { /**< counted string                     */
    m6char n;              /**< # of characters                    */
    m6char addr[0];        /**< n characters. do NOT end with '\0' */
};

struct m6dict_s {         /**< dictionary. used to implement wordlist                */
    int32_t lastword_off; /**< offset of last m6word*,     in bytes. 0 = not present */
    int32_t name_off;     /**< offset of m6countedstring*, in bytes. 0 = not present */
};

#if 0 /* unused */
typedef struct m6err_s m6err;
struct m6err_s {
    m6cell id; /**< error code */
    struct {
        m6countedstring impl;
        m6char buf[31];
    } msg; /**< error message */
};
#endif

/** I/O buffer */
struct m6iobuf_s {
    m6xt func;     /**< ( handle c-addr u -- u' ior ) reads or writes data */
    m6cell handle; /**< FILE*, fd or whatever is needed by func        */
    m6cell err;    /**< last I/O error                                 */
    m6ucell pos;   /**< next char to read (or write) is addr[pos]      */
    m6ucell end;   /**< last char to read (or write) is addr[end-1]    */
    m6ucell max;   /**< capacity. I/O buffer is addr[0..max-1]         */
    m6char *addr;
};

/** local variable */
struct m6local_s {
    m6char idx;
    m6countedstring str;
};

/** list of local variables */
struct m6locals_s {
    m6ucell n, end, capacity;
    m6local vec[];
};

struct m6pair_s {
    union {
        m6cell num;
        const m6word *w;
    };
    m6cell err;
};

struct m6string_s { /**< array of m6char, with size */
    const m6char *addr;
    m6ucell n;
};

struct m6stackeffects_s {
    m6stackeffect dstack; /**< dstack # in and # out. 0xFF if unknown or variable   */
    m6stackeffect rstack; /**< rstack # in and # out. 0xFF if unknown or variable   */
};

struct m6slice_s { /**< array of m6cell, with size */
    m6cell *addr;
    m6ucell n;
};

/** compiled forth word. Execution token i.e. XT is at word + code_off */
struct m6word_s {
    int64_t prev_off;    /**< offset of previous word,   in bytes. 0 = not present */
    uint16_t name_off;   /**< offset of m6countedstring, in bytes. 0 = not present */
    m6stackeffects eff;  /**< stack effects if not jumping                         */
    m6stackeffects jump; /**< stack effects if jumping                             */
    uint16_t asm_len;    /**< native code size, in bytes. 0xFFFF if not available  */
    uint16_t flags;      /**< m6flags                                              */
    uint16_t code_n;     /**< forth code size, in m6token:s                        */
    int32_t data_n;      /**< data size, in bytes                                  */
    m6token code[0];     /**< code. actually code_n elements                       */
};

#include "hashmap_string.h" /* needs m6cell, m6ucell, m6string */

struct m6wordlist_s {     /**< wordlist                                                 */
    const m6dict *dict;   /**< pointer to read-only dictionary                          */
    m6word *last;         /**< pointer to last word. if NULL, use m6dict_lastword(dict) */
    m6hashmap_string map; /**< hash table of contained words. TODO: fill it             */
};

enum { m6searchorder_max = M64TH_SEARCHORDER_MAX };

struct m6searchorder_s {                 /**< counted array of wordlists */
    m6cell n;                            /**< # of wordlists             */
    m6wordlist *addr[m6searchorder_max]; /* array of wordlists           */
};

struct m64th_s {               /**< m64th forth interpreter and compiler          */
    m6stack dstack;            /**< data stack                                   */
    m6stack rstack;            /**< return stack                                 */
    m6cell *lstack;            /**< pointer to forth local variables (in return stack) */
    const m6token *ip;         /**< instruction pointer                          */
    m6func *ftable;            /**< table m6token -> m6func asm function address */
    const m6word **wtable;     /**< table m6token -> m6word*                     */
    m6iobuf *in;               /**< input  buffer                                */
    m6iobuf *out;              /**< output buffer                                */
    m6word *lastw;             /**< last defined forth word                      */
    m6xt xt;                   /**< XT being compiled. also used for STATE       */
                               /*                                                */
    const void *vm;            /**< pointer to '(vm)' bytecode interpreter       */
    const void *c_regs[1];     /**< m64th_run() may save C registers here         */
                               /*                                                */
                               /* USER variables, i.e. thread-local              */
    uint16_t user_size;        /**< # available cells in user variables          */
    uint16_t user_next;        /**< next available cell in user variables        */
    uint8_t pict_start;        /**< offset from HERE to beginning of pictured output buffer */
    uint8_t unused0[3];        /**<                                              */
    m6locals *locals;          /**< local variables of XT being compiled         */
    m6cell base;               /**< current BASE                                 */
    m6cbuf mem;                /**< start, HERE and end of data space            */
    m6cbuf asm_;               /**< start, curr and end of assembly space        */
    m6char *asm_here;          /**< end of current ASM function = ASM-HERE       */
    m6cell handler;            /**< exception handler installed by CATCH         */
    m6cell ex;                 /**< exception set by THROW                       */
    m6string ex_message;       /**< exception message, set manually before THROW */
    m6wordlist *compile_wid;   /**< compilation wordlist                         */
    m6searchorder searchorder; /**< wordlist search order                        */
    m6cell user_var[];         /**< further user variables                       */
};

/** m64th_new() options */
typedef enum m64th_opt_e {
    /* default: forth return stack is shared with C stack  */
    m6opt_return_stack_is_c_stack = 0,
    /* forth return stack is private, allocated memory:
     * useful for testing tokens with side effects on return stack. */
    m6opt_return_stack_is_private = 1,
} m64th_opt;

/* m6*_print* options */
typedef enum m6printmode_e {
    /* default: print user-readable disassembly */
    m6mode_user = 0,
    /* print machine-readable disassembly, usable as input to C compiler (actually assembler) */
    m6mode_c_disasm = 1,
    m6mode_default = m6mode_user,
} m6printmode;

#ifdef __cplusplus
extern "C" {
#endif

/** initialize internal structures. called automatically by m64th_new() */
void m64th_init(void);

/** create a new m64th struct */
m64th *m64th_new(m64th_opt options);

/** delete an m64th struct */
void m64th_del(m64th *m);

/** start forth REPL */
m6cell m64th_repl(m64th *m);

/** execute the specified m6word, then return. preserves m64th->ip */
m6cell m64th_execute_word(m64th *m, const m6word *w);

/**
 * low-level entry point from C. implemented in assembly.
 * execute m64th->ip and subsequent code until m64th_bye is found.
 */
m6cell m64th_run(m64th *m);

/**
 * clear data stack, return stack, input buffer and output buffer.
 * set ->ip to ->code.start
 */
void m64th_clear(m64th *m);

/** return address of state. state is zero when interpreting, nonzero when compiling */
const m6cell *m64th_state(const m64th *m);

/* add wid to the top of search order */
void m64th_also(m64th *m, m6wordlist *wid);

/* start compiling a new word */
void m64th_colon(m64th *m, m6string name);

/* finish compiling a new word */
void m64th_semi(m64th *m);

/* compute m->lastw->data_n (if not compiling) or m->lastw->code_n (if compiling) from HERE */
void m64th_sync_lastw(m64th *m);

/* return <> 0 if search order contains wid */
m6cell m64th_knows(const m64th *m, const m6wordlist *wid);

/**
 * perform self-test, return != 0 if failed.
 * if out != NULL, also print failed tests to out.
 */
m6cell m64th_test(m64th *m, FILE *out);

/**
 * C implementation of asm-reserve.
 * reserves space for at least 'len' bytes in ASM buffer
 * and protects it as READ+WRITE+EXEC
 */
void m64th_asm_reserve(m64th *m, m6ucell len);

/**
 * C implementation of asm-make-func:
 * 1. protect the ASM buffer as READ+EXEC
 * 2. set m64th.asm_.curr = m6mem_funcalign_up(m->asm_here).
 * 3. return original value of m64th.asm_.curr
 */
m6string m64th_asm_make_func(m64th *m);

void *m6mem_allocate(size_t bytes);          /** malloc() wrapper, calls exit(1) on failure */
void m6mem_free(void *ptr);                  /** free() wrapper */
void *m6mem_resize(void *ptr, size_t bytes); /** realloc() wrapper, calls exit(1) on failure */

enum m6protect_e {
    m6protect_none = 0,
    m6protect_read = 1,
    m6protect_write = 2,
    m6protect_exec = 4,
    m6protect_read_exec = m6protect_read | m6protect_exec,
    m6protect_read_write = m6protect_read | m6protect_write,
    m6protect_read_write_exec = m6protect_read_write | m6protect_exec,
};
typedef enum m6protect_e m6protect;

void *m6mem_map(size_t bytes, m6protect prot); /** mmap() wrapper, calls exit(1) on failure */
void m6mem_unmap(void *ptr, size_t bytes);     /** munmap() wrapper */
void m6mem_protect(void *ptr, size_t bytes, m6protect prot); /* mprotect() wrapper */

m6cell m6code_equal(m6code src, m6code dst);
void m6code_print(m6code src, m6printmode mode, FILE *out);
const m6word *m6xt_word(m6xt xt);

const m6word *m6dict_lastword(const m6dict *dict);
m6string m6dict_name(const m6dict *dict);
void m6dict_print(const m6dict *dict, const m6word *override_lastw, m6printmode mode, FILE *out);

/** return how many bytes of code are consumed by token or word marked with given flags */
m6cell m6flags_consume_ip(m6flags fl);
void m6flags_print(m6flags fl, m6printmode mode, FILE *out);

/* try to add a new local variable to m->locals. return ttrue if successful. */
/* empty localname means 'end of local variables' */
m6cell m64th_local(m64th *m, m6string localname);
/* return index of local variable if found, else -1 */
/* use case-insensitive string comparison m6string_ci_equals() */
m6cell m6locals_find(const m6locals *ls, m6string localname);
/* get local variable at specified byte offset */
const m6local *m6locals_at(const m6locals *ls, m6ucell byte_offset);

void m6slice_copy_to_code(m6slice src, m6code *dst);
/*
 * print "<" src.n "> " followed by numeric value of cells
 * (decimal if small, otherwise hexadecimal).
 * if direction < 0, print cells at higher addresses first
 */
void m6slice_print(m6slice cells, m6cell direction, m6printmode mode, FILE *out);
void m6slice_print_stdout(m6slice cells, m6cell direction, m6printmode mode);
void m6slice_to_word_code(const m6slice *src, m6word *dst);

m6string m6string_make(const void *addr, const m6ucell n);
/* convert m6countedstring to m6string */
m6string m6string_count(const m6countedstring *cstr);
m6cell m6string_equals(m6string a, m6string b);
m6cell m6string_ci_equals(m6string a, m6string b); /* case insensitive comparison */
void m6string_print(m6string str, m6printmode mode, FILE *out);
void m6string_print_hex(m6string str, m6printmode mode, FILE *out);
/** print, replacing non-printable chars with escape sequences */
void m6string_print_escape(m6string str, FILE *out);

m6stack m6stack_alloc(m6ucell size);
void m6stack_free(m6stack *arg);
void m6stack_print(const m6stack *stack, m6printmode mode, FILE *out);

/** return how many bytes of code are consumed by executing token */
m6cell m6token_consumes_ip(m6token tok);
void m6token_print(m6token val, m6printmode mode, FILE *out);
/** try to find the m6word that describes given token */
const m6word *m6token_to_word(m6token tok);

m6code m6word_code(const m6word *w);
m6string m6word_data(const m6word *w, m6cell code_start_n);
m6string m6word_name(const m6word *w);
m6string m6word_ident(const m6word *w);
const m6word *m6word_prev(const m6word *w);
m6xt m6word_xt(const m6word *w);
void m6word_print(const m6word *w, m6printmode mode, FILE *out);
void m6word_print_stdout(const m6word *w, m6printmode mode);
void m6word_print_code(const m6word *w, m6printmode mode, FILE *out);
void m6word_data_print(const m6word *w, m6cell data_offset_n, m6printmode mode, FILE *out);

m6wordlist *m6wordlist_new(void);
void m6wordlist_add_word(m6wordlist *wid, m6word *w);
const m6word *m6wordlist_find(const m6wordlist *wid, m6string str);
const m6word *m6wordlist_last_word(const m6wordlist *wid);
m6string m6wordlist_name(const m6wordlist *wid);
void m6wordlist_print(const m6wordlist *wid, m6printmode mode, FILE *out);

#ifdef __cplusplus
}
#endif

#endif /* M64TH_M64TH_H */
