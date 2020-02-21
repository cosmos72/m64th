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

#include "../include/word.mh" /* WORD_SYM() */
#include "../test.h"

enum {
    tfalse = (m4cell)0,
    ttrue = (m4cell)-1,
    callsz = 1 + SZ / SZt, /* # of m4token needed to store a CALL(...) or CALLXT(...) */
};

/* store m4token numeric constant in a m4countedwcode */
#define T(n) (n)
/** store int16_t numeric constant in a m4countedwcode */
#define SHORT(n) (int16_t)(n)
/** store int32_t numeric constant in a m4countedwcode */
#define INT(n) (int32_t)(n), 0
/** store m4cell numeric constant in a m4countedwcode */
#define CELL(n) (m4cell)(n), 0, 0, 0
/** store XT address in a sequence of m4cell. correct only if word->data_len == 0 */
#define DXT(name) ((m4cell)(WORD_SYM(name).data))

/* store m4_call_ and word in a m4countedwcode. */
#define CALL(name) m4_call_, CELL(&WORD_SYM(name))

/* store m4_call_xt_ and XT in a m4countedwcode. correct only if word->data_len == 0 */
#define CALLXT(name) m4_call_xt_, CELL(WORD_SYM(name).data)

typedef struct m4testcompile_s {
    const char *input;
    m4countedstack dbefore, dafter;
    m4countedwcode codegen;
} m4testcompile;

typedef m4cell m4fixedwcode[m4test_code_n];

typedef struct m4testexecute_s {
    const char *name;
    m4fixedwcode code;
    m4countedstacks before, after;
    m4countedwcode codegen;
} m4testexecute;

#endif /* M4TH_T_TEST_IMPL_H */
