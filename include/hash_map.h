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

#ifndef M4TH_INCLUDE_HASH_MAP_H
#define M4TH_INCLUDE_HASH_MAP_H

#include "../m4th.h" /* m4cell_u, m4token */

#ifdef __cplusplus
extern "C" {
#endif

enum {
    m4hash_no_entry = (m4cell_u)-1,
    m4hash_no_next = (m4cell_u)-2,
};

typedef struct m4hash_entry_s {
    m4cell key;
    m4cell val;
    m4cell_u next_index;
} m4hash_entry;

typedef struct m4hash_map_s {
    m4cell_u size;
    m4cell_u lcap; /* capacity is 1<<lcap */
    m4hash_entry *vec;
} m4hash_map;

m4hash_map *m4hash_map_new(m4cell_u capacity);
void m4hash_map_del(m4hash_map *map);

// find key in map. return NULL if not found
const m4hash_entry *m4hash_map_find(const m4hash_map *map, m4cell key);

// insert key and val.
// key MUST NOT be already present. does not grow/rehash.
// returns NULL on failure (if map is too full)
const m4hash_entry *m4hash_map_insert(m4hash_map *map, m4cell key, m4cell val);

#ifdef __cplusplus
}
#endif

#endif /* M4TH_INCLUDE_HASH_MAP_H */
