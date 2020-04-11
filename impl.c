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

#include "impl.h"
#include "include/err.h"
#include "include/hash_map.h"
#include "include/token.h"
#include "include/word_fwd.h"

#include <assert.h> /* assert()                   */
#include <errno.h>  /* errno                      */
#include <stdlib.h> /* strtol()                   */
#include <string.h> /* memcmp() memcpy() strlen() */

/** temporary C implementation of '.' */
void m4th_dot(m4cell n, m4iobuf *io) {
    m4cell_u len;
    enum { N = SZ * 3 + 2 }; /* large enough also for sign and final space */
    char buf[N];
    char *addr = buf + N;

    *--addr = ' ';

    if (n == 0) {
        *--addr = '0';
    } else {
        m4cell negative = n < 0;
        m4cell_u u = (m4cell_u)(negative ? -n : n);

        while (u != 0) {
            *--addr = (u % 10) + '0';
            u /= 10;
        }
        if (negative) {
            *--addr = '-';
        }
    }
    len = buf + N - addr;
    if (io->max - io->end >= len) {
        memcpy(io->addr + io->end, addr, len);
        io->end += len;
        return;
    }
}

/******************************************************************************/
/* C implementation of hash map                                               */
/******************************************************************************/

static inline m4cell_u ceil_log_2(m4cell_u n) {
    m4cell_u ret = 0;
    while ((1u << ret) < n) {
        ret++;
    }
    return ret;
}

m4hash_map *m4hash_map_new(m4cell_u capacity) {
    m4hash_map *map;
    m4cell_u i, lcap;
    lcap = ceil_log_2(capacity);
    capacity = 1 << (lcap + 1);
    map = (m4hash_map *)m4mem_allocate(sizeof(m4hash_map) + capacity * sizeof(m4hash_entry));
    map->size = 0;
    map->lcap = lcap;
    for (i = 0; i < capacity; i++) {
        m4hash_entry *e = map->vec + i;
        e->key = 0;
        e->val = 0;
        e->next_index = m4hash_no_entry;
    }
    return map;
}

void m4hash_map_del(m4hash_map *map) {
    m4mem_free(map);
}

static inline m4cell m4hash_entry_present(const m4hash_entry *e) {
    return e->next_index != m4hash_no_entry;
}

static inline m4cell m4hash_entry_next(const m4hash_entry *e) {
    return e->next_index != m4hash_no_next;
}

static inline uint32_t m4cell_crc(m4cell key) {
    return m4th_crcarray(&key, sizeof(key));
}

static inline m4cell_u m4hash_index_of(const m4hash_map *map, m4cell key) {
    m4cell_u hash = m4cell_crc(key);
    m4cell_u lcap = map->lcap;
    m4cell_u cap = 1u << lcap;
    if (SZ > 4 && lcap > 32) {
        hash = (hash * (hash - 0x13579bdf)) ^ key;
    }
    return (hash ^ (hash >> lcap)) & (cap - 1);
}

static const m4hash_entry *m4hash_map_find_in_collision_list(const m4hash_map *map, m4cell key,
                                                             const m4hash_entry *bucket) {
    while (key != bucket->key) {
        if (!m4hash_entry_next(bucket)) {
            return NULL;
        }
        bucket = map->vec + bucket->next_index;
    }
    return bucket;
}

// find key in map. return NULL if not found
const m4hash_entry *m4hash_map_find(const m4hash_map *map, m4cell key) {
    if (map->size != 0) {
        const m4hash_entry *e = map->vec + m4hash_index_of(map, key);
        if (m4hash_entry_present(e)) {
            return m4hash_map_find_in_collision_list(map, key, e);
        }
    }
    return NULL;
}

static m4cell_u m4hash_pick_collision_index(m4hash_map *map, m4cell_u pos) {
    static const m4cell_u relprime[] = {5, 7, 9, 11};
    const m4cell_u step = relprime[pos & 3];
    const m4cell_u cap = 1u << map->lcap;
    for (m4cell_u i = 0; i < cap; i++) {
        const m4cell_u collision_pos = cap + ((pos + i * step) & (cap - 1));
        const m4hash_entry *entry = map->vec + collision_pos;
        if (!m4hash_entry_present(entry)) {
            return collision_pos;
        }
    }
    return m4hash_no_entry;
}

static void m4hash_store(m4hash_map *map, m4hash_entry *to, m4cell key, m4cell val,
                         m4cell_u next_index) {
    to->key = key;
    to->val = val;
    to->next_index = next_index;
    map->size++;
}

// insert key and val.
// key MUST NOT be already present. does not grow/rehash.
// returns NULL on failure (if map is too full)
const m4hash_entry *m4hash_map_insert(m4hash_map *map, m4cell key, m4cell val) {
    m4cell_u pos = m4hash_index_of(map, key);
    m4hash_entry *entry = map->vec + pos;
    if (!m4hash_entry_present(entry)) {
        m4hash_store(map, entry, key, val, m4hash_no_next);
        return entry;
    }
    pos = m4hash_pick_collision_index(map, pos);
    if (pos != m4hash_no_entry) {
        m4hash_entry *collision_entry = map->vec + pos;
        m4hash_store(map, collision_entry, key, val, entry->next_index);
        entry->next_index = pos;
        return collision_entry;
    }
    return NULL;
}

/******************************************************************************/
/* C implementation of CRC32c                                                 */
/******************************************************************************/
m4cell m4th_crctable[256];

void m4th_crcinit(m4cell table[256]) {
    uint32_t i, j;

    if (table[255] != 0) {
        return;
    }
    for (i = 0; i < 256; i++) {
        uint32_t val = i;
        for (j = 0; j < 8; j++) {
            if (val & 1) {
                val >>= 1;
                /* 0x82f63b78 is crc-32c (Castagnoli). Use 0xedb88320 for vanilla crc-32. */
                val ^= 0x82f63b78;
            } else {
                val >>= 1;
            }
        }
        table[i] = val;
    }
}

uint32_t m4th_crc1byte(uint32_t crc, unsigned char byte) {
    return (crc >> 8) ^ m4th_crctable[(crc & 0xff) ^ byte];
}

uint32_t m4th_crcarray(const void *addr, const m4cell_u nbytes) {
    assert(m4th_crctable[0xff]);
    const m4char *p = (const m4char *)addr;
    uint32_t crc = ~(uint32_t)0;
    for (size_t i = 0; i < nbytes; i++) {
        crc = m4th_crc1byte(crc, p[i]);
    }
    return ~crc;
}

uint32_t m4th_crcstring(m4string str) {
    return m4th_crcarray(str.addr, str.n);
}

#if defined(__x86_64__)

#include <cpuid.h>

/* C wrapper for cpuid() */
static void m4th_cpuid(unsigned level, unsigned count, unsigned ret[4]) {
    unsigned max_level = __get_cpuid_max(level & 0x80000000ul, NULL);
    ret[0] = ret[1] = ret[2] = ret[3] = 0;
    if (max_level != 0 && level <= max_level) {
        __cpuid_count(level, count, ret[0], ret[1], ret[2], ret[3]);
    }
}

/* amd64: use cpuid to detect CRC32c CPU instructions - they are part of SSE4.2 */
m4cell m4th_cpu_features_detect(void) {
    unsigned ret[4];
    m4th_cpuid(1, 0, ret);
    return (ret[2] & bit_SSE4_2) ? m4th_cpu_feature_crc32c : 0;
}

#elif defined(__aarch64__) && defined(__linux__)

#include <asm/hwcap.h>
#include <sys/auxv.h>
/* arm64+Linux: use Linux specific getauxval(AT_HWCAP) to detect CRC32c CPU instructions */
m4cell m4th_cpu_features_detect(void) {
    unsigned long hwcap = getauxval(AT_HWCAP);
    return (hwcap & HWCAP_CRC32) ? m4th_cpu_feature_crc32c : 0;
}

#elif defined(__aarch64__) && defined(__ANDROID__)

#include <cpu-features.h>
/* arm64+Android: use Android specific android_getCpuFeatures() to detect CRC32c CPU instructions */
m4cell m4th_cpu_features_detect(void) {
    uint64_t features = android_getCpuFeatures();
    return (features & ANDROID_CPU_ARM64_FEATURE_CRC32) ? m4th_cpu_feature_crc32c : 0;
}

#else

/* no support to detect CRC32c CPU instructions on this arch/OS pair */
m4cell m4th_cpu_features_detect(void) {
    return m4th_cpu_feature_cannot_detect;
}

#endif

void m4th_cpu_features_autoenable() {
    m4th_cpu_features_enable(m4th_cpu_features_detect());
}
