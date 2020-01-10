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
