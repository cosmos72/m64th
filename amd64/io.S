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

FUNC_START(cr)
        LOAD(  REG1, AT(M4TH, M4TH_OFF_OUT))
        /* TODO check buffer full */
        movb   IMM(10), (REG1);
        inc    REG1;
        STOR(  REG1, AT(M4TH, M4TH_OFF_OUT))
FUNC_END(cr)


FUNC_START(emit)
        LOAD( REG1, AT(M4TH, M4TH_OFF_OUT))
        /* TODO check buffer full */
        STORb( DTOPb, AT(REG1))
        inc    REG1;
        DPOP(  DTOP)
        STOR(  REG1, AT(M4TH, M4TH_OFF_OUT))
FUNC_END(emit)


FUNC_START(key)
        LOAD(  REG1, AT(M4TH, M4TH_OFF_IN))
	cmp    M4TH_OFF_IN_END(M4TH), REG1;
	jge    FUNC_SYM(bye); /* TODO read from stdin instead */
        DPUSH( DTOP)
        incq   M4TH_OFF_IN(M4TH)
        movzbq (REG1), DTOP;
FUNC_END(key)


