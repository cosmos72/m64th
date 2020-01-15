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

FUNC_START(m4_do_)
        DPOP(  REG1)                 /* REG1 = i'             */
        STOR(  RTOP, AT(RSTK, -SZ))  /* save RTOP             */
        MOVE(  DTOP, RTOP)           /* RTOP = i              */
        DPOP(  DTOP)                 /* reload dstack top     */
        STOR(  REG1, AT(RSTK, -SZ2)) /* save   i' to rstack   */
        SUB2(  IMM(SZ2),  RSTK)      /* update rstack pointer */
FUNC_END(m4_do_)



/*
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means (loop) itself
 */
FUNC_START(m4_loop_)
        inc    RTOP;               /* increment i                 */
        cmpq   (RSTK), RTOP;
        je     .Lm4_loop_.leave;   /* leave if i == i'            */
        LOAD(  REG2, AT(IP, SZ))
        lea    (IP, REG2, SZ), IP; /* IP = TARGET_IP              */
        jmp    *(IP);              /* jump to instruction after (do) */
.Lm4_loop_.leave:
        ADD2(  IMM(SZ2), IP)       /* skip jump offset            */
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from return stack */
        jmp    *(IP);              /* execute next instruction    */
FUNC_RAWEND(m4_loop_)