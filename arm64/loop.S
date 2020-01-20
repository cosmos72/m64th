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

/*
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means (?do) itself
 */
FUNC_START(_question_do_)
        LOAD(  REG2, AT(DSTK))
        cmp    REG2, DTOP;
        b.ne   .Lm4_question_do_enter;
        /* skip the loop */
        LOAD(  REG2, AT(IP, SZ))     /* REG2 = IP jump offset */
        LOAD(  DTOP, AT(DSTK, SZ))   /* reload dstack top     */
        add    IP, IP, REG2, lsl PSZ;/* IP = TARGET_IP        */
        ADD2(  IMM(SZ2), DSTK)       /* drop i' i from dstack */
        NEXT0()                      /* jump to TARGET_IP     */
.Lm4_question_do_enter:
        ADD2(  IMM(SZ), IP)          /* skip jump offset      */
        /* FALLTHROUGH into _do_ */
/* FUNC_RAWEND(_question_do_) */


/* FUNC_START(_do_) */
FUNC_DEF_SYM(_do_)
        RPUSH( RTOP)                 /* save rstack top       */
        DPOP(  REG1)                 /* REG1 = i'             */
        MOVE(  DTOP, RTOP)           /* RTOP = i              */
        RPUSH( REG1)                 /* push i' on rstack     */
        DPOP(  DTOP)                 /* reload dstack top     */
FUNC_END(_do_)
FUNC_SIZE(_question_do_)

/*
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means (leave) itself
 */
FUNC_START(_leave_)
        LOAD(  REG2, AT(IP, SZ))
        LOAD(  RTOP, AT(RSTK, SZ))   /* load new rstack top   */
        add    IP, IP, REG2, lsl PSZ;/* IP = TARGET_IP        */
        ADD2(  IMM(SZ2), RSTK)       /* drop i' i from rstack */
        NEXT0()                      /* jump to TARGET_IP     */
FUNC_RAWEND(_leave_)

/*
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means (loop) itself
 */
FUNC_START(_loop_)
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
FUNC_RAWEND(_loop_)
