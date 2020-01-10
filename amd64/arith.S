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
        

/* mod is unsigned remainder */
FUNC_START(m4th_mod)
        DPOP(%rax)
        ZERO(%rdx)
        div DTOP;
        MOV(%rdx, DTOP) /* remainder */
FUNC_END(m4th_mod)

FUNC_START(m4th_over)
        DPUSH(DTOP)
        movq SZ(DSTK), DTOP;
FUNC_END(m4th_over)

FUNC_START(m4th_rot)
        movq (DSTK),   REG1;
        movq DTOP,     (DSTK);
        movq SZ(DSTK), DTOP;
        movq REG1,     SZ(DSTK);
FUNC_END(m4th_rot)

FUNC_START(m4th_slash) /* / */
        DPOP(%rax)
        cqto; /* sign-extend %rax into %rdx */
        idiv DTOP;
        MOV(%rax, DTOP)
FUNC_END(m4th_slash)

/* /mod is unsigned divide & remainder */
FUNC_START(m4th_slash_mod)
        LOAD(DSTK, %rax)
        ZERO(%rdx)
        div DTOP;
        STORE(%rdx, DSTK) /* remainder */
        MOV(%rax, DTOP)   /* quotient */
FUNC_END(m4th_slash_mod)

FUNC_START(m4th_swap)
        xchg (DSTK), DTOP;
FUNC_END(m4th_swap)

