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


FUNC_START(emit)
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_OUT))
        LOAD(  REG2,   AT(REG1, IOBUF_OFF_POS))
        LOAD(  REG3,   AT(REG1, IOBUF_OFF_SIZE))
        /* TODO flush output buffer */
        JAE(   REG2,   REG3,  FUNC_SYM_NEXT(emit))
        ADDI(  REG1,   IOBUF_OFF_ADDR, REG3)
        STORb( DTOPb,  AT(REG3, REG2, 1))
        INC1(  REG2)
        STOR(  REG2,   AT(REG1, IOBUF_OFF_POS))
FUNC_END(emit)


/* in>iobuf ( -- io ) get current input as iobuf */
FUNC_START(in_to_iobuf)
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_IN))
FUNC_END(in_to_iobuf)


/* iobuf>addr ( io -- c-addr ) get start of iobuf data */
FUNC_START(iobuf_addr)
        ADD2(  IMM(IOBUF_OFF_ADDR), DTOP)
FUNC_END(iobuf_addr)


/* iobuf>all-data ( io -- c-addr u ) get iobuf entire content, i.e. from 0 to iobuf>size */
FUNC_START(iobuf_all_data)
        ADDI(  DTOP,   IOBUF_OFF_ADDR, REG1)       /* a = iobuf.addr    */
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_SIZE))   /* dtop = iobuf.size */
        DPUSH( REG1)
FUNC_END(iobuf_all_data)


/* iobuf>data ( io -- c-addr u ) get iobuf current content, i.e. from iobuf>pos to iobuf>size */
FUNC_START(iobuf_data)
        ADDI(  DTOP,   IOBUF_OFF_ADDR, REG1)       /* a = iobuf.addr    */
        LOAD(  REG2,   AT(DTOP, IOBUF_OFF_POS))    /* b = iobuf.pos     */
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_SIZE))   /* dtop = iobuf.size */
        ADD2(  REG2,   REG1)     /* a = c-addr = iobuf.addr + iobuf.pos */
        SUB2(  REG2,   DTOP)     /* dtop =  u  = iobuf.size - iobuf.pos */
        DPUSH( REG1)
FUNC_END(iobuf_data)


/* iobuf>max ( io -- u ) get iobuf.max i.e. capacity */
FUNC_START(iobuf_max)
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_MAX))
FUNC_END(iobuf_max)


/* iobuf>pos ( io -- addr ) get address of iobuf.pos */
FUNC_START(iobuf_pos)
        ADD2(  IMM(IOBUF_OFF_POS), DTOP)
FUNC_END(iobuf_pos)


/* iobuf>size ( io -- addr ) get address of iobuf.size */
FUNC_START(iobuf_size)
        ADD2(  IMM(IOBUF_OFF_SIZE), DTOP)
FUNC_END(iobuf_size)


/* ( -- char ) receive one character */
FUNC_START(key)
        DPUSH( DTOP)
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_IN))
        LOAD(  REG2,   AT(REG1, IOBUF_OFF_POS))
        LOAD(  REG3,   AT(REG1, IOBUF_OFF_SIZE))
#ifdef RFFF
        MOVE(  RFFF,   DTOP)
#else
        MOVE(  IMM(-1),DTOP)
#endif
        /* TODO refill input buffer */
        JAE(   REG2,   REG3,  FUNC_SYM_NEXT(key))
        ADDI(  REG1,   IOBUF_OFF_ADDR, REG4)
        LD_ub( DTOP_ub,AT(REG4, REG2, 1))
        INC1(  REG2)
        STOR(  REG2,   AT(REG1, IOBUF_OFF_POS))
FUNC_END(key)
