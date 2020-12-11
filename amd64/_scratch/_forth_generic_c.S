/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "../../dispatch/asm.mh"
#include "../../include/section.mh"

SECTION_FUNC()

/* clang-format off */

FUNC_START(_next_)
    movzwl (%r8),%r10d;
    mov    0x38(%r9),%rax;
    add    $0x2,%r8;
    jmpq   *(%rax,%r10,8);
FUNC_RAWEND(_next_)

        .ident "m64th 0.0.0"
        .section .note.GNU-stack,"",@progbits
