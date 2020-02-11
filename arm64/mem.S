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


