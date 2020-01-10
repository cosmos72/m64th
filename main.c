#include "m4th.h"

int main(int argc, char* argv[]) {
    m4th* interp = m4th_new();
    m4th_free(interp);
    return 0;
}
