#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

/* sum the numbers from 0 to n-1 */
size_t sum(size_t n) {
    size_t i, ret = 0;
    for (i = 0; i < n; i++) {
        ret += i;
    }
    return ret;
}

int main(int argc, char* argv[]) {
    size_t n = 1000000000;
    if (argc > 1) {
        n = strtoul(argv[1], NULL, 10);
    }
    printf("%lu\n", (unsigned long)sum(n));
}
