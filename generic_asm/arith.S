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
#error "generic_asm/arith.S can only be included from asm.S - do not attempt to use it directly"
#endif

#ifndef M4_LITERAL2S_
FUNC_START(_literal2s_) /* (literal-2s) push to dstack the int16 at following IP */
        DPUSH( DTOP)
        LD_sh( DTOP_sh, AT(IP))
        NEXT2() /* skip 2 bytes */
FUNC_RAWEND(_literal2s_)
#endif

#ifndef M4_LITERAL4S_
FUNC_START(_literal4s_) /* (literal-4s) push to dstack the int32 at following IP */
        DPUSH( DTOP)
        LD_sw( DTOP_sw, AT(IP))
        NEXT4() /* skip 4 bytes */
FUNC_RAWEND(_literal4s_)
#endif

#ifndef M4_LITERAL8S_
FUNC_START(_literal8s_) /* (literal-8s) push to dstack the int64 at following IP */
        DPUSH( DTOP)
        LOAD(  DTOP, AT(IP))
        NEXT8() /* skip 8 bytes */
FUNC_RAWEND(_literal8s_)
#endif

#ifndef M4_MISSING_
FUNC_START(_missing_) /* (missing) called instead of invalid/unimplemented function */
        ZERO(  REG1)
        LOAD(  REG1, AT(REG1)) /* should crash */
FUNC_END(_missing_)
#endif


FUNC_START(times) /* * */
        DPOP(  REG1)
        MUL2(  REG1, DTOP)
FUNC_END(times)


FUNC_START(plus) /* + */
        DPOP(  REG1)
        ADD2(  REG1, DTOP)
FUNC_END(plus)


#ifndef M4PLUS_STORE
FUNC_START(plus_store) /* +! */
        DPOP(  REG1)
        LOAD(  REG2, AT(DTOP))
        ADD2(  REG1, REG2)
        STOR(  REG2, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(plus_store)
#endif


FUNC_START(minus) /* - */
        DPOP(  REG1)
#ifdef SUB3
        SUB3(  REG1, DTOP, DTOP)
#else
        NEG1(  DTOP)
        ADD2(  REG1, DTOP)
#endif
FUNC_END(minus)



#ifndef M4MINUS_ONE
FUNC_START(minus_one)  /* -1   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(-1), DTOP)
FUNC_END(minus_one)
#endif


#ifndef M4ZERO
FUNC_START(zero)     /* 0   m4th-impl */
        DPUSH( DTOP)
        ZERO(  DTOP)
FUNC_END(zero)
#endif


FUNC_START(zero_less)   /* 0< */
        SAR2(  IMM(63), DTOP)
FUNC_END(zero_less)


#ifndef M4ONE
FUNC_START(one)        /* 1    m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(1), DTOP)
FUNC_END(one)
#endif


FUNC_START(one_plus)   /* 1+   */
        INC1(  DTOP)
FUNC_END(one_plus)


FUNC_START(one_minus)  /* 1-   */
        DEC1(  DTOP)
FUNC_END(one_minus)


#ifndef M4TWO
FUNC_START(two)        /* 2   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(2), DTOP)
FUNC_END(two)
#endif


FUNC_START(two_plus)   /* 2+  m4th-impl */
        ADD2(  IMM(2), DTOP)
FUNC_END(two_plus)


FUNC_START(two_minus)  /* 2-  m4th-impl */
        SUB2(  IMM(2), DTOP)
FUNC_END(two_minus)


#ifndef M4THREE
FUNC_START(three)      /* 3   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(3), DTOP)
FUNC_END(three)
#endif


#ifndef M4FOUR
FUNC_START(four)       /* 4   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(4), DTOP)
FUNC_END(four)
#endif


FUNC_START(four_times)  /* 4*  m4th-impl */
        SHL2(  IMM(2), DTOP)
FUNC_END(four_times)


FUNC_START(four_plus)  /* 4+  m4th-impl */
        ADD2(  IMM(4), DTOP)
FUNC_END(four_plus)


#ifndef M4EIGHT
FUNC_START(eight)      /* 8   m4th-impl */
        DPUSH( DTOP)
        MOVE(  IMM(8), DTOP)
FUNC_END(eight)
#endif


FUNC_START(eight_times) /* 8*  m4th-impl */
        SHL2(  IMM(3), DTOP)
FUNC_END(eight_times)


FUNC_START(eight_plus) /* 8+  m4th-impl */
        ADD2(  IMM(8), DTOP)
FUNC_END(eight_plus)


FUNC_START(to_r)       /* >r */
        RPUSH( RTOP)
        MOVE(  DTOP, RTOP)
        DPOP(  DTOP)
FUNC_END(to_r)


FUNC_START(and)
        DPOP(  REG1)
        AND2(  REG1,  DTOP)
FUNC_END(and)


#ifndef M4BL
FUNC_START(bl)
        DPUSH( DTOP)
        MOVE(  IMM(32), DTOP)
FUNC_END(bl)
#endif


FUNC_START(drop)
        DPOP(  DTOP)
FUNC_END(drop)


FUNC_START(depth)
        DPUSH( DTOP)
        LOAD(  DTOP, AT(M4TH, M4TH_OFF_DEND))
        SUB2(  DSTK, DTOP)
        SAR2(  IMM(PSZ), DTOP)
FUNC_END(depth)


FUNC_START(dup)
        DPUSH( DTOP)
FUNC_END(dup)


FUNC_START(i)  /* i and r@ */
        DPUSH( DTOP)
        MOVE(  RTOP, DTOP)
FUNC_END(i)


FUNC_START(i_times) /* i*  m4th */
        MUL2(  RTOP, DTOP)
FUNC_END(i_times)


FUNC_START(i_plus)  /* i+  m4th */
        ADD2(  RTOP, DTOP)
FUNC_END(i_plus)


FUNC_START(i_minus) /* i-  m4th */
        SUB2(  RTOP, DTOP)
FUNC_END(i_minus)


FUNC_START(i_prime) /* i' m4th */
        DPUSH( DTOP)
        LOAD(  DTOP, AT(RSTK))
FUNC_END(i_prime)


FUNC_START(invert)
        NOT1(  DTOP)
FUNC_END(invert)

/**
 * get iteration index of outer do-loop.
 * must skip return stack used by innermost do-loop:
 *   i' i
 */
FUNC_START(j)
        DPUSH( DTOP)
        LOAD(  DTOP, AT(RSTK, SZ))
FUNC_END(j)


FUNC_START(negate)
        NEG1(  DTOP)
FUNC_END(negate)


FUNC_START(nip)
        DPOP(  DTOP)
FUNC_END(nip)


FUNC_START(noop) /* no-op m4th */
FUNC_END(noop)


FUNC_START(or)
        DPOP(  REG1)
        ORR2(  REG1,  DTOP)
FUNC_END(or)


FUNC_START(over)
        DPUSH( DTOP)
        LOAD(  DTOP, AT(DSTK, SZ))
FUNC_END(over)


FUNC_START(r_store)        /* r! */
        MOVE(  DTOP, RTOP)
        DPOP(  DTOP)
FUNC_END(r_store)


FUNC_START(r_plus)         /* r+ */
        ADD2(  DTOP, RTOP)
        DPOP(  DTOP)
FUNC_END(r_plus)


FUNC_START(r_from)         /* r> */
        DPUSH( DTOP)
        MOVE(  RTOP, DTOP)
        RPOP(  RTOP)
FUNC_END(r_from)


FUNC_START(rot)
        LOAD(  REG1, AT(DSTK))
        STOR(  DTOP, AT(DSTK))
        LOAD(  DTOP, AT(DSTK, SZ))
        STOR(  REG1, AT(DSTK, SZ))
FUNC_END(rot)


#ifndef M4SWAP
FUNC_START(swap)
        LOAD(  REG1, AT(DSTK))
        STOR(  DTOP, AT(DSTK))
        MOVE(  REG1, DTOP)
FUNC_END(swap)
#endif


FUNC_START(unloop)
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack */
        ADD2(  IMM(SZ2), RSTK)     /* pop return stack twice */
FUNC_END(unloop)
