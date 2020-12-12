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

#include "c_liblinenoise.h"
#include "../include/err.h"
#include "../include/m64th.mh" /* M6TH_OFF_ */
#include "../linenoise/linenoise.h"

#include <errno.h>   /* errno    */
#include <stdlib.h>  /* qsort() */
#include <strings.h> /* strncasecmp() */
#ifdef __unix__
#include <unistd.h> /* write()  */
#endif

#include "../linenoise/linenoise.c"

m6pair m64th_c_linenoise(const char *prompt, char *addr, size_t len) {
    m6pair ret = {};
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
        ret.err = m6err_c_errno - errno;
    } else {
        ret.err = m6err_unexpected_eof;
    }
    return ret;
}

static int m64th_c_string_is_prefix_of(linenoiseString prefix, linenoiseString str) {
    return str.len > prefix.len && !strncasecmp(str.addr, prefix.addr, prefix.len);
}

static m6cell m64th_c_string_equals(const linenoiseString a, const linenoiseString b) {
    if (a.len != b.len) {
        return tfalse;
    } else if (a.addr == b.addr || a.len == 0) {
        return ttrue;
    } else {
        return memcmp(a.addr, b.addr, a.len) == 0 ? ttrue : tfalse;
    }
}

static int m64th_c_string_compare(const void *left, const void *right) {
    const linenoiseString *a = (const linenoiseString *)left;
    const linenoiseString *b = (const linenoiseString *)right;
    const size_t alen = a->len, blen = b->len;
    int cmp = memcmp(a->addr, b->addr, min2(alen, blen));
    if (cmp != 0) {
        return cmp;
    }
    return alen < blen ? -1 : alen > blen ? 1 : 0;
}

static void m64th_c_strings_sort(linenoiseStrings *strings) {
    const size_t n = strings->size;
    if (n > 1) {
        qsort(strings->vec, n, sizeof(linenoiseString), m64th_c_string_compare);
    }
}

/* remove duplicates. note: strings must be already sorted */
static void m64th_c_strings_unique(linenoiseStrings *strings) {
    linenoiseString last = {};
    const size_t n = strings->size;
    size_t i = 0, j = 0;
    for (; i < n; i++) {
        linenoiseString curr = strings->vec[i];
        if (!m64th_c_string_equals(last, curr)) {
            strings->vec[j++] = last = curr;
        }
    }
    strings->size = j;
}

/* return != 0 if wid is present in searchorder */
static m6cell m64th_c_searchorder_find(const m6searchorder *searchorder, const m6wordlist *wid) {
    for (m6cell i = 0, n = searchorder->n; i < n; i++) {
        if (searchorder->addr[i] == wid) {
            return ttrue;
        }
    }
    return tfalse;
}

/* reverse searchorder */
static void searchorder_reverse(m6searchorder *s) {
    m6cell i, n;
    for (i = 0, n = s->n; i < n / 2; i++) {
        m6wordlist **wid1 = &s->addr[i];
        m6wordlist **wid2 = &s->addr[n - i - 1];
        m6wordlist *tmp = wid1[0];
        wid1[0] = wid2[0];
        wid2[0] = tmp;
    }
}

/* copy searchorder src to dst, ignoring repeated wordlists.
 * preserves wordlists priority i.e. relative ordering */
static void searchorder_copy_unique(const m6searchorder *src, m6searchorder *dst) {
    m6cell i, n;
    /* start from higher priority wordlists i.e. higher indexes */
    for (n = src->n, i = n - 1; i >= 0; i--) {
        m6wordlist *wid = src->addr[i];
        if (!m64th_c_searchorder_find(dst, wid)) {
            dst->addr[dst->n++] = wid;
        }
    }
    searchorder_reverse(dst);
}

/* callback invoked by linenoise() when user presses TAB to complete a word */
linenoiseString m64th_c_complete_word(linenoiseString input, linenoiseStrings *completions,
                                     void *userData) {
    m6searchorder searchorder = {};
    m64th *m = (m64th *)userData;
    m6cell i, n;
    for (n = input.len, i = n; i > 0; i--) {
        /* find last non-blank word in current input */
        if ((m6char)input.addr[i - 1] <= (m6char)' ') {
            break;
        }
    }
    input.len -= i;
    input.addr += i;

    searchorder_copy_unique(&m->searchorder, &searchorder);

    /* priority of each wordlist in searchorder does not matter here:  */
    /* we simply collect all words, and any duplicate due to shadowing */
    /* will be merged by m64th_c_strings_unique() below                 */
    for (i = 0, n = searchorder.n; i < n; i++) {
        const m6wordlist *wid = searchorder.addr[i];
        const m6word *w = m6wordlist_last_word(wid);
        while (w != NULL) {
            const m6string str = m6word_name(w);
            const linenoiseString completion = {str.n, (const char *)str.addr};
            if (m64th_c_string_is_prefix_of(input, completion)) {
                linenoiseAddCompletion(completions, completion);
            }
            w = m6word_prev(w);
        }
    }
    m64th_c_strings_sort(completions);
    m64th_c_strings_unique(completions);
    return input;
}

/* print all words in wordlist, using linenoiseStrings as a qsort buffer */
static void m64th_c_wordlist_print_all_words(const m6wordlist *wid, linenoiseStrings *strings,
                                            size_t columns, FILE *out) {
    const m6word *w = m6wordlist_last_word(wid);
    size_t i, n, line;
    strings->size = 0;
    while (w != NULL) {
        const m6string str = m6word_name(w);
        const linenoiseString lstr = {str.n, (const char *)str.addr};
        linenoiseAddCompletion(strings, lstr);
        w = m6word_prev(w);
    }
    m64th_c_strings_sort(strings);
    m64th_c_strings_unique(strings);

    fputs("\\ ------------- ", out);
    m6string_print(m6wordlist_name(wid), m6mode_user, out);
    fputs(" -------------\n", out);
    line = 0;
    for (i = 0, n = strings->size; i < n; i++) {
        linenoiseString str = strings->vec[i];
        if (line > 0 && line + str.len + 1 >= columns) {
            fputc('\n', out);
            line = 0;
        }
        fwrite(str.addr, sizeof(char), str.len, out);
        fputc(' ', out);
        line += 1 + str.len;
    }
    strings->size = 0;
}

/** temporary C implementation of 'words' */
void m64th_c_searchorder_print_all_words(const m6searchorder *searchorder, FILE *out) {
    m6searchorder s = {};
    linenoiseStrings strings = {};
    m6cell i, n;
    size_t columns = linenoiseGetTerminalColumns();

    searchorder_copy_unique(searchorder, &s);

    /* print wordlists with higher priority first */
    for (n = s.n, i = n - 1; i >= 0; i--) {
        fputs((i == n - 1 ? "\n" : "\n\n"), out);
        m64th_c_wordlist_print_all_words(s.addr[i], &strings, columns, out);
    }
    linenoiseFreeCompletions(&strings);
}

void m64th_c_print_all_words(const m64th *m) {
    m64th_c_searchorder_print_all_words(&m->searchorder, stdout);
}
