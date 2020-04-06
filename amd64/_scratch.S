/* clang-format off */

        .text

#include "asm.mh"

FUNC_START(loop_set_zero)
#if 0
        mov    $0,     %eax;
#elif 0
        xor    %eax,   %eax;
#elif 1
        lea    1(%r11),%rax;
#endif
        ADD4(  %rdi,   %rax, 1, %rdx)
        DEC1(  %rdi)
        JNZ(   %rdi,   FUNC(loop_set_zero))
        MOVE(  %rdi,   %rax)
FUNC_END(loop_set_zero)


#define m4fmain main
FUNC_START(main)
        MOVE(  IMM(1000000000), %rdi)
        MOVE(  IMM(-1),         %r11)
        ASM_CALL(      FUNC(loop_set_zero))
FUNC_END(main)


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
