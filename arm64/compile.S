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

#include "asm.mh"

/** (int32 -- ) pop int32 from dstack and append it to XT being compiled. */
#define M4F_COMPILE4S_
FUNC_START(_compile4s_)    /* (compile-4s,) */
        /* TODO check if enough space */
        LD_uh( REG1_uh,    AT(RXT, XT_OFF_CODE_N))     /* xt.code_n */
        lsl    REG2,       REG1,    IMM(PSZt);
        STORw( DTOPw,      AT(RXT, REG2))              /* xt[xt.code_n] = (int32)DTOP */
        ADD2(  IMM(4/SZt), REG1)
        DPOP(  DTOP)
        STORh( REG1h,      AT(RXT, XT_OFF_CODE_N))     /* xt.code_n += 4/SZt */
FUNC_END(_compile4s_)


/** (int64 -- ) pop int64 from dstack and append it to XT being compiled. */
#define M4F_COMPILE8S_
FUNC_START(_compile8s_)    /* (compile-8s,) */
        /* TODO check if enough space */
        LD_uh( REG1_uh,    AT(RXT, XT_OFF_CODE_N))     /* xt.code_n */
        lsl    REG2,       REG1,    IMM(PSZt);
        STOR(  DTOP,       AT(RXT, REG2))              /* xt[xt.code_n] = (int32)DTOP */
        ADD2(  IMM(8/SZt), REG1)
        DPOP(  DTOP)
        STORh( REG1h,      AT(RXT, XT_OFF_CODE_N))     /* xt.code_n += 8/SZt */
FUNC_END(_compile8s_)
