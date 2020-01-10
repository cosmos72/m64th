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

#define FUNC_START(name) \
                      .globl    name; \
                      .type     name,   @function; \
name: \
                      .cfi_startproc;

#define FUNC_RAWEND(name) \
                      .cfi_endproc; \
                      .size     name,   .-name;

#define FUNC_NEXT(name)                         \
/* .name.next: */ \
                      NEXT()

#define FUNC_END(name) \
                      FUNC_NEXT(name) \
                      FUNC_RAWEND(name)

#define FUNC(name, ...) \
                      FUNC_START(name) \
                      __VA_ARGS__ \
                      FUNC_END(name)

#endif /* M4TH_ASM_GCC_H */
