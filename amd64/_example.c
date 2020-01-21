/**
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

#include <stdint.h>

int64_t load(uint64_t *addr, uint64_t i) {
    return (long)addr[i];
}

int64_t load_sb(int8_t *addr, uint64_t i) {
    return (long)addr[i];
}
int64_t load_sh(int16_t *addr, uint64_t i) {
    return (long)addr[i];
}
int64_t load_sw(int32_t *addr, uint64_t i) {
    return (long)addr[i];
}

int64_t load_ub(uint8_t *addr, uint64_t i) {
    return (long)addr[i];
}
int64_t load_uh(uint16_t *addr, uint64_t i) {
    return (long)addr[i];
}
int64_t load_uw(uint32_t *addr, uint64_t i) {
    return (long)addr[i];
}

void stor_b(uint8_t *addr, uint64_t i, uint8_t val) {
    addr[i] = val;
}
void stor_h(uint16_t *addr, uint64_t i, uint16_t val) {
    addr[i] = val;
}
void stor_w(uint32_t *addr, uint64_t i, uint32_t val) {
    addr[i] = val;
}
void stor(uint64_t *addr, uint64_t i, uint64_t val) {
    addr[i] = val;
}
