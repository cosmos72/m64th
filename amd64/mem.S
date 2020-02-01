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

#define M4C_STORE
FUNC_START(c_store)    /* c! */
        LOAD(  REG1,  AT(DSTK))
        STORb( REG1b, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(c_store)


#define M4SHORT_STORE
FUNC_START(short_store)    /* short! */
        LOAD(  REG1,  AT(DSTK))
        STORh( REG1h, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(short_store)


#define M4INT_STORE
FUNC_START(int_store)    /* int! */
        LOAD(  REG1,  AT(DSTK))
        STORw( REG1w, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(int_store)


#define M4STORE
FUNC_START(store)    /* ! */
        LOAD(  REG1,  AT(DSTK))
        STOR(  REG1,  AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(store)

