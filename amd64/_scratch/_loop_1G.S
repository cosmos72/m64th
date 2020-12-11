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

#include "asm.mh"

#define m6main main

/* clang-format off */

FUNC_START(main)
        ZERO(  REG1)
        MOVE(  IMM(1000000000), REG2)
.Lmain.again:
        inc    REG1;
        cmpq   REG2, REG1;
        jne    .Lmain.again;
        ZERO(  REG1)
        ret;
FUNC_RAWEND(main)
