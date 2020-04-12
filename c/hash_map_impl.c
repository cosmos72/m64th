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

static inline H(m4u) H(ceil_log_2_)(H(m4u) n) {
    m4ucell ret = 0;
    while ((1u << ret) < n) {
        ret++;
    }
    return ret;
}

H(m4hash_map_) * H(m4hash_map_new_)(H(m4u) capacity) {
    H(m4hash_map_) * map;
    H(m4u) i, lcap;
    lcap = H(ceil_log_2_)(capacity);
    capacity = 1 << (lcap + 1);
    map = (H(m4hash_map_) *)m4mem_allocate(sizeof(H(m4hash_map_)) +
                                           capacity * sizeof(H(m4hash_entry_)));
    map->size = 0;
    map->lcap = lcap;
    map->vec = (H(m4hash_entry_) *)(map + 1);
    for (i = 0; i < capacity; i++) {
        H(m4hash_entry_) *e = map->vec + i;
        e->key = 0;
        e->val = 0;
        e->next = H(m4hash_no_entry_);
    }
    return map;
}

void H(m4hash_map_del_)(H(m4hash_map_) * map) {
    m4mem_free(map);
}

static inline m4cell H(m4hash_entry_present_)(const H(m4hash_entry_) * e) {
    return e->next != H(m4hash_no_entry_);
}

static inline m4cell H(m4hash_entry_next_)(const H(m4hash_entry_) * e) {
    return e->next != H(m4hash_no_next_);
}

static inline H(m4u) H(m4hash_index_of_)(const H(m4hash_map_) * map, H(m4) key) {
    H(m4u) hash = m4th_crc_cell(key);
    H(m4u) lcap = map->lcap;
    H(m4u) cap = 1u << lcap;
    if (sizeof(H(m4)) > 4 && lcap > 32) {
        hash = (hash * (hash - 0x13579bdf)) ^ key;
    }
    return (hash ^ (hash >> lcap)) & (cap - 1);
}

static const H(m4hash_entry_) *
    H(m4hash_map_find_in_collision_list_)(const H(m4hash_map_) * map, H(m4) key,
                                          const H(m4hash_entry_) * bucket) {
    while (key != bucket->key) {
        if (!H(m4hash_entry_next_)(bucket)) {
            return NULL;
        }
        bucket = map->vec + bucket->next;
    }
    return bucket;
}

// find key in map. return NULL if not found
const H(m4hash_entry_) * H(m4hash_map_find_)(const H(m4hash_map_) * map, H(m4) key) {
    if (map->size != 0) {
        const H(m4hash_entry_) *e = map->vec + H(m4hash_index_of_)(map, key);
        if (H(m4hash_entry_present_)(e)) {
            return H(m4hash_map_find_in_collision_list_)(map, key, e);
        }
    }
    return NULL;
}

static H(m4u) H(m4hash_pick_collision_index_)(H(m4hash_map_) * map, H(m4u) pos) {
    static const H(m4u) relprime[] = {5, 7, 9, 11};
    const H(m4u) step = relprime[pos & 3];
    const H(m4u) cap = 1u << map->lcap;
    for (H(m4u) i = 0; i < cap; i++) {
        const H(m4u) collision_pos = cap + ((pos + i * step) & (cap - 1));
        const H(m4hash_entry_) *entry = map->vec + collision_pos;
        if (!H(m4hash_entry_present_)(entry)) {
            return collision_pos;
        }
    }
    return H(m4hash_no_entry_);
}

static void H(m4hash_store_)(H(m4hash_map_) * map, H(m4hash_entry_) * to, H(m4) key, m4cell val,
                             H(m4u) next) {
    to->key = key;
    to->val = val;
    to->next = next;
    map->size++;
}

// insert key and val.
// key MUST NOT be already present. does not grow/rehash.
// returns NULL on failure (if map is too full)
const H(m4hash_entry_) * H(m4hash_map_insert_)(H(m4hash_map_) * map, H(m4) key, m4cell val) {
    H(m4u) pos = H(m4hash_index_of_)(map, key);
    H(m4hash_entry_) *entry = map->vec + pos;
    if (!H(m4hash_entry_present_)(entry)) {
        H(m4hash_store_)(map, entry, key, val, H(m4hash_no_next_));
        return entry;
    }
    pos = H(m4hash_pick_collision_index_)(map, pos);
    if (pos != H(m4hash_no_entry_)) {
        H(m4hash_entry_) *collision_entry = map->vec + pos;
        H(m4hash_store_)(map, collision_entry, key, val, entry->next);
        entry->next = pos;
        return collision_entry;
    }
    return NULL;
}
