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

static int m4th_c_string_is_prefix_of(linenoiseString prefix, linenoiseString str) {
    return str.len > prefix.len && !strncasecmp(str.addr, prefix.addr, prefix.len);
}

static m4cell m4th_c_string_equals(const linenoiseString a, const linenoiseString b) {
    if (a.len != b.len) {
        return tfalse;
    } else if (a.addr == b.addr || a.len == 0) {
        return ttrue;
    } else {
        return memcmp(a.addr, b.addr, a.len) == 0 ? ttrue : tfalse;
    }
}

static int m4th_c_string_compare(const void *left, const void *right) {
    const linenoiseString *a = (const linenoiseString *)left;
    const linenoiseString *b = (const linenoiseString *)right;
    const size_t alen = a->len, blen = b->len;
    int cmp = memcmp(a->addr, b->addr, min2(alen, blen));
    if (cmp != 0) {
        return cmp;
    }
    return alen < blen ? -1 : alen > blen ? 1 : 0;
}

static void m4th_c_strings_sort(linenoiseStrings *strings) {
    const size_t n = strings->size;
    if (n > 1) {
        qsort(strings->vec, n, sizeof(linenoiseString), m4th_c_string_compare);
    }
}

/* remove duplicates. note: strings must be already sorted */
static void m4th_c_strings_unique(linenoiseStrings *strings) {
    linenoiseString last = {};
    const size_t n = strings->size;
    size_t i = 0, j = 0;
    for (; i < n; i++) {
        linenoiseString curr = strings->vec[i];
        if (!m4th_c_string_equals(last, curr)) {
            strings->vec[j++] = last = curr;
        }
    }
    strings->size = j;
}

/* return != 0 if wid is present in searchorder */
static m4cell m4th_c_searchorder_find(const m4searchorder *searchorder, const m4wordlist *wid) {
    for (m4cell i = 0, n = searchorder->n; i < n; i++) {
        if (searchorder->addr[i] == wid) {
            return ttrue;
        }
    }
    return tfalse;
}

/* callback invoked by linenoise() when user presses TAB to complete a word */
linenoiseString m4th_c_complete_word(linenoiseString input, linenoiseStrings *completions,
                                     void *userData) {
    m4searchorder searchorder = {};
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

    /* copy m->searchorder ignoring repeated wordlists */
    for (i = 0, n = m->searchorder.n; i < n; i++) {
        m4wordlist *wid = m->searchorder.addr[i];
        if (!m4th_c_searchorder_find(&searchorder, wid)) {
            searchorder.addr[searchorder.n++] = wid;
        }
    }

    /* priority of each wordlist in searchorder does not matter here:  */
    /* we simply collect all words, and any duplicate due to shadowing */
    /* will be merged by m4th_c_strings_unique() below                 */
    for (i = 0, n = searchorder.n; i < n; i++) {
        const m4wordlist *wid = searchorder.addr[i];
        const m4word *w = m4wordlist_lastword(wid);
        while (w != NULL) {
            const m4string str = m4word_name(w);
            const linenoiseString completion = {str.n, (const char *)str.addr};
            if (m4th_c_string_is_prefix_of(input, completion)) {
                linenoiseAddCompletion(completions, completion);
            }
            w = m4word_prev(w);
        }
    }
    m4th_c_strings_sort(completions);
    m4th_c_strings_unique(completions);
    return input;
}
