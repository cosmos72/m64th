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

typedef size_t m4uint;
typedef ssize_t m4int;
typedef struct m4span_s m4span;
typedef struct m4th_s m4th;

struct m4span_s {
    m4int* begin;
    m4int* end;
};

struct m4th_s {
    m4span dstack;  /* data stack */
    m4span rstack;  /* return stack */
    m4span code;    /* executable code */
    m4int* ip;      /* instruction pointer */
    m4int* c_stack; /* C stack pointer. saved here by m4th_enter() */
};

/** malloc() wrapper, calls exit(1) on failure */
void* m4th_alloc(size_t bytes);

/** create a new m4th struct */
m4th* m4th_new();

/** delete an m4th struct */
void  m4th_del(m4th* m);

/**
 * main entry point from C. implemented in assembly.
 * execute m4th->ip and subsequent code until m4th_bye is found.
 */
void m4th_enter(m4th* m);

/** clear data stack and return stack. set ->ip to ->code.begin */
void m4th_clear(m4th* m);

/**
 * perform self-test, return != 0 if failed.
 * if out != NULL, print failed tests to out.
 */
m4int m4th_test(m4th* m, FILE* out);

/** print stack to 'out' */
void m4th_stack_print(const m4span* stack, FILE* out);

#endif /* M4TH_M4TH_H */
