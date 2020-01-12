/**
 * This file is part of m4th.
 *
 * m4th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m4th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m4th.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "asm.h"

/**
 * enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in %rdi as per SYS V amd64 ABI,
 * execute m4th->rstack[0] and subsequent code until m4th_bye is found.
 */
FUNC_START(m4th_enter)
        pushq   %rbx;            /* save C registers */
#if 0 /* not clobbered by m4th */
        pushq   %rbp;
#endif /* 0 */
        pushq   %r12;
        pushq   %r13;
        pushq   %r14;
        pushq   %r15;
        movq    %rdi, M4TH;      /* m                         */
        movq    %rsp, SZ7(M4TH); /* save C stack pointer      */
        movq    (M4TH),  DSTK;   /* load data   stack pointer */
        movq    SZ2(M4TH), RSTK; /* load return stack pointer */
        movq    SZ6(M4TH), IP;   /* load instruction  pointer */
        DPOP(DTOP)               /* load first data   stack element */
        RPOP(RTOP)               /* load first return stack element */
        MOVE(IMM(-1), RFFF)      /* set RFFF to -1 */
        jmp     *(IP);           /* begin execution */
FUNC_RAWEND(m4th_enter)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(m4bye)
        RPUSH(RTOP)              /* save first return stack element */
        DPUSH(DTOP)              /* save first data   stack element */
        movq    IP,   SZ6(M4TH); /* save instruction  pointer */
        movq    RSTK, SZ2(M4TH); /* save return stack pointer */
        movq    DSTK, (M4TH);    /* save data   stack pointer */
        movq    SZ7(M4TH), %rsp; /* load C stack pointer */
        popq    %r15;            /* load C registers */
        popq    %r14;
        popq    %r13;
        popq    %r12;
#if 0 /* not clobbered by m4th */
        popq    %rbp;
#endif /* 0 */
        popq    %rbx;
        ret;
FUNC_RAWEND(m4bye)
