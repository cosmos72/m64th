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


/**
 * enter a forth function that uses local variables.
 * if some local variables are actually registers i.e. Ln > 0
 * they may be used by some function upper in the call stack:
 * we must spill them now to RAM, before the new function tries to use them.
 *
 * input:
 * REG1 = new RSTK address to set, also = new LOCL to set
 */
FUNC_START(_locals_spill_regs_)
LABEL(_locals_spill_regs_.16)
#ifdef LF
        STORL( LF,     AT(REG1, SZ15))
#endif
LABEL(_locals_spill_regs_.15)
#ifdef LE
        STORL( LE,     AT(REG1, SZ14))
#endif
LABEL(_locals_spill_regs_.14)
#ifdef LD
        STORL( LD,     AT(REG1, SZ13))
#endif
LABEL(_locals_spill_regs_.13)
#ifdef LC
        STORL( LC,     AT(REG1, SZ12))
#endif
LABEL(_locals_spill_regs_.12)
#ifdef LB
        STORL( LB,     AT(REG1, SZ11))
#endif
LABEL(_locals_spill_regs_.11)
#ifdef LA
        STORL( LA,     AT(REG1, SZ10))
#endif
LABEL(_locals_spill_regs_.10)
#ifdef L9
        STORL( L9,     AT(REG1, SZ9))
#endif
LABEL(_locals_spill_regs_.09)
#ifdef L8
        STORL( L8,     AT(REG1, SZ8))
#endif
LABEL(_locals_spill_regs_.08)
#ifdef L7
        STORL( L7,     AT(REG1, SZ7))
#endif
LABEL(_locals_spill_regs_.07)
#ifdef L6
        STORL( L6,     AT(REG1, SZ6))
#endif
LABEL(_locals_spill_regs_.06)
#ifdef L5
        STORL( L5,     AT(REG1, SZ5))
#endif
LABEL(_locals_spill_regs_.05)
#ifdef L4
        STORL( L4,     AT(REG1, SZ4))
#endif
LABEL(_locals_spill_regs_.04)
#ifdef L3
        STORL( L3,     AT(REG1, SZ3))
#endif
LABEL(_locals_spill_regs_.03)
#ifdef L2
        STORL( L2,     AT(REG1, SZ2))
#endif
LABEL(_locals_spill_regs_.02)
#ifdef L1
        STORL( L1,     AT(REG1, SZ))
#endif
LABEL(_locals_spill_regs_.01)
#ifdef L0
        STORL( L0,     AT(REG1))
#endif

LABEL(_locals_spill_regs_.finish)
        STOR(  RTOP,   AT(RSTK, -SZ))
        MOVE(  LOCL,   RTOP)
        MOVE(  REG1,   RSTK)
        MOVE(  REG1,   LOCL)
        NEXT0()
FUNC_RAWEND(_locals_spill_regs_)

/* (lenter-1) ( R: -- l0 locl ) reserve space for 1 local variable */
FUNC_START(_lenter_1_)
        ADDI(  RSTK,   -SZ2,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.01))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_1_)

/* (lenter-2) ( R: -- l1 l0 locl ) reserve space for 2 local variables */
FUNC_START(_lenter_2_)
        ADDI(  RSTK,   -SZ3,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.02))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_2_)

/* (lenter-3) ( R: -- l2 .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_3_)
        ADDI(  RSTK,   -SZ4,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.03))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_3_)

/* (lenter-4) ( R: -- l3 .. l0 locl ) reserve space for 4 local variables */
FUNC_START(_lenter_4_)
        ADDI(  RSTK,   -SZ5,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.04))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_4_)

/* (lenter-5) ( R: -- l4 .. l0 locl ) reserve space for 5 local variables */
FUNC_START(_lenter_5_)
        ADDI(  RSTK,   -SZ6,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.05))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_5_)

/* (lenter-6) ( R: -- l5 .. l0 locl ) reserve space for 6 local variables */
FUNC_START(_lenter_6_)
        ADDI(  RSTK,   -SZ7,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.06))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_6_)

/* (lenter-7) ( R: -- l6 .. l0 locl ) reserve space for 7 local variables */
FUNC_START(_lenter_7_)
        ADDI(  RSTK,   -SZ8,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.07))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_7_)

/* (lenter-8) ( R: -- l7 .. l0 locl ) reserve space for 8 local variables */
FUNC_START(_lenter_8_)
        ADDI(  RSTK,   -SZ9,   REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.08))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_8_)

/* (lenter-9) ( R: -- l8 .. l0 locl ) reserve space for 9 local variables */
FUNC_START(_lenter_9_)
        ADDI(  RSTK,   -SZ10,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.09))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_9_)

/* (lenter-a) ( R: -- l9 .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_a_)
        ADDI(  RSTK,   -SZ11,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.10))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_a_)

/* (lenter-b) ( R: -- la .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_b_)
        ADDI(  RSTK,   -SZ12,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.11))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_b_)

/* (lenter-c) ( R: -- lb .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_c_)
        ADDI(  RSTK,   -SZ13,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.12))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_c_)

/* (lenter-d) ( R: -- lc .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_d_)
        ADDI(  RSTK,   -SZ14,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.13))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_d_)

/* (lenter-e) ( R: -- ld .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_e_)
        ADDI(  RSTK,   -SZ15,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.14))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_e_)

/* (lenter-f) ( R: -- le .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_f_)
        ADDI(  RSTK,   -SZ16,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.15))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_f_)

/* (lenter-g) ( R: -- lf .. l0 locl ) reserve space for 3 local variables */
FUNC_START(_lenter_g_)
        ADDI(  RSTK,   -SZ17,  REG1)
        JNZ(   LOCL,   TO(_locals_spill_regs_.16))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_g_)

/* (lenter-x) ( R: -- ln-1 ... l1 l0 locl ) */
/* must be followed by T(N), reserves space for N local variables. N must be >= Ln */
FUNC_START(_lenter_x_)
        LD_ut( REG1,   AT(IP))
        ADD2(IMM(SZt), IP)
        NOT1(  REG1)                      /* a = -n-1       */
        ADD4(  RSTK,   REG1,PSZ,   REG1)  /* a = new RSTK   */
        JNZ(   LOCL,   FUNC(_locals_spill_regs_))
        JUMP(  TO(_locals_spill_regs_.finish))
FUNC_RAWEND(_lenter_x_)





/**
 * exit from a forth function that uses local variables.
 * if some local variables are actually registers i.e. Ln > 0
 * we must reload them now, before caller tries to use them.
 *
 * input:
 * REG1 = new RSTK address to set.
 */
FUNC_START(_locals_reload_regs_)
LABEL(_locals_reload_regs_.16)
#ifdef LF
        LOADL( LF,     AT(LOCL, SZ15))
#endif
LABEL(_locals_reload_regs_.15)
#ifdef LE
        LOADL( LE,     AT(LOCL, SZ14))
#endif
LABEL(_locals_reload_regs_.14)
#ifdef LD
        LOADL( LD,     AT(LOCL, SZ13))
#endif
LABEL(_locals_reload_regs_.13)
#ifdef LC
        LOADL( LC,     AT(LOCL, SZ12))
#endif
LABEL(_locals_reload_regs_.12)
#ifdef LB
        LOADL( LB,     AT(LOCL, SZ11))
#endif
LABEL(_locals_reload_regs_.11)
#ifdef LA
        LOADL( LA,     AT(LOCL, SZ10))
#endif
LABEL(_locals_reload_regs_.10)
#ifdef L9
        LOADL( L9,     AT(LOCL, SZ9))
#endif
LABEL(_locals_reload_regs_.09)
#ifdef L8
        LOADL( L8,     AT(LOCL, SZ8))
#endif
LABEL(_locals_reload_regs_.08)
#ifdef L7
        LOADL( L7,     AT(LOCL, SZ7))
#endif
LABEL(_locals_reload_regs_.07)
#ifdef L6
        LOADL( L6,     AT(LOCL, SZ6))
#endif
LABEL(_locals_reload_regs_.06)
#ifdef L5
        LOADL( L5,     AT(LOCL, SZ5))
#endif
LABEL(_locals_reload_regs_.05)
#ifdef L4
        LOADL( L4,     AT(LOCL, SZ4))
#endif
LABEL(_locals_reload_regs_.04)
#ifdef L3
        LOADL( L3,     AT(LOCL, SZ3))
#endif
LABEL(_locals_reload_regs_.03)
#ifdef L2
        LOADL( L2,     AT(LOCL, SZ2))
#endif
LABEL(_locals_reload_regs_.02)
#ifdef L1
        LOADL( L1,     AT(LOCL, SZ))
#endif
LABEL(_locals_reload_regs_.01)
#ifdef L0
        LOADL( L0,     AT(LOCL))
#endif

LABEL(_locals_reload_regs_.finish)
        MOVE(  RTOP,   LOCL)
        LOAD(  RTOP,   AT(REG1, -SZ))
        MOVE(  REG1,   RSTK)
        NEXT0()
FUNC_RAWEND(_locals_reload_regs_)


/* (lexit-1) ( R: l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_1_)
        ADDI(  RSTK,   SZ2,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.01))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_1_)


/* (lexit-2) ( R: l1 l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_2_)
        ADDI(  RSTK,   SZ3,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.02))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_2_)


/* (lexit-3) ( R: l2 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_3_)
        ADDI(  RSTK,   SZ4,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.03))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_3_)


/* (lexit-4) ( R: l3 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_4_)
        ADDI(  RSTK,   SZ5,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.04))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_4_)


/* (lexit-5) ( R: l4 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_5_)
        ADDI(  RSTK,   SZ6,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.05))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_5_)

/* (lexit-6) ( R: l5 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_6_)
        ADDI(  RSTK,   SZ7,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.06))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_6_)

/* (lexit-7) ( R: l6 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_7_)
        ADDI(  RSTK,   SZ8,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.07))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_7_)

/* (lexit-8) ( R: l7 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_8_)
        ADDI(  RSTK,   SZ9,    REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.08))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_8_)

/* (lexit-9) ( R: l8 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_9_)
        ADDI(  RSTK,   SZ10,   REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.09))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_9_)

/* (lexit-a) ( R: l9 .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_a_)
        ADDI(  RSTK,   SZ11,   REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.10))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_a_)

/* (lexit-b) ( R: la .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_b_)
        ADDI(  RSTK,   SZ12,   REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.11))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_b_)

/* (lexit-c) ( R: lb .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_c_)
        ADDI(  RSTK,   SZ13,   REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.12))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_c_)

/* (lexit-d) ( R: lc .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_d_)
        ADDI(  RSTK,   SZ14,   REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.13))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_d_)

/* (lexit-e) ( R: ld .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_e_)
        ADDI(  RSTK,   SZ15,   REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.14))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_e_)

/* (lexit-f) ( R: le .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_f_)
        ADDI(  RSTK,   SZ16,   REG1)         /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.15))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_f_)

/* (lexit-g) ( R: lf .. l0 outer-locl -- ) release space for last reserved local variables */
FUNC_START(_lexit_g_)
        ADDI(  RSTK,   SZ17,   REG1)           /* updated RSTK */
        JNZ(   RTOP,   TO(_locals_reload_regs_.16))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_g_)

/* (lexit-x) ( R: .. lf .. l0 outer-locl -- ) release space for last reserved local variables */
/* must be followed by T(N), releases space for N local variables. N must be >= Ln */
FUNC_START(_lexit_x_)
        LD_ut( REG1,   AT(IP))
        ADD2(IMM(SZt), IP)
        ADD2(IMM(1),   REG1)                   /* also release space for saved LOCL */
        ADD4(  RSTK,   REG1,PSZ,   REG1)       /* updated RSTK */
        JNZ(   RTOP,   FUNC(_locals_reload_regs_))
        JUMP(  TO(_locals_reload_regs_.finish))
FUNC_RAWEND(_lexit_x_)



/*
 * save all forth local variables before a C function call.
 * must be invoked before _c_arg_*_
 */
FUNC_START(_c_locals_save_)
#if Ln > 0
        ADDI(  RSTK,   -(Ln+1)*SZ, REG1)       /* a = new RSTK   */
        JNZ(   LOCL,   FUNC(_locals_spill_regs_))
#endif
        NEXT0()
FUNC_RAWEND(_c_locals_save_)



/*
 * reload all forth local variables after a C function call.
 * must be invoked after _c_ret_*_
 */
FUNC_START(_c_locals_load_)
#if Ln > 0
        ADDI(  RSTK,   (Ln+1)*SZ,  REG1)       /* a = new RSTK   */
        JNZ(   LOCL,   FUNC(_locals_reload_regs_))
#endif
        NEXT0()
FUNC_RAWEND(_c_locals_load_)




/**
 * lp@ ( -- addr-of-locals ) get current local variables address.
 * only partially useful, as most local variables are usually stored in registers
 */
FUNC_START(lp_fetch)
        DPUSH__DTOP()
        MOVE(  LOCL,   DTOP)
FUNC_END(lp_fetch)
