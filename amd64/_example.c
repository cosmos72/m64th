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

#include <stddef.h> /* size_t    */

size_t string_equal(char *restrict src, size_t sn, char *restrict dst, size_t dn) {
    if (sn != dn) {
        return 0;
    }
    while (sn--) {
        if (*src++ != *dst++) {
            return 0;
        }
    }
    return (size_t)-1;
}

int main(void) {
}