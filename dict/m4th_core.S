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
/* ( -- addr) get address of m4th.err. pure: m4th is a per-thread constant */
WORD(m4th_err,         div_token,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(in_to_iobuf,      m4th_err,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_addr,       in_to_iobuf,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_data,       iobuf_addr,     DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_max,        iobuf_data,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_pos,        iobuf_max,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_size,       iobuf_pos,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(searchorder_i,    iobuf_size,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
/* searchorder-n ( -- addr ) get address of searchorder count */
WORD(searchorder_n,    searchorder_i,  DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/*
 * string>word ( c-addr u -- w|0 -1|0|1 ) find word name in current search order.
 * return 1 if word is immediate, else -1
 */
WORD_START(string_to_word, searchorder_n)
    WORD_FLAGS(0)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* searchorder-n @ 0                       ( c-addr u n 0              )
         * ?do                                     ( c-addr u                  ) (R: n i )
         *    2dup i searchorder-i @               ( c-addr u c-addr u wid     ) (R: n i )
         *    wordlist-find                        ( c-addr u w|0 -1|0|1       ) (R: n i )
         *    ?if
         *       2nip unloop exit                  ( w -1|1                    )
         *    then                                 ( c-addr u 0 0              ) (R: n i )
         *    2drop                                ( c-addr u                  ) (R: n i )
         * loop                                    ( c-addr u                  )
         * 2drop 0 0                               ( 0 0                       )
         */
        searchorder_n, fetch, zero,
        _q_do_, T(14+SZ/SZt),
            two_dup, i, searchorder_i, fetch,
            _call_, WADDR(wordlist_find),
            _q_if_, T(4),
                two_nip, unloop, exit,
            then,
            two_drop,
        _loop_, T(-14-SZ/SZt),
        two_drop, zero, zero, exit
    )
WORD_END(string_to_word)
WORD(to_token,         string_to_word, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_plus,       to_token,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(tokens,           token_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_store,      tokens,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(token_fetch,      token_store,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD_START(user_var,   token_fetch)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS | M4FLAG_CONSUMES_IP_2)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(user_var, T(-1), exit)
WORD_END(user_var)
WORD_START(word_inline_query,  user_var)
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
/* wordlist-find ( c-addr u wid -- w|0 -1|0|1 ) search word name in wordlist */
WORD_START(wordlist_find, word_to_xt)
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* wordlist-last                                       ( addr u w          )
         * begin
         *    ?if0                                             ( addr u 0          )
         *       nip nip 0 exit                                ( 0 0               )
         *    then                                             ( addr u w          )
         *    dup >r word>name                                 ( addr u addr' u'   ) (R: w  )
         *    rot tuck                                         ( addr addr' u u' u ) (R: w  )
         *    = if                                             ( addr addr' u      ) (R: w  )
         *       string<> while                                ( addr addr' u      ) (R: w  )
         *    then                                             ( addr addr' u      ) (R: w  )
         *    nip r> word>prev                                 ( addr u     w'     )
         * repeat
         * 2drop drop r> dup                                   ( w w               )
         * word>flags M4FLAG_IMMEDIATE and 0=                  ( w t|f             )
         * 2* 1+ exit                                          ( w -1|1            )
         */
        wordlist_last,
        begin,
            _q_if_zero_, T(5),
                nip, nip, zero, exit,
            then,
            dup, to_r, word_to_name,
            rot, tuck,
            equal, _if_, T(4),
                string_equal, _while_zero_, T(6),
            then,
            nip, r_from, word_to_prev,
        _repeat_, T(-24),
        two_drop, drop, r_from, dup,
        word_to_flags, _lit_, T(M4FLAG_IMMEDIATE), and, zero_equal,
        two_times, one_plus, exit
    )
WORD_END(wordlist_find)
WORD(wordlist_last,  wordlist_find,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(xt_to_word,     wordlist_last,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)

DICT_BODY(m4th_core, xt_to_word)
DICT_END(m4th_core)
