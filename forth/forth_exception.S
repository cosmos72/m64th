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

DICT_WORDS_FORTH_EXCEPTION(WORDNAME)

WORD_START(abort,      LASTWORD)
    WORD_STACK_NONE()
    WORD_DSTACK(0,-1) /* stack effect when throwing */
    WORD_RSTACK(0,-1)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_JUMP)
    WORD_CODE(minus_one, throw, exit)
WORD_END(abort)
WORD_START(catch,      abort)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(_catch_beg_, _catch_end_, exit)
WORD_END(catch)
WORD_START(throw,      catch)
    WORD_DSTACK(1,0) /* stack effect when not throwing */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,-1) /* stack effect when throwing */
    WORD_RSTACK(0,-1)
    WORD_NATIVE_NONE() /* uses IP-relative jump to 'bye', cannot inline in native code */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_CODE(throw, exit)
WORD_END(throw)

#undef LASTWORD
#define LASTWORD throw
