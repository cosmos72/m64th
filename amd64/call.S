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
 *      passed in %rdi as per SYS V amd64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(th_run_vm)
        push   %rbp;                   /* save C registers                */
        push   %rbx;
        push   %r12;
        push   %r13;
        push   %r14;
        push   %r15;
        MOVE(  %rdi, M4TH)                      /* m                               */
        STOR(  %rsp, AT(M4TH, M4TH_OFF_C_REG0)) /* save C stack pointer            */
        LOAD(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* load data   stack pointer       */
        LOAD(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* load return stack pointer       */
        LOAD(  RXT,  AT(M4TH, M4TH_OFF_W))      /* load word being compiled        */
        LOAD(  IP,   AT(M4TH, M4TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  FTBL, AT(M4TH, M4TH_OFF_FTABLE)) /* load table m4token -> m4func      */
        DPOP(  DTOP)                   /* load first data   stack element */
        RPOP(  RTOP)                   /* load first return stack element */
        ADD2(  IMM(WORD_OFF_XT), RXT)  /* convert m4word* -> XT           */
        MOVE(  IMM(-1), RFFF)          /* set RFFF to -1                  */
        jmp    FUNC_SYM(_vm_)          /* enter vm loop                   */
FUNC_RAWEND(th_run_vm)


/**
 * forth vm main loop: fetch m4token instructions and execute them
 */
FUNC_START(_vm_)
        LD_ut(REG3_ut, AT(IP))         /* load m4token of current vm instruction */
        ADD2(IMM(SZt), IP)             /* increment vm IP                       */
        call *(FTBL, REG3, SZ);        /* execute vm instruction                */
        jmp    FUNC_SYM(_vm_);         /* loop                                  */
FUNC_RAWEND(_vm_)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
	ADD2(  IMM(SZ), IP)               /* point IP to next instruction    */
        SUB2(  IMM(WORD_OFF_XT), RXT)     /* convert RXT -> *m4word           */
        RPUSH( RTOP)                      /* save first return stack element */
        DPUSH( DTOP)                      /* save first data   stack element */
        STOR(  FTBL, AT(M4TH, M4TH_OFF_FTABLE)) /* save table m4token -> m4func     */
        STOR(  IP,   AT(M4TH, M4TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  RXT,  AT(M4TH, M4TH_OFF_W))      /* save word being compiled        */
        STOR(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* save return stack pointer       */
        STOR(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* save data   stack pointer       */
        /*
         * TODO: this discards the call stack of compiled forth code
         *       executed since m4th_run_vm(). how to preserve it?
         */
        LOAD(  %rsp, AT(M4TH, M4TH_OFF_C_REG0))    /* load C stack pointer            */
        pop    %r15;                               /* load C registers                */
        pop    %r14;
        pop    %r13;
        pop    %r12;
        pop    %rbx;
        pop    %rbp;
        ZERO(  %rax)               /* return value = 0                */
        ret;                       /* return to C                     */
FUNC_RAWEND(bye)


/** must be followed by an XT. calls it. */
FUNC_START(_call_)
        RPUSH( RTOP)               /* save RTOP                     */
        lea    AT(IP, SZ), RTOP    /* save return address = IP + SZ */
        LOAD(  IP,     AT(IP))     /* set IP = XT at IP[0]          */
        NEXT0()
FUNC_RAWEND(_call_)


/** pop address of native code from dstack and call it. */
FUNC_START(_exec_native_)
        MOVE(  DTOP, REG1)         /* REG1 = address                */
        DPOP(  DTOP)               /* reload dstack top             */
        jmp    *REG1;              /* tail-call optimization: jump to native code */
FUNC_RAWEND(_exec_native_)


/** pop m4token from dstack and call it. works only for tokens with native_len != -1 */
FUNC_START(_exec_token_)
        /* FIXME this assumes SZt = 2 */
        movzwl DTOPt,  REG3_ut;    /* REG1 = m4token                */
        DPOP(  DTOP)               /* reload dstack top             */
        jmp    *(FTBL, REG3, SZ);  /* tail-call optimization: jump to token */
FUNC_RAWEND(_exec_token_)


/**
  * push to dstack vm's current instruction pointer,
  * i.e. the address of the (ip) m4token itself inside the code being executed
  */
FUNC_START(_ip_)
        DPUSH( DTOP)
        lea    -SZt(IP),   DTOP;   /* IP actually points to next instruction: fix it */
FUNC_END(_ip_)
