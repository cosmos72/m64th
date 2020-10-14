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

/******************************************************************************/
/* C implementation of hash map                                               */
/******************************************************************************/

#include "../include/hashmap_number_impl.h"

static inline H(m4u) H(ceil_log_2_)(H(m4u) n) {
    m4ucell ret = 0;
    while ((1u << ret) < n) {
        ret++;
    }
    return ret;
}

H(m4hashmap_) * H(m4hashmap_new_)(H(m4u) capacity) {
    H(m4hashmap_) * map;
    const H(m4u) lcap = H(ceil_log_2_)(capacity);
    capacity = (H(m4u))1 << lcap;
    /* second half of map->vec[] is dedicated to collisions */
    map = (H(m4hashmap_) *)m4mem_allocate(sizeof(H(m4hashmap_)) +
                                          2 * capacity * sizeof(H(m4hashmap_entry_)));
    map->lcap = lcap;
    map->vec = (H(m4hashmap_entry_) *)(map + 1);
    H(m4hashmap_clear_)(map);
    return map;
}

void H(m4hashmap_clear_)(H(m4hashmap_) * map) {
    H(m4u) i, cap2x = (H(m4u))2 << map->lcap;
    map->size = 0;
    for (i = 0; i < cap2x; i++) {
        H(m4hashmap_entry_) *e = map->vec + i;
        e->key = 0;
        e->val = 0;
        e->next = H(m4hash_no_entry_);
    }
}

void H(m4hashmap_del_)(H(m4hashmap_) * map) {
    m4mem_free(map);
}

static inline m4cell H(m4hashmap_entry_present_)(const H(m4hashmap_entry_) * e) {
    return e->next != H(m4hash_no_entry_);
}

static inline m4cell H(m4hashmap_entry_next_)(const H(m4hashmap_entry_) * e) {
    return e->next != H(m4hash_no_next_);
}

static inline H(m4u) H(m4hashmap_indexof_)(const H(m4hashmap_) * map, H(m4) key) {
    H(m4u) hash = m4th_crc_cell(key);
    H(m4u) lcap = map->lcap;
    H(m4u) cap = 1u << lcap;
    if (sizeof(H(m4)) > 4 && lcap > 32) {
        hash *= hash - 0x13579bdf;
    }
    hash ^= (H(m4u))key;
    return (hash ^ (hash >> lcap)) & (cap - 1);
}

static const H(m4hashmap_entry_) *
    H(m4hashmap_find_in_collision_list_)(const H(m4hashmap_) * map, H(m4) key,
                                         const H(m4hashmap_entry_) * bucket) {
    while (key != bucket->key) {
        if (!H(m4hashmap_entry_next_)(bucket)) {
            return NULL;
        }
        bucket = map->vec + bucket->next;
    }
    return bucket;
}

/* find key in map. return NULL if not found */
const H(m4hashmap_entry_) * H(m4hashmap_find_)(const H(m4hashmap_) * map, H(m4) key) {
    if (map->size != 0) {
        const H(m4hashmap_entry_) *e = map->vec + H(m4hashmap_indexof_)(map, key);
        if (H(m4hashmap_entry_present_)(e)) {
            return H(m4hashmap_find_in_collision_list_)(map, key, e);
        }
    }
    return NULL;
}

static H(m4u) H(m4hash_pick_collision_index_)(H(m4hashmap_) * map, H(m4u) pos) {
    static const H(m4u) relprime[] = {5, 7, 9, 11};
    const H(m4u) step = relprime[pos & 3];
    const H(m4u) cap = (H(m4u))1 << map->lcap;
    for (H(m4u) i = 0; i < cap; i++) {
        /* second half of map->vec[] is dedicated to collisions */
        const H(m4u) collision_pos = cap + ((pos + i * step) & (cap - 1));
        const H(m4hashmap_entry_) *entry = map->vec + collision_pos;
        if (!H(m4hashmap_entry_present_)(entry)) {
            return collision_pos;
        }
    }
    return H(m4hash_no_entry_);
}

static void H(m4hash_store_)(H(m4hashmap_) * map, H(m4hashmap_entry_) * to, H(m4) key, m4cell val,
                             H(m4u) next) {
    to->key = key;
    to->val = val;
    to->next = next;
    map->size++;
}

/*
 * insert key and val. does not grow/rehash.
 * returns NULL on failure (if map is too full or key is already present)
 */
const H(m4hashmap_entry_) * H(m4hashmap_insert_)(H(m4hashmap_) * map, H(m4) key, m4cell val) {
    H(m4u) pos = H(m4hashmap_indexof_)(map, key);
    H(m4hashmap_entry_) *entry = map->vec + pos;
    if (!H(m4hashmap_entry_present_)(entry)) {
        H(m4hash_store_)(map, entry, key, val, H(m4hash_no_next_));
        return entry;
    } else if (H(m4hashmap_find_in_collision_list_)(map, key, entry)) {
        // same key is already present, return NULL
        return NULL;
    }
    pos = H(m4hash_pick_collision_index_)(map, pos);
    if (pos != H(m4hash_no_entry_)) {
        H(m4hashmap_entry_) *collision_entry = map->vec + pos;
        H(m4hash_store_)(map, collision_entry, key, val, entry->next);
        entry->next = pos;
        return collision_entry;
    }
    return NULL;
}
