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

#define m4fth_run m4th_run

/* clang-format off */

/**
 * m4th_run: enter m4th interpreter from C.
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in x0 as per arm64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(th_run)
        stp    x29,  lr,   AT(sp, -SZ12)!;      /* make space for C registers on stack */
	.cfi_def_cfa_offset SZ12
	.cfi_offset 29, -SZ12
	.cfi_offset 30, -SZ11
        MOVE(  sp,   x29)                       /* update x29: helps debuggers     */
        stp    x19,  x20,  AT(sp, SZ2);         /* save C registers                */
        stp    x21,  x22,  AT(sp, SZ4);         /* not clobbered: x18              */
        stp    x23,  x24,  AT(sp, SZ6);
        stp    x25,  x26,  AT(sp, SZ8);
        stp    x27,  x28,  AT(sp, SZ10);
        ADDI(  x0,   M4TH_OFF_,  M4TH)          /* load m4th pointer               */
        STOR(  x29,  AT(M4TH, M4TH_OFF_C_REG0)) /* save C stack pointer            */
        LOAD(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* load data   stack pointer       */

        /* if m4th->rstack.curr == 0, no dedicated forth return stack is available */
        /* => use C stack as forth return stack                                    */
        LOAD(  RSTK, AT(M4TH, M4TH_OFF_RSTK))   /* load return stack pointer       */
        JNZ(   RSTK, TO(th_run.stack_done))
LABEL(th_run.stack_c)
        MOVE(  x29,  RSTK)
        STOR(  x29,  AT(M4TH, M4TH_OFF_REND))

LABEL(th_run.stack_done)
        LOAD(  LOCL, AT(M4TH, M4TH_OFF_LOCL))   /* load local variables pointer    */
        LOAD(  IP,   AT(M4TH, M4TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  FTBL, AT(M4TH, M4TH_OFF_FTABLE)) /* load table m4token -> m4func    */
        LOAD(  VM,   AT(M4TH, M4TH_OFF_VM))     /* load VM pointer                 */
        LOAD(  HERE, AT(M4TH, M4TH_OFF_HERE))   /* load HERE pointer               */
        DPOP___DTOP()                           /* load first data   stack element */
        RPOP(  RTOP)                            /* load first return stack element */
        NEXT0()                                 /* enter vm loop                   */
FUNC_RAWEND(th_run)


/** forth vm main loop: fetch m4token instructions and execute them */
FUNC_START(_vm_)
        /* cannot use x0..x8 here: they are used by c-arg-[N] and c-ret-[N] */
        ldrh   w9,     AT(IP), SZt;        /* load m4token of current vm instruction */
                                           /* then increment vm IP                   */
        LOAD(  x9,     AT(FTBL, x9, SZ))   /* load m4func of current vm instruction  */
        br     x9;                         /* execute vm instruction                 */
FUNC_RAWEND(_vm_)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
        RPUSH( RTOP)                            /* save first return stack element */
        DPUSH__DTOP()                           /* save first data   stack element */
        STOR(  HERE, AT(M4TH, M4TH_OFF_HERE))   /* save HERE pointer               */
        STOR(  VM,   AT(M4TH, M4TH_OFF_VM))     /* save VM pointer                 */
        STOR(  FTBL, AT(M4TH, M4TH_OFF_FTABLE)) /* save table m4token -> m4func    */
        STOR(  IP,   AT(M4TH, M4TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  LOCL, AT(M4TH, M4TH_OFF_LOCL))   /* save local variables pointer    */

        /* if m4th->rstack.curr == 0, no forth return stack is available           */
        /* => we used C stack as forth return stack                                */
        LOAD(  REG1, AT(M4TH, M4TH_OFF_RSTK))
        cmp    REG1, IMM(0);
        csel   RSTK, REG1, RSTK, eq;
        STOR(  RSTK, AT(M4TH, M4TH_OFF_RSTK))

        STOR(  DSTK, AT(M4TH, M4TH_OFF_DSTK))   /* save data   stack pointer       */

        LOAD(  x0,   AT(M4TH, M4TH_OFF_EX))     /* load return value = m4th.ex     */
        LOAD(  x1,   AT(M4TH, M4TH_OFF_C_REG0)) /* load C stack pointer            */
        MOVE(  x1,   sp)
        ldp    x19,  x20,  AT(sp, SZ2);         /* load C registers                */
        ldp    x21,  x22,  AT(sp, SZ4);         /* not clobbered: x18              */
        ldp    x23,  x24,  AT(sp, SZ6);
        ldp    x25,  x26,  AT(sp, SZ8);
        ldp    x27,  x28,  AT(sp, SZ10);
        ldp    x29,  lr,   AT(sp), SZ12;
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
        ret;                                    /* return to C                     */
FUNC_RAWEND(bye)


/* pop 0 args, prepare for C function call */
FUNC_START(_c_arg_0_)
        DPUSH__DTOP() /* c-ret-[N] will reload DTOP */
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
        LOAD(  x9, AT(IP), IMM(SZ))    /* post-increment                     */
        RPUSH( lr)                     /* save lr                            */
        LOAD( x10, AT(M4TH, M4TH_OFF_RSTK))
        JZ(   x10, TO(_c_call_.stack_c))

        /* m4th->rstack.curr != 0 thus RSTK points to dedicated memory       */
        /* and sp points to C stack: nothing to fix                          */
        blr    x9;                     /* call C func, overwrites lr         */
        JUMP(  TO(_c_call_.finish))

LABEL(_c_call_.stack_c)
        /* m4th->rstack.curr == 0 thus RSTK points to C stack, below sp:     */
        /* update sp before call, and restore it after call                  */
        and    sp, RSTK,  IMM(-SZ2);   /* set sp = RSTK, then align it       */
        blr    x9;                     /* call C func, overwrites lr         */
        LOAD(  x9, AT(M4TH, M4TH_OFF_C_REG0))
        MOVE(  x9, sp)                 /* reload sp                          */

LABEL(_c_call_.finish)
        RPOP(  lr)                     /* load lr                            */
FUNC_END(_c_call_)


/* push 0 values returned by C function call */
FUNC_START(_c_ret_0_)
        /* reload DTOP because c_arg_* above moved DSTK */
        DPOP___DTOP()
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


/** must be followed by address of native forth code. call it. */
FUNC_START(_call_native_)
        LOAD(  REG0,   AT(IP),   IMM(SZ)) /* post-increment */
        RPUSH(  lr)                    /* save lr                            */
        blr    REG0;                   /* call native code, overwrites lr    */
        RPOP(   lr)                    /* load lr                            */
FUNC_END(_call_native_)


/** pop m4token from dstack and call it. works only for tokens with native_len != -1 */
FUNC_START(_exec_token_)
        ubfx   REG0t,  DTOP_ut, 0, SZt*8;  /* REG0 = m4token                */
        LOAD(  REG0,   AT(FTBL, REG0, SZ)) /* REG0 = m4func                 */
        DPOP___DTOP()                      /* reload dstack top             */
        br     REG0;                       /* tail-call optimization: jump to token */
FUNC_RAWEND(_exec_token_)


/**
 * pop XT from dstack and call it.
 * This function is called from native code with ASM_CALL()
 * => use ASM_RET() to return
 */
FUNC_START(_exec_xt_from_native_)
    RPUSH2(IP, VM)             /* save IP, VM                       */
    RPUSH( lr)                 /* save lr                           */
    LOAD(  VM, AT(M4TH, M4TH_OFF_VM))  /* set VM   = m4th->vm       */
    ADDROF_1M(TO(_exec_xt_from_native_.vm_code), IP)
    /* enter '(vm)' interpreter, let token 'execute' pop dtop = xt  */
    blr    VM;
    RPOP(  lr)                 /* load lr                           */
    RPOP2( VM, IP)             /* load VM, IP                       */
    ASM_RET()
WORD_CODE_ALIGN()
LABEL(_exec_xt_from_native_.vm_code)
    WORD_CODE_TOKENS(execute, _return_to_native_)
FUNC_RAWEND(_exec_xt_from_native_)

/* return to native code */
FUNC_START(_return_to_native_)
        ASM_RET()
FUNC_RAWEND(_return_to_native_)
