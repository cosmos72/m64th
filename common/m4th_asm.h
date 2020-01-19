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

#ifndef M4TH_COMMON_M4TH_ASM_H
#define M4TH_COMMON_M4TH_ASM_H

#define OFF_DSTK SZ      /* offset of m4th->dstack.curr */
#define OFF_DEND SZ2     /* offset of m4th->dstack.end  */
#define OFF_RSTK SZ4     /* offset of m4th->rstack.curr */
#define OFF_W SZ6        /* offset of m4th->w           */
#define OFF_IP SZ7       /* offset of m4th->ip          */
#define OFF_C_SP SZ8     /* offset of m4th->c_sp        */
#define OFF_IN SZ10      /* offset of m4th->in.curr     */
#define OFF_IN_END SZ11  /* offset of m4th->in.end      */
#define OFF_OUT SZ13     /* offset of m4th->out.curr    */
#define OFF_OUT_END SZ14 /* offset of m4th->out.end     */

#endif /* M4TH_COMMON_M4TH_ASM_H */
