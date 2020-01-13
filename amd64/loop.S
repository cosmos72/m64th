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

FUNC_START(m4do_)
        DPOP(REG1)             /* REG1 = i'      */
        ISET(RTOP, RSTK, -SZ ) /* save RTOP      */
        IGET(IP,    SZ,  REG2) /* REG2 = DELTAIP */
        MOVE(DTOP, RTOP)       /* RTOP = i       */
        ISET(REG2, RSTK, -SZ2) /* save   DELTAIP */
        ISET(REG1, RSTK, -SZ3) /* save   i'      */
        DPOP(DTOP)             /* reload dstack top */
        SUB2(SZ3,  RSTK)       /* update rstack pointer */
FUNC_END(m4do_)



/* loop compiles to this */
FUNC_START(m4loop_)
        cmpq (RSTK), RTOP;
        jge  .Lm4loop_.break;
        IGET(IP, SZ, REG2)
        leaq (IP, REG2, SZ), IP; /* add jump offset to IP */
        jmp  *(IP);
.Lm4loop_.break:
        ADD2(IMM(SZ2), IP)       /* also skip jump offset */
        IGET(RSTK, SZ, RTOP)     /* load new top of rstack */
        ADD2(IMM(SZ2), RSTK)     /* pop return stack twice */
        jmp  *(IP);
FUNC_RAWEND(m4loop_)
