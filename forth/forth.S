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

#include "../include/asm.mh"
#include "../include/dict.mh"
#include "../include/dict_forth.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */

DICT_START(forth_root)
#include "forth_root.S"
#include "forth_root_gen.S"
DICT_BODY(forth_root, LASTWORD)
DICT_END(forth_root)

DICT_START(forth_root)
#include "forth_core.S"
#include "forth_core_ext.S"
#include "forth_double_ext.S"
#include "forth_exception.S"
#include "forth_memory.S"
#include "forth_tools.S"
#include "forth_tools_ext.S"
#include "forth_search_order.S"
#include "forth_search_order_gen.S"
#include "forth_string.S"
DICT_BODY(forth, LASTWORD)
DICT_END(forth)
