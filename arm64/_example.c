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

typedef struct pair_s {
    long first, second;
} pair;

void m4question_dupe(long dtop, long *dstk) {
    if (dtop != 0) {
        *--dstk = dtop;
    }
}

long m4max(long a, long b) {
    return a > b ? a : b;
}

long div(long a, long b) {
    return a / b;
}

long rem(long a, long b) {
    return a % b;
}

pair div_rem(long a, long b) {
    pair ret = {a / b, a % b};
    return ret;
}
