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

#ifndef M4TH_T_TESTHASHMAP_C
#define M4TH_T_TESTHASHMAP_C

#include "../include/hashmap.h"
#include "../include/hashmap_countedstring.h"
#include "testcommon.h"

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */

/* -------------- m4th_testhashmap_int -------------- */

m4cell m4th_testhashmap_int(FILE *out) {
    m4ucell i, n = 512, cap = 256, fail = 0;
    m4hashmap_int *map = m4hashmap_new_int(cap);
    m4int key;
    m4cell val;
    const m4hashmap_entry_int *e;
    for (i = 0; i < n; i++) {
        assert(map->size == i);
        key = i;
        val = i;
        if (!m4hashmap_insert_int(map, key, val)) {
            fprintf(out, "m4hashmap_int too full, failed to insert after %u elements\n",
                    (unsigned)map->size);
            fail++;
            break;
        }
        e = m4hashmap_find_int(map, key);
        if (!e) {
            fprintf(out, "m4hashmap_find_int() returned NULL instead of just-inserted key %u\n",
                    (unsigned)key);
            fail++;
            continue;
        } else if (e->key != key || e->val != val) {
            fprintf(
                out,
                "m4hashmap_find_int() returned wrong entry {0x%x, 0x%x} instead of just-inserted "
                "pair {0x%x, 0x%x}\n",
                (unsigned)e->key, (unsigned)e->val, (unsigned)key, (unsigned)val);
            fail++;
            continue;
        }
    }
    if (fail == 0) {
        fprintf(out, "all %3u hashmap/i tests passed\n", (unsigned)n);
    }
    m4hashmap_del_int(map);
    return fail;
}

/* -------------- m4th_testhashmap_countedstring -------------- */

enum { MAXLEN = 255 };

static void m4th_testhashmap_fill(m4string *key, m4ucell i) {
    m4char *addr = (m4char *)key->addr;
    m4ucell j, n = 0;
    for (j = 0; j < MAXLEN && i; j++) {
        addr[j] = (i & 1) ? 'x' : ' ';
        i >>= 1;
        n++;
    }
    key->n = n;
}

m4cell m4th_testhashmap_countedstring(FILE *out) {
    m4char keybuf[MAXLEN + 1];
    m4string key = {keybuf, 0};
    m4cell val;
    m4ucell i, n = 436, cap = 256, fail = 0;
    m4hashmap_countedstring *map = m4hashmap_new_countedstring(cap);
    const m4hashmap_entry_countedstring *e;
    for (i = 0; i < n; i++) {
        assert(map->size == i);
        m4th_testhashmap_fill(&key, i);
        val = i;
        if (!m4hashmap_insert_countedstring(map, key, val)) {
            fprintf(out, "m4hashmap_countedstring too full, failed to insert after %u elements\n",
                    (unsigned)i);
            fail++;
            break;
        }
        e = m4hashmap_find_countedstring(map, key);
        if (!e) {
            fputs("m4hashmap_find_countedstring() returned NULL instead of just-inserted key \"",
                  out);
            m4string_print(key, out);
            fputs("\"\n", out);
            fail++;
            continue;
        } else if (!m4string_equals(key, m4string_make(e->key, e->keylen)) || e->val != val) {
            fputs("m4hashmap_find_countedstring() returned wrong entry {\"", out);
            m4string_print(m4string_make(e->key, e->keylen), out);
            fprintf(out, "\", 0x%lx} instead of just-inserted pair {\"", (long)e->val);
            m4string_print(key, out);
            fprintf(out, "\", 0x%lx}\n", (long)val);
            fail++;
            continue;
        }
    }
    if (fail == 0) {
        fprintf(out, "all %3u hashmap/s tests passed\n", (unsigned)n);
    }
    m4hashmap_del_countedstring(map);
    return fail;
}

#endif /* M4TH_T_TESTHASHMAP_C */
