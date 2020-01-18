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

#include <string.h> /* strlen() */

#define dpush(val) (*--m->dstack.curr = (val))
#define dpop(val) (*m->dstack.curr++)

/** temporary C implementation of parse */
static void m4th_parse(m4th *m) {
    const char *word = NULL;
    if (m->parsed == NULL || (word = *m->parsed) == NULL) {
        *m->dstack.curr-- = 0;
        *m->dstack.curr-- = 0;
        return;
    }
    dpush((m4int)word);
    dpush(strlen(word));
    m->parsed++;
}

/** temporary C implementation of (lookup-word) */
static void m4th_lookup_word(m4th *m) {
}

/** temporary C implementation of (interpret) */
void m4th_interpret(m4th *m) {
}