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

ASMFUNC_START(_asm_drop_zero_)
        ZERO(  DTOP)                   /* clobbers EFLAGS         */
ASMFUNC_END(_asm_drop_zero_)


ASMFUNC_START(_asm_drop_minus_one_)
        MOVE(  RFFF,   DTOP)
ASMFUNC_END(_asm_drop_minus_one_)


ASMFUNC_START(_asm_drop_lit1s_)  /* actually only values in -129..126 */
        MOVI(  -2,     DTOP)
ASMFUNC_END(_asm_drop_lit1s_)


ASMFUNC_START(_asm_drop_lit4u_)
        movl   IMM(0xffffffff), DTOPw;
ASMFUNC_END(_asm_drop_lit4u_)


ASMFUNC_START(_asm_drop_lit4s_)
        movq   IMM(-1), DTOP;
ASMFUNC_END(_asm_drop_lit4s_)


ASMFUNC_START(_asm_lit8s_)
ASMFUNC_START_NESTED(_asm_lit_nt_body_)
        DPUSH__DTOP()
ASMFUNC_START_NESTED(_asm_drop_lit8s_)
        movabs IMM(0xffffffffffffffff), DTOP;
ASMFUNC_END(_asm_lit8s_)
ASMFUNC_END_NESTED(_asm_lit_nt_body_)
ASMFUNC_END_NESTED(_asm_drop_lit8s_)


ASMFUNC_START(_noop1_) /* 1-byte noop */
        nop;
ASMFUNC_END(_noop1_)
ASMFUNC_START(_noop2_) /* 2-byte noop */
        .byte 0x66, 0x90;
ASMFUNC_END(_noop2_)
ASMFUNC_START(_noop3_) /* 3-byte noop */
        .byte 0x0f, 0x1f, 0x00;
ASMFUNC_END(_noop3_)
ASMFUNC_START(_noop4_) /* 4-byte noop */
        .byte 0x0f, 0x1f, 0x40, 0x00;
ASMFUNC_END(_noop4_)
ASMFUNC_START(_noop5_) /* 5-byte noop */
        .byte 0x0f, 0x1f, 0x44, 0x00, 0x00;
ASMFUNC_END(_noop5_)
ASMFUNC_START(_noop6_) /* 6-byte noop */
        .byte 0x66, 0x0f, 0x1f, 0x44, 0x00, 0x00;
ASMFUNC_END(_noop6_)
ASMFUNC_START(_noop7_) /* 7-byte noop */
        .byte 0x0f, 0x1f, 0x80, 0x00, 0x00, 0x00, 0x00;
ASMFUNC_END(_noop7_)
