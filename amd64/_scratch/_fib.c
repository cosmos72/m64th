#include <stddef.h>
#include <stdio.h>

size_t fib(size_t n) {
    if (n > 2) {
        return fib(n - 1) + fib(n - 2);
    }
    return 1;
}

int main() {
    printf("%lu\n", (unsigned long)fib(45));
}
