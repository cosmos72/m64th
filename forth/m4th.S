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

#include "../include/dict.mh"
#include "../include/dict_m4th.mh"

DICT_START(m4th_c)
DICT_WORDS_M4TH_C(WORDNAME)
#include "m4th_c.S"
DICT_BODY(m4th_c, LASTWORD)
DICT_END(m4th_c)

/**/

DICT_START(m4th_core)
DICT_WORDS_M4TH_CORE(WORDNAME)
#include "m4th_core.S"
DICT_BODY(m4th_core, LASTWORD)
DICT_END(m4th_core)

/**/

DICT_START(m4th_impl)
DICT_WORDS_M4TH_IMPL(WORDNAME)
#include "m4th_impl.S"
DICT_BODY(m4th_impl, LASTWORD)
DICT_END(m4th_impl)

/**/

DICT_START(m4th_user)
DICT_WORDS_M4TH_USER(WORDNAME)
#include "m4th_user.S"
#include "m4th_user_gen.S"
DICT_BODY(m4th_user, LASTWORD)
DICT_END(m4th_user)
