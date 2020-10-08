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

#ifndef M4TH_HASH_MAP_COUNTEDSTRING_H
#define M4TH_HASH_MAP_COUNTEDSTRING_H

#include "../m4th.h"

#ifdef __cplusplus
extern "C" {
#endif

#define H(x) x##countedstring

enum {
    H(m4hash_no_entry_) = (m4char)-1,
    H(m4hash_no_next_) = (m4char)-2,
};

typedef struct m4hashmap_entry_s_string {
    m4char keylen;
    m4char key[255];
    m4cell val;
    m4ucell next;
} H(m4hashmap_entry_);

typedef struct H(m4hashmap_s_) {
    m4ucell size;
    m4ucell lcap; /* capacity is 1<<lcap */
    H(m4hashmap_entry_) * vec;
} H(m4hashmap_);

H(m4hashmap_) * H(m4hashmap_new_)(m4ucell capacity);
void H(m4hashmap_del_)(H(m4hashmap_) * map);

/* find key in map. return NULL if not found */
const H(m4hashmap_entry_) * H(m4hashmap_find_)(const H(m4hashmap_) * map, m4string key);

/*
 * insert key and val.
 * key MUST NOT be already present. does not grow/rehash.
 * returns NULL on failure (if map is too full)
 */
const H(m4hashmap_entry_) * H(m4hashmap_insert_)(H(m4hashmap_) * map, m4string key, m4cell val);

#undef H

#ifdef __cplusplus
}
#endif

#endif /* M4TH_HASH_MAP_COUNTEDSTRING_H */
