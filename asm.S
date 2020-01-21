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

        .file "asm.S"

#include "common/section.mh"
#include "common/marker.mh"

SECTION_FUNC()
/* MARKER(asm_func_start) */

#if defined(__x86_64__)
#include "amd64/arith.S"
#include "amd64/call.S"
#include "amd64/io.S"
#include "amd64/loop.S"
#elif defined(__aarch64__)
#include "arm64/arith.S"
#include "arm64/call.S"
#include "arm64/io.S"
#include "arm64/loop.S"
#else
#error "unsupported architecture: expecting amd64 or arm64"
#endif

#include "common/arith.S"
#include "common/compile.S"

/* MARKER(asm_func_end) */
SECTION_RODATA()
/* MARKER(asm_data_start) */

#include "common/dict_forth.S"
#include "common/dict_m4th_user.S"
#include "common/dict_m4th_impl.S"

/* MARKER(asm_data_end) */

        .ident "m4th 0.0.0"
        .section .note.GNU-stack,"",@progbits

#endif /* M4TH_ASM_S */
