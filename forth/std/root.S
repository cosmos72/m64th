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

#include "../../include/err.mh"

/* words shared between several wordlists: forth-root forth m64th-user */

DICT_WORDS_FORTH_ROOT(WORDNAME)

/* ( -- wid ) get forth wordlist */
WORD_START(forth_wordlist, forth_wordlist)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m6wordlist_forth),            /* extern C symbol      */
        exit
    )
WORD_END(forth_wordlist)
/*
 * replace first wordlist in search order with m64th_user wordlist ( SO: * wid -- * m64th_user )
 * it is included in forth-root wordlist to allow adding m64th* wordlists to searchorder
 * after they have been removed for any reason
 */
WORD_START(m64th_user,  forth_wordlist)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m6wordlist_m64th_user),        /* ( wid                ) */
        searchorder_store_0, exit                      /* (                    ) */
    )
WORD_END(m64th_user)
/* show all words in searchorder wordlists */
WORD_START(words, m64th_user)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        user_var_m64th,
        _c_locals_save_,
            _c_arg_1_, _c_call_, CELL(m64th_c_print_all_words), _c_ret_0_,
        _c_locals_load_, exit
    )
WORD_END(words)

#undef LASTWORD
#define LASTWORD words
