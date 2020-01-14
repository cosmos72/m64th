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

#include "../m4th_asm.h"

#define SZ 8     /* width of registers, m4int and void* in bytes */
#define SZ2 16   /* SZ * 2 */
#define SZ3 24   /* SZ * 3 */
#define SZ4 32   /* SZ * 4 */
#define SZ5 40   /* SZ * 5 */
#define SZ6 48   /* SZ * 6 */
#define SZ9 72   /* SZ * 9 */
#define SZ10 80  /* SZ * 10 */
#define SZ12 96  /* SZ * 12 */
#define SZ13 104 /* SZ * 13 */
#define SZ15 120 /* SZ * 15 */
#define SZ16 128 /* SZ * 16 */

#define IMM(constant) constant /* immediate constant */

/* clang-format off */

#define REG1  x0 /* scratch register 1 */
#define REG2  x1 /* scratch register 2 */
#define REG3  x2 /* scratch register 3 */
#define REG4  x3 /* scratch register 4 */
/* additional scratch registers: x4 .. x9 */

#define REG1w w0 /* low 32 bits of REG1 */

#define DTOP  x10 /* value of first data stack element */
#define DTOPw w10 /* low 32 bits of DTOP */

#define DSTK  x11 /* pointer to second data stack element */
#define IP    x12 /* instruction pointer */
#define RTOP  x13 /* value of first return stack element */
#define RSTK  x14 /* pointer to second return stack element */
#define M4TH  x15 /* pointer to C struct m4th */

#define DPUSH(val)    str       val, [DSTK, -SZ]!; /* push val to second data stack element */
#define DPOP(val)     ldr       val, [DSTK], SZ;   /* pop second data stack element into val */

#define RPUSH(val)    str       val, [RSTK, -SZ]!; /* push val to second return stack element */
#define RPOP(val)     ldr       val, [RSTK], SZ;   /* pop second return stack element into val */

#define NEXT()        ldr       REG1, [IP, SZ]!;   /* jump to next instruction */ \
                      br        REG1;
#define NEXT2()       ldr       REG1, [IP, SZ2]!;  /* skip next instruction, jump to following one */ \
                      br        REG1;


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
#define ORR2(src,dst)    orr  dst, dst, src;    /* dst |= src     */
#define SUB2(src,dst)    sub  dst, dst, src;    /* dst -= src     */
#define SUB3(a,b,dst)    sub  dst, a, b;        /* dst  = a - b   */
#define STOR(reg,mem)    str  reg, mem;         /* *mem = reg     */
#define ZERO(dst)        mov  dst, 0;           /* dst  = 0       */

/* clang-format on */

#endif /* M4TH_ARM64_ASM_H */

