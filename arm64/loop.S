/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
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

/* clang-format off */

/**
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means first instruction after (+loop) itself
 */
FUNC_START(_plus_loop_)
        LOAD(  REG2,   AT(RSTK))                       /* b = i'                      */
        MOVE(  IMM(1<<63), REG1)                       /* a = mincell                 */
        SUB3(  RTOP,   REG2,  REG2)                    /* b = old i - i'              */
        ADD2(  DTOP,   RTOP)                           /* i += delta                  */
        /*
         * leave if i crosses the boundary between i'-1 and i'
         * implementation: leave if updating (i - i' + mincell)
         * causes signed overflow or underflow, detected by the arm64 VS flag
         */
        ADD2(  REG2,   REG1)                           /* a = old i - i' + mincell    */
        adds   REG1,   REG1,   DTOP;                   /* a += delta, update flags    */
        DPOP(  DTOP)                                   /* arm64: does not alter flags */
        b.vs           TO(_plus_loop_.leave);          /* jump if overflow            */
        RELJUMP()
LABEL(_plus_loop_.leave)
        LOAD(  RTOP,   AT(RSTK, SZ))                   /* load new top of rstack      */
        ADD2(  IMM(SZ2),   RSTK)                       /* drop i' i from return stack */
        NEXTT()                                        /* skip IP offset              */
FUNC_RAWEND(_plus_loop_)

/**
 * pop dstack top, enter a do ... (loop) if <> 0.
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means first instruction after (?do) itself
 */
FUNC_START(_q_do_)
        LOAD(  REG2, AT(DSTK))
        cmp    REG2, DTOP;
        b.ne   FUNC(_do_)
        /* skip the loop        */
        LOAD(  DTOP,   AT(DSTK, SZ))   /* reload dstack top     */
        ADD2(  IMM(SZ2), DSTK)         /* drop i' i from dstack */
        RELJUMP()                      /* jump to TARGET_IP     */
FUNC_DEF(_do_)
        ADD2(  IMM(SZt), IP)           /* skip jump offset      */
        /* FALLTHROUGH */
/* FUNC_RAWEND(_q_do_) */
/* FUNC_RAWEND(_do_)   */


#define M4FDO
FUNC_DEF(do) /* FUNC_START(do) */
        RPUSH( RTOP)                 /* save rtop             */
        MOVE(  DTOP,   RTOP)         /* rtop = i              */
        DPOP2( REG1,   DTOP)         /* a = i', reload dtop   */
        RPUSH( REG1)                 /* rpush i'              */
FUNC_END(do)
FUNC_SIZE(_q_do_)
FUNC_SIZE(_do_)


/**
 * pop dstack top.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if) itself
 */
FUNC_START(_if_)
        cmp    DTOP, IMM(0);
        DPOP(  DTOP)
        b.ne   .L_if_.enter;
        RELJUMP()
.L_if_.enter:
        NEXTT()                      /* skip IP offset          */
FUNC_RAWEND(_if_)


/**
 * pop dstack top.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if0_)
        cmp    DTOP, IMM(0);
        DPOP(  DTOP)
        b.eq   TO(_if0_.enter)
        RELJUMP()
LABEL(_if0_.enter)
        NEXTT()                      /* skip IP offset          */
FUNC_RAWEND(_if0_)

/**
 * break from a loop.
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means first instruction after (leave) itself
 */
FUNC_START(_leave_)
        LOAD(  RTOP, AT(RSTK, SZ))   /* load new rstack top   */
        ADD2(  IMM(SZ2), RSTK)       /* drop i' i from rstack */
        RELJUMP()                    /* jump to TARGET_IP     */
FUNC_RAWEND(_leave_)

/**
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means first instruction after (loop) itself
 */
FUNC_START(_loop_)
        INC1(  RTOP)               /* increment i                 */
        LOAD(  REG1, AT(RSTK))     /* REG1 = i'                   */
        cmp    REG1, RTOP;
        b.eq   TO(_loop_.leave)    /* leave if i == i'            */
        RELJUMP()
LABEL(_loop_.leave)
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack      */
        ADD2(  IMM(SZ2), RSTK)     /* drop i' i from return stack */
        NEXTT();                   /* skip IP offset, execute next instruction */
FUNC_RAWEND(_loop_)
