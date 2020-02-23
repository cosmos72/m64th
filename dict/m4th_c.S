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

#include "../include/asm.mh"
#include "../include/dict.mh"
#include "../include/dict_m4th.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-user -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_c)

DICTNAME(6, "m4th-c", m4th_c)

DICT_WORDS_M4TH_C(WORDNAME)

WORD(c_arg_0,          c_arg_0,        DSTACK(0,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(c_arg_1,          c_arg_0,        DSTACK(1,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(c_arg_2,          c_arg_1,        DSTACK(2,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(c_arg_3,          c_arg_2,        DSTACK(3,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(c_arg_4,          c_arg_3,        DSTACK(4,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(c_arg_5,          c_arg_4,        DSTACK(5,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(c_arg_6,          c_arg_5,        DSTACK(6,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD_START(_c_call_,   c_arg_6)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS | M4FLAG_CONSUMES_IP_SZ | M4FLAG_COMPILE_ONLY)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_c_call_, exit)
WORD_END(_c_call_)
WORD(c_ret_0,          _c_call_,       DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(c_ret_1,          c_ret_0,        DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(c_ret_2,          c_ret_1,        DSTACK(0,2), RSTACK(0,0), WORD_IMPURE)

DICT_BODY(m4th_c, c_ret_2)
DICT_END(m4th_c)

