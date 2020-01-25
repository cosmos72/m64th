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

#define m4func_m4th_run m4th_run

/**
 * enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in %rdi as per SYS V amd64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(m4th_run)
        push   %rbx;                      /* save C registers                */
#if 0 /* not clobbered by m4th */
        push   %rbp;
#endif /* 0 */
        push   %r12;
        push   %r13;
        push   %r14;
        push   %r15;
        MOVE(  %rdi, M4TH)                      /* m                               */
        STOR(  %rsp, AT(M4TH, M4TH_OFF_C_SP))   /* save C stack pointer            */
        LOAD(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* load data   stack pointer       */
        LOAD(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* load return stack pointer       */
        LOAD(  M4XT, AT(M4TH, M4TH_OFF_W))      /* load word being compiled        */
        LOAD(  IP,   AT(M4TH, M4TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  ETBL, AT(M4TH, M4TH_OFF_ETABLE)) /* load table m4enum -> m4func      */
        DPOP(  DTOP)                      /* load first data   stack element */
        RPOP(  RTOP)                      /* load first return stack element */
        ADD2(  IMM(WORD_OFF_XT), M4XT)    /* convert *m4word -> XT           */
        MOVE(  IMM(-1), RFFF)             /* set RFFF to -1                  */
        NEXT0()                           /* begin execution                 */
FUNC_RAWEND(m4th_run)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
	ADD2(  IMM(SZ), IP)               /* point IP to next instruction    */
        SUB2(  IMM(WORD_OFF_XT), M4XT)    /* convert XT -> *m4word           */
        RPUSH( RTOP)                      /* save first return stack element */
        DPUSH( DTOP)                      /* save first data   stack element */
        STOR(  ETBL, AT(M4TH, M4TH_OFF_ETABLE)) /* save table m4enum -> m4func       */
        STOR(  IP,   AT(M4TH, M4TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  M4XT, AT(M4TH, M4TH_OFF_W))      /* save word being compiled        */
        STOR(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* save return stack pointer       */
        STOR(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* save data   stack pointer       */
        LOAD(  %rsp, AT(M4TH, M4TH_OFF_C_SP))   /* load C stack pointer            */
        pop    %r15;                            /* load C registers                */
        pop    %r14;
        pop    %r13;
        pop    %r12;
#if 0 /* not clobbered by m4th */
        pop    %rbp;
#endif /* 0 */
        pop    %rbx;
        ZERO(  %rax)                      /* return value = 0                */
        ret;                              /* return to C                     */
FUNC_RAWEND(bye)


/** must be followed by an XT. calls it. */
FUNC_START(_call_)
        RPUSH( RTOP)                   /* save RTOP           */
        lea    AT(IP, SZe+SZ), RTOP    /* save return address = IP + SZe + SZ */
        LOAD(  IP,   AT(IP, SZe))      /* load XT from IP[SZe] */
        NEXT0()                        /* jump to XT          */
FUNC_RAWEND(_call_)

/** return from XT being executed (i.e. current forth word) */
FUNC_START(exit)
        MOVE(  RTOP, IP)
        RPOP(  RTOP)
        NEXT0()
FUNC_RAWEND(exit)
