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

#include "m4th_macro.h"

#include <stddef.h>    /* size_t    */
#include <stdint.h>    /* [u]int*_t */
#include <stdio.h>     /* FILE      */
#include <sys/types.h> /* ssize_t   */

typedef struct m4arg_s m4arg; /**< intentionally incomplete type, cannot be instantiated */

typedef unsigned char m4char;
typedef size_t m4uint;
typedef ssize_t m4int;
/** forth instruction. uses forth calling convention, cannot be invoked from C */
typedef void (*m4instr)(m4arg);

typedef char assert_sizeof_m4instr_equals_sizeof_m4int[sizeof(m4instr) == sizeof(m4int) ? 1 : -1];

/** m4th flags */
typedef enum m4th_flags_e {
    m4th_flag_status_mask = M4TH_FLAG_STATUS_MASK,
    m4th_flag_interpret = M4TH_FLAG_INTERPRET,
    m4th_flag_compile = M4TH_FLAG_COMPILE,
} m4th_flags;

/** m4word flags */
typedef enum m4flags_e {
    m4flag_addr_mask = M4FLAG_ADDR_MASK,
    m4flag_addr_fetch = M4FLAG_ADDR_FETCH,
    m4flag_addr_store = M4FLAG_ADDR_STORE,
    m4flag_compile_only = M4FLAG_COMPILE_ONLY,
    m4flag_immediate = M4FLAG_IMMEDIATE,
    m4flag_inline_mask = M4FLAG_INLINE_MASK,
    m4flag_inline = M4FLAG_INLINE,
    m4flag_inline_always = M4FLAG_INLINE_ALWAYS,
    m4flag_inline_native = M4FLAG_INLINE_NATIVE,
    m4flag_jump = M4FLAG_JUMP,
    m4flag_pure_mask = M4FLAG_PURE_MASK,
    m4flag_pure = M4FLAG_PURE,
    m4flag_consumes_ip_mask = M4FLAG_CONSUMES_IP_MASK,
    m4flag_consumes_ip_1 = M4FLAG_CONSUMES_IP_1,
    m4flag_consumes_ip_2 = M4FLAG_CONSUMES_IP_2,
    m4flag_consumes_ip_4 = M4FLAG_CONSUMES_IP_4,
    m4flag_consumes_ip_8 = M4FLAG_CONSUMES_IP_8,
} m4flags;

typedef struct m4cspan_s m4cspan;
typedef struct m4span_s m4span;
typedef struct m4span_s m4stack;
typedef struct m4code_s m4code;
typedef struct m4countedstring_s m4countedstring;
typedef struct m4dict_s m4dict;
typedef struct m4word_s m4word;
typedef struct m4th_s m4th;

struct m4cspan_s {
    m4char *start;
    m4char *curr;
    m4char *end;
};

struct m4span_s {
    m4int *start;
    m4int *curr;
    m4int *end;
};

struct m4code_s {
    m4instr *start;
    m4instr *curr;
    m4instr *end;
};

struct m4countedstring_s { /**< counted string                           */
    m4char len;            /**< string length, in bytes                  */
    m4char chars[1];       /**< string characters. may NOT end with '\0' */
};

struct m4word_s {       /**< word                                                 */
    int32_t prev_off;   /**< offset of previous word,   in bytes. 0 = not present */
    int16_t name_off;   /**< offset of m4countedstring, in bytes. 0 = not present */
    uint8_t flags;      /**< m4flags                                              */
    uint8_t dstack;     /**< dstack # in and # out. 0xFF if unknown or variable   */
    uint8_t rstack;     /**< rstack # in and # out. 0xFF if unknown or variable   */
    uint8_t native_len; /**< native code size, in bytes                         */
    uint16_t code_len;  /**< forth code size, in bytes                            */
    uint32_t data_len;  /**< data size, in bytes                                  */
    m4instr code[0];    /**< code starts at [0], data starts at [code_len]        */
};

struct m4dict_s {     /**< dictionary                                           */
    int32_t word_off; /**< offset of last word,       in bytes. 0 = not present */
    int16_t name_off; /**< offset of m4countedstring, in bytes. 0 = not present */
};

struct m4th_s {     /**< m4th forth interpreter and compiler */
    m4stack dstack; /**< data stack                          */
    m4stack rstack; /**< return stack                        */
    m4code code;    /**< forth code being compiled           */
    m4instr *ip;    /**< instruction pointer                 */
    void *c_sp;     /**< C stack pointer, may be saved here by m4th_run() */
    m4cspan in;     /**< input  buffer                       */
    m4cspan out;    /**< output buffer                       */
    m4int flags;    /**< m4th_flags                          */

    const m4dict *dicts[4];     /* FIXME: available dictionaries */
    const char *const *in_cstr; /* DELETEME: pre-parsed input    */
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
m4int m4th_run(m4th *m);

/**
 * clear data stack, return stack, input buffer and output buffer.
 * set ->ip to ->code.start
 */
void m4th_clear(m4th *m);

/**
 * perform self-test, return != 0 if failed.
 * if out != NULL, also print failed tests to out.
 */
m4int m4th_test(m4th *m, FILE *out);

/** malloc() wrapper, calls exit(1) on failure */
void *m4th_alloc(size_t bytes);

/** free() wrapper */
void m4th_free(void *ptr);

/** mmap() wrapper, calls exit(1) on failure */
void *m4th_mmap(size_t bytes);

/** munmap() wrapper */
void m4th_munmap(void *ptr, size_t bytes);

void m4th_countedstring_print(const m4countedstring *n, FILE *out);

void m4th_stack_print(const m4stack *stack, FILE *out);

const m4countedstring *m4th_dict_name(const m4dict *d);
const m4word *m4th_dict_lastword(const m4dict *d);
void m4th_dict_print(const m4dict *d, FILE *out);

const m4countedstring *m4th_word_name(const m4word *w);
const m4word *m4th_word_prev(const m4word *w);
void m4th_word_print(const m4word *w, FILE *out);

#ifdef __cplusplus
}
#endif

#endif /* M4TH_M4TH_H */
