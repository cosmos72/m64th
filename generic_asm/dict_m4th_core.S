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
/* --- m4th-core -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_core)

DICTNAME(9, "m4th-core", m4th_core)

DICT_WORDS_M4TH_CORE(WORDNAME)

WORD(div_token,        div_token,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(m4th,             div_token,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD_START(string_to_word, m4th)
    WORD_FLAGS(WORD_IMPURE)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        two_drop, zero, zero, exit /* TODO */
    )
WORD_END(string_to_word)
WORD(to_token,         string_to_word, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_plus,       to_token,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(tokens,           token_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_store,      tokens,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(token_fetch,      token_store,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD_START(word_inline_query,  token_fetch)
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        dup, word_to_flags,
        dup, _lit2s_, SHORT(M4FLAG_INLINE_ALWAYS), and, _if_, T(4),
            two_drop, true, exit,
        then,
        _lit2s_, SHORT(M4FLAG_INLINE), and, _if_zero_, T(4),
            drop, false, exit,
        then,
        word_to_code_n, eight, less, exit
    )
WORD_END(word_inline_query)
WORD(word_to_code,  word_inline_query, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_code_n,   word_to_code,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_flags,    word_to_code_n, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_name,     word_to_flags,  DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_prev,     word_to_name,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_xt,       word_to_prev,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(wordlist_to_last, word_to_xt,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
/* wordlist-find ( c-addr u wid -- w|0 ) search word name in wordlist */
WORD_START(wordlist_find, wordlist_to_last)
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* wordlist>last                                       ( addr n w          )
         * begin
         *    ?if0 nip nip exit                                ( 0                 )
         *    then                                             ( addr n w          )
         *    dup >r word>name                                 ( addr n addr' n'   ) (R: w  )
         *    rot tuck                                         ( addr addr' n n' n ) (R: w  )
         *    = if                                             ( addr addr' n      ) (R: w  )
         *       string= if                                    ( addr addr' n      ) (R: w  )
         *          2drop drop r> exit                         ( w                 )
         *       then                                          ( addr addr' n      ) (R: w  )
         *    then                                             ( addr addr' n      ) (R: w  )
         *    nip r> word>prev                                 ( addr n     w'     )
         * again
         */
        wordlist_to_last,
        begin,
            _q_if_zero_, T(4), nip, nip, exit,
            then,
            dup, to_r, word_to_name,
            rot, tuck,
            equal, _if_, T(9),
                string_equal, _if_, T(5),
                    two_drop, drop, r_from, exit,
                then,
            then,
            nip, r_from, word_to_prev,
        _again_, T(-28)
    )
WORD_END(wordlist_find)
WORD(xt_to_word,     wordlist_find,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)

DICT_BODY(m4th_core, xt_to_word)
DICT_END(m4th_core)
