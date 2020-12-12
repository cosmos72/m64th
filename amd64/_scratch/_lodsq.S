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

#include "asm.mh"

#define m4fmain main

/* clang-format off */

.data
WORD_DEF_SYM(mystr)
        .8byte 0x12345678;

.text
FUNC_START(main)
        movl   $1000000000,%ecx;
LABEL(main.again)
        ADDROF_1M(WORD_SYM(mystr),  %rsi)
#if 1
        lodsq  (%rsi),     %rax;
#else
        movq   (%rsi),     %rax;
        addq   $8,         %rsi;
#endif
#if 0
        loop               TO(main.again);  /* VERY slow */
#else
        decq   %rcx;
        jnz                TO(main.again);
#endif
FUNC_END(main)
