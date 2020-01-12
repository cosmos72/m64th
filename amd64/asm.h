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

#include "../asm_gcc.h"

#define SZ   8    /* width of registers and cells, in bytes */
#define SZ2  16   /* SZ * 2 */
#define SZ3  24   /* SZ * 3 */
#define SZ4  32   /* SZ * 4 */
#define SZ5  40   /* SZ * 5 */
#define SZ6  48   /* SZ * 6 */
#define SZ7  56   /* SZ * 7 */

#define IMM(constant) $constant /* immediate constant */

#define REG1 %rax /* scratch register 1 */
#define REG2 %rcx /* scratch register 2 */
#define REG3 %rdx /* scratch register 3 */
#define REG4 %rdi /* scratch register 4 */
/* additional scratch registers: %r8 %r9 %r10 %r11 */

#define REG1b %al /* low 8 bits of REG1 */

#define DTOP  %rbx /* value of first data stack element */
#define DTOPb %bl  /* low 8 bits of DTOP */
#define DTOPh %bx  /* low 16 bits of DTOP */
#define DTOPw %ebx /* low 32 bits of DTOP */

#define DSTK %rsp /* pointer to second data stack element */
#define IP   %rsi /* instruction pointer */
#define RFFF %r12 /* always contains -1 */
#define RTOP %r13 /* value of first return stack element */
#define RSTK %r14 /* pointer to secont return stack element */
#define M4TH %r15 /* pointer to C struct m4th */

#define DPUSH(val)    pushq     val; /* push val to second data stack element */
#define DPOP(val)     popq      val; /* pop second data stack element into val */

#define RPUSH(val)    subq      $SZ,    RSTK; /* push val to second return stack element */ \
                      movq      val,    (RSTK);

#define RPOP(val)     movq      (RSTK), val; /* pop second return stack element into val */ \
                      addq      $SZ,    RSTK;

#define NEXT()        addq      $SZ,    IP; /* jump to next instruction */ \
                      jmp       *(IP);
#define NEXT2()       addq      $SZ2,   IP; /* skip next instruction, jump to following one */ \
                      jmp       *(IP);


#define ADD2(src,dst)    addq   src,     dst;    /* dst += src     */
#define IGET(addr,i,dst) movq   i(addr), dst;    /* dst  = addr[i] */
#define ISET(src,addr,i) movq   src,     i(addr);/* addr[i] = src  */
#define LOAD(addr,dst)   movq   (addr),  dst;    /* dst  = addr[0] */
#define MOVE(src,dst)    movq   src,     dst;    /* dst  = src     */
#define MUL2(src,dst)    imulq  src,     dst;    /* dst *= src     */
#define NEG1(dst)        negq   dst;             /* dst  = -dst    */
#define SUB2(src,dst)    subq   src,     dst;    /* dst -= src     */
#define STOR(src,addr)   movq   src,     (addr); /* addr[0] = src  */
#define ZERO(dst)        xorq   dst,     dst;    /* dst  = 0       */

#endif /* M4TH_AMD64_ASM_H */

