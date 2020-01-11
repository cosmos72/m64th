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

        .file "arith.S"
        .text

       
#if defined(__x86_64__)
#include "amd64/arith.S"
#elif defined(__aarch64__)
#include "arm64/arith.S"
#else
#error "unsupported architecture: expecting amd64 or arm64"
#endif

FUNC_START(m4at) /* @ */
        LOAD(DTOP, DTOP)
FUNC_END(m4at)

FUNC_START(m4drop)
        DPOP(DTOP)
FUNC_END(m4drop)

FUNC_START(m4dup)
        DPUSH(DTOP)
FUNC_END(m4dup)

#ifndef M4LITERAL
FUNC_START(m4literal)
        ADD2(IMM(SZ), IP)
        DPUSH(DTOP)
        LOAD(IP, DTOP)
FUNC_END(m4literal)
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

FUNC_START(m4noop)
FUNC_END(m4noop)
        
FUNC_START(m4plus) /* + */
        DPOP(REG1)
        ADD2(REG1, DTOP)
FUNC_END(m4plus)

FUNC_START(m4star) /* * */
        DPOP(REG1)
        MUL2(REG1, DTOP)
FUNC_END(m4star)

        .ident "m4th 0.0.0"
        .section .note.GNU-stack,"",@progbits
