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

enum { tfalse = (m4int)0, ttrue = (m4int)-1 };

void m4word_code_print(const m4word *w, FILE *out);

m4int m4th_testcompile(m4th *m, FILE *out);
m4int m4th_testexecute(m4th *m, FILE *out);

/* -------------- m4testexecute  -------------- */

enum { m4test_stack_n = 5 };

typedef struct m4test_stack_s {
    m4int len;
    m4int data[m4test_stack_n];
} m4test_stack;

void m4test_stack_copy(const m4test_stack *src, m4span *dst);

/* -------------- m4testcompile  -------------- */

enum { m4testcompile_code_n = 6 };

typedef struct m4testcompile_code_s {
    m4int len;
    m4instr data[m4testcompile_code_n];
} m4testcompile_code;

typedef struct m4testcompile_word_s {
    m4word impl;
    /* reserve space for generated code */
    m4instr code[m4testcompile_code_n];
} m4testcompile_word;

#endif /* M4TH_TEST_H */
