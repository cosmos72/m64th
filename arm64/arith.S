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
        
#define M4LITERAL
FUNC_START(m4literal)
        DPUSH(DTOP)
        ldr DTOP, [IP, IMM(SZ)]!;
FUNC_END(m4literal)

/* mod is unsigned remainder */
FUNC_START(m4mod)
#if 0 /* TODO */
        DPOP(%rax)
        ZERO(%rdx)
        div DTOP;
        MOV(%rdx, DTOP) /* remainder */
#endif /* 0 */
FUNC_END(m4mod)

FUNC_START(m4over)
        DPUSH(DTOP)
        ldr  DTOP, [DSTK, IMM(SZ)];
FUNC_END(m4over)

FUNC_START(m4rot)
        ldr  REG1, [DSTK];
        str  DTOP, [DSTK];
        ldr  DTOP, [DSTK, IMM(SZ)];
        str  REG1, [DSTK, IMM(SZ)];
FUNC_END(m4rot)

FUNC_START(m4slash) /* / */
        DPOP(REG1)
        DIV3(REG1, DTOP, DTOP)
FUNC_END(m4slash)

/* /mod is unsigned divide & remainder */
FUNC_START(m4slash_mod)
#if 0
        LOAD(DSTK, %rax)
        ZERO(%rdx)
        div DTOP;
        STORE(%rdx, DSTK) /* remainder */
        MOV(%rax, DTOP)   /* quotient */
#endif
FUNC_END(m4slash_mod)

FUNC_START(m4swap)
        ldr  REG1, [DSTK];
        str  DTOP, [DSTK];
        MOV(REG1, DTOP)
FUNC_END(m4swap)
