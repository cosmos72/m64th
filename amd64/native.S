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


ASMFUNC_START(_asm_if_)
        test   DTOP,  DTOP;
        DPOP___DTOP()                  /* preserves EFLAGS        */
        jz     FUNC(_missing_);
ASMFUNC_END(_asm_if_)


ASMFUNC_START(_asm_if0_)
        test   DTOP,  DTOP;
        DPOP___DTOP()                  /* preserves EFLAGS        */
        jnz    FUNC(_missing_);
ASMFUNC_END(_asm_if0_)


/* load literal value into DTOP. ordered from shortest to longest encoding. */

#define M6F_ASM_DROP_ZERO_
ASMFUNC_START(_asm_drop_zero_)
        ZERO(  DTOP)                   /* clobbers EFLAGS         */
ASMFUNC_END(_asm_drop_zero_)


#define M6F_ASM_DROP_MINUS_ONE_
ASMFUNC_START(_asm_drop_minus_one_)
        MOVE(  RFFF,   DTOP)
ASMFUNC_END(_asm_drop_minus_one_)


#define M6F_ASM_DROP_LIT1S_
ASMFUNC_START(_asm_drop_lit1s_)  /* actually only values in -129..126 */
        MOVI(  -2,     DTOP)
ASMFUNC_END(_asm_drop_lit1s_)


#define M6F_ASM_DROP_LIT4U_
ASMFUNC_START(_asm_drop_lit4u_)
        movl   IMM(0xffffffff), DTOPw;
ASMFUNC_END(_asm_drop_lit4u_)


#define M6F_ASM_DROP_LIT4S_
ASMFUNC_START(_asm_drop_lit4s_)
        movq   IMM(-1), DTOP;
ASMFUNC_END(_asm_drop_lit4s_)


#define M6F_ASM_DROP_LIT8S_
ASMFUNC_START(_asm_drop_lit8s_)
        movabs IMM(0xffffffffffffffff), DTOP;
ASMFUNC_END(_asm_drop_lit8s_)
