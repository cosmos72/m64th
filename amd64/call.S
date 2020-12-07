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
#include "../include/word.mh" /* WORD_CODE_ALIGN(), WORD_CODE_TOKENS() */

#define m4fth_run m4th_run

/* clang-format off */

/**
 * m4th_run: enter m4th interpreter from C.
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in %rdi as per SYS V amd64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(th_run)
        push   %rbp;                              /* save C registers                */
        push   %rbx;
        push   %r12;
        push   %r13;
        push   %r14;
        push   %r15;
        ADDI(  %rdi,   M4TH_OFF_,  M4TH)          /* load m4th pointer               */
        STOR(  %rsp,   AT(M4TH, M4TH_OFF_C_REG0)) /* save C stack pointer            */
        LOAD(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* load data   stack pointer       */

        /* changing %rsp to different stack breaks google-pprof: */
        /* do it only if requested i.e. m4th->rstack.curr != 0   */
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_RSTK))   /* load return stack pointer       */
        test   REG1,   REG1;
        cmovne REG1,   RSTK;
        JNZ(   REG1,   TO(th_run.stack_done))
LABEL(th_run.stack_c)
        MOVE(  RSTK,   AT(M4TH, M4TH_OFF_REND))

LABEL(th_run.stack_done)
        LOAD(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))   /* load local variables pointer    */
        LOAD(  IP,     AT(M4TH, M4TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  FTBL,   AT(M4TH, M4TH_OFF_FTABLE)) /* load table m4token -> m4func    */
        LOAD(  VM,     AT(M4TH, M4TH_OFF_VM))     /* load VM pointer                 */
        LOAD(  HERE,   AT(M4TH, M4TH_OFF_HERE))   /* load HERE pointer               */
        DPOP___DTOP()                             /* load first data   stack element */
        RPOP(  RTOP)                              /* load first return stack element */
        RPUSH(IMM(-1)) RPOP(RFFF)                 /* set RFFF = -1                   */
        NEXT0()                                   /* enter vm loop                   */
FUNC_RAWEND(th_run)


/** forth vm main loop: fetch m4token instructions and execute them */
FUNC_START(_vm_)
        /* cannot use REG1..REG4: they are used by c-arg-[N] */
        LD_ut( REG0,   AT(IP))         /* load m4token of current vm instruction */
        ADD2(IMM(SZt), IP)             /* increment vm IP                        */
        jmp  *(FTBL,   REG0,   SZ);    /* execute vm instruction                 */
FUNC_RAWEND(_vm_)


/**
 * exit m4th interpreter and return to C.
 * 1. save local variables to RSTK
 * 2. save m4th registers into struct (m4th*)
 * 3. load C registers
 * 4. return to C
 */
FUNC_START(bye)
        DPUSH__DTOP()                             /* save first data   stack element */
        RPUSH( RTOP)                              /* save first return stack element */
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))   /* save local variables pointer    */
        STOR(  IP,     AT(M4TH, M4TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  FTBL,   AT(M4TH, M4TH_OFF_FTABLE)) /* save table m4token -> m4func    */
        STOR(  VM,     AT(M4TH, M4TH_OFF_VM  ))   /* save VM   address               */
        STOR(  HERE,   AT(M4TH, M4TH_OFF_HERE))   /* save HERE pointer               */

        LOAD(  REG1,   AT(M4TH, M4TH_OFF_RSTK))   /* load return stack pointer       */
        test   REG1,   REG1;
        /* if m4th->rstack.curr != 0, forth return stack is dedicated memory         */
        /* then save RSTK AT(M4TH, M4TH_OFF_RSTK)                                    */
        /* else write zero AT(M4TH, M4TH_OFF_REND)                                   */
        ADDI(  M4TH,   M4TH_OFF_RSTK, REG2)       /* RSTK should be saved here       */
        ADDI(  M4TH,   M4TH_OFF_REND, REG3)       /* REND should be saved here       */
        cmovnz RSTK,   REG1;
        cmovnz REG2,   REG3;
        STOR(  REG1,   AT(REG3))       /* save RSTK, or zero AT(M4TH, M4TH_OFF_REND) */

        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* save data   stack pointer       */
        LOAD(  %rsp,   AT(M4TH, M4TH_OFF_C_REG0)) /* load C stack pointer            */
        LOAD(  %rax,   AT(M4TH, M4TH_OFF_EX))     /* load return value = m4th.ex     */
        pop    %r15;                              /* load C registers                */
        pop    %r14;
        pop    %r13;
        pop    %r12;
        pop    %rbx;
        pop    %rbp;
        ret;                                      /* return to C                     */
FUNC_RAWEND(bye)


/* pop 0 args, prepare for C function call */
FUNC_START(_c_arg_0_)
        SUB2(  IMM(SZ),DSTK)
        /* save DSTK, LOCL to m4th. helps if C calls back into forth                 */
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* save LOCL = %r9  (clobbered)   */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save DSTK = %rsi (clobbered)   */
        STOR(  DTOP,   AT(DSTK))                   /* will be reloaded by c-ret-[N]  */
FUNC_END(_c_arg_0_)


/* pop 1 arg, prepare it for C function call */
FUNC_START(_c_arg_1_)
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* save LOCL = %r9  (clobbered)   */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save DSTK = %rsi (clobbered)   */
        MOVE(  DTOP,   %rdi)                       /* %rdi = C arg 1                 */
FUNC_END(_c_arg_1_)


/* pop 2 args, prepare them for C function call */
FUNC_START(_c_arg_2_)
        ADD2(  IMM(SZ), DSTK)
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* save LOCL = %r9  (clobbered)   */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save DSTK = %rsi (clobbered)   */
        LOAD(  %rdi,   AT(DSTK, -SZ))              /* %rdi = C arg 1                 */
        MOVE(  DTOP,   %rsi)                       /* %rsi = C arg 2 (clobbers DSTK) */
FUNC_END(_c_arg_2_)


/* pop 3 args, prepare them for C function call */
FUNC_START(_c_arg_3_)
        ADD2(  IMM(SZ2), DSTK)
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* save LOCL = %r9  (clobbered)   */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save DSTK = %rsi (clobbered)   */
        MOVE(  DTOP,   %rdx)                       /* %rdx = C arg 3                 */
        LOAD(  %rdi,   AT(DSTK, -SZ))              /* %rdi = C arg 1                 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))             /* %rsi = C arg 2 (clobbers DSTK) */
FUNC_END(_c_arg_3_)


/* pop 4 args, prepare them for C function call */
FUNC_START(_c_arg_4_)
        ADD2(  IMM(SZ3), DSTK)
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* save LOCL = %r9  (clobbered)   */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save DSTK = %rsi (clobbered)   */
        MOVE(  DTOP,   %rcx)                       /* %rcx = C arg 4                 */
        LOAD(  %rdx,   AT(DSTK, -SZ3))             /* %rdx = C arg 3                 */
        LOAD(  %rdi,   AT(DSTK, -SZ))              /* %rdi = C arg 1                 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))             /* %rsi = C arg 2 (clobbers DSTK) */
FUNC_END(_c_arg_4_)


/* pop 5 args, prepare them for C function call */
FUNC_START(_c_arg_5_)
        ADD2(  IMM(SZ4), DSTK)
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* save LOCL = %r9  (clobbered)   */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save DSTK = %rsi (clobbered)   */
        LOAD(  %rcx,   AT(DSTK, -SZ4))             /* %rcx = C arg 4                 */
        LOAD(  %rdx,   AT(DSTK, -SZ3))             /* %rdx = C arg 3                 */
        LOAD(  %rdi,   AT(DSTK, -SZ))              /* %rdi = C arg 1                 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))             /* %rsi = C arg 2 (clobbers DSTK) */
FUNC_END(_c_arg_5_)


/* pop 6 args, prepare them for C function call */
FUNC_START(_c_arg_6_)
        ADD2(  IMM(SZ5), DSTK)
        STOR(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* save LOCL = %r9  (clobbered)   */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save DSTK = %rsi (clobbered)   */
        MOVE(  DTOP,   %r9)                        /* %r9  = C arg 6                 */
        LOAD(  %r8,    AT(DSTK, -SZ5))             /* %r8  = C arg 5                 */
        LOAD(  %rcx,   AT(DSTK, -SZ4))             /* %rcx = C arg 4                 */
        LOAD(  %rdx,   AT(DSTK, -SZ3))             /* %rdx = C arg 3                 */
        LOAD(  %rdi,   AT(DSTK, -SZ))              /* %rdi = C arg 1                 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))             /* %rsi = C arg 2 (clobbers DSTK) */
FUNC_END(_c_arg_6_)


/* must be followed by C function address. call it. */
FUNC_START(_c_call_)

        LOAD(  REG0,   AT(M4TH, M4TH_OFF_RSTK))
        JZ(    REG0,   TO(_c_call_.stack_c))

        /* m4th->rstack.curr != 0 thus forth RSTK i.e. %rsp points to private memory:*/
        /* => update %rsp to point to C stack before call, and restore it after call */
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))
        LOAD(  %rsp,   AT(M4TH, M4TH_OFF_C_REG0))
        call   *AT(IP);
        /* C functions may clobber m4th.c_regs[0] if they call back into forth       */
        /* => restore m4th.c_regs[0] = C stack = %rsp now                            */
        STOR(  %rsp,   AT(M4TH, M4TH_OFF_C_REG0))
        LOAD(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))
        JUMP(  TO(_c_call_.finish))

LABEL(_c_call_.stack_c)
        /* m4th->rstack.curr == 0 thus forth RSTK i.e. %rsp points to C stack:       */
        /* per x86-64 SYSV ABI, we must align %rsp to 16 bytes                       */
        MOVE(  %rsp,   REG0)
        SUB2(IMM(SZ),  %rsp)
        AND2(IMM(-SZ2),%rsp)
        STOR(  REG0,   AT(%rsp))
        call   *AT(IP);
        /* restore %rsp */
        LOAD(  %rsp,   AT(%rsp))

LABEL(_c_call_.finish)
        ADD2(  IMM(SZ),IP)                         /* skip C function address        */
        /*
         * C functions can clobber %rdi %rsi %rdx %rcx %r8 %r9 %r10 %r11
         * i.e our REG1 DSTK REG3 REG2 REG4 LOCL REG0 RFFF
         * and write their results in %rax %rdx
         * i.e. our DTOP REG3
         * we need to restore only: DSTK LOCL RFFF
         */
        LOAD(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* reload DSTK = %rsi             */
        LOAD(  LOCL,   AT(M4TH, M4TH_OFF_LSTK))    /* reload LOCL = %r9              */
        RPUSH(IMM(-1)) RPOP(RFFF)                  /* set RFFF = -1                  */
FUNC_END(_c_call_)


/* push 0 values returned by C function call */
FUNC_START(_c_ret_0_)
        /* reload DTOP from DSTK */
        DPOP___DTOP()
FUNC_END(_c_ret_0_)


/* push 1 value  returned by C function call */
FUNC_START(_c_ret_1_)
        /*MOVE(  %rax,   DTOP)*/                   /* result is already in DTOP = %rax */
FUNC_END(_c_ret_1_)


/* push 2 values returned by C function call */
FUNC_START(_c_ret_2_)
        DPUSH( %rax)
        MOVE(  %rdx,   DTOP)
FUNC_END(_c_ret_2_)


/** must be followed by address of native forth code. call it. */
FUNC_START(_call_native_)
        LOAD(  REG1,   AT(IP))
        ADD2(IMM(SZ),  IP)         /* skip native function address                */
        RPUSH(  VM)                /* native code ends with ASM_RET(),            */
                                   /* which pops address at %rsp and jumps to it  */
        jmp    *REG1;              /* tail-call optimization: jump to native code */
FUNC_RAWEND(_call_native_)


/** pop m4token from dstack and call it. works only for tokens with native_len != -1 */
FUNC_START(_exec_token_)
        LD_ut( REG3,   DTOPt)      /* c = m4token                           */
        DPOP___DTOP()              /* reload dstack top                     */
        jmp    *(FTBL, REG3, SZ);  /* tail-call optimization: jump to token */
FUNC_RAWEND(_exec_token_)


/**
 * pop XT from dstack and call it.
 * This function is called from native code with ASM_CALL()
 * => use ASM_RET() to return
 */
FUNC_START(_exec_xt_from_native_)
    RPUSH( IP)                 /* save IP                           */
    RPUSH( VM)                 /* save VM                           */
    LOAD(  VM, AT(M4TH, M4TH_OFF_VM))  /* set VM   = m4th->vm       */
    ADDROF_1M(TO(_exec_xt_from_native_.vm_code), IP)

    /* enter '(vm)' interpreter, let token 'execute' pop dtop = xt  */
    /* pushes return address to stack,                              */
    /* it will be popped by (return-to-native)                      */
    call  *VM;

    RPOP(  VM)                 /* load VM                           */
    RPOP(  IP)                 /* load IP                           */
    ASM_RET()
WORD_CODE_ALIGN()
LABEL(_exec_xt_from_native_.vm_code)
    WORD_CODE_TOKENS(execute, _asm_exit_)
FUNC_RAWEND(_exec_xt_from_native_)
