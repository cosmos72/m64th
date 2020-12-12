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

#include <stddef.h>

typedef struct pair_s {
    long first, second;
} pair;

const size_t *m6word_prev(const size_t *w) {
    size_t delta = w[0];
    return delta ? (const size_t *)((size_t)w - delta) : NULL;
}

long m6max(long a, long b) {
    return a > b ? a : b;
}

long m6min(long a, long b) {
    return a < b ? a : b;
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
