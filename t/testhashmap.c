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

#include "../include/hashmap_number.h"
#include "../include/hashmap_string.h"
#include "testcommon.h"

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */

/* -------------- m4th_testhashmap_int -------------- */

m4cell m4th_testhashmap_int_opt2_rules(FILE *out) {
    m4ucell fail = 0;
    const m4string data = m4word_data(&WORD_SYM(_optimize_2token_), 0);
    const m4hashmap_int *map = (const m4hashmap_int *)data.addr;
    const m4int key = M4two | (M4pick << 16);
    const m4cell val = 1 | (M4hop << 16);
    const m4hashmap_entry_int *e = m4hashmap_find_int(map, key);
    if (e == NULL) {
        fprintf(out,
                "m4th_testhashmap_int_opt2_rules() returned NULL instead of expected value %u\n",
                (unsigned)val);
        fail++;
    } else if (e->val != val) {
        fprintf(out, "m4th_testhashmap_int_opt2_rules() returned %u instead of expected value %u\n",
                (unsigned)e->val, (unsigned)val);
        fail++;
    }
    return fail;
}

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
    n++, fail += m4th_testhashmap_int_opt2_rules(out);
    if (fail == 0) {
        fprintf(out, "all %3u hashmap/i tests passed\n", (unsigned)n);
    }
    m4hashmap_del_int(map);
    return fail;
}

/* -------------- m4th_testhashmap_string -------------- */

static void m4th_testhashmap_fill(m4string *key, m4ucell len) {
    m4char *addr = (m4char *)m4mem_allocate(len);
    memset(addr, (m4char)len | ' ', len);
    key->addr = addr;
    key->n = len;
}

m4cell m4th_testhashmap_string(FILE *out) {
    enum { n = 470 };
    m4string key, keys[n] = {};
    m4cell val;
    m4ucell i, cap = 256, fail = 0;
    m4hashmap_string *map = m4hashmap_new_string(cap);
    const m4hashmap_entry_string *e;
    for (i = 0; i < n; i++) {
        assert(map->size == i);
        m4th_testhashmap_fill(&key, i);
        keys[i] = key;
        val = i;
        if (!m4hashmap_insert_string(map, key, val)) {
            fprintf(out, "m4hashmap_string too full, failed to insert after %u elements\n",
                    (unsigned)i);
            fail++;
            break;
        }
        e = m4hashmap_find_string(map, key);
        if (!e) {
            fprintf(out,
                    "m4hashmap_find_string() failed after %u elements, returned NULL instead of "
                    "just-inserted key ",
                    (unsigned)i);
            m4string_print(key, m4mode_exact, out);
            fputc('\n', out);
            fail++;
            continue;
        } else if (!m4string_equals(key, e->key) || e->val != val) {
            fprintf(out, "m4hashmap_find_string() failed after %u elements, returned wrong entry {",
                    (unsigned)i);
            m4string_print(e->key, m4mode_exact, out);
            fprintf(out, ", 0x%lx} instead of just-inserted pair {", (long)e->val);
            m4string_print(key, m4mode_exact, out);
            fprintf(out, ", 0x%lx}\n", (long)val);
            fail++;
            continue;
        }
    }
    if (fail == 0) {
        fprintf(out, "all %3u hashmap/s tests passed\n", (unsigned)n);
    }
    m4hashmap_del_string(map);
    for (i = 0; i < n; i++) {
        m4mem_free((void *)keys[i].addr);
    }
    return fail;
}

#endif /* M4TH_T_TESTHASHMAP_C */
