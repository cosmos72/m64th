#include "m4th.h"
#include "decl.h"

int main(int argc, char* argv[]) {
    m4th* interp = m4th_new();
    interp->rstack[0] = (m_int)m4th_bye;
    m4th_enter(interp);
    m4th_free(interp);
    return 0;
}
