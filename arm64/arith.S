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

#include "asm.h"


/* signed divide */
FUNC_START(m4slash) /* / */
        DPOP(REG1)
        DIV3(REG1, DTOP, DTOP)
FUNC_END(m4slash)


/* signed divide & remainder */
FUNC_START(m4slash_mod)  /* /mod */
        LOAD(  REG1, AT(DSTK))
        DIV3(  REG1, DTOP, REG2)
        msub   REG1, REG2, DTOP, REG1;
        MOVE(  REG2, DTOP)
        STOR(  REG1, AT(DSTK))
FUNC_END(m4slash_mod)


FUNC_START(m4zero_less)   /* 0<   */
        asr   DTOP, DTOP, IMM(63)
FUNC_END(m4zero_less)


FUNC_START(m4zero_not_equals)   /* 0<>  core ext */
        cmp   DTOP, IMM(0)
        csetm DTOP, ne
FUNC_END(m4zero_not_equals)


FUNC_START(m4zero_equals)   /* 0=   */
        cmp   DTOP, IMM(0)
        csetm DTOP, eq
FUNC_END(m4zero_equals)


FUNC_START(m4zero_greater_than)   /* 0>   */
        cmp   DTOP, IMM(0)
        csetm DTOP, gt
FUNC_END(m4zero_greater_than)


FUNC_START(m4two_slash) /* 2/   */
        add   DTOP, DTOP, DTOP, lsr IMM(63)
        asr   DTOP, DTOP, IMM(1)
FUNC_END(m4two_slash)


FUNC_START(m4two_star) /* 2* */
        lsl   DTOP, DTOP, IMM(1)
FUNC_END(m4two_star)


FUNC_START(m4less_than)   /* < */
        DPOP(  REG2)
        cmp    REG2, DTOP
        csetm  DTOP, lt
FUNC_END(m4less_than)


FUNC_START(m4not_equals)   /* <>   core ext */
        DPOP(REG2)
        cmp   REG2, DTOP
        csetm DTOP, ne
FUNC_END(m4not_equals)


FUNC_START(m4equals)   /* = */
        DPOP(  REG2)
        cmp    REG2, DTOP
        csetm  DTOP, eq
FUNC_END(m4equals)


FUNC_START(m4greater_than)   /* > */
        DPOP(REG2)
        cmp   REG2, DTOP
        csetm DTOP, gt
FUNC_END(m4greater_than)


FUNC_START(m4abs)
        cmp    DTOP, IMM(0);
        cneg   DTOP, DTOP, lt;
FUNC_END(m4abs)


FUNC_START(m4c_store) /* c! */
        DPOP(  REG1)
        strb   REG1w, [DTOP];
        DPOP(  DTOP)
FUNC_END(m4c_store)


FUNC_START(m4c_fetch) /* c@ */
        ldrb   DTOPw, [DTOP];
FUNC_END(m4c_fetch)


FUNC_START(m4max)
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csel   DTOP, REG2, DTOP, gt
FUNC_END(m4max)


FUNC_START(m4min)
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csel   DTOP, REG2, DTOP, lt
FUNC_END(m4min)
        
/* signed remainder */
FUNC_START(m4mod)
        DPOP(  REG1)
        DIV3(  REG1, DTOP, REG2)
        msub   DTOP, REG2, DTOP, REG1;
FUNC_END(m4mod)


FUNC_START(m4xor)
        DPOP(REG1)
        eor   DTOP, DTOP, REG1;
FUNC_END(m4xor)
