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
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_PURE)
    WORD_CODE(two_drop, drop, zero, _lit_, T(M4ERR_UNEXPECTED_EOF), exit)
WORD_END(always_eof)
/* compile-string, ( c-addr u -- ) runtime effect: ( -- c-addr' u ) */
WORD_START(compile_string_comma, always_eof)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* dup dup >token <>                           ( c-addr u t|f       )
         * if                                          ( c-addr u           )
         *   M4ERR_DEFINITION_NAME_TOO_LONG throw      (                    )
         * then                                        ( c-addr u           )
         * ' (lit-string) token,                       ( c-addr u           )
         * dup token,                                  ( c-addr u           )
         * here swap                                   ( c-addr here u      )
         * cmove                                       (                    )
         * token-aligned                               (                    )
         */
        /* TODO */
        exit
    )
WORD_END(compile_string_comma)
/**
 * ibuf-delimited-line ( io ch -- c-addr u ) get string before ch in current iobuf line,
 * without refilling and stopping before any CR
 */
WORD_START(ibuf_delimited_line, compile_string_comma)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /*
         * 2dup 2>r drop iobuf>data r@ line-find-char  ( u            ) (R: io ch  )
         * i' iobuf>data rot tuck                      ( addr u u' u  ) (R: io ch  )
         * >                                           ( addr u t|f   ) (R: io ch  )
         * if                                          ( addr u       ) (R: io ch  )
         *    2dup chars + c@                          ( addr u ch'   ) (R: io ch  )
         *    trail r> =                               ( addr u u t|f ) (R: io     )
         *    negate +                                 ( addr u u'    ) (R: io     )
         * else                                        ( addr u u     ) (R: io ch  )
         *    dup r> drop                              ( addr u u     ) (R: io     )
         * then                                        ( addr u u     ) (R: io     )
         * r> iobuf>pos +!                             ( addr u       )
         */
        two_dup_two_to_r, drop, iobuf_data, r_fetch, line_find_char,
        i_prime, iobuf_data, rot, tuck,
        more,
        _if_, T(11),
            two_dup, chars, plus, c_fetch,
            trail, r_from, equal,
            negate, plus,
        _else_, T(3),
            dup, r_from_drop,
        then,
        r_from, iobuf_pos, plus_store, exit
    )
WORD_END(ibuf_delimited_line)
/**
 * ibuf-nonblank-line ( io -- c-addr u ) find first non-blank string in current iobuf line,
 * without refilling and stopping before any CR
 */
WORD_START(ibuf_nonblank_line, ibuf_delimited_line)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /*
         * dup ibuf-skip-blanks-except-cr            ( io t|f        )
         * if                                        ( io            )
         *    drop 0 0                               ( 0 0           )
         * else                                      ( io            )
         *    dup >r iobuf>data                      ( addr u        ) (R: io     )
         *    trail string-first-blank               ( addr u'       ) (R: io     )
         *    dup r@ iobuf>pos                       ( addr u u pos  ) (R: io     )
         *    +!                                     ( addr u        ) (R: io     )
         *    r> drop                                ( addr u        )
         * then                                      ( addr u        )
         */
        dup, CALL(ibuf_skip_blanks_except_cr),
        _if_, T(5),
            drop, zero, zero,
        _else_, T(10),
            dup_to_r, iobuf_data,
            trail, string_first_blank,
            dup, r_fetch, iobuf_pos,
            plus_store,
            r_from_drop,
        then, exit
    )
WORD_END(ibuf_nonblank_line)
/* ibuf-refill ( io -- err ) read some chars into iobuf */
WORD_START(ibuf_refill, ibuf_nonblank_line)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* dup >r iobuf>pos @                       ( pos                ) (R: io )
         * ?if                                      ( pos                ) (R: io )
         *    r@ iobuf>data                         ( pos c-addr u       ) (R: io )
         *    r@ iobuf>addr swap                    ( pos c-addr addr0 u ) (R: io )
         *    cmove                                 ( pos                ) (R: io )
         *    negate r@ iobuf>size +!               (                    ) (R: io )
         *    0 r@ iobuf>pos !                      (                    ) (R: io )
         * else
         *    drop                                  (                    ) (R: io )
         * then                                     (                    ) (R: io )
         * r@ iobuf>handle @                        ( handle             ) (R: io )
         * r@ iobuf>free-data                       ( handle addr u      ) (R: io )
         * r@ iobuf>func @ execute                  ( u' err             ) (R: io )
         * tuck                                     ( err u' err         ) (R: io )
         * r@ iobuf>err !                           ( err u'             ) (R: io )
         * r> iobuf>size                            ( err u' size-addr   )
         * +!                                       ( err                )
         */
        dup_to_r, iobuf_pos, fetch,
        _q_if_, T(16),
            r_fetch, iobuf_data,
            r_fetch, iobuf_addr, swap,
            cmove,
            negate, r_fetch, iobuf_size, plus_store,
            zero, r_fetch, iobuf_pos, store,
        _else_, T(2),
            drop,
        then,
        r_fetch, iobuf_handle, fetch,
        r_fetch, iobuf_free_data,
        r_fetch, iobuf_func, fetch, execute,
        tuck,
        r_fetch, iobuf_err, store,
        r_from, iobuf_size,
        plus_store, exit
    )
WORD_END(ibuf_refill)
/* ibuf-refill-if-empty ( io -- err ) read some chars into iobuf if it's empty */
WORD_START(ibuf_refill_if_empty, ibuf_refill)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* dup iobuf-empty?                         ( io t|f             )
         * if                                       ( io                 )
         *    ibuf-refill                           ( err                )
         * else                                     ( io                 )
         *    drop 0                                ( 0                  )
         * then                                     ( err | 0            )
         */
        dup, iobuf_empty_query,
        _if_, T(3+nCALLt),
            CALL(ibuf_refill),
        _else_, T(3),
            drop, zero,
        then, exit
    )
WORD_END(ibuf_refill_if_empty)
/* ( io -- ) skip blanks i.e. chars <= ' ' from iobuf current data. does not refill. */
WORD_START(ibuf_skip_blanks, ibuf_refill_if_empty)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* 0 over iobuf>data bounds                    ( io 0 end addr   )
         * ?do                                         ( io u            ) (R: end addr-i )
         *    i c@ bl >                                ( io u t|f        ) (R: end addr-i )
         *    if                                       ( io u            ) (R: end addr-i )
         *       leave                                 ( io u            )
         *    then                                     ( io u            ) (R: end addr-i )
         *    1+                                       ( io u'           ) (R: end addr-i )
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
/* ( io -- t|f ) skip blanks until end of line. true if found end of line.
   does not refill, and does not skip CR
 */
WORD_START(ibuf_skip_blanks_except_cr, ibuf_skip_blanks)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* 0 over trail iobuf>data bounds              ( io 0 0 end addr )
         * ?do                                         ( io u f          ) (R: end addr-i )
         *    drop i c@ bl >                           ( io u t|f        ) (R: end addr-i )
         *    if                                       ( io u            ) (R: end addr-i )
         *       false leave                           ( io u f          )
         *    then                                     ( io u            ) (R: end addr-i )
         *    i c@ 10 =                   ( LF is 10 ) ( io u t|f        ) (R: end addr-i )
         *    i c@ 13 = or                ( CR ir 13 ) ( io u t|f        ) (R: end addr-i )
         *    if                                       ( io u            ) (R: end addr-i )
         *       true leave                            ( io u t          )
         *    then                                     ( io u            ) (R: end addr-i )
         *    1+ false                                 ( io u' f         ) (R: end addr-i )
         * loop              ( better: 1 chars +loop ) ( io u t|f        )
         * flip iobuf>pos                              ( t|f u pos       )
         * +!                                          ( t|f             )
         */
        zero, over, trail, iobuf_data, bounds,
        _q_do_, T(32),
            drop, i, c_fetch, bl, more,
            _if_, T(4),
                false, _leave_, T(22),
            then,
            i, c_fetch, _lit_, T(10), equal,
            i, c_fetch, _lit_, T(13), equal, or,
            _if_, T(4),
                true, _leave_, T(5),
            then,
            one_plus, false,
        _loop_, T(-32),
        flip, iobuf_pos,
        plus_store, exit
    )
WORD_END(ibuf_skip_blanks_except_cr)
/* ( io -- t|f ) skip blanks until end of line. true if found end of line.
   does not refill. Also skips CR if found.
 */
WORD_START(ibuf_skip_blanks_until_cr, ibuf_skip_blanks_except_cr)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* dup ibuf-skip-blanks-except-cr              ( io t|f        )
         * ?if                                         ( io t          )
         *    1 rot iobuf-pos                          ( t 1 addr      )
         *    +!                                       ( t             )
         * else                                        ( io f          )
         *    nip                                      ( f             )
         * then
         */
        dup, CALL(ibuf_skip_blanks_except_cr),
        _q_if_, T(6),
            one, rot, iobuf_pos,
            plus_store,
        _else_, T(2),
            nip,
        then, exit
    )
WORD_END(ibuf_skip_blanks_until_cr)
WORD(in_to_ibuf,ibuf_skip_blanks_until_cr,DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_addr,       in_to_ibuf,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_all_data,   iobuf_addr,     DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_data,       iobuf_all_data, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_data_n,     iobuf_data,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_free_data,  iobuf_data_n,   DSTACK(1,2), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_empty_query,iobuf_free_data,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_err,     iobuf_empty_query, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_func,       iobuf_err,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_handle,     iobuf_handle,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_max,        iobuf_func,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(iobuf_pos,        iobuf_max,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(iobuf_size,       iobuf_pos,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(latest,           iobuf_size,     DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( c-addr u -- nt ) create a new name. do NOT add it to compilation wordlist */
WORD_START(name_comma,  latest)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses IP-relative jump to m4func, cannot inline in native code */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(name_comma, exit)
WORD_END(name_comma)
WORD_START(name_inline_query,  name_comma)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_CODE(
        dup, name_to_flags,
        dup, _lit2s_, SHORT(M4FLAG_INLINE_ALWAYS), and, _if_, T(4),
            two_drop, true, exit,
        then,
        _lit2s_, SHORT(M4FLAG_INLINE), and, _if0_, T(4),
            drop, false, exit,
        then,
        name_to_code_n, eight, less, exit
    )
WORD_END(name_inline_query)
WORD(name_to_code,  name_inline_query, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(name_to_code_n,   name_to_code,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(name_to_flags,    name_to_code_n, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(name_to_prev,     name_to_flags,  DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(name_to_xt,       name_to_prev,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
/* obuf-flush ( io -- err ) flush iobuf data */
WORD_START(obuf_flush, name_to_xt)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* >r                                       (                    ) (R: io )
         * begin                                    (                    ) (R: io )
         *    r@ iobuf>data                         ( c-addr u           ) (R: io )
         *    ?if0                                  ( c-addr u           ) (R: io )
         *       0 r@ iobuf>pos !                   ( c-addr 0           ) (R: io )
         *       0 r@ iobuf>size !                  ( c-addr 0           ) (R: io )
         *       nip r> drop exit                   ( 0                  )
         *    then                                  ( c-addr u           ) (R: io )
         *    r@ iobuf>handle @ -rot                ( handle c-addr u    ) (R: io )
         *    r@ iobuf>func @ execute               ( u' err             ) (R: io )
         *    swap r@ iobuf>pos +!                  ( err                ) (R: io )
         *    ?dup                                  ( err err | 0        ) (R: io )
         * until                                    ( err                ) (R: io )
         * dup r> iobuf>err                         ( err err addr       )
         * !                                        ( err                )
         */
        to_r,
        begin,
            r_fetch, iobuf_data,
            _q_if0_, T(12),
                zero, r_fetch, iobuf_pos, store,
                zero, r_fetch, iobuf_size, store,
                nip, r_from_drop, exit,
            then,
            r_fetch, iobuf_handle, fetch, minus_rot,
            r_fetch, iobuf_func, fetch, execute,
            swap, r_fetch, iobuf_pos, plus_store,
            question_dup,
        _until_, T(-31),
        dup, r_from, iobuf_err,
        store, exit
    )
WORD_END(obuf_flush)
/* (obuf-flush-write-char) ( io c -- err  ) flush iobuf, then write one char to it */
WORD_START(_obuf_flush_write_char_, obuf_flush)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
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
        over, CALL(obuf_flush),
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
    WORD_DSTACK(3,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
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
        rot, dup, CALL(obuf_flush),
        _q_if_, T(4),
            two_nip, nip, exit,
        then,
        drop, dup, to_r,
        iobuf_free_data, dup,
        two_over, drop,
        less,
        _if_, T(8+nCALLt),
            two_drop, r_from, minus_rot,
            CALL(_obuf_overflow_),
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
    WORD_DSTACK(3,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
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
         *       dup r> iobuf>err                   ( c-addr u err err addr    )
         *       ! exit                             ( c-addr u err             )
         *    then                                  ( c-addr u err             ) (R: io )
         *    drop                                  ( c-addr u                 ) (R: io )
         * repeat                                   ( c-addr u                 ) (R: io )
         * r> drop 0                                ( c-addr u 0               )
         */
        rot, to_r,
        begin,
            _q_while_, T(23),
            two_dup,
            r_fetch, iobuf_handle, fetch, minus_rot,
            r_fetch, iobuf_func, fetch, execute,
            to_r, div_string,
            r_from,
            _q_if_, T(6),
                dup, r_from, iobuf_err,
                store, exit,
            then,
            drop,
        _repeat_, T(-25),
        r_from_drop, zero, exit
    )
WORD_END(_obuf_overflow_)
/* obuf-write-char ( io c-addr u -- err  ) write one char to iobuf */
WORD_START(obuf_write_char, _obuf_overflow_)
    WORD_DSTACK(3,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* cannot inline in native code: has multiple returns + uses ip-relative JUMP */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH | M4FLAG_MEM_STORE)
    WORD_CODE(obuf_write_char, exit)
WORD_END(obuf_write_char)
/* obuf-write-string ( io c-addr u -- err  ) write a string to iobuf */
WORD_START(obuf_write_string, obuf_write_char)
    WORD_DSTACK(3,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        obuf_write_string, exit
    )
WORD_END(obuf_write_string)
WORD(out_to_obuf,   obuf_write_string, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* searchorder-i ( -- addr ) get address of ith wordlist in searchorder */
WORD(searchorder_i,    out_to_obuf,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
/* searchorder-n ( -- addr ) get address of searchorder count */
WORD(searchorder_n,    searchorder_i,  DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(set_latest,       searchorder_n,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
/*
 * string>name ( c-addr u -- nt|0 -1|0|1 ) find name in current search order.
 * return 1 if name is immediate, else -1
 */
WORD_START(string_to_name, set_latest)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
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
        _q_do_, T(14+nCALLt),
            two_dup, i, searchorder_i, fetch,
            CALL(wordlist_find),
            _q_if_, T(4),
                two_nip, unloop, exit,
            then,
            two_drop,
        _loop_, T(-14-nCALLt),
        two_drop, zero, zero, exit
    )
WORD_END(string_to_name)
WORD(to_token,         string_to_name, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_plus,       to_token,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(tokens,           token_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_store,      tokens,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(token_fetch,      token_store,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(token_align,      token_store,    DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(token_aligned,    token_align,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD_START(user_var,   token_aligned)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS | M4FLAG_CONSUMES_IP_2)
    WORD_CODE(user_var, T(-1), exit)
WORD_END(user_var)
/**
 * wordlist-find ( c-addr u wid -- w|0 -1|0|1 ) search word name in wordlist.
 * return 0 if not found. return 1 if word is immediate, otherwise return -1
 */
WORD_START(wordlist_find, user_var)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_CODE(
        /* wordlist-last                                       ( addr u nt         )
         * begin
         *    ?if0                                             ( addr u 0          )
         *       nip nip 0 exit                                ( 0 0               )
         *    then                                             ( addr u nt         )
         *    dup >r name>string                               ( addr u addr' u'   ) (R: w  )
         *    rot tuck                                         ( addr addr' u u' u ) (R: w  )
         *    = if                                             ( addr addr' u      ) (R: w  )
         *       string-ci<> while                             ( addr addr' u      ) (R: w  )
         *    then                                             ( addr addr' u      ) (R: w  )
         *    nip r> name>prev                                 ( addr u     nt'    )
         * repeat
         * 2drop drop r> dup                                   ( nt nt             )
         * name>flags M4FLAG_IMMEDIATE and 0=                  ( nt t|f            )
         * 2* 1+ exit                                          ( nt -1|1           )
         */
        wordlist_last,
        begin,
            _q_if0_, T(5),
                nip, nip, zero, exit,
            then,
            dup, to_r, name_to_string,
            rot, tuck,
            equal, _if_, T(4),
                string_ci_equal, _while0_, T(6),
            then,
            nip, r_from, name_to_prev,
        _repeat_, T(-24),
        two_drop, drop, r_from, dup,
        name_to_flags, _lit_, T(M4FLAG_IMMEDIATE), and, zero_equal,
        two_times, one_plus, exit
    )
WORD_END(wordlist_find)
WORD(wordlist_add,   wordlist_find,    DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH | M4FLAG_MEM_STORE)
WORD(wordlist_last,  wordlist_add,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(wordlist_reset, wordlist_last,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(xt_to_name,     wordlist_reset,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)

DICT_BODY(m4th_core, xt_to_name)
DICT_END(m4th_core)
