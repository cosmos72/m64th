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

#include "../common/asm.h"
#include "dict_asm.h"

/* ---------------------------------------------------------------------------------------------- */
DICT_START(forth)

DICTNAME(5, "forth", forth)

DICT_WORDS_FORTH(WORDNAME)

WORD(store,           store,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_STORE)
WORD(star,            store,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus,            star,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus_store,      plus,        DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_STORE)
WORD(minus,           plus_store,  DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(slash,           minus,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(slash_mod,       slash,       DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD(zero_less,       slash_mod,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_not_equals, zero_less,   DSTACK(1,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(zero_equals,     zero_not_equals,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_greater_than,zero_equals,DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_plus,  zero_greater_than, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_minus,       one_plus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_star,        one_minus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_plus,        two_star,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_minus,       two_plus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_slash,       two_minus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(less_than,       two_slash,   DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(not_equals,      less_than,       DSTACK(2,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(equals,          not_equals,   DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(greater_than,    equals,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(to_r,            greater_than,DSTACK(1,0), RSTACK(0,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(question_dupe,   to_r,        DSTACK(1,-1),RSTACK(0,0), WORD_PURE)
WORD(fetch,         question_dupe, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_FETCH)
WORD(abs,             fetch,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(and,             abs,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(bl,              and,         DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(c_store,         bl,          DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_STORE)
WORD_START(bye, c_store) /* tools ext */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_DSTACK(0,-1) /* data   stack may be altered from outside */
    WORD_RSTACK(0,-1) /* return stack may be altered from outside */
    WORD_NATIVE_LEN_0()
    /* exit is reachable by subsequent m4th_run() */
    WORD_FUNCS(bye, exit)
WORD_END(bye)
WORD(c_fetch,         bye,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_FETCH)
WORD(cell_plus,       c_fetch,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(cells,           cell_plus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD_START(char_plus, cells)
   WORD_FLAGS(WORD_PURE)
   WORD_DSTACK(1,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_LEN(one_plus) /* char+ is implemented as an alias to 1+ */
   WORD_FUNCS(one_plus, exit)
WORD_END(char_plus)
WORD_START(chars, char_plus)
   WORD_FLAGS(WORD_PURE)
   WORD_DSTACK(1,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_LEN_0() /* chars is implemented as noop */
   WORD_FUNCS(exit)
WORD_END(chars)
WORD(depth,           chars,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(drop,            depth,       DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,             drop,        DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(exit, dup)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(0,-1) /* FIXME: mark as M4FLAG_JUMP */
   WORD_RSTACK(1,-1)
   WORD_NATIVE_LEN_0()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_FUNCS(exit, exit)
WORD_END(exit)
WORD_START(false, exit) /* core ext */
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN(zero)
    WORD_FUNCS(zero, exit)
WORD_END(false)
WORD(i,               false,        DSTACK(0,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_prime,         i,           DSTACK(0,1), RSTACK(2,2), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(invert,          i_prime,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(j,               invert,      DSTACK(0,1), RSTACK(3,3), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(literal, j)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN_0()
    WORD_FUNCS(literal, exit)
WORD_END(literal)
WORD(lshift,          literal,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(max,             lshift,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(min,             max,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(mod,             min,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(negate,          mod,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(nip,             negate,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(or,              nip,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(over,            or,          DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD(r_from,          over,        DSTACK(0,1), RSTACK(1,0), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(rot,             r_from,      DSTACK(3,3), RSTACK(0,0), WORD_PURE)
WORD(rshift,          rot,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(swap,            rshift,      DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD_START(true, swap) /* core ext */
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN(minus_one)
    WORD_FUNCS(minus_one, exit)
WORD_END(true)
WORD(unloop,          true,        DSTACK(0,0), RSTACK(2,0), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(xor,             unloop,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)

DICT_BODY(forth, xor)
DICT_END(forth)


/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_impl)

DICTNAME(9, "m4th-impl", m4th_impl)

DICT_WORDS_M4TH_IMPL(WORDNAME)

WORD_START(_question_do_, _question_do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(2,0) /* stack effect when not jumping */
   WORD_RSTACK(0,2)
   WORD_NATIVE_LEN_0()
   WORD_FUNCS(_question_do_, exit)
WORD_END(_question_do_)
WORD_START(_call_, _question_do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(0,-1) /* stack effect after called function returns */
   WORD_RSTACK(0,0)
   WORD_NATIVE_LEN_0()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_FUNCS(_call_, exit)
WORD_END(_call_)
WORD(_do_,          _call_,        DSTACK(2,0), RSTACK(0,2), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(_lit_, _do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(0,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_LEN_0()
   WORD_FUNCS(_lit_, exit)
WORD_END(_lit_)
WORD_START(_leave_, _lit_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(0,0) /* FIXME: mark as M4FLAG_JUMP. these are stack effects when jumping */
   WORD_RSTACK(2,0)
   WORD_NATIVE_LEN_0()
   WORD_FUNCS(_leave_, exit)
WORD_END(_leave_)
WORD_START(_loop_, _leave_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
   WORD_DSTACK(0,0) /* FIXME: add stack effects when jumping? */
   WORD_RSTACK(2,0)
   WORD_NATIVE_LEN_0()
   WORD_FUNCS(_loop_, exit)
WORD_END(_loop_)
WORD(minus_one,       _loop_,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(zero,            minus_one,   DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(one,             zero,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two,             one,         DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD_START(noop, two)
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN_0()
    WORD_FUNCS(exit)
WORD_END(noop)

DICT_BODY(m4th_impl, noop)
DICT_END(m4th_impl)


/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_user)

DICTNAME(9, "m4th-user", m4th_user)

DICT_WORDS_M4TH_USER(WORDNAME)

WORD(less_equals,         less_equals,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(greater_equals,      less_equals,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(zero_less_equals,    greater_equals,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_greater_equals, zero_less_equals,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(i_star,              zero_greater_equals, DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_plus,              i_star,              DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_minus,             i_plus,              DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)

DICT_BODY(m4th_user, i_minus)
DICT_END(m4th_user)
