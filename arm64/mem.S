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

/* cmove ( addr-src addr-dst u -- ) 'string' word set */
FUNC_START(cmove)    
        DPOP(  REG2)                       /* b = dst        */
        DPOP(  REG1)                       /* a = src        */
        ZERO(  REG0)                       /* @ = index      */
        JB(    DTOP,   IMM(SZ),TO(cmove_1.test))  /* copying < SZ bytes => slow       */
        JAE(   REG1,   REG2,   TO(cmove_SZ.init)) /* copying to lower address => fast */
        SUB3(  REG2,   REG1,   REG3)              /* c = dst - src                    */
        JB(    REG3,   IMM(SZ),TO(cmove_1))       /* copying to too near address => slow */ 
LABEL(cmove_SZ.init)
        SUB2(  IMM(SZ),DTOP)               /* u -= SZ        */
        /* copy SZ bytes per iteration */
LABEL(cmove_SZ)
        LOAD(  REG3,   AT(REG1, REG0))     /* c = src[index] */
        STOR(  REG3,   AT(REG2, REG0))     /* dst[index] = c */
        ADD2(  IMM(SZ),REG0)               /* index += SZ    */
        JB(    REG0,   DTOP,   TO(cmove_SZ))/* loop if index < u i.e. still > SZ bytes to copy */
        /* copy last SZ bytes */
        LOAD(  REG3,   AT(REG1, DTOP))     /* c = src[u-SZ] */
        STOR(  REG3,   AT(REG2, DTOP))     /* dst[u-SZ] = c */
        JUMP(  TO(cmove.done))
        /* copy 1 byte per iteration */
LABEL(cmove_1)
        LD_ub( REG3_ub,AT(REG1, REG0))     /* c = src[index] */
        STORb( REG3b,  AT(REG2, REG0))     /* dst[index] = c */
        ADD2(  IMM(1), REG0)               /* index++        */
LABEL(cmove_1.test)
        JB(    REG0,   DTOP,   TO(cmove_1))/* loop if index < u */
LABEL(cmove.done)
        DPOP(  DTOP)
FUNC_END(cmove)


FUNC_START(string_equal)   /* string=  ( addr1 addr2 u -- addr1 addr2 u t|f ) m4th-user */
        LOAD(  REG2,   AT(DSTK))       /* b = addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = addr1 */
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
        LD_ub( REG3_ub,AT(REG1, REG0, 1))
        LD_ub( REG4_ub,AT(REG2, REG0, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        INC1(  REG0)
        JB(    REG0,   DTOP,    TO(string_equal.byte))
LABEL(string_equal.true)
        MOVE(  IMM(-1),DTOP)
        NEXT()
LABEL(string_equal.false)
        ZERO(  DTOP)
FUNC_END(string_equal)

