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

#ifndef M4TH_M4TH_ASM_H
#error "common/compile.h can only be included from asm.S - do not attempt to use it directly"
#endif

/* literal: compile the literal number found on the stack */
FUNC_START(m4literal)
        FADDR( m4_lit_, REG1)
        CPUSH(REG1, DTOP)
        DPOP(  DTOP)
FUNC_END(m4literal)
