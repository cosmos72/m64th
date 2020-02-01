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

#ifndef M4TH_ASM_S
#error "generic_asm/loop.S can only be included from asm.S - do not attempt to use it directly"
#endif

/** implementation of 'do', enters a (do) ... (loop) */
#ifndef M4F_DO_
FUNC_START(_do_)
        RPUSH( RTOP)                 /* save rstack top       */
        DPOP(  REG1)                 /* REG1 = i'             */
        MOVE(  DTOP, RTOP)           /* RTOP = i              */
        RPUSH( REG1)                 /* push i' on rstack     */
        DPOP(  DTOP)                 /* reload dstack top     */
FUNC_END(_do_)
#endif

/**
 * implementation of 'else'.
 * must be followed by IP offset to skip.
 * IP offset = 0 means first instruction after (else) itself
 */
#ifndef M4F_ELSE_
FUNC_START(_else_)
        RELJUMP()
FUNC_END(_else_)
#endif


FUNC_START(to_r)       /* >r */
        RPUSH( RTOP)
        MOVE(  DTOP, RTOP)
        DPOP(  DTOP)
FUNC_END(to_r)


FUNC_START(dup_to_r)   /* dup>r    m4th-user */
        RPUSH( RTOP)
        MOVE(  DTOP, RTOP)
FUNC_END(dup_to_r)


FUNC_START(i)          /* i and r@ */
        DPUSH( DTOP)
        MOVE(  RTOP, DTOP)
FUNC_END(i)


FUNC_START(i_times)    /* i*  m4th-user */
        MUL2(  RTOP, DTOP)
FUNC_END(i_times)


FUNC_START(i_plus)     /* i+  m4th-user */
        ADD2(  RTOP, DTOP)
FUNC_END(i_plus)


FUNC_START(i_minus)    /* i-  m4th-user */
        SUB2(  RTOP, DTOP)
FUNC_END(i_minus)


FUNC_START(i_prime)    /* i' m4th-user */
        DPUSH( DTOP)
        LOAD(  DTOP, AT(RSTK))
FUNC_END(i_prime)


FUNC_START(r_store)    /* r!   m4th-user */
        MOVE(  DTOP, RTOP)
        DPOP(  DTOP)
FUNC_END(r_store)


FUNC_START(r_plus)     /* r+   m4th-user */
        ADD2(  DTOP, RTOP)
        DPOP(  DTOP)
FUNC_END(r_plus)


FUNC_START(r_from)     /* r> */
        DPUSH( DTOP)
        MOVE(  RTOP, DTOP)
        RPOP(  RTOP)
FUNC_END(r_from)


FUNC_START(r_from_drop)    /* r>drop   m4th-user */
        RPOP(  RTOP)
FUNC_END(r_from_drop)


FUNC_START(unloop)
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack */
        ADD2(  IMM(SZ2), RSTK)     /* pop return stack twice */
FUNC_END(unloop)

