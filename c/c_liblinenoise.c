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

#include <errno.h>  /* errno    */


m4pair m4th_c_linenoise(const char *prompt, char *addr, size_t len) {
    m4pair ret = {};
    linenoiseSetMultiLine(1);
    int n = linenoise(addr, len, prompt);
    if (n > 0) {
        ret.num = n;
        if (addr[n-1] == '\n') {
            addr[n-1] = '\0';
            linenoiseHistoryAdd(addr);
            addr[n-1] = '\n';
        }
    } else if (n == 0) {
        ret.err = m4err_unexpected_eof;
    } else {
        ret.err = m4err_c_errno - errno;
    }
    return ret;
}

#include "../linenoise/linenoise.c"
