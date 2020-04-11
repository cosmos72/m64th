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

#include "../include/hash_map.h"
#include "testcommon.h"

#include <assert.h> /* assert() */
#include <stdio.h>  /* fprintf() fputs() */

/* -------------- m4testhash_map -------------- */

m4cell m4th_testhash_map(FILE *out) {
    m4cell_u i, n = 512, cap = 256, fail = 0;
    m4hash_map *map = m4hash_map_new(cap);
    m4cell key;
    m4cell val;
    const m4hash_entry *e;
    for (i = 0; i < n; i++) {
        assert(map->size == i);
        key = i;
        val = i;
        if (!m4hash_map_insert(map, key, val)) {
            fprintf(out, "m4hash_map too full, failed to insert after %u elements\n",
                    (unsigned)map->size);
            fail++;
            break;
        }
        e = m4hash_map_find(map, key);
        if (!e) {
            fprintf(out, "m4hash_map_find() returned NULL instead of just-inserted key %u\n",
                    (unsigned)key);
            fail++;
            continue;
        } else if (e->key != key || e->val != val) {
            fprintf(out,
                    "m4hash_map_find() returned wrong entry {0x%x, 0x%x} instead of just-inserted "
                    "pair {0x%x, 0x%x}\n",
                    (unsigned)e->key, (unsigned)e->val, (unsigned)key, (unsigned)val);
            fail++;
            continue;
        }
    }
    if (fail == 0) {
        fprintf(out, "all %3u hashmap tests passed\n", (unsigned)n);
    }
    return fail;
}

#endif /* M4TH_T_TESTHASHMAP_C */
