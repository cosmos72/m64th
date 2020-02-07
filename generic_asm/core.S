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


/**
  * push to dstack vm's current instruction pointer,
  * i.e. the address of the (ip) m4token itself inside the code being executed
  */
FUNC_START(_ip_)
        DPUSH( DTOP)
#ifdef LEA                            /* IP actually points to next instruction: fix it */
        LEA(   DTOP,   AT(IP,-SZt))   
#else
        SUB3(  IP, IMM(SZt), DTOP)
#endif
FUNC_END(_ip_)


/**
  * push to dstack the data address of word being executed.
  * must be the first instruction in the word's code.
  */
FUNC_START(_ip_to_body_)
        DPUSH( DTOP)
#ifdef LEA                            /* IP actually points to next instruction: fix it */
        LEA(   DTOP,   AT(IP,-SZt))
#else
        SUB3(  IP, IMM(SZt), DTOP)
#endif
        LD_uh( REG1_uh,    AT(DTOP, XT_OFF_CODE_N)) /* REG1 = code_n    */
        SHL2(  IMM(PSZt),  REG1)                    /* REG1 = data offset in bytes */
        ADD2(  REG1,       DTOP)                    /* DTOP = unaligned(data_addr) */
        ALIGN( SZ,         DTOP)                    /* DTOP = aligned(data_addr)   */
FUNC_END(_ip_to_body_)


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
        ADD2(  DTOP,       REG1)                    /* REG1 = unaligned(data_addr) */
        ALIGN( SZ,         REG1)                    /* REG1 = aligned(data_addr)   */
        LD_uw( DTOP_uw,    AT(DTOP, XT_OFF_DATA_N)) /* dtop = data_n    */
        DPUSH( REG1)                                /*  d2 = data_addr  */
FUNC_END(xt_to_data)


FUNC_START(xt_to_data_addr) /* ( xt -- caddr ) */
        LD_uh( REG1_uh,    AT(DTOP, XT_OFF_CODE_N)) /* REG1 = code_n    */
        SHL2(  IMM(PSZt),  REG1)                    /* REG1 = data offset in bytes */
        ADD2(  REG1,       DTOP)                    /* DTOP = unaligned(data_addr) */
        ALIGN( SZ,         DTOP)                    /* DTOP = aligned(data_addr)   */
FUNC_END(xt_to_data_addr)


FUNC_START(xt_to_data_n) /* ( xt -- n ) */
        LD_uw( DTOP_uw,    AT(DTOP, XT_OFF_DATA_N)) /* dtop = data_n    */
FUNC_END(xt_to_data_n)


FUNC_START(xt_to_flags) /* ( xt -- m4flags ) */
        LD_uh( DTOP_uh,    AT(DTOP, XT_OFF_FLAGS)) /* dtop = m4flags    */
FUNC_END(xt_to_flags)
