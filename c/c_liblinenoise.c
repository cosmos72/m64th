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

#include "c_liblinenoise.h"
#include "../include/err.h"
#include "../linenoise/linenoise.h"

#include <errno.h> /* errno    */
#ifdef __unix__
#include <unistd.h> /* write()  */
#endif

m4pair m4th_c_linenoise(const char *prompt, char *addr, size_t len) {
    m4pair ret = {};
    linenoiseSetMultiLine(1);
    int n = linenoise(addr, len, prompt);
    if (n >= 0) {
        ret.num = n;
#ifdef __unix__
        /* forth expects a space to be printed instead of newline */
        (void)write(1, " ", 1);
#endif
        linenoiseHistoryAdd(addr);
    } else if (errno) {
        ret.err = m4err_c_errno - errno;
    } else {
        ret.err = m4err_unexpected_eof;
    }
    return ret;
}

#include "../linenoise/linenoise.c"
