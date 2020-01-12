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

FUNC_START(m4abs)
        MOVE(DTOP, REG1)
        NEG1(REG1)
        cmovlq REG1, DTOP;
FUNC_END(m4abs)


FUNC_START(m4c_fetch) /* c@ */
        movzbq (DTOP), DTOP;
FUNC_END(m4c_store)


FUNC_START(m4c_store) /* c! */
        DPOP(REG1)
        movb REG1b, (DTOP);
        DPOP(DTOP)
FUNC_END(m4c_store)


FUNC_START(m4max)
        DPOP(REG1)
        cmpq   DTOP, REG1;
        cmovgq REG1, DTOP;
FUNC_END(m4min)

FUNC_START(m4min)
        DPOP(REG1)
        cmpq   DTOP, REG1;
        cmovlq REG1, DTOP;
FUNC_END(m4min)

/* unsigned remainder */
FUNC_START(m4mod)
        DPOP(%rax)
        ZERO(%rdx)
        div DTOP;
        MOVE(%rdx, DTOP) /* remainder */
FUNC_END(m4mod)


#define M4ONE_MINUS
FUNC_START(m4one_minus) /* 1- */
        dec  DTOP;
FUNC_END(m4one_minus)


#define M4ONE_PLUS
FUNC_START(m4one_plus) /* 1+ */
        inc  DTOP;
FUNC_END(m4one_plus)


#define M4PLUS_STORE
FUNC_START(m4plus_store) /* +! */
        DPOP(REG1)
        addq REG1, (DTOP);
        DPOP(DTOP)
FUNC_END(m4plus_store)


FUNC_START(m4slash) /* / */
        DPOP(%rax)
        cqto; /* sign-extend %rax into %rdx */
        idiv DTOP;
        MOVE(%rax, DTOP)
FUNC_END(m4slash)

/* unsigned divide & remainder */
FUNC_START(m4slash_mod) /* /mod */
        LOAD(DSTK, %rax)
        ZERO(%rdx)
        div  DTOP;
        STOR(%rdx, DSTK) /* remainder */
        MOVE(%rax, DTOP)   /* quotient */
FUNC_END(m4slash_mod)


#define M4SWAP
FUNC_START(m4swap)
        xchg (DSTK), DTOP;
FUNC_END(m4swap)


FUNC_START(m4two_slash) /* 2/ */
        sar  IMM(1), DTOP;
FUNC_END(m4two_slash)


FUNC_START(m4two_star) /* 2* */
        sal  IMM(1), DTOP;
FUNC_END(m4two_star)

