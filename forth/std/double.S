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

/* clang-format off */

DICT_WORDS_FORTH_DOUBLE(WORDNAME)

WORD(d_to_s,                 LASTWORD, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/* d0< ( d -- t|f ) true if d is negative */
WORD_START(d_zero_less,        d_to_s)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        d_to_hi, zero_less, exit
    )
WORD_END(d_zero_less)
/* d0= ( d -- t|f ) true if d is zero */
WORD_START(d_zero_equal,       d_zero_less)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        or, zero_equal, exit
    )
WORD_END(d_zero_equal)

#undef LASTWORD
#define LASTWORD d_zero_equal
