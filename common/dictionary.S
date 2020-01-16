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

#ifdef __ANDROID__
        /*
	 * work around linker message
	 * "warning: creating a DT_TEXTREL in a shared object"
	 * because it produces non-working executable that fail with
	 * CANNOT LINK EXECUTABLE: "/cmd/full/path" has text relocations
	 */
	.data
#else
	.rodata
#endif

/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th)

WORDNAME(3, "(1)", _1_)
WORDNAME(4, "(do)", _do_)
/* omitted: (lit) */
/* omitted: (leave) */
/* omitted: (loop) */
WORDNAME(2, "i*", i_star)
WORDNAME(2, "i+", i_plus)
WORDNAME(2, "i-", i_minus)
WORDNAME(4, "noop", noop)

WORD_SIMPLE(_1_)
WORD_SIMPLE(_do_, _1_)
/* omitted: (lit) */
/* omitted: (leave) */
/* omitted: (loop) */
WORD_SIMPLE(i_star, _do_)
WORD_SIMPLE(i_plus, i_star)
WORD_SIMPLE(i_minus, i_plus)
WORD_START(noop, i_minus)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_INLINE_NATIVE)
    WORD_INLINE_NATIVE_LEN_0()
    WORD_CODE_N(1)
    WORD_DATA_N(0)
    WORD_CODE_FUNC(exit)
WORD_END(noop)

DICT_END(m4th)
/* ---------------------------------------------------------------------------------------------- */
DICT_START(tools_ext)

WORDNAME(3, "bye", bye)

WORD_START(bye)
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


WORDNAME(1, "!", store)
WORDNAME(1, "*", star)
WORDNAME(1, "+", plus)
WORDNAME(2, "+!", plus_store)
WORDNAME(1, "-", minus)
WORDNAME(1, "/", slash)
WORDNAME(4, "/mod", slash_mod)
WORDNAME(2, "0<", zero_less)
WORDNAME(3, "0<>", zero_not_equals)
WORDNAME(2, "0=", zero_equals)
WORDNAME(2, "0>", zero_greater_than)
WORDNAME(2, "1+", one_plus)
WORDNAME(2, "1-", one_minus)
WORDNAME(2, "2*", two_star)
WORDNAME(2, "2+", two_plus)
WORDNAME(2, "2-", two_minus)
WORDNAME(2, "2/", two_slash)
WORDNAME(1, "<", less_than)
WORDNAME(2, "<>", not_equals)
WORDNAME(1, "=", equals)
WORDNAME(1, ">", greater_than)
WORDNAME(2, ">r", to_r)
WORDNAME(4, "?dup", question_dupe)
WORDNAME(1, "@", fetch)
WORDNAME(3, "abs", abs)
WORDNAME(3, "and", and)
WORDNAME(2, "bl", bl)
WORDNAME(2, "c!", c_store)
WORDNAME(2, "c@", c_fetch)
WORDNAME(5, "depth", depth)
WORDNAME(4, "drop", drop)
WORDNAME(3, "dup", dup)
WORDNAME(5, "false", false)
WORDNAME(1, "i", i)
WORDNAME(2, "i'", i_prime)
WORDNAME(6, "invert", invert)
WORDNAME(1, "j", j)
WORDNAME(7, "literal", literal)
WORDNAME(3, "max", max)
WORDNAME(3, "min", min)
WORDNAME(3, "mod", mod)
WORDNAME(3, "negate", negate)
WORDNAME(3, "nip", nip)
WORDNAME(2, "or", or)
WORDNAME(4, "over", over)
WORDNAME(2, "r>", r_from)
WORDNAME(3, "rot", rot)
WORDNAME(4, "swap", swap)
WORDNAME(4, "true", true)
WORDNAME(6, "unloop", unloop)
WORDNAME(3, "xor", xor)


WORD_SIMPLE(store)
WORD_SIMPLE(star, store)
WORD_SIMPLE(plus, star)
WORD_SIMPLE(plus_store, plus)
WORD_SIMPLE(minus, plus_store)
WORD_SIMPLE(slash, minus)
WORD_SIMPLE(slash_mod, slash)
WORD_SIMPLE(zero_less, slash_mod)
WORD_SIMPLE(zero_not_equals, zero_less)
WORD_SIMPLE(zero_equals, zero_not_equals)
WORD_SIMPLE(zero_greater_than, zero_equals)
WORD_SIMPLE(one_plus, zero_greater_than)
WORD_SIMPLE(one_minus, one_plus)
WORD_SIMPLE(two_star, one_minus)
WORD_SIMPLE(two_plus, two_star)
WORD_SIMPLE(two_minus, two_plus)
WORD_SIMPLE(two_slash, two_minus)
WORD_SIMPLE(less_than, two_slash)
WORD_SIMPLE(not_equals, less_than)
WORD_SIMPLE(equals, not_equals)
WORD_SIMPLE(greater_than, equals)
WORD_SIMPLE(to_r, greater_than)
WORD_SIMPLE(question_dupe, to_r)
WORD_SIMPLE(fetch, question_dupe)
WORD_SIMPLE(abs, fetch)
WORD_SIMPLE(and, abs)
WORD_SIMPLE(bl, and)
WORD_SIMPLE(c_store, bl)
WORD_SIMPLE(c_fetch, c_store)
WORD_SIMPLE(depth, c_fetch)
WORD_SIMPLE(drop, depth)
WORD_SIMPLE(dup, drop)
WORD_SIMPLE(false, dup)
WORD_SIMPLE(i, false)
WORD_SIMPLE(i_prime, i)
WORD_SIMPLE(invert, i_prime)
WORD_SIMPLE(j, invert)
WORD_START(literal, j)
    WORD_FLAGS(M4FLAG_IMMEDIATE | M4FLAG_INLINE | M4FLAG_INLINE_NATIVE)
    WORD_INLINE_NATIVE_LEN(literal)
    WORD_CODE_N(2)
    WORD_DATA_N(0)
    WORD_CODE_FUNC(literal)
    WORD_CODE_FUNC(exit)
WORD_END(literal)
WORD_SIMPLE(max, literal)
WORD_SIMPLE(min, max)
WORD_SIMPLE(mod, min)
WORD_SIMPLE(negate, mod)
WORD_SIMPLE(nip, negate)
WORD_SIMPLE(or, nip)
WORD_SIMPLE(over, or)
WORD_SIMPLE(r_from, over)
WORD_SIMPLE(rot, r_from)
WORD_SIMPLE(swap, rot)
WORD_SIMPLE(true, swap)
WORD_SIMPLE(unloop, true)
WORD_SIMPLE(xor, unloop)

DICT_END(core)
/* ---------------------------------------------------------------------------------------------- */
