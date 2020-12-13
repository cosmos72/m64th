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


/* load literal value into DTOP. ordered from shortest to longest encoding. */

ASMFUNC_START(_asm_drop_zero_)
        ZERO(  DTOP)
ASMFUNC_END(_asm_drop_zero_)


ASMFUNC_START(_asm_drop_lit2u_)
        mov    DTOP,   IMM(0);
ASMFUNC_END(_asm_drop_lit2u_)


ASMFUNC_START(_asm_drop_lit2s_) /* actually only negative values in -(2^16)..-1 */
        movn   DTOP,   IMM(0);
ASMFUNC_END(_asm_drop_lit2s_)


ASMFUNC_START(_asm_drop_lit4u_)
        mov    DTOP,   IMM(0);
        movk   DTOP,   IMM(0), lsl IMM(16);
ASMFUNC_END(_asm_drop_lit4u_)


ASMFUNC_START(_asm_drop_lit4s_) /* actually only negative values in -(2^32)..-1 */
        movn   DTOP,   IMM(0);
        movk   DTOP,   IMM(0), lsl IMM(16);
ASMFUNC_END(_asm_drop_lit4s_)


ASMFUNC_START(_asm_drop_lit6u_)
        mov    DTOP,   IMM(0);
        movk   DTOP,   IMM(0), lsl IMM(16);
        movk   DTOP,   IMM(0), lsl IMM(32);
ASMFUNC_END(_asm_drop_lit6u_)


ASMFUNC_START(_asm_drop_lit6s_) /* actually only negative values in -(2^48)..-1 */
        movn   DTOP,   IMM(0);
        movk   DTOP,   IMM(0), lsl IMM(16);
        movk   DTOP,   IMM(0), lsl IMM(32);
ASMFUNC_END(_asm_drop_lit6s_)


ASMFUNC_START(_asm_drop_lit8s_)
        mov    DTOP,   IMM(0);
        movk   DTOP,   IMM(0), lsl IMM(16);
        movk   DTOP,   IMM(0), lsl IMM(32);
        movk   DTOP,   IMM(0), lsl IMM(48);
ASMFUNC_END(_asm_drop_lit8s_)
