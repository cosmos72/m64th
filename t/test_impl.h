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

#ifndef M4TH_T_TEST_IMPL_H
#define M4TH_T_TEST_IMPL_H

#include "../test.h"

enum {
    tfalse = (m4long)0,
    ttrue = (m4long)-1,
    SZ = sizeof(m4long),
    ISZ = sizeof(m4enum),
    m4enum_per_m4long = (SZ + ISZ - 1) / SZ, /* # of m4enum needed to store an m4long */
    callsz = 1 + m4enum_per_m4long,
};

/** padding needed for element-to-element conversion from m4long[] to m4enum[] */
#define CELL(n) (m4long)(n), 0, 0, 0
#define CALLXT(name) m4_call_, CELL(m4word_##name.code)

#endif /* M4TH_T_TEST_IMPL_H */
