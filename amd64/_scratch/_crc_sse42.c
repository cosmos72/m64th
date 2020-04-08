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

#ifdef __x86_64__

#include <nmmintrin.h>
#include <stddef.h>
#include <stdint.h>

#pragma GCC push_options
#pragma GCC target("sse4.2")

/*
 * known collision on low 16 bits of CRC32c:
 * 68da62ec short!
 * fdab62ec (c-arg-4)
 */

/* must give same results as m4th_crc1byte() in impl.c */
uint32_t m4th_crc1byte_asm(uint32_t crc, unsigned char byte) {
    return _mm_crc32_u8(crc, byte);
}

/* must give same results as m4th_crcstring() in impl.c */
uint32_t m4th_crcstring_asm(const unsigned char *addr, const size_t n) {
    uint32_t crc = ~(uint32_t)0;
    size_t i = 0;
    for (; i + 8 <= n; i += 8) {
        crc = _mm_crc32_u64(crc, *(const uint64_t *)(addr + i));
    }
    if (i + 4 <= n) {
        crc = _mm_crc32_u32(crc, *(const uint32_t *)(addr + i));
        i += 4;
    }
    if (i + 2 <= n) {
        crc = _mm_crc32_u16(crc, *(const uint16_t *)(addr + i));
        i += 2;
    }
    if (i < n) {
        crc = _mm_crc32_u8(crc, addr[i]);
    }
    return ~crc;
}

#pragma GCC pop_options
#endif /* __x86_64__ */
