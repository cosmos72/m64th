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
#include "../include/err.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-core -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_core)

DICTNAME(9, "m4th-core", m4th_core)

DICT_WORDS_M4TH_CORE(WORDNAME)

WORD(div_token,        div_token,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* always-eof ( handle c-addr u -- 0 M4ERR_UNEXPECTED_EOF ) always return EOF. usable for iobuf>func */
WORD_START(always_eof, div_token)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_PURE)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(two_drop, drop, zero, _lit_, T(M4ERR_UNEXPECTED_EOF), exit)
WORD_END(always_eof)
WORD(m4th_err,         always_eof,     DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(in_to_iobuf,      m4th_err,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_addr,       in_to_iobuf,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_all_data,   iobuf_addr,     DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_data,       iobuf_all_data, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_free_data,  iobuf_data,     DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_func,      iobuf_free_data, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_handle,     iobuf_handle,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_max,        iobuf_func,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_pos,        iobuf_max,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_size,       iobuf_pos,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* ( io -- ) read and skip blanks from iobuf, refilling as needed */
WORD_START(iobuf_read_blanks, iobuf_size)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* begin                                       ( io           )
         *    dup iobuf-skip-blanks                    ( io           )
         *    dup iobuf>data nip 0=                    ( io t|f       )
         *    while                                    ( io           )
         *    dup iobuf-refill                         ( io err       )
         *    ?if                                      ( io err       )
         *       m4th>err ! break                      ( io           )
         *    then
         * repeat                                      ( io           )
         * drop                                        (              )
         */
        begin,
            dup, _call_, WADDR(iobuf_skip_blanks),
            dup, iobuf_data, nip,
            _while_zero_, T(11+SZ/SZt),
            dup, _call_, WADDR(iobuf_refill),
            _q_if_, T(5),
                m4th_err, store, _break_, T(3),
            then,
        _repeat_, T(-18-2*SZ/SZt),
        drop, exit
    )
WORD_END(iobuf_read_blanks)
/* ( io -- c-addr u ) read blank-delimited string from iobuf. TODO: refill */
WORD_START(iobuf_read_nonblanks, interpret)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /*
         * dup iobuf-read-blanks                     ( io                  )
         * dup iobuf>data bounds                     ( io end addr         )
         * tuck                                      ( io addr end addr    )
         * 0 -rot                                    ( io addr 0 end addr  )
         * ?do                                       ( io addr u           ) (R: end addr-i )
         *   i c@ bl <=                              ( io addr u t|f       ) (R: end addr-i )
         *   if                                      ( io addr u           ) (R: end addr-i )
         *     leave                                 ( io addr u           )
         *   then                                    ( io addr u           ) (R: end addr-i )
         *   1+                                      ( io addr u'          ) (R: end addr-i )
         * loop            ( better: 1 chars +loop ) ( io addr u           )
         * rot trail iobuf>pos                       ( addr u u pos        )
         * +!                                        ( addr u              )
         */
        dup, _call_, WADDR(iobuf_read_blanks),
        dup, iobuf_data, bounds,
        tuck,
        zero, minus_rot,
        _q_do_, T(12),
            i, c_fetch, bl, less_equal,
            _if_, T(3),
                _leave_, T(4),
            then,
            one_plus,
        _loop_, T(-12),
        rot, trail, iobuf_pos,
        plus_store, exit
    )
WORD_END(iobuf_read_nonblanks)
/* iobuf-refill ( io -- err ) read some chars into iobuf */
WORD_START(iobuf_refill, iobuf_read_blanks)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* dup iobuf>pos @                          ( io pos                )
         * ?if                                      ( io pos                )
         *    over dup iobuf>data                   ( io pos io c-addr u    )
         *    rot iobuf>addr swap                   ( io pos c-addr addr0 u )
         *    cmove                                 ( io pos                )
         *    negate iobuf>size +!                  ( io                    )
         *    0 iobuf>pos !                         ( io                    )
         * else
         *    drop
         * then                                     ( io                      )
         * dup iobuf>handle @ over dup              ( io handle io io         )
         * iobuf>free-data rot                      ( io handle addr u io     )
         * iobuf>func @ execute                     ( io u' err               )
         * flip iobuf>size                          ( err u' size-addr        )
         * +!                                       ( err                     )
         */
        dup, iobuf_pos, fetch,
        _q_if_, T(15),
            over, dup, iobuf_data,
            rot, iobuf_addr, swap,
            cmove,
            negate, iobuf_size, plus_store,
            zero, iobuf_pos, store,
        _else_, T(2),
            drop,
        then,
        dup, iobuf_handle, fetch, over, dup,
        iobuf_free_data, rot,
        iobuf_func, fetch, execute,
        flip, iobuf_size,
        plus_store, exit
    )
WORD_END(iobuf_refill)
/* ( io -- ) skip blanks from iobuf current data */
WORD_START(iobuf_skip_blanks, iobuf_read_nonblanks)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* 0 over iobuf>data bounds                    ( io 0 end addr   )
         * ?do                                         ( io u            ) (R: end addr-i )
         *    i c@ bl >                                ( io u t|f        ) (R: end addr-i )
         *    if                                       ( io u            ) (R: end addr-i )
         *       leave                                 ( io u            )
         *    then                                     ( io u            ) (R: end addr-i )
         *    one_plus,                                ( io u'           ) (R: end addr-i )
         * loop              ( better: 1 chars +loop ) ( io u            )
         * swap iobuf>pos                              ( u pos           )
         * +!
         */
        zero, over, iobuf_data, bounds,
        _q_do_, T(12),
            i, c_fetch, bl, more,
            _if_, T(2),
                _leave_, T(4),
            then,
            one_plus,
        _loop_, T(-12),
        swap, iobuf_pos,
        plus_store, exit
    )
WORD_END(iobuf_skip_blanks)
/* searchorder-i ( -- addr ) get address of ith wordlist in searchorder */
WORD(searchorder_i,    iobuf_refill,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
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
/**
 * wordlist-find ( c-addr u wid -- w|0 -1|0|1 ) search word name in wordlist.
 * return 0 if not found. return 1 if word is immediate, otherwise return -1
 */
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
         *       string-ci<> while                             ( addr addr' u      ) (R: w  )
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
                string_ci_equal, _while_zero_, T(6),
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
