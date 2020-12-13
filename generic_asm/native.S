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

/* clang-format off */

#include "../dispatch/asm.mh"


FUNCASM_START(_asm_q_if_)
        JZ(    DTOP,   FUNC(_missing_))
FUNCASM_END(_asm_q_if_)


FUNCASM_START(_asm_q_if0_)
        JNZ(   DTOP,   FUNC(_missing_))
FUNCASM_END(_asm_q_if0_)


/* ASM code for all unconditional jumps */
FUNCASM_START(_asm_else_)
        JUMP(  FUNC(_missing_))
FUNCASM_END(_asm_else_)


FUNCASM_START(_asm_q_do_)               /* ( end beg           ) */
        MOVE(  DTOP,   REG1)         /* a = beg               */
        DPOP2( REG2,   DTOP)         /* b = end, reload dtop  */
        JEQ(   REG1,   REG2,   FUNC(_missing_))
LABEL(_asm_q_do_.jump)
        RPUSH( RTOP)                 /* save rtop             */
        MOVE(  REG1,   RTOP)         /* ( R: beg            ) */
        RPUSH( REG2)                 /* ( R: end beg        ) */
FUNCASM_END(_asm_q_do_)


FUNCASM_START(_asm_loop_)
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
FUNCASM_END(_asm_loop_)


/* [asm-lit,] followed by CELL(addr) T(u) just calls asm_comma */
FUNC_START(_asm_lit_comma_)
        DPUSH__DTOP()
        LOAD(  REG1,   AT(IP))
        LD_ut( DTOP,   AT(IP, SZ))
        ADD2(IMM(SZ+SZt),  IP)
        DPUSH( REG1)
        /* fallthrough */

/* asm, ( addr u -- ) m64th-asm */
FUNC_DEF(asm_comma)
        LOAD(  REG1,   AT(M64TH, M64TH_OFF_ASM_HERE))  /* a = asm-here         */
        LOAD(  REG2,   AT(M64TH, M64TH_OFF_ASM_END))   /* b = asm-end          */
        SUB2(  REG1,   REG2)                           /* b = free_bytes       */
        MOVI(  M6ERR_ASM_OVERFLOW, REG0)
        JA(    DTOP,   REG2,    FUNC(_throw_reg0_))

        DPUSH( REG1)                                   /* ( addr asm-here u )  */
        ADD2(  DTOP,   REG1)
        STOR(  REG1,   AT(M64TH, M64TH_OFF_ASM_HERE))  /* asm-here += u        */
        JUMP(  FUNC(cmove))
/* FUNC_RAWEND(_asm_lit_comma_) */
FUNC_RAWEND(asm_comma)


/* asm-clear ( -- ) m64th-asm forget all code in ASM buffer */
FUNC_START(asm_clear)
        LOAD(  REG1,   AT(M64TH, M64TH_OFF_ASM_FUNC))  /* a = asm-func         */
        STOR(  REG1,   AT(M64TH, M64TH_OFF_ASM_HERE))
FUNC_END(asm_clear)


/* ( -- addr ) get ASM_HERE = current ASM address */
FUNC_START(asm_here)
        DPUSH__DTOP()
        LOAD( DTOP,    AT(M64TH, M64TH_OFF_ASM_HERE))
FUNC_END(asm_here)


/* ( -- addr ) get ASM_FUNC = start of ASM code */
FUNC_START(asm_func)
        DPUSH__DTOP()
        LOAD( DTOP,    AT(M64TH, M64TH_OFF_ASM_FUNC))
FUNC_END(asm_func)


/* ( -- u ) get ASM_HERE - ASM_FUNC */
FUNC_START(asm_size)
        DPUSH__DTOP()
        LOAD( DTOP,    AT(M64TH, M64TH_OFF_ASM_HERE))
#ifdef ARITH_ARG1_AT
        SUB2( AT(M64TH, M64TH_OFF_ASM_BEG),  DTOP)
#else
        LOAD( REG1,    AT(M64TH, M64TH_OFF_ASM_FUNC))
        SUB2( REG1,    DTOP)
#endif
FUNC_END(asm_size)
