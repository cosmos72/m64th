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

#include "asm.h"

/**
 * enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in x0 as per aarch64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(th_run)
        SUB2(  IMM(SZ8), sp)
        STOR(  x26,  AT(sp, SZ6))        /* save C registers                */
        STOR(  x25,  AT(sp, SZ5))
        STOR(  x24,  AT(sp, SZ4))
        STOR(  x23,  AT(sp, SZ3))
        STOR(  x22,  AT(sp, SZ2))
        STOR(  x21,  AT(sp, SZ))
        STOR(  x20,  AT(sp))
        MOVE(  x0,   M4TH)               /* m                               */
        LOAD(  DSTK, AT(M4TH, M4TH_OFF_DSTK)) /* load data   stack pointer       */
        LOAD(  RSTK, AT(M4TH, M4TH_OFF_RSTK)) /* load return stack pointer       */
        LOAD(  M4W,  AT(M4TH, M4TH_OFF_W))    /* load word being compiled        */
        LOAD(  IP,   AT(M4TH, M4TH_OFF_IP))   /* load instruction  pointer       */
        DPOP(  DTOP)                     /* load first data   stack element */
        RPOP(  RTOP)                     /* load first return stack element */
        LOAD(  REG1, AT(IP))             /* begin execution                 */
        br     REG1;
FUNC_RAWEND(th_run)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
	ADD2(  IMM(SZ), IP)               /* point IP to next instruction    */
        RPUSH( RTOP)                      /* save first return stack element */
        DPUSH( DTOP)                      /* save first data   stack element */
        STOR(  IP,   AT(M4TH, M4TH_OFF_IP))    /* save instruction  pointer       */
        STOR(  M4W,  AT(M4TH, M4TH_OFF_W))     /* save word being compiled        */
        STOR(  RSTK, AT(M4TH, M4TH_OFF_RSTK))  /* save return stack pointer       */
        STOR(  DSTK, AT(M4TH, M4TH_OFF_DSTK))  /* save data   stack pointer       */
        LOAD(  x20,  AT(sp))              /* load C registers                */
        LOAD(  x21,  AT(sp, SZ))
        LOAD(  x22,  AT(sp, SZ2))
        LOAD(  x23,  AT(sp, SZ3))
        LOAD(  x24,  AT(sp, SZ4))
        LOAD(  x25,  AT(sp, SZ5))
        LOAD(  x26,  AT(sp, SZ6))
        ADD2(  IMM(SZ8), sp)
        ZERO(  x0)                        /* return value = 0                */
        ret;                              /* return to C                     */
FUNC_RAWEND(bye)

/** must be followed by address of a forth function. calls it. */
FUNC_START(_call_)
        RPUSH( RTOP)
        /* execution will resume at IP + SZ2 after called function returns */
        ADD3(  IP,   IMM(SZ2), RTOP)
        /* load function address */
        LOAD(  IP,   AT(IP, SZ))
        /* jump to function */
        LOAD(  REG1, AT(IP))
        br     REG1;
FUNC_RAWEND(_call_)

/** return from word being executed (i.e. current function) */
FUNC_START(exit)
        MOVE(  RTOP, IP)
        RPOP(  RTOP)
        LOAD(  REG1, AT(IP))
        br     REG1;
FUNC_RAWEND(exit)
