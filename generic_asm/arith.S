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

#ifndef M4F_LIT2S_
FUNC_START(_lit2s_)        /* (lit-2s) push to dstack the int16 at following IP */
        DPUSH__DTOP()
        LD_sh( DTOP,   AT(IP))
        NEXT2() /* skip 2 bytes */
FUNC_RAWEND(_lit2s_)
#endif

#ifndef M4F_LIT4S_
FUNC_START(_lit4s_)        /* (lit-4s) push to dstack the int32 at following IP */
        DPUSH__DTOP()
        LD_sw( DTOP,   AT(IP))
        NEXT4() /* skip 4 bytes */
FUNC_RAWEND(_lit4s_)
#endif

#ifndef M4F_LIT8S_
FUNC_START(_lit8s_)        /* (lit-8s) push to dstack the int64 at following IP */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(IP))
        NEXT8() /* skip 8 bytes */
FUNC_RAWEND(_lit8s_)
#endif

#ifndef M4F_LIT_STRING_
FUNC_START(_lit_string_)   /* (lit-string) push to dstack the SZt and ascii at following IP */
        DPUSH__DTOP()
        LD_ut( DTOP,   AT(IP))         /* dtop = length                     */
        ADDI(  IP,     SZt,    REG1)   /* a  = c-addr                       */
        ADD4(  REG1,   DTOP,0, IP)     /* IP = c-addr + length              */
        DPUSH( REG1)
        ALIGN( SZt,    IP)             /* IP = aligned@SZt(c-addr + length) */
        NEXT0()                        /* jump to end of string             */
FUNC_RAWEND(_lit_string_)
#endif

#ifndef M4F_MISSING_
FUNC_START(_missing_)      /* (missing) called instead of invalid/unimplemented m4func */
        ZERO(  REG1)
        LOAD(  REG1,   AT(REG1)) /* load NULL address, should crash */
FUNC_END(_missing_)
#endif

FUNC_START(two_drop)       /* 2drop    */
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(  IMM(SZ2),   DSTK)
FUNC_END(two_drop)


FUNC_START(two_dup)        /* 2dup     */
        LOAD(  REG1,   AT(DSTK))
        STOR(  DTOP,   AT(DSTK, -SZ))
        STOR(  REG1,   AT(DSTK, -SZ2))
        SUB2(  IMM(SZ2),   DSTK)
FUNC_END(two_dup)


#ifndef M4FTWO_NIP
FUNC_START(two_nip)        /* 2nip     m4th-user */
        LOAD(  REG1,   AT(DSTK))
        STOR(  REG1,   AT(DSTK, SZ2))
        ADD2(  IMM(SZ2),   DSTK)
FUNC_END(two_nip)
#endif


FUNC_START(two_over)       /* 2over    ( a b c d -- a b c d a b ) */
        STOR(  DTOP,   AT(DSTK, -SZ))  /* save d   */
        LOAD(  REG1,   AT(DSTK, SZ2))  /* a        */
        LOAD(  DTOP,   AT(DSTK, SZ))   /* dtop = b */
        STOR(  REG1,   AT(DSTK, -SZ2)) /* save a   */
        SUB2(  IMM(SZ2), DSTK)         /* update dstk */
FUNC_END(two_over)


#ifndef M4FTWO_ROT
FUNC_START(two_rot)       /* 2rot      ( a b c d e f -- c d e f a b ) */
        LOAD(  REG1,   AT(DSTK, SZ4))  /* a        */
        LOAD(  REG2,   AT(DSTK, SZ3))  /* b        */
        LOAD(  REG3,   AT(DSTK, SZ2))  /* c        */
        LOAD(  REG4,   AT(DSTK, SZ))   /* d        */
        LOAD(  REG0,   AT(DSTK))       /* e        */
        STOR(  REG3,   AT(DSTK, SZ4))  /* ( c _ _ _ _ _ ) */
        STOR(  REG4,   AT(DSTK, SZ3))  /* ( c d _ _ _ _ ) */
        STOR(  REG0,   AT(DSTK, SZ2))  /* ( c d e _ _ _ ) */
        STOR(  DTOP,   AT(DSTK, SZ))   /* ( c d e f _ _ ) */
        STOR(  REG1,   AT(DSTK))       /* ( c d e f a _ ) */
        MOVE(  REG2,   DTOP)           /* ( c d e f a b ) */
FUNC_END(two_rot)
#endif


#ifndef M4FMINUS_TWO_ROT
FUNC_START(minus_two_rot)  /* -2rot    ( a b c d e f -- e f a b c d ) */
        LOAD(  REG0,   AT(DSTK))       /* e        */
        LOAD(  REG4,   AT(DSTK, SZ))   /* d        */
        LOAD(  REG3,   AT(DSTK, SZ2))  /* c        */
        LOAD(  REG2,   AT(DSTK, SZ3))  /* b        */
        LOAD(  REG1,   AT(DSTK, SZ4))  /* a        */
        STOR(  REG3,   AT(DSTK))       /* ( _ _ _ _ c _ ) */
        STOR(  REG2,   AT(DSTK, SZ))   /* ( _ _ _ b c _ ) */
        STOR(  REG1,   AT(DSTK, SZ2))  /* ( _ _ a b c _ ) */
        STOR(  DTOP,   AT(DSTK, SZ3))  /* ( _ f a b c _ ) */
        STOR(  REG0,   AT(DSTK, SZ4))  /* ( e f a b c _ ) */
        MOVE(  REG4,   DTOP)           /* ( e f a b c d ) */
FUNC_END(minus_two_rot)
#endif


#ifndef M4FTWO_SWAP
/* remember: x86 instruction 'xchg' with memory operand is SLOW */
FUNC_START(two_swap)       /* 2swap    ( a b c d -- c d a b ) */
        LOAD(  REG1,   AT(DSTK))
        LOAD(  REG2,   AT(DSTK, SZ))
        LOAD(  REG3,   AT(DSTK, SZ2))
        STOR(  DTOP,   AT(DSTK, SZ))
        STOR(  REG1,   AT(DSTK, SZ2))
        STOR(  REG3,   AT(DSTK))
        MOVE(  REG2,   DTOP)
FUNC_END(two_swap)
#endif


#ifndef M4FTIMES
FUNC_START(times)          /* *    */
        DPOP(  REG1)
        MUL2(  REG1,   DTOP)
FUNC_END(times)
#endif


#ifndef M4FPLUS
FUNC_START(plus)           /* +    */
        DPOP(  REG1)
        ADD2(  REG1,   DTOP)
FUNC_END(plus)
#endif


#ifndef M4FPLUS_STORE
FUNC_START(plus_store)     /* +!   */
        DPOP(  REG1)
        LOAD(  REG2,   AT(DTOP))
        ADD2(  REG1,   REG2)
        STOR(  REG2,   AT(DTOP))
        DPOP___DTOP()
FUNC_END(plus_store)
#endif


#ifndef M4FMINUS
FUNC_START(minus)          /* -  ( x y -- x-y )  */
        DPOP(  REG1)           /* a = x              */
        XSUB2( REG1,   DTOP)   /* dtop = x - y       */
FUNC_END(minus)
#endif


FUNC_START(minus_two)      /* -2   m4th-impl */
        DPUSH__DTOP()
        MOVI(  -2,     DTOP)
FUNC_END(minus_two)


FUNC_START(minus_one)      /* -1   m4th-impl */
        DPUSH__DTOP()
        MOVE(  IMM_1,  DTOP)
FUNC_END(minus_one)


#ifndef M4FZERO
FUNC_START(zero)           /* 0   m4th-impl */
        DPUSH__DTOP()
        ZERO(  DTOP)
FUNC_END(zero)
#endif


FUNC_START(zero_less)      /* 0< */
        SAR2(  IMM(63),DTOP)
FUNC_END(zero_less)


FUNC_START(one)            /* 1    m4th-impl */
        DPUSH__DTOP()
        MOVI(  1,      DTOP)
FUNC_END(one)


FUNC_START(one_plus)       /* 1+   */
        INC1(  DTOP)
FUNC_END(one_plus)


FUNC_START(one_minus)      /* 1-   */
        DEC1(  DTOP)
FUNC_END(one_minus)


FUNC_START(two)            /* 2   m4th-impl */
        DPUSH__DTOP()
        MOVI(  2,      DTOP)
FUNC_END(two)


FUNC_START(two_times)      /* 2*   */
        SHL2(  IMM(1), DTOP)
FUNC_END(two_times)


FUNC_START(two_plus)       /* 2+  m4th-user */
        ADD2(  IMM(2), DTOP)
FUNC_END(two_plus)


FUNC_START(two_minus)      /* 2-  m4th-user */
        SUB2(  IMM(2), DTOP)
FUNC_END(two_minus)


FUNC_START(two_div)        /* 2/   floored divide by 2 */
        SAR2(  IMM(1), DTOP)       /* SAR2 rounds toward -infinity */
FUNC_END(two_div)


FUNC_START(three)          /* 3   m4th-impl */
        DPUSH__DTOP()
        MOVI(  3,      DTOP)
FUNC_END(three)


FUNC_START(four)           /* 4   m4th-impl */
        DPUSH__DTOP()
        MOVI(  4,      DTOP)
FUNC_END(four)


FUNC_START(four_times)     /* 4*  m4th-user */
        SHL2(  IMM(2), DTOP)
FUNC_END(four_times)


FUNC_START(four_plus)      /* 4+  m4th-user */
        ADD2(  IMM(4), DTOP)
FUNC_END(four_plus)


FUNC_START(four_div)       /* 4/   m4th-user floored divide by 4 */
        SAR2(  IMM(2), DTOP)  /* SAR2 rounds toward -infinity */
FUNC_END(four_div)


FUNC_START(eight)          /* 8   m4th-impl */
        DPUSH__DTOP()
        MOVI(  8,      DTOP)
FUNC_END(eight)


FUNC_START(eight_times)    /* 8*  m4th-user */
        SHL2(  IMM(3), DTOP)
FUNC_END(eight_times)


FUNC_START(eight_plus)     /* 8+  m4th-user */
        ADD2(  IMM(8), DTOP)
FUNC_END(eight_plus)


FUNC_START(eight_div)      /* 8/   m4th-user floored divide by 8 */
        SAR2(  IMM(3), DTOP)  /* SAR2 rounds toward -infinity */
FUNC_END(eight_div)


FUNC_START(question_dup)   /* ?dup */
        JZ(    DTOP,   FUNC_RET(question_dup))
        DPUSH__DTOP()
FUNC_END(question_dup)


FUNC_START(short_aligned)    /* short-aligned m4th-user */
        ALIGN( 2,      DTOP)
FUNC_END(short_aligned)


FUNC_START(int_aligned)      /* int-aligned   m4th-user */
        ALIGN( 4,      DTOP)
FUNC_END(int_aligned)


FUNC_START(aligned)
        ALIGN( SZ,     DTOP)
FUNC_END(aligned)


FUNC_START(and)
        DPOP(  REG1)
        AND2(  REG1,   DTOP)
FUNC_END(and)


FUNC_START(base)
        DPUSH__DTOP()
        ADDI(  M4TH,   M4TH_OFF_BASE, DTOP)
FUNC_END(base)


FUNC_START(bl)
        DPUSH__DTOP()
        MOVI(  32,     DTOP)
FUNC_END(bl)


FUNC_START(bounds) /* bounds m4th-user ( c-addr u -- c-addr+u c-addr ) get string bounds */
        LOAD(  REG1,   AT(DSTK))
        MOVE(  REG1,   REG2)
        ADD2(  DTOP,   REG1)
        MOVE(  REG2,   DTOP)
        STOR(  REG1,   AT(DSTK))
FUNC_END(bounds)


FUNC_START(drop)
        DPOP___DTOP()
FUNC_END(drop)


FUNC_START(depth)          /* ( -- n ) get stack depth */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_DEND))
        SUB2(  DSTK,   DTOP)
        SAR2(IMM(PSZ), DTOP)
FUNC_END(depth)


FUNC_START(dp0)           /* dp0       m4th-user ( x -- x addr-of-x ) get address of stack bottom */
        DPUSH__DTOP()
        MOVE(  DSTK,   DTOP)
FUNC_END(dp0)


FUNC_START(dup)
        DPUSH__DTOP()
FUNC_END(dup)


FUNC_START(flip)          /* flip      m4th-user ( a b c -- c b a ) equivalent to: swap rot */
        LOAD(  REG1,   AT(DSTK, SZ))
        STOR(  DTOP,   AT(DSTK, SZ))
        MOVE(  REG1,   DTOP)
FUNC_END(flip)


FUNC_START(here)
        DPUSH__DTOP()
        MOVE(  HERE,   DTOP)
FUNC_END(here)


FUNC_START(invert)
        NOT1(  DTOP)
FUNC_END(invert)

/**
 * get iteration index of outer do-loop.
 * must skip return stack used by innermost do-loop:
 *   i' i
 */
FUNC_START(j)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(RSTK, SZ))
FUNC_END(j)


FUNC_START(negate)
        NEG1(  DTOP)
FUNC_END(negate)


FUNC_START(nip)
        ADD2( IMM(SZ), DSTK)
FUNC_END(nip)


FUNC_START(noop)           /* no-op    m4th-user */
FUNC_END(noop)


FUNC_START(or)
        DPOP(  REG1)
        ORR2(  REG1,   DTOP)
FUNC_END(or)


#ifndef M4FOVER
FUNC_START(over)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(DSTK, SZ))
FUNC_END(over)
#endif


/* pick ( xu ... x1 x0 u -- xu ... x1 x0 xu ) core-ext */
FUNC_START(pick)
        LOAD(  DTOP,   AT(DSTK, DTOP, SZ))
FUNC_END(pick)


/* hop ( a b c -- a b c a ) m4th-user equivalent to '2 pick' */
FUNC_START(hop)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(DSTK, SZ2))
FUNC_END(hop)


FUNC_START(rdepth)          /* ( -- n ) m4th-user get return stack depth */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_REND))
        SUB2(  RSTK,   DTOP)
        SAR2(  IMM(PSZ),   DTOP)
FUNC_END(rdepth)


FUNC_START(rot)            /* rot   ( a b c -- b c a ) */
        LOAD(  REG1,   AT(DSTK))     /* REG1 = b */
        STOR(  DTOP,   AT(DSTK))     /* store  c */
        LOAD(  DTOP,   AT(DSTK, SZ)) /* DTOP = a */
        STOR(  REG1,   AT(DSTK, SZ)) /* store  b */
FUNC_END(rot)


FUNC_START(minus_rot)      /* -rot  ( a b c -- c a b ) m4th-user */
        LOAD(  REG1,   AT(DSTK,SZ))  /* REG1 = a */
        STOR(  DTOP,   AT(DSTK,SZ))  /* store  c */
        LOAD(  DTOP,   AT(DSTK))     /* DTOP = b */
        STOR(  REG1,   AT(DSTK))     /* store  a */
FUNC_END(minus_rot)


FUNC_START(squared)        /* squared  m4th-user equivalent to: dup * */
        MUL2(  DTOP,   DTOP)
FUNC_END(squared)


#ifndef M4FSUB
FUNC_START(sub)            /* sub      m4th-user equivalent to: swap - */
        DPOP(  REG1)
        SUB2(  REG1,   DTOP)
FUNC_END(sub)
#endif


FUNC_START(swap)           /* remember: x86 instruction 'xchg' with memory operand is SLOW */
        LOAD(  REG1,   AT(DSTK))
        STOR(  DTOP,   AT(DSTK))
        MOVE(  REG1,   DTOP)
FUNC_END(swap)


FUNC_START(trail)          /* trail    m4th-user ( a b -- a a b ) equivalent to: over swap */
        LOAD(  REG1,   AT(DSTK))
        DPUSH( REG1)
FUNC_END(trail)


#ifndef M4FTUCK
FUNC_START(tuck)          /* tuck      core ( a b -- b a b ) */
        LOAD(  REG1,   AT(DSTK))
        STOR(  DTOP,   AT(DSTK))
        DPUSH( REG1)
FUNC_END(tuck)
#endif
