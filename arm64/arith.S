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


#define M4F_LIT2S_
FUNC_START(_lit2s_)        /* (lit-2s) push to dstack the int16 at following IP */
        DPUSH__DTOP()
        ldrsh  DTOP_sh,AT(IP), 2;
FUNC_END(_lit2s_)


#define M4F_LIT4S_
FUNC_START(_lit4s_)        /* (lit-4s) push to dstack the int32 at following IP */
        DPUSH__DTOP()
        ldrsw  DTOP_sw,AT(IP), 4;
FUNC_END(_lit4s_)


#define M4F_LIT8S_
FUNC_START(_lit8s_)        /* (lit-8s) push to dstack the int64 at following IP */
        DPUSH__DTOP()
        ldr    DTOP,   AT(IP), SZ;
FUNC_END(_lit8s_)


#define M4F_MISSING_
FUNC_START(_missing_)      /* (missing) called instead of invalid/unimplemented function */
        .int   0; /* udf */            /* crash with SIGILL */
FUNC_END(_missing_)


/* signed divide */
FUNC_START(div)      /* / */
        DPOP(  REG1)
        DIV3(  REG1,   DTOP,   DTOP)
FUNC_END(div)


/* signed divide & remainder */
FUNC_START(div_mod)          /* /mod */
        LOAD(  REG1,   AT(DSTK))
        DIV3(  REG1,   DTOP,   REG2)
        msub   REG1,   REG2,   DTOP,   REG1;
        MOVE(  REG2,   DTOP)
        STOR(  REG1,   AT(DSTK))
FUNC_END(div_mod)


FUNC_START(zero_less_equal)   /* 0<=  m4th-user   */
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


FUNC_START(zero_more_equal)/* 0>=  m4th-user  */
        cmp    DTOP,   IMM(0);
        csetm  DTOP,   ge;
FUNC_END(zero_more_equal)


FUNC_START(two_sm_div)     /* 2sm/ m4th-user symmetric divide by 2 */
        add    DTOP,   DTOP,   DTOP, lsr IMM(63);
        asr    DTOP,   DTOP,   IMM(1);
FUNC_END(two_sm_div)


#define M4FTWO_NIP
FUNC_START(two_nip)        /* 2nip     m4th-user */
        LOAD(  REG1,   AT(DSTK))
        str    REG1,   [DSTK, SZ2]!;
FUNC_END(two_nip)


/* 2pick ( du ... d1 d0 u -- du ... d1 d0 du ) m4th-user */
FUNC_START(two_pick)
        ADD4(  DSTK,   DTOP,   IMM(PSZ+1), REG1)
        ldp    DTOP,   REG2,   AT(REG1);
        DPUSH( REG2)
FUNC_END(two_pick)


/* 2rot  ( a b c d e f -- c d e f a b ) */
#define M4FTWO_ROT
FUNC_START(two_rot)
        ldp    REG2,   REG1,   AT(DSTK, SZ3);  /* b, a            */
        ldp    REG4,   REG3,   AT(DSTK, SZ);   /* d, c            */
        ldr    REG0,           AT(DSTK);       /* e               */
        stp    REG4,   REG3,   AT(DSTK, SZ3);  /* ( c d _ _ _ _ ) */
        stp    DTOP,   REG0,   AT(DSTK, SZ);   /* ( c d e f _ _ ) */
        str    REG1,           AT(DSTK);       /* ( c d e f a _ ) */
        MOVE(  REG2,   DTOP)                   /* ( c d e f a b ) */
FUNC_END(two_rot)


/* -2rot  ( a b c d e f -- e f a b c d ) m4th-user */
#define M4FMINUS_TWO_ROT
FUNC_START(minus_two_rot)
        ldp    REG0,   REG4,   AT(DSTK);       /* e, d            */
        ldp    REG3,   REG2,   AT(DSTK, SZ2);  /* c, b            */
        ldr    REG1,           AT(DSTK, SZ4);  /* a               */
        stp    REG3,   REG2,   AT(DSTK);       /* ( _ _ _ b c _ ) */
        stp    REG1,   DTOP,   AT(DSTK, SZ2);  /* ( _ f a b c _ ) */
        str    REG0,           AT(DSTK, SZ4);  /* ( e f a b c _ ) */
        MOVE(  REG4,   DTOP)                   /* ( e f a b c d ) */
FUNC_END(minus_two_rot)


/* 2swap ( a b c d -- c d a b ) */
#define M4FTWO_SWAP
FUNC_START(two_swap)
        ldp    REG1,   REG2, AT(DSTK);
        ldr    REG3,         AT(DSTK, SZ2);
        stp    DTOP,   REG1, AT(DSTK, SZ);
        str    REG3,         AT(DSTK);
        MOVE(  REG2,   DTOP)
FUNC_END(two_swap)


FUNC_START(four_sm_div)    /* 4sm/ m4th-user symmetric divide by 4 */
        cmp    DTOP,   IMM(0);
        add    REG1,   DTOP,   IMM(3);     /* add 3 if negative */
        csel   DTOP,   REG1,   DTOP,   lt;
        asr    DTOP,   DTOP,   IMM(2);     /* because asr rounds toward -infinity */
FUNC_END(four_sm_div)


FUNC_START(eight_sm_div)      /* 8/   m4th-user symmetric divide by 8 */
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


FUNC_START(less_equal)     /* <=   m4th-user */
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


FUNC_START(more_equal)     /* >=   m4th-user */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   ge;
FUNC_END(more_equal)


FUNC_START(abs)
        cmp    DTOP,   IMM(0);
        cneg   DTOP,   DTOP,   lt;
FUNC_END(abs)


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


FUNC_START(to_byte)        /* to-byte      m4th-user */
        sbfx   DTOP,   DTOP, 0, 8;
FUNC_END(to_byte)

FUNC_START(to_short)       /* to-short     m4th-user */
        sbfx   DTOP,   DTOP, 0, 16;
FUNC_END(to_short)

FUNC_START(to_int)         /* to-int       m4th-user */
        sbfx   DTOP,   DTOP, 0, 32;
FUNC_END(to_int)

FUNC_START(to_char)        /* to-char      m4th-user */
        ubfx   DTOPw,  DTOPw, 0, 8;
FUNC_END(to_char)

FUNC_START(to_ushort)      /* to-ushort    m4th-user */
        ubfx   DTOPw,  DTOPw, 0, 16;
FUNC_END(to_ushort)

FUNC_START(to_uint)        /* to-uint      m4th-user */
        ubfx   DTOPw,  DTOPw, 0, 32;
FUNC_END(to_uint)


FUNC_START(u_less)         /* u<   */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   lo;
FUNC_END(u_less)


FUNC_START(u_less_equal)   /* u<=      m4th-user */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   ls;
FUNC_END(u_less_equal)


FUNC_START(u_more)         /* u>       core ext */
        DPOP(  REG2)
        cmp    REG2,   DTOP;
        csetm  DTOP,   hi;
FUNC_END(u_more)


FUNC_START(u_more_equal)   /* u>=      m4th-user */
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
