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

#include <stdlib.h>   /* malloc(), free() */

enum {
      dstack_n = 256,
      rstack_n = 64,
      code_n   = 1024,
};

m4th* m4th_new() {
    m4th* interp = (m4th*)malloc(sizeof(m4th));
    interp->dstack = interp->dstack0 = dstack_n - 1 + (m4int*)malloc(dstack_n * sizeof(m4int));
    interp->rstack = interp->rstack0 = rstack_n - 1 + (m4int*)malloc(rstack_n * sizeof(m4int));
    interp->code = (m4int*)malloc(code_n * sizeof(m4int));
    interp->c_stack = NULL;
    return interp;
}

void m4th_free(m4th* interp) {
    free(interp->code);
    free(interp->rstack0 - (rstack_n - 1));
    free(interp->dstack0 - (dstack_n - 1));
    free(interp);
}

