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

DICT_WORDS_FORTH_SEARCH_ORDER(WORDNAME)

/* duplicate first wordlist in search order (S: wid -- wid wid ) */
WORD_START(also,       LASTWORD)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        searchorder_n, fetch,                          /* ( n                ) */
        _lit_, T(M4TH_SEARCHORDER_MAX), more_equal,    /* ( t|f              ) */
        _lit_, T(M4ERR_WORDLIST_OVERFLOW), and,        /* ( err|0            ) */
        throw,                                         /* (                  ) */
        one, searchorder_n, plus_store,                /* (                  ) */
        one, searchorder_i, fetch,                     /* ( wid              ) */
        zero, searchorder_i, store,                    /* (                  ) */
        exit
    )
WORD_END(also)
/* replace first wordlist in search order with forth wordlist (S: wid -- forth ) */
WORD_START(forth,          also)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        CALL(forth_wordlist),                          /* ( wid              ) */
        CALL(searchorder_store_0), exit                /* (                  ) */
    )
WORD_END(forth)
/* ( -- wid ) get forth wordlist */
WORD_START(forth_wordlist, forth)
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
/* ( -- wid ) get current compilation wordlist */
WORD(get_current,      forth_wordlist, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( c-addr u wid -- 0 | xt 1 | xt -1 ) */
WORD_START(search_wordlist, get_current)
    WORD_DSTACK(3,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_MEM_FETCH)
    WORD_CODE(
        CALL(wordlist_find),                           /* ( w|0 -1|0|1       ) */
        _q_if0_, T(2),                                 /* ( 0   0            ) */
            nip, exit,                                 /* ( 0                ) */
        then,                                          /* ( w   -1|1         ) */
        swap, name_to_xt, swap, exit                   /* ( xt  -1|1         ) */
    )
WORD_END(search_wordlist)
/* ( wid -- ) set compilation wordlist */
WORD(set_current,     search_wordlist, DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)

#undef LASTWORD
#define LASTWORD set_current
