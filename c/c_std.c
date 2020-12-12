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

#include "c_std.h"
#include "../include/err.h"

#include <errno.h>  /* errno            */
#include <stdio.h>  /* fread() fwrite() */


m4pair m64th_c_fread(FILE *in, void *addr, size_t len) {
    m4pair ret = {};
    if (len != 0 && (ret.num = fread(addr, 1, len, in)) == 0) {
        if (feof(in)) {
            ret.err = m4err_unexpected_eof;
        } else {
            ret.err = m4err_c_errno - errno;
        }
    }
    return ret;
}

m4pair m64th_c_fwrite_fflush(FILE *out, const void *addr, size_t len) {
    m4pair ret = {};
    if (len != 0) {
        if ((ret.num = fwrite(addr, 1, len, out)) == 0 || fflush(out) != 0) {
            ret.err = m4err_c_errno - errno;
        }
    }
    return ret;
}
