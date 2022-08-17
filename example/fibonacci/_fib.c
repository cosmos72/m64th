#include <stddef.h>
#include <stdio.h>

/* recursive implementation of fibonacci sequence */
size_t fib(size_t n) {
    if (n > 2) {
        return fib(n - 1) + fib(n - 2);
    } else {
        return 1;
    }
}

int main(void) {
    printf("fibonacci(45) = %lu\n", (unsigned long)fib(45));
}
