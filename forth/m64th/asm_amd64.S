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

#include "../../include/asm.mh"
#include "../../include/dict.mh"
#include "../../include/m64th/dict.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m64th-asm   arch-specific words for amd64 ------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

/* ( jump_location jump_category -- ) resolve an ASM jump to here */
WORD_START(_asm_resolve_jump_here_,  LASTWORD)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        /**
         * ASM relative jumps are quite simple on amd64:
         * their jump offset occupies either 1 byte (not used by m64th) or 4 bytes,
         * and it's exactly the distance in bytes from the end of the jump instruction.
         */
        drop,                                  /* ( jump_location                  ) */
        asm_start, plus,                       /* ( addr_of_jump_offset+4          ) */
        dup, four_minus, swap,                 /* ( addr addr+4                    ) */
        asm_here, sub,                         /* ( addr distance                  ) */
        swap, int_store, exit                  /* (                                ) */
    )
WORD_END(_asm_resolve_jump_here_)
/* ( jump_location jump_category -- ) resolve an ASM jump from here */
WORD_START(_asm_resolve_jump_there_,  _asm_resolve_jump_here_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        /* see comment above for amd64 relative ASM jumps */
        drop,                                  /* ( jump_location                  ) */
        asm_size, minus,                       /* ( distance                       ) */
        asm_here, four_minus, int_store, exit  /* (                                ) */
    )
WORD_END(_asm_resolve_jump_there_)

#undef LASTWORD
#define LASTWORD _asm_resolve_jump_there_
