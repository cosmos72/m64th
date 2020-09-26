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

#include "../dispatch/asm.mh"

/* clang-format off */

/** must be followed by an XT. calls it. */
FUNC_START(_call_xt_)
        RPUSH( RTOP)               /* save RTOP            */
        ADDI(  IP,     SZ, RTOP)   /* save return address = IP+SZ   */
        LOAD(  IP,     AT(IP))     /* load xr from IP[0]   */
        NEXT0()                    /* jump to xt           */
FUNC_RAWEND(_call_xt_)


/** pop XT from dstack and call it from native code. */
FUNC_START(_exec_xt_from_native_)
        RPUSH( IP)                 /* save IP. reorders rstack...     */
        /*                          let token 'execute' pop dtop = xt */
        ADDROF_1M(TO(_exec_xt_from_native_.vm_code), IP)
        ASM_CALL(      FUNC(_vm_))
        RPOP(  IP)                 /* load IP. reorders rstack...     */
        ASM_RET()
	WORD_CODE_ALIGN()
LABEL(_exec_xt_from_native_.vm_code)
        WORD_CODE_TOKENS(execute, _return_to_native_)
FUNC_RAWEND(_exec_xt_from_native_)


/*
 * (catch-beg) is the first part of 'catch'. it must be followed by '(catch-end)'
 * it pushes the following cells to rstk:
 *
 * ...  old-RTOP  RSTK-depth  old-m4th.handler  RTOP=IP
 */
FUNC_START(_catch_beg_)
        RPUSH( RTOP)/* save current RTOP */

        /* pop XT */
        MOVE(  DTOP,   REG2)                       /* b = XT to execute  */
        DPOP___DTOP()

        /* save dstk depth to rstk */
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_DEND))
        SUB2(  DSTK,   REG1)                       /* a  = dend - dstk   */
        RPUSH( REG1)                               /* save dend - dstk   */

        /* save m4th.handler to rstk */
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_HANDLER))
        RPUSH( REG1)                               /* save m4th.handler  */

        /* save IP to RTOP, as 'execute' does */
        MOVE(  IP,     RTOP)

        /* save rstk depth to m4th.handler */
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_REND))
        SUB2(  RSTK,   REG1)                       /* a  = rend - rstk   */
        STOR(  REG1,   AT(M4TH, M4TH_OFF_HANDLER)) /* save rend - rstk   */

        /* clear m4th.ex and m4th.ex_message */
        init_R000_REG1()
        STOR(  R000_REG1,  AT(M4TH, M4TH_OFF_EX))
        STOR(  R000_REG1,  AT(M4TH, M4TH_OFF_EX_STRING_N))

        /* execute IP */
        MOVE(  REG2,   IP)
        NEXT0()
FUNC_RAWEND(_catch_beg_)




/* second part of 'catch'. invoked both if nothing was thrown, and if an exception was thrown */
FUNC_START(_catch_end_)
        LOAD(  REG2,   AT(M4TH, M4TH_OFF_EX))        /* a = exception | 0        */
        JNZ(   REG2,   TO(_catch_end_.thrown))

        /* no exception was thrown. just restore m4th.handler and rstk,          */
        /* without restoring dstk                                                */
        STOR(  RTOP,   AT(M4TH, M4TH_OFF_HANDLER))   /* m4th.handler = rtop = previous m4th.handler */
        LOAD(  RTOP,   AT(RSTK, SZ))                 /* reload rtop              */
        ADD2(  IMM(SZ2), RSTK)                       /* adjust rstk              */
        JUMP(  TO(_catch_end_.push))

LABEL(_catch_end_.thrown)
        /*
         * an exception was thrown. almost everything has already been restored by 'throw':
         * we only need to push exception to dstk then clear m4th.ex
         */
        init_R000_REG1()
        STOR(  R000_REG1,  AT(M4TH, M4TH_OFF_EX))    /* clear m4th.ex              */
        /* do NOT clear m4th.ex_message, caller may need it                        */

LABEL(_catch_end_.push)
        /* final touch: push REG2 to dstk */
        DPUSH__DTOP()
        MOVE(  REG2,   DTOP)                         /* ( exception | 0          ) */
FUNC_END(_catch_end_)


/* ( x -- x ) must be followed by e = expected x. throws x <> e */
FUNC_START(_check_lit_)    /* [check] */
        LD_ut( REG1,   AT(IP))                       /* a = expected               */
        MOVI(  M4ERR_CONTROL_STRUCTURE_MISMATCH,   REG0)
        JNE(   REG1,   DTOP,   FUNC(_throw_reg0_))
        NEXTT()                                      /* skip m4token               */
FUNC_RAWEND(_check_lit_)


/* ( ex -- ) throw exception if ex != 0 */
FUNC_START(throw)
        MOVE(  DTOP,   REG0)
        DPOP___DTOP()
        JZ(    REG0,   FUNC_NEXT(throw))             /* 0 means 'do not throw'             */
FUNC_DEF(_throw_reg0_)
        STOR(  REG0,   AT(M4TH, M4TH_OFF_EX))        /* save exception to m4th.ex          */
        LOAD(  REG2,   AT(M4TH, M4TH_OFF_HANDLER))   /* b = m4th.handler = rend - rstk     */
        JZ(    REG2,   FUNC(bye))                    /* no handler => jump to 'bye'        */

        /* recompute rstk from m4th.rend and m4th.handler                                  */
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_REND))      /* a = rend'                          */
        SUB2(  REG2,   REG1)                         /* a = rend' - (rend - rstk) = rstk'  */

        /* speculatively copy RTOP to IP: it may contain the IP saved to RTOP by (catch-beg) */
        MOVE(  RTOP,   IP)
        JEQ(   REG1,   RSTK,  TO(throw.rstk_ok))
        /* rstk changed. it must contain *more* items, thus saved IP is no longer in RTOP  */
        LOAD(  IP,     AT(REG1, -SZ))
        MOVE(  REG1,   RSTK)

LABEL(throw.rstk_ok)
        /* load previous m4th.handler from rstk */
        RPOP(  REG1)                                 /* a = previous m4th.handler */
        STOR(  REG1,   AT(M4TH, M4TH_OFF_HANDLER))   /* m4th.handler = a          */

        /*
         * recompute dstk from m4th.dend and depth saved to rstk.
         * this is tricky because we must also preserve/restore DTOP
         */
        RPOP(  REG1)                                 /* a = dend - dstk = saved depth      */
        LOAD(  REG3,   AT(M4TH, M4TH_OFF_DEND))      /* c = dend'                          */
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


/** pop XT from dstack and call it. */
FUNC_START(execute)
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
