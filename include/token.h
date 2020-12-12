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

#ifndef M64TH_INCLUDE_TOKEN_H
#define M64TH_INCLUDE_TOKEN_H

#ifdef __cplusplus
extern "C" {
#endif

#include "dict_all.mh"
#include "token.mh"

#include <stdint.h>

#define M6TOKEN_ENTRY(strlen, len, name) M6TOKEN_SYM(name) = M6TOKEN_VAL(name),

#if defined(__cplusplus) && __cplusplus >= 201103L

/** small enum representing a forth instruction */
enum m6token : uint16_t { DICT_TOKENS_ALL(M6TOKEN_ENTRY) };
/** small enum representing a forth instruction. same as m6token */
typedef m6token m6token_e;

#else /* !defined(__cplusplus) || __cplusplus < 201103L */

/** enum representing a forth instruction. use m6token for accurate sizeof() */
typedef enum m6token_e { DICT_TOKENS_ALL(M6TOKEN_ENTRY) } m6token_e;
/** small integer representing a forth instruction. use m6token_e for symbolic names */
typedef uint16_t m6token;

#endif /* defined(__cplusplus) && __cplusplus >= 201103L */

#undef M6TOKEN_ENTRY

#ifdef __cplusplus
}
#endif

#endif /* M64TH_INCLUDE_TOKEN_H */
