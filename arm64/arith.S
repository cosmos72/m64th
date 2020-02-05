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


/* signed divide */
FUNC_START(div)      /* / */
        DPOP(  REG1)
        DIV3(  REG1, DTOP, DTOP)
FUNC_END(div)


/* signed divide & remainder */
FUNC_START(div_mod)          /* /mod */
        LOAD(  REG1, AT(DSTK))
        DIV3(  REG1, DTOP, REG2)
        msub   REG1, REG2, DTOP, REG1;
        MOVE(  REG2, DTOP)
        STOR(  REG1, AT(DSTK))
FUNC_END(div_mod)


FUNC_START(zero_less_equal)   /* 0<=  m4th-user   */
        cmp    DTOP, IMM(0);
        csetm  DTOP, le;
FUNC_END(zero_less_equal)


FUNC_START(zero_ne)    /* 0<>  core ext */
        cmp    DTOP, IMM(0);
        csetm  DTOP, ne;
FUNC_END(zero_ne)


FUNC_START(zero_equal)        /* 0=   */
        cmp    DTOP, IMM(0);
        csetm  DTOP, eq;
FUNC_END(zero_equal)


FUNC_START(zero_more)      /* 0>   */
        cmp    DTOP, IMM(0);
        csetm  DTOP, gt;
FUNC_END(zero_more)


FUNC_START(zero_more_equal)/* 0>=  m4th-user  */
        cmp    DTOP, IMM(0);
        csetm  DTOP, ge;
FUNC_END(zero_more_equal)


FUNC_START(two_div)        /* 2/   */
        add    DTOP, DTOP, DTOP, lsr IMM(63);
        asr    DTOP, DTOP, IMM(1);
FUNC_END(two_div)


FUNC_START(two_times)      /* 2*   */
        lsl    DTOP, DTOP, IMM(1);
FUNC_END(two_times)


FUNC_START(four_div)       /* 4/   m4th-user */
        cmp    DTOP,   IMM(0);
        add    REG1,   DTOP,   IMM(3);     /* add 3 if negative */
        csel   DTOP,   REG1,   DTOP,   lt;
        asr    DTOP,   DTOP,   IMM(2);     /* because asr rounds toward -infinity */
FUNC_END(four_div)



FUNC_START(eight_div)      /* 8/   m4th-user */
        cmp    DTOP,   IMM(0);
        add    REG1,   DTOP,   IMM(7);     /* add 7 if negative */
        csel   DTOP,   REG1,   DTOP,   lt;
        asr    DTOP,   DTOP,   IMM(3);     /* because asr rounds toward -infinity */
FUNC_END(eight_div)


FUNC_START(less)           /* <    */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, lt;
FUNC_END(less)


FUNC_START(less_equal)     /* <=   m4th-user */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, le;
FUNC_END(less_equal)


FUNC_START(ne)             /* <>   core ext */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, ne;
FUNC_END(ne)


FUNC_START(equal)          /* = */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, eq;
FUNC_END(equal)


FUNC_START(more)           /* > */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, gt;
FUNC_END(more)


FUNC_START(more_equal)     /* >=   m4th-user */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, ge;
FUNC_END(more_equal)


FUNC_START(question_dup)   /* ?dup */
        cbz    DTOP, FUNC_SYM_NEXT(question_dup);
        DPUSH( DTOP)
FUNC_END(question_dup)


FUNC_START(abs)
        cmp    DTOP, IMM(0);
        cneg   DTOP, DTOP, lt;
FUNC_END(abs)


FUNC_START(lshift)
        DPOP(  REG1)
        lsl    DTOP, REG1, DTOP;
FUNC_END(lshift)


FUNC_START(max)
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csel   DTOP, REG2, DTOP, gt;
FUNC_END(max)


FUNC_START(min)
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csel   DTOP, REG2, DTOP, lt;
FUNC_END(min)

/* signed remainder */
FUNC_START(mod)
        DPOP(  REG1)
        DIV3(  REG1, DTOP, REG2)
        msub   DTOP, REG2, DTOP, REG1;
FUNC_END(mod)


FUNC_START(rshift)
        DPOP(  REG1)
        lsr    DTOP, REG1, DTOP;
FUNC_END(rshift)


FUNC_START(to_byte)    /* to-byte */
        sbfx   DTOP, DTOP, 0, 8;
FUNC_END(to_byte)

FUNC_START(to_short)   /* to-short */
        sbfx   DTOP, DTOP, 0, 16;
FUNC_END(to_short)

FUNC_START(to_int)     /* to-int */
        sbfx   DTOP, DTOP, 0, 32;
FUNC_END(to_int)

FUNC_START(to_char)    /* to-char */
        ubfx   DTOPw, DTOPw, 0, 8;
FUNC_END(to_char)

FUNC_START(to_ushort)  /* to-ushort */
        ubfx   DTOPw, DTOPw, 0, 16;
FUNC_END(to_ushort)

FUNC_START(to_uint)    /* to-uint */
        ubfx   DTOPw, DTOPw, 0, 32;
FUNC_END(to_uint)


FUNC_START(u_less)         /* u<   */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, lo;
FUNC_END(u_less)


FUNC_START(u_less_equal)   /* u<=  m4th-user */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, ls;
FUNC_END(u_less_equal)


FUNC_START(u_more)         /* u>   core ext */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, hi;
FUNC_END(u_more)


FUNC_START(u_more_equal)   /* u>=  m4th-user */
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csetm  DTOP, hs;
FUNC_END(u_more_equal)


/* ( x lo hi -- flag ) true if lo <= x < hi \ signed or unsigned */
FUNC_START(within)         /* within   core ext */
        DPOP(  REG2)                   /* REG2 = lo                 */
        DPOP(  REG1)                   /* REG1 = x                  */
        SUB2(  REG2,   DTOP)           /* DTOP = hi-lo              */
        SUB2(  REG2,   REG1)           /* REG1 = x-lo               */
        cmp    REG1,   DTOP;
        csetm  DTOP,   lo;
FUNC_END(within)


FUNC_START(xor)
        DPOP(  REG1)
        eor    DTOP, DTOP, REG1;
FUNC_END(xor)
