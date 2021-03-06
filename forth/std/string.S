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

/* clang-format off */

DICT_WORDS_FORTH_STRING(WORDNAME)

WORD(div_string,       LASTWORD,   DSTACK(3,2), RSTACK(0,0), WORD_PURE)
WORD_START(blank,      div_string)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_STORE)
    WORD_CODE(bl, fill, exit)
WORD_END(blank)
WORD_START(cmove,      blank)
    WORD_DSTACK(3,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses %ip-relative TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH | M6FLAG_MEM_STORE)
    WORD_CODE(cmove, exit)
WORD_END(cmove)

#undef LASTWORD
#define LASTWORD cmove
