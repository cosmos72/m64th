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

#include "m4th.h"
#include "decl.h"

#include <stdio.h>  /* fprintf() */
#include <string.h> /* memcpy() */

void m4th_print_dstack(FILE* out, m4th* interp) {
    m4int* lo = interp->dstack.begin;
    m4int* hi = interp->dstack.end;
    fprintf(out, "<%ld> ", (long)(hi - lo));
    while (hi != lo) {
        fprintf(out, "%ld ", (long)*--hi);
    }
    fputc('\n', out);
}

static void add_sample_code(m4int* code) {
    static const m4int sample[] =
        { (m4int)m4literal, 1,
          (m4int)m4literal, 2,
          (m4int)m4literal, 3,
          (m4int)m4rot,
          (m4int)m4bye,
        };
    memcpy(code, sample, sizeof(sample));
}

int main(int argc, char* argv[]) {
    m4th* interp = m4th_new();

    m4int* code = interp->code.begin;
    interp->rstack.begin[0] = (m4int)code;
    add_sample_code(code);

    m4th_enter(interp);
    m4th_print_dstack(stdout, interp);
    m4th_del(interp);
    return 0;
}
