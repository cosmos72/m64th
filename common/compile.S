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
/** push to dstack the XT of word currently being compiled */
FUNC_START(xt) /* (-- xt) */
        DPUSH( DTOP)
        MOVE(  M4XT, DTOP)
FUNC_END(xt)


FUNC_START(xt_code_n_fetch) /* (xt -- xt.code_n) */
        LD_uw(DTOP_wh,   AT(DTOP, XT_OFF_CODE_N))
FUNC_END(xt_code_n_fetch)
#endif /* 0 */


/**
 * (ushort -- ) pop m4enum or 16-bit from dstack and append it to XT being compiled.
 * the standard function 'compile,' calls this function followed by optimizations
 */
FUNC_START(_compile_comma_)    /* (compile,) */
        /* TODO check if enough space */
        LD_uw(REG1_uw, AT(M4XT, XT_OFF_CODE_N)) /* xt.code_n */
        STORe(  DTOPe,   AT(M4XT, REG1, ISZ))     /* xt[xt.code_n] = (m4enum)DTOP */
        INC1(  REG1)
        DPOP(  DTOP)
        STORw( REG1w,    AT(M4XT, XT_OFF_CODE_N)) /* xt.code_n++ */
FUNC_END(_compile_comma_)
