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

FUNC_START(m4cr)
        IGET( M4TH, OFF_OUT, REG1)
        /* TODO check buffer full */
        movb  IMM(10), (REG1);
        inc   REG1;
        ISET( REG1, M4TH, OFF_OUT)
FUNC_END(m4cr)


FUNC_START(m4emit)
        IGET( M4TH, OFF_OUT, REG1)
        /* TODO check buffer full */
        movb  DTOPb, (REG1);
        inc   REG1;
        DPOP( DTOP)
        ISET( REG1, M4TH, OFF_OUT)
FUNC_END(m4emit)


FUNC_START(m4key)
        IGET(  M4TH, OFF_IN, REG1)
	cmp    OFF_IN_END(M4TH), REG1;
	jge    m4bye; /* TODO read from stdin instead */
        DPUSH( DTOP)
        incq   OFF_IN(M4TH)
        movzbq (REG1), DTOP;
FUNC_END(m4key)


