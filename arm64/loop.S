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

#include "asm.mh"

/**
 * pop dstack top, enter a (do) ... (loop) if <> 0.
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means first instruction after (?do) itself
 */
FUNC_START(_question_do_)
        LOAD(  REG2, AT(DSTK))
        cmp    REG2, DTOP;
        b.eq   .L_question_do_.skip;
        ADD2(  IMM(SZe), IP)           /* skip jump offset      */
        b      FUNC_SYM(_do_);
.L_question_do_.skip:                /* skip the loop:        */
        LD_sh(REG2_sh, AT(IP, SZe))  /* REG2 = IP jump offset */
        LOAD(  DTOP,   AT(DSTK, SZ))   /* reload dstack top     */
        add    IP, IP, REG2, lsl PSZe; /* IP = TARGET_IP        */
        ADD2(  IMM(SZ2), DSTK)         /* drop i' i from dstack */
        NEXT0()                        /* jump to TARGET_IP     */
FUNC_RAWEND(_question_do_)


/**
 * pop dstack top.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if) itself
 */
FUNC_START(_if_)
        cmp    DTOP, IMM(0);
        DPOP(  DTOP)
        b.eq   .L_if_.enter;
        RELJUMP()
.L_if_.enter:
        NEXTE()                      /* skip IP offset          */
FUNC_RAWEND(_if_)

/**
 * pop dstack top.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if-zero) itself
 */
FUNC_START(_if_zero_)
        cmp    DTOP, IMM(0);
        DPOP(  DTOP)
        b.ne   .L_if_zero_.enter;
        RELJUMP()
.L_if_zero_.enter:
        NEXTE()                      /* skip IP offset          */
FUNC_RAWEND(_if_zero_)

/**
 * pop dstack twice.
 * if d2 < dtop continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if<) itself
 */
FUNC_START(_if_less_)
        DPOP(  REG1)
        cmp    DTOP, REG1;
	DPOP(  DTOP)
        b.lt   .L_if_less_.enter;
	RELJUMP()
.L_if_less_.enter:
        NEXTE()                      /* skip IP offset          */
FUNC_RAWEND(_if_less_)

/**
 * pop dstack twice.
 * if d2 <= dtop continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if<) itself
 */
FUNC_START(_if_less_equal_)
        DPOP(  REG1)
        cmp    DTOP, REG1;
	DPOP(  DTOP)
        b.le   .L_if_less_equal_.enter;
	RELJUMP()
.L_if_less_equal_.enter:
        NEXTE()                      /* skip IP offset          */
FUNC_RAWEND(_if_less_equal_)

/**
 * pop dstack twice.
 * if d2 <> dtop continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if<) itself
 */
FUNC_START(_if_ne_)
        DPOP(  REG1)
        cmp    DTOP, REG1;
	DPOP(  DTOP)
        b.ne   .L_if_ne_.enter;
	RELJUMP()
.L_if_ne_.enter:
        NEXTE()                      /* skip IP offset          */
FUNC_RAWEND(_if_ne_)

/**
 * break from a loop.
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means first instruction after (leave) itself
 */
FUNC_START(_leave_)
        LOAD(  REG2, AT(IP, SZ))
        LOAD(  RTOP, AT(RSTK, SZ))   /* load new rstack top   */
        add    IP, IP, REG2, lsl PSZ;/* IP = TARGET_IP        */
        ADD2(  IMM(SZ2), RSTK)       /* drop i' i from rstack */
        NEXT0()                      /* jump to TARGET_IP     */
FUNC_RAWEND(_leave_)

/**
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means first instruction after (loop) itself
 */
FUNC_START(_loop_)
        ADD2(  IMM(1), RTOP)        /* increment i                 */
        LOAD(  REG1, AT(RSTK))      /* REG1 = i'                   */
        cmp    REG1, RTOP;
        b.eq   .L_loop_.break;        /* break if i == i'            */
	RELJUMP()
.L_loop_.break:
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from return stack */
        NEXTE();                   /* skip IP offset, execute next instruction */
FUNC_RAWEND(_loop_)
