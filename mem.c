#include "m4th.h"

#include <stdlib.h>   /* malloc(), free() */

enum {
      dstack_n = 256,
      rstack_n = 64,
      code_n   = 1024,
};

m4th* m4th_new() {
    m4th* interp = (m4th*)malloc(sizeof(m4th));
    interp->dstack = interp->dstack0 = dstack_n - 1 + (m_int*)malloc(dstack_n * sizeof(m_int));
    interp->rstack = interp->rstack0 = rstack_n - 1 + (m_int*)malloc(rstack_n * sizeof(m_int));
    interp->code = (m_int*)malloc(code_n * sizeof(m_int));
    interp->c_stack = NULL;
    return interp;
}

void m4th_free(m4th* interp) {
    free(interp->code);
    free(interp->rstack0 - (rstack_n - 1));
    free(interp->dstack0 - (dstack_n - 1));
    free(interp);
}

