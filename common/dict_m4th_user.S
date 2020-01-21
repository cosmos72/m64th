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
#include "dict_m4th_user.mh"

/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_user)

DICTNAME(9, "m4th-user", m4th_user)

DICT_WORDS_M4TH_USER(WORDNAME)

WORD(less_equals,         less_equals,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(greater_equals,      less_equals,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(zero_less_equals,    greater_equals,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_greater_equals, zero_less_equals,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)

DICT_BODY(m4th_user, zero_greater_equals)
DICT_END(m4th_user)
