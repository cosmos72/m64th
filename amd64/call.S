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

#include "../include/word.mh" /* WORD_CODE_ALIGN(), WORD_CODE_TOKENS() */
#include "asm.mh"

#define m4fth_run m4th_run

/* clang-format off */

/**
 * m4th_run: enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in %rdi as per SYS V amd64 ABI,
 * execute m4th->code.start[0] and subsequent instructions until m4bye is found.
 */
FUNC_START(th_run)
        push   %rbp;                   /* save C registers                */
        push   %rbx;
        push   %r12;
        push   %r13;
        push   %r14;
        push   %r15;
        MOVE(  %rdi,   M4TH)                      /* m                               */
        STOR(  %rsp,   AT(M4TH, M4TH_OFF_C_REG0)) /* save C stack pointer            */
        LOAD(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* load data   stack pointer       */
        LOAD(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))   /* load return stack pointer       */
        LOAD(  IP,     AT(M4TH, M4TH_OFF_IP))     /* load instruction  pointer       */
        LOAD(  FTBL,   AT(M4TH, M4TH_OFF_FTABLE)) /* load table m4token -> m4func    */
        LOAD(  HERE,   AT(M4TH, M4TH_OFF_HERE))   /* load HERE pointer               */
        DPOP(  DTOP)                   /* load first data   stack element */
        RPOP(  RTOP)                   /* load first return stack element */
        MOVE(  IMM(-1),RFFF)           /* set RFFF to -1                  */
        jmp    FUNC_SYM(_vm_)          /* enter vm loop                   */
FUNC_RAWEND(th_run)


/**
 * forth vm main loop: fetch m4token instructions and execute them
 */
FUNC_START(_vm_)
        /* cannot use REG1..REG4: they are used by c-arg-[N] */
        LD_ut(%r11,    AT(IP))         /* load m4token of current vm instruction */
        ADD2(IMM(SZt), IP)             /* increment vm IP                       */
        call *(FTBL, %r11, SZ);        /* execute vm instruction                */
        jmp    FUNC_SYM(_vm_);         /* loop                                  */
FUNC_RAWEND(_vm_)


/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(bye)
        ADD2(  IMM(SZ), IP)                       /* point IP to next instruction    */
        RPUSH( RTOP)                              /* save first return stack element */
        DPUSH( DTOP)                              /* save first data   stack element */
        STOR(  HERE,   AT(M4TH, M4TH_OFF_HERE))   /* save HERE pointer               */
        STOR(  FTBL,   AT(M4TH, M4TH_OFF_FTABLE)) /* save table m4token -> m4func    */
        STOR(  IP,     AT(M4TH, M4TH_OFF_IP))     /* save instruction  pointer       */
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))   /* save return stack pointer       */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* save data   stack pointer       */
        /*
         * TODO: this discards the call stack of compiled forth code
         *       executed since m4th_run(). how to preserve it?
         */
        LOAD(  %rsp,   AT(M4TH, M4TH_OFF_C_REG0))  /* load C stack pointer            */
        LOAD(  %rax,   AT(M4TH, M4TH_OFF_ERR))     /* load return value = m4th.err    */
        pop    %r15;                               /* load C registers                */
        pop    %r14;
        pop    %r13;
        pop    %r12;
        pop    %rbx;
        pop    %rbp;
        ret;                       /* return to C                     */
FUNC_RAWEND(bye)


/* pop 0 args, prepare for C function call */
FUNC_START(_c_arg_0_)
        SUB2(  IMM(SZ),DSTK)
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))   /* save rstk = %rsi (clobbered)  */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* save dstk = %rdi (clobbered)  */
        STOR(  DTOP,   AT(DSTK))                  /* will be reloaded by c-ret-[N] */
FUNC_END(_c_arg_0_)


/* pop 1 arg, prepare it for C function call */
FUNC_START(_c_arg_1_)
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))   /* save rstk = %rsi (clobbered) */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* save dstk = %rdi = C arg1 */
        MOVE(  DTOP, %rdi)                        /* %rdi = C arg 1 */
FUNC_END(_c_arg_1_)


/* pop 2 args, prepare them for C function call */
FUNC_START(_c_arg_2_)
        ADD2(  IMM(SZ), DSTK)
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))   /* save rstk = %rsi = C arg2 */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* save dstk = %rdi = C arg1 */
        MOVE(  DTOP, %rsi)                        /* %rsi = C arg 2 */
        LOAD(  %rdi,   AT(DSTK, -SZ))             /* %rdi = C arg 1 */
FUNC_END(_c_arg_2_)


/* pop 3 args, prepare them for C function call */
FUNC_START(_c_arg_3_)
        ADD2(  IMM(SZ2), DSTK)
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))   /* save rstk = %rsi = C arg2 */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* save dstk = %rdi = C arg1 */
        MOVE(  DTOP, %rdx)                        /* %rdx = C arg 3 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))            /* %rsi = C arg 2 */
        LOAD(  %rdi,   AT(DSTK, -SZ))             /* %rdi = C arg 1 */
FUNC_END(_c_arg_3_)


/* pop 4 args, prepare them for C function call */
FUNC_START(_c_arg_4_)
        ADD2(  IMM(SZ3), DSTK)
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))   /* save rstk = %rsi = C arg2 */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))   /* save dstk = %rdi = C arg1 */
        MOVE(  DTOP, %rcx)                        /* %rcx = C arg 4 */
        LOAD(  %rdx,   AT(DSTK, -SZ3))            /* %rdx = C arg 3 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))            /* %rsi = C arg 2 */
        LOAD(  %rdi,   AT(DSTK, -SZ))             /* %rdi = C arg 1 */
FUNC_END(_c_arg_4_)


/* pop 5 args, prepare them for C function call */
FUNC_START(_c_arg_5_)
        ADD2(  IMM(SZ4), DSTK)
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))    /* save rstk = %rsi = C arg2 */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save dstk = %rdi = C arg1 */
        MOVE(  DTOP, %r8)                          /* %r8  = C arg 5 */
        LOAD(  %rcx,   AT(DSTK, -SZ4))             /* %rcx = C arg 4 */
        LOAD(  %rdx,   AT(DSTK, -SZ3))             /* %rdx = C arg 3 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))             /* %rsi = C arg 2 */
        LOAD(  %rdi,   AT(DSTK, -SZ))              /* %rdi = C arg 1 */
FUNC_END(_c_arg_5_)


/* pop 6 args, prepare them for C function call */
FUNC_START(_c_arg_6_)
        ADD2(  IMM(SZ5), DSTK)
        STOR(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))    /* save rstk = %rsi = C arg2 */
        STOR(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* save dstk = %rdi = C arg1 */
        /* cannot set FTBL = %r9 = C arg 6 now, it is needed by m4f_vm_ */
        LOAD(  %r8,    AT(DSTK, -SZ5))             /* %r8  = C arg 5 */
        LOAD(  %rcx,   AT(DSTK, -SZ4))             /* %rcx = C arg 4 */
        LOAD(  %rdx,   AT(DSTK, -SZ3))             /* %rdx = C arg 3 */
        LOAD(  %rsi,   AT(DSTK, -SZ2))             /* %rsi = C arg 2 */
        LOAD(  %rdi,   AT(DSTK, -SZ))              /* %rdi = C arg 1 */
FUNC_END(_c_arg_6_)


/* must be followed by C function address. call it. */
FUNC_START(_c_call_)
        /* in case C function has 6 args: */
        MOVE(  DTOP,   %r9)                        /* %r9  = C arg 6 = FTBL */
        /* do not restore %rsp, it would clobber our call stack */
        call   *AT(IP);
        ADD2(  IMM(SZ),IP)                         /* skip C function address */
        /* C functions clobber %rdi %rsi %rdx %rcx %r8 %r9 %r10 %r11 */
        /* we must restore only the following ones: */
        LOAD(  DSTK,   AT(M4TH, M4TH_OFF_DSTK))    /* %rdi = DSTK */
        LOAD(  RSTK,   AT(M4TH, M4TH_OFF_RSTK))    /* %rsi = RSTK */
        LOAD(  FTBL,   AT(M4TH, M4TH_OFF_FTABLE))  /* %r9  = FTBL */
        MOVE(  IMM(-1),RFFF)                       /* %r10 = RFFF */
FUNC_END(_c_call_)


/* push 0 values returned by C function call */
FUNC_START(_c_ret_0_)
        /* reload DTOP because c_arg_* above moved DSTK */
        DPOP(  DTOP)
FUNC_END(_c_ret_0_)


/* push 1 value  returned by C function call */
FUNC_START(_c_ret_1_)
        MOVE(  %rax,   DTOP)
FUNC_END(_c_ret_1_)


/* push 2 values returned by C function call */
FUNC_START(_c_ret_2_)
        DPUSH( %rax)
        MOVE(  %rdx,   DTOP)
FUNC_END(_c_ret_2_)


/** pop address of native code from dstack and call it. */
FUNC_START(_exec_native_)
        MOVE(  DTOP, REG1)         /* REG1 = address                */
        DPOP(  DTOP)               /* reload dstack top             */
        jmp    *REG1;              /* tail-call optimization: jump to native code */
FUNC_RAWEND(_exec_native_)


/** pop m4token from dstack and call it. works only for tokens with native_len != -1 */
FUNC_START(_exec_token_)
        /* FIXME this assumes SZt = 2 */
        movzwl DTOPt,  REG3_ut;    /* a = m4token                   */
        DPOP(  DTOP)               /* reload dstack top             */
        jmp    *(FTBL, REG3, SZ);  /* tail-call optimization: jump to token */
FUNC_RAWEND(_exec_token_)


/* return to native code */
FUNC_START(_return_to_native_)
        ADD2(  IMM(SZ),%rsp)       /* skip return address, it's inside _vm_ */
        ASM_RET()                  /* return to caller of _vm_ - usually _exec_xt_from_native_ */
FUNC_RAWEND(_return_to_native_)

