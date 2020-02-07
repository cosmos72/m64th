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
FUNC_START(_q_do_)
        cmp    DTOP, AT(DSTK);
        jne     .L_q_do_.enter;
                                           /* skip the loop:        */
        LOAD(  DTOP,      AT(DSTK, SZ))    /* reload dstack top     */
        ADD2(  IMM(SZ2),  DSTK)            /* drop i' i from dstack */
        RELJUMP()
.L_q_do_.enter:                     /* enter the loop:       */
        ADD2(  IMM(SZt), IP)               /* skip jump offset      */
        /* FALLTHROUGH */
/* FUNC_RAWEND(_q_do_) */


#define M4FDO
FUNC_DEF_SYM(do)
/* FUNC_START(do) */
        SUB2(  IMM(SZ2),   RSTK)       /* update rstack pointer */
        LOAD(  REG1, AT(DSTK))         /* REG1 = i'             */
        STOR(  RTOP, AT(RSTK, SZ))     /* save RTOP             */
        MOVE(  DTOP, RTOP)             /* RTOP = i              */
        STOR(  REG1, AT(RSTK))         /* save i' to rstack     */
        LOAD(  DTOP, AT(DSTK, SZ))     /* reload dstack top     */
        ADD2(  IMM(SZ2),   DSTK)       /* update dstack pointer */
FUNC_END(do)
FUNC_SIZE(_q_do_)


/**
 * ( n -- n ) examine dstack top without removing it.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (?if) itself
 */
FUNC_START(_q_if_)
        test   DTOP, DTOP;
        jnz    .L_q_if_.enter;
        RELJUMP()
.L_q_if_.enter:
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_q_if_)

/**
 * ( n -- n ) examine dstack top without removing it.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (?if0) itself
 */
FUNC_START(_q_if_zero_)
        test   DTOP, DTOP;
        jz     .L_q_if_zero_.enter;
        RELJUMP()
.L_q_if_zero_.enter:
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_q_if_zero_)

/**
 * pop dstack top.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if) itself
 */
FUNC_START(_if_)
        test   DTOP, DTOP;
        jnz     .L_if_.enter;
        DPOP(  DTOP)               /* affects EFLAGS          */
        RELJUMP()
.L_if_.enter:
        DPOP(  DTOP)               /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_)

/**
 * pop dstack top.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if_zero_)
        test   DTOP, DTOP;
        jz     .L_if_zero_.enter;
        DPOP(  DTOP)               /* affects EFLAGS          */
        RELJUMP()
.L_if_zero_.enter:
        DPOP(  DTOP)               /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_zero_)

/**
 * pop dstack twice.
 * if d1 < dtop, continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if_less_)
        cmp    DTOP, AT(DSTK);
        LOAD(  DTOP, AT(DSTK, SZ))
        jl     .L_if_less_.enter;
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        RELJUMP()
.L_if_less_.enter:
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_less_)

/**
 * pop dstack twice.
 * if d1 <= dtop, continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if_less_equal_)
        cmp    DTOP, AT(DSTK);
        LOAD(  DTOP, AT(DSTK, SZ))
        jle    .L_if_less_equal_.enter;
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        RELJUMP()
.L_if_less_equal_.enter:
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_less_equal_)

/**
 * pop dstack twice.
 * if d1 <> dtop, continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if_ne_)
        cmp    DTOP, AT(DSTK);
        LOAD(  DTOP, AT(DSTK, SZ))
        jne    .L_if_ne_.enter;
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        RELJUMP()
.L_if_ne_.enter:
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_ne_)

/**
 * pop dstack twice.
 * if d1 = dtop, continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if_equal_)
        cmp    DTOP, AT(DSTK);
        LOAD(  DTOP, AT(DSTK, SZ))
        je     .L_if_equal_.enter;
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        RELJUMP()
.L_if_equal_.enter:
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_equal_)

/**
 * pop dstack twice.
 * if d1 > dtop, continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if_more_)
        cmp    DTOP, AT(DSTK);
        LOAD(  DTOP, AT(DSTK, SZ))
        jg     .L_if_more_.enter;
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        RELJUMP()
.L_if_more_.enter:
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_more_)

/**
 * pop dstack twice.
 * if d1 >= dtop, continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if_more_equal_)
        cmp    DTOP, AT(DSTK);
        LOAD(  DTOP, AT(DSTK, SZ))
        jge    .L_if_more_equal_.enter;
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        RELJUMP()
.L_if_more_equal_.enter:
        ADD2(  IMM(SZ2),   DSTK)   /* affects EFLAGS          */
        NEXTT()                    /* skip IP offset          */
FUNC_RAWEND(_if_more_equal_)

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
        NEXTT()                    /* skip IP offset              */
FUNC_RAWEND(_loop_)
