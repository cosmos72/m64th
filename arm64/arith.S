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


#define M4F_LIT2S_
FUNC_START(_lit2s_)        /* (lit-2s) push to dstack the int16 at following IP */
        DPUSH__DTOP()
        LD_sh( DTOP,   AT(IP), 2)
FUNC_END(_lit2s_)


#define M4F_LIT4S_
FUNC_START(_lit4s_)        /* (lit-4s) push to dstack the int32 at following IP */
        DPUSH__DTOP()
        LD_sw( DTOP,   AT(IP), 4)
FUNC_END(_lit4s_)


#define M4F_LIT8S_
FUNC_START(_lit8s_)        /* (lit-8s) push to dstack the int64 at following IP */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(IP), 8)
FUNC_END(_lit8s_)


#define M4F_LIT_STRING_
FUNC_START(_lit_string_)   /* (lit-string) push to dstack the SZt and ascii at following IP */
        LD_st( REG1,   AT(IP), SZt)    /* a  = length; IP = c-addr          */
        DPUSH2(DTOP,   IP)             /* push dtop, c-addr to DSTK         */
        ADD4(  IP,     REG1,0,   IP)   /* IP = c-addr + length              */
        MOVE(  REG1,   DTOP)           /* dtop = length                     */
        ALIGN( SZt,    IP)             /* IP = aligned@SZt(c-addr + length) */
        NEXT0()                        /* jump to end of string             */
FUNC_RAWEND(_lit_string_)


#define M4F_MISSING_
FUNC_START(_missing_)      /* (missing) called instead of invalid/unimplemented function */
        .4byte   0; /* udf */          /* crash with SIGILL */
FUNC_END(_missing_)


/* signed divide */
FUNC_START(div)      /* / */
        DPOP(  REG1)
        DIV3(  REG1,   DTOP,   DTOP)
FUNC_END(div)


/* /mod ( a b -- a%b a/b ) signed remainder & quotient */
FUNC_START(div_mod)          /*  */
        LOAD(  REG1,   AT(DSTK))
        DIV3(  REG1,   DTOP,   REG2)
        msub   REG1,   REG2,   DTOP,   REG1;
        MOVE(  REG2,   DTOP)
        STOR(  REG1,   AT(DSTK))
FUNC_END(div_mod)


/* u/mod ( u1 u2 -- u1%u2 u1/u2 ) unsigned remainder & divide */
FUNC_START(u_div_mod)
        LOAD(  REG1,   AT(DSTK))
        UDIV3( REG1,   DTOP,   REG2)
        msub   REG1,   REG2,   DTOP,   REG1;
        MOVE(  REG2,   DTOP)
        STOR(  REG1,   AT(DSTK))
FUNC_END(u_div_mod)


FUNC_START(zero_less_equal)   /* 0<=  m64th-user   */
        cmp    DTOP,   IMM(0);
        csetm  DTOP,   le;
FUNC_END(zero_less_equal)


FUNC_START(zero_ne)    /* 0<>  core ext */
        cmp    DTOP,   IMM(0);
        csetm  DTOP,   ne;
FUNC_END(zero_ne)


FUNC_START(zero_equal)        /* 0=   */
        cmp    DTOP,   IMM(0);
        csetm  DTOP,   eq;
FUNC_END(zero_equal)


FUNC_START(zero_more)      /* 0>   */
        cmp    DTOP,   IMM(0);
        csetm  DTOP,   gt;
FUNC_END(zero_more)


FUNC_START(zero_more_equal)/* 0>=  m64th-user  */
        cmp    DTOP,   IMM(0);
        csetm  DTOP,   ge;
FUNC_END(zero_more_equal)


FUNC_START(two_sm_div)     /* 2sm/ m64th-user symmetric divide by 2 */
        add    DTOP,   DTOP,   DTOP, lsr IMM(63);
        asr    DTOP,   DTOP,   IMM(1);
FUNC_END(two_sm_div)


FUNC_START(four_sm_div)    /* 4sm/ m64th-user symmetric divide by 4 */
        cmp    DTOP,   IMM(0);
        add    REG1,   DTOP,   IMM(3);     /* add 3 if negative */
        csel   DTOP,   REG1,   DTOP,   lt;
        asr    DTOP,   DTOP,   IMM(2);     /* because asr rounds toward -infinity */
FUNC_END(four_sm_div)


FUNC_START(eight_sm_div)      /* 8/   m64th-user symmetric divide by 8 */
        cmp    DTOP,   IMM(0);
        add    REG1,   DTOP,   IMM(7);     /* add 7 if negative */
        csel   DTOP,   REG1,   DTOP,   lt;
        asr    DTOP,   DTOP,   IMM(3);     /* asr rounds toward -infinity */
FUNC_END(eight_sm_div)


FUNC_START(less)           /* <    */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   lt;
FUNC_END(less)


FUNC_START(less_equal)     /* <=   m64th-user */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   le;
FUNC_END(less_equal)


FUNC_START(ne)             /* <>   core ext */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   ne;
FUNC_END(ne)


FUNC_START(equal)          /* = */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   eq;
FUNC_END(equal)


FUNC_START(more)           /* > */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   gt;
FUNC_END(more)


FUNC_START(more_equal)     /* >=   m64th-user */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   ge;
FUNC_END(more_equal)


FUNC_START(abs)
        cmp    DTOP,   IMM(0);
        cneg   DTOP,   DTOP,   lt;
FUNC_END(abs)


/* choose ( a b flag -- a|b ) m64th-user if flag is nonzero return a, else b */
FUNC_START(choose)
        cmp    DTOP,   IMM(0);
        cset   REG1,   ne;
        LOAD(  DTOP,   AT(DSTK, REG1, SZ))
        ADD2(IMM(SZ2), DSTK)
FUNC_END(choose)


FUNC_START(lshift)
        DPOP(  REG1)
        lsl    DTOP,   REG1,   DTOP;
FUNC_END(lshift)


FUNC_START(max)
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csel   DTOP,   REG2,   DTOP,   gt;
FUNC_END(max)


FUNC_START(min)
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csel   DTOP,   REG2,   DTOP,   lt;
FUNC_END(min)


/* signed remainder */
FUNC_START(mod)
        DPOP(  REG1)
        DIV3(  REG1,   DTOP,   REG2)
        msub   DTOP,   REG2,   DTOP,   REG1;
FUNC_END(mod)


FUNC_START(rshift)
        DPOP(  REG1)
        lsr    DTOP,   REG1,  DTOP;
FUNC_END(rshift)


FUNC_START(to_byte)        /* to-byte      m64th-user */
        sbfx   DTOP,   DTOP, 0, 8;
FUNC_END(to_byte)

FUNC_START(to_short)       /* to-short     m64th-user */
        sbfx   DTOP,   DTOP, 0, 16;
FUNC_END(to_short)

FUNC_START(to_int)         /* to-int       m64th-user */
        sbfx   DTOP,   DTOP, 0, 32;
FUNC_END(to_int)

FUNC_START(to_char)        /* to-char      m64th-user */
        ubfx   DTOPw,  DTOPw, 0, 8;
FUNC_END(to_char)

FUNC_START(to_ushort)      /* to-ushort    m64th-user */
        ubfx   DTOPw,  DTOPw, 0, 16;
FUNC_END(to_ushort)

FUNC_START(to_uint)        /* to-uint      m64th-user */
        ubfx   DTOPw,  DTOPw, 0, 32;
FUNC_END(to_uint)


FUNC_START(u_less)         /* u<   */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   lo;
FUNC_END(u_less)


FUNC_START(u_less_equal)   /* u<=      m64th-user */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   ls;
FUNC_END(u_less_equal)


FUNC_START(u_more)         /* u>       core ext */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   hi;
FUNC_END(u_more)


FUNC_START(u_more_equal)   /* u>=      m64th-user */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   hs;
FUNC_END(u_more_equal)


#define M4FTUCK
FUNC_START(tuck)           /* tuck      core ( a b -- b a b ) */
        LOAD(  REG1,          AT(DSTK))
        stp    REG1,   DTOP,  [DSTK, -SZ]!;
FUNC_END(tuck)


/* ( x lo hi -- flag ) true if lo <= x < hi \ signed or unsigned */
FUNC_START(within)         /* within   core ext */
        DPOP2( REG2,   REG1)           /* REG2 = lo, REG1 = x       */
        SUB2(  REG2,   DTOP)           /* DTOP = hi-lo              */
        SUB2(  REG2,   REG1)           /* REG1 = x-lo               */
        cmp    REG1,   DTOP;
        csetm  DTOP,   lo;
FUNC_END(within)


FUNC_START(xor)
        DPOP(  REG1)
        XOR2(  REG1,   DTOP)
FUNC_END(xor)
