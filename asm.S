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

        .file "asm.S"
        .text


#if defined(__x86_64__)
#include "amd64/arith.S"
#include "amd64/call.S"
#include "amd64/io.S"
#include "amd64/loop.S"
#elif defined(__aarch64__)
#include "arm64/arith.S"
#include "arm64/call.S"
#include "arm64/io.S"
#include "arm64/loop.S"
#else
#error "unsupported architecture: expecting amd64 or arm64"
#endif

FUNC_START(m4store) /* ! */
        DPOP(REG1)
        STOR(REG1, AT(DTOP))
        DPOP(DTOP)
FUNC_END(m4store)


#ifndef M4_LIT_
FUNC_START(m4_lit_) /* (lit) */
        DPUSH(DTOP)
        LOAD(DTOP, AT(IP, SZ))
        NEXT2()
FUNC_RAWEND(m4_lit_)
#endif


FUNC_START(m4star) /* * */
        DPOP(REG1)
        MUL2(REG1, DTOP)
FUNC_END(m4star)


FUNC_START(m4plus) /* + */
        DPOP(REG1)
        ADD2(REG1, DTOP)
FUNC_END(m4plus)


#ifndef M4PLUS_STORE
FUNC_START(m4plus_store) /* +! */
        DPOP(REG1)
        LOAD(REG2, AT(DTOP))
        ADD2(REG1, REG2)
        STOR(REG2, AT(DTOP))
        DPOP(DTOP)
FUNC_END(m4plus_store)
#endif


FUNC_START(m4minus) /* - */
        DPOP(REG1)
#ifdef SUB3
        SUB3(REG1, DTOP, DTOP)
#else
        NEG1(DTOP)
        ADD2(REG1, DTOP)
#endif
FUNC_END(m4minus)


#ifndef M4SLASH_C
FUNC_START(m4slash_c) /* /c   m4th: sizeof(m4char) i.e. 1  */
        DPUSH( DTOP)
        MOVE(  IMM(1), DTOP)
FUNC_END(m4slash_c)
#endif


#ifndef M4SLASH_N
FUNC_START(m4slash_n) /* /n   m4th: sizeof(m4int)  i.e. SZ */
        DPUSH( DTOP)
        MOVE(  IMM(SZ), DTOP)
FUNC_END(m4slash_n)
#endif


#ifndef M4ONE_MINUS
FUNC_START(m4one_minus) /* 1-   */
        SUB2(IMM(1), DTOP);
FUNC_END(m4one_minus)
#endif


#ifndef M4ONE_PLUS
FUNC_START(m4one_plus) /* 1+   */
        ADD2(IMM(1), DTOP);
FUNC_END(m4one_plus)
#endif


FUNC_START(m4two_minus) /* 2- */
        SUB2(  IMM(2), DTOP)
FUNC_END(m4two_minus)


FUNC_START(m4two_plus) /* 2+ */
        ADD2(  IMM(2), DTOP)
FUNC_END(m4two_plus)


FUNC_START(m4to_r) /* >r */
        RPUSH( RTOP)
        MOVE(  DTOP, RTOP)
        DPOP(  DTOP)
FUNC_END(m4to_r)


FUNC_START(m4fetch) /* @ */
        LOAD(DTOP, AT(DTOP))
FUNC_END(m4fetch)


FUNC_START(m4and)
        DPOP(REG1)
        AND2(REG1,  DTOP)
FUNC_END(m4and)


#ifndef M4BL
FUNC_START(m4bl)
        DPUSH(DTOP)
        MOVE(IMM(32), DTOP)
FUNC_END(m4bl)
#endif


FUNC_START(m4drop)
        DPOP(DTOP)
FUNC_END(m4drop)


FUNC_START(m4dup)
        DPUSH(DTOP)
FUNC_END(m4dup)


#ifndef M4FALSE
FUNC_START(m4false)
        DPUSH(DTOP)
        ZERO(DTOP)
FUNC_END(m4false)
#endif


FUNC_START(m4i)
        DPUSH(DTOP)
        MOVE(RTOP, DTOP)
FUNC_END(m4i)


FUNC_START(m4i_prime) /* i' */
        DPUSH(DTOP)
        LOAD(DTOP, AT(RSTK))
FUNC_END(m4i_prime)


/**
 * get iteration index of outer do-loop.
 * must skip return stack used by innermost do-loop:
 *   i' i
 */
FUNC_START(m4j)
        DPUSH(DTOP)
        LOAD(DTOP, AT(RSTK, SZ))
FUNC_END(m4j)


FUNC_START(m4negate)
        NEG1(DTOP)
FUNC_END(m4negate)


FUNC_START(m4noop)
FUNC_END(m4noop)


FUNC_START(m4or)
        DPOP(REG1)
        ORR2(REG1,  DTOP)
FUNC_END(m4or)


FUNC_START(m4over)
        DPUSH( DTOP)
        LOAD(  DTOP, AT(DSTK, SZ))
FUNC_END(m4over)


FUNC_START(m4r_from) /* r> */
        DPUSH(DTOP)
        MOVE(RTOP, DTOP)
        RPOP(RTOP)
FUNC_END(m4r_from)


FUNC_START(m4rot)
        LOAD(REG1, AT(DSTK))
        STOR(DTOP, AT(DSTK))
        LOAD(DTOP, AT(DSTK, SZ))
        STOR(REG1, AT(DSTK, SZ))
FUNC_END(m4rot)


#ifndef M4TRUE
FUNC_START(m4true)
        DPUSH(DTOP)
        MOVE(IMM(-1), DTOP)
FUNC_END(m4true)
#endif


#ifndef M4SWAP
FUNC_START(m4swap)
        LOAD(REG1, AT(DSTK))
        STOR(DTOP, AT(DSTK))
        MOVE(REG1, DTOP)
FUNC_END(m4swap)
#endif


FUNC_START(m4unloop)
        LOAD(  RTOP, AT(RSTK, SZ)) /* load new top of rstack */
        ADD2(  IMM(SZ2), RSTK)     /* pop return stack twice */
FUNC_END(m4unloop)


        .ident "m4th 0.0.0"
        .section .note.GNU-stack,"",@progbits
