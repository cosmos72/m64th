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

FUNC_START(_asm_if_)
        cmp    DTOP,   IMM(0);
        DPOP___DTOP()
        b.eq   FUNC(_missing_);
FUNC_RAWEND(_asm_if_)


FUNC_START(_asm_if0_)
        cmp    DTOP,   IMM(0);
        DPOP___DTOP()
        b.ne   FUNC(_missing_);
FUNC_RAWEND(_asm_if0_)


FUNC_START(_asm_loop_)
        LOAD(  REG0,   AT(RSTK))
        INC1(  RTOP)                 /* increment i                 */
        JNE(   RTOP,   REG0,   FUNC(_missing_)) /* loop if i != i'  */
LABEL(_asm_loop_.jump)
        RPOP(  RTOP)                 /* drop i' from return stack   */
        RPOP(  RTOP)                 /* reload RTOP                 */
FUNC_RAWEND(_asm_loop_)
