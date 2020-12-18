package main

import (
	"fmt"
	"os"
	"strconv"
)

/* sum the numbers from 0 to n-1 */
func sum(n uintptr) uintptr {
	var ret uintptr
	for i := uintptr(0); i < n; i++ {
		ret += i
	}
	return ret
}

func main() {
	n := uintptr(1000000000)
	if len(os.Args) > 1 {
		n2, err := strconv.ParseUint(os.Args[1], 10, 64)
		if err == nil {
			n = uintptr(n2)
		}
	}
	fmt.Println(sum(n))
}
