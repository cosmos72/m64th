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

#include <stddef.h>    /* size_t  */
#include <stdio.h>     /* FILE    */
#include <sys/types.h> /* ssize_t */

typedef unsigned char m4char;
typedef size_t m4uint;
typedef ssize_t m4int;

typedef struct m4cspan_s m4cspan;
typedef struct m4ispan_s m4ispan;
typedef struct m4ispan_s m4stack;
typedef struct m4ispan_s m4code;
typedef struct m4th_s m4th;

struct m4cspan_s {
    m4char *start;
    m4char *curr;
    m4char *end;
};

struct m4ispan_s {
    m4int *start;
    m4int *curr;
    m4int *end;
};

struct m4th_s {
    m4stack dstack; /* data stack          */
    m4stack rstack; /* return stack        */
    m4code code;    /* executable code     */
    m4int *ip;      /* instruction pointer */
    m4int *c_sp;    /* C stack pointer. saved here by m4th_enter() */
    m4cspan in;     /* input  buffer       */
    m4cspan out;    /* output buffer       */
};

/** create a new m4th struct */
m4th *m4th_new();

/** delete an m4th struct */
void m4th_del(m4th *m);

/**
 * main entry point from C. implemented in assembly.
 * execute m4th->ip and subsequent code until m4th_bye is found.
 */
void m4th_enter(m4th *m);

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

/** print stack to out */
void m4th_stack_print(const m4stack *stack, FILE *out);

/** malloc() wrapper, calls exit(1) on failure */
void *m4th_alloc(size_t bytes);

/** free() wrapper */
void m4th_free(void *ptr);

/** mmap() wrapper, calls exit(1) on failure */
void *m4th_mmap(size_t bytes);

/** munmap() wrapper */
void m4th_munmap(void *ptr, size_t bytes);

#endif /* M4TH_M4TH_H */
