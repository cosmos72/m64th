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

#ifndef M4TH_ASM_GCC_H
#define M4TH_ASM_GCC_H

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

/* clang-format on */

#endif /* M4TH_ASM_GCC_H */
