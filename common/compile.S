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
#error "common/compile.h can only be included from asm.S - do not attempt to use it directly"
#endif

#if 0
/* push to dstack the address of word currently being compiled */
FUNC_START(_word) /* (-- word) */
        DPUSH( DTOP)
        MOVE(  M4W, DTOP)
FUNC_END(_word)


FUNC_START(_word_code) /* (word -- word.code) */
        ADD2(  IMM(WORD_OFF_CODE_N), DTOP)
FUNC_END(_word_code)


FUNC_START(_word_code_n_fetch) /* (word -- word.code_n) */
        LOAD_uh(DTOP_uh,   AT(DTOP, WORD_OFF_CODE_N))
FUNC_END(_word_code_n_fetch)
#endif /* 0 */


/*
 * (xt -- ) pop xt or number from dstack and append it to current word's code
 * the standard function compile, calls this function followed by optimizations
 */
FUNC_START(_compile_comma_)    /* (compile,) */
        /* TODO check if enough space */
        LOAD_uh(REG1_uh,   AT(M4W, WORD_OFF_CODE_N)) /* word.code_n */
        STOR(  DTOP,   AT(M4W, REG1, SZ)) /* word.code[word.code_n] = DTOP */
        INC1(  REG1)
        STORh( REG1h,  AT(M4W, WORD_OFF_CODE_N)) /* word.code_n++ */
        DPOP(  DTOP)
FUNC_END(_compile_comma_)
