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

/**
 * enter m4th interpreter from C:
 * save C registers,
 * load m4th registers from struct (m4th*)
 *      passed in x0 as per aarch64 ABI,
 * execute m4th->rstack[0] and subsequent code until m4th_bye is found.
 */
FUNC_START(m4th_enter)
        MOVE(x0, M4TH)             /* m                         */
        IGET(M4TH, OFF_DSTK, DSTK) /* load data   stack pointer */
        IGET(M4TH, OFF_RSTK, RSTK) /* load return stack pointer */
        IGET(M4TH, OFF_IP,   IP)   /* load instruction  pointer */
        DPOP(DTOP)                 /* load first data   stack element  */
        RPOP(RTOP)                 /* load first return stack element  */
        LOAD(IP,   REG1)           /* begin execution */
        br   REG1;
FUNC_RAWEND(m4th_enter)

/**
 * exit m4th interpreter and return to C:
 * save m4th registers into struct (m4th*)
 * load C registers
 * return to C
 */
FUNC_START(m4bye)
        RPUSH(RTOP)                /* save first return stack element */
        DPUSH(DTOP)                /* save first data   stack element */
        ISET(IP,   M4TH, OFF_IP)   /* save instruction  pointer */
        ISET(RSTK, M4TH, OFF_RSTK) /* save return stack pointer */
        ISET(DSTK, M4TH, OFF_DSTK) /* save data   stack pointer */
        ret;                       /* return to C               */
FUNC_RAWEND(m4bye)


/** return from word being executed (i.e. current function) */
FUNC_START(m4exit)
        MOVE(RTOP, IP)
        RPOP(RTOP)
        LOAD(IP, REG1)
        br   REG1;
FUNC_RAWEND(m4exit)
