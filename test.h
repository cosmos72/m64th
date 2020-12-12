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

#ifndef M64TH_TEST_H
#define M64TH_TEST_H

#include "include/m64th.h"

m6cell m64th_testcompile(m64th *m, FILE *out);
m6cell m64th_testexecute(m64th *m, FILE *out);
m6cell m64th_testhashmap_int(FILE *out);
m6cell m64th_testhashmap_string(FILE *out);
m6cell m64th_testio(m64th *m, FILE *out);
m6cell m64th_testlocal(m64th *m, FILE *out);

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

/* -------------- m6countedstack  -------------- */

enum { m6test_stack_n = 10 };

typedef struct m6countedstack_s {
    m6cell len;
    m6cell data[m6test_stack_n];
} m6countedstack;

typedef struct m6countedstacks_s {
    m6countedstack d, r;
} m6countedstacks;

void m6countedstack_copy(const m6countedstack *src, m6buf *dst);
m6cell m6countedstack_equal(const m6countedstack *src, const m6buf *dst);
void m6countedstack_print(const m6countedstack *src, FILE *out);

/* -------------- m6code_pair  -------------- */

typedef struct m6code_pair_s {
    m6code first, second;
} m6code_pair;

/* -------------- m6countedcode  -------------- */

enum { m6test_code_n = 16 };

typedef struct m6countedcode_s {
    m6cell n;
    m6token data[m6test_code_n];
} m6countedcode;

typedef struct m6countedcode_pair_s {
    m6countedcode first, second;
} m6countedcode_pair;

/* -------------- m6countedwcode  -------------- */

typedef struct m6countedwcode_s {
    m6cell n;
    m6cell data[m6test_code_n];
} m6countedwcode;

#endif /* M64TH_TEST_H */
