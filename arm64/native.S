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
        cmp    DTOP,   IMM(0);
        DPOP___DTOP()
        b.eq   FUNC(_missing_);
ASMFUNC_END(_asm_if_)


ASMFUNC_START(_asm_if0_)
        cmp    DTOP,   IMM(0);
        DPOP___DTOP()
        b.ne   FUNC(_missing_);
ASMFUNC_END(_asm_if0_)


ASMFUNC_START(_asm_if_less_)
        MOVE(  DTOP,   REG2)
        DPOP2( REG1,   DTOP)
        cmp    REG1,   REG2;
        b.ge   FUNC(_missing_);
ASMFUNC_END(_asm_if_less_)


ASMFUNC_START(_asm_if_less_equal_)
        MOVE(  DTOP,   REG2)
        DPOP2( REG1,   DTOP)
        cmp    REG1,   REG2;
        b.gt   FUNC(_missing_);
ASMFUNC_END(_asm_if_less_equal_)


ASMFUNC_START(_asm_if_ne_)
        MOVE(  DTOP,   REG2)
        DPOP2( REG1,   DTOP)
        cmp    REG1,   REG2;
        b.eq   FUNC(_missing_);
ASMFUNC_END(_asm_if_ne_)


ASMFUNC_START(_asm_if_equal_)
        MOVE(  DTOP,   REG2)
        DPOP2( REG1,   DTOP)
        cmp    REG1,   REG2;
        b.ne   FUNC(_missing_);
ASMFUNC_END(_asm_if_equal_)


ASMFUNC_START(_asm_if_more_)
        MOVE(  DTOP,   REG2)
        DPOP2( REG1,   DTOP)
        cmp    REG1,   REG2;
        b.le   FUNC(_missing_);
ASMFUNC_END(_asm_if_more_)


ASMFUNC_START(_asm_if_more_equal_)
        MOVE(  DTOP,   REG2)
        DPOP2( REG1,   DTOP)
        cmp    REG1,   REG2;
        b.lt   FUNC(_missing_);
ASMFUNC_END(_asm_if_more_equal_)


/* load literal value into DTOP */

ASMFUNC_START(_asm_drop_zero_)
        ZERO(  DTOP)
ASMFUNC_END(_asm_drop_zero_)


ASMFUNC_START(_asm_drop_lit2n_) /* only negative values in -(2^16)..-1 */
        movn   DTOP,   IMM(0);
ASMFUNC_END(_asm_drop_lit2n_)


ASMFUNC_START(_asm_lit8s_)
ASMFUNC_START_NESTED(_asm_lit_nt_body_)
        DPUSH__DTOP()
ASMFUNC_START_NESTED(_asm_drop_lit2u_)
        mov    DTOP,   IMM(0);
ASMFUNC_END_NESTED(_asm_drop_lit2u_)
ASMFUNC_START_NESTED(_asm_arm64_movk16_)
        movk   DTOP,   IMM(0), lsl IMM(16);
ASMFUNC_END_NESTED(_asm_arm64_movk16_)
ASMFUNC_START_NESTED(_asm_arm64_movk32_)
        movk   DTOP,   IMM(0), lsl IMM(32);
ASMFUNC_END_NESTED(_asm_arm64_movk32_)
ASMFUNC_START_NESTED(_asm_arm64_movk48_)
        movk   DTOP,   IMM(0), lsl IMM(48);
ASMFUNC_END_NESTED(_asm_arm64_movk48_)
ASMFUNC_END_NESTED(_asm_lit_nt_body_)
ASMFUNC_END(_asm_lit8s_)


ASMFUNC_START(_noop4_) /* 4-byte noop */
        nop;
ASMFUNC_END(_noop4_)
