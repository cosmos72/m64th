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

#define m4fth_run m4th_run

/* clang-format off */

/**
 * m4th_run: enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in x0 as per arm64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(th_run)
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
        LOAD(  IP,   AT(M4TH, M4TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  FTBL, AT(M4TH, M4TH_OFF_FTABLE)) /* load table m4token -> m4func    */
        LOAD(  HERE, AT(M4TH, M4TH_OFF_HERE))   /* load HERE pointer               */
        DPOP(  DTOP)                            /* load first data   stack element */
        RPOP(  RTOP)                            /* load first return stack element */
        b      FUNC_SYM(_vm_)                   /* enter vm loop                   */
FUNC_RAWEND(th_run)

/**
 * forth vm main loop: fetch m4token instructions and execute them
 */
FUNC_START(_vm_)
        LD_ut( REG3_ut, AT(IP))            /* load m4token of current vm instruction */
        ADD2(  IMM(SZt), IP)               /* pre-increment vm IP                    */
        LOAD(  REG0, AT(FTBL, REG3, SZ))   /* load m4func of current vm instruction  */
        blr    REG0;                       /* execute vm instruction                 */
        b      FUNC_SYM(_vm_);             /* loop                                   */
FUNC_RAWEND(_vm_)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
	ADD2(  IMM(SZ), IP)            /* point IP to next instruction    */
        RPUSH( RTOP)                   /* save first return stack element */
        DPUSH( DTOP)                   /* save first data   stack element */
        STOR(  HERE, AT(M4TH, M4TH_OFF_HERE))   /* save HERE pointer               */
        STOR(  FTBL, AT(M4TH, M4TH_OFF_FTABLE)) /* save table m4token -> m4func    */
        STOR(  IP,   AT(M4TH, M4TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* save return stack pointer       */
        STOR(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* save data   stack pointer       */
        /*
         * TODO: these discard the call stack of compiled forth code
         *       executed since m4th_run(). how to preserve it?
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

/** pop address of native code from dstack and call it. */
FUNC_START(_exec_native_)
        MOVE(  DTOP, REG0)         /* REG1 = address                */
        DPOP(  DTOP)               /* reload dstack top             */
        br     REG0;               /* tail-call optimization: jump to native code */
FUNC_RAWEND(_exec_native_)


/** pop m4token from dstack and call it. works only for tokens with native_len != -1 */
FUNC_START(_exec_token_)
        ubfx   REG0t,  DTOP_ut, 0, SZt*8;  /* REG0 = m4token                */
        LOAD(  REG0,   AT(FTBL, REG0, SZ)) /* REG0 = m4func                 */
        DPOP(  DTOP)                       /* reload dstack top             */
        br     REG0;                       /* tail-call optimization: jump to token */
FUNC_RAWEND(_exec_token_)


