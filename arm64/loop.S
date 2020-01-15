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
        RPUSH( RTOP)                 /* save rstack top       */
        DPOP(  REG1)                 /* REG1 = i'             */
        MOVE(  DTOP, RTOP)           /* RTOP = i              */
        RPUSH( REG1)                 /* push i' on rstack     */
        DPOP(  DTOP)                 /* reload dstack top     */
FUNC_END(m4_do_)


/*
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means (leave) itself
 */
FUNC_START(m4_leave_)
        LOAD(  REG2, AT(IP, SZ))
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        add    IP, IP, REG2, lsl 3;/* IP = TARGET_IP              */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from return stack */
        LOAD(  REG3, AT(IP))
        br     REG3;               /* jump to instruction after (loop) */
FUNC_RAWEND(m4_leave_)

/*
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means (loop) itself
 */
FUNC_START(m4_loop_)
        ADD2(  IMM(1), RTOP)        /* increment i                 */
        LOAD(  REG1, AT(RSTK))      /* REG1 = i'                   */
        cmp    REG1, RTOP;
        b.eq   .Lm4_loop_.break;    /* break if i == i'            */
        LOAD(  REG2, AT(IP, SZ))
        add    IP, IP, REG2, lsl 3; /* IP = TARGET_IP              */
        LOAD(  REG3, AT(IP))
        br     REG3;                /* jump to instruction after (do) */
.Lm4_loop_.break:
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from return stack */
        NEXT2();                   /* skip IP offset, execute next instruction */
FUNC_RAWEND(m4_loop_)
