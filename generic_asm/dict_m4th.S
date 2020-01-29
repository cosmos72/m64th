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

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-user -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_user)

DICTNAME(9, "m4th-user", m4th_user)

DICT_WORDS_M4TH_USER(WORDNAME)

/* just an alias for c@, no dedicated m4token value */
WORDNAME(5, "char@", char_fetch)

WORD(less_equal,       less_equal,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(more_equal,       less_equal,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(zero_less_equal,  more_equal,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_more_equal, zero_less_equal, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(dup_to_r,        zero_more_equal, DSTACK(1,1), RSTACK(0,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(r_from_drop,      dup_to_r,       DSTACK(0,0), RSTACK(1,0), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(r_plus,           r_from_drop,    DSTACK(1,0), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(r_store,          r_plus,         DSTACK(1,0), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(to_byte,          r_store,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_int,           to_byte,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_short,         to_int,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_char,          to_short,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_uint,          to_char,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_ushort,        to_uint,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)

WORD(byte_fetch,       to_ushort,      DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(int_fetch,        byte_fetch,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(short_fetch,      int_fetch,      DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)

WORD_START(char_fetch, short_fetch)
    WORD_FLAGS(WORD_IMPURE | M4FLAG_MEM_FETCH)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_LEN(c_fetch)
    WORD_TOKENS(c_fetch, bye)
WORD_END(char_fetch)
WORD(uint_fetch,       char_fetch,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(ushort_fetch,     uint_fetch,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)

DICT_BODY(m4th_user, ushort_fetch)
DICT_END(m4th_user)

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-impl -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_impl)

DICTNAME(9, "m4th-impl", m4th_impl)

DICT_WORDS_M4TH_IMPL(WORDNAME)

WORD_START(_question_do_, _question_do_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_question_do_, exit)
WORD_END(_question_do_)
WORD_START(_call_, _question_do_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(-1,-1) /* stack effects of called XT */
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_TOKENS(_call_, exit)
WORD_END(_call_)
WORD(_compile2s_,   _call_,        DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile4s_,   _compile2s_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile8s_,   _compile4s_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD_START(_compile_lit2s_, _compile4s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_2 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_TOKENS(_compile_lit2s_, exit)
WORD_END(_compile_lit2s_)
WORD(_do_,     _compile_lit2s_,    DSTACK(2,0), RSTACK(0,2), WORD_PURE   | M4FLAG_COMPILE_ONLY)
WORD_START(_else_, _do_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_else_, exit)
WORD_END(_else_)
WORD_START(_exec_native_, _else_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE() /* (exec-native) uses tail-call optimization: cannot inline into native code */
    WORD_TOKENS(_exec_native_, exit)
WORD_END(_exec_native_)
WORD_START(_exec_token_, _exec_native_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE() /* (exec-token) uses tail-call optimization: cannot inline into native code */
    WORD_TOKENS(_exec_token_, exit)
WORD_END(_exec_token_)
WORD_START(_if_, _exec_token_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(1,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_, exit)
WORD_END(_if_)
WORD_START(_if_zero_, _if_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(1,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_zero_, exit)
WORD_END(_if_zero_)
WORD_START(_if_less_, _if_zero_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_less_, exit)
WORD_END(_if_less_)
WORD_START(_if_less_equal_, _if_less_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_less_equal_, exit)
WORD_END(_if_less_equal_)
WORD_START(_if_ne_, _if_less_equal_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_ne_, exit)
WORD_END(_if_ne_)
WORD_START(_if_equal_, _if_ne_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_equal_, exit)
WORD_END(_if_equal_)
WORD_START(_if_more_, _if_equal_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_more_, exit)
WORD_END(_if_more_)
WORD_START(_if_more_equal_, _if_more_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_if_more_equal_, exit)
WORD_END(_if_more_equal_)
WORD_START(_inline_, _if_more_equal_)
    WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_TOKENS(exit) /* currently does nothing */
WORD_END(_inline_)
WORD_START(_ip_, _inline_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_TOKENS(_ip_, exit)
WORD_END(_ip_)
WORD_START(_jump_, _ip_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_jump_, exit)
WORD_END(_jump_)
WORD_START(_leave_, _jump_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_leave_, exit)
WORD_END(_leave_)
WORD_START(_literal2s_, _leave_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_2 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_TOKENS(_literal2s_, exit)
WORD_END(_literal2s_)
WORD_START(_literal4s_, _literal2s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_4 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_TOKENS(_literal2s_, exit)
WORD_END(_literal4s_)
WORD_START(_literal8s_, _literal4s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_8 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_TOKENS(_literal8s_, exit)
WORD_END(_literal8s_)
WORD_START(_loop_, _literal8s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(2,2)
    WORD_NATIVE_NONE()
    WORD_TOKENS(_loop_, exit)
WORD_END(_loop_)
WORD(_missing_,        _loop_,     DSTACK(0,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_JUMP)
WORD_START(_optimize_, _missing_)
    WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_TOKENS(exit) /* currently does nothing */
WORD_END(_optimize_)
WORD_START(_then_, _optimize_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_LEN_0()
    WORD_TOKENS(_then_, exit)
WORD_END(_then_)
WORD(minus_one,        _then_,     DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(zero,             minus_one,  DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(one,              zero,       DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two,              one,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two_plus,         two,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_minus,        two_plus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(three,            two_minus,  DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four,             three,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four_times,       four,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_plus,        four_times, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight,            four_plus,  DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(eight_times,      eight,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_plus,       eight_times,DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(i_prime,          eight_plus, DSTACK(0,1), RSTACK(2,2), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_times,          i_prime,    DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_plus,           i_times,    DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_minus,          i_plus,     DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(noop, i_minus)
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_LEN_0()
    WORD_TOKENS(exit)
WORD_END(noop)

DICT_BODY(m4th_impl, noop)
DICT_END(m4th_impl)

