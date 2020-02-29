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

#include "c_std.h"
#include "../include/err.h"

#include <errno.h>  /* errno             */
#include <stdio.h>  /* fgetc() fgets()   */
#include <string.h> /* memchr() memset() */

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

/* memrchr() is GNU: implement our replacement */
static size_t find_last_char(const char *src, int c, size_t len) {
    const char *addr = memchr(src, c, len);
    size_t i = 0;
    if (!addr) {
        /* char not found, return len */
        return len;
    }
    do {
        i = addr - src;
    } while ((addr = memchr(src + i + 1, c, len - i - 1)));
    return i;
}

m4pair m4th_c_fread(FILE *in, void *addr, size_t len) {
    /*
     * We cannot actually use fread(): it blocks until all len bytes have been read.
     * Instead we want to return as soon as possible, typically after reading '\n'.
     * Thus we must use fgets(): tricky because it does not tell how many bytes it read.
     */
    m4pair ret = {};
    char *caddr = (char *)addr;
    if (len == 1) {
        int c = fgetc(in);
        if (c == EOF) {
            ret.err = m4err_c_errno - errno;
        } else {
            caddr[0] = (char)c;
            ret.num = 1;
        }
        return ret;
    }
    /* needed to detect last '\0' */
    memset(addr, '\xff', len);
    if (fgets(caddr, len, in) == NULL) {
        ret.err = m4err_c_errno - errno;
    } else {
        ret.num = find_last_char(caddr, '\0', len);
    }
    return ret;
}

m4pair m4th_c_fwrite(FILE *out, const void *addr, size_t len) {
    m4pair ret = {};
    if (len != 0 && (ret.num = fwrite(addr, 1, len, out)) == 0) {
        ret.err = m4err_c_errno - errno;
    }
    return ret;
}