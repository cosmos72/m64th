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

#include "../common/asm.mh"
#include "../common/macro.mh"
#include "../dispatch/sz.mh" /* SZ SZe */
#include "dict.mh"
#include "dict_m4th.mh"

/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_impl)

DICTNAME(9, "m4th-impl", m4th_impl)

DICT_WORDS_M4TH_IMPL(WORDNAME)

WORD_START(_question_do_, _question_do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZe | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(2,0) /* stack effects when not jumping */
   WORD_RSTACK(0,2)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_question_do_, exit)
WORD_END(_question_do_)
WORD_START(_call_, _question_do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZe | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(-1,-1) /* stack effects of called function */
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_ENUMS(_call_, exit)
WORD_END(_call_)
WORD(_compile2s_,   _call_,        DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile4s_,   _compile2s_,   DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile8s_,   _compile4s_,   DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_do_,          _compile8s_,   DSTACK(2,0), RSTACK(0,2), WORD_PURE   | M4FLAG_COMPILE_ONLY)
WORD_START(_else_, _do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZe | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(1,0) /* stack effect when not jumping */
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_else_, exit)
WORD_END(_else_)
WORD_START(_if_, _else_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(1,0) /* stack effect when not jumping */
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_if_, exit)
WORD_END(_if_)
WORD_START(_inline_, _if_)
   WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
   WORD_DSTACK(0,0)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(exit) /* currently does nothing */
WORD_END(_inline_)
WORD_START(_jump_, _inline_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,0)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_jump_, exit)
WORD_END(_jump_)
WORD_START(_leave_, _jump_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,-1)
   WORD_RSTACK(2,-1)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_leave_, exit)
WORD_END(_leave_)
WORD_START(_literal2s_, _leave_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_2 | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(0,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_literal2s_, exit)
WORD_END(_literal2s_)
WORD_START(_literal4s_, _literal2s_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_4 | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(0,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_literal2s_, exit)
WORD_END(_literal4s_)
WORD_START(_literal8s_, _literal4s_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_8 | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(0,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_literal8s_, exit)
WORD_END(_literal8s_)
WORD_START(_loop_, _literal8s_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZe | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(0,0) /* stack effect when not jumping */
   WORD_RSTACK(2,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(_loop_, exit)
WORD_END(_loop_)
WORD_START(_optimize_, _loop_)
   WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
   WORD_DSTACK(0,0)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_ENUMS(exit) /* currently does nothing */
WORD_END(_optimize_)
WORD(minus_one,        _optimize_, DSTACK(0,1), RSTACK(0,0), WORD_PURE)
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
    WORD_NATIVE_LEN_0()
    WORD_ENUMS(exit)
WORD_END(noop)

DICT_BODY(m4th_impl, noop)
DICT_END(m4th_impl)

