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

#ifndef M4TH_TEST_H
#define M4TH_TEST_H

#include "m4th.h"

m4cell m4th_testcompile(m4th *m, FILE *out);
m4cell m4th_testexecute(m4th *m, FILE *out);
m4cell m4th_testio(m4th *m, FILE *out);
m4cell m4th_testhashmap_int(FILE *out);
m4cell m4th_testhashmap_countedstring(FILE *out);

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

/* -------------- m4countedstack  -------------- */

enum { m4test_stack_n = 10 };

typedef struct m4countedstack_s {
    m4cell len;
    m4cell data[m4test_stack_n];
} m4countedstack;

typedef struct m4countedstacks_s {
    m4countedstack d, r;
} m4countedstacks;

void m4countedstack_copy(const m4countedstack *src, m4buf *dst);
m4cell m4countedstack_equal(const m4countedstack *src, const m4buf *dst);
void m4countedstack_print(const m4countedstack *src, FILE *out);

/* -------------- m4code_pair  -------------- */

typedef struct m4code_pair_s {
    m4code first, second;
} m4code_pair;

/* -------------- m4countedcode  -------------- */

enum { m4test_code_n = 16 };

typedef struct m4countedcode_s {
    m4cell n;
    m4token data[m4test_code_n];
} m4countedcode;

typedef struct m4countedcode_pair_s {
    m4countedcode first, second;
} m4countedcode_pair;

/* -------------- m4countedwcode  -------------- */

typedef struct m4countedwcode_s {
    m4cell n;
    m4cell data[m4test_code_n];
} m4countedwcode;

#endif /* M4TH_TEST_H */
