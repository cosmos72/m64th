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

/* clang-format off */

FUNC_START(cmove)    /* cmove   'string' word set */
        DPOP(  REG2)            /* REG2 = dst   */
        DPOP(  REG1)            /* REG1 = src   */
        ZERO(  REG0)            /* REG0 = index */
        b      .Lcmove.test;
.Lcmove.loop:
        LD_ub( REG3_ub,AT(REG1, REG0))
        STORb( REG3b,  AT(REG2, REG0))
        ADD2(  IMM(1), REG0)
.Lcmove.test:
        cmp    REG0,   DTOP;
        b.lt   .Lcmove.loop;
        DPOP(  DTOP)
FUNC_END(cmove)


FUNC_START(string_equal)   /* string=  ( addr1 addr2 u -- t|f ) m4th-user */
        DPOP(  REG2)       /* b = addr2 */
        DPOP(  REG1)       /* a = addr1 */
#if 0
        cmp    REG1,   REG2;
        je     LABEL_SYM(string_equal.true); /* addr1 == addr2 */
        JZ(    DTOP,   string_equal.true)    /* u == 0         */
        ZERO(  REG0)
LABEL(string_equal.iter)
        LD_ub( REG3_ub,AT(REG1, REG0, 1))
        cmpb   REG3b,  AT(REG2, REG0, 1);
        jne    LABEL_SYM(string_equal.false);
        INC1(  REG0)
        cmp    REG0,   DTOP;
        jne    LABEL_SYM(string_equal.iter);
LABEL(string_equal.true)
        MOVE(  RFFF,   DTOP)
        NEXT()
LABEL(string_equal.false)
#endif
        ZERO(  DTOP)
FUNC_END(string_equal)

