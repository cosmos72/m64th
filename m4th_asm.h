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

#ifndef M4TH_M4TH_ASM_H
#define M4TH_M4TH_ASM_H

/* clang-format off */

/* align functions at 8 bytes. */
/* on x86_64, aligning at 16 bytes should be faster, but wastes more memory */
#define FUNC_ALIGN()                                                                               \
    .p2align 3

#define FUNC_START(name)                                                                           \
    FUNC_ALIGN();                                                                                  \
    .globl name;                                                                                   \
    .type name, @function;                                                                         \
    name:                                                                                          \
    .cfi_startproc;

#define FUNC_RAWEND(name)                                                                          \
    .cfi_endproc;                                                                                  \
    .size name, .- name;

#define FUNC_END(name)                                                                             \
    .name.next:                                                                                    \
    NEXT()                                                                                         \
    FUNC_RAWEND(name)

/* expand AT(addr) -> AT0(addr) and AT(addr, i) -> ATx(addr, i) */
#define AT_0(addr, i)           AT0(addr)
#define AT_x(addr, i)           ATx(addr, i)
#define AT_(addr, i, kind, ...) AT_##kind(addr, i)
#define AT(...)                 AT_(__VA_ARGS__, x, 0)

/* expand CPUSH(a) -> CPUSH1(a) and CPUSH(a, b) -> CPUSH2(a, b) */
#define CPUSH_1(a, b)           CPUSH1(a)
#define CPUSH_2(a, b)           CPUSH2(a, b)
#define CPUSH_(a, b, kind, ...) CPUSH_##kind(a, b)
#define CPUSH(...)              CPUSH_(__VA_ARGS__, 2, 1)

#define OFF_DSTK    SZ   /* offset of m4th->dstack.curr */
#define OFF_DEND    SZ2  /* offset of m4th->dstack.end  */
#define OFF_RSTK    SZ4  /* offset of m4th->rstack.curr */
#define OFF_CODE    SZ6  /* offset of m4th->code.start  */
#define OFF_CSTK    SZ7  /* offset of m4th->code.curr   */
#define OFF_IP      SZ9  /* offset of m4th->ip          */
#define OFF_C_SP    SZ10 /* offset of m4th->c_sp        */
#define OFF_IN      SZ12 /* offset of m4th->in.curr     */
#define OFF_IN_END  SZ13 /* offset of m4th->in.end      */
#define OFF_OUT     SZ15 /* offset of m4th->out.curr    */
#define OFF_OUT_END SZ16 /* offset of m4th->out.end     */

/* clang-format on */

#endif /* M4TH_M4TH_ASM_H */
