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
/* --- m4th-user -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_user)

DICTNAME(9, "m4th-user", m4th_user)

DICT_WORDS_M4TH_USER(WORDNAME)

WORD(less_equal,       less_equal,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(more_equal,       less_equal,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(zero_less_equal,  more_equal,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_more_equal, zero_less_equal, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_plus,        zero_more_equal, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_minus,        two_plus,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_dup_two_to_r, two_minus,      DSTACK(2,2), RSTACK(0,2), WORD_R_PURE)
WORD(two_nip,         two_dup_two_to_r,DSTACK(4,2), RSTACK(0,0), WORD_PURE)
WORD(two_r_from_two_drop, two_nip,     DSTACK(0,0), RSTACK(2,0), WORD_R_PURE)
WORD(four_times,   two_r_from_two_drop,DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_plus,        four_times,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_div,         four_plus,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_times,      four_div,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_plus,       eight_times,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_div,        eight_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD_START(q_if, eight_div)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_init_, _compile_unresolved_jump_, _q_if_, _if_, exit
    )
WORD_END(q_if)
WORD_START(q_if_zero, q_if)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_init_, _compile_unresolved_jump_, _q_if0_, _if_, exit
    )
WORD_END(q_if_zero)
WORD(bounds,           q_if_zero,      DSTACK(2,2), RSTACK(0,0), M4FLAG_PURE)
WORD_START(break,      bounds)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_init_, _compile_unresolved_jump_, _break_, _while_, exit
    )
WORD_END(break)
WORD_START(continue,   bounds)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_init_, _compile_resolved_jump_, _continue_, begin, exit
    )
WORD_END(_continue_)
WORD(dup_to_r,         bounds,         DSTACK(1,1), RSTACK(0,1), WORD_R_PURE)
WORD(flip,             dup_to_r,       DSTACK(3,3), RSTACK(0,0), WORD_PURE)
WORD(i_times,          flip,           DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_plus,           i_times,        DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_minus,          i_plus,         DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_prime,          i_minus,        DSTACK(0,1), RSTACK(2,2), WORD_R_PURE)
WORD_START(if_zero, i_prime)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_init_, _compile_unresolved_jump_, _if0_, _if_, exit
    )
WORD_END(if_zero)
/*
 * classic forth interpreter/compiler iteration:
 *    read a name i.e. a non-blank string from IN,
 *    execute STRING>WORD which searches the current search order for name,
 *    and, if a word is found:
 *       if interpreting, perform the interpretation semantics of the word
 *       otherwise, perform the compilation semantics of the word
 *    otherwise, execute STRING>NUMBER which attempts to convert name to a number and,
 *    if successful:
 *       place the number on the data stack
 *       if compiling, execute the word LITERAL, which pops the number and compiles code
 *         that when executed will place the number on the data stack
 *    otherwise, set an error condition
 */
WORD_START(interpret,  if_zero)
    WORD_FLAGS(0)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(-1,-1)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* parse-name                                   ( c-addr u                 )
         * ?if0                                         ( c-addr u                 )
         *    2drop exit                                (                          )
         * then                                         ( c-addr u                 )
         * 2dup                                         ( c-addr u c-addr u        )
         * string>name                                  ( c-addr u nt|0 -1|0|1     )
         * ?if                      ( is a word )       ( c-addr u nt  -1|1        )
         *    2nip (eval-name) (check-stacks) exit      (                          )
         * then                                         ( c-addr u 0 0             )
         * 2drop 2dup string>number                     ( c-addr u x t|f           )
         * if                       ( is a number )     ( c-addr u x               )
         *    nip nip (eval-number) exit                (                          )
         * then                     ( neither )         ( c-addr u x               )
         * drop ex-string!                              (                          )
         * M4ERR_UNDEFINED_WORD throw                   (                          )
         */
        CALL(parse_name),
        _q_if0_, T(3),
            two_drop, exit,
        then,
        two_dup,
        CALL(string_to_name),
        _q_if_, T(5+2*SZ/SZt),
            two_nip, CALL(_eval_name_), CALL(_check_stacks_), exit,
        then,
        two_drop, two_dup, CALL(string_to_number),
        _if_, T(5+SZ/SZt),
            nip, nip, CALL(_eval_number_), exit,
        then,
        drop, ex_string_store,
        _lit_, T(M4ERR_UNDEFINED_WORD), throw, exit
    )
WORD_END(interpret)
WORD(noop,             interpret,      DSTACK(0,0), RSTACK(0,0), WORD_PURE)
WORD(r_store,          noop,           DSTACK(1,0), RSTACK(1,1), WORD_R_PURE)
WORD(r_plus,           r_store,        DSTACK(1,0), RSTACK(1,1), WORD_R_PURE)
WORD(r_from_drop,      r_plus,         DSTACK(0,0), RSTACK(1,0), WORD_R_PURE)
WORD(rdepth,           r_from_drop,    DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/**
 * forth interpreter/compiler loop:
 *    call INTERPRET repeatedly until an exception is thrown.
 */
WORD_START(repl,  rdepth)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(-1,-1)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* begin                                       ( ...           )
         *    in>ibuf ibuf-refill-if-empty drop        ( ...           )
         *    ' interpret catch                        ( ...' ex|0     )
         *    dup 0=                                   ( ... ex|0 t|f  )
         *    in>ibuf ibuf-skip-blanks-until-cr and    ( ... ex|0 t|f  )
         *    if                                       ( ... 0         )
         *       drop (repl-type-ack)                  ( ...           )
         *    else                                     ( ... ex        )
         *       type-exception                        ( ...           )
         *    then                                     ( ...           )
         *    out>obuf obuf-flush drop                 ( ...           )
         *    in>ibuf iobuf>err @                      ( ... err|0     )
         * until                                       ( ...           )
         * cr out>obuf obuf-flush drop                 ( ...           )
         */
        begin,
            in_to_ibuf, CALL(ibuf_refill_if_empty), drop,
            _lit_cell_, XT(interpret), _catch_beg_, _catch_end_,
            dup, zero_equal,
            in_to_ibuf, CALL(ibuf_skip_blanks_until_cr), and,
            _if_, T(4+SZ/SZt),
                drop, CALL(_repl_type_ack_),
            _else_, T(2+SZ/SZt),
                CALL(type_exception),
            then,
            out_to_obuf, CALL(obuf_flush), drop,
            in_to_ibuf, iobuf_err, fetch,
        _until_, T(-28-6*SZ/SZt),
        _lit_, T('\n'), emit, out_to_obuf, CALL(obuf_flush), drop, exit
    )
WORD_END(repl)
WORD(squared,          repl,           DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(sub,              squared,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(minus_rot,        sub,            DSTACK(3,3), RSTACK(0,0), WORD_PURE)
/* ( ex|0 -- ) write cr exception and ex-string@ to current output */
WORD_START(type_exception,   minus_rot)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* ?if                                         ( ex|0          )
         *    s\" \n exception " type                  (               )
         *    .                                        (               )
         *    ex-string@ type cr                       (               )
         * else                                        ( 0             )
         *    drop                                     (               )
         * then                                        (               )
         */
        _q_if_, T(11 + (11+SZt-1)/SZt + SZ/SZt),
            LIT_STRING(11, "\nexception "), type,
            CALL(dot),
            ex_string_fetch, type,
            _lit_, T('\n'), emit,
        _else_, T(2),
            drop,
        then, exit
    )
WORD_END(type_exception)
WORD(div_byte,         type_exception, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_char,         div_byte,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_short,        div_char,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_ushort,       div_short,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_int,          div_ushort,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_uint,         div_int,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_cell,         div_uint,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(byte_plus,        div_cell,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* WORD(char_plus,     ,               DSTACK(1,1), RSTACK(0,0), WORD_PURE) */ /* already in forth 'core' word set */
WORD(short_plus,       byte_plus,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(ushort_plus,      short_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(int_plus,         ushort_plus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(uint_plus,        int_plus,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* WORD(cell_plus,     ,               DSTACK(1,1), RSTACK(0,0), WORD_PURE) */ /* already in forth 'core' word set */
WORD(bytes,            uint_plus,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* WORD(chars,         ,               DSTACK(1,1), RSTACK(0,0), WORD_PURE) */ /* already in forth 'core' word set */
WORD(shorts,           bytes,          DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(ushorts,          shorts,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(ints,             ushorts,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(uints,            ints,           DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* WORD(cells    ,     ,               DSTACK(1,1), RSTACK(0,0), WORD_PURE) */ /* already in forth 'core' word set */
WORD(byte_store,       uints,          DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE) /* alias of c! */
WORD(char_store,       byte_store,     DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE) /* alias of c! */
WORD(short_store,      char_store,     DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(ushort_store,     short_store,    DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE) /* alias of short! */
WORD(int_store,        ushort_store,   DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(uint_store,       int_store,      DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE) /* alias of int! */
WORD(byte_fetch,       uint_store,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(char_fetch,       byte_fetch,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH) /* alias of c@ */
WORD(short_fetch,      char_fetch,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(ushort_fetch,     short_fetch,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(int_fetch,        ushort_fetch,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(uint_fetch,       int_fetch,      DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(short_comma,      uint_fetch,     DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD(int_comma,        short_comma,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD_START(countedstring_comma, int_comma)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses IP-relative JUMP, cannot inline in native code */
    WORD_CODE(
        countedstring_comma, exit
    )
WORD_END(countedstring_comma)
WORD(to_byte,     countedstring_comma, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_char,          to_byte,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_short,         to_char,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_ushort,        to_short,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_int,           to_ushort,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_uint,          to_int,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/**
 * string-first-blank ( c-addr u -- u' ) return index of first blank (i.e. char <= 32) in string,
 * return string length if not found.
 */
WORD(string_first_blank, to_uint,      DSTACK(2,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
/**
 * string>number ( c-addr u -- x t|f )
 * convert string to number, recognizing base prefixes # $ % and sign prefix '-'
 * Also convert any single-quoted char 'x' to ASCII code of x
 */
WORD_START(string_to_number, string_first_blank)
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_DSTACK(2,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* ?if0
         *    nip false exit               ( 0 false             )
         * then
         * string>char dup invert          ( caddr n c flag      )
         * if
         *    nip nip true exit            ( c true              )
         * then                            ( caddr n -1          )
         * drop string>base -rot           ( base caddr n        )
         * string>sign over                ( base caddr n sign n )
         * if0                             ( base caddr n sign   )
         *    2drop drop false exit        ( 0 false             ) \ no digits
         * then                            ( base caddr n sign   )
         * >r rot                          ( caddr n base        ) (R: sign )
         * string&base>u                   ( caddr n u           ) (R: sign )
         * rot drop                        ( n u                 ) (R: sign )
         * r> * swap                       ( x n                 )
         * 0=                              ( x t|f               )
         */
        _q_if0_, T(4),
            nip, false, exit,
        then,
        CALL(string_to_char), dup, invert,
        _if_, T(5),
            nip, nip, true, exit,
        then,
        drop, CALL(string_to_base), minus_rot,
        CALL(string_to_sign), over,
        _if0_, T(5),
            two_drop, drop, false, exit,
        then,
        to_r, rot,
        CALL(string_base_to_u),
        rot, drop, r_from, times, swap,
        zero_equal, exit
    )
WORD_END(string_to_number)
/* string= ( addr1 addr2 u -- addr1 addr2 u t|f ) t if the two strings have the same content */
WORD(string_equal, string_to_number, DSTACK(3,4), RSTACK(0,0), M4FLAG_INLINE | M4FLAG_MEM_FETCH)
/* string-ci= ( addr1 addr2 u -- addr1 addr2 u t|f ) t if the two strings have the same content, ignoring case */
WORD(string_ci_equal,  string_equal, DSTACK(3,4), RSTACK(0,0), M4FLAG_INLINE | M4FLAG_MEM_FETCH)
WORD_START(string_ci_ne,  string_ci_equal)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(3,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(string_ci_equal, invert, exit)
WORD_END(string_ci_ne)
WORD_START(string_ne,  string_ci_ne)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(3,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(string_equal, invert, exit)
WORD_END(string_ne)
WORD(trail,            string_ne,      DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD(u_less_equal,     trail,          DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(u_more_equal,     u_less_equal,   DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(valid_base_q, u_more_equal)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        two, _lit2s_, T(37),       /* base 2 37                   */
        within,                    /* caddr n base                */
        exit
    )
WORD_END(valid_base_q)

DICT_BODY(m4th_user, valid_base_q)
DICT_END(m4th_user)
