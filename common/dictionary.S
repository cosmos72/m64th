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

#ifndef M4TH_ASM_S
#error "common/dictionary.h can only be included from asm.S - do not attempt to use it directly"
#endif

/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th)

WORD_SIMPLE(3, "(1)", _1_)
WORD_SIMPLE(4, "(do)", _do_, _1_)
/* omitted: (lit) */
/* omitted: (leave) */
/* omitted: (loop) */
WORD_SIMPLE(2, "i*", i_star, _do_)
WORD_SIMPLE(2, "i+", i_plus, i_star)
WORD_SIMPLE(2, "i-", i_minus, i_plus)
WORD_START(4, "noop", noop, i_minus)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_INLINE_NATIVE)
    WORD_INLINE_NATIVE_LEN_0()
    WORD_CODE_N(1)     
    WORD_DATA_N(0)
    WORD_CODE_FUNC(exit)
WORD_END(noop)

DICT_END(m4th)
/* ---------------------------------------------------------------------------------------------- */
DICT_START(tools_ext)

WORD_START(3, "bye", bye)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_INLINE_NATIVE_LEN_0()
    WORD_CODE_N(2)     
    WORD_DATA_N(0)
    WORD_CODE_FUNC(bye)
    WORD_CODE_FUNC(exit) /* reachable by subsequent m4th_enter() */
WORD_END(bye)

DICT_END(tools_ext)
/* ---------------------------------------------------------------------------------------------- */
DICT_START(core)

WORD_SIMPLE(1, "!", store)
WORD_SIMPLE(1, "*", star, store)
WORD_SIMPLE(1, "+", plus, star)
WORD_SIMPLE(2, "+!", plus_store, plus)
WORD_SIMPLE(1, "-", minus, plus_store)
WORD_SIMPLE(1, "/", slash, minus)
WORD_SIMPLE(4, "/mod", slash_mod, slash)
WORD_SIMPLE(2, "0<", zero_less, slash_mod)
WORD_SIMPLE(3, "0<>", zero_not_equals, zero_less)
WORD_SIMPLE(2, "0=", zero_equals, zero_not_equals)
WORD_SIMPLE(2, "0>", zero_greater_than, zero_equals)
WORD_SIMPLE(2, "1+", one_plus, zero_greater_than)
WORD_SIMPLE(2, "1-", one_minus, one_plus)
WORD_SIMPLE(2, "2*", two_star, one_minus)
WORD_SIMPLE(2, "2+", two_plus, two_star)
WORD_SIMPLE(2, "2-", two_minus, two_plus)
WORD_SIMPLE(2, "2/", two_slash, two_minus)
WORD_SIMPLE(1, "<", less_than, two_slash)
WORD_SIMPLE(2, "<>", not_equals, less_than)
WORD_SIMPLE(1, "=", equals, not_equals)
WORD_SIMPLE(1, ">", greater_than, equals)
WORD_SIMPLE(2, ">r", to_r, greater_than)
WORD_SIMPLE(4, "?dup", question_dupe, to_r)
WORD_SIMPLE(1, "@", fetch, question_dupe)
WORD_SIMPLE(3, "abs", abs, fetch)
WORD_SIMPLE(3, "and", and, abs)
WORD_SIMPLE(2, "bl", bl, and)
WORD_SIMPLE(2, "c!", c_store, bl)
WORD_SIMPLE(2, "c@", c_fetch, c_store)
WORD_SIMPLE(5, "depth", depth, c_fetch)
WORD_SIMPLE(4, "drop", drop, depth)
WORD_SIMPLE(3, "dup", dup, drop)
WORD_SIMPLE(5, "false", false, dup)
WORD_SIMPLE(1, "i", i, false)
WORD_SIMPLE(2, "i'", i_prime, i)
WORD_SIMPLE(6, "invert", invert, i_prime)
WORD_SIMPLE(1, "j", j, invert)
WORD_START(7, "literal", literal, j)
    WORD_FLAGS(M4FLAG_IMMEDIATE | M4FLAG_INLINE | M4FLAG_INLINE_NATIVE)
    WORD_INLINE_NATIVE_LEN(literal)
    WORD_CODE_N(2)     
    WORD_DATA_N(0)
    WORD_CODE_FUNC(literal)
    WORD_CODE_FUNC(exit)
WORD_END(literal)
WORD_SIMPLE(3, "max", max, literal)
WORD_SIMPLE(3, "min", min, max)
WORD_SIMPLE(3, "mod", mod, min)
WORD_SIMPLE(3, "negate", negate, mod)
WORD_SIMPLE(3, "nip", nip, negate)
WORD_SIMPLE(2, "or", or, nip)
WORD_SIMPLE(4, "over", over, or)
WORD_SIMPLE(2, "r>", r_from, over)
WORD_SIMPLE(3, "rot", rot, r_from)
WORD_SIMPLE(4, "swap", swap, rot)
WORD_SIMPLE(4, "true", true, swap)
WORD_SIMPLE(6, "unloop", unloop, true)
WORD_SIMPLE(3, "xor", xor, unloop)

DICT_END(core)
/* ---------------------------------------------------------------------------------------------- */
