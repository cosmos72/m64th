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

#include "asm.mh"

#define M4PLUS_STORE
FUNC_START(plus_store) /* +!   */
        DPOP(  REG1)
        ADD2(  REG1, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(plus_store)



#define M4MINUS_ONE
FUNC_START(minus_one)  /* -1   m4th-impl */
        DPUSH( DTOP)
        MOVE(  RFFF, DTOP)
FUNC_END(minus_one)


/* signed divide */
FUNC_START(slash)              /* / */
        DPOP(  %rax)
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        MOVE(  %rax, DTOP)
FUNC_END(slash)


/* signed divide & remainder */
FUNC_START(slash_mod)          /* /mod */
        LOAD(  %rax, AT(DSTK))
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        STOR(  %rdx, AT(DSTK)) /* remainder */
        MOVE(  %rax, DTOP)     /* quotient */
FUNC_END(slash_mod)


#define M4ZERO
FUNC_START(zero)       /* 0    m4th-impl */
        DPUSH( DTOP)
        ZERO(  DTOPw)
FUNC_END(zero)


FUNC_START(zero_less_equals)   /* 0<=  m4th-user */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;       /* xor would affect EFLAGS */
        cmovle RFFF,   DTOP;
FUNC_END(zero_less_equals)


FUNC_START(zero_not_equals)    /* 0<>  core ext */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(zero_not_equals)


FUNC_START(zero_equals)        /* 0=   */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(zero_equals)


FUNC_START(zero_greater_than)  /* 0>   */
        test   DTOP,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(zero_greater_than)


FUNC_START(zero_greater_equals)/* 0>=  m4th-user */
        test   DTOP,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovge RFFF,   DTOP;
FUNC_END(zero_greater_equals)


#define M4ONE
FUNC_START(one)        /* 1    m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(1), DTOPw)
FUNC_END(one)


#define M4TWO
FUNC_START(two)        /* 2    m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(2), DTOPw)
FUNC_END(two)


FUNC_START(two_star)   /* 2*   */
        sal    DTOP;
FUNC_END(two_star)


FUNC_START(two_slash)  /* 2/   */
        MOVE(  DTOP, REG1)
        shr    IMM(63), REG1;
        ADD2(  REG1, DTOP) /* add 1 if negative */
        sar    DTOP;       /* because sar rounds toward -infinity */
FUNC_END(two_slash)


#define M4THREE
FUNC_START(three)      /* 3   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(3), DTOPw)
FUNC_END(three)


#define M4FOUR
FUNC_START(four)       /* 4    m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(4), DTOPw)
FUNC_END(four)


#define M4EIGHT
FUNC_START(eight)      /* 8   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(8), DTOPw)
FUNC_END(eight)


FUNC_START(less_than)          /* <   */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovl  RFFF,   DTOP;
FUNC_END(less_than)


FUNC_START(less_equals)        /* <=   m4th-user */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovle RFFF,   DTOP;
FUNC_END(less_equals)


FUNC_START(not_equals)         /* <>   core ext */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(not_equals)


FUNC_START(equals)             /* = */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(equals)


FUNC_START(greater_than)       /* > */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(greater_than)


FUNC_START(greater_equals)     /* >=   m4th-user */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovge RFFF,   DTOP;
FUNC_END(greater_equals)


FUNC_START(question_dupe)      /* ?dup */
        test   DTOP, DTOP;
        jz     FUNC_SYM_NEXT(question_dupe);
        DPUSH( DTOP)
FUNC_END(question_dupe)


FUNC_START(abs)        /* abs */
        MOVE(  DTOP, REG1)
        NEG1(  REG1)
        cmovg  REG1, DTOP;
FUNC_END(abs)


#define M4BL
FUNC_START(bl)         /* bl   */
        DPUSH( DTOP)
        MOVE(  IMM(32), DTOPw)
FUNC_END(bl)


FUNC_START(lshift)     /* lshift */
        MOVE(  DTOP, %rcx)
        DPOP(  DTOP)
        shl    %cl,  DTOP;
FUNC_END(lshift)


FUNC_START(max)        /* max  */
        DPOP(  REG1)
        cmp    DTOP, REG1;
        cmovg  REG1, DTOP;
FUNC_END(max)


FUNC_START(min)        /* min */
        DPOP(  REG1)
        cmp    DTOP, REG1;
        cmovl  REG1, DTOP;
FUNC_END(min)


/* signed remainder */
FUNC_START(mod)        /* mod  */
        DPOP(  %rax)
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        MOVE(  %rdx, DTOP) /* remainder */
FUNC_END(mod)


FUNC_START(rshift)     /* rshift */
        MOVE(  DTOP, %rcx)
        DPOP(  DTOP)
        shr    %cl,  DTOP;
FUNC_END(rshift)


#define M4SWAP
FUNC_START(swap)       /* swap */
        xchg   (DSTK), DTOP;
FUNC_END(swap)


FUNC_START(xor)        /* xor  */
        DPOP(  REG1)
        xor    REG1,  DTOP;
FUNC_END(xor)
