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

#include <errno.h>    /* errno */
#include <stdio.h>    /* fprinf() */
#include <stdlib.h>   /* exit(), free(), malloc() */
#include <string.h>   /* memset() */

enum {
      dstack_n = 256,
      rstack_n = 64,
      code_n   = 1024,
};

void* m4th_alloc(size_t bytes) {
    void* ret;
    if (bytes == 0) {
        return NULL;
    }
    ret = malloc(bytes);
    if (ret == NULL) {
        fprintf(stderr, "failed to allocate %lu bytes: %s\n", (unsigned long)bytes, strerror(errno));
        exit(1);
    }
    memset(ret, '\xFF', bytes);
    return ret;
}

m4th* m4th_new() {
    m4th* interp = (m4th*)m4th_alloc(sizeof(m4th));
    interp->dstack.end = dstack_n - 1 + (m4int*)m4th_alloc(dstack_n * sizeof(m4int));
    interp->rstack.end = rstack_n - 1 + (m4int*)m4th_alloc(rstack_n * sizeof(m4int));
    interp->code.begin = interp->ip =   (m4int*)m4th_alloc(code_n * sizeof(m4int));

    interp->dstack.begin = interp->dstack.end;
    interp->rstack.begin = interp->rstack.end;
    interp->code.end = interp->code.begin + code_n;

    interp->c_stack = NULL;
    return interp;
}

void m4th_del(m4th* interp) {
    free(interp->code.begin);
    free(interp->rstack.end - (rstack_n - 1));
    free(interp->dstack.end - (dstack_n - 1));
    free(interp);
}

