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
 * : do-i+-loop ( u -- u' )
 *    do i + loop
 * ;
 *
 * forth bytecode would be, after optimizing 'i +' => 'i+'
 *
 * WORD_CODE(do, i_plus, loop, exit)
 */
FUNC_START(do_i_plus_loop)
        /* do */
        SUB2( IMM(SZ2),RSTK)           /* update rstack pointer */
        LOAD(  REG1,   AT(DSTK))       /* REG1 = i'             */
        STOR(  RTOP,   AT(RSTK, SZ))   /* save RTOP             */
        MOVE(  DTOP,   RTOP)           /* RTOP = i              */
        STOR(  REG1,   AT(RSTK))       /* save i' to rstack     */
        LOAD(  DTOP,   AT(DSTK, SZ))   /* reload dstack top     */
        ADD2( IMM(SZ2),DSTK)           /* update dstack pointer */
ASM_ALIGN(3) /* *much* faster at least on x86-64 */
LABEL(test_sum_forth.iter)
        /* i_plus */
        ADD2(  RTOP, DTOP)
        /* loop */
        INC1(  RTOP)                               /* increment i          */
#ifdef __x86_64__
        JNE(   RTOP,   AT(RSTK), TO(test_sum_forth.iter)) /* repeat if i != i'    */
#else
        LOAD(  REG1, AT(RSTK))                     /* a = i'               */
        JNE(   REG1, RTOP, TO(test_sum_forth.iter))/* repeat if i != i'    */
#endif
        LOAD(  RTOP,   AT(RSTK, SZ))               /* load new top of rstack      */
        ADD2(  IMM(SZ2),   RSTK)                   /* drop i' i from return stack */
FUNC_END(do_i_plus_loop)

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
        DPUSH__DTOP()
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
        DPUSH__DTOP()
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
        ASM_CALL(FUNC(_exec_xt_from_native_), test_exec_xt_from_native.0)
FUNC_END(test_exec_xt_from_native)
