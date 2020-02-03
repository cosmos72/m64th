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

#include "../dispatch/asm.mh"


FUNC_START(xt_to_code) /* ( xt -- taddr n ) */
        DPUSH( DTOP)                                /*  d2 = taddr = xt */
        LD_uh( DTOP_uh,    AT(DTOP, XT_OFF_CODE_N)) /* dtop = code_n    */
FUNC_END(xt_to_code)


FUNC_START(xt_to_code_n) /* ( xt -- n ) */
        LD_uh( DTOP_uh,    AT(DTOP, XT_OFF_CODE_N)) /* dtop = code_n    */
FUNC_END(xt_to_code_n)


FUNC_START(xt_to_data) /* ( xt -- caddr n ) */
        LD_uh( REG1_uh,    AT(DTOP, XT_OFF_CODE_N)) /* REG1 = code_n    */
        SHL2(  IMM(PSZt),  REG1)                    /* REG1 = data offset in bytes */
        ADD2(  DTOP,       REG1)                    /* REG1 = data_addr */
        LOAD(  DTOP,       AT(DTOP, XT_OFF_DATA_N)) /* dtop = data_n    */
        DPUSH( REG1)                                /*  d2 = data_addr  */
FUNC_END(xt_to_data)


FUNC_START(xt_to_data_addr) /* ( xt -- caddr ) */
        LD_uh( REG1_uh,    AT(DTOP, XT_OFF_CODE_N)) /* REG1 = code_n    */
        SHL2(  IMM(PSZt),  REG1)                    /* REG1 = data offset in bytes */
        ADD2(  REG1,       DTOP)                    /* DTOP = data_addr */
FUNC_END(xt_to_data_addr)


FUNC_START(xt_to_data_n) /* ( xt -- n ) */
        LOAD(  DTOP,       AT(DTOP, XT_OFF_DATA_N)) /* dtop = data_n    */
FUNC_END(xt_to_data_n)


FUNC_START(xt_to_flags) /* ( xt -- m4flags ) */
        LD_uh( DTOP_uh,    AT(DTOP, XT_OFF_FLAGS)) /* dtop = m4flags    */
FUNC_END(xt_to_flags)
