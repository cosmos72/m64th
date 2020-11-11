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


/**
 * ( n -- n ) examine dstack top without removing it.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (?if) itself
 */
FUNC_START(_q_if_)
        JNZ(   DTOP,   TO(_q_if_.enter))
        RELJUMP()
LABEL(_q_if_.enter)
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_q_if_)


/**
 * ( n -- n ) examine dstack top without removing it.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (?if0) itself
 */
FUNC_START(_q_if0_)
        JZ(    DTOP,   TO(_q_if0_.enter))
        RELJUMP()
LABEL(_q_if0_.enter)
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_q_if0_)


/**
 * implementation of '(jump)', used by all unconditional jumps: (again) (break) (continue) (else)
 * must be followed by IP offset to skip.
 * IP offset = 0 means first instruction after (jump) itself
 */
FUNC_START(_jump_)
        RELJUMP()
FUNC_RAWEND(_jump_)


/** implementation of 'do', enters a (do) ... (loop) */
#ifndef M4FDO
FUNC_START(do)
        DPOP(  REG1)                 /* REG1 = i'             */
        RPUSH2(RTOP,       REG1)     /* save rstack top, i'   */
        MOVE(  DTOP,       RTOP)     /* RTOP = i              */
        DPOP___DTOP()                /* reload dstack top     */
FUNC_END(do)
#endif


#ifndef M4FTWO_DUP_TWO_TO_R
FUNC_START(two_dup_two_to_r)   /* 2dup 2>r  m4th-user */
        LOAD(  REG1,       AT(DSTK))
        RPUSH2(RTOP,       REG1)
        MOVE(  DTOP,       RTOP)
FUNC_END(two_dup_two_to_r)
#endif


#ifndef M4FTWO_TO_R
FUNC_START(two_to_r)           /* 2>r      */
        DPOP(  REG1)
        RPUSH2(RTOP,       REG1)
        MOVE(  DTOP,       RTOP)
        DPOP___DTOP()
FUNC_END(two_to_r)
#endif


#ifndef M4FTWO_R_FROM
FUNC_START(two_r_from)         /* 2r>      */
        DPUSH__DTOP()
        MOVE(  RTOP,       DTOP)
        RPOP2( REG1,       RTOP)
        DPUSH( REG1)
FUNC_END(two_r_from)
#endif


FUNC_START(two_r_from_two_drop)/* 2r>2drop  m4th-user */
        LOAD(  RTOP,       AT(RSTK, SZ))
        ADD2(  IMM(SZ2),   RSTK)
FUNC_END(two_r_from_two_drop)


#ifndef M4FTWO_R_FETCH
FUNC_START(two_r_fetch)        /* 2r@      */
        STOR(  DTOP,       AT(DSTK, -SZ))
        LOAD(  REG1,       AT(RSTK))
        MOVE(  RTOP,       DTOP)
        STOR(  REG1,       AT(DSTK, -SZ2))
        SUB2(  IMM(SZ2),   DSTK)
FUNC_END(two_r_fetch)
#endif


FUNC_START(to_r)               /* >r */
        RPUSH( RTOP)
        MOVE(  DTOP, RTOP)
        DPOP___DTOP()
FUNC_END(to_r)


FUNC_START(dup_to_r)           /* dup>r    m4th-user */
        RPUSH( RTOP)
        MOVE(  DTOP, RTOP)
FUNC_END(dup_to_r)


FUNC_START(i)                  /* i and r@ */
        DPUSH__DTOP()
        MOVE(  RTOP, DTOP)
FUNC_END(i)


FUNC_START(i_times)            /* i*  m4th-user */
        MUL2(  RTOP, DTOP)
FUNC_END(i_times)


FUNC_START(i_plus)             /* i+  m4th-user */
        ADD2(  RTOP, DTOP)
FUNC_END(i_plus)


FUNC_START(i_minus)            /* i-  m4th-user */
        SUB2(  RTOP, DTOP)
FUNC_END(i_minus)


FUNC_START(i_prime)            /* i' and r2nd@ m4th-user */
        DPUSH__DTOP()
        LOAD(  DTOP, AT(RSTK))
FUNC_END(i_prime)


FUNC_START(r_store)            /* r!   ( x -- ) (R: y -- x ) m4th-user */
        MOVE(  DTOP, RTOP)
        DPOP___DTOP()
FUNC_END(r_store)


FUNC_START(r_plus)             /* r+   ( i -- ) (R: n -- n+i ) m4th-user */
        ADD2(  DTOP, RTOP)
        DPOP___DTOP()
FUNC_END(r_plus)


FUNC_START(r_from)             /* r> */
        DPUSH__DTOP()
        MOVE(  RTOP, DTOP)
        RPOP(  RTOP)
FUNC_END(r_from)


FUNC_START(r_from_drop)        /* r>drop   m4th-user */
        RPOP(  RTOP)
FUNC_END(r_from_drop)


FUNC_START(unloop)
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack */
        ADD2(  IMM(SZ2), RSTK)     /* pop return stack twice */
FUNC_END(unloop)
