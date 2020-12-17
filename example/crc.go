package main

import "fmt"

var crc_table [256]uint32

func crc_init_1(n uint32) uint32 {
    for i := uint32(0); i < 8; i++ {
        if (n & 1) != 0 {
            n = (n >> 1) ^ 0xedb88320
        } else {
            n >>= 1
        }
    }
    return n
}


func init() {
    for n := uint32(0); n < 256; n++ {
        crc_table[n] = crc_init_1(n)
    }
}

func crc_add_byte(crc uint32, b uint8) uint32 {
    return (crc >> 8) ^ crc_table[uint8(crc) ^ b]
}

func crc_n_bytes(b uint8, n uintptr) uint32 {
    crc := uint32(0xffffffff)
    for i := uintptr(0); i < n; i++ {
        crc = crc_add_byte(crc, b)
    }
    return crc;
}

func main() {
    fmt.Println(crc_n_bytes('t', 100 * 1000 * 1000))
}
