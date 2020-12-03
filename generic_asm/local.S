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

/* clang-format off */

#ifndef Ln
#define Ln 0 /* number of local variables stored in registers L0...LF */
#endif

#ifdef L0
#define L0__to_DTOP()  MOVL(   L0,     DTOP)
#define DTOP_to__L0()  MOVL(   DTOP,   L0)
#else
#define L0__to_DTOP()  LOAD(   DTOP,   AT(LOCL))
#define DTOP_to__L0()  STOR(   DTOP,   AT(LOCL))
#endif

#ifdef L1
#define L1__to_DTOP()  MOVL(   L1,     DTOP)
#define DTOP_to__L1()  MOVL(   DTOP,   L1)
#else
#define L1__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ))
#define DTOP_to__L1()  STOR(   DTOP,   AT(LOCL, SZ))
#endif

#ifdef L2
#define L2__to_DTOP()  MOVL(   L2,     DTOP)
#define DTOP_to__L2()  MOVL(   DTOP,   L2)
#else
#define L2__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ2))
#define DTOP_to__L2()  STOR(   DTOP,   AT(LOCL, SZ2))
#endif

#ifdef L3
#define L3__to_DTOP()  MOVL(   L3,     DTOP)
#define DTOP_to__L3()  MOVL(   DTOP,   L3)
#else
#define L3__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ3))
#define DTOP_to__L3()  STOR(   DTOP,   AT(LOCL, SZ3))
#endif

#ifdef L4
#define L4__to_DTOP()  MOVL(   L4,     DTOP)
#define DTOP_to__L4()  MOVL(   DTOP,   L4)
#else
#define L4__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ4))
#define DTOP_to__L4()  STOR(   DTOP,   AT(LOCL, SZ4))
#endif

#ifdef L5
#define L5__to_DTOP()  MOVL(   L5,     DTOP)
#define DTOP_to__L5()  MOVL(   DTOP,   L5)
#else
#define L5__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ5))
#define DTOP_to__L5()  STOR(   DTOP,   AT(LOCL, SZ5))
#endif

#ifdef L6
#define L6__to_DTOP()  MOVL(   L6,     DTOP)
#define DTOP_to__L6()  MOVL(   DTOP,   L6)
#else
#define L6__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ6))
#define DTOP_to__L6()  STOR(   DTOP,   AT(LOCL, SZ6))
#endif

#ifdef L7
#define L7__to_DTOP()  MOVL(   L7,     DTOP)
#define DTOP_to__L7()  MOVL(   DTOP,   L7)
#else
#define L7__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ7))
#define DTOP_to__L7()  STOR(   DTOP,   AT(LOCL, SZ7))
#endif

#ifdef L8
#define L8__to_DTOP()  MOVL(   L8,     DTOP)
#define DTOP_to__L8()  MOVL(   DTOP,   L8)
#else
#define L8__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ8))
#define DTOP_to__L8()  STOR(   DTOP,   AT(LOCL, SZ8))
#endif

#ifdef L9
#define L9__to_DTOP()  MOVL(   L9,     DTOP)
#define DTOP_to__L9()  MOVL(   DTOP,   L9)
#else
#define L9__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ9))
#define DTOP_to__L9()  STOR(   DTOP,   AT(LOCL, SZ9))
#endif

#ifdef LA
#define LA__to_DTOP()  MOVL(   LA,     DTOP)
#define DTOP_to__LA()  MOVL(   DTOP,   LA)
#else
#define LA__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ10))
#define DTOP_to__LA()  STOR(   DTOP,   AT(LOCL, SZ10))
#endif

#ifdef LB
#define LB__to_DTOP()  MOVL(   LB,     DTOP)
#define DTOP_to__LB()  MOVL(   DTOP,   LB)
#else
#define LB__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ11))
#define DTOP_to__LB()  STOR(   DTOP,   AT(LOCL, SZ11))
#endif

#ifdef LC
#define LC__to_DTOP()  MOVL(   LC,     DTOP)
#define DTOP_to__LC()  MOVL(   DTOP,   LC)
#else
#define LC__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ12))
#define DTOP_to__LC()  STOR(   DTOP,   AT(LOCL, SZ12))
#endif

#ifdef LD
#define LD__to_DTOP()  MOVL(   LD,     DTOP)
#define DTOP_to__LD()  MOVL(   DTOP,   LD)
#else
#define LD__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ13))
#define DTOP_to__LD()  STOR(   DTOP,   AT(LOCL, SZ13))
#endif

#ifdef LE
#define LE__to_DTOP()  MOVL(   LE,     DTOP)
#define DTOP_to__LE()  MOVL(   DTOP,   LE)
#else
#define LE__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ14))
#define DTOP_to__LE()  STOR(   DTOP,   AT(LOCL, SZ14))
#endif

#ifdef LF
#define LF__to_DTOP()  MOVL(   LF,     DTOP)
#define DTOP_to__LF()  MOVL(   DTOP,   LF)
#else
#define LF__to_DTOP()  LOAD(   DTOP,   AT(LOCL, SZ15))
#define DTOP_to__LF()  STOR(   DTOP,   AT(LOCL, SZ15))
#endif

FUNC_START(_l0_) /* (l0) ( -- x ) push 0-th local variable to dstack */
        DPUSH__DTOP()
        L0__to_DTOP()
FUNC_END(_l0_)
FUNC_START(_drop_l0_) /* (drop&l0) ( y -- x ) drop, then push 0-th local variable to dstack */
        L0__to_DTOP()
FUNC_END(_drop_l0_)
FUNC_START(_to_l0_) /* (>l0) ( x -- ) store dstack top to 1-st local variable */
        DTOP_to__L0()
        DPOP___DTOP()
FUNC_END(_to_l0_)
FUNC_START(_dup_to_l0_) /* (dup>l0) ( x -- x ) copy dstack top to 1-st local variable */
        DTOP_to__L0()
FUNC_END(_dup_to_l0_)


FUNC_START(_l1_) /* (l1) ( -- x ) push 1-st local variable to dstack */
        DPUSH__DTOP()
        L1__to_DTOP()
FUNC_END(_l1_)
FUNC_START(_drop_l1_) /* (drop&l1) ( y -- x ) drop, then push 1-st local variable to dstack */
        L1__to_DTOP()
FUNC_END(_drop_l1_)
FUNC_START(_to_l1_) /* (>l1) ( x -- ) store dstack top to 1-st local variable */
        DTOP_to__L1()
        DPOP___DTOP()
FUNC_END(_to_l1_)
FUNC_START(_dup_to_l1_) /* (dup>l1) ( x -- x ) copy dstack top to 1-st local variable */
        DTOP_to__L1()
FUNC_END(_dup_to_l1_)


FUNC_START(_l2_) /* (l2) ( -- x ) push 2-nd local variable to dstack */
        DPUSH__DTOP()
        L2__to_DTOP()
FUNC_END(_l2_)
FUNC_START(_drop_l2_) /* (drop&l2) ( y -- x ) drop, then push 2-nd local variable to dstack */
        L2__to_DTOP()
FUNC_END(_drop_l2_)
FUNC_START(_to_l2_) /* (>l2) ( x -- ) store dstack top to 2-nd local variable */
        DTOP_to__L2()
        DPOP___DTOP()
FUNC_END(_to_l2_)
FUNC_START(_dup_to_l2_) /* (dup>l2) ( x -- x ) copy dstack top to 2-nd local variable */
        DTOP_to__L2()
FUNC_END(_dup_to_l2_)


FUNC_START(_l3_) /* (l3) ( -- x ) push 3-rd local variable to dstack */
        DPUSH__DTOP()
        L3__to_DTOP()
FUNC_END(_l3_)
FUNC_START(_drop_l3_) /* (drop&l3) ( y -- x ) drop, then push 3-rd local variable to dstack */
        L3__to_DTOP()
FUNC_END(_drop_l3_)
FUNC_START(_to_l3_) /* (>l3) ( x -- ) store dstack top to 3-rd local variable */
        DTOP_to__L3()
        DPOP___DTOP()
FUNC_END(_to_l3_)
FUNC_START(_dup_to_l3_) /* (dup>l3) ( x -- x ) copy dstack top to 3-rd local variable */
        DTOP_to__L3()
FUNC_END(_dup_to_l3_)


FUNC_START(_l4_) /* (l4) ( -- x ) push 4-th local variable to dstack */
        DPUSH__DTOP()
        L4__to_DTOP()
FUNC_END(_l4_)
FUNC_START(_drop_l4_) /* (drop&l4) ( y -- x ) drop, then push 4-th local variable to dstack */
        L4__to_DTOP()
FUNC_END(_drop_l4_)
FUNC_START(_to_l4_) /* (>l4) ( x -- ) store dstack top to 4-th local variable */
        DTOP_to__L4()
        DPOP___DTOP()
FUNC_END(_to_l4_)
FUNC_START(_dup_to_l4_) /* (dup>l4) ( x -- x ) copy dstack top to 4-th local variable */
        DTOP_to__L4()
FUNC_END(_dup_to_l4_)


FUNC_START(_l5_) /* (l5) ( -- x ) push 5-th local variable to dstack */
        DPUSH__DTOP()
        L5__to_DTOP()
FUNC_END(_l5_)
FUNC_START(_drop_l5_) /* (drop&l5) ( y -- x ) drop, then push 5-th local variable to dstack */
        L5__to_DTOP()
FUNC_END(_drop_l5_)
FUNC_START(_to_l5_) /* (>l5) ( x -- ) store dstack top to 5-th local variable */
        DTOP_to__L5()
        DPOP___DTOP()
FUNC_END(_to_l5_)
FUNC_START(_dup_to_l5_) /* (dup>l5) ( x -- x ) copy dstack top to 5-th local variable */
        DTOP_to__L5()
FUNC_END(_dup_to_l5_)


FUNC_START(_l6_) /* (l6) ( -- x ) push 6-th local variable to dstack */
        DPUSH__DTOP()
        L6__to_DTOP()
FUNC_END(_l6_)
FUNC_START(_drop_l6_) /* (drop&l6) ( y -- x ) drop, then push 6-th local variable to dstack */
        L6__to_DTOP()
FUNC_END(_drop_l6_)
FUNC_START(_to_l6_) /* (>l6) ( x -- ) store dstack top to 6-th local variable */
        DTOP_to__L6()
        DPOP___DTOP()
FUNC_END(_to_l6_)
FUNC_START(_dup_to_l6_) /* (dup>l6) ( x -- x ) copy dstack top to 6-th local variable */
        DTOP_to__L6()
FUNC_END(_dup_to_l6_)


FUNC_START(_l7_) /* (l7) ( -- x ) push 7-th local variable to dstack */
        DPUSH__DTOP()
        L7__to_DTOP()
FUNC_END(_l7_)
FUNC_START(_drop_l7_) /* (drop&l7) ( y -- x ) drop, then push 7-th local variable to dstack */
        L7__to_DTOP()
FUNC_END(_drop_l7_)
FUNC_START(_to_l7_) /* (>l7) ( x -- ) store dstack top to 7-th local variable */
        DTOP_to__L7()
        DPOP___DTOP()
FUNC_END(_to_l7_)
FUNC_START(_dup_to_l7_) /* (dup>l7) ( x -- x ) copy dstack top to 7-th local variable */
        DTOP_to__L7()
FUNC_END(_dup_to_l7_)


FUNC_START(_l8_) /* (l8) ( -- x ) push 8-th local variable to dstack */
        DPUSH__DTOP()
        L8__to_DTOP()
FUNC_END(_l8_)
FUNC_START(_drop_l8_) /* (drop&l8) ( y -- x ) drop, then push 8-th local variable to dstack */
        L8__to_DTOP()
FUNC_END(_drop_l8_)
FUNC_START(_to_l8_) /* (>l8) ( x -- ) store dstack top to 8-th local variable */
        DTOP_to__L8()
        DPOP___DTOP()
FUNC_END(_to_l8_)
FUNC_START(_dup_to_l8_) /* (dup>l8) ( x -- x ) copy dstack top to 8-th local variable */
        DTOP_to__L8()
FUNC_END(_dup_to_l8_)


FUNC_START(_l9_) /* (l9) ( -- x ) push 9-th local variable to dstack */
        DPUSH__DTOP()
        L9__to_DTOP()
FUNC_END(_l9_)
FUNC_START(_drop_l9_) /* (drop&l9) ( y -- x ) drop, then push 9-th local variable to dstack */
        L9__to_DTOP()
FUNC_END(_drop_l9_)
FUNC_START(_to_l9_) /* (>l9) ( x -- ) store dstack top to 9-th local variable */
        DTOP_to__L9()
        DPOP___DTOP()
FUNC_END(_to_l9_)
FUNC_START(_dup_to_l9_) /* (dup>l9) ( x -- x ) copy dstack top to 9-th local variable */
        DTOP_to__L9()
FUNC_END(_dup_to_l9_)


FUNC_START(_la_) /* (la) ( -- x ) push 10-th local variable to dstack */
        DPUSH__DTOP()
        LA__to_DTOP()
FUNC_END(_la_)
FUNC_START(_drop_la_) /* (drop&la) ( y -- x ) drop, then push 10-th local variable to dstack */
        LA__to_DTOP()
FUNC_END(_drop_la_)
FUNC_START(_to_la_) /* (>la) ( x -- ) store dstack top to 10-th local variable */
        DTOP_to__LA()
        DPOP___DTOP()
FUNC_END(_to_la_)
FUNC_START(_dup_to_la_) /* (dup>la) ( x -- x ) copy dstack top to 10-th local variable */
        DTOP_to__LA()
FUNC_END(_dup_to_la_)


FUNC_START(_lb_) /* (lb) ( -- x ) push 11-th local variable to dstack */
        DPUSH__DTOP()
        LB__to_DTOP()
FUNC_END(_lb_)
FUNC_START(_drop_lb_) /* (drop&lb) ( y -- x ) drop, then push 11-th local variable to dstack */
        LB__to_DTOP()
FUNC_END(_drop_lb_)
FUNC_START(_to_lb_) /* (>lb) ( x -- ) store dstack top to 11-th local variable */
        DTOP_to__LB()
        DPOP___DTOP()
FUNC_END(_to_lb_)
FUNC_START(_dup_to_lb_) /* (dup>lb) ( x -- x ) copy dstack top to 11-th local variable */
        DTOP_to__LB()
FUNC_END(_dup_to_lb_)


FUNC_START(_lc_) /* (lc) ( -- x ) push 12-th local variable to dstack */
        DPUSH__DTOP()
        LC__to_DTOP()
FUNC_END(_lc_)
FUNC_START(_drop_lc_) /* (drop&lc) ( y -- x ) drop, then push 12-th local variable to dstack */
        LC__to_DTOP()
FUNC_END(_drop_lc_)
FUNC_START(_to_lc_) /* (>lc) ( x -- ) store dstack top to 12-th local variable */
        DTOP_to__LC()
        DPOP___DTOP()
FUNC_END(_to_lc_)
FUNC_START(_dup_to_lc_) /* (dup>lc) ( x -- x ) copy dstack top to 12-th local variable */
        DTOP_to__LC()
FUNC_END(_dup_to_lc_)


FUNC_START(_ld_) /* (ld) ( -- x ) push 13-th local variable to dstack */
        DPUSH__DTOP()
        LD__to_DTOP()
FUNC_END(_ld_)
FUNC_START(_drop_ld_) /* (drop&ld) ( y -- x ) drop, then push 13-th local variable to dstack */
        LD__to_DTOP()
FUNC_END(_drop_ld_)
FUNC_START(_to_ld_) /* (>ld) ( x -- ) store dstack top to 13-th local variable */
        DTOP_to__LD()
        DPOP___DTOP()
FUNC_END(_to_ld_)
FUNC_START(_dup_to_ld_) /* (dup>ld) ( x -- x ) copy dstack top to 13-th local variable */
        DTOP_to__LD()
FUNC_END(_dup_to_ld_)


FUNC_START(_le_) /* (le) ( -- x ) push 14-th local variable to dstack */
        DPUSH__DTOP()
        LE__to_DTOP()
FUNC_END(_le_)
FUNC_START(_drop_le_) /* (drop&le) ( y -- x ) drop, then push 14-th local variable to dstack */
        LE__to_DTOP()
FUNC_END(_drop_le_)
FUNC_START(_to_le_) /* (>le) ( x -- ) store dstack top to 14-th local variable */
        DTOP_to__LE()
        DPOP___DTOP()
FUNC_END(_to_le_)
FUNC_START(_dup_to_le_) /* (dup>le) ( x -- x ) copy dstack top to 14-th local variable */
        DTOP_to__LE()
FUNC_END(_dup_to_le_)


FUNC_START(_lf_) /* (lf) ( -- x ) push 15-th local variable to dstack */
        DPUSH__DTOP()
        LF__to_DTOP()
FUNC_END(_lf_)
FUNC_START(_drop_lf_) /* (drop&lf) ( y -- x ) drop, then push 15-th local variable to dstack */
        LF__to_DTOP()
FUNC_END(_drop_lf_)
FUNC_START(_to_lf_) /* (>lf) ( x -- ) store dstack top to 15-th local variable */
        DTOP_to__LF()
        DPOP___DTOP()
FUNC_END(_to_lf_)
FUNC_START(_dup_to_lf_) /* (dup>lf) ( x -- x ) copy dstack top to 15-th local variable */
        DTOP_to__LF()
FUNC_END(_dup_to_lf_)


/* (lx) ( -- x ) followed by T(N), push N-th local variable to dstack. N must be >= Ln */
FUNC_START(_lx_)
        LD_ut( REG1,   AT(IP))
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, REG1, SZ))
        ADD2(IMM(SZt), IP)
FUNC_END(_lx_)
/* (drop&lx) ( y -- x ) followed by T(N), drop, then push N-th local variable to dstack. N must be >= Ln */
FUNC_START(_drop_lx_)
        LD_ut( REG1,   AT(IP))
        LOAD(  DTOP,   AT(LOCL, REG1, SZ))
        ADD2(IMM(SZt), IP)
FUNC_END(_drop_lx_)
/* (lx) ( x -- ) followed by T(N), store dstack top to N-th local variable. N must be >= Ln */
FUNC_START(_to_lx_)
        LD_ut( REG1,   AT(IP))
        STOR(  DTOP,   AT(LOCL, REG1, SZ))
        DPOP___DTOP()
        ADD2(IMM(SZt), IP)
FUNC_END(_to_lx_)
/* (dup>lx) ( x -- x ) followed by T(N), copy dstack top to N-th local variable. N must be >= Ln */
FUNC_START(_dup_to_lx_)
        LD_ut( REG1,   AT(IP))
        STOR(  DTOP,   AT(LOCL, REG1, SZ))
        ADD2(IMM(SZt), IP)
FUNC_END(_dup_to_lx_)


/* (locals-enter) ( R: -- locl ln-1 ... l1 l0 n ) followed by T(N), reserve space for N local variables */
FUNC_START(_locals_enter_)
#ifdef __aarch64__
        LD_ut( REG2,   AT(IP), SZt)        /* b = n; IP += SZt i.e. skip T(n) */
#else
        LD_ut( REG2,   AT(IP))             /* b = n                           */
        ADD2(IMM(SZt), IP)                 /* IP += SZt i.e. skip T(n)        */
#endif
        MOVE(  LOCL,   REG3)               /* c = outer LOCL                  */
        RPUSH2(RTOP,   LOCL)               /* ( R: LOCL _                   ) */
        MOVE(  REG2,   RTOP)               /* ( R: LOCL n                   ) */
        NEG1(  REG2)                       /* b = -n                          */
        ADD4(  RSTK,   REG2, PSZ,  RSTK)   /* ( R: LOCL ln-1 ... l1 l0 n    ) */
        MOVE(  RSTK,   LOCL)               /* LOCL = &l0                      */

#if Ln > 0
        /* if outer LOCL is 0, local variables were not in use => nothing to save */
        MOVE(  RSTK,   REG0)               /* @ = &lo needed by _locals_save_reg02_ */
        NEG1(  REG2)                       /* b = n                           */
        JNZ(   REG3,   FUNC(_locals_save_reg02_))
#endif
        NEXT0()
FUNC_RAWEND(_locals_enter_)


/**
 * if some local variables are actually registers i.e. Ln > 0
 * we must save them now in the space we just reserved, before caller overwrites them.
 *
 * input:
 * REG0 = base address where to save local variables
 * REG2 = n number of local variables to save.
 */
FUNC_START(_locals_save_reg02_)
#if defined(__x86_64__)
#define MUL_by_sizeof_STOR_Lx(reg) MUL2(IMM(6), reg)
#elif defined(__aarch64__)
#define MUL_by_sizeof_STOR_Lx(reg) SHL2(IMM(2), reg)
#elif Ln > 0
#error please configure how many bytes are needed by asm instructions STOR(Lx, AT(REG0, SZx)) below
#endif

#if Ln > 0
        /* paranoia... we should only be called with base address != 0 */
        JZ(    REG0,   FUNC_RET(_locals_save_reg02_))

        /* paranoia... we should only be called with n > 0 */
        JZ(    REG2,   FUNC_RET(_locals_save_reg02_))
        JBE(   REG2,   IMM(Ln),    TO(_locals_save_reg02_.work))

        /* caller asked for more local variables than available L0...Lx       */
        /* additional variables will be in return stack                       */
        MOVI(  Ln,     REG2)

LABEL(_locals_save_reg02_.work)
        NEG1(  REG2)
        INC1(  REG2)
        MUL_by_sizeof_STOR_Lx(REG2) /* a = (1-n) * sizeof_each_asm_instruction */

        ADDROF_1M(TO(_locals_save_reg02_.save1reg), REG1)
        ADD2(  REG2,   REG1)
        JUMP_REG(      REG1)

#ifdef LF
        STORL( LF,     AT(REG0, SZ15))
#endif
#ifdef LE
        STORL( LE,     AT(REG0, SZ14))
#endif
#ifdef LD
        STORL( LD,     AT(REG0, SZ13))
#endif
#ifdef LC
        STORL( LC,     AT(REG0, SZ12))
#endif
#ifdef LB
        STORL( LB,     AT(REG0, SZ11))
#endif
#ifdef LA
        STORL( LA,     AT(REG0, SZ10))
#endif
#ifdef L9
        STORL( L9,     AT(REG0, SZ9))
#endif
#ifdef L8
        STORL( L8,     AT(REG0, SZ8))
#endif
#ifdef L7
        STORL( L7,     AT(REG0, SZ7))
#endif
#ifdef L6
        STORL( L6,     AT(REG0, SZ6))
#endif
#ifdef L4
        STORL( L4,     AT(REG0, SZ4))
#endif
#ifdef L3
        STORL( L3,     AT(REG0, SZ3))
#endif
#ifdef L2
        STORL( L2,     AT(REG0, SZ2))
#endif
#ifdef L1
        STORL( L1,     AT(REG0, SZ))
#endif
LABEL(_locals_save_reg02_.save1reg)
#ifdef L0
        STORL( L0,     AT(REG0))
#endif
#endif /* Ln > 0 */

FUNC_END(_locals_save_reg02_)


/* (locals-exit) ( R: locl ln-1 ... l1 l0 n -- ) release space for last reserved local variables */
FUNC_START(_locals_exit_)

        MOVE(  RTOP,   REG2)               /* b = n                            */
        MOVE(  LOCL,   REG0)               /* @ = inner LOCL                   */

#ifdef __x86_64__
        leaq   SZ2(RSTK, RTOP, SZ),  RSTK;
        LOAD(  LOCL,   AT(RSTK, -SZ2))
        LOAD(  RTOP,   AT(RSTK, -SZ))
#else
        ADD4(  RSTK,   RTOP, PSZ,  RSTK)   /* ( R: LOCL n                    ) */
        RPOP2( LOCL,   RTOP)               /* ( R:                           ) */
#endif

        /* if outer LOCL == 0, no need to restore local variables */
        JNZ(   LOCL,   FUNC(_locals_load_reg02_))
FUNC_END(_locals_exit_)

/**
 * if some local variables are actually registers i.e. Ln > 0
 * we must reload them now, before caller tries to use them.
 *
 * input:
 * REG0 = base address to load local variables from
 * REG2 = n number of local variables to load.
 */
FUNC_START(_locals_load_reg02_)
#if defined(__x86_64__)
#define MUL_by_sizeof_LOAD_Lx(reg) MUL2(IMM(6), reg)
#define LOAD_Lx_asm_bytes 6
#elif defined(__aarch64__)
#define MUL_by_sizeof_LOAD_Lx(reg) SHL2(IMM(2), reg)
#elif Ln > 0
#error please configure how many bytes are needed by asm instructions LOAD(Lx, AT(REG0, SZx)) below
#endif

#if Ln > 0
        /* paranoia... we should only be called with base address != 0 */
        JZ(    REG0,   FUNC_RET(_locals_load_reg02_))

        /* paranoia... we should only be called with n > 0 */
        JZ(    REG2,   FUNC_RET(_locals_load_reg02_))

        JBE(   REG2,   IMM(Ln), TO(_locals_load_reg02_.work))

        /* inner LOCL used more local variables than available L0...Lx         */
        /* additional variables are in return stack => no need to restore them */
        MOVI(  Ln,     REG2)

LABEL(_locals_load_reg02_.work)
        NEG1(  REG2)
        INC1(  REG2)
        MUL_by_sizeof_LOAD_Lx( REG2) /* a = (1-n) * sizeof_each_asm_instruction */

        ADDROF_1M(TO(_locals_load_reg02_.load1reg), REG1)
        ADD2(  REG2,   REG1)
        JUMP_REG(      REG1)

#ifdef LF
        LOADL( LF,     AT(REG0, SZ15))
#endif
#ifdef LE
        LOADL( LE,     AT(REG0, SZ14))
#endif
#ifdef LD
        LOADL( LD,     AT(REG0, SZ13))
#endif
#ifdef LC
        LOADL( LC,     AT(REG0, SZ12))
#endif
#ifdef LB
        LOADL( LB,     AT(REG0, SZ11))
#endif
#ifdef LA
        LOADL( LA,     AT(REG0, SZ10))
#endif
#ifdef L9
        LOADL( L9,     AT(REG0, SZ9))
#endif
#ifdef L8
        LOADL( L8,     AT(REG0, SZ8))
#endif
#ifdef L7
        LOADL( L7,     AT(REG0, SZ7))
#endif
#ifdef L6
        LOADL( L6,     AT(REG0, SZ6))
#endif
#ifdef L4
        LOADL( L4,     AT(REG0, SZ4))
#endif
#ifdef L3
        LOADL( L3,     AT(REG0, SZ3))
#endif
#ifdef L2
        LOADL( L2,     AT(REG0, SZ2))
#endif
#ifdef L1
        LOADL( L1,     AT(REG0, SZ))
#endif
LABEL(_locals_load_reg02_.load1reg)
#ifdef L0
        LOADL( L0,     AT(REG0))
#endif
#endif /* Ln > 0 */

FUNC_END(_locals_load_reg02_)



/*
 * save forth local variables before a C function call.
 * must be invoked before _c_arg_*_
 */
FUNC_START(_c_locals_save_)
#if Ln > 0
        JZ(    LOCL,   FUNC_RET(_c_locals_save_))
#ifdef LF
        RPUSHL(LF)
#endif
#ifdef LE
        RPUSHL(LE)
#endif
#ifdef LD
        RPUSHL(LD)
#endif
#ifdef LC
        RPUSHL(LC)
#endif
#ifdef LB
        RPUSHL(LB)
#endif
#ifdef LA
        RPUSHL(LA)
#endif
#ifdef L9
        RPUSHL(L9)
#endif
#ifdef L8
        RPUSHL(L8)
#endif
#ifdef L7
        RPUSHL(L7)
#endif
#ifdef L6
        RPUSHL(L6)
#endif
#ifdef L5
        RPUSHL(L5)
#endif
#ifdef L4
        RPUSHL(L4)
#endif
#ifdef L3
        RPUSHL(L3)
#endif
#ifdef L2
        RPUSHL(L2)
#endif
#ifdef L1
        RPUSHL(L1)
#endif
#ifdef L0
        RPUSHL(L0)
#endif
#endif
FUNC_END(_c_locals_save_)



/*
 * reload forth local variables after a C function call.
 * must be invoked after _c_ret_*_
 */
FUNC_START(_c_locals_load_)
#if Ln > 0
        JZ(    LOCL,   FUNC_RET(_c_locals_load_))
#ifdef L0
        RPOPL( L0)
#endif
#ifdef L1
        RPOPL( L1)
#endif
#ifdef L2
        RPOPL( L2)
#endif
#ifdef L3
        RPOPL( L3)
#endif
#ifdef L4
        RPOPL( L4)
#endif
#ifdef L5
        RPOPL( L5)
#endif
#ifdef L6
        RPOPL( L6)
#endif
#ifdef L7
        RPOPL( L7)
#endif
#ifdef L8
        RPOPL( L8)
#endif
#ifdef L9
        RPOPL( L9)
#endif
#ifdef LA
        RPOPL( LA)
#endif
#ifdef LB
        RPOPL( LB)
#endif
#ifdef LC
        RPOPL( LC)
#endif
#ifdef LD
        RPOPL( LD)
#endif
#ifdef LE
        RPOPL( LE)
#endif
#ifdef LF
        RPOPL( LF)
#endif
#endif
FUNC_END(_c_locals_load_)




/* lp@ ( -- addr-of-locals ) get current local variables address */
FUNC_START(lp_fetch)
        DPUSH__DTOP()
        MOVE(  LOCL,   DTOP)
FUNC_END(lp_fetch)
