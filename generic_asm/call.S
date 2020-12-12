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


/* return from ASM to ASM */
FUNCASM_START(_asm_ret_)
        ASM_RET()
FUNCASM_END(_asm_ret_)


/** must be followed by an XT. calls it. */
FUNC_START(_call_)
        RPUSH( RTOP)               /* save RTOP                     */
        ADDI(  IP,     SZ, RTOP)   /* save return address = IP+SZ   */
        LOAD(  IP,     AT(IP))     /* load xt from IP[0]            */
        NEXT0()                    /* jump to xt                    */
FUNC_RAWEND(_call_)


/*
 * (catch-beg) is the first part of 'catch'. it must be followed by '(catch-end)'
 * it pushes the following cells to rstk:
 *
 * ...  old-RTOP  RSTK-depth  old-m64th.handler  RTOP=IP
 */
FUNC_START(_catch_beg_)
        TOKEN_CALL_NOTHROW(FUNC(_validate_xt_to_reg0_), _catch_beg_.0)
        JNZ(   REG0,   FUNC(_throw_reg0_))

        RPUSH( RTOP)                               /* save current RTOP */

        /* pop XT */
        SUB2(IMM(SZ),  REG1)                       /* update stack depth */
        MOVE(  DTOP,   REG2)                       /* b = XT to execute  */
        DPOP___DTOP()

        /* save dstk depth to rstk */
        RPUSH( REG1)                               /* save dend - dstk   */

        /* save locals address register to rstk */
        RPUSH( LOCL)                               /* save LOCL          */

        /* save m64th.handler to rstk */
        LOAD(  REG1,   AT(M64TH, M64TH_OFF_HANDLER))
        RPUSH( REG1)                               /* save m64th.handler  */

        /* save IP to RTOP, as 'execute' does */
        MOVE(  IP,     RTOP)

        /* save rstk depth to m64th.handler */
        LOAD(  REG1,   AT(M64TH, M64TH_OFF_REND))
        SUB2(  RSTK,   REG1)                       /* a  = rend - rstk   */
        STOR(  REG1,   AT(M64TH, M64TH_OFF_HANDLER)) /* save rend - rstk   */

        /* clear m64th.ex and m64th.ex_message */
        init_R000_REG1()
        STOR(  R000_REG1,  AT(M64TH, M64TH_OFF_EX))
        STOR(  R000_REG1,  AT(M64TH, M64TH_OFF_EX_STRING_N))

        /* execute IP */
        MOVE(  REG2,   IP)
        NEXT0()
FUNC_RAWEND(_catch_beg_)




/* second part of 'catch'. invoked both if nothing was thrown, and if an exception was thrown */
FUNC_START(_catch_end_)
        LOAD(  REG2,   AT(M64TH, M64TH_OFF_EX))        /* a = exception | 0        */
        JNZ(   REG2,   TO(_catch_end_.thrown))

        /* no exception was thrown. just restore m64th.handler and rstk,          */
        /* without restoring dstk                                                */
        STOR(  RTOP,   AT(M64TH, M64TH_OFF_HANDLER))   /* m64th.handler = rtop = previous m64th.handler */
        LOAD(  RTOP,   AT(RSTK, SZ2))                /* reload rtop              */
        ADD2(  IMM(SZ3), RSTK)                       /* adjust rstk              */
        JUMP(  TO(_catch_end_.push))

LABEL(_catch_end_.thrown)
        /*
         * an exception was thrown. almost everything has already been restored by 'throw':
         * we only need to push exception to dstk then clear m64th.ex
         */
        init_R000_REG1()
        STOR(  R000_REG1,  AT(M64TH, M64TH_OFF_EX))    /* clear m64th.ex              */
        /* do NOT clear m64th.ex_message, caller may need it                        */

LABEL(_catch_end_.push)
        /* final touch: push exception to dstk */
        DPUSH__DTOP()
        MOVE(  REG2,   DTOP)                         /* ( exception | 0          ) */
FUNC_END(_catch_end_)


/* ( x -- x ) must be followed by e = expected x. throws x <> e */
FUNC_START(_check_lit_tok_)    /* [check] */
        LD_ut( REG1,   AT(IP))                       /* a = expected               */
        MOVI(  M6ERR_CONTROL_STRUCTURE_MISMATCH,   REG0)
        JNE(   REG1,   DTOP,   FUNC(_throw_reg0_))
        NEXTT()                                      /* skip m6token               */
FUNC_RAWEND(_check_lit_tok_)


/* _validate_xt_to_reg0_ is invoked with TOKEN_CALL_NOTHROW => cannot throw   */
/* thus set REG0 to validation error instead, and let caller throw it */
FUNC_START(_validate_xt_to_reg0_)
        /* check for stack underflow */
        LOAD(  REG1,   AT(M64TH, M64TH_OFF_DEND))
        MOVI(  M6ERR_STACK_UNDERFLOW,  REG0)
        JA(    DSTK,   REG1,   FUNC_RET(_validate_xt_to_reg0_))
        SUB2(  DSTK,   REG1)                       /* a  = dend - dstk   */
        /* _catch_beg_ also needs that we set REG1 = stack depth */

        /* check for obviously invalid XT: */
        /* 1. XT must be a multiple of SZ */
        MOVE(  DTOP,   REG2)
        AND2(IMM(SZ-1),REG2)
        MOVI(  M6ERR_INVALID_MEMORY_ADDRESS,   REG0)
        JNZ(   REG2,               FUNC_RET(_validate_xt_to_reg0_))

#if defined(__linux__) && !defined(__ANDROID__)
        /* 2. on linux, XT must be >= XT(forth_wordlist) */
        ADDROF_4G(WORD_SYM(forth_wordlist), REG2)
        ADD2(IMM(WORD_OFF_XT),     REG2)
#else
        /* 3. some other systems, including at least Termux on Android, */
        /*    place the heap BEFORE text segment and data segment.      */
        /*    On such systems, use a conservative check XT >= 1MB       */
        MOVI( 1<<20,   REG2)
#endif
        JB(   DTOP,    REG2,       FUNC_RET(_validate_xt_to_reg0_))


        /* 4. XT must be < saved C stack, which is usually         */
        /* the highest writeable virtual address                   */
        LOAD( REG2,    AT(M64TH, M64TH_OFF_C_REG0))
        JAE(  DTOP,    REG2, FUNC_RET(_validate_xt_to_reg0_))

        ZERO( REG0)
FUNC_END(_validate_xt_to_reg0_)


/** pop XT from dstack and call it. */
FUNC_START(execute)
        TOKEN_CALL_NOTHROW(FUNC(_validate_xt_to_reg0_), execute.0)
        JNZ(   REG0,   FUNC(_throw_reg0_))

        RPUSH( RTOP)               /* save RTOP                */
        MOVE(  IP,     RTOP)       /* save return address = IP */
        MOVE(  DTOP,   IP)         /* set IP = XT              */
        DPOP___DTOP()              /* reload dstack top        */
        NEXT0()
FUNC_RAWEND(execute)


/** exit from current XT being executed */
FUNC_START(exit)
        MOVE(  RTOP, IP)
        RPOP(  RTOP)
        NEXT0()
FUNC_RAWEND(exit)


/** (recurse)  ( -- ) execution semantics of 'recurse'
 * must be followed by jump offset. calls it. */
FUNC_START(_recurse_)
        RPUSH( RTOP)               /* save RTOP                     */
        ADDI(  IP,     SZt,RTOP)   /* save return address = IP+SZt  */
        LD_st( REG3,     AT(IP))   /* c = jump offset               */
#ifdef ADD5
        ADD5(IP, REG3,PSZt, SZt, IP)  /* set target IP             */
#else
        ADD2(IMM(SZt), IP)            /* skip IP offset            */
        ADD4(IP, REG3,PSZt,      IP)  /* set target IP             */
#endif
        NEXT0()                    /* jump                          */
FUNC_RAWEND(_recurse_)


/* rp@ ( R: x y -- x y ) ( -- &x ) get current return stack address */
FUNC_START(rp_fetch)
        DPUSH__DTOP()
        MOVE(  RSTK,   DTOP)
FUNC_END(rp_fetch)


/* ( ex -- ) throw exception if ex != 0 */
FUNC_START(throw)
        MOVE(  DTOP,   REG0)
        DPOP___DTOP()
        JZ(    REG0,   FUNC_RET(throw))              /* 0 means 'do not throw'             */
FUNC_DEF(_throw_reg0_)
        STOR(  REG0,   AT(M64TH, M64TH_OFF_EX))        /* save exception to m64th.ex          */
        LOAD(  REG2,   AT(M64TH, M64TH_OFF_HANDLER))   /* b = m64th.handler = rend - rstk     */
        JZ(    REG2,   FUNC(bye))                    /* no handler => jump to 'bye'        */

        /* recompute rstk from m64th.rend and m64th.handler                                  */
        LOAD(  REG1,   AT(M64TH, M64TH_OFF_REND))      /* a = rend'                          */
        SUB2(  REG2,   REG1)                         /* a = rend' - (rend - rstk) = rstk'  */

        /* speculatively copy RTOP to IP: it may contain the IP saved to RTOP by (catch-beg) */
        MOVE(  RTOP,   IP)
        JEQ(   REG1,   RSTK,  TO(throw.rstk_ok))
        /* rstk changed. it must contain *more* items, thus saved IP is no longer in RTOP  */
        LOAD(  IP,     AT(REG1, -SZ))
        MOVE(  REG1,   RSTK)

LABEL(throw.rstk_ok)
        /* load previous m64th.handler from rstk */
        RPOP(  REG1)                                 /* a = previous m64th.handler */
        STOR(  REG1,   AT(M64TH, M64TH_OFF_HANDLER))   /* m64th.handler = a          */

        /* load previous LOCL register from rstk */
        RPOP(  LOCL)

        /*
         * recompute dstk from m64th.dend and depth saved to rstk.
         * this is tricky because we must also preserve/restore DTOP
         */
        RPOP(  REG1)                                 /* a = dend - dstk = saved depth      */
        LOAD(  REG3,   AT(M64TH, M64TH_OFF_DEND))      /* c = dend'                          */
        MOVE(  REG3,   REG2)                         /* b = dend'                          */
        SUB2(  DSTK,   REG3)                         /* c = dend' - dstk' = current depth' */
        JEQ(   REG1,   REG3,   TO(throw.dstk_ok))    /* jump if depth = depth'             */
        JL(    REG1,   REG3,   TO(throw.dstk))       /* jump if depth < depth'             */

        /* depth > depth' i.e. we must invent some values and push them to dstk            */
        STOR(  DTOP,   AT(DSTK, -SZ))                /* save current DTOP                  */
        MOVE(  IMM_1,  DTOP)                         /* invent a new value for DTOP        */

LABEL(throw.dstk)
        /* recompute dstk, because depth <> depth' */
#ifdef SUB3
        SUB3(  REG2,   REG1,   DSTK)                 /* dstk' = dend' - (dend - dstk)      */
#else
        SUB2(  REG1,   REG2)                         /* a     = dend' - (dend - dstk)      */
        MOVE(  REG2,   DSTK)                         /* dstk' = a                          */
#endif
        /* we carefully preserved REG1 and REG3. if depth < depth' we must reload DTOP     */
        JGE(   REG1,   REG3,   TO(throw.dstk_ok))    /* jump if depth >= depth'            */
        LOAD(  DTOP,   AT(DSTK, -SZ))

LABEL(throw.dstk_ok)
        RPOP(  RTOP)                                 /* restore RTOP pushed by (catch-beg) */
FUNC_END(throw)


FUNC_START(xt_to_validate)
        TOKEN_CALL_NOTHROW(FUNC(_validate_xt_to_reg0_), xt_to_validate.0)
        JNZ(   REG0,   FUNC(_throw_reg0_))
FUNC_END(xt_to_validate)
