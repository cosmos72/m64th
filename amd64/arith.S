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

#define M4F_MISSING_
FUNC_START(_missing_) /* (missing) called instead of invalid/unimplemented function */
        ud2;                   /* should crash with SIGILL */
        ZERO(  REG1)
        LOAD(  REG1, AT(REG1)) /* should crash with SIGSEGV */
FUNC_END(_missing_)


#define M4FPLUS_STORE
FUNC_START(plus_store) /* +!   */
        LOAD(  REG1,   AT(DSTK))
        ADD2(  REG1,   AT(DTOP))
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(plus_store)



#define M4FMINUS_ONE
FUNC_START(minus_one)  /* -1   m4th-impl */
        DPUSH( DTOP)
        MOVE(  RFFF, DTOP)
FUNC_END(minus_one)


/* signed divide */
FUNC_START(div)              /* / */
        DPOP(  %rax)
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        MOVE(  %rax, DTOP)
FUNC_END(div)


/* signed divide & remainder */
FUNC_START(div_mod)          /* /mod */
        LOAD(  %rax, AT(DSTK))
        cqto;  /* sign-extend %rax into %rdx */
        idiv   DTOP;
        STOR(  %rdx, AT(DSTK)) /* remainder */
        MOVE(  %rax, DTOP)     /* quotient */
FUNC_END(div_mod)


#define M4FZERO
FUNC_START(zero)           /* 0    m4th-impl */
        DPUSH( DTOP)
        ZERO(  DTOPw)
FUNC_END(zero)


FUNC_START(zero_less_equal)   /* 0<=  m4th-user */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;       /* xor would affect EFLAGS */
        cmovle RFFF,   DTOP;
FUNC_END(zero_less_equal)


FUNC_START(zero_ne)        /* 0<>  core ext */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(zero_ne)


FUNC_START(zero_equal)     /* 0=   */
        test   DTOP, DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(zero_equal)


FUNC_START(zero_more)      /* 0>   */
        test   DTOP,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(zero_more)


FUNC_START(zero_more_equal)/* 0>=  m4th-user */
        test   DTOP,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovge RFFF,   DTOP;
FUNC_END(zero_more_equal)


#define M4FONE
FUNC_START(one)        /* 1    m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(1), DTOPw)
FUNC_END(one)


#define M4FTWO
FUNC_START(two)        /* 2    m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(2), DTOPw)
FUNC_END(two)


FUNC_START(two_times)   /* 2*   */
        sal    DTOP;
FUNC_END(two_times)


FUNC_START(two_div)  /* 2/   */
        MOVE(  DTOP, REG1)
        shr    IMM(63), REG1;
        ADD2(  REG1, DTOP) /* add 1 if negative */
        sar    DTOP;       /* because sar rounds toward -infinity */
FUNC_END(two_div)


#define M4FTHREE
FUNC_START(three)      /* 3   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(3), DTOPw)
FUNC_END(three)


#define M4FFOUR
FUNC_START(four)        /* 4    m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(4), DTOPw)
FUNC_END(four)


FUNC_START(four_div)   /* 4/   m4th-user */
        test   DTOP,   DTOP
        lea    3(DTOP),REG1;  /* add 3 if negative */
        cmovs  REG1,   DTOP;
        sar    IMM(2), DTOP;  /* because sar rounds toward -infinity */
FUNC_END(four_div)


#define M4FEIGHT
FUNC_START(eight)      /* 8   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(8), DTOPw)
FUNC_END(eight)


FUNC_START(eight_div)  /* 8/   m4th-user */
        test   DTOP,   DTOP
        lea    7(DTOP),REG1;  /* add 7 if negative */
        cmovs  REG1,   DTOP;
        sar    IMM(3), DTOP;  /* because sar rounds toward -infinity */
FUNC_END(eight_div)


FUNC_START(less)          /* <   */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovl  RFFF,   DTOP;
FUNC_END(less)


FUNC_START(less_equal)        /* <=   m4th-user */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovle RFFF,   DTOP;
FUNC_END(less_equal)


FUNC_START(ne)         /* <>   core ext */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(ne)


FUNC_START(equal)             /* = */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(equal)


FUNC_START(more)       /* > */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(more)


FUNC_START(more_equal)     /* >=   m4th-user */
        DPOP(  REG2)
        cmp    DTOP, REG2;
        mov    IMM(0), DTOPw;      /* xor would affect EFLAGS */
        cmovge RFFF,   DTOP;
FUNC_END(more_equal)


FUNC_START(question_dup)      /* ?dup */
        test   DTOP, DTOP;
        jz     FUNC_SYM_NEXT(question_dup);
        DPUSH( DTOP)
FUNC_END(question_dup)


FUNC_START(abs)        /* abs */
        MOVE(  DTOP, REG1)
        NEG1(  REG1)
        cmovg  REG1, DTOP;
FUNC_END(abs)


#define M4FBL
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


#define M4FSWAP
FUNC_START(swap)       /* swap */
        xchg   (DSTK), DTOP;
FUNC_END(swap)


FUNC_START(to_byte)    /* to-byte */
        movsbq   DTOPb, DTOP_sb;
FUNC_END(to_byte)

FUNC_START(to_short)   /* to-short */
        movswq   DTOPh, DTOP_sh;
FUNC_END(to_short)

FUNC_START(to_int)     /* to-int */
        movslq   DTOPw, DTOP_sw;
FUNC_END(to_int)

FUNC_START(to_char)    /* to-char */
        movzbl   DTOPb, DTOP_ub;
FUNC_END(to_char)

FUNC_START(to_ushort)  /* to-ushort */
        movzwl   DTOPh, DTOP_uh;
FUNC_END(to_ushort)

FUNC_START(to_uint)    /* to-uint */
        movl     DTOPw, DTOP_uw;
FUNC_END(to_uint)


FUNC_START(xor)        /* xor  */
        DPOP(  REG1)
        xor    REG1,  DTOP;
FUNC_END(xor)
