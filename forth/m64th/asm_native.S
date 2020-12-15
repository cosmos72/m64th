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

#ifdef __aarch64__
/* ( x y u -- x>>16 y>>16 x>>16==y>>16 ) inject 16-bit immediate 'u' into arm64 ASM instruction at asm_here[-4] */
WORD_START(_asm_arm64_inject_imm16_,  LASTWORD)
    WORD_DSTACK(3,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        /* inject ushort(u) at here[-4]                   ( x y u                ) */
        to_ushort, five, lshift,                       /* ( x y ushort(u)<<5     ) */
        asm_here, four_minus, uint_fetch, or,          /* ( x y asm_instr        ) */
        asm_here, four_minus, int_store,               /* ( x y                  ) */
        sixteen, rshift, swap,                         /* ( y>>16 x              ) */
        sixteen, rshift, swap,                         /* ( x>>16 y>>16          ) */
        two_dup, ne, exit                              /* ( x>>16 y>>16 x>>16==y>>16 ) */
    )
WORD_END(_asm_arm64_inject_imm16_)
#undef LASTWORD
#define LASTWORD _asm_arm64_inject_imm16_
#endif /* __aarch64__ */

/* ( tok-addr -- ) compile ASM code for pushing literal to DSTACK */
WORD_START(_asm_lit8s_,                LASTWORD)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_LEN(_asm_lit8s_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
#if defined(__x86_64__)
        /* compile ASM code for 'dup' */
        _asm_lit_comma_, CELL(FUNC(dup)), T(FUNC_SIZE(dup)), /* ( tok-addr ) */

        CALL(lit_to_n),                                /* ( n                    ) */
        /* n+1 fits a signed byte? */
        dup, one_plus, dup, to_byte, equal,            /* ( n t|f                ) */
        _if_, T(8+nCALLt),                             /* ( n                    ) */
            /* compile ASM code for '(asm/drop_lit1s)' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_drop_lit1s_)), T(ASMFUNC_SIZE(_asm_drop_lit1s_)),
            /* inject n+1 at asm_here[-1]              */
            one_plus, asm_here, one_minus, c_store,    /* (                      ) */
            exit,                                      /* (                      ) */
        then,                                          /* ( n                    ) */
        /* n fits unsigned 4 bytes?  */
        dup, dup, to_uint, equal,                      /* ( n t|f                ) */
        _if_, T(7+nCALLt),                             /* ( n                    ) */
            /* compile ASM code for '(asm/drop_lit4u)' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_drop_lit4u_)), T(ASMFUNC_SIZE(_asm_drop_lit4u_)),
            /* inject n at asm_here[-4]                */
            asm_here, four_minus, int_store,           /* (                      ) */
            exit,                                      /* (                      ) */
        then,                                          /* ( n                    ) */
        /* n fits signed 4 bytes?  */
        dup, dup, to_int, equal,                       /* ( n t|f                ) */
        _if_, T(7+nCALLt),                             /* ( n                    ) */
            /* compile ASM code for '(asm/drop_lit4s)' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_drop_lit4s_)), T(ASMFUNC_SIZE(_asm_drop_lit4s_)),
            /* inject n at asm_here[-4]                */
            asm_here, four_minus, int_store,           /* (                      ) */
            exit,                                      /* (                      ) */
        then,                                          /* ( n                    ) */
        /* compile ASM code for '(asm/drop_lit8s)' */
        _asm_lit_comma_, CELL(ASMFUNC(_asm_drop_lit8s_)), T(ASMFUNC_SIZE(_asm_drop_lit8s_)),
        /* inject n at asm_here[-8]                */
        asm_here, eight_minus, store, exit             /* (                      ) */

#elif defined(__aarch64__)
        /* compile ASM code for 'dup' */
        _asm_lit_comma_, CELL(FUNC(dup)), T(FUNC_SIZE(dup)), /* ( tok-addr ) */

        CALL(lit_to_n),                                /* ( n                    ) */
        dup, zero_less,                                /* ( n t|f                ) */
        _if_, T(7+nCALLt),                             /* ( n                    ) */
            /* compile ASM code for '(asm/drop_lit2n)' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_drop_lit2n_)), T(ASMFUNC_SIZE(_asm_drop_lit2n_)),
            minus_one, over, invert,                   /* ( n -1 ~n              ) */
        _else_, T(4+nCALLt),                           /* ( n                    ) */
            /* compile ASM code for '(asm/drop_lit2u)' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_drop_lit2u_)), T(ASMFUNC_SIZE(_asm_drop_lit2u_)),
            zero, over,                                /* ( n 0 n                ) */
        then,                                          /* ( n x n|~n             ) */
        CALL(_asm_arm64_inject_imm16_),                /* ( n' x' t|f            ) */
        begin,                                         /* ( n x t|f              ) */
        _while_, T(21+6*nCALLt),                       /* ( n x                  ) */

            /* compile ASM code of 'movk ... lsl 16' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_arm64_movk16_)), T(ASMFUNC_SIZE(_asm_arm64_movk16_)),
            over, CALL(_asm_arm64_inject_imm16_),      /* ( n' x' t|f            ) */
        _while_, T(14+4*nCALLt),                       /* ( n x                  ) */

            /* compile ASM code of 'movk ... lsl 32' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_arm64_movk32_)), T(ASMFUNC_SIZE(_asm_arm64_movk32_)),
            over, CALL(_asm_arm64_inject_imm16_),      /* ( n' x' t|f            ) */
        _while_, T(7+2*nCALLt),                        /* ( n x                  ) */

            /* compile ASM code of 'movk ... lsl 48' */
            _asm_lit_comma_, CELL(ASMFUNC(_asm_arm64_movk48_)), T(ASMFUNC_SIZE(_asm_arm64_movk48_)),
            over, CALL(_asm_arm64_inject_imm16_),      /* ( n n true             ) */
        _until_, T(-20-6*nCALLt),                      /* ( n n                  ) */
        then, then, then,                              /* ( n n                  ) */
        two_drop, exit                                 /* (                      ) */
#else
        _lit_, T(M6ERR_UNSUPPORTED_OPERATION), throw, exit
#endif
    )
WORD_END(_asm_lit8s_)
/* ( jump_location jump_category -- ) resolve an ASM jump to here */
WORD_START(_asm_resolve_jump_here_,    _asm_lit8s_)
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
        token_to_asm_addr,                     /* ( addr m6func                    ) */
        _lit_cell_, CELL(FUNC(_asm_else_)),    /* ( addr m6func1 m6func2           ) */
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
/* ( dest orig -- ) resolve an ASM jump from orig to dest */
WORD_START(_asm_resolve_jump_there_,   _asm_resolve_jump_here_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
#if defined(__x86_64__)
        /* see comment above about amd64 relative ASM jumps */
        drop, nip,                             /* ( dest_location orig_location    ) */
        tuck, minus, swap,                     /* ( distance orig_location         ) */
        asm_func, plus, four_minus,            /* ( distance addr                  ) */
        int_store, exit                        /* (                                ) */
#elif defined(__aarch64__)
        _lit_, T(M6ERR_UNSUPPORTED_OPERATION), throw, exit
#else
        _lit_, T(M6ERR_UNSUPPORTED_OPERATION), throw, exit
#endif
    )
WORD_END(_asm_resolve_jump_there_)

#undef LASTWORD
#define LASTWORD _asm_resolve_jump_there_
