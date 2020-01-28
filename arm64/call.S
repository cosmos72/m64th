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

#define m4fth_run_vm m4th_run_vm

/**
 * m4th_run_vm: enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in x0 as per aarch64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(th_run_vm)
        SUB2(  IMM(SZ10), sp)          /* save C registers                */
        STOR(  lr,   AT(sp, SZ9))      /* save LR register (return addr)  */
        STOR(  x27,  AT(sp, SZ7))
        STOR(  x26,  AT(sp, SZ6))
        STOR(  x25,  AT(sp, SZ5))
        STOR(  x24,  AT(sp, SZ4))
        STOR(  x23,  AT(sp, SZ3))
        STOR(  x22,  AT(sp, SZ2))
        STOR(  x21,  AT(sp, SZ))
        STOR(  x20,  AT(sp))
        MOVE(  x0,   M4TH)             /* load m4th*                      */
        MOVE(  sp,   REG1)
        STOR(  REG1, AT(M4TH, M4TH_OFF_C_REG0)) /* save C stack pointer            */
        LOAD(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* load data   stack pointer       */
        LOAD(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* load return stack pointer       */
        LOAD(  M4XT, AT(M4TH, M4TH_OFF_W))      /* load word being compiled        */
        LOAD(  IP,   AT(M4TH, M4TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  ETBL, AT(M4TH, M4TH_OFF_ETABLE)) /* load table m4enum -> m4func     */
        DPOP(  DTOP)                            /* load first data   stack element */
        RPOP(  RTOP)                            /* load first return stack element */
        ADD2(  IMM(WORD_OFF_XT), M4XT)          /* convert m4word* -> XT           */
        b      FUNC_SYM(_vm_)                   /* enter vm loop                   */
FUNC_RAWEND(th_run_vm)

/**
 * forth vm main loop: fetch m4enum instructions and execute them
 */
FUNC_START(_vm_)
        LD_ue( REG3_ue, AT(IP))            /* load m4enum of current vm instruction */
        ADD2(  IMM(SZe), IP)               /* increment vm IP                       */
        LOAD(  REG0, AT(ETBL, REG3, SZ))   /* load m4func of current vm instruction */
        blr    REG0;                       /* execute vm instruction                */
        b      FUNC_SYM(_vm_);             /* loop                                  */
FUNC_RAWEND(_vm_)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
	ADD2(  IMM(SZ), IP)            /* point IP to next instruction    */
        SUB2(  IMM(WORD_OFF_XT), M4XT) /* convert XT -> *m4word           */
        RPUSH( RTOP)                   /* save first return stack element */
        DPUSH( DTOP)                   /* save first data   stack element */
        STOR(  ETBL, AT(M4TH, M4TH_OFF_ETABLE)) /* save table m4enum -> m4func     */
        STOR(  IP,   AT(M4TH, M4TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  M4XT, AT(M4TH, M4TH_OFF_W))      /* save word being compiled        */
        STOR(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* save return stack pointer       */
        STOR(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* save data   stack pointer       */
        /*
         * TODO: these discard the call stack of compiled forth code
         *       executed since m4th_run_vm(). how to preserve it?
         */
        LOAD(  REG1, AT(M4TH, M4TH_OFF_C_REG0)) /* load C stack pointer            */
        MOVE(  REG1, sp)
        LOAD(  x20,  AT(sp))                    /* load C registers                */
        LOAD(  x21,  AT(sp, SZ))
        LOAD(  x22,  AT(sp, SZ2))
        LOAD(  x23,  AT(sp, SZ3))
        LOAD(  x24,  AT(sp, SZ4))
        LOAD(  x25,  AT(sp, SZ5))
        LOAD(  x26,  AT(sp, SZ6))
        LOAD(  x27,  AT(sp, SZ7))
        LOAD(  lr,   AT(sp, SZ9))               /* load LR register (return addr)  */
        ADD2(  IMM(SZ10), sp)
        ZERO(  x0)                     /* return value = 0                */
        ret;                           /* return to C                     */
FUNC_RAWEND(bye)

/** must be followed by an XT. calls it. */
FUNC_START(_call_)
        RPUSH( RTOP)                   /* save RTOP           */
        ADD3(  IP,   IMM(SZ), RTOP)    /* save return address = IP+SZ  */
        LOAD(  IP,   AT(IP))           /* load XT from IP[0]  */
        NEXT0()                        /* jump to XT          */
FUNC_RAWEND(_call_)

/** return from XT being executed (i.e. current forth word) */
FUNC_START(exit)
        MOVE(  RTOP, IP)
        RPOP(  RTOP)
        NEXT0()
FUNC_RAWEND(exit)
