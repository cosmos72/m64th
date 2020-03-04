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

/** must be followed by a word address. calls it. */
FUNC_START(_call_)
        RPUSH( RTOP)               /* save RTOP            */
        ADDI(  IP,     SZ, RTOP)   /* save return address = IP+SZ   */
        LOAD(  IP,     AT(IP))     /* load w from IP[0]             */
        LD_uh( REG2_uh,AT(IP, WORD_OFF_CODE_OFF)) /* b = w.code_off */
        ADD2(  REG2,   IP)         /* IP = XT              */
        NEXT0()                    /* jump to XT           */
FUNC_RAWEND(_call_)


/** must be followed by an XT. calls it. */
FUNC_START(_call_xt_)
        RPUSH( RTOP)               /* save RTOP            */
        ADDI(  IP,     SZ, RTOP)   /* save return address = IP+SZ   */
        LOAD(  IP,     AT(IP))     /* load XT from IP[0]   */
        NEXT0()                    /* jump to XT           */
FUNC_RAWEND(_call_xt_)


/** pop XT from dstack and call it from native code. */
FUNC_START(_exec_xt_from_native_)
        RPUSH( RTOP)               /* save rtop                       */
        MOVE(  IP,     RTOP)       /* rtop = IP                       */
        /*                          let token 'execute' pop dtop = xt */
        ADDROF_1M(TO(_exec_xt_from_native_.vm_code), IP)
        ASM_CALL(      FUNC(_vm_))
        MOVE(  RTOP,   IP)         /* IP   = rtop                     */
        RPOP(  RTOP)               /* load rtop                       */
        ASM_RET()
	WORD_CODE_ALIGN()
LABEL(_exec_xt_from_native_.vm_code)
        WORD_CODE_TOKENS(execute, _return_to_native_)
FUNC_RAWEND(_exec_xt_from_native_)


/*
 * (catch-beg) is the first part of 'catch'. it must be followed by '(catch-end)'
 * it pushes the following cells to rstk:
 *
 * ...  old-RTOP  RSTK-depth  m4th.handler  RTOP=IP
 */
FUNC_START(_catch_beg_)
        RPUSH( RTOP)/* save current RTOP */

        /* pop XT */
        MOVE(  DTOP,   REG2)                       /* b = XT to execute  */
        DPOP(  DTOP)

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

        /* clear m4th.ex */
        ZERO(  REG1)
        STOR(  REG1,   AT(M4TH, M4TH_OFF_EX))

        /* execute IP */
        MOVE(  REG2,   IP)
        NEXT0()
FUNC_RAWEND(_catch_beg_)

/* second part of 'catch'. invoked both if nothing was thrown, and if an exception was thrown */
FUNC_START(_catch_end_)
        /* recompute rstk from m4th.rend and m4th.handler = rend - rstk = depth */
        LOAD(  RSTK,   AT(M4TH, M4TH_OFF_REND))     /* r = rend        */
#ifdef __x86_64__
        SUB2(  AT(M4TH, M4TH_OFF_HANDLER), RSTK)    /* r = rend - (rend - rstk) = rstk */
#else
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_HANDLER))  /* a = rend - rstk */
        SUB2(  REG1,   RSTK)                        /* r = rend - (rend - rstk) = rstk */
#endif

        /*
         * now we should restore the IP saved to RTOP by (catch-beg):
         * if we are executing this, IP is already correct
         * => nothing needed in order to undo MOVE( IP, RTOP )
         */

        /* load previous m4th.handler from rstk */
        RPOP(  REG1)                                /* a = previous m4th.handler */
        STOR(  REG1,   AT(M4TH, M4TH_OFF_HANDLER))  /* m4th.handler = a */

        /*
         * recompute dstk from m4th.dend and depth saved to rstk.
         * this is tricky because we must also preserve/restore DTOP
         */
        RPOP(  REG1)                                 /* a = dend - dstk = saved depth      */
        LOAD(  REG2,   AT(M4TH, M4TH_OFF_DEND))      /* b = dend'                          */
        SUB2(  DSTK,   REG3)                         /* c = dend' - dstk' = current depth' */
        JBE(   REG1,   REG3,   TO(_catch_end_.dstk)) /* jump if depth <= depth'            */

        /* depth > depth' i.e. we must invent some values and push them to dstk */
        STOR(  DTOP,   AT(DSTK, -SZ))                /* save current DTOP */
#ifdef RFFF
        MOVE(  RFFF,   DTOP)                         /* invent a new value for DTOP */
#else
        MOVE(  IMM(-1),DTOP)
#endif

LABEL(_catch_end_.dstk)
        /* recompute dstk */
#ifdef SUB3
        SUB3(  REG2,   REG1,   DSTK)                 /* dstk' = dend' - (dend - dstk)      */
#else
        SUB2(  REG1,   REG2)                         /* a     = dend' - (dend - dstk)      */
        MOVE(  REG2,   DSTK)                         /* dstk' = a                          */
#endif
        /* we carefully preserved REG1 and REG3. if depth < depth' we must reload DTOP     */
        JAE(   REG1,   REG3,   TO(_catch_end_.done)) /* jump if depth >= depth'            */
        LOAD(  DTOP,   AT(DSTK, -SZ))

LABEL(_catch_end_.done)
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_EX))        /* push exception m4th.ex to dstk     */
        ZERO(  REG1)
        STOR(  REG1,   AT(M4TH, M4TH_OFF_EX))        /* clear m4th.ex                      */

        RPOP(  RTOP)                                 /* restore pushed RTOP                */
FUNC_END(_catch_end_)


FUNC_START(throw)
FUNC_END(throw)


/** pop XT from dstack and call it. */
FUNC_START(execute)
        RPUSH( RTOP)               /* save RTOP                */
        MOVE(  IP,     RTOP)       /* save return address = IP */
        MOVE(  DTOP,   IP)         /* set IP = XT              */
        DPOP(  DTOP)               /* reload dstack top        */
        NEXT0()
FUNC_RAWEND(execute)


/** exit from current XT being executed */
FUNC_START(exit)
        MOVE(  RTOP, IP)
        RPOP(  RTOP)
        NEXT0()
FUNC_RAWEND(exit)
