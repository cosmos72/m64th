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
 * IP offset = 0 means (?do) itself
 */
FUNC_START(_question_do_)
        LOAD(  REG2, AT(DSTK))
        cmp    REG2, DTOP;
        b.eq   .L_question_do_.skip;
        ADD2(  IMM(ISZ), IP)           /* skip jump offset      */
        b      FUNC_SYM(_do_);
.L_question_do_.skip:                /* skip the loop:        */
        LD_sh(REG2_sh, AT(IP, ISZ))  /* REG2 = IP jump offset */
        LOAD(  DTOP,   AT(DSTK, SZ))   /* reload dstack top     */
        add    IP, IP, REG2, lsl PISZ; /* IP = TARGET_IP        */
        ADD2(  IMM(SZ2), DSTK)         /* drop i' i from dstack */
        NEXT0()                        /* jump to TARGET_IP     */
FUNC_RAWEND(_question_do_)


/** implementation of 'do', enters a (do) ... (loop) */
FUNC_START(_do_)
        RPUSH( RTOP)                 /* save rstack top       */
        DPOP(  REG1)                 /* REG1 = i'             */
        MOVE(  DTOP, RTOP)           /* RTOP = i              */
        RPUSH( REG1)                 /* push i' on rstack     */
        DPOP(  DTOP)                 /* reload dstack top     */
FUNC_END(_do_)

/**
 * unconditional jump.
 * must be followed by IP offset to skip.
 * IP offset = 0 means (jump) itself
 */
FUNC_START(_jump_)
        LD_sh(  REG2_sh, AT(IP, ISZ))  /* REG2 = IP jump offset   */
        add    IP, IP, REG2, lsl PISZ;   /* IP   = TARGET_IP        */
        NEXT0()                          /* jump to TARGET_IP       */
FUNC_END(_jump_)

/**
 * pop dstack top.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means (_else_) itself
 */
FUNC_START(_else_)
        cmp    DTOP, IMM(0);
        DPOP(  DTOP)
        b.ne   .L_else_.jump;
        NEXT2()                      /* skip IP offset          */
.L_else_.jump:
        LOAD(  REG2, AT(IP, SZ))     /* REG2 = IP jump offset   */
        add    IP, IP, REG2, lsl PSZ;/* IP   = TARGET_IP        */
        NEXT0()                      /* jump to TARGET_IP       */
FUNC_RAWEND(_else_)

/**
 * pop dstack top.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means (_if_) itself
 */
FUNC_START(_if_)
        cmp    DTOP, IMM(0);
        DPOP(  DTOP)
        b.eq   .L_if_.jump;
        NEXT2()                      /* skip IP offset          */
.L_if_.jump:
        LOAD(  REG2, AT(IP, SZ))     /* REG2 = IP jump offset   */
        add    IP, IP, REG2, lsl PSZ;/* IP   = TARGET_IP        */
        NEXT0()                      /* jump to TARGET_IP       */
FUNC_RAWEND(_if_)

/**
 * break from a loop.
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

/**
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means (loop) itself
 */
FUNC_START(_loop_)
        ADD2(  IMM(1), RTOP)        /* increment i                 */
        LOAD(  REG1, AT(RSTK))      /* REG1 = i'                   */
        cmp    REG1, RTOP;
        b.eq   .L_loop_.break;        /* break if i == i'            */
        LD_sh(  REG2_sh, AT(IP, ISZ)) /* REG2 = IP jump offset   */
        add    IP, IP, REG2, lsl PISZ;  /* IP = TARGET_IP              */
        NEXT0()                         /* jump to TARGET_IP           */
.L_loop_.break:
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from return stack */
        NEXT2();                   /* skip IP offset, execute next instruction */
FUNC_RAWEND(_loop_)
