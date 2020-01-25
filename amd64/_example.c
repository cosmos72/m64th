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

void store(char *addr, long i, long val) {
    *(long *)(addr + i * 2) = val;
}

void store_sb(char *addr, long i, int8_t val) {
    *(int8_t *)(addr + i * 2) = val;
}
void store_sh(char *addr, long i, int16_t val) {
    *(int16_t *)(addr + i * 2) = val;
}
void store_sw(char *addr, long i, int32_t val) {
    *(int32_t *)(addr + i * 2) = val;
}
