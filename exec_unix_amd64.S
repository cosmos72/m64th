        .file "exec_unix_amd64.S"
        
#include "asm_amd64.h"
        
        .text

/**
 * enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in %rdi as per SYS V amd64 ABI,
 * execute m4th->rstack[0]
 */
FUNC_START(m4th_enter)
        pushq   %rbx;            /* save C registers */
        pushq   %rbp;
        pushq   %r12;
        pushq   %r13;
        pushq   %r14;
        pushq   %r15;
        movq    %rdi, M4TH;      /* interp                    */
        movq    %rsp, SZ5(M4TH); /* save C stack pointer      */
        movq    SZ(M4TH),  DSTK; /* load data   stack pointer */
        movq    SZ3(M4TH), RSTK; /* load return stack pointer */
        DPOP(DTOP)               /* load first data   stack element */
        RPOP(RTOP)               /* load first return stack element  */
        jmp     *(RTOP);         /* execute it */
FUNC_END(m4th_enter)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(m4th_bye)
        RPUSH(RTOP)              /* save first return stack element */
        DPUSH(DTOP)              /* save first data   stack element */
        movq    RSTK, SZ3(M4TH); /* save return stack pointer */
        movq    DSTK, SZ(M4TH);  /* save data   stack pointer */
        movq    SZ5(M4TH), %rsp; /* load C stack pointer */
        popq    %r15;            /* load C registers */
        popq    %r14;
        popq    %r13;
        popq    %r12;
        popq    %rbp;
        popq    %rbx;
        ret;
FUNC_END(m4th_bye)


        .ident "m4th 0.0.0"
        .section .note.GNU-stack,"",@progbits
