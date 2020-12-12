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

#ifdef __cplusplus
extern "C" {
#endif

enum {
    H(m6hash_no_entry_) = (H(m6u)) - 1,
    H(m6hash_no_next_) = (H(m6u)) - 2,
};

typedef struct H(m6hashmap_entry_s_) {
    m6cell val;
    H(m6) key;
    H(m6u) next;
} H(m6hashmap_entry_);

typedef struct H(m6hashmap_s_) {
    H(m6u) size;
    H(m6u) lcap; /* capacity is 1<<lcap */
    H(m6hashmap_entry_) * vec;
} H(m6hashmap_);

H(m6hashmap_) * H(m6hashmap_new_)(H(m6u) capacity);
void H(m6hashmap_clear_)(H(m6hashmap_) * map);
void H(m6hashmap_del_)(H(m6hashmap_) * map);

/* find key in map. return NULL if not found */
const H(m6hashmap_entry_) * H(m6hashmap_find_)(const H(m6hashmap_) * map, H(m6) key);

/*
 * insert key and val. does not grow/rehash.
 * returns NULL on failure (if map is too full or key is already present)
 */
const H(m6hashmap_entry_) * H(m6hashmap_insert_)(H(m6hashmap_) * map, H(m6) key, m6cell val);

#ifdef __cplusplus
}
#endif
