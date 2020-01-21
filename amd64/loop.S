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
 * IP offset = 0 means (?do) itself
 */
FUNC_START(_question_do_)
        cmp    DTOP, AT(DSTK);
        jne    .Lm4_question_do_enter;
        /* skip the loop */
        LOAD(  REG2, AT(IP, SZ))     /* REG2 = IP jump offset */
        LOAD(  DTOP, AT(DSTK, SZ))   /* reload dstack top     */
        lea    (IP, REG2, SZ), IP;   /* IP = TARGET_IP        */
        ADD2(  IMM(SZ2), DSTK)       /* drop i' i from dstack */
        NEXT0()                      /* jump to TARGET_IP     */
.Lm4_question_do_enter:
        ADD2(  IMM(SZ), IP)          /* skip jump offset      */
        /* FALLTHROUGH into _do_ */
/* FUNC_RAWEND(_question_do_) */


FUNC_DEF_SYM(_do_)
/* FUNC_START(_do_) */
        DPOP(  REG1)                 /* REG1 = i'             */
        STOR(  RTOP, AT(RSTK, -SZ))  /* save RTOP             */
        MOVE(  DTOP, RTOP)           /* RTOP = i              */
        DPOP(  DTOP)                 /* reload dstack top     */
        STOR(  REG1, AT(RSTK, -SZ2)) /* save i' to rstack     */
        SUB2(  IMM(SZ2),  RSTK)      /* update rstack pointer */
FUNC_END(_do_)
FUNC_SIZE(_question_do_)


/**
 * unconditional jump.
 * must be followed by IP offset to skip.
 * IP offset = 0 means (jump) itself
 */
FUNC_START(_jump_)
        LOAD(  REG2, AT(IP, SZ))   /* REG2 = IP jump offset   */
        lea    (IP, REG2, SZ), IP; /* IP   = TARGET_IP        */
        NEXT0()                    /* jump to TARGET_IP       */
FUNC_RAWEND(_jump_)

/**
 * pop dstack top, and jump if <> 0.
 * must be followed by IP offset to skip.
 * IP offset = 0 means (jump_if) itself
 */
FUNC_START(_jump_if_)
        test   DTOP, DTOP;
        DPOP(  DTOP)
        jnz    .Lm4_jump_if_nonzero;
        NEXT2()                    /* skip IP offset          */
.Lm4_jump_if_nonzero:
        LOAD(  REG2, AT(IP, SZ))   /* REG2 = IP jump offset   */
        lea    (IP, REG2, SZ), IP; /* IP   = TARGET_IP        */
        NEXT0()                    /* jump to TARGET_IP       */
FUNC_RAWEND(_jump_if_)

/**
 * pop dstack top, and jump if = 0.
 * must be followed by IP offset to skip.
 * IP offset = 0 means (jump_unless) itself
 */
FUNC_START(_jump_unless_)
        test   DTOP, DTOP;
        DPOP(  DTOP)
        jnz    .Lm4_jump_unless_zero;
        NEXT2()                    /* skip IP offset          */
.Lm4_jump_unless_zero:
        LOAD(  REG2, AT(IP, SZ))   /* REG2 = IP jump offset   */
        lea    (IP, REG2, SZ), IP; /* IP   = TARGET_IP        */
        NEXT0()                    /* jump to TARGET_IP       */
FUNC_RAWEND(_jump_unless_)

/**
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means (leave) itself
 */
FUNC_START(_leave_)
        LOAD(  REG2, AT(IP, SZ))   /* REG2 = IP jump offset   */
        LOAD(  RTOP, AT(RSTK, SZ)) /* reload rstack top       */
        lea    (IP, REG2, SZ), IP; /* IP = TARGET_IP          */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from rstack   */
        NEXT0()                    /* jump to TARGET_IP       */
FUNC_RAWEND(_leave_)

/**
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means (loop) itself
 */
FUNC_START(_loop_)
        inc    RTOP;               /* increment i                 */
        cmpq   (RSTK), RTOP;
        je     .Lm4_loop_.leave;   /* leave if i == i'            */
        LOAD(  REG2, AT(IP, SZ))
        lea    (IP, REG2, SZ), IP; /* IP = TARGET_IP              */
        NEXT0()                    /* jump to instruction after (do) */
.Lm4_loop_.leave:
        ADD2(  IMM(SZ2), IP)       /* skip jump offset            */
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from return stack */
        NEXT0()                    /* execute next instruction    */
FUNC_RAWEND(_loop_)
