/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
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

#include "../../include/asm.mh"
#include "../../include/dict.mh"
#include "../../include/m4th/dict.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-asm --------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

/* ( addr u -- ) store ASM code at HERE */
WORD_NONATIVE(asm_comma,   asm_comma,      DSTACK(2,0), RSTACK(0,0), WORD_IMPURE)
WORD(name_to_asm_n,        asm_comma,      DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD_START(token_to_asm,   name_to_asm_n)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        dup, token_to_asm_addr,                     /* ( token m4func|0          ) */
        _q_if0_, T(4),                              /* ( m4func 0                ) */
            nip, dup, exit,                         /* ( 0 0                     ) */
        then,                                       /* ( token m4func            ) */
        swap, CALL(token_to_asm_n),                 /* ( m4func u|-1             ) */
        dup, invert,                                /* ( m4func u|-1 flag        ) */
        _if0_, T(4),                                /* ( m4func -1               ) */
            nip, invert, dup,                       /* ( 0 0                     ) */
        then, exit                                  /* ( m4func u | 0 0          ) */
    )
WORD_END(token_to_asm)
WORD_START(token_to_asm_n, token_to_asm)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        token_to_name,                              /* ( nt|0                    ) */
        _q_if_, T(3),                               /* ( nt                      ) */
            name_to_asm_n,                          /* ( u|-1                    ) */
        _else_, T(2),                               /* ( 0                       ) */
            invert,                                 /* ( -1                      ) */
        then, exit                                  /* ( u|-1                    ) */
    )
WORD_END(token_to_asm_n)
WORD(token_to_asm_addr,    token_to_asm_n, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- ) attempt to compile to native ASM all tokens between XT and HERE */
WORD_START(xt_to_asm, token_to_asm_addr)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        exit,
        CALL(xt_to_asm_q),                          /* ( t|f                             ) */
        _if0_, T(2),                                /* (                                 ) */
            exit,                                   /* (                                 ) */
        then,                                       /* (                                 ) */
        /* skip final 'exit' token */
        here, one_token, minus, state, fetch,       /* ( here-SZt xt                     ) */
        do,                                         /* (                 ) ( R: end pos  ) */
            i, token_fetch, dup,                    /* ( tok             ) ( R: end pos  ) */
            CALL(token_to_asm),                     /* ( tok addr u      ) ( R: end pos  ) */
            asm_comma,                              /* ( tok             ) ( R: end pos  ) */
            token_to_name, name_to_flags, flags_to_consumed_tokens,
            one_plus, tokens,                       /* ( consumed_bytes  ) ( R: end pos  ) */
        _plus_loop_, T(-12-nCALLt),                 /* (                 )                 */
        exit
    )
WORD_END(xt_to_asm)
/* ( -- t|f ) return t if all tokens between XT and HERE can be compiled to native ASM */
WORD_START(xt_to_asm_q,    xt_to_asm)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* skip final 'exit' token */
        here, one_token, minus, state, fetch,       /* ( here-SZt xt     )                 */
        two_dup, less_equal,                        /* ( here-SZt xt t|f )                 */
        _if_, T(4),                                 /* ( here-SZt xt     )                 */
            two_drop, false, exit,                  /* ( false           )                 */
        then,
        do,                                         /* (                 ) ( R: end pos  ) */
            i, token_fetch, dup,                    /* ( tok tok         ) ( R: end pos  ) */
            CALL(token_to_asm_n), invert,           /* ( tok 0|-u-1      ) ( R: end pos  ) */
            _if0_, T(4),                            /* ( tok             ) ( R: end pos  ) */
                unloop, drop, false, exit,          /* ( false           )                 */
            then,                                   /* ( tok             ) ( R: end pos  ) */
            token_to_name, name_to_flags, flags_to_consumed_tokens,
            one_plus, tokens,                       /* ( consumed_bytes  ) ( R: end pos  ) */
        _plus_loop_, T(-19-nCALLt),                 /* (                 )                 */
        true, exit                                  /* ( true            )                 */
    )
WORD_END(xt_to_asm_q)

#undef LASTWORD
#define LASTWORD xt_to_asm_q
