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
#include "amd64/exec.S"
#include "amd64/loop.S"
#elif defined(__aarch64__)
#include "arm64/arith.S"
#include "arm64/exec.S"
#include "arm64/loop.S"
#else
#error "unsupported architecture: expecting amd64 or arm64"
#endif


FUNC_START(m4drop)
        DPOP(DTOP)
FUNC_END(m4drop)


FUNC_START(m4dup)
        DPUSH(DTOP)
FUNC_END(m4dup)


FUNC_START(m4fetch) /* @ */
        LOAD(DTOP, DTOP)
FUNC_END(m4fetch)


FUNC_START(m4i)
        DPUSH(DTOP)
        MOVE(RTOP, DTOP)
FUNC_END(m4i)


FUNC_START(m4i_prime) /* i' */
        DPUSH(DTOP)
        LOAD(RSTK, DTOP)
FUNC_END(m4i_prime)


FUNC_START(m4j)
        DPUSH(DTOP)
        IGET(RSTK, SZ, DTOP)
FUNC_END(m4j)


#ifndef M4LITERAL
FUNC_START(m4literal)
        DPUSH(DTOP)
        IGET(IP, SZ, DTOP)
        NEXT2()
FUNC_RAWEND(m4literal)
#endif

#ifndef M4LITERAL_1
FUNC_START(m4literal_1)
        DPUSH(DTOP)
        MOVE(IMM(-1), DTOP)
FUNC_END(m4literal_1)
#endif

#ifndef M4LITERAL0
FUNC_START(m4literal0)
        DPUSH(DTOP)
        ZERO(DTOP)
FUNC_END(m4literal0)
#endif

#ifndef M4LITERAL1
FUNC_START(m4literal1)
        DPUSH(DTOP)
        MOVE(IMM(1), DTOP)
FUNC_END(m4literal1)
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


FUNC_START(m4negate)
        NEG1(DTOP)
FUNC_END(m4negate)


FUNC_START(m4noop)
FUNC_END(m4noop)


#ifndef M4ONE_MINUS
FUNC_START(m4one_minus) /* 1- */
        SUB2(IMM(1), DTOP);
FUNC_END(m4one_minus)
#endif


#ifndef M4ONE_PLUS
FUNC_START(m4one_plus) /* 1+ */
        ADD2(IMM(1), DTOP);
FUNC_END(m4one_plus)
#endif


FUNC_START(m4over)
        DPUSH(DTOP)
        IGET(DSTK, SZ, DTOP)
FUNC_END(m4over)


FUNC_START(m4plus) /* + */
        DPOP(REG1)
        ADD2(REG1, DTOP)
FUNC_END(m4plus)


#ifndef M4PLUS_STORE
FUNC_START(m4plus_store) /* +! */
        DPOP(REG1)
        LOAD(DTOP, REG2)
        ADD2(REG1, REG2)
        STOR(REG2, DTOP)
        DPOP(DTOP)
FUNC_END(m4plus_store)
#endif /* M4PLUS_STORE */


FUNC_START(m4r_from) /* r> */
        DPUSH(DTOP)
        MOVE(RTOP, DTOP)
        RPOP(RTOP)
FUNC_END(m4r_from)


FUNC_START(m4rot)
        LOAD(DSTK, REG1)
        STOR(DTOP, DSTK)
        IGET(DSTK, SZ, DTOP)
        ISET(REG1, DSTK, SZ)
FUNC_END(m4rot)


FUNC_START(m4star) /* * */
        DPOP(REG1)
        MUL2(REG1, DTOP)
FUNC_END(m4star)


FUNC_START(m4store) /* ! */
        DPOP(REG1)
        STOR(REG1, DTOP)
        DPOP(DTOP)
FUNC_END(m4store)


FUNC_START(m4to_r) /* >r */
        RPUSH(RTOP)
        MOVE(DTOP, RTOP)
        DPOP(DTOP)
FUNC_END(m4to_r)


FUNC_START(m4two_minus) /* 2- */
        SUB2(IMM(2),  DTOP)
FUNC_END(m4two_minus)


FUNC_START(m4two_plus) /* 2+ */
        ADD2(IMM(2), DTOP)
FUNC_END(m4two_plus)


#ifndef M4SWAP
FUNC_START(m4swap)
        LOAD(DSTK, REG1)
        STOR(DTOP, DSTK)
        MOVE(REG1, DTOP)
FUNC_END(m4swap)
#endif


FUNC_START(m4unloop)
        IGET(RSTK, SZ, RTOP)
        ADD2(IMM(SZ2), RSTK)
FUNC_END(m4slash)


        .ident "m4th 0.0.0"
        .section .note.GNU-stack,"",@progbits
