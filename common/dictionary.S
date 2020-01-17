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

/*
 * work around Android linker message
 * "warning: creating a DT_TEXTREL in a shared object"
 * because it produces non-working executable that fail with
 * CANNOT LINK EXECUTABLE: "/cmd/full/path" has text relocations
 */
#if defined(__ELF__) && !defined(__ANDROID__)
       .section .rodata
#else
       .data
#endif

/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th)

WORDNAME(3, "(1)", _1_)
WORDNAME(5, "(?do)", _question_do_)
WORDNAME(6, "(call)", _call_)
WORDNAME(4, "(do)", _do_)
WORDNAME(5, "(lit)", _lit_)
WORDNAME(7, "(leave)", _leave_)
WORDNAME(6, "(loop)", _loop_)
/* WORDNAME(2, "*!", star_store)  TODO */
/* WORDNAME(2, "-!", minus_store) TODO */
WORDNAME(2, "i*", i_star)
WORDNAME(2, "i+", i_plus)
WORDNAME(2, "i-", i_minus)
WORDNAME(4, "noop", noop)

WORD(_1_,             _1_,         DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD_START(_question_do_, _1_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(2,-1)
   WORD_RSTACK(0,-1)
   WORD_INLINE_NATIVE_LEN_0()
   WORD_CODE_N(2)
   WORD_DATA_N(0)
   WORD_CODE_FUNC(_question_do_)
   WORD_CODE_FUNC(exit)
WORD_END(_question_do_)
WORD_START(_call_, _question_do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,0)
   WORD_RSTACK(0,1)
   WORD_INLINE_NATIVE_LEN_0()
   WORD_CODE_N(2)
   WORD_DATA_N(0)
   WORD_CODE_FUNC(_call_)
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_CODE_FUNC(exit)
WORD_END(_call_)
WORD(_do_,          _call_,        DSTACK(2,0), RSTACK(0,2), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(_lit_, _do_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
   WORD_DSTACK(0,1)
   WORD_RSTACK(0,0)
   WORD_INLINE_NATIVE_LEN_0()
   WORD_CODE_N(2)
   WORD_DATA_N(0)
   WORD_CODE_FUNC(_lit_)
   WORD_CODE_FUNC(exit)
WORD_END(_lit_)
WORD_START(_leave_, _lit_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,0)
   WORD_RSTACK(2,0)
   WORD_INLINE_NATIVE_LEN_0()
   WORD_CODE_N(2)
   WORD_DATA_N(0)
   WORD_CODE_FUNC(_leave_)
   WORD_CODE_FUNC(exit)
WORD_END(_leave_)
WORD_START(_loop_, _leave_)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,0)
   WORD_RSTACK(2,-1)
   WORD_INLINE_NATIVE_LEN_0()
   WORD_CODE_N(2)
   WORD_DATA_N(0)
   WORD_CODE_FUNC(_loop_)
   WORD_CODE_FUNC(exit)
WORD_END(_loop_)
WORD(i_star,          _loop_,      DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_plus,          i_star,      DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_minus,         i_plus,      DSTACK(1,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(noop, i_minus)
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_INLINE_NATIVE_LEN_0()
    WORD_CODE_N(1)
    WORD_DATA_N(0)
    WORD_CODE_FUNC(exit)
WORD_END(noop)

DICT_END(m4th)
/* ---------------------------------------------------------------------------------------------- */
DICT_START(tools_ext)

WORDNAME(3, "bye", bye)

WORD_START(bye, bye)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_JUMP)
    WORD_DSTACK(0,-1) /* data   stack may be altered from outside */
    WORD_RSTACK(0,-1) /* return stack may be altered from outside */
    WORD_INLINE_NATIVE_LEN_0()
    WORD_CODE_N(2)
    WORD_DATA_N(0)
    WORD_CODE_FUNC(bye)
    WORD_CODE_FUNC(exit) /* reachable by subsequent m4th_enter() */
WORD_END(bye)

DICT_END(tools_ext)
/* ---------------------------------------------------------------------------------------------- */
DICT_START(core)


WORDNAME(1, "!",    store)
WORDNAME(1, "*",    star)
WORDNAME(1, "+",    plus)
WORDNAME(2, "+!",   plus_store)
WORDNAME(1, "-",    minus)
WORDNAME(1, "/",    slash)
WORDNAME(4, "/mod", slash_mod)
WORDNAME(2, "0<",   zero_less)
WORDNAME(3, "0<>",  zero_not_equals)
WORDNAME(2, "0=",   zero_equals)
WORDNAME(2, "0>",   zero_greater_than)
WORDNAME(2, "1+",   one_plus)
WORDNAME(2, "1-",   one_minus)
WORDNAME(2, "2*",   two_star)
WORDNAME(2, "2+",   two_plus)
WORDNAME(2, "2-",   two_minus)
WORDNAME(2, "2/",   two_slash)
WORDNAME(1, "<",    less_than)
WORDNAME(2, "<>",   not_equals)
WORDNAME(1, "=",    equals)
WORDNAME(1, ">",    greater_than)
WORDNAME(2, ">r",   to_r)
WORDNAME(4, "?dup", question_dupe)
WORDNAME(1, "@",    fetch)
WORDNAME(3, "abs",  abs)
WORDNAME(3, "and",  and)
WORDNAME(2, "bl",   bl)
WORDNAME(2, "c!",   c_store)
WORDNAME(2, "c@",   c_fetch)
WORDNAME(5, "depth",depth)
WORDNAME(4, "drop", drop)
WORDNAME(3, "dup",  dup)
WORDNAME(4, "exit", exit)
WORDNAME(5, "false",false)
WORDNAME(1, "i",    i)
WORDNAME(2, "i'",   i_prime)
WORDNAME(6, "invert",  invert)
WORDNAME(1, "j",    j)
WORDNAME(7, "literal", literal)
WORDNAME(6, "lshift",  lshift)
WORDNAME(3, "max",  max)
WORDNAME(3, "min",  min)
WORDNAME(3, "mod",  mod)
WORDNAME(3, "negate",  negate)
WORDNAME(3, "nip",  nip)
WORDNAME(2, "or",   or)
WORDNAME(4, "over", over)
WORDNAME(2, "r>",   r_from)
WORDNAME(3, "rot",  rot)
WORDNAME(6, "rshift",  rshift)
WORDNAME(4, "swap", swap)
WORDNAME(4, "true", true)
WORDNAME(6, "unloop",  unloop)
WORDNAME(3, "xor",  xor)


WORD(store,           store,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_STORE)
WORD(star,            store,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus,            star,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus_store,      plus,        DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_STORE)
WORD(minus,           plus_store,  DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(slash,           minus,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(slash_mod,       slash,       DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD(zero_less,       slash_mod,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_not_equals, zero_less,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_equals, zero_not_equals, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_greater_than,zero_equals,DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_plus,  zero_greater_than, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_minus,       one_plus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_star,        one_minus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_plus,        two_star,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_minus,       two_plus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_slash,       two_minus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(less_than,       two_slash,   DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(not_equals,      less_than,   DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(equals,          not_equals,  DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(greater_than,    equals,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(to_r,            greater_than,DSTACK(1,0), RSTACK(0,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(question_dupe,   to_r,        DSTACK(1,-1),RSTACK(0,0), WORD_PURE)
WORD(fetch,         question_dupe, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_FETCH)
WORD(abs,             fetch,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(and,             abs,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(bl,              and,         DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(c_store,         bl,          DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_STORE)
WORD(c_fetch,         c_store,     DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_ADDR_FETCH)
WORD(depth,           c_fetch,     DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(drop,            depth,       DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,             drop,        DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(exit, dup)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,0)
   WORD_RSTACK(1,0)
   WORD_INLINE_NATIVE_LEN_0()
   WORD_CODE_N(2)
   WORD_DATA_N(0)
   WORD_CODE_FUNC(exit)
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_CODE_FUNC(exit)
WORD_END(exit)
WORD(false,           exit,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(i,               false,       DSTACK(0,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_prime,         i,           DSTACK(0,1), RSTACK(2,2), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(invert,          i_prime,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(j,               invert,      DSTACK(0,1), RSTACK(3,3), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(literal, j)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_INLINE_NATIVE_LEN_0()
    WORD_CODE_N(2)
    WORD_DATA_N(0)
    WORD_CODE_FUNC(literal)
    WORD_CODE_FUNC(exit)
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
WORD(true,            swap,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(unloop,          true,        DSTACK(0,0), RSTACK(2,0), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(xor,             unloop,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)

DICT_END(core)
/* ---------------------------------------------------------------------------------------------- */
