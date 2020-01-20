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

#ifndef M4TH_ARM64_ASM_H
#define M4TH_ARM64_ASM_H

#include "../common/asm.h"

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
#define SZ11 88  /* SZ * 11 */
#define SZ12 96  /* SZ * 12 */
#define SZ13 104 /* SZ * 13 */
#define SZ15 120 /* SZ * 15 */
#define SZ16 128 /* SZ * 16 */
#define PSZ 3    /* (1 << PSZ) == SZ */

#define ISZ SZ   /* size of a forth instruction in bytes */

#define IMM(constant) constant /* immediate constant */

/* clang-format off */

/*
 * aarch64 ABI:
 * argument registers:     x0 ... x7
 * return   registers:     x0 x1. also x8 for wider returns
 * caller-saved registers: x9 ... x17 and argument/return registers
 * callee-saved registers: x18 ... x30 and sp (i.e. x31)
 */

#define REG1  x0 /* scratch register 1 */
#define REG2  x1 /* scratch register 2 */
#define REG3  x2 /* scratch register 3 */
/* additional scratch registers:      x3 .. x17           */
/* additional callee-saved registers: x18 x19 x27 ... x30 */

#define REG1b w0    /* low 8 bits of REG1 */
#define REG1h w0    /* low 16 bits of REG1 */
#define REG1w w0    /* low 32 bits of REG1 */
#define REG1_ub w0  /* zero-extend  8 bits into REG1 */
#define REG1_uh w0  /* zero-extend 16 bits into REG1 */
#define REG1_uw w0  /* zero-extend 32 bits into REG1 */
#define REG1_sb w0  /* sign-extend  8 bits into REG1 */
#define REG1_sh w0  /* sign-extend 16 bits into REG1 */
#define REG1_sw w0  /* sign-extend 32 bits into REG1 */

#define DTOP  x20 /* value of first data stack element */
#define DTOPb w20    /* low 8 bits of DTOP */
#define DTOPh w20    /* low 16 bits of DTOP */
#define DTOPw w20    /* low 32 bits of DTOP */
#define DTOP_ub w20  /* zero-extend  8 bits into DTOP */
#define DTOP_uh w20  /* zero-extend 16 bits into DTOP */
#define DTOP_uw w20  /* zero-extend 32 bits into DTOP */
#define DTOP_sb w20  /* sign-extend  8 bits into DTOP */
#define DTOP_sh w20  /* sign-extend 16 bits into DTOP */
#define DTOP_sw w20  /* sign-extend 32 bits into DTOP */


#define DSTK  x21 /* pointer to second data stack element */
#define IP    x22 /* instruction pointer */
#define RTOP  x23 /* value of first return stack element */
#define RSTK  x24 /* pointer to second return stack element */
#define M4W   x25 /* pointer to word being compiled */
#define M4TH  x26 /* pointer to C struct m4th */


#define ADD2(src,dst)    add  dst, dst, src;    /* dst += src     */
#define ADD3(a,b,dst)    add  dst, a, b;        /* dst  = a + b   */
#define AND2(src,dst)    and  dst, dst, src;    /* dst &= src     */
#define AT0(addr)             [addr]            /* addr[0]        */
#define ATx(addr, i)          [addr, i]         /* addr[i]        */
#define DIV3(a,b,dst)    sdiv dst, a, b;        /* dst  = a / b   */
#define LOAD(reg,mem)    ldr  reg, mem;         /* reg  = *mem    */
#define MOVE(src,dst)    mov  dst, src;         /* dst  = src     */
#define MUL2(src,dst)    mul  dst, dst, src;    /* dst *= src     */
#define NEG1(dst)        neg  dst, dst;         /* dst  = -dst    */
#define NOT1(dst)        mvn  dst, dst;         /* dst  = ~dst    */
#define ORR2(src,dst)    orr  dst, dst, src;    /* dst |= src     */
#define SAR2(src,dst)    asr  dst, dst, src;    /* dst >>= src    signed   */
#define SHL2(src,dst)    lsl  dst, dst, src;    /* dst <<= src    */
#define SUB2(src,dst)    sub  dst, dst, src;    /* dst -= src     */
#define SUB3(a,b,dst)    sub  dst, a, b;        /* dst  = a - b   */
#define STOR(reg,mem)    str  reg, mem;         /* *mem = reg     */
#define ZERO(dst)        mov  dst, 0;           /* dst  = 0       */

#define LOAD_sb(reg, mem)  ldrsb  mem,     reg; /* reg = *(int8_t *)mem */
#define LOAD_sh(reg, mem)  ldrhs  mem,     reg; /* reg = *(int16_t*)mem */
#define LOAD_sw(reg, mem)  ldrsw  mem,     reg; /* reg = *(int32_t*)mem */

#define LOAD_ub(reg, mem)  ldrb   mem,     reg; /* reg = *(uint8_t *)mem */
#define LOAD_uh(reg, mem)  ldrw   mem,     reg; /* reg = *(uint16_t*)mem */
#define LOAD_uw(reg, mem)  ldr    mem,     reg; /* reg = *(uint32_t*)mem */

/* no difference between signed and unsigned STOR* */
#define STORb(reg, mem)    strb   reg,     mem; /* *(uint8_t *)mem = reg */
#define STORh(reg, mem)    strw   reg,     mem; /* *(uint16_t*)mem = reg */
#define STORw(reg, mem)    str    reg,     mem; /* *(uint32_t*)mem = reg */

#if 0
#define IPUSH1(val)   /* push val to code array */  \
    str   val, [ISTK], SZ;

#define IPUSH2(a, b)  /* push a, b to code array */ \
    str   b,   [ISTK,  SZ];                         \
    str   a,   [ISTK], SZ2;
#endif /* 0 */

#define FADDR(fun, dst) /* load function address */ \
    adrp  dst,  fun;             /* high 21 bits */ \
    add   dst,  dst,  :lo12:fun; /* low  12 bits */

#define DPUSH(val)    str       val, [DSTK, -SZ]!; /* push val to second data stack element */
#define DPOP(val)     ldr       val, [DSTK], SZ;   /* pop second data stack element into val */

/* jump to current instruction. useful after manually updating IP */
#define NEXT0()       ldr       REG1, [IP];        \
                      br        REG1;
#define NEXT()        ldr       REG1, [IP, SZ]!;   /* jump to next instruction */ \
                      br        REG1;
#define NEXT2()       ldr       REG1, [IP, SZ2]!;  /* skip next instruction, jump to following one */ \
                      br        REG1;

#define RPUSH(val)    str       val, [RSTK, -SZ]!; /* push val to second return stack element */
#define RPOP(val)     ldr       val, [RSTK], SZ;   /* pop second return stack element into val */

/* clang-format on */

#endif /* M4TH_ARM64_ASM_H */

