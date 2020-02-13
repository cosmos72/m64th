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

#ifndef M4TH_INCLUDE_TOKEN_H
#define M4TH_INCLUDE_TOKEN_H

#ifdef __cplusplus
extern "C" {
#endif

#include "dict_all.mh"
#include "token.mh"

#include <stdint.h>

#define M4TOKEN_ENTRY(strlen, len, name) M4TOKEN_SYM(name) = M4TOKEN_VAL(name),

#if defined(__cplusplus) && __cplusplus >= 201103L

/** small enum representing a forth instruction. same as m4token */
enum m4_token : uint16_t { DICT_TOKENS_ALL(M4TOKEN_ENTRY) };
/** small enum representing a forth instruction */
typedef m4_token m4token;

#else /* !defined(__cplusplus) || __cplusplus < 201103L */

/** enum representing a forth instruction. use m4token for accurate sizeof() */
typedef enum m4_token_e { DICT_TOKENS_ALL(M4TOKEN_ENTRY) } m4_token;
/** small integer representing a forth instruction. use m4_token for symbolic names */
typedef uint16_t m4token;

#endif /* defined(__cplusplus) && __cplusplus >= 201103L */

#undef M4TOKEN_ENTRY

#ifdef __cplusplus
}
#endif

#endif /* M4TH_INCLUDE_TOKEN_H */
