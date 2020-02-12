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
        cmp    REG1,   REG2;
        b.eq   LABEL_SYM(string_equal.true); /* addr1 == addr2 */
        JZ(    DTOP,     string_equal.true)  /* u == 0         */
        ZERO(  REG0)
        cmp    DTOP,   IMM(8);
        b.lo   LABEL_SYM(string_equal.byte);
        SUB2(  IMM(8), DTOP)
LABEL(string_equal.cell)
        LOAD(  REG3,   AT(REG1, REG0, 1))
        LOAD(  REG4,   AT(REG2, REG0, 1))
        cmp    REG3,   REG4;
        b.ne   LABEL_SYM(string_equal.false);
        ADD2(  IMM(8), REG0)
        cmp    REG0,   DTOP;
        b.lo   LABEL_SYM(string_equal.cell);
        LOAD(  REG3,   AT(REG1, DTOP, 1)) /* compare last 8 bytes */
        LOAD(  REG4,   AT(REG2, DTOP, 1))
        cmp    REG3,   REG4;
        b.ne   LABEL_SYM(string_equal.false);
        JUMP(  string_equal.true)
LABEL(string_equal.byte)
        LD_ub( REG3_ub,AT(REG1, REG0, 1))
        LD_ub( REG4_ub,AT(REG2, REG0, 1))
        cmp    REG3,   REG4;
        b.ne   LABEL_SYM(string_equal.false);
        INC1(  REG0)
        cmp    REG0,   DTOP;
        b.lo   LABEL_SYM(string_equal.byte);
LABEL(string_equal.true)
        MOVE(  IMM(-1),DTOP)
        NEXT()
LABEL(string_equal.false)
        ZERO(  DTOP)
FUNC_END(string_equal)

