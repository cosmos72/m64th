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

#ifndef M4TH_M4TH_H
#define M4TH_M4TH_H

#include "include/token.h" /* FIXME not a public header */
#include "m4th.mh"

#include <stddef.h>    /* size_t    */
#include <stdint.h>    /* [u]int*_t */
#include <stdio.h>     /* FILE      */
#include <sys/types.h> /* ssize_t   */

typedef struct m4arg_s m4arg; /**< intentionally incomplete type, cannot be instantiated */

typedef unsigned char m4char;
typedef ssize_t m4cell;  /**< main forth type: number or pointer */
typedef size_t m4cell_u; /**< unsigned variant of m4cell         */
typedef m4cell m4err;    /**< error code, set by ABORT or THROW  */

/** forth instruction. uses forth calling convention, cannot be invoked from C */
typedef void (*m4func)(m4arg);

typedef uint8_t m4stackeffect; /**< stack # in and # out. 0xF if unknown or variable   */

typedef char
    m4th_assert_sizeof_voidptr_less_equal_sizeof_m4cell[sizeof(void *) <= sizeof(m4cell) ? 1 : -1];

typedef char
    m4th_assert_sizeof_m4func_less_equal_sizeof_m4cell[sizeof(m4func) <= sizeof(m4cell) ? 1 : -1];

typedef char
    m4th_assert_sizeof_m4token_divides_sizeof_m4cell[(sizeof(m4cell) % sizeof(m4token) == 0) ? 1
                                                                                             : -1];

/** m4word flags */
typedef enum m4flags_e {
    m4flag_mem_fetch = M4FLAG_MEM_FETCH,
    m4flag_mem_store = M4FLAG_MEM_STORE,
    m4flag_compile_only = M4FLAG_COMPILE_ONLY,
    m4flag_immediate = M4FLAG_IMMEDIATE,
    m4flag_inline = M4FLAG_INLINE,
    m4flag_inline_always = M4FLAG_INLINE_ALWAYS,
    m4flag_jump_mask = M4FLAG_JUMP_MASK,
    m4flag_jump = M4FLAG_JUMP,
    m4flag_may_jump = M4FLAG_MAY_JUMP,
    m4flag_pure_mask = M4FLAG_PURE_MASK,
    m4flag_pure = M4FLAG_PURE,
    m4flag_consumes_ip_mask = M4FLAG_CONSUMES_IP_MASK,
    m4flag_consumes_ip_2 = M4FLAG_CONSUMES_IP_2,
    m4flag_consumes_ip_4 = M4FLAG_CONSUMES_IP_4,
    m4flag_consumes_ip_8 = M4FLAG_CONSUMES_IP_8,
    m4flag_data_tokens = M4FLAG_DATA_TOKENS,
} m4flags;

/** m4th state */
typedef enum m4th_state_e {
    m4th_state_interpret = M4TH_STATE_INTERPRET,
    m4th_state_compile = M4TH_STATE_COMPILE,
} m4th_state;

typedef struct m4buf_s m4buf;
typedef struct m4cbuf_s m4cbuf;
typedef struct m4code_s m4code;
typedef struct m4counteddata_s m4counteddata;
typedef struct m4countedstring_s m4countedstring;
typedef struct m4dict_s m4dict;
typedef struct m4iobuf_s m4iobuf;
typedef struct m4slice_s m4slice;
typedef struct m4buf_s m4stack;
typedef struct m4searchorder_s m4searchorder;
typedef struct m4stackeffects_s m4stackeffects;
typedef struct m4string_s m4string;
typedef struct m4th_s m4th;
typedef struct m4word_s m4word;
typedef struct m4wordlist_s m4wordlist;

/** array of m4cell, with current size and capacity */
struct m4buf_s {
    m4cell *start;
    m4cell *curr;
    m4cell *end;
};

/** array of m4char, with current size and capacity */
struct m4cbuf_s {
    m4char *start;
    m4char *curr;
    m4char *end;
};

struct m4code_s { /**< array of m4token, with size */
    m4token *addr;
    m4cell_u n;
};

struct m4counteddata_s { /**< counted data                     */
    uint32_t n;          /**< # of bytes                       */
    m4char addr[0];      /**< bytes                            */
};

struct m4countedstring_s { /**< counted string                   */
    m4char n;              /**< # of characters                  */
    m4char addr[0];        /**< characters. do NOT end with '\0' */
};

struct m4dict_s {         /**< dictionary. used to implement wordlist                */
    int32_t lastword_off; /**< offset of last m4word*,     in bytes. 0 = not present */
    int16_t name_off;     /**< offset of m4countedstring*, in bytes. 0 = not present */
};

#if 0 /* unused */
typedef struct m4err_s m4err;
struct m4err_s {
    m4cell id; /**< error code */
    struct {
        m4countedstring impl;
        m4char buf[31];
    } msg; /**< error message */
};
#endif

/** I/O buffer */
struct m4iobuf_s {
    m4char *addr;
    m4cell_u size;
    m4cell_u curr; /**< current char is addr[curr] */
};

struct m4string_s { /**< array of m4char, with size */
    const m4char *addr;
    m4cell_u n;
};

struct m4stackeffects_s {
    m4stackeffect dstack; /**< dstack # in and # out. 0xFF if unknown or variable   */
    m4stackeffect rstack; /**< rstack # in and # out. 0xFF if unknown or variable   */
};

struct m4slice_s { /**< array of m4cell, with size */
    m4cell *addr;
    m4cell_u n;
};

/** compiled forth word. Execution token i.e. XT is at word + code_off */
struct m4word_s {
    int32_t prev_off;    /**< offset of previous word,   in bytes. 0 = not present */
    int16_t name_off;    /**< offset of m4countedstring, in bytes. 0 = not present */
    uint16_t flags;      /**< m4flags                                              */
    m4stackeffects eff;  /**< stack effects if not jumping                         */
    m4stackeffects jump; /**< stack effects if jumping                             */
    uint16_t native_len; /**< native code size, in bytes. 0xFFFF if not available  */
    uint16_t code_n;     /**< forth code size, in m4token:s                        */
    uint32_t code_off;   /**< offset of code, in bytes. 0 = not present            */
    uint32_t data_n;     /**< data size, in bytes                                  */
    m4char data[0];
};

struct m4wordlist_s {   /**< wordlist                                             */
    const m4dict *dict; /**< pointer to implementation dictionary                 */
    /* TODO hash table of contained words */
};

enum { m4searchorder_max = M4TH_SEARCHORDER_MAX };

struct m4searchorder_s {                 /**< counted array of wordlists */
    m4cell n;                            /**< # of wordlists             */
    m4wordlist *addr[m4searchorder_max]; /* array of wordlists           */
};

struct m4th_s {        /**< m4th forth interpreter and compiler */
    m4stack dstack;    /**< data stack                          */
    m4stack rstack;    /**< return stack                        */
    const m4token *ip; /**< instruction pointer                 */
    m4func *ftable;    /**< table m4t -> asm function address   */
    m4iobuf in;        /**< input  buffer                       */
    m4iobuf out;       /**< output buffer                       */

    m4cell state;          /**< m4th_state: interpret = 0, compile <> 0 */
    const void *c_regs[1]; /**< m4th_run() may save C registers here  */

    /* USER variables, i.e. thread-local */
    m4word *w;                 /**< forth word being compiled          */
    m4cbuf mem;                /**< start, HERE and end of data space  */
    m4cell base;               /**< current BASE                       */
    m4searchorder searchorder; /**< wordlist search order              */
    m4func quit;               /**< forth function to execute on quit. usually m4fbye or m4fquit */
    m4err err;                 /**< error set by ABORT                 */
};

#ifdef __cplusplus
extern "C" {
#endif

/** create a new m4th struct */
m4th *m4th_new();

/** delete an m4th struct */
void m4th_del(m4th *m);

/**
 * main entry point from C. implemented in assembly.
 * execute m4th->ip and subsequent code until m4th_bye is found.
 */
m4cell m4th_run(m4th *m);

/** execute the specified m4word, then return. preserves m4th->ip */
m4cell m4th_execute_word(m4th *m, const m4word *w);

/**
 * clear data stack, return stack, input buffer and output buffer.
 * set ->ip to ->code.start
 */
void m4th_clear(m4th *m);

/* add wid to the top of search order */
void m4th_also(m4th *m, m4wordlist *wid);

/* return <> 0 if search order contains wid */
m4cell m4th_knows(const m4th *m, const m4wordlist *wid);

/**
 * perform self-test, return != 0 if failed.
 * if out != NULL, also print failed tests to out.
 */
m4cell m4th_test(m4th *m, FILE *out);

void *m4mem_allocate(size_t bytes);          /** malloc() wrapper, calls exit(1) on failure */
void m4mem_free(void *ptr);                  /** free() wrapper */
void *m4mem_resize(void *ptr, size_t bytes); /** realloc() wrapper, calls exit(1) on failure */
void *m4mem_map(size_t bytes);               /** mmap() wrapper, calls exit(1) on failure */
void m4mem_unmap(void *ptr, size_t bytes);   /** munmap() wrapper */

m4cell m4code_equal(m4code src, m4code dst);
void m4code_print(m4code src, FILE *out);
const m4word *m4code_addr_to_word(const m4token *xt);

const m4word *m4dict_lastword(const m4dict *dict);
m4string m4dict_name(const m4dict *dict);
void m4dict_print(const m4dict *dict, FILE *out);

/** return how many bytes of code are consumed by token or word marked with given flags */
m4cell m4flags_consume_ip(m4flags fl);
void m4flags_print(m4flags fl, FILE *out);

/** return how many bytes of code are consumed by executing token */
m4cell m4token_consumes_ip(m4token tok);
void m4token_print(m4token val, FILE *out);
/** try to find the m4word that describes given token */
const m4word *m4token_to_word(m4token tok);

void m4slice_copy_to_code(m4slice src, m4code *dst);
void m4slice_to_word_code(const m4slice *src, m4word *dst);

m4cell m4string_equals(m4string a, m4string b);
void m4string_print(m4string str, FILE *out);
void m4string_print_hex(m4string str, FILE *out);

void m4stack_print(const m4stack *stack, FILE *out);

m4code m4word_code(const m4word *w);
m4string m4word_data(const m4word *w, m4cell code_start_n);
m4string m4word_name(const m4word *w);
const m4word *m4word_prev(const m4word *w);
void m4word_print(const m4word *w, FILE *out);
void m4word_code_print(const m4word *w, FILE *out);
void m4word_data_print(const m4word *w, m4cell data_start_n, FILE *out);

m4string m4wordlist_name(const m4wordlist *d);
const m4word *m4wordlist_lastword(const m4wordlist *d);
void m4wordlist_print(const m4wordlist *d, FILE *out);

#ifdef __cplusplus
}
#endif

#endif /* M4TH_M4TH_H */
