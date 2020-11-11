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

#include "../include/err.mh"

/* words shared between forth wordlist and forth-root wordlist */

DICT_WORDS_FORTH_ROOT(WORDNAME)

/* ( -- wid ) get forth wordlist */
WORD_START(forth_wordlist, forth_wordlist)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m4wordlist_forth),            /* extern C symbol      */
        exit
    )
WORD_END(forth_wordlist)
/*
 * replace first wordlist in search order with m4th_user wordlist (S: * wid -- * m4th_user )
 * it is included in forth-root wordlist to allow adding m4th* wordlists to searchorder
 * after they have been removed for any reason
 */
WORD_START(m4th_user,  forth_wordlist)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m4wordlist_m4th_user),        /* ( wid                ) */
        searchorder_store_0, exit                      /* (                    ) */
    )
WORD_END(m4th_user)

#undef LASTWORD
#define LASTWORD m4th_user
