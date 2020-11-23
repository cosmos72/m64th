/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
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

#include "../dispatch/asm.mh"

/* clang-format off */

#define M4F_MISSING_
FUNC_START(_missing_)      /* (missing) called instead of invalid/unimplemented function */
        ud2;                   /* crash with SIGILL */
FUNC_END(_missing_)


#define M4FTIMES
FUNC_START(times)          /* *    */
        MUL2(  AT(DSTK),   DTOP)
        ADD2(  IMM(SZ),    DSTK)
FUNC_END(times)


#define M4FPLUS
FUNC_START(plus)           /* +    */
        ADD2(  AT(DSTK),   DTOP)
        ADD2(  IMM(SZ),    DSTK)
FUNC_END(plus)


#define M4FPLUS_STORE
FUNC_START(plus_store)     /* +!   */
        LOAD(  REG1,   AT(DSTK))
        ADD2(  REG1,   AT(DTOP))
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(plus_store)


#define M4FMINUS
FUNC_START(minus)          /* -  ( x y -- x-y )  */
        MOVE(  DTOP,   REG1)       /* a = y              */
        DPOP___DTOP()              /* dtop = x           */
        SUB2(REG1,   DTOP)         /* dtop = x - y       */
FUNC_END(minus)


/* / ( a b -- a/b ) signed divide */
FUNC_START(div)
        MOVE(  DTOP,   %rcx)       /* DTOP is %rax, we will clobber it */
        DPOP___DTOP()              /* load %rax                        */
        cqto;                      /* sign-extend %rax into %rdx       */
        idiv   %rcx;               /* quotient is in %rax, remainder in %rdx */
        /*MOVE(%rax,   DTOP)*/     /* result is already in DTOP = %rax */
FUNC_END(div)


/* /mod ( a b -- a%b a/b ) signed remainder & divide */
FUNC_START(div_mod)
        MOVE(  DTOP,   %rcx)       /* DTOP is %rax, we will clobber it */
        LOAD(  %rax,   AT(DSTK))
        cqto;                      /* sign-extend %rax into %rdx */
        idiv   %rcx;               /* quotient is in %rax, remainder in %rdx */
        STOR(  %rdx,   AT(DSTK))   /* remainder */
        /*MOVE(%rax, DTOP)*/       /* result is already in DTOP = %rax */
FUNC_END(div_mod)


/* u/mod ( u1 u2 -- u1%u2 u1/u2 ) unsigned remainder & divide */
FUNC_START(u_div_mod)
        MOVE(  DTOP,   %rcx)       /* DTOP is %rax, we will clobber it */
        LOAD(  %rax,   AT(DSTK))
        xor    %edx,   %edx;       /* zero-extend %rax into %rdx */
        div    %rcx;               /* quotient is in %rax, remainder in %rdx */
        STOR(  %rdx,   AT(DSTK))   /* remainder */
        /*MOVE(%rax, DTOP)*/       /* result is already in DTOP = %rax */
FUNC_END(u_div_mod)


#define M4FZERO
FUNC_START(zero)           /* 0    m4th-impl */
        DPUSH__DTOP()
        ZERO(  DTOP)
FUNC_END(zero)


FUNC_START(zero_less_equal)/* 0<=  m4th-user */
        test   DTOP,   DTOP;
        MOVI(  0,      DTOP)       /* xor would affect EFLAGS */
        cmovle RFFF,   DTOP;
FUNC_END(zero_less_equal)


FUNC_START(zero_ne)        /* 0<>  core ext */
        test   DTOP,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(zero_ne)


FUNC_START(zero_equal)     /* 0=   */
        test   DTOP,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(zero_equal)


FUNC_START(zero_more)      /* 0>   */
        test   DTOP,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(zero_more)


FUNC_START(zero_more_equal)/* 0>=  m4th-user */
        test   DTOP,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovge RFFF,   DTOP;
FUNC_END(zero_more_equal)


FUNC_START(two_sm_div)     /* 2sm/   m4th-user symmetric divide by 2 */
        MOVE(  DTOP, REG1)
        shr    IMM(63), REG1;
        ADD2(  REG1, DTOP) /* add 1 if negative */
        sar    DTOP;       /* because sar rounds toward -infinity */
FUNC_END(two_sm_div)


FUNC_START(four_sm_div)    /* 4sm/ m4th-user symmetric divide by 4 */
        test   DTOP,   DTOP
        lea    3(DTOP),REG1;  /* add 3 if negative */
        cmovs  REG1,   DTOP;
        sar    IMM(2), DTOP;  /* because sar rounds toward -infinity */
FUNC_END(four_sm_div)


FUNC_START(eight_sm_div)   /* 8sm/ m4th-user symmetric divide by 8 */
        test   DTOP,   DTOP
        lea    7(DTOP),REG1;  /* add 7 if negative */
        cmovs  REG1,   DTOP;
        sar    IMM(3), DTOP;  /* because sar rounds toward -infinity */
FUNC_END(eight_sm_div)


FUNC_START(less)           /* <   */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovl  RFFF,   DTOP;
FUNC_END(less)


FUNC_START(less_equal)     /* <=   m4th-user */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovle RFFF,   DTOP;
FUNC_END(less_equal)


FUNC_START(ne)             /* <>   core ext */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovne RFFF,   DTOP;
FUNC_END(ne)


FUNC_START(equal)          /* = */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmove  RFFF,   DTOP;
FUNC_END(equal)


FUNC_START(more)           /* > */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovg  RFFF,   DTOP;
FUNC_END(more)


FUNC_START(more_equal)     /* >=   m4th-user */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)      /* xor would affect EFLAGS */
        cmovge RFFF,   DTOP;
FUNC_END(more_equal)


FUNC_START(abs)            /* abs */
        MOVE(  DTOP,   REG1)
        NEG1(  REG1)
        cmovg  REG1,   DTOP;
FUNC_END(abs)


FUNC_START(lshift)         /* lshift */
        MOVE(  DTOPw,  %ecx)
        DPOP___DTOP()
        shl    %cl,    DTOP;
FUNC_END(lshift)


FUNC_START(max)            /* max  */
        DPOP(  REG1)
        cmp    DTOP,   REG1;
        cmovg  REG1,   DTOP;
FUNC_END(max)


FUNC_START(min)            /* min */
        DPOP(  REG1)
        cmp    DTOP,   REG1;
        cmovl  REG1,   DTOP;
FUNC_END(min)


FUNC_START(mod)            /* mod  i.e. signed remainder */
        MOVE(  DTOP,   %rcx)       /* DTOP is %rax, we will clobber it */
        DPOP___DTOP()              /* load %rax                        */
        cqto;                      /* sign-extend %rax into %rdx */
        idiv   %rcx;               /* quotient is in %rax, remainder in %rdx */
        MOVE(  %rdx,   DTOP)       /* remainder */
FUNC_END(mod)


#define M4FOVER
FUNC_START(over)
        STOR(  DTOP,   AT(DSTK, -SZ))
        LOAD(  DTOP,   AT(DSTK))
        SUB2(  IMM(SZ),DSTK)
FUNC_END(over)


FUNC_START(rshift)         /* rshift */
        MOVE(  DTOPw,  %ecx)
        DPOP___DTOP()
        shr    %cl,    DTOP;
FUNC_END(rshift)


#define M4FSUB
FUNC_START(sub)            /* sub      m4th-user equivalent to: swap - */
        SUB2(  AT(DSTK),   DTOP)
        ADD2(  IMM(SZ),    DSTK)
FUNC_END(sub)


FUNC_START(to_byte)        /* to-byte  m4th-user */
        movsbq DTOPb,  DTOP_sb;
FUNC_END(to_byte)

FUNC_START(to_short)       /* to-short m4th-user */
        movswq DTOPh,  DTOP_sh;
FUNC_END(to_short)

FUNC_START(to_int)         /* to-int   m4th-user */
        /* cltq; */        /* alias of: cdqe */
        movslq DTOPw,  DTOP_sw;
FUNC_END(to_int)

FUNC_START(to_char)        /* to-char  m4th-user */
        movzbl DTOPb,  DTOP_ub;
FUNC_END(to_char)

FUNC_START(to_ushort)      /* to-ushort m4th-user */
        movzwl DTOPh,  DTOP_uh;
FUNC_END(to_ushort)

FUNC_START(to_uint)        /* to-uint m4th-user */
        movl   DTOPw,  DTOP_uw;
FUNC_END(to_uint)


FUNC_START(u_less)         /* u<   */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)           /* xor would affect EFLAGS   */
        cmovb  RFFF,   DTOP;
FUNC_END(u_less)


FUNC_START(u_less_equal)   /* u<=  m4th-user */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)           /* xor would affect EFLAGS   */
        cmovbe RFFF,   DTOP;
FUNC_END(u_less_equal)


FUNC_START(u_more)         /* u>   core ext */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)           /* xor would affect EFLAGS   */
        cmova  RFFF,   DTOP;
FUNC_END(u_more)


FUNC_START(u_more_equal)   /* u>=  m4th-user */
        MOVE(  DTOP,   REG2)
        DPOP___DTOP()
        cmp    REG2,   DTOP;
        MOVI(  0,      DTOP)           /* xor would affect EFLAGS   */
        cmovae RFFF,   DTOP;
FUNC_END(u_more_equal)


/* ( x lo hi -- flag ) true if lo <= x < hi \ signed or unsigned */
FUNC_START(within)         /* within   core ext */
        DPOP2( REG2,   REG1)           /* b = lo, a = x             */
        SUB2(  REG2,   DTOP)           /* DTOP = hi-lo              */
        SUB2(  REG2,   REG1)           /* REG1 = x-lo               */
        cmp    DTOP,   REG1;
        MOVI(  0,      DTOP)           /* xor would affect EFLAGS   */
        cmovb  RFFF,   DTOP;
FUNC_END(within)


FUNC_START(xor)            /* xor  */
        xor    AT(DSTK),   DTOP;
        ADD2(  IMM(SZ),    DSTK)
FUNC_END(xor)
