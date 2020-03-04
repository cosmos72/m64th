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
/* ( io -- err ) read and skip blanks from iobuf, refilling as needed */
WORD_START(ibuf_read_blanks, always_eof)
    WORD_FLAGS(0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* begin                                       ( io           )
         *    dup iobuf-skip-blanks                    ( io           )
         *    dup iobuf>data nip                       ( io len       )
         *    if                                       ( io           )
         *       drop 0 exit                           ( 0            )
         *    then                                     ( io           )
         *    dup iobuf-refill                         ( io err       )
         *    ?if                                      ( io err       )
         *       nip exit         ( may be eof )       ( err          )
         *    then                                     ( io err       )
         *    drop                                     ( io           )
         * again                                       ( io           )
         */
        begin,
            dup, _call_, WADDR(ibuf_skip_blanks),
            dup, iobuf_data, nip,
            _if_, T(4),
                drop, zero, exit,
            then,
            dup, _call_, WADDR(ibuf_refill),
            _q_if_, T(3),
                nip, exit,
            then,
            drop,
        _again_, T(-21-2*SZ/SZt)
    )
WORD_END(ibuf_read_blanks)
/* ( io -- c-addr u ) read blank-delimited string from iobuf, refilling as needed */
WORD_START(ibuf_read_nonblanks, ibuf_read_blanks)
    WORD_FLAGS(0)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /*
         * dup dup iobuf-read-blanks 2>r             ( io            ) (R: io err )
         * iobuf>data                                ( addr u        ) (R: io err )
         * begin                                     ( addr u        ) (R: io err )
         *    2dup string-first-blank                ( addr u u'     ) (R: io err )
         *    tuck = while                           ( addr u'       ) (R: io err )
         *    dup $ff < while    ( max name length ) ( addr u        ) (R: io err )
         *    r@ while0          ( I/O err ?       ) ( addr u        ) (R: io err )
         *    2drop i'                               ( io            ) (R: io err )
         *    iobuf-refill       ( also moves data ) ( err'          ) (R: io err )
         *    r!                                     (               ) (R: io err')
         *    i' iobuf>data                          ( addr u        ) (R: io err )
         * ?until0                                   ( addr u        ) (R: io err )
         * dup i' iobuf>pos                          ( addr u u pos  ) (R: io err )
         * +!                                        ( addr u        ) (R: io err )
         * 2r> 2drop                                 ( addr u        )
         */
        dup, dup, _call_, WADDR(ibuf_read_blanks), two_to_r,
        iobuf_data,
        begin,
            two_dup, string_first_blank,
            tuck, equal, _while_, T(17+SZ/SZt),
            dup, _lit_, T(0xff), less, _while_, T(11+SZ/SZt),
            r_fetch, _while_zero_, T(8+SZ/SZt),
            two_drop, i_prime,
            _call_, WADDR(ibuf_refill),
            r_store,
            i_prime, iobuf_data,
        _q_until_zero_, T(-23-SZ/SZt),
        dup, i_prime, iobuf_pos,
        plus_store,
        two_r_from_two_drop, exit
    )
WORD_END(ibuf_read_nonblanks)
/* iobuf-refill ( io -- err ) read some chars into iobuf */
WORD_START(ibuf_refill, ibuf_read_nonblanks)
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
         *    negate over iobuf>size +!             ( io                    )
         *    0 over iobuf>pos !                    ( io                    )
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
        _q_if_, T(17),
            over, dup, iobuf_data,
            rot, iobuf_addr, swap,
            cmove,
            negate, over, iobuf_size, plus_store,
            zero, over, iobuf_pos, store,
        _else_, T(2),
            drop,
        then,
        dup, iobuf_handle, fetch, over, dup,
        iobuf_free_data, rot,
        iobuf_func, fetch, execute,
        flip, iobuf_size,
        plus_store, exit
    )
WORD_END(ibuf_refill)
/* ( io -- ) skip blanks from iobuf current data */
WORD_START(ibuf_skip_blanks, ibuf_refill)
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
WORD_END(ibuf_skip_blanks)
WORD(in_to_ibuf,    ibuf_skip_blanks, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_addr,       in_to_ibuf,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_all_data,   iobuf_addr,     DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_data,       iobuf_all_data, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_free_data,  iobuf_data,     DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_func,      iobuf_free_data, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_handle,     iobuf_handle,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_max,        iobuf_func,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_pos,        iobuf_max,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_size,       iobuf_pos,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(m4th_ex,          iobuf_size,     DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* obuf-flush ( io -- err ) flush iobuf data */
WORD_START(obuf_flush, m4th_ex)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* >r                                       (                    ) (R: io )
         * begin                                    (                    ) (R: io )
         *    r@ iobuf>data                         ( c-addr u           ) (R: io )
         *    ?if0                                  ( c-addr u           ) (R: io )
         *       0 r@ iobuf>pos !                   ( c-addr 0           ) (R: io )
         *       0 r@ iobuf>size !                  ( c-addr 0           ) (R: io )
         *       nip break                          ( 0                  ) (R: io )
         *    then                                  ( c-addr u           ) (R: io )
         *    r@ iobuf>handle @ -rot                ( handle c-addr u    ) (R: io )
         *    r@ iobuf>func @ execute               ( u' err             ) (R: io )
         *    swap r@ iobuf>pos +!                  ( err                ) (R: io )
         *    ?dup                                  ( err err | 0        ) (R: io )
         * until                                    ( err                ) (R: io )
         * r> drop                                  ( err                )
         */
        to_r,
        begin,
            r_fetch, iobuf_data,
            _q_if_zero_, T(12),
                zero, r_fetch, iobuf_pos, store,
                zero, r_fetch, iobuf_size, store,
                nip, _break_, T(16),
            then,
            r_fetch, iobuf_handle, fetch, minus_rot,
            r_fetch, iobuf_func, fetch, execute,
            swap, r_fetch, iobuf_pos, plus_store,
            question_dup,
        _until_, T(-31),
        r_from_drop, exit
    )
WORD_END(obuf_flush)
/* (obuf-flush-write-char) ( io c -- err  ) flush iobuf, then write one char to it */
WORD_START(_obuf_flush_write_char_, obuf_flush)
    WORD_FLAGS(0)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* over iobuf-flush                            ( io c err     )
         * ?if                                         ( io c err     )
         *    nip nip exit                             ( err          )
         * then                                        ( io c err     )
         * drop                                        ( io c         )
         * over iobuf>free-data drop                   ( io c c-addr  )
         * c!                                          ( io           )
         * 1 swap iobuf>size                           ( 1 size-addr  )
         * +! 0                                        ( 0            )
         */
        over, _call_, WADDR(obuf_flush),
        _q_if_, T(4),
            nip, r_from_drop, exit,
        then,
        drop,
        over, iobuf_free_data, drop,
        c_store,
        one, swap, iobuf_size,
        plus_store, zero, exit
    )
WORD_END(_obuf_flush_write_char_)
/* (obuf-flush-write-string) ( io c-addr u -- err  ) flush iobuf, then write string to it */
WORD_START(_obuf_flush_write_string_, _obuf_flush_write_char_)
    WORD_FLAGS(0)
    WORD_DSTACK(3,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* rot dup obuf-flush                         ( c-addr u io err )
         * ?if                                         ( c-addr u io err )
         *    2nip nip exit                            ( err             )
         * then                                        ( c-addr u io err )
         * drop dup >r                                 ( c-addr u io              ) (R: io )
         * iobuf>free-data dup                         ( c-addr u c-addr' u' u'   ) (R: io )
         * 2over drop                                  ( c-addr u c-addr' u' u' u ) (R: io )
         * <                                           ( c-addr u c-addr' u' t|f  ) (R: io )
         * if        ( string does not fit free data ) ( c-addr u c-addr' u'      ) (R: io )
         *    2drop r> -rot                            ( io c-addr u     )
         *    obuf-overflow                            ( c-addr' u' err  )
         *    nip nip exit                             ( err             )
         * then      ( string fits free data )         ( c-addr u c-addr' u'      ) (R: io )
         * drop swap dup >r                            ( c-addr c-addr' u         ) (R: io u )
         * cmove r> r>                                 ( u io                     )
         * iobuf>size +! 0                             ( 0                        )
         */
        rot, dup, _call_, WADDR(obuf_flush),
        _q_if_, T(4),
            two_nip, nip, exit,
        then,
        drop, dup, to_r,
        iobuf_free_data, dup,
        two_over, drop,
        less,
        _if_, T(8+SZ/SZt),
            two_drop, r_from, minus_rot,
            _call_, WADDR(_obuf_overflow_),
            nip, nip, exit,
        then,
        drop, swap, dup, to_r,
        cmove, r_from, r_from,
        iobuf_size, plus_store, zero, exit
    )
WORD_END(_obuf_flush_write_string_)
/*
 * (obuf-overflow) ( io c-addr u -- c-addr' u' err ) send string to iobuf I/O func,
 * ignoring current data. return string still to write - non-empty only on I/O error
 */
WORD_START(_obuf_overflow_, _obuf_flush_write_string_)
    WORD_FLAGS(0)
    WORD_DSTACK(3,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* rot >r                                   ( c-addr u                 ) (R: io )
         * begin                                    ( c-addr u                 ) (R: io )
         *    ?while                                ( c-addr u                 ) (R: io )
         *    2dup                                  ( c-addr u c-addr u        ) (R: io )
         *    r@ iobuf>handle @ -rot                ( c-addr u handle c-addr u ) (R: io )
         *    r@ iobuf>func @ execute               ( c-addr u u' err          ) (R: io )
         *    >r /string                            ( c-addr' u'               ) (R: io err )
         *    r>                                    ( c-addr u err             ) (R: io )
         *    ?if                                   ( c-addr u err             ) (R: io )
         *       r> drop exit                       ( c-addr u err             )
         *    then                                  ( c-addr u err             ) (R: io )
         *    drop                                  ( c-addr u                 ) (R: io )
         * repeat                                   ( c-addr u                 ) (R: io )
         * r> drop 0                                ( c-addr u 0               )
         */
        rot, to_r,
        begin,
            _q_while_, T(20),
            two_dup,
            r_fetch, iobuf_handle, fetch, minus_rot,
            r_fetch, iobuf_func, fetch, execute,
            to_r, div_string,
            r_from,
            _q_if_, T(3),
                r_from_drop, exit,
            then,
            drop,
        _repeat_, T(-22),
        r_from_drop, zero, exit
    )
WORD_END(_obuf_overflow_)
/* obuf-write-char ( io c-addr u -- err  ) write one char to iobuf */
WORD_START(obuf_write_char, _obuf_overflow_)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH | M4FLAG_MEM_STORE)
    WORD_DSTACK(3,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* cannot inline in native code: has multiple returns + uses ip-relative JUMP */
    WORD_CODE(obuf_write_char, exit)
WORD_END(obuf_write_char)
/* obuf-write-string ( io c-addr u -- err  ) write a string to iobuf */
WORD_START(obuf_write_string, obuf_write_char)
    WORD_FLAGS(0)
    WORD_DSTACK(3,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* TODO */
        exit
    )
WORD_END(obuf_write_string)
WORD(out_to_obuf,   obuf_write_string, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* searchorder-i ( -- addr ) get address of ith wordlist in searchorder */
WORD(searchorder_i,    out_to_obuf,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
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
