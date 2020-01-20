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
FUNC_START(word_code_n) /* (word -- word.code_n) */
        LOAD_sb(DTOP_sb, AT(DTOP, WORD_OFF_CODE_N))
        LOAD_sh(DTOP_sh, AT(DTOP, WORD_OFF_CODE_N))
        LOAD_sw(DTOP_sw, AT(DTOP, WORD_OFF_CODE_N))
        LOAD_ub(DTOP_ub, AT(DTOP, WORD_OFF_CODE_N))
        LOAD_uh(DTOP_uh, AT(DTOP, WORD_OFF_CODE_N))
        LOAD_uw(DTOP_uw, AT(DTOP, WORD_OFF_CODE_N))
        LOAD(   DTOP,    AT(DTOP, WORD_OFF_CODE_N))
        STORb(  DTOPb,   AT(DTOP, WORD_OFF_CODE_N))
        STORh(  DTOPh,   AT(DTOP, WORD_OFF_CODE_N))
        STORw(  DTOPw,   AT(DTOP, WORD_OFF_CODE_N))
        STOR(   DTOP,    AT(DTOP, WORD_OFF_CODE_N))
FUNC_END(word_code_n)
#endif /* 0 */

/* compile, : pop xt from dstack and append it to current word's code */
FUNC_START(compile_comma)
        /* TODO check if enough space */
        DPOP(  DTOP)
FUNC_END(compile_comma)

/* literal: compile the literal number found on the stack */
FUNC_START(literal)
#if 0
        FADDR( m4_lit_, REG1)
        IPUSH2(REG1, DTOP)
#endif /* 0 */
        DPOP(  DTOP)
FUNC_END(literal)
