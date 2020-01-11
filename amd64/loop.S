/**
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

#include "asm.h"

FUNC_START(m4do)
        DPOP(REG1)
        RPUSH(REG1)
        RPUSH(DTOP)
        DPOP(DTOP)
FUNC_END(m4do)


FUNC_START(m4loop)
        LOAD(RSTK, REG1)
        cmpq SZ(RSTK), REG1;
        jge  .m4loop.break;
        /* TODO set IP to loop beginning before jump */
        jmp  *(IP);
.m4loop.break:
        ADD2(IMM(SZ2), RSTK)
FUNC_END(m4loop)        
