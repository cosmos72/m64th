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

#ifndef M4TH_COMMON_DICTIONARY_ASM_H
#define M4TH_COMMON_DICTIONARY_ASM_H

#define DICT_WORDS_M4TH(X)                                                                         \
    X(3, "(1)", _1_)                                                                               \
    X(5, "(?do)", _question_do_)                                                                   \
    X(6, "(call)", _call_)                                                                         \
    X(4, "(do)", _do_)                                                                             \
    X(5, "(lit)", _lit_)                                                                           \
    X(7, "(leave)", _leave_)                                                                       \
    X(6, "(loop)", _loop_)                                                                         \
    /* X(2, "*!", star_store)  TODO */                                                             \
    /* X(2, "-!", minus_store) TODO */                                                             \
    X(2, "i*", i_star)                                                                             \
    X(2, "i+", i_plus)                                                                             \
    X(2, "i-", i_minus)                                                                            \
    X(4, "noop", noop)

#define DICT_WORDS_TOOLS_EXT(X) X(3, "bye", bye)

#define DICT_WORDS_CORE(X)                                                                         \
    X(1, "!", store)                                                                               \
    X(1, "*", star)                                                                                \
    X(1, "+", plus)                                                                                \
    X(2, "+!", plus_store)                                                                         \
    X(1, "-", minus)                                                                               \
    X(1, "/", slash)                                                                               \
    X(4, "/mod", slash_mod)                                                                        \
    X(2, "0<", zero_less)                                                                          \
    X(3, "0<>", zero_not_equals)                                                                   \
    X(2, "0=", zero_equals)                                                                        \
    X(2, "0>", zero_greater_than)                                                                  \
    X(2, "1+", one_plus)                                                                           \
    X(2, "1-", one_minus)                                                                          \
    X(2, "2*", two_star)                                                                           \
    X(2, "2+", two_plus)                                                                           \
    X(2, "2-", two_minus)                                                                          \
    X(2, "2/", two_slash)                                                                          \
    X(1, "<", less_than)                                                                           \
    X(2, "<>", not_equals)                                                                         \
    X(1, "=", equals)                                                                              \
    X(1, ">", greater_than)                                                                        \
    X(2, ">r", to_r)                                                                               \
    X(4, "?dup", question_dupe)                                                                    \
    X(1, "@", fetch)                                                                               \
    X(3, "abs", abs)                                                                               \
    X(3, "and", and)                                                                               \
    X(2, "bl", bl)                                                                                 \
    X(2, "c!", c_store)                                                                            \
    X(2, "c@", c_fetch)                                                                            \
    X(5, "cell+", cell_plus)                                                                       \
    X(5, "cells", cells)                                                                           \
    X(5, "char+", char_plus)                                                                       \
    X(5, "chars", chars)                                                                           \
    X(5, "depth", depth)                                                                           \
    X(4, "drop", drop)                                                                             \
    X(3, "dup", dup)                                                                               \
    X(4, "exit", exit)                                                                             \
    X(5, "false", false)                                                                           \
    X(1, "i", i)                                                                                   \
    X(2, "i'", i_prime)                                                                            \
    X(6, "invert", invert)                                                                         \
    X(1, "j", j)                                                                                   \
    X(7, "literal", literal)                                                                       \
    X(6, "lshift", lshift)                                                                         \
    X(3, "max", max)                                                                               \
    X(3, "min", min)                                                                               \
    X(3, "mod", mod)                                                                               \
    X(3, "negate", negate)                                                                         \
    X(3, "nip", nip)                                                                               \
    X(2, "or", or)                                                                                 \
    X(4, "over", over)                                                                             \
    X(2, "r>", r_from)                                                                             \
    X(3, "rot", rot)                                                                               \
    X(6, "rshift", rshift)                                                                         \
    X(4, "swap", swap)                                                                             \
    X(4, "true", true)                                                                             \
    X(6, "unloop", unloop)                                                                         \
    X(3, "xor", xor)

#endif /* M4TH_COMMON_DICTIONARY_ASM_H */
