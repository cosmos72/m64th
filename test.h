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

#ifndef M4TH_TEST_H
#define M4TH_TEST_H

#include "m4th.h"

m4cell m4th_testcompile(m4th *m, FILE *out);
m4cell m4th_testexecute(m4th *m, FILE *out);

/* -------------- m4test_stack  -------------- */

enum { m4test_stack_n = 5 };

typedef struct m4test_stack_s {
    m4cell len;
    m4cell data[m4test_stack_n];
} m4test_stack;

typedef struct m4test_stacks_s {
    m4test_stack d, r;
} m4test_stacks;

void m4test_stack_copy(const m4test_stack *src, m4span *dst);
m4cell m4test_stack_equal(const m4test_stack *src, const m4span *dst);
void m4test_stack_print(const m4test_stack *src, FILE *out);

/* -------------- m4test_code  -------------- */

enum { m4test_code_n = 15 };

typedef struct m4test_code_s {
    m4cell n;
    m4cell data[m4test_code_n];
} m4test_code;

void m4test_code_print(const m4test_code *src, FILE *out);

/* -------------- m4test_word  -------------- */

typedef struct m4test_word_s {
    m4word impl;
    /* reserve space for test code + generated code */
    m4enum code[2 * m4test_code_n];
} m4test_word;

m4code m4test_word_as_code(const m4word *w, m4cell code_start_n);

void m4test_slice_to_word_code(const m4slice *src, m4word *dst);

#endif /* M4TH_TEST_H */
