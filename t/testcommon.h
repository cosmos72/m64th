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

#ifndef M4TH_T_TEST_IMPL_H
#define M4TH_T_TEST_IMPL_H

#include "../impl.h"          /* tfalse, ttrue */
#include "../include/word.mh" /* WORD_SYM() */
#include "../test.h"

enum {
    callsz = 1 + SZ / SZt, /* # of m4token needed to store a CALL(...) */
};

/* store m4token numeric constant in a m4countedwcode */
#define T(n) (n)
/** store int16_t numeric constant in a m4countedwcode */
#define SHORT(n) (int16_t)(n)
/** store int32_t numeric constant in a m4countedwcode */
#define INT(n) (int32_t)(n), 0
/** store m4cell numeric constant in a m4countedwcode */
#define CELL(n) (m4cell)(n), 0, 0, 0
/** store XT address in a sequence of m4cell */
#define DXT(name) ((m4cell)(WORD_SYM(name).code))

/* store m4_call_ and WORD_SYM(name).code in a m4countedwcode. */
#define CALL(name) m4_call_, CELL(WORD_SYM(name).code)

/* store m4_lit_string_ length and chars in a m4countedwcode. */
#define LIT_STRING(len, chars) m4_lit_string_, T(len), (m4cell)(chars)

/* -------------- m4testcompile --------------------------------------------- */

typedef struct m4testcompile_s {
    const char *input;
    m4countedstack dbefore, dafter;
    m4countedwcode codegen;
} m4testcompile;

/* -------------- m4testexecute --------------------------------------------- */

typedef m4cell m4fixedwcode[m4test_code_n];

typedef struct m4testexecute_s {
    const char *name;
    m4fixedwcode code;
    m4countedstacks before, after;
    m4countedwcode codegen;
} m4testexecute;

/* -------------- m4testio -------------------------------------------------- */

typedef struct m4cstr_pair_s {
    const char *in, *out;
} m4cstr_pair;

typedef struct m4testio_s {
    const char *name;
    m4fixedwcode code;
    m4countedstacks before, after;
    m4cstr_pair iobefore, ioafter;
} m4testio;

/* -------------- m4testcount ----------------------------------------------- */

typedef struct m4testcount_s {
    m4cell failed;
    m4cell total;
} m4testcount;

/* -------------- m4cell[] -> m4token[] conversion -------------------------- */

#define m4array_copy_to_tarray(array, tarray)                                                      \
    m4array_n_copy_to_tarray_n(array, N_OF(array), tarray, N_OF(tarray))

void m4array_n_copy_to_tarray_n(const m4cell array[], const m4cell array_n /*               */,
                                m4token tarray[], const m4cell tarray_n);

/* -------------- m4cell[] -> m4token[] conversion -------------------------- */

/**
 * remove all user-defined words, for example defined by a test.
 * needed before executing the following test
 */
void m4test_forget_all(m4th *m);

#endif /* M4TH_T_TEST_IMPL_H */
