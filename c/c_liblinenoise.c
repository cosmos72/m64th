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

#include <errno.h>   /* errno    */
#include <stdlib.h>  /* qsort() */
#include <strings.h> /* strncasecmp() */
#ifdef __unix__
#include <unistd.h> /* write()  */
#endif

#include "../linenoise/linenoise.c"

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

static int m4th_c_is_prefix_of_string(linenoiseString prefix, linenoiseString str) {
    return str.len > prefix.len && !strncasecmp(str.addr, prefix.addr, prefix.len);
}

static int m4th_c_compare_string(const void *left, const void *right) {
    const linenoiseString *a = (const linenoiseString *)left;
    const linenoiseString *b = (const linenoiseString *)right;
    const size_t alen = a->len, blen = b->len;
    int cmp = memcmp(a->addr, b->addr, min2(alen, blen));
    if (cmp != 0) {
        return cmp;
    }
    return alen < blen ? -1 : alen > blen ? 1 : 0;
}

static void m4th_c_sort_completions(linenoiseStrings *completions) {
    const size_t n = completions->size;
    if (n > 1) {
        qsort(completions->vec, n, sizeof(linenoiseString), m4th_c_compare_string);
    }
}

/* callback invoked by linenoise() when user presses TAB to complete a word */
linenoiseString m4th_c_complete_word(linenoiseString input, linenoiseStrings *completions,
                                     void *userData) {
    m4th *m = (m4th *)userData;
    m4cell i, n;
    for (n = input.len, i = n; i > 0; i--) {
        /* find last non-blank word in current input */
        if ((m4char)input.addr[i - 1] <= (m4char)' ') {
            break;
        }
    }
    input.len -= i;
    input.addr += i;

    for (n = m->searchorder.n, i = n - 1; i >= 0; i--) {
        const m4wordlist *wid = m->searchorder.addr[i];
        const m4word *w = m4wordlist_lastword(wid);
        while (w != NULL) {
            const m4string str = m4word_name(w);
            const linenoiseString completion = {str.n, (const char *)str.addr};
            if (m4th_c_is_prefix_of_string(input, completion)) {
                linenoiseAddCompletion(completions, completion);
            }
            w = m4word_prev(w);
        }
    }
    m4th_c_sort_completions(completions);
    return input;
}
