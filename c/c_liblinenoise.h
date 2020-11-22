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

#ifndef M4TH_C_LIBLINENOISE_H
#define M4TH_C_LIBLINENOISE_H

#include "../include/m4th.h"
#include "../linenoise/linenoise.h"

#include <stdio.h>

/** wrapper around liblinenoise C function linenoise() */
m4pair m4th_c_linenoise(const char *prompt, char *addr, size_t len);

/* callback invoked by linenoise() when user presses TAB to complete a word */
linenoiseString m4th_c_complete_word(linenoiseString input, linenoiseStrings *completions,
                                     void *userData);

/** temporary C implementation of 'words' */
void m4th_c_searchorder_print_all_words(const m4searchorder *s, FILE *out);

#endif /* M4TH_C_LIBLINENOISE_H */
