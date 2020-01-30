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
#error "generic_asm/mem.S can only be included from asm.S - do not attempt to use it directly"
#endif


FUNC_START(byte_fetch)    /* byte@ */
        LD_sb(DTOP_sb, AT(DTOP))
FUNC_END(byte_fetch)


FUNC_START(short_fetch)    /* short@ */
        LD_sh(DTOP_sh, AT(DTOP))
FUNC_END(short_fetch)


FUNC_START(int_fetch)    /* int@ */
        LD_sw(DTOP_sw, AT(DTOP))
FUNC_END(int_fetch)


FUNC_START(fetch) /* @ */
        LOAD(  DTOP, AT(DTOP))
FUNC_END(fetch)


FUNC_START(c_fetch)    /* c@ */
        LD_ub(DTOP_ub, AT(DTOP))
FUNC_END(c_fetch)


FUNC_START(ushort_fetch)    /* ushort@ */
        LD_uh(DTOP_uh, AT(DTOP))
FUNC_END(ushort_fetch)


FUNC_START(uint_fetch)    /* uint@ */
        LD_uw(DTOP_uw, AT(DTOP))
FUNC_END(uint_fetch)


FUNC_START(c_store)    /* c! */
        DPOP(  REG1)
        STORb( REG1b, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(c_store)


FUNC_START(store) /* ! */
        DPOP(  REG1)
        STOR(  REG1, AT(DTOP))
        DPOP(  DTOP)
FUNC_END(store)
