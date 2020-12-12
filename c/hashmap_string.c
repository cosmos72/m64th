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

/******************************************************************************/
/* C implementation of hash map                                               */
/******************************************************************************/

#include "../include/hashmap_string.h"

#define H(x) x##string

static inline m6ucell H(ceil_log_2_)(m6ucell n) {
    m6ucell ret = 0;
    while ((1u << ret) < n) {
        ret++;
    }
    return ret;
}

H(m6hashmap_) * H(m6hashmap_new_)(m6ucell capacity) {
    H(m6hashmap_) *map = (H(m6hashmap_) *)m6mem_allocate(sizeof(H(m6hashmap_)));
    map->lcap = H(ceil_log_2_)(capacity);
    capacity = (m6ucell)1 << map->lcap;
    /* second half of map->vec[] is dedicated to collisions */
    map->vec = (H(m6hashmap_entry_) *)m6mem_allocate(2 * capacity * sizeof(H(m6hashmap_entry_)));
    H(m6hashmap_clear_)(map);
    return map;
}

void H(m6hashmap_clear_)(H(m6hashmap_) * map) {
    m6ucell i, cap2x = (m6ucell)2 << map->lcap;
    map->size = 0;
    for (i = 0; i < cap2x; i++) {
        H(m6hashmap_entry_) *e = map->vec + i;
        e->next = H(m6hash_no_entry_);
        e->keyhash = 0;
        e->key.addr = NULL;
        e->key.n = 0;
        e->val = 0;
    }
}

void H(m6hashmap_del_)(H(m6hashmap_) * map) {
    if (map) {
        m6mem_free(map->vec);
        m6mem_free(map);
    }
}

static inline m6cell H(m6hashmap_entry_present_)(const H(m6hashmap_entry_) * e) {
    return e->next != H(m6hash_no_entry_);
}

static inline m6cell H(m6hashmap_entry_next_)(const H(m6hashmap_entry_) * e) {
    return e->next != H(m6hash_no_next_);
}

static inline m6ucell H(m6hashmap_indexof_)(const H(m6hashmap_) * map, m6string key,
                                            m6ucell keyhash) {
    m6ucell hash = keyhash;
    m6ucell lcap = map->lcap;
    m6ucell cap = (m6ucell)1 << lcap;
    if (lcap > 32) {
        hash *= hash - 0x13579bdf;
    }
    hash ^= key.n;
    return (hash ^ (hash >> lcap)) & (cap - 1);
}

static const H(m6hashmap_entry_) *
    H(m6hashmap_find_in_collision_list_)(const H(m6hashmap_) * map, m6string key, m6ucell keyhash,
                                         const H(m6hashmap_entry_) * bucket) {
    while (keyhash != bucket->keyhash || !m6string_equals(key, bucket->key)) {
        if (!H(m6hashmap_entry_next_)(bucket)) {
            return NULL;
        }
        bucket = map->vec + bucket->next;
    }
    return bucket;
}

/* find key in map. return NULL if not found */
const H(m6hashmap_entry_) * H(m6hashmap_find_)(const H(m6hashmap_) * map, m6string key) {
    if (map->size != 0) {
        const m6ucell keyhash = m64th_crc_string(key);
        const H(m6hashmap_entry_) *e = map->vec + H(m6hashmap_indexof_)(map, key, keyhash);
        if (H(m6hashmap_entry_present_)(e)) {
            return H(m6hashmap_find_in_collision_list_)(map, key, keyhash, e);
        }
    }
    return NULL;
}

static m6ucell H(m6hash_pick_collision_index_)(H(m6hashmap_) * map, m6ucell pos) {
    static const m6ucell relprime[] = {5, 7, 9, 11};
    const m6ucell step = relprime[pos & 3];
    const m6ucell cap = (m6ucell)1 << map->lcap;
    for (m6ucell i = 0; i < cap; i++) {
        /* second half of map->vec[] is dedicated to collisions */
        const m6ucell collision_pos = cap + ((pos + i * step) & (cap - 1));
        const H(m6hashmap_entry_) *entry = map->vec + collision_pos;
        if (!H(m6hashmap_entry_present_)(entry)) {
            return collision_pos;
        }
    }
    return H(m6hash_no_entry_);
}

static void H(m6hash_store_)(H(m6hashmap_) * map, H(m6hashmap_entry_) * to, m6string key,
                             m6ucell keyhash, m6cell val, m6ucell next) {
    to->next = next;
    to->keyhash = keyhash;
    to->key = key; /* keeps a reference to key.addr, does NOT copy string contents */
    to->val = val;
    map->size++;
}

/*
 * insert key and val. does not grow/rehash.
 * returns NULL on failure (if map is too full or key is already present)
 */
const H(m6hashmap_entry_) * H(m6hashmap_insert_)(H(m6hashmap_) * map, m6string key, m6cell val) {
    const m6ucell keyhash = m64th_crc_string(key);
    m6ucell pos = H(m6hashmap_indexof_)(map, key, keyhash);
    H(m6hashmap_entry_) *entry = map->vec + pos;
    if (!H(m6hashmap_entry_present_)(entry)) {
        H(m6hash_store_)(map, entry, key, keyhash, val, H(m6hash_no_next_));
        return entry;
    } else if (H(m6hashmap_find_in_collision_list_)(map, key, keyhash, entry)) {
        /* same key is already present, return NULL */
        return NULL;
    }
    pos = H(m6hash_pick_collision_index_)(map, pos);
    if (pos != H(m6hash_no_entry_)) {
        H(m6hashmap_entry_) *collision_entry = map->vec + pos;
        H(m6hash_store_)(map, collision_entry, key, keyhash, val, entry->next);
        entry->next = pos;
        return collision_entry;
    }
    return NULL;
}
