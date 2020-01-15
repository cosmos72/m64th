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

#define M4_1_
FUNC_START(m4_1_) /* (1) */
        DPUSH( DTOP)
        MOVE(  IMM(1), DTOPw)
FUNC_END(m4_1_)


#define M4PLUS_STORE
FUNC_START(m4plus_store) /* +! */
        DPOP(  REG1)
        ADD2(  REG1, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(m4plus_store)


/* signed divide */
FUNC_START(m4slash) /* / */
        DPOP(  %rax)
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        MOVE(  %rax, DTOP)
FUNC_END(m4slash)


/* signed divide & remainder */
FUNC_START(m4slash_mod)      /* /mod */
        LOAD(  %rax, AT(DSTK))
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        STOR(  %rdx, AT(DSTK)) /* remainder */
        MOVE(  %rax, DTOP)     /* quotient */
FUNC_END(m4slash_mod)


FUNC_START(m4zero_less)   /* 0< */
        sar    IMM(63),DTOP 
FUNC_END(m4zero_less)


FUNC_START(m4zero_not_equals)   /* 0<>  core ext */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;    /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(m4zero_not_equals)


FUNC_START(m4zero_equals)     /* 0= */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;    /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(m4zero_equals)


FUNC_START(m4zero_greater_than)   /* 0> */
        test   DTOP,   DTOP;
        mov    IMM(0), DTOPw;    /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(m4zero_greater_than)


#define M4ONE_MINUS
FUNC_START(m4one_minus) /* 1-   */
        dec    DTOP;
FUNC_END(m4one_minus)


#define M4ONE_PLUS
FUNC_START(m4one_plus) /* 1+   */
        inc    DTOP;
FUNC_END(m4one_plus)


FUNC_START(m4two_slash) /* 2/ */
        MOVE(  DTOP, REG1)
        shr    IMM(63), REG1;
        ADD2(  REG1, DTOP) /* add 1 if negative */
        sar    DTOP;       /* because sar rounds toward -infinity */
FUNC_END(m4two_slash)


FUNC_START(m4two_star) /* 2* */
        sal    DTOP;
FUNC_END(m4two_star)


FUNC_START(m4less_than)   /* < */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;    /* xor would affect EFLAGS */
        cmovl  RFFF,   DTOP;
FUNC_END(m4less_than)


FUNC_START(m4not_equals) /* <>   core ext */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        mov    IMM(0), DTOPw;    /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(m4not_equals)


FUNC_START(m4equals)   /* = */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        mov    IMM(0), DTOPw;    /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(m4equals)


FUNC_START(m4greater_than)   /* > */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;    /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(m4greater_than)


FUNC_START(m4question_dupe)   /* ?dup */
        test   DTOP, DTOP;
        jz     .m4question_dupe.next;
        DPUSH( DTOP)
FUNC_END(m4question_dupe)


FUNC_START(m4abs)
        MOVE(  DTOP, REG1)
        NEG1(  REG1)
        cmovg  REG1, DTOP;
FUNC_END(m4abs)


#define M4BL
FUNC_START(m4bl)
        DPUSH( DTOP)
        mov    IMM(32), DTOPw
FUNC_END(m4bl)


FUNC_START(m4c_store) /* c! */
        DPOP(  REG1)
        mov    REG1b, (DTOP);
        DPOP(  DTOP)
FUNC_END(m4c_store)


FUNC_START(m4c_fetch) /* c@ */
        movzbq (DTOP), DTOP;
FUNC_END(m4c_fetch)


#define M4FALSE
FUNC_START(m4false)
        DPUSH( DTOP)
        ZERO(  DTOPw)
FUNC_END(m4false)


FUNC_START(m4max)
        DPOP(  REG1)
        cmp    DTOP, REG1;
        cmovg  REG1, DTOP;
FUNC_END(m4max)


FUNC_START(m4min)
        DPOP(  REG1)
        cmp    DTOP, REG1;
        cmovl  REG1, DTOP;
FUNC_END(m4min)

/* signed remainder */
FUNC_START(m4mod)
        DPOP(  %rax)
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        MOVE(  %rdx, DTOP) /* remainder */
FUNC_END(m4mod)


#define M4SWAP
FUNC_START(m4swap)
        xchg   (DSTK), DTOP;
FUNC_END(m4swap)


#define M4TRUE
FUNC_START(m4true)
        DPUSH( DTOP)
        MOVE(  RFFF, DTOP)
FUNC_END(m4true)


FUNC_START(m4xor)
        DPOP(  REG1)
        xor    REG1,  DTOP;
FUNC_END(m4xor)
