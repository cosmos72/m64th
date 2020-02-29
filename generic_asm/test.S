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

        .text

/**
 * manually-compiled native forth code. forth source would be
 *
 * : crc+ ( crc char -- crc' )
 *    over xor 0xff and cells m4th_crctable + @ swap 8 rshift xor
 * ;
 *
 * forth bytecode would be, after optimizing '0xff and' => 'to-char'
 *
 * WORD_CODE_TOKENS(
 *    over, xor, to_char, cells, _lit_cell_, CELL(m4th_crctable),
 *    plus, fetch, swap, eight, rshift, xor, exit
 * )
 */
FUNC_START(test_crc_plus_native_forth)
        /* over */
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(DSTK, SZ))
        /* xor */
#ifdef __x86_64__
        XOR2(  AT(DSTK),   DTOP)
        ADD2(  IMM(8), DSTK)
#else
        DPOP(  REG1)
        XOR2(  REG1,   DTOP)
#endif
        /* to_char */
#ifdef __x86_64__
        movzbl DTOPb,  DTOP_ub;
#else
        ubfx   DTOPw,  DTOPw, 0, 8;
#endif
        /* cells */
        SHL2(  IMM(3), DTOP)
        /* _lit_cell_, CELL(m4th_crctable) */
        DPUSH( DTOP)
        ADDROF_4G(m4th_crctable,  DTOP)
        /* plus */
        DPOP(  REG1)
        ADD2(  REG1,   DTOP)
        /* fetch */
        LOAD(  DTOP,   AT(DTOP))
        /* swap */
        LOAD(  REG1,   AT(DSTK))
        STOR(  DTOP,   AT(DSTK))
        MOVE(  REG1,   DTOP)
        /* eight rshift */
        SHR2(  IMM(8), DTOP)
        /* xor */
#ifdef __x86_64__
        XOR2(  AT(DSTK),   DTOP)
        ADD2(  IMM(8), DSTK)
#else
	DPOP(  REG1)
        XOR2(  REG1,   DTOP)
#endif
FUNC_END(test_crc_plus_native_forth)


FUNC_START(test_exec_xt_from_native)
        ASM_CALL(      FUNC(_exec_xt_from_native_))
FUNC_END(test_exec_xt_from_native)
