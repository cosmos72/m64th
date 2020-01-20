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

#ifndef M4TH_TEST_H
#define M4TH_TEST_H

#include "m4th.h"

enum { tfalse = (m4int)0, ttrue = (m4int)-1 };

void m4word_code_print(const m4word *w, FILE *out);

m4int m4th_testcompile(m4th *m, FILE *out);
m4int m4th_testexecute(m4th *m, FILE *out);

#endif /* M4TH_TEST_H */
