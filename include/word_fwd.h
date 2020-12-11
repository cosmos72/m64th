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

#ifndef M64TH_INCLUDE_WORD_FWD_H
#define M64TH_INCLUDE_WORD_FWD_H

#ifdef __cplusplus
extern "C" {
#endif

#include "dict_all.mh"
#include "word.mh"

typedef struct m6word_s m6word;

/* declare all 'extern const m6word m6word_* ;' in one fell swoop */

#define M6WORD_ENTRY(strlen, str, name) extern const m6word WORD_SYM(name);
DICT_WORDS_ALL(M6WORD_ENTRY)
#undef M6WORD_ENTRY

#ifdef __cplusplus
}
#endif

#endif /* M64TH_INCLUDE_WORD_FWD_H */
