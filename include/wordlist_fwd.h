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

#ifndef M64TH_INCLUDE_WORDLIST_FWD_H
#define M64TH_INCLUDE_WORDLIST_FWD_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct m6wordlist_s m6wordlist;

/**
 * Contains all standard words from the forth 2012 standard word sets
 * (core, core ext, tools ext ...) that are actually implemented in m64th.
 */
extern m6wordlist m6wordlist_forth;
/**
 * Contains a minimal subset of words from the forth 2012 standard word sets:
 * the ones available after executing standard word 'only'
 */
extern m6wordlist m6wordlist_forth_root;
/**
 * Contains commonly found words that are not part of the standard.
 * Examples: 0<= 0>= <= >= i* i+ i-
 */
extern m6wordlist m6wordlist_m64th_user;
/**
 * Contains words to generate native assembly.
 */
extern m6wordlist m6wordlist_m64th_asm;
/**
 * Contains words to call C functions from forth.
 */
extern m6wordlist m6wordlist_m64th_c;
/**
 * Contains words that directly interact with m64th implementation.
 */
extern m6wordlist m6wordlist_m64th_core;
/**
 * Contains words used internally by m64th implementation.
 */
extern m6wordlist m6wordlist_m64th_impl;

#ifdef __cplusplus
}
#endif

#endif /* M64TH_INCLUDE_WORDLIST_FWD_H */
