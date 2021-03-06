/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "../dispatch/asm.mh"

/* clang-format off */

#ifndef M6F_LIT2S_
FUNC_START(_lit2s_)        /* (lit2s) push to dstack the int16 at following IP */
        DPUSH__DTOP()
        LD_sh( DTOP,   AT(IP))
        NEXT2() /* skip 2 bytes */
FUNC_RAWEND(_lit2s_)
#endif

#ifndef M6F_LIT4S_
FUNC_START(_lit4s_)        /* (lit4s) push to dstack the int32 at following IP */
        DPUSH__DTOP()
        LD_sw( DTOP,   AT(IP))
        NEXT4() /* skip 4 bytes */
FUNC_RAWEND(_lit4s_)
#endif

#ifndef M6F_LIT8S_
FUNC_START(_lit8s_)        /* (lit8s) push to dstack the int64 at following IP */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(IP))
        NEXT8() /* skip 8 bytes */
FUNC_RAWEND(_lit8s_)
#endif

#ifndef M6F_LIT_STRING_
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

#ifndef M6F_MISSING_
FUNC_START(_missing_)      /* (missing) called instead of invalid/unimplemented m6func */
        ZERO(  REG1)
        LOAD(  REG1,   AT(REG1)) /* load NULL address, should crash */
FUNC_END(_missing_)
#endif

#ifndef M6FTIMES
FUNC_START(times)          /* *    */
        DPOP(  REG1)
        MUL2(  REG1,   DTOP)
FUNC_END(times)
#endif


#ifndef M6FPLUS
FUNC_START(plus)           /* +    */
        DPOP(  REG1)
        ADD2(  REG1,   DTOP)
FUNC_END(plus)
#endif


#ifndef M6FPLUS_STORE
FUNC_START(plus_store)     /* +!   */
        DPOP(  REG1)
        LOAD(  REG2,   AT(DTOP))
        ADD2(  REG1,   REG2)
        STOR(  REG2,   AT(DTOP))
        DPOP___DTOP()
FUNC_END(plus_store)
#endif


#ifndef M6FMINUS
FUNC_START(minus)          /* -  ( x y -- x-y )  */
        DPOP(  REG1)           /* a = x              */
        XSUB2( REG1,   DTOP)   /* dtop = x - y       */
FUNC_END(minus)
#endif


FUNC_START(minus_two)      /* -2   m64th-impl */
        DPUSH__DTOP()
        MOVI(  -2,     DTOP)
FUNC_END(minus_two)


FUNC_START(minus_one)      /* -1   m64th-impl */
        DPUSH__DTOP()
        MOVE(  IMM_1,  DTOP)
FUNC_END(minus_one)


#ifndef M6FZERO
FUNC_START(zero)           /* 0   m64th-impl */
        DPUSH__DTOP()
        ZERO(  DTOP)
FUNC_END(zero)
#endif


FUNC_START(zero_less)      /* 0< */
        SAR2(  IMM(63),DTOP)
FUNC_END(zero_less)


FUNC_START(one)            /* 1    m64th-impl */
        DPUSH__DTOP()
        MOVI(  1,      DTOP)
FUNC_END(one)


FUNC_START(one_plus)       /* 1+   */
        INC1(  DTOP)
FUNC_END(one_plus)


FUNC_START(one_minus)      /* 1-   */
        DEC1(  DTOP)
FUNC_END(one_minus)


FUNC_START(two)            /* 2   m64th-impl */
        DPUSH__DTOP()
        MOVI(  2,      DTOP)
FUNC_END(two)


FUNC_START(two_times)      /* 2*   */
        SHL2(  IMM(1), DTOP)
FUNC_END(two_times)


FUNC_START(two_plus)       /* 2+  m64th-user */
        ADD2(  IMM(2), DTOP)
FUNC_END(two_plus)


FUNC_START(two_minus)      /* 2-  m64th-user */
        SUB2(  IMM(2), DTOP)
FUNC_END(two_minus)


FUNC_START(two_div)        /* 2/   floored divide by 2 */
        SAR2(  IMM(1), DTOP)       /* SAR2 rounds toward -infinity */
FUNC_END(two_div)


FUNC_START(three)          /* 3   m64th-impl */
        DPUSH__DTOP()
        MOVI(  3,      DTOP)
FUNC_END(three)


FUNC_START(four)           /* 4   m64th-impl */
        DPUSH__DTOP()
        MOVI(  4,      DTOP)
FUNC_END(four)


FUNC_START(four_times)     /* 4*  m64th-user */
        SHL2(  IMM(2), DTOP)
FUNC_END(four_times)


FUNC_START(four_plus)      /* 4+  m64th-user */
        ADD2(  IMM(4), DTOP)
FUNC_END(four_plus)


FUNC_START(four_minus)     /* 4-  m64th-user */
        SUB2(  IMM(4), DTOP)
FUNC_END(four_minus)


FUNC_START(four_div)       /* 4/   m64th-user floored divide by 4 */
        SAR2(  IMM(2), DTOP)  /* SAR2 rounds toward -infinity */
FUNC_END(four_div)


FUNC_START(five)           /* 5   m64th-impl */
        DPUSH__DTOP()
        MOVI(  5,      DTOP)
FUNC_END(five)


FUNC_START(six)            /* 6   m64th-impl */
        DPUSH__DTOP()
        MOVI(  6,      DTOP)
FUNC_END(six)


FUNC_START(seven)          /* 7   m64th-impl */
        DPUSH__DTOP()
        MOVI(  7,      DTOP)
FUNC_END(seven)


FUNC_START(eight)          /* 8   m64th-impl */
        DPUSH__DTOP()
        MOVI(  8,      DTOP)
FUNC_END(eight)


FUNC_START(eight_times)    /* 8*  m64th-user */
        SHL2(  IMM(3), DTOP)
FUNC_END(eight_times)


FUNC_START(eight_plus)     /* 8+  m64th-user */
        ADD2(  IMM(8), DTOP)
FUNC_END(eight_plus)


FUNC_START(eight_minus)    /* 8-  m64th-user */
        SUB2(  IMM(8), DTOP)
FUNC_END(eight_minus)


FUNC_START(eight_div)      /* 8/   m64th-user floored divide by 8 */
        SAR2(  IMM(3), DTOP)  /* SAR2 rounds toward -infinity */
FUNC_END(eight_div)


FUNC_START(eight_lshift)   /* 8lshift   left shift by 8 */
        SHR2(  IMM(8), DTOP)
FUNC_END(eight_lshift)


FUNC_START(eight_rshift)   /* 8rshift   unsigned right shift by 8 */
        SHR2(  IMM(8), DTOP)
FUNC_END(eight_rshift)


FUNC_START(sixteen)        /* 16   m64th-impl */
        DPUSH__DTOP()
        MOVI(  16,     DTOP)
FUNC_END(sixteen)



FUNC_START(question_dup)   /* ?dup */
        JZ(    DTOP,   FUNC_RET(question_dup))
        DPUSH__DTOP()
FUNC_END(question_dup)


FUNC_START(short_aligned)    /* short-aligned m64th-user */
        ALIGN( 2,      DTOP)
FUNC_END(short_aligned)


FUNC_START(int_aligned)      /* int-aligned   m64th-user */
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
        ADDI(  M64TH,   M64TH_OFF_BASE, DTOP)
FUNC_END(base)


FUNC_START(bl)
        DPUSH__DTOP()
        MOVI(  32,     DTOP)
FUNC_END(bl)


FUNC_START(bounds) /* bounds m64th-user ( c-addr u -- c-addr+u c-addr ) get string bounds */
        LOAD(  REG1,   AT(DSTK))
        MOVE(  REG1,   REG2)
        ADD2(  DTOP,   REG1)
        MOVE(  REG2,   DTOP)
        STOR(  REG1,   AT(DSTK))
FUNC_END(bounds)


FUNC_START(breakpoint)           /* breakpoint    m64th-user */
#ifdef __x86_64__
        int3;
#elif __aarch64__
        brk 0;                   /* may not work on iOS */
#endif
FUNC_END(breakpoint)


FUNC_START(drop)
        DPOP___DTOP()
FUNC_END(drop)


FUNC_START(depth)          /* ( -- n ) get stack depth */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M64TH, M64TH_OFF_DEND))
        SUB2(  DSTK,   DTOP)
        SAR2(IMM(PSZ), DTOP)
FUNC_END(depth)


FUNC_START(dup)
        DPUSH__DTOP()
FUNC_END(dup)


FUNC_START(flip)          /* flip      m64th-user ( a b c -- c b a ) equivalent to: swap rot */
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


FUNC_START(noop)           /* no-op    m64th-user */
FUNC_END(noop)


FUNC_START(n_to_drop)      /* n>drop ( xn .. x1 n -- ) m64th-user: drop n cells  */
        ADD4(  DSTK,   DTOP, PSZ,  DSTK)
        DPOP___DTOP()
FUNC_END(n_to_drop)


FUNC_START(or)
        DPOP(  REG1)
        ORR2(  REG1,   DTOP)
FUNC_END(or)


#ifndef M6FOVER
FUNC_START(over)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(DSTK, SZ))
FUNC_END(over)
#endif


/* pick ( xu ... x1 x0 u -- xu ... x1 x0 xu ) core-ext */
FUNC_START(pick)
        LOAD(  DTOP,   AT(DSTK, DTOP, SZ))
FUNC_END(pick)


/* hop ( a b c -- a b c a ) m64th-user equivalent to '2 pick' */
FUNC_START(hop)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(DSTK, SZ2))
FUNC_END(hop)


FUNC_START(rdepth)          /* ( -- n ) m64th-user get return stack depth */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M64TH, M64TH_OFF_REND))
        SUB2(  RSTK,   DTOP)
        SAR2(  IMM(PSZ),   DTOP)
        INC1(  DTOP)        /* also consider RTOP */
FUNC_END(rdepth)


FUNC_START(rot)            /* rot   ( a b c -- b c a ) */
        LOAD(  REG1,   AT(DSTK))     /* REG1 = b */
        STOR(  DTOP,   AT(DSTK))     /* store  c */
        LOAD(  DTOP,   AT(DSTK, SZ)) /* DTOP = a */
        STOR(  REG1,   AT(DSTK, SZ)) /* store  b */
FUNC_END(rot)


FUNC_START(minus_rot)      /* -rot  ( a b c -- c a b ) m64th-user */
        LOAD(  REG1,   AT(DSTK,SZ))  /* REG1 = a */
        STOR(  DTOP,   AT(DSTK,SZ))  /* store  c */
        LOAD(  DTOP,   AT(DSTK))     /* DTOP = b */
        STOR(  REG1,   AT(DSTK))     /* store  a */
FUNC_END(minus_rot)


FUNC_START(sp_fetch)       /* sp@   m64th-user ( x -- x addr-of-x ) get current data stack address */
        DPUSH__DTOP()
        MOVE(  DSTK,   DTOP)
FUNC_END(sp_fetch)


FUNC_START(squared)        /* squared  m64th-user equivalent to: dup * */
        MUL2(  DTOP,   DTOP)
FUNC_END(squared)


#ifndef M6FSUB
FUNC_START(sub)            /* sub      m64th-user equivalent to: swap - */
        DPOP(  REG1)
        SUB2(  REG1,   DTOP)
FUNC_END(sub)
#endif


FUNC_START(swap)           /* remember: x86 instruction 'xchg' with memory operand is SLOW */
        LOAD(  REG1,   AT(DSTK))
        STOR(  DTOP,   AT(DSTK))
        MOVE(  REG1,   DTOP)
FUNC_END(swap)


FUNC_START(trail)          /* trail    m64th-user ( a b -- a a b ) equivalent to: over swap */
        LOAD(  REG1,   AT(DSTK))
        DPUSH( REG1)
FUNC_END(trail)


#ifndef M6FTUCK
FUNC_START(tuck)           /* tuck      core ( a b -- b a b ) */
        LOAD(  REG1,   AT(DSTK))
        STOR(  DTOP,   AT(DSTK))
        DPUSH( REG1)
FUNC_END(tuck)
#endif


FUNC_START(u_two_div)      /* u2/   unsigned divide by 2 */
        SHR2(  IMM(1), DTOP)
FUNC_END(u_two_div)


FUNC_START(u_four_div)     /* u4/   unsigned divide by 4 */
        SHR2(  IMM(2), DTOP)
FUNC_END(u_four_div)


FUNC_START(u_eight_div)    /* u8/   unsigned divide by 8 */
        SHR2(  IMM(3), DTOP)
FUNC_END(u_eight_div)
