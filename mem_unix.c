#include "m4th.h"

#include <stdlib.h>   /* malloc(), free() */
#include <sys/mman.h> /* mmap(), munmap() */

enum {
      dstack_n = 256,
      rstack_n = 64,
      page_size = 4096,
};

m4th* m4th_new() {
    m4th* interp = (m4th*)malloc(sizeof(m4th));
    interp->dstack0 = dstack_n + (m_int*)malloc(dstack_n * sizeof(m_int));
    interp->rstack0 = rstack_n + (m_int*)malloc(rstack_n * sizeof(m_int));
    interp->dstack = interp->dstack0 - 1;
    interp->rstack = interp->rstack0 - 1;
    interp->code = mmap(NULL, page_size, PROT_READ | PROT_WRITE | PROT_EXEC,
                        MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    interp->c_stack = NULL;
    return interp;
}

void m4th_free(m4th* interp) {
    munmap(interp->code, page_size);
    free(interp->rstack0 - rstack_n);
    free(interp->dstack0 - dstack_n);
    free(interp);
}

