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


/** pop XT from dstack and call it. */
FUNC_START(execute)
        RPUSH( RTOP)               /* save RTOP                */
        MOVE(  IP,     RTOP)       /* save return address = IP */
        MOVE(  DTOP,   IP)         /* set IP = XT              */
        DPOP(  DTOP)               /* reload dstack top        */
        NEXT0()
FUNC_RAWEND(execute)


/** exit from current XT being executed */
FUNC_START(exit)
        MOVE(  RTOP, IP)
        RPOP(  RTOP)
        NEXT0()
FUNC_RAWEND(exit)
