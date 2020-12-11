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


#define M6FTWO_NIP
FUNC_START(two_nip)        /* 2nip     m64th-user */
        LOAD(  REG1,   AT(DSTK))
        str    REG1,   [DSTK, SZ2]!;
FUNC_END(two_nip)


/* 2pick ( du ... d1 d0 u -- du ... d1 d0 du ) m64th-user */
FUNC_START(two_pick)
        ADD4(  DSTK,   DTOP,   IMM(PSZ+1), REG1)
        ldp    DTOP,   REG2,   AT(REG1);
        DPUSH( REG2)
FUNC_END(two_pick)


/* 2rot  ( a b c d e f -- c d e f a b ) */
#define M6FTWO_ROT
FUNC_START(two_rot)
        ldp    REG2,   REG1,   AT(DSTK, SZ3);  /* b, a            */
        ldp    REG4,   REG3,   AT(DSTK, SZ);   /* d, c            */
        ldr    REG0,           AT(DSTK);       /* e               */
        stp    REG4,   REG3,   AT(DSTK, SZ3);  /* ( c d _ _ _ _ ) */
        stp    DTOP,   REG0,   AT(DSTK, SZ);   /* ( c d e f _ _ ) */
        str    REG1,           AT(DSTK);       /* ( c d e f a _ ) */
        MOVE(  REG2,   DTOP)                   /* ( c d e f a b ) */
FUNC_END(two_rot)


/* -2rot  ( a b c d e f -- e f a b c d ) m64th-user */
#define M6FMINUS_TWO_ROT
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
#define M6FTWO_SWAP
FUNC_START(two_swap)
        ldp    REG1,   REG2, AT(DSTK);
        ldr    REG3,         AT(DSTK, SZ2);
        stp    DTOP,   REG1, AT(DSTK, SZ);
        str    REG3,         AT(DSTK);
        MOVE(  REG2,   DTOP)
FUNC_END(two_swap)
