package main

import "fmt"

/* recursive implementation of fibonacci sequence */
func fib(n uintptr) uintptr {
    if (n > 2) {
        return fib(n - 1) + fib(n - 2)
    } else {
        return 1
    }
}

func main() {
    fmt.Println(fib(40))
}
