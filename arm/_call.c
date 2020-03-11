#include <stdint.h>

void foo(void);

void *addrof_symbol(void) {
    return (void *)foo;
}

int call_func(void) {
    foo();
}

void tail_call_func(void) {
    foo();
}

int call_reg(void (*f)(void)) {
    f();
    return 0;
}

void tail_call_reg(void (*f)(void)) {
    f();
}
