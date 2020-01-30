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

#ifndef M4TH_DICT_FWD_H
#define M4TH_DICT_FWD_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct m4dict_s m4dict;

/**
 * Contains all standard words from the ANS forth standard word sets
 * (core, core ext, tools ext ...) that are actually implemented in m4th.
 */
extern const m4dict m4dict_forth;
/**
 * Contains commonly found words that are not part of the standard.
 * Examples: 0<= 0>= <= >= i* i+ i-
 */
extern const m4dict m4dict_m4th_user;
/**
 * Contains words that directly interact with m4th implementation.
 */
extern const m4dict m4dict_m4th_core;
/**
 * Contains words used internally by m4th implementation.
 */
extern const m4dict m4dict_m4th_impl;

#ifdef __cplusplus
}
#endif

#endif /* M4TH_DICT_FWD_H */
