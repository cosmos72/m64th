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

/* clang-format off */

DICT_WORDS_FORTH_TOOLS(WORDNAME)

WORD_START(see, LASTWORD)
    WORD_DSTACK(0,0)  /* data   stack may be altered from outside */
    WORD_RSTACK(0,0)  /* return stack may be altered from outside */
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        CALL(parse_name), two_dup, CALL(string_to_name), drop,  /* ( c-addr u nt|0 ) */
        _q_if0_, T(6),                                          /* ( c-addr u nt|0 ) */
            drop, ex_message_store,                             /* (               ) */
            _lit_, T(M4ERR_UNDEFINED_WORD), throw,              /* (               ) */
        then,                                                   /* ( c-addr u nt   ) */
        nip, nip,                                               /* ( nt            ) */
        _c_arg_1_, _c_call_, CELL(m4word_print_stdout), _c_ret_0_, exit
    )
WORD_END(see)

#undef LASTWORD
#define LASTWORD see
