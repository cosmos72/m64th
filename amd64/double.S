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

/* 2pick ( du du-1 ... d1 d0 u -- du-1 ... d1 d0 du ) m64th-user */
FUNC_START(two_pick)
        shl    DTOP;
        mov    SZ(DSTK, DTOP, SZ), REG1;
        mov      (DSTK, DTOP, SZ), DTOP;
        DPUSH( REG1)
FUNC_END(two_pick)


#define M4FTWO_TO_R
FUNC_START(two_to_r)       /* 2>r      */
        LOAD(  REG1,   AT(DSTK))
        RPUSH2(RTOP,   REG1)
        MOVE(  DTOP,   RTOP)
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(two_to_r)


#define M4FTWO_DUP_TWO_TO_R
FUNC_START(two_dup_two_to_r)   /* 2dup 2>r  m64th-user */
        STOR(  RTOP,       AT(RSTK, -SZ))
        LOAD(  REG1,       AT(DSTK))
        MOVE(  DTOP,       RTOP)
        STOR(  REG1,       AT(RSTK, -SZ2))
        SUB2(  IMM(SZ2),   RSTK)
FUNC_END(two_dup_two_to_r)


#define M4FTWO_R_FROM
FUNC_START(two_r_from)     /* 2r>      */
        RPOP(  REG1)
        DPUSH2(DTOP,   REG1)
        MOVE(  RTOP,   DTOP)
        RPOP(  RTOP)
FUNC_END(two_r_from)
