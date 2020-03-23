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
        DPOP(  DTOP)
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
        DPOP(  DTOP)
FUNC_END(short_store)
#endif

#ifndef M4FINT_STORE
FUNC_START(int_store)      /* int!     m4th-user */
        DPOP(  REG1)
        STORw( REG1,   AT(DTOP))
        DPOP(  DTOP)
FUNC_END(int_store)
#endif

#ifndef M4FSTORE
FUNC_START(store)          /* ! */
        DPOP(  REG1)
        STOR(  REG1,   AT(DTOP))
        DPOP(  DTOP)
FUNC_END(store)
#endif


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


#ifndef M4FDIV_STRING
/* /string ( c-addr u n -- c-addr' u' )  'string' word set */
FUNC_START(div_string)
        MOVE(  DTOP,   REG1)           /* a = n       */
        DPOP(  DTOP)                   /* dtop = u    */
        LOAD(  REG2,   AT(DSTK))       /* b = c-addr  */
        SUB2(  REG1,   DTOP)           /* dtop -= n   */
        ADD2(  REG1,   REG2)           /* c-addr += n */
        STOR(  REG2,   AT(DSTK))
FUNC_END(div_string)
#endif /* M4FDIV_STRING */


/* ( yu xu yu_1 xu_1 ... y1 x1 y0 x0 u -- yu_1 xu_1 ... y1 x1 y0 x0 yu xu ) */
FUNC_START(two_roll)
        SHL2(IMM(1),   DTOP)               /* dtop <<= 1                          */
        ADDI(  DSTK,   SZ2,  REG1)         /* a = address of x1                   */
        ADD4(  DSTK,   DTOP, PSZ, REG2)    /* b = address of xu                   */
        LOAD(  REG4,   AT(REG2, SZ))       /* d = yu                              */
        LOAD(  REG3,   AT(REG2))           /* c = xu                              */
        STOR(  REG4,   AT(DSTK, -SZ))      /* ( yu xu ... y0 x0 yu u            ) */
        STOR(  REG3,   AT(DSTK, -SZ2))     /* ( yu xu ... y0 x0 yu xu u         ) */
        STOR(  DSTK,   AT(DSTK, -SZ3))     /* ( yu xu ... y0 x0 yu xu &x0 u     ) */
        STOR(  REG1,   AT(DSTK, -SZ4))     /* ( yu xu ... y0 x0 yu xu &x0 &x1 u ) */
        SUB2(IMM(SZ4), DSTK)
        ASM_CALL(      FUNC(move))         /* ( yu_1 xu_1 ... y0 x0 y0 x0 yu xu ) */
        JUMP(          FUNC(two_nip))      /* ( yu_1 xu_1 ... y0 x0 yu xu       ) */
FUNC_RAWEND(two_roll)


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
        ZERO(  REG0w)
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
        ZERO(  DTOPw)
FUNC_END(string_ci_equal)


/**
 * string-first-blank ( c-addr u -- u' ) return index of first blank (i.e. char <= 32) in string,
 * return string length if not found.
 */
FUNC_START(string_first_blank)
        DPOP(  REG2)                                               /* b = addr */
        JZ(    DTOP,            TO(string_first_blank.ret)) /* u == 0   */
        ZERO(  REG1w)
LABEL(string_first_blank.byte)
        LD_ub( REG3,   AT(REG2, REG1, 1))
        JBE(   REG3w,  IMM(32), TO(string_first_blank.found))
        INC1(  REG1)
        JB(    REG1,   DTOP,    TO(string_first_blank.byte))
LABEL(string_first_blank.found)
        MOVE(  REG1,   DTOP)
LABEL(string_first_blank.ret)
FUNC_END(string_first_blank)
