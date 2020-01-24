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

#ifndef M4TH_COMMON_FUNC_FWD_H
#define M4TH_COMMON_FUNC_FWD_H

#ifdef __cplusplus
extern "C" {
#endif

#include "dict_all.mh"
#include "func_alias.mh"

typedef struct m4arg_s m4arg; /* intentionally incomplete type, cannot be instantiated */

/**
 * The functions m4func_* use m4th calling convention, not C !
 *
 * Do not attempt to invoke them directly from C - the only useful
 * operation from C is taking their address and copying it to m4th->etable
 */

#define FUNC_FWD_ENTRY(strlen, str, name) void m4func_##name(m4arg _);
DICT_WORDS_ALL(FUNC_FWD_ENTRY) /* declare all void m4func_*(m4arg _) in one fell swoop */
#undef FUNC_FWD_ENTRY

#ifdef __cplusplus
}
#endif

#endif /* M4TH_COMMON_FUNC_FWD_H */
