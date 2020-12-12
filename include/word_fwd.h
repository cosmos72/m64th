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

#ifndef M4TH_INCLUDE_WORD_FWD_H
#define M4TH_INCLUDE_WORD_FWD_H

#ifdef __cplusplus
extern "C" {
#endif

#include "dict_all.mh"
#include "word.mh"

typedef struct m4word_s m4word;

/* declare all 'extern const m4word m4word_* ;' in one fell swoop */

#define M4WORD_ENTRY(strlen, str, name) extern const m4word WORD_SYM(name);
DICT_WORDS_ALL(M4WORD_ENTRY)
#undef M4WORD_ENTRY

#ifdef __cplusplus
}
#endif

#endif /* M4TH_INCLUDE_WORD_FWD_H */
