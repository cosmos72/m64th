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

typedef struct m4th_s {
    void *data;
} m4th;

typedef struct instruction_s instruction;

struct instruction_s {
    long (*f)(long dtop, long *dstk, long rtop, long *rstk, const instruction *ip, m4th *m);
};

long m4equal(long dtop, long *dstk, long rtop, long *rstk, const instruction *ip, m4th *m) {
    long a = *dstk++;
    dtop = (a == dtop) ? 1 : 0;
    ++ip;
    return ip->f(dtop, dstk, rtop, rstk, ip, m);
}
