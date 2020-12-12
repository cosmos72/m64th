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

#ifndef M6TH_HASHMAP_STRING_H
#define M6TH_HASHMAP_STRING_H

#include "m64th.h"

#ifdef __cplusplus
extern "C" {
#endif

#define H(x) x##string

enum {
    H(m6hash_no_entry_) = (m6ucell)-1,
    H(m6hash_no_next_) = (m6ucell)-2,
};

typedef struct H(m6hashmap_entry_s_) {
    m6ucell next;
    m6ucell keyhash;
    H(m6) key;
    m6cell val;
} H(m6hashmap_entry_);

typedef struct H(m6hashmap_s_) {
    m6ucell size;
    m6ucell lcap; /* capacity is 1<<lcap */
    H(m6hashmap_entry_) * vec;
} H(m6hashmap_);

H(m6hashmap_) * H(m6hashmap_new_)(m6ucell capacity);
void H(m6hashmap_del_)(H(m6hashmap_) * map);
void H(m6hashmap_clear_)(H(m6hashmap_) * map);

/* find key in map. return NULL if not found */
const H(m6hashmap_entry_) * H(m6hashmap_find_)(const H(m6hashmap_) * map, H(m6) key);

/*
 * insert key and val. does not grow/rehash.
 * keeps a reference to key.addr, does NOT copy string contents.
 * returns NULL on failure (if map is too full or key is already present)
 */
const H(m6hashmap_entry_) * H(m6hashmap_insert_)(H(m6hashmap_) * map, H(m6) key, m6cell val);

#undef H

#ifdef __cplusplus
}
#endif

#endif /* M6TH_HASHMAP_STRING_H */
