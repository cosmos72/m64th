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
#include "dict.mh"
#include "dict_m4th_impl.mh"

/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_impl)

DICTNAME(9, "m4th-impl", m4th_impl)

DICT_WORDS_M4TH_IMPL(WORDNAME)

WORD_START(_question_do_, _question_do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(2,0) /* stack effects when not jumping */
   WORD_RSTACK(0,2)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_question_do_, exit)
WORD_END(_question_do_)
WORD_START(_call_, _question_do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(-1,-1) /* stack effects of called function */
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_FUNCS(_call_, exit)
WORD_END(_call_)
WORD(_compile_comma_,  _call_, DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_do_,     _compile_comma_,DSTACK(2,0), RSTACK(0,2), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(_else_, _do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(1,0) /* stack effect when not jumping */
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_else_, exit)
WORD_END(_else_)
WORD_START(_if_, _else_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(1,0) /* stack effect when not jumping */
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_if_, exit)
WORD_END(_if_)
WORD_START(_inline_, _if_)
   WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
   WORD_DSTACK(0,0)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(exit) /* currently does nothing */
WORD_END(_inline_)
WORD_START(_jump_, _inline_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,0)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_jump_, exit)
WORD_END(_jump_)
WORD_START(_leave_, _jump_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,-1)
   WORD_RSTACK(2,-1)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_leave_, exit)
WORD_END(_leave_)
WORD_START(_lit_, _leave_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(0,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_lit_, exit)
WORD_END(_lit_)
WORD_START(_loop_, _lit_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(0,0) /* stack effect when not jumping */
   WORD_RSTACK(2,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_loop_, exit)
WORD_END(_loop_)
WORD_START(_optimize_, _loop_)
   WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
   WORD_DSTACK(0,0)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(exit) /* currently does nothing */
WORD_END(_optimize_)
WORD(minus_one,       _optimize_,  DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(zero,            minus_one,   DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(one,             zero,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two,             one,         DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two_plus,        two,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_minus,       two_plus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(three,           two_minus,   DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four,            three,       DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four_star,       four,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_plus,       four_star,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight,           four_plus,   DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(eight_star,      eight,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_plus,      eight_star,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(i_star,          eight_plus,  DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_plus,          i_star,      DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_minus,         i_plus,      DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(noop, i_minus)
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN_0()
    WORD_FUNCS(exit)
WORD_END(noop)

DICT_BODY(m4th_impl, noop)
DICT_END(m4th_impl)

