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

#define M4FSTORE
FUNC_START(store)    /* ! */
        LOAD(  REG1,  AT(DSTK))
        STOR(  REG1,  AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(store)

#define M4FC_STORE
FUNC_START(c_store)    /* c! */
        LOAD(  REG1,  AT(DSTK))
        STORb( REG1b, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(c_store)


#define M4FSHORT_STORE
FUNC_START(short_store)    /* short! */
        LOAD(  REG1,  AT(DSTK))
        STORh( REG1h, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(short_store)


#define M4FINT_STORE
FUNC_START(int_store)    /* int! */
        LOAD(  REG1,  AT(DSTK))
        STORw( REG1w, AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ2))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(int_store)


FUNC_START(cmove)    /* cmove   'string' word set */
        MOVE(  %rdi,  %rax)            /* save DSTK == %rdi */
        MOVE(  %rsi,  %rdx)            /* save RSTK == %rsi */
        LOAD(  %rdi,  AT(%rax))        /* src               */
        LOAD(  %rsi,  AT(%rax, SZ))    /* dst               */
        MOVE(  DTOP,  %rcx)            /* n                 */

        cld;                           /* forward direction */
        rep    movsb (%rsi), (%rdi);   /* copy string       */
        
        lea    AT(%rax,SZ3), DSTK;     /* load DSTK         */
        MOVE(  AT(%rax,SZ2), DTOP)     /* load dstack top   */
        MOVE(  %rdx,   %rsi)           /* load RSTK         */
FUNC_END(cmove)


