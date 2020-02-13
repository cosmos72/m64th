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

#ifndef M4TH_ASM_S
#define M4TH_ASM_S

/* clang-format off */

        .file "asm.S"

#include "include/section.mh"
#include "include/marker.mh"

SECTION_FUNC()
MARKER(asm_func_start)

#if defined(__x86_64__)
#include "amd64/arith.S"
#include "amd64/call.S"
#include "amd64/core.S"
#include "amd64/io.S"
#include "amd64/loop.S"
#include "amd64/mem.S"
#elif defined(__aarch64__)
#include "arm64/arith.S"
#include "arm64/call.S"
#include "arm64/core.S"
#include "arm64/io.S"
#include "arm64/loop.S"
#include "arm64/mem.S"
#else
#error "unsupported architecture: expecting x86_64 (amd64) or aarch64 (arm64)"
#endif

#include "generic_asm/arith.S"
#include "generic_asm/call.S"
#include "generic_asm/compile.S"
#include "generic_asm/core.S"
#include "generic_asm/loop.S"
#include "generic_asm/mem.S"

MARKER(asm_func_end)
SECTION_RODATA()
MARKER(asm_data_start)

#include "generic_asm/dict_forth.S"
#include "generic_asm/dict_m4th.S"

MARKER(asm_data_end)

        .ident "m4th 0.0.0"
        .section .note.GNU-stack,"",@progbits

#endif /* M4TH_ASM_S */
