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
                                    /* not clobbered: x18 x19 x28 x29 x30 */
        stp    x20,  x21,  AT(sp);
        stp    x22,  x23,  AT(sp, SZ2);
        stp    x24,  x25,  AT(sp, SZ4);
        stp    x26,  x27,  AT(sp, SZ6);
        STOR(  lr,   AT(sp, SZ9))      /* save LR register (return addr)  */
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
        /* cannot use x0..x8 here: they are used by c-arg-[N] and c-ret-[N] */
        LD_ut( w9,     AT(IP))             /* load m4token of current vm instruction */
        ADD2(  IMM(SZt), IP)               /* pre-increment vm IP                    */
        LOAD(  x9,     AT(FTBL, x9, SZ))   /* load m4func of current vm instruction  */
        blr    x9;                         /* execute vm instruction                 */
        b      FUNC_SYM(_vm_);             /* loop                                   */
FUNC_RAWEND(_vm_)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
        ADD2(  IMM(SZ), IP)                     /* point IP to next instruction    */
        RPUSH( RTOP)                            /* save first return stack element */
        DPUSH( DTOP)                            /* save first data   stack element */
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
        LOAD(  x0,   AT(M4TH, M4TH_OFF_ERR))    /* load return value = m4th.err    */
        MOVE(  REG1, sp)
        ldp    x20,  x21,  AT(sp);              /* load C registers                */
        ldp    x22,  x23,  AT(sp, SZ2);
        ldp    x24,  x25,  AT(sp, SZ4);
        ldp    x26,  x27,  AT(sp, SZ6);
        LOAD(  lr,   AT(sp, SZ9))               /* load LR register (return addr)  */
        ADD2(  IMM(SZ10), sp)
        ret;                                    /* return to C                     */
FUNC_RAWEND(bye)


/* pop 0 args, prepare for C function call */
FUNC_START(_c_arg_0_)
        DPUSH( DTOP) /* c-ret-[N] will reload DTOP */
FUNC_END(_c_arg_0_)


/* pop 1 arg, prepare it for C function call */
FUNC_START(_c_arg_1_)
        MOVE(  DTOP,   x0)
FUNC_END(_c_arg_1_)


/* pop 2 args, prepare them for C function call */
FUNC_START(_c_arg_2_)
        MOVE(  DTOP,   x1)
        DPOP(  x0)
FUNC_END(_c_arg_2_)


/* pop 3 args, prepare them for C function call */
FUNC_START(_c_arg_3_)
        MOVE(  DTOP,   x2)
        DPOP2( x1, x0)
FUNC_END(_c_arg_3_)


/* pop 4 args, prepare them for C function call */
FUNC_START(_c_arg_4_)
        MOVE(  DTOP,   x3)
        DPOP(  x2)
        DPOP2( x1, x0)
FUNC_END(_c_arg_4_)


/* pop 5 args, prepare them for C function call */
FUNC_START(_c_arg_5_)
        MOVE(  DTOP,   x4)
        DPOP2( x3, x2)
        DPOP2( x1, x0)
FUNC_END(_c_arg_5_)


/* pop 6 args, prepare them for C function call */
FUNC_START(_c_arg_6_)
        MOVE(  DTOP,   x5)
        DPOP(  x4)
        DPOP2( x3, x2)
        DPOP2( x1, x0)
FUNC_END(_c_arg_6_)


/* must be followed by C function address. call it. */
FUNC_START(_c_call_)
        /* cannot use x0..x8 here, they are used by c-args-[N] and c-ret-[N] */
        ldr    x9,     AT(IP),   IMM(SZ); /* post-increment */
        br     x9;                /* tail call optimization */
FUNC_RAWEND(_c_call_)


/* push 0 values returned by C function call */
FUNC_START(_c_ret_0_)
        /* reload DTOP because c_arg_* above moved DSTK */
        DPOP(  DTOP)
FUNC_END(_c_ret_0_)


/* push 1 value  returned by C function call */
FUNC_START(_c_ret_1_)
        MOVE(  x0,     DTOP)
FUNC_END(_c_ret_1_)


/* push 2 values returned by C function call */
FUNC_START(_c_ret_2_)
        DPUSH( x0)
        MOVE(  x1,     DTOP)
        /* TODO */
FUNC_END(_c_ret_2_)


/** pop address of native code from dstack and call it. */
FUNC_START(_exec_native_)
        MOVE(  DTOP,   REG0)       /* REG1 = address                */
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


/* return to native code */
FUNC_START(_return_to_native_)
        RPOP(  lr)                 /* skip current return address (it's inside _vm_) and load next one */
        ASM_RET()                  /* return to caller of _vm_ - usually _exec_xt_from_native_ */
FUNC_RAWEND(_return_to_native_)

