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

DICT_WORDS_FORTH_STRING(WORDNAME)

WORD(div_string,       LASTWORD,   DSTACK(3,2), RSTACK(0,0), WORD_PURE)
WORD_START(cmove,      div_string)
    WORD_DSTACK(3,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses %ip-relative TOKEN_CALL(), cannot inline in native code */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH | M4FLAG_MEM_STORE)
    WORD_CODE(cmove, exit)
WORD_END(cmove)

#undef LASTWORD
#define LASTWORD cmove
