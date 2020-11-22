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
#include "std/root.S"
#include "std/root_gen.S"
DICT_BODY(forth_root, LASTWORD)
DICT_END(forth_root)

DICT_START(forth_root)
#include "std/core.S"
#include "std/core_ext.S"
#include "std/double_ext.S"
#include "std/exception.S"
#include "std/memory.S"
#include "std/tools.S"
#include "std/tools_ext.S"
#include "std/searchorder.S"
#include "std/searchorder_gen.S"
#include "std/string.S"
DICT_BODY(forth, LASTWORD)
DICT_END(forth)
