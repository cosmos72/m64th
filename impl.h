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

#ifndef M4TH_IMPL_H
#define M4TH_IMPL_H

#include "include/m4th.h"

enum {
    tfalse = 0,
    ttrue = (m4cell)-1,
};

/** temporary C implementation of '.' */
void m4th_dot(m4cell n, m4iobuf *io);

/** used for testing and benchmark */
extern m4cell m4th_crctable[256];
void m4th_crcinit(m4cell table[256]);
uint32_t m4th_crc1byte(uint32_t crc, unsigned char byte);
uint32_t m4th_crc_cell(m4cell key);
uint32_t m4th_crc_string(m4string str);
uint32_t m4th_crc_array(const void *addr, const m4ucell nbytes);

/**
 * detect and enable/disable optional CPU features:
 * CRC32c asm instructions, atomic increment instructions...
 */
enum {
    m4th_cpu_feature_cannot_detect = 1,
    m4th_cpu_feature_crc32c = 2,
    m4th_cpu_feature_atomic_add = 4,
};
m4cell m4th_cpu_features_detect(void);
void m4th_cpu_features_autoenable();
m4cell m4th_cpu_features_enabled(void);
void m4th_cpu_features_enable(m4cell mask);
void m4th_cpu_features_disable(m4cell mask);

#endif /* M4TH_IMPL_H */
