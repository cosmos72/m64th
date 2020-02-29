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

#include "asm.mh"

/* clang-format off */

#define M4FSTORE
FUNC_START(store)          /* ! */
        LOAD(  REG1,  AT(DSTK))
        STOR(  REG1,  AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(store)

#define M4FC_STORE
FUNC_START(c_store)        /* c! */
        LOAD(  REG1,  AT(DSTK))
        STORb( REG1b, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(c_store)


#define M4FSHORT_STORE
FUNC_START(short_store)    /* short! */
        LOAD(  REG1,  AT(DSTK))
        STORh( REG1h, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(short_store)


#define M4FINT_STORE
FUNC_START(int_store)      /* int! */
        LOAD(  REG1,  AT(DSTK))
        STORw( REG1w, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(int_store)


#define M4FDIV_STRING
/* /string ( c-addr u n -- c-addr' u' )  'string' word set */
FUNC_START(div_string)
        MOVE(  DTOP,   REG1)           /* a = n       */
        DPOP(  DTOP)                   /* dtop = u    */
        SUB2(  REG1,   DTOP)           /* dtop -= n   */
        ADD2(  REG1,   AT(DSTK))       /* c-addr += n */
FUNC_END(div_string)


/* cmove ( addr-src addr-dst u -- ) 'string' word set */
FUNC_START(cmove)
        MOVE(  %rdi,  %rax)            /* save DSTK == %rdi */
        MOVE(  %rsi,  %rdx)            /* save RSTK == %rsi */
        LOAD(  %rdi,  AT(%rax))        /* src               */
        LOAD(  %rsi,  AT(%rax, SZ))    /* dst               */
        MOVE(  DTOP,  %rcx)            /* n                 */

        cld;                           /* forward direction */
        rep    movsb (%rsi), (%rdi);   /* copy string       */

        lea    AT(%rax,SZ3), DSTK;     /* load DSTK         */
        MOVE(  AT(%rax,SZ2), DTOP)     /* load dstack top   */
        MOVE(  %rdx,   %rsi)           /* load RSTK         */
FUNC_END(cmove)


FUNC_START(string_equal)   /* string=  ( addr1 addr2 u -- addr1 addr2 u t|f ) m4th-user */
        LOAD(  REG2,   AT(DSTK))       /* b = addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = addr1 */
        DPUSH( DTOP)
        JEQ(   REG1,   REG2,    TO(string_equal.true))   /* addr1 == addr2 */
        JZ(    DTOP,            TO(string_equal.true))   /* u == 0         */
        ZERO(  REG4w)
        JB(    DTOP,   IMM(8),  TO(string_equal.byte))   /* < 8 bytes */
        SUB2(  IMM(8), DTOP)
LABEL(string_equal.cell)
        LOAD(  REG3,   AT(REG1, REG4, 1))
        JNE(   REG3,   AT(REG2, REG4, 1),  TO(string_equal.false)) /* x86 specific */
        ADD2(  IMM(8), REG4)
        JB(    REG4,   DTOP,    TO(string_equal.cell))   /* > 8 bytes left ? */
        LOAD(  REG3,   AT(REG1, DTOP, 1))                   /* compare last 8 bytes */
        LOAD(  REG4,   AT(REG2, DTOP, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        JUMP(                   TO(string_equal.true))
LABEL(string_equal.byte)
        LD_ub( REG3_ub,AT(REG1, REG4, 1))
        JNE(   REG3b,  AT(REG2, REG4, 1),  TO(string_equal.false)) /* x86 specific */
        INC1(  REG4)
        JB(    REG4,   DTOP,    TO(string_equal.byte))
LABEL(string_equal.true)
        MOVE(  RFFF,   DTOP)
        NEXT()
LABEL(string_equal.false)
        ZERO(  DTOPw)
FUNC_END(string_equal)

