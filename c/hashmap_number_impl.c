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

#include "../include/hashmap_number_impl.h"

static inline H(m6u) H(ceil_log_2_)(H(m6u) n) {
    m6ucell ret = 0;
    while ((1u << ret) < n) {
        ret++;
    }
    return ret;
}

H(m6hashmap_) * H(m6hashmap_new_)(H(m6u) capacity) {
    H(m6hashmap_) * map;
    const H(m6u) lcap = H(ceil_log_2_)(capacity);
    capacity = (H(m6u))1 << lcap;
    /* second half of map->vec[] is dedicated to collisions */
    map = (H(m6hashmap_) *)m6mem_allocate(sizeof(H(m6hashmap_)) +
                                          2 * capacity * sizeof(H(m6hashmap_entry_)));
    map->lcap = lcap;
    map->vec = (H(m6hashmap_entry_) *)(map + 1);
    H(m6hashmap_clear_)(map);
    return map;
}

void H(m6hashmap_clear_)(H(m6hashmap_) * map) {
    H(m6u) i, cap2x = (H(m6u))2 << map->lcap;
    map->size = 0;
    for (i = 0; i < cap2x; i++) {
        H(m6hashmap_entry_) *e = map->vec + i;
        e->key = 0;
        e->val = 0;
        e->next = H(m6hash_no_entry_);
    }
}

void H(m6hashmap_del_)(H(m6hashmap_) * map) {
    m6mem_free(map);
}

static inline m6cell H(m6hashmap_entry_present_)(const H(m6hashmap_entry_) * e) {
    return e->next != H(m6hash_no_entry_);
}

static inline m6cell H(m6hashmap_entry_next_)(const H(m6hashmap_entry_) * e) {
    return e->next != H(m6hash_no_next_);
}

static inline H(m6u) H(m6hashmap_indexof_)(const H(m6hashmap_) * map, H(m6) key) {
    H(m6u) hash = m64th_crc_cell(key);
    H(m6u) lcap = map->lcap;
    H(m6u) cap = 1u << lcap;
    if (sizeof(H(m6)) > 4 && lcap > 32) {
        hash *= hash - 0x13579bdf;
    }
    hash ^= (H(m6u))key;
    return (hash ^ (hash >> lcap)) & (cap - 1);
}

static const H(m6hashmap_entry_) *
    H(m6hashmap_find_in_collision_list_)(const H(m6hashmap_) * map, H(m6) key,
                                         const H(m6hashmap_entry_) * bucket) {
    while (key != bucket->key) {
        if (!H(m6hashmap_entry_next_)(bucket)) {
            return NULL;
        }
        bucket = map->vec + bucket->next;
    }
    return bucket;
}

/* find key in map. return NULL if not found */
const H(m6hashmap_entry_) * H(m6hashmap_find_)(const H(m6hashmap_) * map, H(m6) key) {
    if (map->size != 0) {
        const H(m6hashmap_entry_) *e = map->vec + H(m6hashmap_indexof_)(map, key);
        if (H(m6hashmap_entry_present_)(e)) {
            return H(m6hashmap_find_in_collision_list_)(map, key, e);
        }
    }
    return NULL;
}

static H(m6u) H(m6hash_pick_collision_index_)(H(m6hashmap_) * map, H(m6u) pos) {
    static const H(m6u) relprime[] = {5, 7, 9, 11};
    const H(m6u) step = relprime[pos & 3];
    const H(m6u) cap = (H(m6u))1 << map->lcap;
    for (H(m6u) i = 0; i < cap; i++) {
        /* second half of map->vec[] is dedicated to collisions */
        const H(m6u) collision_pos = cap + ((pos + i * step) & (cap - 1));
        const H(m6hashmap_entry_) *entry = map->vec + collision_pos;
        if (!H(m6hashmap_entry_present_)(entry)) {
            return collision_pos;
        }
    }
    return H(m6hash_no_entry_);
}

static void H(m6hash_store_)(H(m6hashmap_) * map, H(m6hashmap_entry_) * to, H(m6) key, m6cell val,
                             H(m6u) next) {
    to->key = key;
    to->val = val;
    to->next = next;
    map->size++;
}

/*
 * insert key and val. does not grow/rehash.
 * returns NULL on failure (if map is too full or key is already present)
 */
const H(m6hashmap_entry_) * H(m6hashmap_insert_)(H(m6hashmap_) * map, H(m6) key, m6cell val) {
    H(m6u) pos = H(m6hashmap_indexof_)(map, key);
    H(m6hashmap_entry_) *entry = map->vec + pos;
    if (!H(m6hashmap_entry_present_)(entry)) {
        H(m6hash_store_)(map, entry, key, val, H(m6hash_no_next_));
        return entry;
    } else if (H(m6hashmap_find_in_collision_list_)(map, key, entry)) {
        /* same key is already present, return NULL */
        return NULL;
    }
    pos = H(m6hash_pick_collision_index_)(map, pos);
    if (pos != H(m6hash_no_entry_)) {
        H(m6hashmap_entry_) *collision_entry = map->vec + pos;
        H(m6hash_store_)(map, collision_entry, key, val, entry->next);
        entry->next = pos;
        return collision_entry;
    }
    return NULL;
}
