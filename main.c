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
#include "word_decl.h"

#include <stdio.h>

static void m4th_dict_print(const m4word *w, FILE *out) {
    if (out == NULL) {
        return;
    }
    while (w) {
        m4th_word_print(w, out);
        w = m4th_word_prev(w);
    }
}

int main(int argc, char *argv[]) {
    m4th *m = m4th_new();

    m4th_del(m);

    m4th_dict_print(&m4word_noop, stdout);
    m4th_dict_print(&m4word_bye, stdout);
    m4th_dict_print(&m4word_xor, stdout);

    /* suppress 'unused parameter' warning */
    return 0 & argc & (m4int)argv;
}
