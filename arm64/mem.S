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

/* cmove ( src-c-addr dst-c-addr u -- ) 'string' word set */
FUNC_START(cmove)
        ASM_CALL(      FUNC(cmove_star))
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(IMM(SZ2), DSTK)
FUNC_END(cmove)

/* cmove* ( src-addr dst-addr u -- src-addr+u dst-addr+u ) m4th-user */
FUNC_START(cmove_star)
        LOAD(  REG1,   AT(DSTK, SZ))       /* a = src                 */
        DPOP(  REG2)                       /* b = dst                 */
        ZERO(  REG0)                       /* @ = index               */
        JB(    DTOP,   IMM(SZ),TO(cmove_1.test))  /* copying < SZ bytes => slow       */
        JAE(   REG1,   REG2,   TO(cmove_SZ.init)) /* copying to lower address => fast */
        SUB3(  REG2,   REG1,   REG3)              /* c = dst - src                    */
        JB(    REG3,   IMM(SZ),TO(cmove_1))       /* copying to too near address => slow */
LABEL(cmove_SZ.init)
        SUB2(  IMM(SZ),DTOP)               /* u -= SZ        */
        /* copy SZ bytes per iteration */
FUNC_ALIGN()
LABEL(cmove_SZ)
        LOAD(  REG3,   AT(REG1, REG0))     /* c = src[index] */
        STOR(  REG3,   AT(REG2, REG0))     /* dst[index] = c */
        ADD2(  IMM(SZ),REG0)               /* index += SZ    */
        JB(    REG0,   DTOP,   TO(cmove_SZ))/* loop if index < u i.e. still > SZ bytes to copy */
        /* copy last SZ bytes */
        LOAD(  REG3,   AT(REG1, DTOP))     /* c = src[u-SZ] */
        STOR(  REG3,   AT(REG2, DTOP))     /* dst[u-SZ] = c */
        ADD2(  IMM(SZ),DTOP)               /* u += SZ       */
        JUMP(  TO(cmove.done))
        /* copy 1 byte per iteration */
LABEL(cmove_1)
        LD_ub( REG3,   AT(REG1, REG0))     /* c = src[index] */
        STORb( REG3,   AT(REG2, REG0))     /* dst[index] = c */
        ADD2(  IMM(1), REG0)               /* index++        */
LABEL(cmove_1.test)
        JB(    REG0,   DTOP,   TO(cmove_1))/* loop if index < u */
LABEL(cmove.done)
        ADD2(  DTOP,   REG1)               /* src += u       */
        ADD2(  REG2,   DTOP)               /* dtop = dst + u */
        STOR(  REG1,   AT(DSTK))           /* ( src+u dst+u )*/
FUNC_END(cmove_star)


/* move ( src-addr dst-addr u -- ) */
FUNC_START(move)
        DPOP2( REG2,   REG1)                   /* b = dst, a = src     */
        JEQ(   DTOP,   IMM(0), TO(move.done))

        ADD4(  REG1,   DTOP,   PSZ,  REG3)     /* c = src_end          */
        MOVI(  SZ8,    REG0)                   /* @ = 8*SZ = step_fwd  */
        JAE(   REG1,   REG2,   TO(move.work))  /* copying to lower address => forward */
        JBE(   REG3,   REG2,   TO(move.work))  /* not overlapping          => forward */

        /* reverse copy, from top to bottom */
        MOVI(  -SZ8,   REG0)                   /* @ = -8*SZ = step_rev */
        ADD4(  REG1,   DTOP,   PSZ,  REG1)     /* a = src_end          */
        ADD4(  REG2,   DTOP,   PSZ,  REG2)     /* b = dst_end          */
        SUB2(IMM(SZ8), REG1)                   /* a = src_end - 8*SZ   */
        SUB2(IMM(SZ8), REG2)                   /* b = dst_end - 8*SZ   */

LABEL(move.work)
        JB(    DTOP,   IMM(8), TO(move.by1))   /* < 8 cells => slow    */
LABEL(move.by8)
        ldp    x5, x6, AT(REG1, IMM(0));
        ldp    x7, x8, AT(REG1, IMM(SZ2));
        ldp    x9, x10,AT(REG1, IMM(SZ4));
        ldp    x11,x12,AT(REG1, IMM(SZ6));
        SUB2(IMM(8),   DTOP)
        stp    x5, x6, AT(REG2, IMM(0));
        stp    x7, x8, AT(REG2, IMM(SZ2));
        stp    x9, x10,AT(REG2, IMM(SZ4));
        stp    x11,x12,AT(REG2, IMM(SZ6));
        ADD2(  REG0,   REG1)
        ADD2(  REG0,   REG2)
        JAE(   DTOP,   IMM(8),  TO(move.by8))

LABEL(move.by1)
        JEQ(   DTOP,   IMM(0),  TO(move.done))
        SAR2(IMM(3),   REG0)                   /* @ = +/- SZ           */
        JG(    REG0,   IMM(0),  TO(move.by1.loop))
        ADD2(IMM(SZ7), REG1)                   /* a += 7*SZ            */
        ADD2(IMM(SZ7), REG2)                   /* b += 7*SZ            */
LABEL(move.by1.loop)
        LOAD(  REG4,   AT(REG1))
        SUB2(IMM(1),   DTOP)
        STOR(  REG4,   AT(REG2))
        ADD2(  REG0,   REG1)
        ADD2(  REG0,   REG2)
        JNE(   DTOP,   IMM(0),  TO(move.by1.loop))

LABEL(move.done)
        DPOP___DTOP()
FUNC_END(move)


/*
 * crc-string/simd ( c-addr u -- crc ) compute CRC32c of a string
 * TODO: use NEON CPU instructions crc32*
 */
FUNC_DEF(crc_string_simd)

/* crc-string ( c-addr u -- crc ) compute CRC32c of a string */
FUNC_START(crc_string)     /* crc-string ( c-addr u -- crc ) m4th-user */
        MOVE(  DTOP,   REG2)               /* b = u                    */
        MOVI(  0xffffffff, REG3w)          /* c = 0xffffffff           */
        DPOP___DTOP()                      /* dtop = c-addr            */
        JZ(    REG2,   TO(crc_string.done))
        ZERO(  REG0)                       /* @ = 0                    */
        ADDROF_4G(m4th_crctable,   REG4)   /* d = table                */
FUNC_ALIGN()
LABEL(crc_string.loop)
        LD_ub( REG1,   AT(DTOP, REG0, 1))  /* a = c-addr[@] = str[i]   */
        INC1(  REG0)                       /* @++                      */
        XOR2(  REG3w,  REG1w)              /* a = str[i] ^ crc         */
        cmp    REG0,   REG2;               /* if (i < u)               */
        AND2(IMM(0xff),REG1w)              /* a &= 0xff                */
        LOAD(  REG1,   AT(REG4, REG1, SZ)) /* a = table[a]             */
        eor    REG3w,  REG1w, REG3w, lsr 8;/* crc = a ^ (crc >> 8)     */
        b.lo   TO(crc_string.loop);
LABEL(crc_string.done)
        NOT2(  REG3w,  DTOPw)
FUNC_END(crc_string)

FUNC_SIZE(crc_string_simd)


FUNC_START(string_equal)   /* string=  ( addr1 addr2 u -- addr1 addr2 u t|f ) m4th-user */
        ldp    REG2,   REG1,    AT(DSTK);                /* b = addr2, a = addr1 */
        DPUSH( DTOP)
        JEQ(   REG1,   REG2,    TO(string_equal.true))   /* addr1 == addr2 */
        JZ(    DTOP,            TO(string_equal.true))   /* u == 0         */
        ZERO(  REG0)
        JB(    DTOP,   IMM(8),  TO(string_equal.byte))   /* < 8 bytes */
        SUB2(  IMM(8), DTOP)
LABEL(string_equal.cell)
        LOAD(  REG3,   AT(REG1, REG0, 1))
        LOAD(  REG4,   AT(REG2, REG0, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        ADD2(  IMM(8), REG0)
        JB(    REG0,   DTOP,    TO(string_equal.cell))  /* > 8 bytes left ? */
        LOAD(  REG3,   AT(REG1, DTOP, 1))                  /* compare last 8 bytes */
        LOAD(  REG4,   AT(REG2, DTOP, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        JUMP(                   TO(string_equal.true))
LABEL(string_equal.byte)
        LD_ub( REG3,   AT(REG1, REG0, 1))
        LD_ub( REG4,   AT(REG2, REG0, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        INC1(  REG0)
        JB(    REG0,   DTOP,    TO(string_equal.byte))
LABEL(string_equal.true)
        MOVE(  IMM_1,  DTOP)
        NEXT()
LABEL(string_equal.false)
        ZERO(  DTOP)
FUNC_END(string_equal)
