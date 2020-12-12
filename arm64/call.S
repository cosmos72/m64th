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

#define m6fth_run m64th_run

/* clang-format off */

/**
 * m64th_run: enter m64th interpreter from C.
 * save C registers,
 * load m64th registers from struct (m64th*)
 *      passed in x0 as per arm64 ABI,
 * execute m64th->code.start[0] and subsequent instructions until m6bye is found.
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
        ADDI(  x0,   M64TH_OFF_,  M64TH)          /* load m64th pointer               */
        STOR(  x29,  AT(M64TH, M64TH_OFF_C_REG0)) /* save C stack pointer            */
        LOAD(  DSTK, AT(M64TH, M64TH_OFF_DSTK))   /* load data   stack pointer       */

        /* if m64th->rstack.curr == 0, no dedicated forth return stack is available */
        /* => use C stack as forth return stack                                    */
        LOAD(  RSTK, AT(M64TH, M64TH_OFF_RSTK))   /* load return stack pointer       */
        JNZ(   RSTK, TO(th_run.stack_done))
LABEL(th_run.stack_c)
        MOVE(  x29,  RSTK)
        STOR(  x29,  AT(M64TH, M64TH_OFF_REND))
        /* decrease sp to ensure we do not write below it:                         */
        /* required by aarch64 procedure call standard, checked by valgrind        */
        SUB2(IMM(4096),    sp)

LABEL(th_run.stack_done)
        LOAD(  LOCL, AT(M64TH, M64TH_OFF_LSTK))   /* load local variables pointer    */
        LOAD(  IP,   AT(M64TH, M64TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  FTBL, AT(M64TH, M64TH_OFF_FTABLE)) /* load table m6token -> m6func    */
        LOAD(  VM,   AT(M64TH, M64TH_OFF_VM))     /* load VM pointer                 */
        LOAD(  HERE, AT(M64TH, M64TH_OFF_HERE))   /* load HERE pointer               */
        DPOP___DTOP()                           /* load first data   stack element */
        RPOP(  RTOP)                            /* load first return stack element */
        NEXT0()                                 /* enter vm loop                   */
FUNC_RAWEND(th_run)


/** forth vm main loop: fetch m6token instructions and execute them */
FUNC_START(_vm_)
        /* cannot use x0..x8 here: they are used by c-arg-[N] and c-ret-[N] */
        ldrh   w9,     AT(IP), SZt;        /* load m6token of current vm instruction */
                                           /* then increment vm IP                   */
        LOAD(  x9,     AT(FTBL, x9, SZ))   /* load m6func of current vm instruction  */
        br     x9;                         /* execute vm instruction                 */
FUNC_RAWEND(_vm_)

/**
 * exit m64th interpreter and return to C:
 * save m64th registers into struct (m64th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
        DPUSH__DTOP()                           /* save first data   stack element */
        RPUSH( RTOP)                            /* save first return stack element */
        STOR(  HERE, AT(M64TH, M64TH_OFF_HERE))   /* save HERE pointer               */
        STOR(  VM,   AT(M64TH, M64TH_OFF_VM))     /* save VM pointer                 */
        STOR(  FTBL, AT(M64TH, M64TH_OFF_FTABLE)) /* save table m6token -> m6func    */
        STOR(  IP,   AT(M64TH, M64TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  LOCL, AT(M64TH, M64TH_OFF_LSTK))   /* save local variables pointer    */

        /* if m64th->rstack.curr == 0, no forth return stack is available           */
        /* => we used C stack as forth return stack                                */
        LOAD(  REG1, AT(M64TH, M64TH_OFF_RSTK))
        cmp    REG1, IMM(0);
        csel   RSTK, REG1, RSTK, eq;
        STOR(  RSTK, AT(M64TH, M64TH_OFF_RSTK))

        STOR(  DSTK, AT(M64TH, M64TH_OFF_DSTK))   /* save data   stack pointer       */

        LOAD(  x0,   AT(M64TH, M64TH_OFF_EX))     /* load return value = m64th.ex     */
        LOAD(  x1,   AT(M64TH, M64TH_OFF_C_REG0)) /* load C stack pointer            */
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
        LOAD( x10, AT(M64TH, M64TH_OFF_RSTK))

        /* save & restore lr around any call that clobbers it, not to break google-gprof */
        RPUSH( lr)

        JZ(   x10, TO(_c_call_.stack_c))

        /* m64th->rstack.curr != 0 thus RSTK points to dedicated memory       */
        /* and sp points to C stack: nothing to fix                          */
        blr    x9;                     /* call C func, overwrites lr         */
        JUMP(  TO(_c_call_.done))

LABEL(_c_call_.stack_c)
        /* m64th->rstack.curr == 0 thus RSTK points to C stack, possibly below sp: */
        /* update sp before call, and restore it after call                  */
        AND3(  RSTK,IMM(-SZ2), sp)     /* set sp = RSTK, then align it       */
        blr    x9;                     /* call C func, overwrites lr         */
        /* decrease sp to ensure we do not write below it                    */
        SUB2(IMM(4096),   sp)

LABEL(_c_call_.done)
        RPOP(  lr)
        NEXT0()
FUNC_RAWEND(_c_call_)


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


/** must be followed by address of native ASM code. call it. */
FUNC_START(_call_asm_)
        LOAD(  REG0,   AT(IP),   IMM(SZ)) /* post-increment                    */
        /* save & restore lr around any call that clobbers it, not to break google-gprof */
        RPUSH( lr)
        blr    REG0;
        RPOP(  lr)
        NEXT0()
FUNC_RAWEND(_call_asm_)


/** pop m6token from dstack and call it. works only for tokens with asm_len != -1 */
FUNC_START(_exec_token_)
        ubfx   REG0t,  DTOP_ut, 0, SZt*8;  /* REG0 = m6token                 */
        LOAD(  REG0,   AT(FTBL, REG0, SZ)) /* REG0 = m6func                  */
        DPOP___DTOP()                      /* reload dstack top              */
        br     REG0;                       /* tail-call optimization: jump to token */
        /* the token will return to '(vm)' when done                         */
FUNC_RAWEND(_exec_token_)


/**
 * pop XT from dstack and use 'catch' to run it.
 * This function is called *only* from native ASM code with ASM_CALL()
 * => it must use ASM_RET() to return when finished.
 */
FUNC_START(_asm_vm_catch_)
        ADDROF_1M(TO(_asm_vm_catch_.tokens), REG0) /* @ = tokens to execute */

        JUMP(  TO(_asm_vm_execute_.reg0))
FUNC_RAWEND(_asm_vm_catch_)


/**
 * pop XT from dstack and execute it.
 * This function is called *only* from native ASM code with ASM_CALL()
 * => it must use ASM_RET() to return when finished.
 */
FUNC_START(_asm_vm_execute_)
        ADDROF_1M(TO(_asm_vm_execute_.tokens), REG0) /* @ = tokens to execute */

LABEL(_asm_vm_execute_.reg0)
        /**
         * no need to save lr here: every place that clobbers lr
         * is in charge of saving & restoring it, not to break google-gprof
         */
        RPUSH2(RTOP, IP)           /* save RTOP, IP                     */
        MOVE(  VM,   RTOP)         /* save VM                           */
        LOAD(  VM, AT(M64TH, M64TH_OFF_VM)) /* set VM = m64th->vm          */
        MOVE(  REG0, IP)                  /* set IP = tokens to execute */
        /* enter '(vm)' interpreter, let token 'execute' pop dtop = xt  */
        JUMP_REG(VM)
        /* '(vm)' interpreter will execute '_vm_return_to_asm_' when done  */
        /* which reloads the registers saved above then returns to ASM  */
FUNC_RAWEND(_asm_vm_execute_)


/* return from VM to native ASM code. it's the bottom half of _asm_vm_execute_ */
FUNC_START(_vm_return_to_asm_)
        /**
         * no need to restore lr here: every place that clobbers lr
         * is in charge of saving & restoring it, not to break google-gprof
         */
        MOVE(  RTOP, VM)           /* load VM                           */
        RPOP2( IP,   RTOP)         /* load IP, RTOP                     */
        ASM_RET()                  /* return to ASM                     */
FUNC_RAWEND(_vm_return_to_asm_)


WORD_CODE_ALIGN()
LABEL(_asm_vm_catch_.tokens)
        WORD_CODE_TOKENS(_catch_beg_, _catch_end_, _vm_return_to_asm_)

WORD_CODE_ALIGN()
LABEL(_asm_vm_execute_.tokens)
        WORD_CODE_TOKENS(execute, _vm_return_to_asm_)
