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


#ifndef M4FC_STORE
FUNC_START(c_store)        /* c! */
        DPOP(  REG1)
        STORb( REG1,  AT(DTOP))
        DPOP___DTOP()
FUNC_END(c_store)
#endif


FUNC_START(count)          /* count */
        LD_ub( REG1,   AT(DTOP))
        INC1(  DTOP)
        DPUSH( DTOP)
        MOVE(  REG1,   DTOP)
FUNC_END(count)

#ifndef M4FSHORT_STORE
FUNC_START(short_store)    /* short!   m4th-user */
        DPOP(  REG1)
        STORh( REG1,  AT(DTOP))
        DPOP___DTOP()
FUNC_END(short_store)
#endif

#ifndef M4FINT_STORE
FUNC_START(int_store)      /* int!     m4th-user */
        DPOP(  REG1)
        STORw( REG1,   AT(DTOP))
        DPOP___DTOP()
FUNC_END(int_store)
#endif

#ifndef M4FSTORE
FUNC_START(store)          /* ! */
        DPOP(  REG1)
        STOR(  REG1,   AT(DTOP))
        DPOP___DTOP()
FUNC_END(store)
#endif


FUNC_START(two_store)      /* 2!  ( y x addr -- ) */
        LOAD(  REG1,   AT(DSTK))
        LOAD(  REG2,   AT(DSTK, SZ))
        STOR(  REG1,   AT(DTOP))
        STOR(  REG2,   AT(DTOP, SZ))
        LOAD(  DTOP,   AT(DSTK, SZ2))
        ADD2(IMM(SZ3), DSTK)
FUNC_END(two_store)


FUNC_START(byte_fetch)     /* byte@    m4th-user */
        LD_sb(DTOP,    AT(DTOP))
FUNC_END(byte_fetch)


FUNC_START(c_fetch)        /* c@ */
        LD_ub(DTOP,    AT(DTOP))
FUNC_END(c_fetch)


FUNC_START(short_fetch)    /* short@   m4th-user */
        LD_sh(DTOP,    AT(DTOP))
FUNC_END(short_fetch)


FUNC_START(ushort_fetch)   /* ushort@  m4th-user */
        LD_uh(DTOP,    AT(DTOP))
FUNC_END(ushort_fetch)


FUNC_START(int_fetch)      /* int@     m4th-user */
        LD_sw(DTOP,    AT(DTOP))
FUNC_END(int_fetch)


FUNC_START(uint_fetch)     /* uint@    m4th-user */
        LD_uw(DTOP,    AT(DTOP))
FUNC_END(uint_fetch)


FUNC_START(fetch)          /* @ */
        LOAD(  DTOP, AT(DTOP))
FUNC_END(fetch)


FUNC_START(two_fetch)      /* 2@ */
        LOAD(  REG1, AT(DTOP, SZ))
        LOAD(  DTOP, AT(DTOP))
        DPUSH( REG1)
FUNC_END(two_fetch)


/* crc-byte ( x -- crc ) m4th-user: compute CRC32c of a byte */
FUNC_START(crc_byte)
        DPUSH( DTOP)                       /* ( x _                  ) */
        STOR(  DSTK,   AT(DSTK, -SZ))
        SUB2( IMM(SZ), DSTK)               /* ( x &x _               ) */
        MOVE( IMM(1),  DTOP)               /* ( x &x 1               ) */
        ASM_CALL(      FUNC(crc_string))   /* ( x crc                ) */
        ADD2( IMM(SZ), DTOP)               /* ( crc                  ) */
FUNC_END(crc_byte)


/* crc-short ( x -- crc ) m4th-user: compute CRC32c of a short */
FUNC_START(crc_short)
        DPUSH( DTOP)                       /* ( x _                  ) */
        STOR(  DSTK,   AT(DSTK, -SZ))
        SUB2( IMM(SZ), DSTK)               /* ( x &x _               ) */
        MOVE( IMM(2),  DTOP)               /* ( x &x 2               ) */
        ASM_CALL(      FUNC(crc_string))   /* ( x crc                ) */
        ADD2( IMM(SZ), DTOP)               /* ( crc                  ) */
FUNC_END(crc_short)


/* crc-int ( x -- crc ) m4th-user: compute CRC32c of an int */
FUNC_START(crc_int)
        DPUSH( DTOP)                       /* ( x _                  ) */
        STOR(  DSTK,   AT(DSTK, -SZ))
        SUB2( IMM(SZ), DSTK)               /* ( x &x _               ) */
        MOVE( IMM(4),  DTOP)               /* ( x &x 4               ) */
        ASM_CALL(      FUNC(crc_string))   /* ( x crc                ) */
        ADD2( IMM(SZ), DTOP)               /* ( crc                  ) */
FUNC_END(crc_int)


/* crc-cell ( x -- crc ) m4th-user: compute CRC32c of a cell */
FUNC_START(crc_cell)
        DPUSH( DTOP)                       /* ( x _                  ) */
        STOR(  DSTK,   AT(DSTK, -SZ))
        SUB2( IMM(SZ), DSTK)               /* ( x &x _               ) */
        MOVE( IMM(SZ), DTOP)               /* ( x &x SZ              ) */
        ASM_CALL(      FUNC(crc_string))   /* ( x crc                ) */
        ADD2( IMM(SZ), DTOP)               /* ( crc                  ) */
FUNC_END(crc_cell)


#ifndef M4FDIV_STRING
/* /string ( c-addr u n -- c-addr' u' )  'string' word set */
FUNC_START(div_string)
        MOVE(  DTOP,   REG1)           /* a = n       */
        DPOP___DTOP()                  /* dtop = u    */
        LOAD(  REG2,   AT(DSTK))       /* b = c-addr  */
        SUB2(  REG1,   DTOP)           /* dtop -= n   */
        ADD2(  REG1,   REG2)           /* c-addr += n */
        STOR(  REG2,   AT(DSTK))
FUNC_END(div_string)
#endif /* M4FDIV_STRING */


FUNC_START(line_find_char) /* ( c-addr u ch -- u' ) get index of char or CR */
        ZERO(  REG1)                   /* a = index = 0 */
        DPOP2( REG2,   REG3)           /* b = max = u,  c = c-addr    */
        JZ(    REG2,   TO(line_find_char.done))
LABEL(line_find_char.loop)
        LD_ub( REG4,   AT(REG3, REG1, 1)) /* d = c-addr[index] */
        JEQ(   REG4,   DTOP,   TO(line_find_char.done))
        JEQ(   REG4,   IMM(10),TO(line_find_char.done))
        JEQ(   REG4,   IMM(13),TO(line_find_char.done))
        INC1(  REG1)
        JB(    REG1,   REG2,   TO(line_find_char.loop))
LABEL(line_find_char.done)
        MOVE(  REG1,   DTOP)
FUNC_END(line_find_char)


/* ( xu xu_1 ... x1 x0 u -- xu_1 ... x1 x0 xu ) */
FUNC_START(roll)
        LOAD(  REG1,   AT(DSTK, DTOP, SZ)) /* a = xu                             */
        ADDI(  DSTK,   SZ,   REG2)         /* b = address of x1                  */
        STOR(  REG1,   AT(DSTK, -SZ))      /* ( xu xu_1 ... x1 x0 xu u         ) */
        STOR(  DSTK,   AT(DSTK, -SZ2))     /* ( xu xu_1 ... x1 x0 xu &x0 u     ) */
        STOR(  REG2,   AT(DSTK, -SZ3))     /* ( xu xu_1 ... x1 x0 xu &x0 &x1 u ) */
        SUB2(IMM(SZ3), DSTK)
        ASM_CALL(      FUNC(move))         /* ( xu_1 ... x1 x0 x0 xu )           */
        ADD2(IMM(SZ),  DSTK)               /* ( xu_1 ... x1 x0 xu    )           */
FUNC_END(roll)


/* ( xu xu_1 ... x1 x0 u -- x0 xu xu_1 ... x1 ) */
FUNC_START(minus_roll)
        ADD4(  DSTK,   DTOP, PSZ, REG0)    /* @ = address of xu   */
        LOAD(  REG1,   AT(DSTK))           /* a = x0              */
        ADDI(  DSTK,   SZ,   REG2)         /* b = address of x1   */
        STOR(  REG1,   AT(DSTK, -SZ))      /* ( xu xu_1 ... x1 x0 x0 u             ) */
        STOR(  REG0,   AT(DSTK, -SZ2))     /* ( xu xu_1 ... x1 x0 x0 &xu u         ) */
        STOR(  REG2,   AT(DSTK, -SZ3))     /* ( xu xu_1 ... x1 x0 x0 &xu &x1 u     ) */
        STOR(  DSTK,   AT(DSTK, -SZ4))     /* ( xu xu_1 ... x1 x0 x0 &xu &x1 &x0 u ) */
        SUB2(IMM(SZ4), DSTK)
        ASM_CALL(      FUNC(move))         /* ( xu xu xu_1 ... x1 x0 &xu           ) */
        JUMP(  FUNC(store))                /* ( x0 xu xu_1 ... x1                  ) */
FUNC_RAWEND(minus_roll)


/* ( du du_1 ... d1 d0 u -- du_1 ... d1 d0 du ) */
FUNC_START(two_roll)
        SHL2(IMM(1),   DTOP)               /* dtop <<= 1                         */
        ADDI(  DSTK,   SZ2,  REG1)         /* a = address of d1                  */
        ADD4(  DSTK,   DTOP, PSZ, REG2)    /* b = address of du                  */
        LOAD(  REG3,   AT(REG2))           /* c = xu  \ du = ( yu xu )           */
        LOAD(  REG4,   AT(REG2, SZ))       /* d = yu  /                          */
        STOR(  REG4,   AT(DSTK, -SZ))      /* ( du ... d0 yu u                 ) */
        STOR(  REG3,   AT(DSTK, -SZ2))     /* ( du ... d0 du u                 ) */
        STOR(  DSTK,   AT(DSTK, -SZ3))     /* ( du ... d0 du &d0 u             ) */
        STOR(  REG1,   AT(DSTK, -SZ4))     /* ( du ... d0 du &d0 &d1 u         ) */
        SUB2(IMM(SZ4), DSTK)
        ASM_CALL(      FUNC(move))         /* ( du_1 ... d0 d0 du              ) */
        JUMP(          FUNC(two_nip))      /* ( du_1 ... d0 du                 ) */
FUNC_RAWEND(two_roll)


/* ( du du_1 ... d1 d0 u -- d0 du du_1 ... d1 ) */
FUNC_START(minus_two_roll)
        SHL2(IMM(1),   DTOP)               /* dtop <<= 1                         */
        ADD4(  DSTK,   DTOP, PSZ, REG0)    /* @ = address of du                  */
        LOAD(  REG1,   AT(DSTK))           /* a = x0  \ d0 = ( y0 x0 )           */
        LOAD(  REG2,   AT(DSTK, SZ))       /* b = y0  /                          */
        ADDI(  DSTK,   SZ2,   REG3)        /* c = address of x1                  */
        STOR(  REG2,   AT(DSTK, -SZ))      /* ( du ... d0 y0 u                 ) */
        STOR(  REG1,   AT(DSTK, -SZ2))     /* ( du ... d0 d0 u                 ) */
        STOR(  REG0,   AT(DSTK, -SZ3))     /* ( du ... d0 d0 &du u             ) */
        STOR(  REG3,   AT(DSTK, -SZ4))     /* ( du ... d0 d0 &du &d1 u         ) */
        STOR(  DSTK,   AT(DSTK, -SZ5))     /* ( du ... d0 d0 &du &d1 &d0 u     ) */
        SUB2(IMM(SZ5), DSTK)
        ASM_CALL(      FUNC(move))         /* ( du du ... d1 d0 &du            ) */
        JUMP(          FUNC(two_store))    /* ( d0 du ... d1                   ) */
FUNC_RAWEND(minus_two_roll)


/**
 * string-ci=  ( c-addr1 c-addr2 u -- c-addr1 c-addr2 u t|f ) m4th-user
 * compare two strings, ignoring case
 */
FUNC_START(string_ci_equal)
        LOAD(  REG2,   AT(DSTK))       /* b = addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = addr1 */
        DPUSH( DTOP)
        JEQ(   REG1,   REG2,    TO(string_ci_equal.true))   /* addr1 == addr2 */
        JZ(    DTOP,            TO(string_ci_equal.true))   /* u == 0         */
        ZERO(  REG0)
LABEL(string_ci_equal.byte)
        LD_ub( REG3,   AT(REG1, REG0, 1))
        LD_ub( REG4,   AT(REG2, REG0, 1))
        JNE(   REG3w,  REG4w,   TO(string_ci_equal.cmp))
LABEL(string_ci_equal.next)
        INC1(  REG0)
        JB(    REG0,   DTOP,    TO(string_ci_equal.byte))
LABEL(string_ci_equal.true)
        MOVE(  IMM_1,  DTOP)
        NEXT()
LABEL(string_ci_equal.cmp)
        ORR2(  IMM('a'-'A'), REG3w)
        ORR2(  IMM('a'-'A'), REG4w)
        JNE(   REG3w,  REG4w,   TO(string_ci_equal.false))
        JB(    REG3w,  IMM('a'),TO(string_ci_equal.false))
        JA(    REG3w,  IMM('z'),TO(string_ci_equal.false))
        JB(    REG4w,  IMM('a'),TO(string_ci_equal.false))
        JA(    REG4w,  IMM('z'),TO(string_ci_equal.false))
        JUMP(  TO(string_ci_equal.next))
LABEL(string_ci_equal.false)
        ZERO(  DTOP)
FUNC_END(string_ci_equal)


/**
 * string-find-blank ( c-addr u -- u' ) return index of first blank (i.e. char <= 32) in string.
 * return string length if not found.
 */
FUNC_START(string_find_blank)
        DPOP(  REG2)                                   /* b = addr */
        JZ(    DTOP,   FUNC_NEXT(string_find_blank))   /* u == 0   */
        ZERO(  REG1)
LABEL(string_find_blank.loop)
        LD_ub( REG3,   AT(REG2, REG1, 1))
        JBE(   REG3w,  IMM(32),TO(string_find_blank.found))
        INC1(  REG1)
        JB(    REG1,   DTOP,   TO(string_find_blank.loop))
LABEL(string_find_blank.found)
        MOVE(  REG1,   DTOP)
FUNC_END(string_find_blank)


/**
 * string-find-char ( c-addr u ch -- u' ) return index of first ch in string.
 * return string length if not found.
 */
FUNC_START(string_find_char)
        DPOP2( REG4,   REG2)                            /* @ = u,  b = addr */
        ZERO(  REG1)
        JZ(    REG4,   TO(string_find_char.found))      /* u == 0           */
LABEL(string_find_char.loop)
        LD_ub( REG3,   AT(REG2, REG1, 1))
        JEQ(   REG3w,  DTOPw,  TO(string_find_char.found))
        INC1(  REG1)
        JB(    REG1,   REG4,   TO(string_find_char.loop))
LABEL(string_find_char.found)
        MOVE(  REG1,   DTOP)
FUNC_END(string_find_char)

/*
 * string-find-nonblank ( c-addr u -- u' ) get index of first non-blank (i.e. char > 32) in string.
 * return string length if not found.
 */
FUNC_START(string_find_nonblank)
        DPOP(  REG2)                                   /* b = addr      */
        JZ(    DTOP,   FUNC_NEXT(string_find_nonblank))/* u == 0       */
        ZERO(  REG1)                                   /* a = index = 0 */
LABEL(string_find_nonblank.loop)
        LD_ub( REG3,   AT(REG2, REG1, 1))              /* c = addr[index] */
        JA(    REG3w,  IMM(32),TO(string_find_nonblank.found))
        INC1(  REG1)
        JB(    REG1,   DTOP,   TO(string_find_nonblank.loop))
LABEL(string_find_nonblank.found)
        MOVE(  REG1,   DTOP)
FUNC_END(string_find_nonblank)
