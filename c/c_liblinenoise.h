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

#ifndef M64TH_C_LIBLINENOISE_H
#define M64TH_C_LIBLINENOISE_H

#include "../include/m64th.h"
#include "../linenoise/linenoise.h"

#include <stdio.h>

/** wrapper around liblinenoise C function linenoise() */
m6pair m64th_c_linenoise(const char *prompt, char *addr, size_t len);

/* callback invoked by linenoise() when user presses TAB to complete a word */
linenoiseString m64th_c_complete_word(linenoiseString input, linenoiseStrings *completions,
                                     void *userData);

/** temporary C implementation of 'words' */
void m64th_c_searchorder_print_all_words(const m6searchorder *s, FILE *out);

#endif /* M64TH_C_LIBLINENOISE_H */
