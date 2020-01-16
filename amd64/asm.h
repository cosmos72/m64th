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

#ifndef M4TH_AMD64_ASM_H
#define M4TH_AMD64_ASM_H

#include "../macro.h"

#define SZ 8     /* width of registers, m4int and void* in bytes */
#define SZ2 16   /* SZ * 2 */
#define SZ3 24   /* SZ * 3 */
#define SZ4 32   /* SZ * 4 */
#define SZ5 40   /* SZ * 5 */
#define SZ6 48   /* SZ * 6 */
#define SZ7 56   /* SZ * 7 */
#define SZ8 64   /* SZ * 8 */
#define SZ9 72   /* SZ * 9 */
#define SZ10 80  /* SZ * 10 */
#define SZ12 96  /* SZ * 12 */
#define SZ13 104 /* SZ * 13 */
#define SZ15 120 /* SZ * 15 */
#define SZ16 128 /* SZ * 16 */
#define PSZ 3    /* (1 << PSZ) == SZ */

#define ISZ SZ /* size of a forth instruction in bytes */

#define IMM(constant) $constant /* immediate constant */

/* clang-format off */

/*
 * SYS-V ABI:
 * argument registers:     %rdi %rsi %rdx %rcx %r8 %r9
 * return   registers:     %rax %rdx
 * caller-saved registers: %r10 %r11 and argument/return registers
 * callee-saved registers: %rbx %rbp %rsp %r12 %r13 %r14 %r15
 */
#define REG1  %rax  /* scratch register 1 */
#define REG2  %rcx  /* scratch register 2 */
#define REG3  %rdx  /* scratch register 3 */
/* additional scratch registers: %r8 %r9 %r10 %r11 */
/* additional callee-saved registers: %rbp */

#define REG1b %al   /* low 8 bits of REG1 */

#define DTOP  %rbx  /* value of first data stack element */
#define DTOPb %bl   /* low 8 bits of DTOP */
#define DTOPh %bx   /* low 16 bits of DTOP */
#define DTOPw %ebx  /* low 32 bits of DTOP */

#define DSTK  %rsp  /* pointer to second data stack element */
#define IP    %rdi  /* forth instruction pointer */
#define RTOP  %rsi  /* value of first return stack element */
#define RSTK  %r12  /* pointer to second return stack element */
#define ISTK  %r13  /* pointer to code being compiled */
#define M4TH  %r14  /* pointer to C struct m4th */
#define RFFF  %r15  /* always contains -1 */
#define RIP   %rip  /* x86-64 instruction pointer */

#define AND2(src, dst)       and  src,     dst; /* dst &= src     */
#define ADD2(src, dst)       add  src,     dst; /* dst += src     */
#define AT0(addr)                 (addr)        /* addr[0]        */
#define ATx(addr, i)              i(addr)       /* addr[i]        */
#define LOAD(reg, mem)       mov  mem,     reg; /* reg  = *mem    */
#define MOVE(src, dst)       mov  src,     dst; /* dst  = src     */
#define MUL2(src, dst)       imul src,     dst; /* dst *= src     */
#define NEG1(dst)            neg  dst;          /* dst  = -dst    */
#define NOT1(dst)            not  dst;          /* dst  = ~dst    */
#define ORR2(src, dst)       or   src,     dst; /* dst |= src     */
#define SAR2(src, dst)       sar  src,     dst; /* dst >>= src    signed */
#define SUB2(src, dst)       sub  src,     dst; /* dst -= src     */
#define STOR(reg, mem)       mov  reg,     mem; /* *mem = reg     */
#define ZERO(dst)            xor  dst,     dst; /* dst  = 0       */

/* clang-format on */

#define IPUSH1(val) /* push val to code array */                                                   \
    mov val, (ISTK);                                                                               \
    addq IMM(SZ), (ISTK);

#define IPUSH2(a, b) /* push a, b to code array */                                                 \
    mov b, SZ(ISTK);                                                                               \
    mov a, (ISTK);                                                                                 \
    addq IMM(SZ2), (ISTK);

#define FADDR(fun, dst) lea fun(RIP), dst; /* load function address */

#define DPUSH(val) pushq val; /* push val to second data stack element */
#define DPOP(val) popq val;   /* pop second data stack element into val */

#define NEXT() /* jump to next instruction */                                                      \
    add $SZ, IP;                                                                                   \
    jmp *(IP);
#define NEXT2() /* skip next instruction, jump to following one */                                 \
    add $SZ2, IP;                                                                                  \
    jmp *(IP);

#define RPUSH(val) /* push val to second return stack element */                                   \
    sub $SZ, RSTK;                                                                                 \
    mov val, (RSTK);

#define RPOP(val) /* pop second return stack element into val */                                   \
    mov 0(RSTK), val;                                                                              \
    add $SZ, RSTK;

#endif /* M4TH_AMD64_ASM_H */
