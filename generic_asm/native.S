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

/* clang-format off */

#include "../dispatch/asm.mh"


FUNC_START_ASM(_asm_q_if_)
        JZ(    DTOP,   FUNC(_missing_))
FUNC_END_ASM(_asm_q_if_)


FUNC_START_ASM(_asm_q_if0_)
        JNZ(   DTOP,   FUNC(_missing_))
FUNC_END_ASM(_asm_q_if0_)


FUNC_START_ASM(_asm_else_)
        JUMP(  FUNC(_missing_))
FUNC_END_ASM(_asm_else_)


FUNC_START_ASM(_asm_q_do_)               /* ( end beg           ) */
        MOVE(  DTOP,   REG1)         /* a = beg               */
        DPOP2( REG2,   DTOP)         /* b = end, reload dtop  */
        JEQ(   REG1,   REG2,   FUNC(_missing_))
LABEL(_asm_q_do_.jump)
        RPUSH( RTOP)                 /* save rtop             */
        MOVE(  REG1,   RTOP)         /* ( R: beg            ) */
        RPUSH( REG2)                 /* ( R: end beg        ) */
FUNC_END_ASM(_asm_q_do_)


FUNC_START_ASM(_asm_loop_)
#ifdef JUMP_ARG2_AT
        INC1(  RTOP)                 /* increment i                 */
        JNE(   RTOP,   AT(RSTK), FUNC(_missing_))/* loop if i != i' */
#else
        LOAD(  REG0,   AT(RSTK))
        INC1(  RTOP)                 /* increment i                 */
        JNE(   RTOP,   REG0,     FUNC(_missing_))/* loop if i != i' */
#endif
LABEL(_asm_loop_.jump)
        RPOP(  RTOP)                 /* drop i' from return stack   */
        RPOP(  RTOP)                 /* reload RTOP                 */
FUNC_END_ASM(_asm_loop_)


/* ( -- addr ) get ASM_HERE = current ASM address */
FUNC_START(asm_here)
        DPUSH__DTOP()
        LOAD( DTOP,    AT(M4TH, M4TH_OFF_ASM_HERE))
FUNC_END(asm_here)


/* ( -- addr ) get ASM_START = start of ASM code */
FUNC_START(asm_start)
        DPUSH__DTOP()
        LOAD( DTOP,    AT(M4TH, M4TH_OFF_ASM_BEG))
FUNC_END(asm_start)


/* ( -- u ) get ASM_HERE - ASM_START */
FUNC_START(asm_size)
        DPUSH__DTOP()
        LOAD( DTOP,    AT(M4TH, M4TH_OFF_ASM_HERE))
#ifdef ARITH_ARG1_AT
        SUB2( AT(M4TH, M4TH_OFF_ASM_BEG),  DTOP)
#else
        LOAD( REG1,    AT(M4TH, M4TH_OFF_ASM_BEG))
        SUB2( REG1,    DTOP)
#endif
FUNC_END(asm_size)
