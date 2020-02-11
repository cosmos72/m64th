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

#ifndef M4TH_T_TEST_IMPL_H
#define M4TH_T_TEST_IMPL_H

#include "../include/word.mh" /* WORD_SYM() */
#include "../test.h"

enum {
    tfalse = (m4cell)0,
    ttrue = (m4cell)-1,
    callsz = 1 + SZ / SZt, /* # of m4token needed to store a (call) XT(...) */
};

/* store m4token numeric constant in a sequence of m4token */
#define T(n) (n)
/** store int16_t numeric constant in a sequence of m4token */
#define SHORT(n) (int16_t)(n)
/** store int32_t numeric constant in a sequence of m4token */
#define INT(n) (int32_t)(n), 0
/** store m4cell numeric constant in a sequence of m4token */
#define CELL(n) (m4cell)(n), 0, 0, 0
/** store XT address in a sequence of m4cell. only works if word->data_len == 0 */
#define DXT(name) ((m4cell)(WORD_SYM(name).data))

/* store m4_call_ and word in a sequence of m4cell. */
#define CALL(name) m4_call_, CELL(&WORD_SYM(name))

/* store m4_call_xt_ and XT in a sequence of m4cell. only works if word->data_len == 0 */
#define CALLXT(name) m4_call_xt_, CELL(WORD_SYM(name).data)

#endif /* M4TH_T_TEST_IMPL_H */
