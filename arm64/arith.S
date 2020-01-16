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
FUNC_START(slash) /* / */
        DPOP(  REG1)
        DIV3(  REG1, DTOP, DTOP)
FUNC_END(slash)


/* signed divide & remainder */
FUNC_START(slash_mod)  /* /mod */
        LOAD(  REG1, AT(DSTK))
        DIV3(  REG1, DTOP, REG2)
        msub   REG1, REG2, DTOP, REG1;
        MOVE(  REG2, DTOP)
        STOR(  REG1, AT(DSTK))
FUNC_END(slash_mod)


FUNC_START(zero_not_equals)   /* 0<>  core ext */
        cmp    DTOP, IMM(0)
        csetm  DTOP, ne
FUNC_END(zero_not_equals)


FUNC_START(zero_equals)   /* 0=   */
        cmp    DTOP, IMM(0)
        csetm  DTOP, eq
FUNC_END(zero_equals)


FUNC_START(zero_greater_than)   /* 0>   */
        cmp    DTOP, IMM(0)
        csetm  DTOP, gt
FUNC_END(zero_greater_than)


FUNC_START(two_slash) /* 2/   */
        add    DTOP, DTOP, DTOP, lsr IMM(63)
        asr    DTOP, DTOP, IMM(1)
FUNC_END(two_slash)


FUNC_START(two_star) /* 2* */
        lsl    DTOP, DTOP, IMM(1)
FUNC_END(two_star)


FUNC_START(less_than)   /* < */
        DPOP(  REG2)
        cmp    REG2, DTOP
        csetm  DTOP, lt
FUNC_END(less_than)


FUNC_START(not_equals)   /* <>   core ext */
        DPOP(  REG2)
        cmp    REG2, DTOP
        csetm  DTOP, ne
FUNC_END(not_equals)


FUNC_START(equals)   /* = */
        DPOP(  REG2)
        cmp    REG2, DTOP
        csetm  DTOP, eq
FUNC_END(equals)


FUNC_START(greater_than)   /* > */
        DPOP(  REG2)
        cmp    REG2, DTOP
        csetm  DTOP, gt
FUNC_END(greater_than)


FUNC_START(question_dupe)   /* ?dup */
        cbz    DTOP, FUNC_SYM_NEXT(question_dupe);
        DPUSH( DTOP)
FUNC_END(question_dupe)


FUNC_START(abs)
        cmp    DTOP, IMM(0);
        cneg   DTOP, DTOP, lt;
FUNC_END(abs)


FUNC_START(c_store) /* c! */
        DPOP(  REG1)
        strb   REG1w, [DTOP];
        DPOP(  DTOP)
FUNC_END(c_store)


FUNC_START(c_fetch) /* c@ */
        ldrb   DTOPw, [DTOP];
FUNC_END(c_fetch)


FUNC_START(max)
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csel   DTOP, REG2, DTOP, gt
FUNC_END(max)


FUNC_START(min)
        DPOP(  REG2)
        cmp    REG2, DTOP;
        csel   DTOP, REG2, DTOP, lt
FUNC_END(min)
        
/* signed remainder */
FUNC_START(mod)
        DPOP(  REG1)
        DIV3(  REG1, DTOP, REG2)
        msub   DTOP, REG2, DTOP, REG1;
FUNC_END(mod)


FUNC_START(xor)
        DPOP(  REG1)
        eor    DTOP, DTOP, REG1;
FUNC_END(xor)
