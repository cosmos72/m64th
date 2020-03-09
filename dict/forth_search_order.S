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

/* ( c-addr u wid -- 0 | xt 1 | xt -1 ) */
WORD_START(search_wordlist, LASTWORD)
    WORD_FLAGS(M4FLAG_MEM_FETCH)
    WORD_DSTACK(3,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        CALL(wordlist_find),                  /* ( w|0 -1|0|1       ) */
        _q_if_zero_, T(2),                             /* ( 0   0            ) */
            nip, exit,                                 /* ( 0                ) */
        then,                                          /* ( w   -1|1         ) */
        swap, name_to_xt, swap, exit                   /* ( xt  -1|1         ) */
    )
WORD_END(search_wordlist)

#undef LASTWORD
#define LASTWORD search_wordlist
