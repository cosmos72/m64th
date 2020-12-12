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

#ifndef M64TH_IMPL_H
#define M64TH_IMPL_H

#include "include/m64th.h"

enum {
    tfalse = 0,
    ttrue = (m6cell)-1,
};

/** used for testing and benchmark */
extern m6cell m64th_crctable[256];
void m64th_crcinit(m6cell table[256]);
uint32_t m64th_crc1byte(uint32_t crc, unsigned char byte);
uint32_t m64th_crc_cell(m6cell key);
uint32_t m64th_crc_string(m6string str);
uint32_t m64th_crc_array(const void *addr, const m6ucell nbytes);

/**
 * detect and enable/disable optional CPU features:
 * CRC32c asm instructions, atomic increment instructions...
 */
enum {
    m64th_cpu_feature_cannot_detect = 1,
    m64th_cpu_feature_crc32c = 2,
    m64th_cpu_feature_atomic_add = 4,
};
m6cell m64th_cpu_features_detect(void);
void m64th_cpu_features_autoenable();
m6cell m64th_cpu_features_enabled(void);
void m64th_cpu_features_enable(m6cell mask);
void m64th_cpu_features_disable(m6cell mask);

#endif /* M64TH_IMPL_H */
