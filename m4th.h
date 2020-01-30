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
typedef size_t m4uint;
typedef ssize_t m4cell;
/** forth instruction. uses forth calling convention, cannot be invoked from C */
typedef void (*m4func)(m4arg);

typedef char
    m4th_assert_sizeof_m4instr_less_equal_sizeof_m4cell[sizeof(m4func) <= sizeof(m4cell) ? 1 : -1];

typedef char
    m4th_assert_sizeof_m4token_divides_sizeof_m4cell[(sizeof(m4cell) % sizeof(m4token) == 0) ? 1
                                                                                             : -1];

/** m4th flags */
typedef enum m4th_flags_e {
    m4th_flag_status_mask = M4TH_FLAG_STATUS_MASK,
    m4th_flag_interpret = M4TH_FLAG_INTERPRET,
    m4th_flag_compile = M4TH_FLAG_COMPILE,
} m4th_flags;

typedef uint8_t m4stackeffect; /**< stack # in and # out. 0xFF if unknown or variable   */

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
    m4flag_data_is_code = M4FLAG_DATA_IS_CODE,
} m4flags;

typedef struct m4countedstring_s m4countedstring;
typedef struct m4cspan_s m4cspan;
typedef struct m4dict_s m4dict;
typedef struct m4code_s m4code;
typedef struct m4span_s m4span;
typedef struct m4span_s m4stack;
typedef struct m4stackeffects_s m4stackeffects;
typedef struct m4string_s m4string;
typedef struct m4slice_s m4slice;
typedef struct m4word_s m4word;
typedef struct m4wordlist_s m4wordlist;
typedef struct m4th_s m4th;

struct m4countedstring_s { /**< counted string                   */
    m4char n;              /**< # of characters                  */
    m4char chars[1];       /**< characters. do NOT end with '\0' */
};

struct m4code_s { /**< array of m4token, with size */
    m4token *data;
    m4cell n;
};

/** array of m4char, with current size and capacity */
struct m4cspan_s {
    m4char *start;
    m4char *curr;
    m4char *end;
};

/** array of m4cell, with current size and capacity */
struct m4span_s {
    m4cell *start;
    m4cell *curr;
    m4cell *end;
};

struct m4string_s { /**< array of characters, with size */
    const m4char *data;
    m4cell n;
};

struct m4stackeffects_s {
    m4stackeffect dstack; /**< dstack # in and # out. 0xFF if unknown or variable   */
    m4stackeffect rstack; /**< rstack # in and # out. 0xFF if unknown or variable   */
};

/** array of m4cell, with size */
struct m4slice_s {
    m4cell *data;
    m4cell n;
};

/** compiled forth word. Execution token i.e. XT is the address of m4word.code[0] */
struct m4word_s {
    int32_t prev_off;    /**< offset of previous word,   in bytes. 0 = not present */
    int16_t name_off;    /**< offset of m4countedstring, in bytes. 0 = not present */
    uint16_t flags;      /**< m4flags                                              */
    m4stackeffects eff;  /**< stack effects if not jumping                         */
    m4stackeffects jump; /**< stack effects if jumping                             */
    uint16_t native_len; /**< native code size, in bytes. 0xFFFF if not available  */
    uint16_t code_n;     /**< forth code size, in m4token:s                         */
    uint64_t data_len;   /**< data size, in bytes                                  */
    m4token code[0];     /**< code i.e. XT starts at [0], data starts at [code_n]  */
};

struct m4wordlist_s {   /**< wordlist                                             */
    const m4dict *impl; /**< pointer to implementation dictionary                 */
    /* TODO hash table of contained words */
};

struct m4dict_s {     /**< dictionary. used to implement wordlist                */
    int32_t word_off; /**< offset of last m4word*,     in bytes. 0 = not present */
    int16_t name_off; /**< offset of m4countedstring*, in bytes. 0 = not present */
};

enum { m4th_wordlist_n = 12 };

struct m4th_s {        /**< m4th forth interpreter and compiler */
    m4stack dstack;    /**< data stack                          */
    m4stack rstack;    /**< return stack                        */
    m4word *w;         /**< forth word being compiled           */
    const m4token *ip; /**< instruction pointer                 */
    m4func *ftable;    /**< table m4t -> asm function address   */
    m4cspan in;        /**< input  buffer                       */
    m4cspan out;       /**< output buffer                       */

    m4cell flags;          /**< m4th_flags                               */
    const void *c_regs[1]; /**< m4th_run_vm() may save C registers here  */

    m4wordlist *wordlist[m4th_wordlist_n]; /**< FIXME: visible wordlists     */
    const char *const *in_cstr;            /**< DELETEME: pre-parsed input   */
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
m4cell m4th_run_vm(m4th *m);

/**
 * clear data stack, return stack, input buffer and output buffer.
 * set ->ip to ->code.start
 */
void m4th_clear(m4th *m);

/**
 * perform self-test, return != 0 if failed.
 * if out != NULL, also print failed tests to out.
 */
m4cell m4th_test(m4th *m, FILE *out);

/** malloc() wrapper, calls exit(1) on failure */
void *m4mem_allocate(size_t bytes);

/** free() wrapper */
void m4mem_free(void *ptr);

/** realloc() wrapper, calls exit(1) on failure */
void *m4mem_resize(void *ptr, size_t bytes);

/** mmap() wrapper, calls exit(1) on failure */
void *m4mem_map(size_t bytes);

/** munmap() wrapper */
void m4mem_unmap(void *ptr, size_t bytes);

m4cell m4code_equal(m4code src, m4code dst);
void m4code_print(m4code src, FILE *out);

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

m4cell m4string_compare(m4string a, m4string b);
void m4string_print(m4string str, FILE *out);
void m4string_print_hex(m4string str, FILE *out);

void m4stack_print(const m4stack *stack, FILE *out);

m4code m4word_code(const m4word *w, m4cell code_start_n);
m4string m4word_data(const m4word *w, m4cell code_start_n);
m4string m4word_name(const m4word *w);
const m4word *m4word_prev(const m4word *w);
void m4word_print(const m4word *w, FILE *out);
void m4word_code_print(const m4word *w, m4cell code_start_n, FILE *out);
void m4word_data_print(const m4word *w, m4cell data_start_n, FILE *out);

m4string m4wordlist_name(const m4wordlist *d);
const m4word *m4wordlist_lastword(const m4wordlist *d);
void m4wordlist_print(const m4wordlist *d, FILE *out);

#ifdef __cplusplus
}
#endif

#endif /* M4TH_M4TH_H */
