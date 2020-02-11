/**
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

#include "../dispatch/sz.mh" /* SZ SZt */
#include "../include/asm.mh"
#include "../include/macro.mh"
#include "../include/dict.mh"
#include "../include/dict_m4th.mh"
#include "../include/err.mh"

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
WORD(two_nip,          two_minus,      DSTACK(4,2), RSTACK(0,0), WORD_PURE)
WORD(four_times,       two_nip,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_plus,        four_times,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_div,         four_plus,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_times,      four_div,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_plus,       eight_times,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_div,        eight_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(i_times,          eight_div,      DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_plus,           i_times,        DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_minus,          i_plus,         DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_prime,          i_minus,        DSTACK(0,1), RSTACK(2,2), WORD_R_PURE)
WORD_START(q_if, i_prime)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_unresolved_jump_, _q_if_, exit
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
        _compile_unresolved_jump_, _q_if_zero_, exit
    )
WORD_END(q_if_zero)
WORD(noop,             q_if_zero,      DSTACK(0,0), RSTACK(0,0), WORD_PURE)
WORD(dup_to_r,         noop,           DSTACK(1,1), RSTACK(0,1), WORD_R_PURE)
WORD(r_from_drop,      dup_to_r,       DSTACK(0,0), RSTACK(1,0), WORD_R_PURE)
WORD(r_plus,           r_from_drop,    DSTACK(1,0), RSTACK(1,1), WORD_R_PURE)
WORD(r_store,          r_plus,         DSTACK(1,0), RSTACK(1,1), WORD_R_PURE)
WORD(minus_rot,        r_store,        DSTACK(3,3), RSTACK(0,0), WORD_PURE)
WORD(div_byte,         minus_rot,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
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
WORD(to_byte,          uint_fetch,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_char,          to_byte,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_short,         to_char,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_ushort,        to_short,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_int,           to_ushort,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_uint,          to_int,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/**
 * string>number ( caddr n -- caddr' n' x t|f )
 * convert string to number, recognizing base prefixes # $ % and sign prefix '-'
 * Also convert any single-quoted char 'x' to ASCII code of x
 */
WORD_START(string_to_number, to_uint)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(2,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* ?if0
         *    0 false exit                 ( caddr n 0 false )
         * then
         * string>char dup invert          ( caddr n c flag  )
         * if
         *    true exit                    ( caddr n c true  )
         * then                            ( caddr n c       )
         * drop string>base >r             ( caddr n         ) (R: base )
         * string>sign over                ( caddr n sign n  ) (R: base )
         * if0                             ( caddr n sign    ) (R: base )
         *    drop 0 false r> drop exit    ( caddr n 0 false ) \ no digits
         * then                            ( caddr n sign    ) (R: base )
         * r@ swap r!                      ( caddr n base    ) (R: sign )
         * string&base>u                   ( caddr n u       ) (R: sign )
         * r> * over                       ( caddr n x n     )
         * 0=                              ( caddr n x t|f   )
         */
        _q_if_zero_, T(4),
            zero, false, exit,
        _then_,
        _call_, WADDR(string_to_char), dup, invert,
        _if_, T(3),
            true, exit,
        _then_,
        drop, _call_, WADDR(string_to_base), to_r,
        _call_, WADDR(string_to_sign), over,
        _if_zero_, T(6),
            drop, zero, false, r_from_drop, exit,
        _then_,
        r_fetch, swap, r_store,
        _call_, WADDR(string_base_to_u),
        r_from, times, over,
        zero_equal, exit
    )
WORD_END(string_to_number)
WORD(u_less_equal,   string_to_number, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(u_more_equal,     u_less_equal,   DSTACK(2,1), RSTACK(0,0), WORD_PURE)

DICT_BODY(m4th_user, u_more_equal)
DICT_END(m4th_user)

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-core -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_core)

DICTNAME(9, "m4th-core", m4th_core)

DICT_WORDS_M4TH_CORE(WORDNAME)

WORD(div_token,        div_token,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_plus,       div_token,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(tokens,           token_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(token_store,      tokens,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(token_fetch,      token_store,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(to_token,         token_fetch,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD_START(word_inline_query,  to_token)
    WORD_FLAGS(WORD_IMPURE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        dup, word_to_flags,
        dup, _lit2s_, SHORT(M4FLAG_INLINE_ALWAYS), and, _if_, T(4),
            two_drop, true, exit,
        _then_,
        _lit2s_, SHORT(M4FLAG_INLINE), and, _if_zero_, T(4),
            drop, false, exit,
        _then_,
        word_to_code_n, eight, less, exit
    )
WORD_END(word_inline_query)
WORD(word_to_code,  word_inline_query, DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_code_addr,  word_to_code, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_code_n,word_to_code_addr, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(word_to_flags,    word_to_code_n, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(xt_to_word,       word_to_flags,  DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)

DICT_BODY(m4th_core, word_to_flags)
DICT_END(m4th_core)

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-impl -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_impl)

DICTNAME(9, "m4th-impl", m4th_impl)

DICT_WORDS_M4TH_IMPL(WORDNAME)

WORD_START(_q_do_, _q_do_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, _q_do_, exit)
WORD_END(_q_do_)
WORD_START(_q_if_, _q_do_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, _q_if_, exit)
WORD_END(_q_if_)
WORD_START(_q_if_zero_, _q_if_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, _q_if_zero_, exit)
WORD_END(_q_if_zero_)
WORD_START(_call_, _q_if_zero_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(-1,-1) /* stack effects of called word */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0) /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_NATIVE_NONE()
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(_call_, exit)
WORD_END(_call_)
WORD_START(_call_xt_, _call_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(-1,-1) /* stack effects of called XT */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0) /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_NATIVE_NONE()
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(_call_xt_, exit)
WORD_END(_call_xt_)
WORD_START(_else_, _call_xt_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE()  /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_call_, WADDR(else), exit)
WORD_END(_else_)
WORD_START(_exec_native_, _else_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* (exec-native) uses tail-call optimization: cannot inline into native code */
    WORD_CODE(_exec_native_, exit)
WORD_END(_exec_native_)
WORD_START(_exec_token_, _exec_native_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* (exec-token) uses tail-call optimization: cannot inline into native code */
    WORD_CODE(_exec_token_, exit)
WORD_END(_exec_token_)
WORD_START(_if_, _exec_token_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, _if_, exit)
WORD_END(_if_)
WORD_START(_if_zero_, _if_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, _if_zero_, exit)
WORD_END(_if_zero_)
WORD_START(_ip_, _if_zero_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_ip_, exit)
WORD_END(_ip_)
WORD_START(_ip_to_data_, _ip_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_ip_to_data_, exit)
WORD_END(_ip_to_data_)
WORD_START(_ip_to_data_addr_, _ip_to_data_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_ip_to_data_addr_, exit)
WORD_END(_ip_to_data_addr_)
WORD_START(_leave_, _ip_to_data_addr_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, _leave_, exit)
WORD_END(_leave_)
WORD_START(_lit2s_, _leave_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_2 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_lit2s_, SHORT(-1), exit)
WORD_END(_lit2s_)
WORD_START(_lit4s_, _lit2s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_4 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_lit4s_, INT(-1), exit)
WORD_END(_lit4s_)
WORD_START(_lit8s_, _lit4s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_8 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_lit8s_, CELL(-1), exit)
WORD_END(_lit8s_)
WORD_START(_loop_, _lit8s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(2,2)
    WORD_NATIVE_NONE()
    WORD_CODE(_loop_, T(-1), exit)
WORD_END(_loop_)
WORD(_missing_,        _loop_,         DSTACK(0,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_JUMP)
WORD_START(_then_, _missing_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_IMMEDIATE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_LEN_0()
    WORD_CODE(_call_, WADDR(then), exit)
WORD_END(_then_)
WORD(_num_compiled_,   _then_,         DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile2s_,      _num_compiled_, DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile4s_,      _compile2s_,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile8s_,      _compile4s_,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD_START(_compile_lit_, _compile4s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_lit_, T(-1), exit)
WORD_END(_compile_lit_)
WORD_START(_compile_unresolved_jump_, _compile_lit_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, T(-1), exit)
WORD_END(_compile_unresolved_jump_)
WORD_START(_inline_, _compile_unresolved_jump_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        word_to_code, one_minus, /* ( code n-1 )  skip 'exit' at the end of XT */
        dup, zero, less_equal, _if_, T(2),
            exit,              /* inline length is <= 0 */
        _then_,                /* ( code n-1 )   */
        zero, do,
            dup, token_fetch,  /* ( code token ) */
            _compile_token_,
            token_plus,        /* ( code++ )     */
        _loop_, T(-6), drop, exit
    )
WORD_END(_inline_)
WORD_START(_optimize_, _inline_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(exit) /* currently does nothing */
WORD_END(_optimize_)
/**
 * resolve the most recent unresolved jump, setting its destination to 'here'.
 * Called by 'else' and 'then' to resolve the jump offset of a preceding 'if' or 'else'.
 * ( jump_address jump_token -- )
 */
WORD_START(_resolve_jump_here_, _optimize_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        drop, dup, negate, _num_compiled_, plus, /* ( #tokens IP-offset )    */
        swap, one_minus, tokens,           /* ( IP-offset toffset ) toffset of token after (if) or (else) */
        _word_, word_to_code_addr, plus,   /* ( IP-offset taddr   ) taddr   of token after (if) or (else) */
        token_store, exit
    )
WORD_END(_resolve_jump_here_)
/**
 * called by 'loop': resolve the jump offsets of one 'loop', zero or more 'leave' and one 'do'
 * ( ctrl-loop -- )
 */
WORD_START(_resolve_loop_, _resolve_jump_here_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(-1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* TODO */ exit
    )
WORD_END(_resolve_loop_)
/**
 * test whether executing a token produces the given cell value
 * ( x token -- token true | x false )
 */
WORD_START(_token_gives_cell_q_, _resolve_loop_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        over, over,                        /* ( x token x token ) */
        _exec_token_, equal, _if_, T(4),   /* ( x token )         */
            nip, true, exit,               /* ( token true )      */
        _then_,
        drop, false, exit                  /* ( x false )         */
    )
WORD_END(_token_gives_cell_q_)
/**
 * test whether executing one of the tokens taddr[0...tn-1] produces the given cell value
 * ( x taddr tn -- token true | x false )
 */
WORD_START(_any_token_gives_cell_q_, _token_gives_cell_q_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        zero, _q_do_, T(14+SZ/SZt),          /* loop if tn != 0          */
                                             /* ( x taddr )              */
            dup_to_r, token_fetch,           /* ( x token ) (R taddr )   */
            _call_, WADDR(_token_gives_cell_q_),/* ( token true | x false ) (R taddr ) */
            _if_, T(5),
                r_from_drop, true,           /* ( token true )           */
                unloop, exit,                /* exit                     */
            _then_,
            r_from, token_plus,              /* ( x taddr )              */
        _loop_, T(-14-SZ/SZt),
        drop, false, exit                    /* ( x false )              */
    )
WORD_END(_token_gives_cell_q_)
WORD(_word_, _any_token_gives_cell_q_, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(minus_one,        _word_,         DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(zero,             minus_one,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(one,              zero,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two,              one,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(three,            two,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four,             three,          DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(eight,            four,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
/* ( ch -- n )  convert '#' to 10, '$' to 16, '%' to 2, else 0 */
WORD_START(char_to_base, eight)
    WORD_FLAGS(M4FLAG_PURE) /* cannot be inlined, uses (ip) to access its body */
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_DATA_AND_CODE(
      char_to_base,
      WORD_DATA_BYTES(10, 16, 2),
      WORD_CODE_TOKENS(
        /* (ip>data>addr) swap to-char '#' - dup 2 <= if
         *    chars + c@ exit
         * then drop drop 0
         */
        _ip_to_data_addr_, swap, to_char,      /* ( body ch )               */
        _lit2s_, T('#'), minus, dup, two,      /* ( body ch-'#' ch-'#' 2 )  */
        less_equal, _if_, T(5),                /* ( body ch-'#' )           */
            chars, plus, c_fetch, exit,
        _then_,                                /* ( body ch-'#' )           */
        two_drop, zero, exit
      )
    )
WORD_END(char_to_base)
/* ( ch -- n )  convert one digit in base 2..36 from char to unsigned number, else -1 */
WORD_START(char_to_u, char_to_base)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_PURE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* dup '0' ':' within if        \ ':' == '9' + 1
         *   '0' - exit
         * then dup 'A' '[' within if   \ '[' == 'Z' + 1
         *   55 - exit
         * then dup 'a' '{' within if   \ '{' == 'z' + 1
         *   87 - exit
         * then -1
         */
        dup, _lit2s_, T('0'), _lit2s_, T('9'+1), /* ( ch ch '0' '9'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit2s_, T('0'), minus, exit,        /* ( ch-'0' )                  */
        _then_,
        dup, _lit2s_, T('A'), _lit2s_, T('Z'+1), /* ( ch ch 'A' 'Z'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit2s_, T('A'-10), minus, exit,     /* ( ch-'A'+10 )               */
        _then_,
        dup, _lit2s_, T('a'), _lit2s_, T('z'+1), /* ( ch ch 'a' 'z'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit2s_, T('a'-10), minus, exit,     /* ( ch-'a'+10 )               */
        _then_,
        drop, minus_one, exit                    /* ( -1 )                      */
    )
WORD_END(char_to_u)
/*
 * string>base ( caddr n -- caddr' n' base )
 * if string starts with # $ or % consume it and return corresponding base, else return current base
 */
WORD_START(string_to_base, char_to_u)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* ?if                             ( caddr n       )
         *    over c@ char>base            ( caddr n base  )
         *    ?if                          ( caddr n base  )
         *       >r                        ( caddr n       ) (R: base )
         *       1- swap char+ swap        ( caddr' n'     ) (R: base )
         *       r> exit                   ( caddr n' base )
         *    then
         *    drop                         ( caddr n       )
         * then
         * base @ exit                     ( caddr n base  )
         */
        _q_if_, T(15+SZ/SZt),
           over, c_fetch, _call_, WADDR(char_to_base),
           _q_if_, T(8),
              to_r,
              one_minus, swap, char_plus, swap,
              r_from, exit,
           _then_,
           drop,
        _then_,
        _call_, WADDR(base), fetch, exit
    )
WORD_END(string_to_base)
/* ( caddr n -- caddr' n' ch )  convert three-character string "'x'" to char 'x' for any x, else -1 */
WORD_START(string_to_char, string_to_base)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* dup 3 =                         ( caddr   n   t|f     )
         * if                              ( caddr   n           )
         *    drop dup c@ ''' =            ( caddr   t|f         )
         *    if                           ( caddr               )
         *       2+ dup c@ ''' =           ( caddr+2  t|f  )
         *       if                        ( caddr+2             )
         *          1+ dup 2- c@           ( caddr+3 ch          )
         *          0 swap exit            ( caddr+3 n-3 ch      )
         *       then                      ( caddr+2             )
         *       2-                        ( caddr               )
         *    then                         ( caddr               )
         *    3                            ( caddr   n           )
         * then                            ( caddr   n           )
         * -1 ;                            ( caddr   n   -1      )
         */
        dup, three, equal,
        _if_, T(28),
            drop, dup, c_fetch, _lit2s_, T('\''), equal,
            _if_, T(18),
                two_plus, dup, c_fetch, _lit2s_, T('\''), equal,
                _if_, T(8),
                    one_plus, dup, two_minus, c_fetch,
                    zero, swap, exit,
                _then_,
                two_minus,
            _then_,
            three,
        _then_,
        minus_one, exit
    )
WORD_END(string_to_char)
/**
 * string&base>u ( caddr n base -- caddr' n' u )
 * convert string from base to unsigned number
 */
WORD_START(string_base_to_u, string_to_char)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(3,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* over if0                            ( caddr n base      )
         *    drop 0 exit                      ( caddr n 0         )
         * then
         * >r 0 -rot 0                         ( u caddr n 0       ) (R: base     )
         * do                                  ( u caddr           ) (R: base n 0 )
         *    dup c@ char>u dup 0 j within     ( u caddr digit t|f ) (R: base n i )
         *    if0                              ( u caddr digit     ) (R: base n i )
         *       drop swap                     ( caddr u           ) (R: base n i )
         *       i' i - unloop r> drop         ( caddr u n'        )
         *       swap exit                     ( caddr n u         )
         *    then                             ( u caddr digit     ) (R: base n i )
         *    rot j * +                        ( caddr u'          ) (R: base n i )
         *    swap char+                       ( u caddr'          ) (R: base n i )
         * loop
         * swap 0 swap                         ( caddr 0 u         ) (R: base     )
         * r> drop ;                           ( caddr 0 u         )
         */
        over, _if_zero_, T(4),
            drop, zero, exit,
        _then_,
        to_r, zero, minus_rot, zero,
        do,
            dup, c_fetch, _call_, WADDR(char_to_u), dup, zero, j/*NON-PORTABLE*/, within,
            _if_zero_, T(10),
                drop, swap,
                i_prime, i, minus, unloop, r_from_drop,
                swap, exit,
            _then_,
            rot, j/*NON-PORTABLE*/, times, plus,
            swap, char_plus,
        _loop_, T(-27-SZ/SZt),
        swap, zero, swap,
        r_from_drop, exit
    )
WORD_END(string_base_to_u)
/**
 * string>sign ( caddr n -- caddr' n' sign ) parse '-' prefix and return -1, else return 1
 */
WORD_START(string_to_sign, string_base_to_u)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
       /* ?if0                                ( caddr n           )
        *    one exit                         ( caddr n 1         )
        * then
        * over c@ '-' <>                      ( caddr n t|f       )
        * if
        *    one exit                         ( caddr n 1         )
        * then
        * 1- swap char+ swap                  ( caddr' n'         )
        * -1 ;                                ( caddr n -1        )
        */
        _q_if_zero_, T(3),
            one, exit,
        _then_,
        over, c_fetch, _lit_, T('-'), ne,
        _if_, T(3),
            one, exit,
        _then_,
        one_minus, swap, char_plus, swap,
        minus_one, exit
    )
WORD_END(string_to_sign)
WORD_START(valid_base_q, string_to_sign)
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

DICT_BODY(m4th_impl, valid_base_q)
DICT_END(m4th_impl)

