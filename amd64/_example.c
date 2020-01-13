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

long equals(long a, long b, long ttrue) {
    return a == b ? ttrue : 0;
}

long zero_equals(long a, long ttrue) {
    return a == 0 ? ttrue : 0;
}

long zero_less_than(long a) {
    return a < 0 ? -1 : 0;
}

long zero_greater_than(long a, long ttrue) {
    return a > 0 ? ttrue : 0;
}
