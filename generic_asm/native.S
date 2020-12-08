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

FUNC_START(_asm_else_)
        JUMP(  FUNC(_missing_))
FUNC_RAWEND(_asm_else_)


FUNC_START(_asm_q_do_)               /* ( end beg           ) */
        MOVE(  DTOP,   REG1)         /* a = beg               */
        DPOP2( REG2,   DTOP)         /* b = end, reload dtop  */
        JEQ(   REG1,   REG2,   FUNC(_missing_))
LABEL(_asm_q_do_.jump)
        RPUSH( RTOP)                 /* save rtop             */
        MOVE(  REG1,   RTOP)         /* ( R: beg            ) */
        RPUSH( REG2)                 /* ( R: end beg        ) */
FUNC_RAWEND(_asm_q_do_)
