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

#ifndef M4TH_ASM_S
#error "generic_asm/loop.S can only be included from asm.S - do not attempt to use it directly"
#endif

/** implementation of 'do', enters a (do) ... (loop) */
#ifndef M4_DO_
FUNC_START(_do_)
        RPUSH( RTOP)                 /* save rstack top       */
        DPOP(  REG1)                 /* REG1 = i'             */
        MOVE(  DTOP, RTOP)           /* RTOP = i              */
        RPUSH( REG1)                 /* push i' on rstack     */
        DPOP(  DTOP)                 /* reload dstack top     */
FUNC_END(_do_)
#endif

/**
 * unconditional jump.
 * must be followed by IP offset to skip.
 * IP offset = 0 means first instruction after (jump) itself
 */
#ifndef M4_JUMP_
FUNC_START(_jump_)
        RELJUMP()
FUNC_END(_jump_)
#endif
