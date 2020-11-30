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

FUNC_START(_l0_) /* (l0) ( -- x ) push 0-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL))
FUNC_END(_l0_)
FUNC_START(_drop_l0_) /* (drop&l0) ( y -- x ) drop, then push 0-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL))
FUNC_END(_drop_l0_)
FUNC_START(_to_l0_) /* (>l0) ( x -- ) store dstack top to 1-st local variable */
        STOR(  DTOP,   AT(LOCL))
        DPOP___DTOP()
FUNC_END(_to_l0_)
FUNC_START(_dup_to_l0_) /* (dup>l0) ( x -- x ) copy dstack top to 1-st local variable */
        STOR(  DTOP,   AT(LOCL))
FUNC_END(_dup_to_l0_)


FUNC_START(_l1_) /* (l1) ( -- x ) push 1-st local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ))
FUNC_END(_l1_)
FUNC_START(_drop_l1_) /* (drop&l1) ( y -- x ) drop, then push 1-st local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ))
FUNC_END(_drop_l1_)
FUNC_START(_to_l1_) /* (>l1) ( x -- ) store dstack top to 1-st local variable */
        STOR(  DTOP,   AT(LOCL, SZ))
        DPOP___DTOP()
FUNC_END(_to_l1_)
FUNC_START(_dup_to_l1_) /* (dup>l1) ( x -- x ) copy dstack top to 1-st local variable */
        STOR(  DTOP,   AT(LOCL, SZ))
FUNC_END(_dup_to_l1_)


FUNC_START(_l2_) /* (l2) ( -- x ) push 2-nd local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ2))
FUNC_END(_l2_)
FUNC_START(_drop_l2_) /* (drop&l2) ( y -- x ) drop, then push 2-nd local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ2))
FUNC_END(_drop_l2_)
FUNC_START(_to_l2_) /* (>l2) ( x -- ) store dstack top to 2-nd local variable */
        STOR(  DTOP,   AT(LOCL, SZ2))
        DPOP___DTOP()
FUNC_END(_to_l2_)
FUNC_START(_dup_to_l2_) /* (dup>l2) ( x -- x ) copy dstack top to 2-nd local variable */
        STOR(  DTOP,   AT(LOCL, SZ2))
FUNC_END(_dup_to_l2_)


FUNC_START(_l3_) /* (l3) ( -- x ) push 3-rd local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ3))
FUNC_END(_l3_)
FUNC_START(_drop_l3_) /* (drop&l3) ( y -- x ) drop, then push 3-rd local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ3))
FUNC_END(_drop_l3_)
FUNC_START(_to_l3_) /* (>l3) ( x -- ) store dstack top to 3-rd local variable */
        STOR(  DTOP,   AT(LOCL, SZ3))
        DPOP___DTOP()
FUNC_END(_to_l3_)
FUNC_START(_dup_to_l3_) /* (dup>l3) ( x -- x ) copy dstack top to 3-rd local variable */
        STOR(  DTOP,   AT(LOCL, SZ3))
FUNC_END(_dup_to_l3_)


FUNC_START(_l4_) /* (l4) ( -- x ) push 4-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ4))
FUNC_END(_l4_)
FUNC_START(_drop_l4_) /* (drop&l4) ( y -- x ) drop, then push 4-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ4))
FUNC_END(_drop_l4_)
FUNC_START(_to_l4_) /* (>l4) ( x -- ) store dstack top to 4-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ4))
        DPOP___DTOP()
FUNC_END(_to_l4_)
FUNC_START(_dup_to_l4_) /* (dup>l4) ( x -- x ) copy dstack top to 4-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ4))
FUNC_END(_dup_to_l4_)


FUNC_START(_l5_) /* (l5) ( -- x ) push 5-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ5))
FUNC_END(_l5_)
FUNC_START(_drop_l5_) /* (drop&l5) ( y -- x ) drop, then push 5-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ5))
FUNC_END(_drop_l5_)
FUNC_START(_to_l5_) /* (>l5) ( x -- ) store dstack top to 5-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ5))
        DPOP___DTOP()
FUNC_END(_to_l5_)
FUNC_START(_dup_to_l5_) /* (dup>l5) ( x -- x ) copy dstack top to 5-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ5))
FUNC_END(_dup_to_l5_)


FUNC_START(_l6_) /* (l6) ( -- x ) push 6-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ6))
FUNC_END(_l6_)
FUNC_START(_drop_l6_) /* (drop&l6) ( y -- x ) drop, then push 6-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ6))
FUNC_END(_drop_l6_)
FUNC_START(_to_l6_) /* (>l6) ( x -- ) store dstack top to 6-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ6))
        DPOP___DTOP()
FUNC_END(_to_l6_)
FUNC_START(_dup_to_l6_) /* (dup>l6) ( x -- x ) copy dstack top to 6-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ6))
FUNC_END(_dup_to_l6_)


FUNC_START(_l7_) /* (l7) ( -- x ) push 7-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ7))
FUNC_END(_l7_)
FUNC_START(_drop_l7_) /* (drop&l7) ( y -- x ) drop, then push 7-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ7))
FUNC_END(_drop_l7_)
FUNC_START(_to_l7_) /* (>l7) ( x -- ) store dstack top to 7-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ7))
        DPOP___DTOP()
FUNC_END(_to_l7_)
FUNC_START(_dup_to_l7_) /* (dup>l7) ( x -- x ) copy dstack top to 7-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ7))
FUNC_END(_dup_to_l7_)


FUNC_START(_l8_) /* (l8) ( -- x ) push 8-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ8))
FUNC_END(_l8_)
FUNC_START(_drop_l8_) /* (drop&l8) ( y -- x ) drop, then push 8-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ8))
FUNC_END(_drop_l8_)
FUNC_START(_to_l8_) /* (>l8) ( x -- ) store dstack top to 8-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ8))
        DPOP___DTOP()
FUNC_END(_to_l8_)
FUNC_START(_dup_to_l8_) /* (dup>l8) ( x -- x ) copy dstack top to 8-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ8))
FUNC_END(_dup_to_l8_)


FUNC_START(_l9_) /* (l9) ( -- x ) push 9-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ9))
FUNC_END(_l9_)
FUNC_START(_drop_l9_) /* (drop&l9) ( y -- x ) drop, then push 9-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ9))
FUNC_END(_drop_l9_)
FUNC_START(_to_l9_) /* (>l9) ( x -- ) store dstack top to 9-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ9))
        DPOP___DTOP()
FUNC_END(_to_l9_)
FUNC_START(_dup_to_l9_) /* (dup>l9) ( x -- x ) copy dstack top to 9-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ9))
FUNC_END(_dup_to_l9_)


FUNC_START(_la_) /* (la) ( -- x ) push 10-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ10))
FUNC_END(_la_)
FUNC_START(_drop_la_) /* (drop&la) ( y -- x ) drop, then push 10-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ10))
FUNC_END(_drop_la_)
FUNC_START(_to_la_) /* (>la) ( x -- ) store dstack top to 10-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ10))
        DPOP___DTOP()
FUNC_END(_to_la_)
FUNC_START(_dup_to_la_) /* (dup>la) ( x -- x ) copy dstack top to 10-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ10))
FUNC_END(_dup_to_la_)


FUNC_START(_lb_) /* (lb) ( -- x ) push 11-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ11))
FUNC_END(_lb_)
FUNC_START(_drop_lb_) /* (drop&lb) ( y -- x ) drop, then push 11-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ11))
FUNC_END(_drop_lb_)
FUNC_START(_to_lb_) /* (>lb) ( x -- ) store dstack top to 11-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ11))
        DPOP___DTOP()
FUNC_END(_to_lb_)
FUNC_START(_dup_to_lb_) /* (dup>lb) ( x -- x ) copy dstack top to 11-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ11))
FUNC_END(_dup_to_lb_)


FUNC_START(_lc_) /* (lc) ( -- x ) push 12-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ12))
FUNC_END(_lc_)
FUNC_START(_drop_lc_) /* (drop&lc) ( y -- x ) drop, then push 12-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ12))
FUNC_END(_drop_lc_)
FUNC_START(_to_lc_) /* (>lc) ( x -- ) store dstack top to 12-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ12))
        DPOP___DTOP()
FUNC_END(_to_lc_)
FUNC_START(_dup_to_lc_) /* (dup>lc) ( x -- x ) copy dstack top to 12-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ12))
FUNC_END(_dup_to_lc_)


FUNC_START(_ld_) /* (ld) ( -- x ) push 13-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ13))
FUNC_END(_ld_)
FUNC_START(_drop_ld_) /* (drop&ld) ( y -- x ) drop, then push 13-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ13))
FUNC_END(_drop_ld_)
FUNC_START(_to_ld_) /* (>ld) ( x -- ) store dstack top to 13-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ13))
        DPOP___DTOP()
FUNC_END(_to_ld_)
FUNC_START(_dup_to_ld_) /* (dup>ld) ( x -- x ) copy dstack top to 13-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ13))
FUNC_END(_dup_to_ld_)


FUNC_START(_le_) /* (le) ( -- x ) push 14-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ14))
FUNC_END(_le_)
FUNC_START(_drop_le_) /* (drop&le) ( y -- x ) drop, then push 14-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ14))
FUNC_END(_drop_le_)
FUNC_START(_to_le_) /* (>le) ( x -- ) store dstack top to 14-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ14))
        DPOP___DTOP()
FUNC_END(_to_le_)
FUNC_START(_dup_to_le_) /* (dup>le) ( x -- x ) copy dstack top to 14-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ14))
FUNC_END(_dup_to_le_)


FUNC_START(_lf_) /* (lf) ( -- x ) push 15-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ15))
FUNC_END(_lf_)
FUNC_START(_drop_lf_) /* (drop&lf) ( y -- x ) drop, then push 15-th local variable to dstack */
        LOAD(  DTOP,   AT(LOCL, SZ15))
FUNC_END(_drop_lf_)
FUNC_START(_to_lf_) /* (>lf) ( x -- ) store dstack top to 15-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ15))
        DPOP___DTOP()
FUNC_END(_to_lf_)
FUNC_START(_dup_to_lf_) /* (dup>lf) ( x -- x ) copy dstack top to 15-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ15))
FUNC_END(_dup_to_lf_)


/* (lx) ( -- x ) followed by T(N), push N-th local variable to dstack */
FUNC_START(_lx_)
        LD_ut( REG1,   AT(IP))
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, REG1, SZ))
        ADD2(IMM(SZt), IP)
FUNC_END(_lx_)
/* (drop&lx) ( y -- x ) followed by T(N), drop, then push N-th local variable to dstack */
FUNC_START(_drop_lx_)
        LD_ut( REG1,   AT(IP))
        LOAD(  DTOP,   AT(LOCL, REG1, SZ))
        ADD2(IMM(SZt), IP)
FUNC_END(_drop_lx_)
/* (lx) ( x -- ) followed by T(N), store dstack top to N-th local variable */
FUNC_START(_to_lx_)
        LD_ut( REG1,   AT(IP))
        STOR(  DTOP,   AT(LOCL, REG1, SZ))
        DPOP___DTOP()
        ADD2(IMM(SZt), IP)
FUNC_END(_to_lx_)
/* (dup>lx) ( x -- x ) followed by T(N), copy dstack top to N-th local variable */
FUNC_START(_dup_to_lx_)
        LD_ut( REG1,   AT(IP))
        STOR(  DTOP,   AT(LOCL, REG1, SZ))
        ADD2(IMM(SZt), IP)
FUNC_END(_dup_to_lx_)


/* (locals-enter) (R: -- locl ln-1 ... l1 l0 n ) followed by T(n), reserve space for n local variables */
FUNC_START(_locals_enter_)
#ifdef __aarch64__
        LD_ut( REG1,   AT(IP), SZt)        /* a = n; IP += SZt i.e. skip T(n) */
#else
        LD_ut( REG1,   AT(IP))             /* a = n                           */
        ADD2(IMM(SZt), IP)                 /* IP += SZt i.e. skip T(n)        */
#endif
        RPUSH2(RTOP,   LOCL)               /* (R: LOCL _                    ) */
        MOVE(  REG1,   RTOP)               /* (R: LOCL n                    ) */
        NEG1(  REG1)                       /* a = -n                          */
        ADD4(  RSTK,   REG1, PSZ,  RSTK)   /* (R: LOCL ln-1 ... l1 l0 n     ) */
        MOVE(  RSTK,   LOCL)               /* LOCL = &l0                      */
        NEXT0()
FUNC_RAWEND(_locals_enter_)


/* (locals-exit) (R: locl ln-1 ... l1 l0 n -- ) release space for last reserved local variables */
FUNC_START(_locals_exit_)
#ifdef __x86_64__
        leaq   SZ2(RSTK, RTOP, SZ),  RSTK;
        LOAD(  LOCL,   AT(RSTK, -SZ2))
        LOAD(  RTOP,   AT(RSTK, -SZ))
#else
        ADD4(  RSTK,   RTOP, PSZ,  RSTK)   /* (R: LOCL n                    ) */
        RPOP2( LOCL,   RTOP)               /* (R:                           ) */
#endif
FUNC_END(_locals_exit_)


/* lp0 ( -- addr-of-locals ) get address of local variables */
FUNC_START(lp0)
        DPUSH__DTOP()
        MOVE(  LOCL,   DTOP)
FUNC_END(lp0)
