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

#include "../../include/asm.mh"
#include "../../include/dict.mh"
#include "../../include/err.mh"
#include "../../include/m4th/dict.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-core -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

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
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_COMPILE_ONLY)
    WORD_CODE(
        /* dup dup >token <>                           ( c-addr u t|f       )
         * M4ERR_DEFINITION_NAME_TOO_LONG and throw    ( c-addr u           )
         * ' (lit-string) token,                       ( c-addr u           )
         * dup token,                                  ( c-addr u           )
         * here swap                                   ( c-addr here u      )
         * dup allot token-align       ( update HERE ) ( c-addr here u      )
         * cmove                                       (                    )
         */
        dup, dup, to_token, ne,
        _lit_, T(M4ERR_DEFINITION_NAME_TOO_LONG), and, throw,
        _lit_comma_, _lit_string_,
        dup, token_comma,
        here, swap,
        dup, allot, token_align,
        cmove, exit
    )
WORD_END(compile_string_comma)
/* ( -- ) if compiling, forget latest word, discard compilation stack, */
/* skip until end of input line. also unconditionally stops compiling */
WORD_START(compiler_abort, compile_string_comma)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        state, fetch, zero_ne,                             /* ( t|f                    ) */
        zero, state, store,  /* set interpretation state      ( t|f                    ) */
        latest, and,                                       /* ( nt|0                   ) */
        _q_if0_, T(3),                                     /* ( 0                      ) */
            /* no word being compiled */                   /* ( 0                      ) */
            drop, exit,                                    /* (                        ) */
        then,                                              /* ( nt                     ) */
        dup, name_to_string, drop,                         /* ( nt c-addr|0            ) */
        _q_if_, T(4),                                      /* ( nt c-addr              ) */
            nip, one_minus,                                /* ( &countedstring         ) */
        _else_, T(2),                                      /* ( nt 0                   ) */
            /* unnamed word */                             /* ( nt 0                   ) */
            drop,                                          /* ( nt                     ) */
        then,                                              /* ( addr                   ) */
        here, minus,                                       /* ( negative_offset_bytes  ) */
        allot,                                             /* (                        ) */
        /* discard compilation stack */                    /* (                        ) */
        begin,                                             /* ( sys*                   ) */
            depth,                                         /* ( sys* u                 ) */
        _while_, T(6),                                     /* ( sys* sys               ) */
            _lit_tok_, colon, equal, nip,                  /* ( sys* t|f               ) */
        _until_, T(-9),                                    /* (                        ) */
        then,                                              /* (                        ) */
        /* skip until end of input line */
        CALL(backslash), exit
    )
WORD_END(compiler_abort)
/* count-tokens ( counted-tokens -- tok-addr u ) */
WORD(count_tokens,     compiler_abort, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE|M4FLAG_MEM_FETCH)
/**
 * compile u tokens. the address counted-tokens contains
 * the number u - which occupies 1 token - followed by u tokens
 * ( counted-tokens|0 -- )
 */
WORD_START(countedtokens_comma,   count_tokens)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        question_dup, _if_, T(2+nCALLt), count_tokens, CALL(tokens_comma), then, exit
    )
WORD_END(countedtokens_comma)
/* flags>consumed-tokens ( flags -- u ) get # consumed tokens from flags */
WORD(flags_to_consumed_tokens, countedtokens_comma, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/**
 * ibuf-find-char ( io ch -- c-addr u ) find ch in iobuf and return string before it.
 * if ch is present, consume it. does not refill.
 */
WORD_START(ibuf_find_char, flags_to_consumed_tokens)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /*
         * 2dup 2>r drop iobuf>data trail r@           ( addr addr u ch   ) (R: io ch  )
         * string-find-char dup                        ( addr u' u'       ) (R: io ch  )
         * r2nd@ iobuf>pos +!                          ( addr u           ) (R: io ch  )
         * r2nd@ iobuf>data                            ( addr u addr' u'  ) (R: io ch  )
         * if0                                         ( addr u addr'     ) (R: io ch  )
         *    drop 2r> 2drop exit                      ( addr u           )
         * then                                        ( addr u addr'     ) (R: io ch  )
         * c@ r> =                                     ( addr u t|f       ) (R: io     )
         * negate                                      ( addr u 1|0       ) (R: io     )
         * r> iobuf>pos +!                             ( addr u           )
         */
        two_dup_two_to_r, drop, iobuf_data, trail, r_fetch,
        string_find_char, dup,
        r2nd_fetch, iobuf_pos, plus_store,
        r2nd_fetch, iobuf_data,
        _if0_, T(4),
            drop, two_r_from_two_drop, exit,
        then,
        c_fetch, r_from, equal,
        negate,
        r_from, iobuf_pos, plus_store, exit
    )
WORD_END(ibuf_find_char)
/**
 * ibuf-find-nonblanks ( io -- c-addr u ) get first non-blank string in current iobuf,
 * without refilling.
 */
WORD_START(ibuf_find_nonblanks, ibuf_find_char)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /*
         * dup >r ibuf-skip-blanks                   (               ) (R: io     )
         * r@ iobuf>data                             ( addr u        ) (R: io     )
         * trail string-find-blank                   ( addr u'       ) (R: io     )
         * dup r@ iobuf>pos                          ( addr u u pos  ) (R: io     )
         * +!                                        ( addr u        ) (R: io     )
         * r> drop                                   ( addr u        )
         */
        dup_to_r, CALL(ibuf_skip_blanks),
        r_fetch, iobuf_data,
        trail, string_find_blank,
        dup, r_fetch, iobuf_pos,
        plus_store,
        r_from_drop, exit
    )
WORD_END(ibuf_find_nonblanks)
/* ibuf-refill ( io -- err ) read some chars into iobuf */
WORD_START(ibuf_refill, ibuf_find_nonblanks)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* dup >r iobuf>pos @                       ( pos                ) (R: io )
         * dup if                                   ( pos                ) (R: io )
         *    r@ iobuf>data                         ( pos c-addr u       ) (R: io )
         *    r@ iobuf>addr swap                    ( pos c-addr addr0 u ) (R: io )
         *    cmove                                 ( pos                ) (R: io )
         *    negate r@ iobuf>end +!                (                    ) (R: io )
         *    0 r@ iobuf>pos !                      (                    ) (R: io )
         * else
         *    drop                                  (                    ) (R: io )
         * then                                     (                    ) (R: io )
         * r@ iobuf>handle @                        ( handle             ) (R: io )
         * r@ iobuf>free-data                       ( handle addr u      ) (R: io )
         * r@ iobuf>func @ execute                  ( u' err             ) (R: io )
         * tuck                                     ( err u' err         ) (R: io )
         * r@ iobuf>err !                           ( err u'             ) (R: io )
         * r> iobuf>end                             ( err u' size-addr   )
         * +!                                       ( err                )
         */
        dup_to_r, iobuf_pos, fetch,
        _q_if_, T(16),
            r_fetch, iobuf_data,
            r_fetch, iobuf_addr, swap,
            cmove,
            negate, r_fetch, iobuf_end, plus_store,
            zero, r_fetch, iobuf_pos, store,
        _else_, T(2),
            drop,
        then,
        r_fetch, iobuf_handle, fetch,
        r_fetch, iobuf_free_data,
        r_fetch, iobuf_func, fetch, execute,
        tuck,
        r_fetch, iobuf_err, store,
        r_from, iobuf_end,
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
/* ( io -- ) skip one blank from ibuf. does not refill. */
WORD_START(ibuf_skip_1blank, ibuf_refill_if_empty)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* dup iobuf>data                              ( io addr u       )
         * if0                                         ( io addr         )
         *    2drop exit                               (                 )
         * then                                        ( io addr         )
         * c@ bl >                                     ( io t|f          )
         * if                                          ( io              )
         *    drop exit                                (                 )
         * then                                        ( io              )
         * 1 swap                                      ( 1 io            )
         * iobuf>pos +!                                (                 )
         */
        dup, iobuf_data,
        _if0_, T(3),
            two_drop, exit,
        then,
        c_fetch, bl, more,
        _if_, T(3),
            drop, exit,
        then,
        one, swap,
        iobuf_pos, plus_store, exit
    )
WORD_END(ibuf_skip_1blank)
/* ( io -- ) skip blanks i.e. chars <= ' ' from iobuf. does not refill. */
WORD_START(ibuf_skip_blanks, ibuf_skip_1blank)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* dup iobuf>data                              ( io c-addr u     )
         * string-find-nonblank                        ( io u'           )
         * swap iobuf>pos                              ( u pos           )
         * +!
         */
        dup, iobuf_data,
        string_find_nonblank,
        swap, iobuf_pos,
        plus_store, exit
    )
WORD_END(ibuf_skip_blanks)
WORD(in_to_ibuf,     ibuf_skip_blanks, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
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
WORD(iobuf_end,        iobuf_pos,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(latest,           iobuf_end,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(to_latest,     latest,         DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
/* ( c-addr u -- nt ) create a new name. do NOT add it to compilation wordlist */
WORD_START(name_comma,  to_latest)
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
WORD(name_to_data,     name_to_code_n, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(name_to_flags,    name_to_data,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(name_to_flags_store,name_to_flags,DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD_START(name_to_ident,  name_to_flags_store)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses %rip-relative TOKEN_CALL_NOTHROW */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_CODE(name_to_ident, exit)
WORD_END(name_to_ident)
WORD(name_to_prev,     name_to_ident,  DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(name_to_xt,       name_to_prev,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
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
         *       0 r@ iobuf>end !                   ( c-addr 0           ) (R: io )
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
                zero, r_fetch, iobuf_end, store,
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
         * 1 swap iobuf>end                           ( 1 size-addr  )
         * +! 0                                        ( 0            )
         */
        over, CALL(obuf_flush),
        _q_if_, T(4),
            nip, r_from_drop, exit,
        then,
        drop,
        over, iobuf_free_data, drop,
        c_store,
        one, swap, iobuf_end,
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
         * iobuf>end +! 0                             ( 0                        )
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
        iobuf_end, plus_store, zero, exit
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
         * ?while                                   ( c-addr u                 ) (R: io )
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
/* parse-nt ( -- nt wid -1|1 ) throws if name is not found. 1 if name is immediate, else -1 */
WORD_START(parse_nt,  out_to_obuf)
    WORD_DSTACK(0,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* parse-name                                  ( c-addr u          )
         * ?if0                                        ( c-addr u          )
         *    M4ERR_ZERO_LENGTH_NAME throw             (                   )
         * then                                        ( c-addr u          )
         * 2dup 2>r                                    ( c-addr u          ) (R: c-addr u )
         * string>name                                 ( nt|0 wid|0 -1|0|1 ) (R: c-addr u )
         * ?if0                     ( word not found ) ( 0 0 0             ) (R: c-addr u )
         *    2r> ex-message!                          ( 0 0 0             )
         *    M4ERR_UNDEFINED_WORD throw               (                   )
         * then                                        ( nt wid -1|1       ) (R: c-addr u )
         * 2r> 2drop                                   ( nt wid -1|1       )
         */
        CALL(parse_name),
        _q_if0_, T(4),
            _lit_, T(M4ERR_ZERO_LENGTH_NAME), throw,
        then,
        two_dup_two_to_r,
        CALL(string_to_name),
        _q_if0_, T(6),
            two_r_from, ex_message_store,
            _lit_, T(M4ERR_UNDEFINED_WORD), throw,
        then,
        two_r_from_two_drop, exit
    )
WORD_END(parse_nt)
/* parse-xt ( -- xt -1|1 ) throws if name is not found. 1 if xt is immediate, else -1 */
WORD_START(parse_xt,  parse_nt)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* parse-nt nip                                ( nt -1|1                   )
         * swap name>xt swap                           ( xt -1|1                   )
         */
        CALL(parse_nt), nip,
        swap, name_to_xt, swap, exit
    )
WORD_END(parse_xt)
/* (S: wid_u-1 .. wid_0 -- )                 */
WORD(searchorder_clear, parse_xt,          DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
/* (S: wid_u-1 .. wid_0 -- same ) ( -- u )   */
WORD(searchorder_depth, searchorder_clear, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* (S: wid -- )                              */
WORD(searchorder_drop,  searchorder_depth, DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
/* (S: wid -- wid wid )                      */
WORD(searchorder_dup,   searchorder_drop,  DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
/* (S: wid_u .. wid_0 -- same ) ( u -- wid_u ) */
WORD(searchorder_pick,  searchorder_dup,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
/* searchorder[0]! ( wid -- ) set first wid in searchorder */
WORD(searchorder_store_0,searchorder_pick, DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
/* ( c-addr u -- idx true | -1 false ) find local variable in m4th->locals */
WORD_START(string_to_local,      searchorder_store_0)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY)
    WORD_CODE(
        user_var, T(M4TH_USER_VAR_LOCALS), fetch,
        _q_if0_, T(6),                          /* ( c-addr u 0                ) */
            nip, nip, minus_one, swap, exit,    /* ( -1 false                  ) */
        then,                                   /* ( c-addr u ls               ) */
        minus_rot, CALL(_locals_find_),         /* ( idx|-1                    ) */
        dup, one_plus, zero_ne, exit            /* ( idx true | -1 false       ) */
    )
WORD_END(string_to_local)
/*
 * string>name ( c-addr u -- nt|0 wid|0 -1|0|1 ) find name in current search order.
 * return 1 if name is immediate, else -1
 */
WORD_START(string_to_name, string_to_local)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* searchorder-depth 0                     ( c-addr u n 0              )
         * ?do                                     ( c-addr u                  ) (R: n i )
         *    2dup i searchorder-pick              ( c-addr u c-addr u wid     ) (R: n i )
         *    wordlist-find                        ( c-addr u nt|0 -1|0|1      ) (R: n i )
         *    ?if
         *       2nip                              ( nt -1|1                   ) (R: n i )
         *       i searchorder-pick swap           ( nt wid -1|1               ) (R: n i )
         *       unloop exit                       ( nt wid -1|1               )
         *    then                                 ( c-addr u 0 0              ) (R: n i )
         *    2drop                                ( c-addr u                  ) (R: n i )
         * loop                                    ( c-addr u                  )
         * 2drop 0 0 0                             ( 0 0 0                     )
         */
        searchorder_depth, zero,
        _q_do_, T(16+nCALLt),
            two_dup, i, searchorder_pick,
            CALL(wordlist_find),
            _q_if_, T(7),
                two_nip,
                i, searchorder_pick, swap,
                unloop, exit,
            then,
            two_drop,
        _loop_, T(-16-nCALLt),
        two_drop, zero, zero, zero, exit
    )
WORD_END(string_to_name)
WORD(to_token,         string_to_name, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_token,        to_token,       DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(token_plus,       one_token,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(tokens,           token_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)

DEF_WORD_STORE_TYP(token,      tokens)

DEF_WORD_FETCH_TYP(token,      token_store_8)

WORD(token_align,      token_fetch_8,  DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(token_aligned,    token_align,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_to_name,    token_aligned,  DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
WORD(token_comma,      token_to_name,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD_START(tokens_comma,   token_comma)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(/* generated from file m4th_core.forth - see source and comments there */
        /*11*/ tokens, bounds, _q_do_, T(6), i, token_fetch, token_comma, one_token, _plus_loop_, T(-6), exit
    )
WORD_END(tokens_comma)
WORD_START(user_var,   tokens_comma)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS | M4FLAG_CONSUMES_IP_2)
    WORD_CODE(user_var, T(-1), exit)
WORD_END(user_var)
/**
 * wordlist-find ( c-addr u wid -- nt|0 -1|0|1 ) search word by name in wordlist.
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
        wordlist_last_name,
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
WORD(wordlist_add_name,    wordlist_find,      DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH | M4FLAG_MEM_STORE)
WORD(wordlist_last_name,   wordlist_add_name,  DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(wordlist_reset,       wordlist_last_name, DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(wordlist_to_string,   wordlist_last_name, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(xt_to_name,           wordlist_to_string, DSTACK(1,1), RSTACK(0,0), WORD_PURE)

#undef LASTWORD
#define LASTWORD xt_to_name
