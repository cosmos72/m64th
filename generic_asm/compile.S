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
#error "generic_asm/compile.S can only be included from asm.S - do not attempt to use it directly"
#endif

#if 0
/** push to dstack the XT of word currently being compiled */
FUNC_START(xt) /* (-- xt) */
        DPUSH( DTOP)
        MOVE(  M4XT, DTOP)
FUNC_END(xt)


FUNC_START(xt_code_n_fetch) /* (xt -- xt.code_n) */
        LD_uh(DTOP_uh,   AT(DTOP, XT_OFF_CODE_N))
FUNC_END(xt_code_n_fetch)
#endif /* 0 */

#ifndef M4_COMPILE2S_
/** (int16 -- ) pop int16 from dstack and append it to XT being compiled. */
FUNC_START(_compile2s_)    /* (compile-2s,) */
        /* TODO check if enough space */
        LD_uh( REG1_uh,    AT(M4XT, XT_OFF_CODE_N))    /* xt.code_n */
        STORh( DTOPh,      AT(M4XT, REG1, SZt))        /* xt[xt.code_n] = (int16)DTOP */
        ADD2(  IMM(2/SZt), REG1)
        DPOP(  DTOP)
        STORh( REG1h,      AT(M4XT, XT_OFF_CODE_N))    /* xt.code_n += 2/SZt */
FUNC_END(_compile2s_)
#endif


#ifndef M4_COMPILE_LIT2S_
/** ( -- ) must be followed by int16, append it to XT being compiled. */
FUNC_START(_compile_lit2s_)    /* (compile-lit-2s,) */
        /* TODO check if enough space */
        LD_sh( REG2_sh,    AT(IP))                     /* REG1 = int16          */
        LD_uh( REG1_uh,    AT(M4XT, XT_OFF_CODE_N))    /* xt.code_n             */
        STORh( REG2h,      AT(M4XT, REG1, SZt))        /* xt[xt.code_n] = int16 */
        ADD2(  IMM(2/SZt), REG1)
        STORh( REG1h,      AT(M4XT, XT_OFF_CODE_N))    /* xt.code_n ++          */
        NEXT2()                                        /* skip int16            */
FUNC_RAWEND(_compile_lit2s_)
#endif

