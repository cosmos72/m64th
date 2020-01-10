#include "m4th.h"

#include <stdlib.h>   /* malloc(), free() */
#include <sys/mman.h> /* mmap(), munmap() */

enum { page_size = 4096 };

m4th* m4th_new() {
    m4th* interp = (m4th*)malloc(sizeof(m4th));
    interp->dstack = interp->dstack0 = (m_int*)malloc(page_size);
    interp->rstack = interp->rstack0 = (m_int*)malloc(page_size);
    interp->code = mmap(NULL, page_size, PROT_READ | PROT_WRITE | PROT_EXEC,
                        MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    return interp;
}

void m4th_free(m4th* interp) {
    munmap(interp->code, page_size);
    free(interp->rstack0);
    free(interp->dstack0);
    free(interp);
}

