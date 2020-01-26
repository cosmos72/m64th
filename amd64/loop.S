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

/*
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means first instruction after (?do) itself
 */
FUNC_START(_question_do_)
        cmp    DTOP, AT(DSTK);
        jne     .L_question_do_.enter;
                                           /* skip the loop:        */
        LOAD(  DTOP,      AT(DSTK, SZ))    /* reload dstack top     */
        ADD2(  IMM(SZ2),  DSTK)            /* drop i' i from dstack */
        RELJUMP()
.L_question_do_.enter:                     /* enter the loop:       */
        ADD2(  IMM(SZe), IP)               /* skip jump offset      */
        /* FALLTHROUGH */
/* FUNC_RAWEND(_question_do_) */


FUNC_DEF_SYM(_do_)
/* FUNC_START(_do_) */
        DPOP(  REG1)                   /* REG1 = i'             */
        STOR(  RTOP, AT(RSTK, -SZ))    /* save RTOP             */
        MOVE(  DTOP, RTOP)             /* RTOP = i              */
        DPOP(  DTOP)                   /* reload dstack top     */
        STOR(  REG1, AT(RSTK, -SZ2))   /* save i' to rstack     */
        SUB2(  IMM(SZ2),  RSTK)        /* update rstack pointer */
FUNC_END(_do_)
FUNC_SIZE(_question_do_)


/**
 * unconditional jump. must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (jump) itself
 */
FUNC_START(_jump_)
        RELJUMP()
FUNC_RAWEND(_jump_)

/**
 * pop dstack top.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (else) itself
 */
FUNC_START(_else_)
        test   DTOP, DTOP;
        jnz    .L_else_.jump;
        DPOP(  DTOP)               /* affects EFLAGS          */
        NEXT2()                    /* skip IP offset          */
.L_else_.jump:
        DPOP(  DTOP)
        RELJUMP()
FUNC_RAWEND(_else_)

/**
 * pop dstack top.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if) itself
 */
FUNC_START(_if_)
        test   DTOP, DTOP;
        jz     .L_if_.jump;
        DPOP(  DTOP)               /* affects EFLAGS          */
        NEXT2()                    /* skip IP offset          */
.L_if_.jump:
        DPOP(  DTOP)
        RELJUMP()
FUNC_RAWEND(_if_)

/**
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means first instruction after (leave) itself
 */
FUNC_START(_leave_)
        LOAD(  RTOP,       AT(RSTK, SZ))   /* reload rstack top     */
        ADD2(  IMM(SZ2),   RSTK)           /* drop i' i from rstack */
        RELJUMP()
FUNC_RAWEND(_leave_)

/**
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means first instruction after (loop) itself
 */
FUNC_START(_loop_)
        inc    RTOP;               /* increment i                 */
        cmpq   (RSTK), RTOP;
        je     .L_loop_.leave;     /* leave if i == i'            */
        RELJUMP()
.L_loop_.leave:
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        ADD2(  IMM(SZ2),   RSTK)   /* drop i' i from return stack */
        NEXT2()                    /* skip IP offset              */
FUNC_RAWEND(_loop_)
