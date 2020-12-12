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

#ifndef M4TH_HASHMAP_STRING_H
#define M4TH_HASHMAP_STRING_H

#include "m64th.h"

#ifdef __cplusplus
extern "C" {
#endif

#define H(x) x##string

enum {
    H(m4hash_no_entry_) = (m4ucell)-1,
    H(m4hash_no_next_) = (m4ucell)-2,
};

typedef struct H(m4hashmap_entry_s_) {
    m4ucell next;
    m4ucell keyhash;
    H(m4) key;
    m4cell val;
} H(m4hashmap_entry_);

typedef struct H(m4hashmap_s_) {
    m4ucell size;
    m4ucell lcap; /* capacity is 1<<lcap */
    H(m4hashmap_entry_) * vec;
} H(m4hashmap_);

H(m4hashmap_) * H(m4hashmap_new_)(m4ucell capacity);
void H(m4hashmap_del_)(H(m4hashmap_) * map);
void H(m4hashmap_clear_)(H(m4hashmap_) * map);

/* find key in map. return NULL if not found */
const H(m4hashmap_entry_) * H(m4hashmap_find_)(const H(m4hashmap_) * map, H(m4) key);

/*
 * insert key and val. does not grow/rehash.
 * keeps a reference to key.addr, does NOT copy string contents.
 * returns NULL on failure (if map is too full or key is already present)
 */
const H(m4hashmap_entry_) * H(m4hashmap_insert_)(H(m4hashmap_) * map, H(m4) key, m4cell val);

#undef H

#ifdef __cplusplus
}
#endif

#endif /* M4TH_HASHMAP_STRING_H */
