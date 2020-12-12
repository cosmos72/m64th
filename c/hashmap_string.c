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

static inline m4ucell H(ceil_log_2_)(m4ucell n) {
    m4ucell ret = 0;
    while ((1u << ret) < n) {
        ret++;
    }
    return ret;
}

H(m4hashmap_) * H(m4hashmap_new_)(m4ucell capacity) {
    H(m4hashmap_) *map = (H(m4hashmap_) *)m4mem_allocate(sizeof(H(m4hashmap_)));
    map->lcap = H(ceil_log_2_)(capacity);
    capacity = (m4ucell)1 << map->lcap;
    /* second half of map->vec[] is dedicated to collisions */
    map->vec = (H(m4hashmap_entry_) *)m4mem_allocate(2 * capacity * sizeof(H(m4hashmap_entry_)));
    H(m4hashmap_clear_)(map);
    return map;
}

void H(m4hashmap_clear_)(H(m4hashmap_) * map) {
    m4ucell i, cap2x = (m4ucell)2 << map->lcap;
    map->size = 0;
    for (i = 0; i < cap2x; i++) {
        H(m4hashmap_entry_) *e = map->vec + i;
        e->next = H(m4hash_no_entry_);
        e->keyhash = 0;
        e->key.addr = NULL;
        e->key.n = 0;
        e->val = 0;
    }
}

void H(m4hashmap_del_)(H(m4hashmap_) * map) {
    if (map) {
        m4mem_free(map->vec);
        m4mem_free(map);
    }
}

static inline m4cell H(m4hashmap_entry_present_)(const H(m4hashmap_entry_) * e) {
    return e->next != H(m4hash_no_entry_);
}

static inline m4cell H(m4hashmap_entry_next_)(const H(m4hashmap_entry_) * e) {
    return e->next != H(m4hash_no_next_);
}

static inline m4ucell H(m4hashmap_indexof_)(const H(m4hashmap_) * map, m4string key,
                                            m4ucell keyhash) {
    m4ucell hash = keyhash;
    m4ucell lcap = map->lcap;
    m4ucell cap = (m4ucell)1 << lcap;
    if (lcap > 32) {
        hash *= hash - 0x13579bdf;
    }
    hash ^= key.n;
    return (hash ^ (hash >> lcap)) & (cap - 1);
}

static const H(m4hashmap_entry_) *
    H(m4hashmap_find_in_collision_list_)(const H(m4hashmap_) * map, m4string key, m4ucell keyhash,
                                         const H(m4hashmap_entry_) * bucket) {
    while (keyhash != bucket->keyhash || !m4string_equals(key, bucket->key)) {
        if (!H(m4hashmap_entry_next_)(bucket)) {
            return NULL;
        }
        bucket = map->vec + bucket->next;
    }
    return bucket;
}

/* find key in map. return NULL if not found */
const H(m4hashmap_entry_) * H(m4hashmap_find_)(const H(m4hashmap_) * map, m4string key) {
    if (map->size != 0) {
        const m4ucell keyhash = m64th_crc_string(key);
        const H(m4hashmap_entry_) *e = map->vec + H(m4hashmap_indexof_)(map, key, keyhash);
        if (H(m4hashmap_entry_present_)(e)) {
            return H(m4hashmap_find_in_collision_list_)(map, key, keyhash, e);
        }
    }
    return NULL;
}

static m4ucell H(m4hash_pick_collision_index_)(H(m4hashmap_) * map, m4ucell pos) {
    static const m4ucell relprime[] = {5, 7, 9, 11};
    const m4ucell step = relprime[pos & 3];
    const m4ucell cap = (m4ucell)1 << map->lcap;
    for (m4ucell i = 0; i < cap; i++) {
        /* second half of map->vec[] is dedicated to collisions */
        const m4ucell collision_pos = cap + ((pos + i * step) & (cap - 1));
        const H(m4hashmap_entry_) *entry = map->vec + collision_pos;
        if (!H(m4hashmap_entry_present_)(entry)) {
            return collision_pos;
        }
    }
    return H(m4hash_no_entry_);
}

static void H(m4hash_store_)(H(m4hashmap_) * map, H(m4hashmap_entry_) * to, m4string key,
                             m4ucell keyhash, m4cell val, m4ucell next) {
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
const H(m4hashmap_entry_) * H(m4hashmap_insert_)(H(m4hashmap_) * map, m4string key, m4cell val) {
    const m4ucell keyhash = m64th_crc_string(key);
    m4ucell pos = H(m4hashmap_indexof_)(map, key, keyhash);
    H(m4hashmap_entry_) *entry = map->vec + pos;
    if (!H(m4hashmap_entry_present_)(entry)) {
        H(m4hash_store_)(map, entry, key, keyhash, val, H(m4hash_no_next_));
        return entry;
    } else if (H(m4hashmap_find_in_collision_list_)(map, key, keyhash, entry)) {
        /* same key is already present, return NULL */
        return NULL;
    }
    pos = H(m4hash_pick_collision_index_)(map, pos);
    if (pos != H(m4hash_no_entry_)) {
        H(m4hashmap_entry_) *collision_entry = map->vec + pos;
        H(m4hash_store_)(map, collision_entry, key, keyhash, val, entry->next);
        entry->next = pos;
        return collision_entry;
    }
    return NULL;
}
