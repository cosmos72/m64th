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
        STORb( REG1b, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(c_store)
#endif


FUNC_START(count)          /* count */
        LD_ub( REG1_ub,AT(DTOP))
        INC1(  DTOP)
        DPUSH( DTOP)
        MOVE(  REG1,   DTOP)
FUNC_END(count)

#ifndef M4FSHORT_STORE
FUNC_START(short_store)    /* short! */
        DPOP(  REG1)
        STORh( REG1h, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(short_store)
#endif

#ifndef M4FINT_STORE
FUNC_START(int_store)      /* int! */
        DPOP(  REG1)
        STORw( REG1w, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(int_store)
#endif

#ifndef M4FSTORE
FUNC_START(store)          /* ! */
        DPOP(  REG1)
        STOR(  REG1, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(store)
#endif


FUNC_START(byte_fetch)     /* byte@ */
        LD_sb(DTOP_sb, AT(DTOP))
FUNC_END(byte_fetch)


FUNC_START(c_fetch)        /* c@ */
        LD_ub(DTOP_ub, AT(DTOP))
FUNC_END(c_fetch)


FUNC_START(short_fetch)    /* short@ */
        LD_sh(DTOP_sh, AT(DTOP))
FUNC_END(short_fetch)


FUNC_START(ushort_fetch)   /* ushort@ */
        LD_uh(DTOP_uh, AT(DTOP))
FUNC_END(ushort_fetch)


FUNC_START(int_fetch)      /* int@ */
        LD_sw(DTOP_sw, AT(DTOP))
FUNC_END(int_fetch)


FUNC_START(uint_fetch)     /* uint@ */
        LD_uw(DTOP_uw, AT(DTOP))
FUNC_END(uint_fetch)


FUNC_START(fetch)          /* @ */
        LOAD(  DTOP, AT(DTOP))
FUNC_END(fetch)


/**
 * string-ci=  ( c-addr1 c-addr2 u -- c-addr1 c-addr2 u t|f ) m4th-user
 * compare two strings, ignoring case
 */
FUNC_START(string_ci_equal)   
        LOAD(  REG2,   AT(DSTK))       /* b = addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = addr1 */
        DPUSH( DTOP)
        JEQ(   REG1,   REG2,    LABEL_SYM(string_ci_equal.true))   /* addr1 == addr2 */
        JZ(    DTOP,            LABEL_SYM(string_ci_equal.true))   /* u == 0         */
        ZERO(  REG0w)
LABEL(string_ci_equal.byte)
        LD_ub( REG3_ub,AT(REG1, REG0, 1))
        LD_ub( REG4_ub,AT(REG2, REG0, 1))
        JNE(   REG3w,  REG4w,   LABEL_SYM(string_ci_equal.cmp))
LABEL(string_ci_equal.next)
        INC1(  REG0)
        JB(    REG0,   DTOP,    LABEL_SYM(string_ci_equal.byte))
LABEL(string_ci_equal.true)
#ifdef RFFF
        MOVE(  RFFF,   DTOP)
#else
        MOVE(  IMM(-1),DTOP)
#endif
        NEXT()
LABEL(string_ci_equal.cmp)
        ORR2(  IMM('a'-'A'), REG3w)
        ORR2(  IMM('a'-'A'), REG4w)
        JNE(   REG3w,  REG4w,   LABEL_SYM(string_ci_equal.false))
        JB(    REG3w,  IMM('a'),LABEL_SYM(string_ci_equal.false))
        JA(    REG3w,  IMM('z'),LABEL_SYM(string_ci_equal.false))
        JB(    REG4w,  IMM('a'),LABEL_SYM(string_ci_equal.false))
        JA(    REG4w,  IMM('z'),LABEL_SYM(string_ci_equal.false))
        JUMP(  LABEL_SYM(string_ci_equal.next))
LABEL(string_ci_equal.false)
        ZERO(  DTOPw)
FUNC_END(string_ci_equal)


/**
 * string-first-blank ( c-addr u -- u' ) return index of first blank (i.e. char <= 32) in string,
 * return string length if not found.
 */
FUNC_START(string_first_blank)
        DPOP(  REG2)                                               /* b = addr */
        JZ(    DTOP,            LABEL_SYM(string_first_blank.ret)) /* u == 0   */
        ZERO(  REG1w)
LABEL(string_first_blank.byte)
        LD_ub( REG3_ub,AT(REG2, REG1, 1))
        JBE(   REG3w,  IMM(32), LABEL_SYM(string_first_blank.found))
        INC1(  REG1)
        JB(    REG1,   DTOP,    LABEL_SYM(string_first_blank.byte))
LABEL(string_first_blank.found)
        MOVE(  REG1,   DTOP)
LABEL(string_first_blank.ret)
FUNC_END(string_first_blank)
