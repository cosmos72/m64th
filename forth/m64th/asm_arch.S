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
/* --- m64th-asm   arch-specific words ---------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

/* ( jump_location jump_category -- ) resolve an ASM jump to here */
WORD_START(_asm_resolve_jump_here_,  LASTWORD)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
#if defined(__x86_64__)
        /**
         * ASM relative jumps are quite simple on amd64:
         * their jump offset occupies either 1 byte (not used by m64th) or 4 bytes,
         * and it's exactly the distance in bytes from the end of the jump instruction.
         */
        drop,                                  /* ( jump_location                  ) */
        asm_func, plus,                        /* ( addr_of_jump_offset+4          ) */
        dup, four_minus, swap,                 /* ( addr addr+4                    ) */
        asm_here, sub,                         /* ( addr distance                  ) */
        swap, int_store, exit                  /* (                                ) */
#elif defined(__aarch64__)
        /**
         * ASM relative jumps on arm64 have several possible encodings:
         * 1. unconditional jump 'b' or call 'bl': bits 0..25 contain distance/4
         * 2. conditional jumps 'b.cond':          bits 5..23 contain distance/4
         *
         * in all cases, distance is computed from the *start* of jump instruction.
         */
        swap, asm_func, plus, four_minus, swap,/* ( addr_of_jump_instr jump_categ  ) */
        token_to_asm_addr,                     /* ( addr m4func                    ) */
        _lit_cell_, CELL(FUNC(_asm_else_)),    /* ( addr m4func1 m4func2           ) */
        /** TODO: compare with _asm_call_ */
        equal,                                 /* ( addr t|f                       ) */

        _if_, T(12+8/SZt),  /* unconditional jump ( addr_of_jump_instr             ) */
            dup, uint_fetch,                   /* ( addr jump_instr                ) */
                        /* clear any pre-set distance bits                           */
            _lit4s_, INT(0xfc000000), and,     /* ( addr jump_instr'               ) */
                        /* compute distance bits                                     */
            over, asm_here, sub, four_div,     /* ( addr jump_instr distance/4     ) */
            _lit4s_, INT(0x03ffffff), and,     /* ( addr jump_instr distance_bits  ) */

        _else_, T(13+8/SZt),/* conditional jump   ( addr_of_jump_instr             ) */
            dup, uint_fetch,                   /* ( addr jump_instr                ) */
                        /* clear any pre-set distance bits                           */
            _lit4s_, INT(0xff00001f), and,     /* ( addr jump_instr'               ) */
                        /* compute distance bits                                     */
            over, asm_here, sub, four_div,     /* ( addr jump_instr distance/4     ) */
            _lit4s_, INT(0x0007ffff), and,     /* ( addr jump_instr distance/4'    ) */
            five, lshift,                      /* ( addr jump_instr distance_bits  ) */

        then,                                  /* ( addr jump_instr distance_bits  ) */
                        /* set distance bits                                         */
        or, swap,                              /* ( jump_instr' addr               ) */
        int_store, exit                        /* (                                ) */
#else
        _lit_, T(M6ERR_UNSUPPORTED_OPERATION), throw, exit
#endif
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
#ifdef __x86_64__
        /* see comment above for amd64 relative ASM jumps */
        drop,                                  /* ( jump_location                  ) */
        asm_size, minus,                       /* ( distance                       ) */
        asm_here, four_minus, int_store, exit  /* (                                ) */
#else
        /* TODO */
        _lit_, T(M6ERR_UNSUPPORTED_OPERATION), throw, exit
#endif
    )
WORD_END(_asm_resolve_jump_there_)

#undef LASTWORD
#define LASTWORD _asm_resolve_jump_there_
