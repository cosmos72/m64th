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

#ifndef M4TH_COMMON_ENUM_H
#define M4TH_COMMON_ENUM_H

#ifdef __cplusplus
extern "C" {
#endif

#include "dict_all.mh"
#include "enum.mh"

#include <stdint.h>

#define M4ENUM_SYM(name) m4##name

#define M4ENUM_ENTRY(strlen, len, name) M4ENUM_SYM(name) = M4ENUM_VAL(name),

#if defined(__cplusplus) && __cplusplus >= 201103L

/** small enum representing a forth instruction. same as m4enum */
enum m4_enum : uint16_t { DICT_WORDS_ALL(M4ENUM_ENTRY) };
/** small enum representing a forth instruction */
typedef m4_enum m4enum;

#else /* !defined(__cplusplus) || __cplusplus < 201103L */

/** enum representing a forth instruction. use m4enum for accurate sizeof() */
typedef enum m4_enum_e { DICT_WORDS_ALL(M4ENUM_ENTRY) } m4_enum;
/** small integer representing a forth instruction. use m4_enum for symbolic names */
typedef uint16_t m4enum;

#endif /* defined(__cplusplus) && __cplusplus >= 201103L */

#undef M4ENUM_ENTRY

#ifdef __cplusplus
}
#endif

#endif /* M4TH_COMMON_ENUM_H */
