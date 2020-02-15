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
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_OUT_CURR))
        LOAD(  REG2,   AT(M4TH, M4TH_OFF_OUT_SIZE))
        /* TODO flush output buffer */
        JAE(   REG1,   REG2,  FUNC_SYM_NEXT(emit))
        LOAD(  REG2,   AT(M4TH, M4TH_OFF_OUT_ADDR))
        STORb( DTOPb,  AT(REG1, REG2, 1))
        INC1(  REG1)
        STOR(  REG1,   AT(M4TH, M4TH_OFF_OUT_CURR))
FUNC_END(emit)


/* in>addr ( -- addr ) get start of input buffer */
FUNC_START(in_to_addr)
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_OUT_ADDR))
FUNC_END(in_to_addr)


/* in>curr ( -- addr ) alias of >in */
FUNC_START(in_to_curr)
        DPUSH( DTOP)
        ADDI(  M4TH,   M4TH_OFF_OUT_ADDR, DTOP)
FUNC_END(in_to_curr)


/* in>size ( -- u ) get size of input buffer */
FUNC_START(in_to_size)
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_OUT_SIZE))
FUNC_END(in_to_size)


/* ( -- char ) receive one character */ 
FUNC_START(key)
        DPUSH( DTOP)
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_IN_CURR))
        LOAD(  REG2,   AT(M4TH, M4TH_OFF_IN_SIZE))
#ifdef RFFF
        MOVE(  RFFF,   DTOP)
#else
        MOVE(  IMM(-1),DTOP)
#endif
        /* TODO refill input buffer */
	JAE(   REG1,   REG2,  FUNC_SYM_NEXT(key))
        LOAD(  REG2,   AT(M4TH, M4TH_OFF_IN_ADDR))
        LD_ub( DTOP_ub,AT(REG1, REG2, 1))
        INC1(  REG1)
        STOR(  REG1,   AT(M4TH, M4TH_OFF_IN_CURR))
FUNC_END(key)
