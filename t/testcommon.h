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

#ifndef M6TH_T_TEST_IMPL_H
#define M6TH_T_TEST_IMPL_H

#include "../impl.h"          /* tfalse, ttrue */
#include "../include/word.mh" /* WORD_SYM() */
#include "../test.h"

/* store m6token numeric constant in a m6countedwcode */
#define T(n) (n)
/** store int16_t numeric constant in a m6countedwcode */
#define SHORT(n) (int16_t)(n)
/** store int32_t numeric constant in a m6countedwcode */
#define INT(n) (int32_t)(n), 0
/** store m6cell numeric constant in a m6countedwcode */
#define CELL(n) (m6cell)(n), 0, 0, 0
/** store XT address in a sequence of m6cell */
#define DXT(name) ((m6cell)(WORD_SYM(name).code))

/* store m6_call_ and WORD_SYM(name).code in a m6countedwcode. */
#define CALL(name) m6_call_, CELL(WORD_SYM(name).code)

/* store m6_lit_string_ length and chars in a m6countedwcode. */
#define LIT_STRING(len, chars) m6_lit_string_, T(len), (m6cell)(chars)

/* -------------- m6testcompile --------------------------------------------- */

typedef struct m6testcompile_s {
    const char *input;
    m6countedstack dbefore, dafter;
    m6countedwcode codegen;
} m6testcompile;

/* -------------- m6testexecute --------------------------------------------- */

typedef m6cell m6fixedwcode[m6test_code_n];

typedef struct m6testexecute_s {
    const char *name;
    m6fixedwcode code;
    m6countedstacks before, after;
    m6countedwcode codegen;
} m6testexecute;

/* -------------- m6testio -------------------------------------------------- */

typedef struct m6cstr_pair_s {
    const char *in, *out;
} m6cstr_pair;

typedef struct m6testio_s {
    const char *name;
    m6fixedwcode code;
    m6countedstacks before, after;
    m6cstr_pair iobefore, ioafter;
} m6testio;

/* -------------- m6testcount ----------------------------------------------- */

typedef struct m6testcount_s {
    m6cell failed;
    m6cell total;
} m6testcount;

/* -------------- m6cell[] -> m6token[] conversion -------------------------- */

#define m6array_copy_to_tarray(array, tarray)                                                      \
    m6array_n_copy_to_tarray_n(array, N_OF(array), tarray, N_OF(tarray))

void m6array_n_copy_to_tarray_n(const m6cell array[], const m6cell array_n /*               */,
                                m6token tarray[], const m6cell tarray_n);

/* -------------- m6cell[] -> m6token[] conversion -------------------------- */

/**
 * remove all user-defined words, for example defined by a test.
 * needed before executing the following test
 */
void m6test_forget_all(m64th *m);

#endif /* M6TH_T_TEST_IMPL_H */
