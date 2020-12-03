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

DICT_WORDS_FORTH_SEARCHORDER(WORDNAME)

/* duplicate first wordlist in search order ( SO: wid -- wid wid ) */
WORD_START(also,       LASTWORD)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        searchorder_dup, exit
    )
WORD_END(also)
/* ( -- wid ) get current compilation wordlist */
WORD(get_current,      also,           DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( wid -- ) set compilation wordlist */
WORD(set_current,      get_current,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
/* ( -- wid ) create a new, initially empty wordlist */
WORD_START(wordlist,   set_current)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _c_locals_save_,
            _c_arg_0_, _c_call_, CELL(m4wordlist_new), _c_ret_1_,/*( wid|0      ) */
        _c_locals_load_,
        dup, zero_equal,                                        /* ( wid|0 t|f  ) */
        _lit_, T(M4ERR_FAILED_TO_ALLOCATE), and, throw,         /* ( wid        ) */
        exit
    )
WORD_END(wordlist)

#undef LASTWORD
#define LASTWORD wordlist
