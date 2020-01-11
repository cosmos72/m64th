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


FUNC_START(m4abs)
        /* TODO */
FUNC_END(m4abs)


FUNC_START(m4max)
        /* TODO */
FUNC_END(m4min)


FUNC_START(m4min)
        /* TODO */
FUNC_END(m4min)
        
#define M4LITERAL
FUNC_START(m4literal)
        DPUSH(DTOP)
        ldr DTOP, [IP, IMM(SZ)]!;
FUNC_END(m4literal)

/* mod is unsigned remainder */
FUNC_START(m4mod)
        /* TODO */
FUNC_END(m4mod)


FUNC_START(m4slash) /* / */
        DPOP(REG1)
        DIV3(REG1, DTOP, DTOP)
FUNC_END(m4slash)

/* /mod is unsigned divide & remainder */
FUNC_START(m4slash_mod)
        /* TODO */
FUNC_END(m4slash_mod)

