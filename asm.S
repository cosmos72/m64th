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

#ifndef M64TH_ASM_S
#define M64TH_ASM_S

/* clang-format off */

        .file "asm.S"

#include "include/marker.mh"
#include "include/section.mh"

SECTION_FUNC()
MARKER(asm_func_start)

#if defined(__x86_64__)
#include "amd64/arith.S"
#include "amd64/double.S"
#include "amd64/call.S"
#include "amd64/compile.S"
#include "amd64/core.S"
#include "amd64/loop.S"
#include "amd64/mem.S"
#include "amd64/native.S"
#elif defined(__aarch64__)
#include "arm64/arith.S"
#include "arm64/double.S"
#include "arm64/call.S"
#include "arm64/compile.S"
#include "arm64/core.S"
#include "arm64/loop.S"
#include "arm64/mem.S"
#include "arm64/native.S"
#else
#error "unsupported architecture: expecting x86_64 (amd64) or aarch64 (arm64)"
#endif

#include "generic_asm/arith.S"
#include "generic_asm/double.S"
#include "generic_asm/call.S"
#include "generic_asm/compile.S"
#include "generic_asm/core.S"
#include "generic_asm/io.S"
#include "generic_asm/local.S"
#include "generic_asm/loop.S"
#include "generic_asm/mem.S"
#include "generic_asm/native.S"

#include "generic_asm/test.S" /* only used for test & benchmark */

MARKER(asm_func_end)
SECTION_RODATA_REL()
MARKER(asm_rodata_start)

#include "forth/std.S"
#include "forth/m64th.S"

MARKER(asm_rodata_end)
SECTION_DATA()
MARKER(asm_rwdata_start)

WORDLIST(forth)
WORDLIST(forth_root)
WORDLIST(m64th_asm)
WORDLIST(m64th_c)
WORDLIST(m64th_core)
WORDLIST(m64th_impl)
WORDLIST(m64th_user)

MARKER(asm_rwdata_end)

        .ident "m64th 0.0.0"
        .section .note.GNU-stack,"",@progbits

#endif /* M64TH_ASM_S */
