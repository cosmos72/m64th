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

#ifndef M4TH_IMPL_H
#define M4TH_IMPL_H

#include "m4th.h"

typedef struct m4string_s m4string;

struct m4string_s {
    const char *addr;
    m4int len;
};

void m4th_string_print(m4string str, FILE *out);

m4int m4th_string_equals(m4string a, const m4countedstring *b);

/* warning: str must end with '\0' */
static m4int m4th_string_to_int(m4string str, m4int *out_n);

/** temporary C implementation of (interpret-word) */
m4int m4th_interpret_word(m4th *m, const m4word *w);

/** temporary C implementation of (compile-number) */
m4int m4th_compile_number(m4th *m, m4int n);

/** temporary C implementation of (interpret) */
m4int m4th_interpret(m4th *m);

/** temporary C implementation of (interpret-loop) */
void m4th_interpret_loop(m4th *m);

#endif /* M4TH_IMPL_H */
