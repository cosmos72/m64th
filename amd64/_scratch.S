/* clang-format off */

        .text

#include "asm.mh"

FUNC_START(scratch_vm)
        call *(%rbp,   %r10,   SZ);
        call *(%rbp,   %r11,   SZ);
        call *(%r8,    %r10,   SZ);
        call *(%r8,    %r11,   SZ);
        call *(%r9,    %r10,   SZ);
        call *(%r9,    %r11,   SZ);
        call *(%r10,   %r10,   SZ);
        call *(%r10,   %r11,   SZ);
        call *(%r12,   %r10,   SZ);
        call *(%r12,   %r11,   SZ);
        call *(%r13,   %r10,   SZ);
        call *(%r13,   %r11,   SZ);
        call *(%r14,   %r10,   SZ);
        call *(%r14,   %r11,   SZ);
        call *(%r15,   %r10,   SZ);
        call *(%r15,   %r11,   SZ);
FUNC_END(scratch_vm)

