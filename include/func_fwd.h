/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef M64TH_INCLUDE_FUNC_FWD_H
#define M64TH_INCLUDE_FUNC_FWD_H

#ifdef __cplusplus
extern "C" {
#endif

#include "dict_all.mh"
#include "func_alias.mh"

typedef struct m6arg_s m6arg; /* intentionally incomplete type, cannot be instantiated */

/**
 * The functions m6f* use m64th calling convention, not C !
 *
 * Do not attempt to invoke them directly from C - the only useful
 * operation from C is taking their address and copying it to m64th->ftable
 */

#define FUNC_FWD_ENTRY(strlen, str, name) void m6f##name(m6arg _);
DICT_WORDS_ALL(FUNC_FWD_ENTRY) /* declare all void m6f*(m6arg _) in one fell swoop */
#undef FUNC_FWD_ENTRY

#ifdef __cplusplus
}
#endif

#endif /* M64TH_INCLUDE_FUNC_FWD_H */
