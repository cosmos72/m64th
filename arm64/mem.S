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


/* cmove/count ( src-addr dst-addr u -- src-addr+u dst-addr+u ) m4th-user */
FUNC_START(cmove_count)
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
FUNC_END(cmove_count)


/* -cmove/count ( src-addr dst-addr u -- src-addr-u dst-addr-u ) m4th-user */
/* backward copy u bytes from src-1..src-u to dst-1..dst-u and return updated addresses */
FUNC_START(minus_cmove_count)
        NEG1(  DTOP)                       /* dtop = -u               */
        LOAD(  REG1,   AT(DSTK, SZ))       /* a = src                 */
        DPOP(  REG2)                       /* b = dst                 */
        ZERO(  REG0)                       /* @ = index               */
        JA(    DTOP,   IMM(-SZ),TO(cmove_1.test)) /* copying < SZ bytes => slow        */
        JAE(   REG2,   REG1,   TO(cmove_SZ.init)) /* copying to higher address => fast */
        SUB3(  REG1,   REG2,   REG3)              /* c = src - dst                     */
        JB(    REG3,   IMM(SZ),TO(cmove_1))       /* copying to too near address => slow */
LABEL(minus_cmove_SZ.init)
        ADD2(  IMM(SZ),DTOP)               /* dtop = -u + SZ */
        /* copy SZ bytes per iteration */
FUNC_ALIGN()
LABEL(minus_cmove_SZ)
        SUB2(  IMM(SZ),REG0)               /* index -= SZ    */
        LOAD(  REG3,   AT(REG1, REG0))     /* c = src[index] */
        STOR(  REG3,   AT(REG2, REG0))     /* dst[index] = c */
        JA(    REG0,   DTOP,   TO(cmove_SZ))/* loop if index > -u i.e. still > SZ bytes to copy */
        /* copy last SZ bytes */
        LOAD(  REG3,   AT(REG1, DTOP))     /* c = src[-u+SZ] */
        STOR(  REG3,   AT(REG2, DTOP))     /* dst[-u+SZ] = c */
        SUB2(  IMM(SZ),DTOP)               /* dtop = -u      */
        JUMP(  TO(cmove.done))
        /* copy 1 byte per iteration */
LABEL(minus_cmove_1)
        SUB2(  IMM(1), REG0)               /* index--        */
        LD_ub( REG3,   AT(REG1, REG0))     /* c = src[index] */
        STORb( REG3,   AT(REG2, REG0))     /* dst[index] = c */
LABEL(minus_cmove_1.test)
        JA(    REG0,   DTOP,   TO(cmove_1))/* loop if index > -u */
LABEL(minus_cmove.done)
        ADD2(  DTOP,   REG1)               /* src -= u       */
        ADD2(  REG2,   DTOP)               /* dtop = dst - u */
        STOR(  REG1,   AT(DSTK))           /* ( src-u dst-u )*/
FUNC_END(minus_cmove_count)


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


/* crc-cell/simd ( x -- crc ) m4th-user: compute CRC32c of a cell */
FUNC_START(crc_cell_simd)
        MOVI(  0xffffffff, REG1w)      /* dtop = 0xffffffff        */
        /*
         * symbolic ASM instructions crc32c*
         * would require compiler/assembler flag -march=armv8.1-a
         */
        .4byte 0x9ad45c21;             /* crc32cx REG1w, REG1w, DTOP;  */
        NOT2(  REG1w,    DTOPw)
FUNC_END(crc_cell_simd)


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


/*
 * crc-string/simd ( c-addr u -- crc ) compute CRC32c of a string
 * uses ARM NEON instructions crc32cb, crc32ch, crc32cw, crc32cx
 */
FUNC_START(crc_string_simd)
        MOVI(  0xffffffff, REG3w)          /* c = 0xffffffff           */
        DPOP(  REG1)                       /* a = c-addr               */
        ZERO(  REG0)                       /* @ = i = 0                */
        JB(    DTOP,   IMM(8), TO(crc_string_simd.upto7))
#if 1
        JB(    DTOP,   IMM(64),TO(crc_string_simd.by8))

        SUB2(IMM(64),  DTOP)
FUNC_ALIGN()
LABEL(crc_string_simd.by64.loop)
        ldp    x4, x5, AT(REG1);
        ldp    x6, x7, AT(REG1, 16);
        ldp    x8, x9, AT(REG1, 32);
        ldp    x10,x11,AT(REG1, 48);
        ADD2(IMM(64),  REG0)               /* i += 64                  */
        ADD2(IMM(64),  REG1)               /* c-addr += 64             */
        /*
         * symbolic ASM instructions crc32c*
         * would require compiler/assembler flag -march=armv8.1-a
         */
        .4byte 0x9ac45c63;             /* crc32cx REG3w, REG3w,  x4;    */
        .4byte 0x9ac55c63;             /* crc32cx REG3w, REG3w,  x5;    */
        .4byte 0x9ac65c63;             /* crc32cx REG3w, REG3w,  x6;    */
        .4byte 0x9ac75c63;             /* crc32cx REG3w, REG3w,  x7;    */
        .4byte 0x9ac85c63;             /* crc32cx REG3w, REG3w,  x8;    */
        .4byte 0x9ac95c63;             /* crc32cx REG3w, REG3w,  x9;    */
        .4byte 0x9aca5c63;             /* crc32cx REG3w, REG3w,  x10;   */
        .4byte 0x9acb5c63;             /* crc32cx REG3w, REG3w,  x11;   */

        JBE(   REG0,   DTOP,   TO(crc_string_simd.by64.loop))
        ADD2(IMM(64),  DTOP)
        SUB2(  REG0,   REG1)               /* c-addr -= i              */
        SUB3(  DTOP,   REG0,   REG4)       /* d = left = u - i         */
        JB(    REG4,   IMM(8), TO(crc_string_simd.upto7))

LABEL(crc_string_simd.by8)
#endif /* 1 */

        SUB2(  IMM(8), DTOP)
FUNC_ALIGN()
LABEL(crc_string_simd.by8.loop)
        LOAD(  REG2,   AT(REG1, REG0, 1))  /* b = c-addr[i...i+7]      */
        ADD2(  IMM(8), REG0)
        .4byte 0x9ac25c63;             /* crc32cx REG3w, REG3w,  REG2; */
        JBE(   REG0,   DTOP,   TO(crc_string_simd.by8.loop))
        ADD2(  IMM(8), DTOP)
LABEL(crc_string_simd.upto7)
        ADDI(  REG0,   4,  REG4)
        JA(    REG4,   DTOP, TO(crc_string_simd.upto3)) /* jump if (i + 4 > u) */
        LD_uw( REG2,   AT(REG1, REG0, 1))
        MOVE(  REG4,   REG0)           /* i += 4                        */
        .4byte 0x1ac25863;             /* crc32cw REG3w, REG3w,  REG2w; */
LABEL(crc_string_simd.upto3)
        ADDI(  REG0,   2,  REG4)
        JA(    REG4,   DTOP, TO(crc_string_simd.upto1)) /* jump if (i + 2 > u) */
        LD_uh( REG2,   AT(REG1, REG0, 1))
        MOVE(  REG4,   REG0)           /* i += 2                        */
        .4byte 0x1ac25463;             /* crc32ch REG3w, REG3w,  REG2w; */
LABEL(crc_string_simd.upto1)
        JAE(   REG0,   DTOP, TO(crc_string_simd.0)) /* jump if (i >= u) */
        LD_ub( REG2,   AT(REG1, REG0, 1))
        .4byte 0x1ac25063;             /* crc32cb REG3w, REG3w,  REG2w; */
LABEL(crc_string_simd.0)
        NOT2(  REG3w,  DTOPw)
FUNC_END(crc_string_simd)


/* fill ( c-addr u char -- ) core */
FUNC_START(fill)
        LOAD(  REG1,   AT(DSTK, SZ))           /* a = c-addr                  */
        LOAD(  REG2,   AT(DSTK))               /* b = u = count               */
        AND3(  DTOPw,  IMM(255),DTOPw)
        orr    DTOPw,  DTOPw,   DTOPw,  lsl 8;
        orr    DTOPw,  DTOPw,   DTOPw,  lsl 16;
        orr    DTOP,   DTOP,    DTOP,   lsl 32;/* DTOP = ch<<56|ch<<48 ... | ch<<8|ch */
        JB(    REG2,   IMM(16), TO(fill.tiny))
        JB(    REG2,   IMM(64), TO(fill.small))

        SUB2(IMM(16),  REG1)                   /* c-addr -= 16                */
        SUB2(IMM(64),  REG2)                   /* count  -= 64                */
FUNC_ALIGN()
LABEL(fill.large.loop)
        stp    DTOP,   DTOP, AT(REG1, 16);
        stp    DTOP,   DTOP, AT(REG1, 32);
        stp    DTOP,   DTOP, AT(REG1, 48);
        stp    DTOP,   DTOP, [REG1, 64]!;      /* pre-increment c-addr        */
        subs   REG2,   REG2, IMM(64);          /* count -= 64; update flags   */
        b.hs   TO(fill.large.loop);
        ADD2(IMM(64),  REG2)                   /* count  += 64                */
        ADD2(IMM(16),  REG1)                   /* c-addr += 16                */
        JB(    REG2,   IMM(16), TO(fill.small.tail)) /* jump if count < 16     */

FUNC_ALIGN()
LABEL(fill.small)
        SUB2(IMM(16),  REG2)                   /* count -= 16                 */
        stp    DTOP,   DTOP, AT(REG1), 16;     /* post-increment c-addr       */
        JAE(   REG2,   IMM(16), TO(fill.small))/* loop while count >= 16      */

LABEL(fill.small.tail)
        /* store 16 bytes at c-addr[u - 16] */
        add    REG1,   REG1, REG2;             /* a = c-addr + u              */
        stp    DTOP,   DTOP, AT(REG1, IMM(-16));
        JUMP(  TO(fill.done))

LABEL(fill.tiny)
        tbz    REG2,   IMM(3),  TO(fill.upto7);/* jump if count & (1<<3) == 0 */
        str    DTOP,   AT(REG1),  8;
LABEL(fill.upto7)
        tbz    REG2,   IMM(2),  TO(fill.upto3);/* jump if count & (1<<2) == 0 */
        str    DTOPw,  AT(REG1),  4;
LABEL(fill.upto3)
        tbz    REG2,   IMM(1),  TO(fill.upto1);/* jump if count & (1<<1) == 0 */
        strh   DTOPh,  AT(REG1),  2;
LABEL(fill.upto1)
        tbz    REG2,   IMM(0),  TO(fill.done); /* jump if count & (1<<0) == 0 */
        strb   DTOPb,  AT(REG1);
LABEL(fill.done)
        LOAD(  DTOP,   AT(DSTK, SZ2))
        ADD2(IMM(SZ3), DSTK)
FUNC_END(fill)


FUNC_START(string_equal)   /* string=  ( addr1 addr2 u -- addr1 addr2 u t|f ) m4th-user */
        ldp    REG2,   REG1,    AT(DSTK);              /* b = addr2, a = addr1 */
        DPUSH__DTOP()
        JEQ(   REG1,   REG2,    TO(string_equal.true)) /* addr1 == addr2 */
        JZ(    DTOP,            TO(string_equal.true)) /* u == 0         */
        ZERO(  REG0)
        JB(    DTOP,   IMM(SZ), TO(string_equal.byte)) /* < SZ bytes */
        SUB2(IMM(SZ), DTOP)
LABEL(string_equal.cell)
        LOAD(  REG3,   AT(REG1, REG0, 1))
        LOAD(  REG4,   AT(REG2, REG0, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        ADD2(  IMM(8), REG0)
        JB(    REG0,   DTOP,    TO(string_equal.cell)) /* >= SZ bytes left ? */
        LOAD(  REG3,   AT(REG1, DTOP, 1))              /* compare last SZ bytes */
        LOAD(  REG4,   AT(REG2, DTOP, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
LABEL(string_equal.true)
        MOVE(  IMM_1,  DTOP)
        JUMP(                   FUNC_RET(string_equal))

LABEL(string_equal.byte)
        LD_ub( REG3,   AT(REG1, REG0, 1))
        LD_ub( REG4,   AT(REG2, REG0, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        INC1(  REG0)
        JB(    REG0,   DTOP,    TO(string_equal.byte))
        MOVE(  IMM_1,  DTOP)
        JUMP(                   FUNC_RET(string_equal))

LABEL(string_equal.false)
        ZERO(  DTOP)
FUNC_END(string_equal)


/*
 * atomic1+! ( addr -- n' ) atomically increment cell at addr by 1.
 * return cell old value.
 */
FUNC_START(atomic_one_plus_store)
        ldaxr  REG1,   AT(REG0);               /* a = dtop[0] atomic fetch   */
        ADDI(  REG1,   1,      REG2)           /* b = a + 1                  */
        stlxr  REG3w,  REG2,   AT(DTOP);       /* try atomic store           */
        JNZ(   REG3w,  FUNC(atomic_one_plus_store))
        MOVE(  REG1,   DTOP)
FUNC_END(atomic_one_plus_store)


/*
 * atomic+! ( n addr -- n' ) atomically increment cell at addr by n.
 * return cell old value.
 */
FUNC_START(atomic_plus_store)
        LOAD(  REG0,   AT(DSTK))               /* @ = n = delta              */
        MOVE(  DTOP,   REG1)                   /* a = addr                   */
LABEL(atomic_plus_store.retry)
        ldaxr  DTOP,   AT(REG1);               /* dtop = addr[0] atomic fetch*/
        ADD4(  DTOP,   REG0,0, REG2)           /* b = dtop + 1               */
        stlxr  REG3w,  REG2,   AT(REG1);       /* try atomic store           */
        JNZ(   REG3w,  TO(atomic_plus_store.retry))
FUNC_END(atomic_plus_store)
