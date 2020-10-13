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

#include "impl.h"

#include "c/c_liblinenoise.c"
#include "c/c_std.c"

/******************************************************************************/
/* C implementation of hash map                                               */
/******************************************************************************/

#define H(x) x##byte
#include "c/hashmap_impl.c"
#undef H
#define H(x) x##short
#include "c/hashmap_impl.c"
#undef H
#define H(x) x##int
#include "c/hashmap_impl.c"
#undef H
#define H(x) x##cell
#include "c/hashmap_impl.c"
#undef H
#include "c/hashmap_countedstring.c"
