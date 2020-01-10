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

#include <stdio.h>

static void show_dstack(m4th* interp) {
    m_int* lo = interp->dstack;
    m_int* hi = interp->dstack0;
    printf("<%ld> ", (long)(hi - lo));
    while (hi != lo) {
        printf("%ld ", (long)*--hi);
    }
    putchar('\n');
}

static void add_sample_code(m_int* code) {
    *code++ = (m_int)m4th_literal;
    *code++ = 1;
    *code++ = (m_int)m4th_literal;
    *code++ = 2;
    *code++ = (m_int)m4th_literal;
    *code++ = 3;
    *code++ = (m_int)m4th_rot;
    *code++ = (m_int)m4th_bye;
}

int main(int argc, char* argv[]) {
    m4th* interp = m4th_new();
    m_int* code = interp->code;
    interp->rstack[0] = (m_int)code;

    add_sample_code(code);

    m4th_enter(interp);
    show_dstack(interp);
    m4th_free(interp);
    return 0;
}
