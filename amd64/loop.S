/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "../dispatch/asm.mh"

/* clang-format off */

/**
 * must be followed by IP offset of first instruction after (do) - usually < 0
 * IP offset = 0 means first instruction after (+loop) itself
 */
FUNC_START(_plus_loop_)
        MOVE(  RFFF,   REG1)                           /* a = -1                      */
        MOVE(  DTOP,   REG2)                           /* b = delta                   */
        SHL2( IMM(63), REG1)                           /* a = mincell                 */
        ADD2(  RTOP,   REG1)                           /* a = old i + mincell         */
        ADD2(  DTOP,   RTOP)                           /* i += delta                  */
        /*
         * leave if i crosses the boundary between i'-1 and i'
         * implementation: leave if updating (i - i' + mincell)
         * causes signed overflow or underflow, detected by the x86-64 OF flag
         */
        SUB2( AT(RSTK),REG1)                           /* a = old i - i' + mincell    */
        DPOP___DTOP()
        ADD2(  REG2,   REG1)                           /* a += delta                  */
        jo             TO(_plus_loop_.leave);          /* jump if overflow            */
        RELJUMP()
LABEL(_plus_loop_.leave)
        LOAD(  RTOP,   AT(RSTK, SZ))                   /* load new top of rstack      */
        ADD2(  IMM(SZ2),   RSTK)                       /* drop i' i from return stack */
        NEXTT()                                        /* skip IP offset              */
FUNC_RAWEND(_plus_loop_)


/*
 * must be followed by IP offset of first instruction after (loop)
 * IP offset = 0 means first instruction after (?do) itself
 */
FUNC_START(_q_do_)
        JNE(  AT(DSTK),DTOP,   FUNC(_do_))
        /* skip the loop        */
        LOAD(  DTOP,   AT(DSTK, SZ))   /* reload dstack top     */
        ADD2( IMM(SZ2),DSTK)           /* drop i' i from dstack */
        RELJUMP()

FUNC_DEF(_do_)
/* FUNC_START(_do_) */
        /* enter the loop       */
        ADD2( IMM(SZt),IP)             /* skip jump offset      */
        /* FALLTHROUGH */
/* FUNC_RAWEND(_q_do_) */
/* FUNC_RAWEND(_do_)   */


#define M6FDO
FUNC_DEF(do)
/* FUNC_START(do) */
        RPUSH( RTOP)                 /* save rtop             */
        MOVE(  DTOP,   RTOP)         /* rtop = i              */
        DPOP2( REG1,   DTOP)         /* a = i', reload dtop   */
        RPUSH( REG1)                 /* rpush i'              */
FUNC_END(do)
FUNC_DEFSIZE(_q_do_)
FUNC_DEFSIZE(_do_)


/**
 * pop dstack top.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if) itself
 */
FUNC_START(_if_)
        LD_st( REG3,   AT(IP))         /* c = jump offset         */
        ADD2(IMM(SZt), IP)             /* skip IP offset          */
        test   DTOP,   DTOP;
        ADD4(  IP,     REG3,PSZt, REG3)/* c = TARGET_IP - preserves EFLAGS */
        DPOP___DTOP()                  /* preserves EFLAGS        */
        cmovz  REG3,   IP;             /* set IP if DTOP was 0    */
FUNC_END(_if_)


/**
 * pop dstack top.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (if0) itself
 */
FUNC_START(_if0_)
        LD_st( REG3,   AT(IP))         /* c = jump offset         */
        ADD2(IMM(SZt), IP)             /* skip IP offset          */
        test   DTOP,   DTOP;
        ADD4(  IP,     REG3,PSZt, REG3)/* c = TARGET_IP - preserves EFLAGS */
        DPOP___DTOP()                  /* preserves EFLAGS        */
        cmovnz REG3,   IP;             /* set IP if DTOP was <> 0 */
FUNC_END(_if0_)


/**
 * ( n -- n ) examine dstack top without removing it.
 * if <> 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (?if) itself
 */
#define M6F_Q_IF_
FUNC_START(_q_if_)
        LD_st( REG3,   AT(IP))         /* c = jump offset         */
        ADD2(IMM(SZt), IP)             /* skip IP offset          */
        test   DTOP,   DTOP;
        ADD4(  IP,     REG3,PSZt, REG3)/* c = TARGET_IP - preserves EFLAGS */
        cmovz  REG3,   IP;             /* set IP if DTOP was 0    */
FUNC_END(_q_if_)


/**
 * ( n -- n ) examine dstack top without removing it.
 * if = 0 continue to next instruction, otherwise jump.
 * must be followed by IP offset to jump.
 * IP offset = 0 means first instruction after (?if0) itself
 */
#define M6F_Q_IF0_
FUNC_START(_q_if0_)
        LD_st( REG3,   AT(IP))         /* c = jump offset         */
        ADD2(IMM(SZt), IP)             /* skip IP offset          */
        test   DTOP,   DTOP;
        ADD4(  IP,     REG3,PSZt, REG3)/* c = TARGET_IP - preserves EFLAGS */
        cmovnz REG3,   IP;             /* set IP if DTOP was <> 0 */
FUNC_END(_q_if0_)


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
        INC1(  RTOP)                               /* increment i                 */
        JEQ(   RTOP,   AT(RSTK), TO(_loop_.leave)) /* leave if i == i'            */
        RELJUMP()
LABEL(_loop_.leave)
        RPOP(  RTOP)                               /* drop i' from return stack   */
        RPOP(  RTOP)                               /* reload RTOP                 */
        NEXTT()                                    /* skip IP offset              */
FUNC_RAWEND(_loop_)
