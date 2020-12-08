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

/* ( -- ) return to native code */
WORD(_asm_exit_,           _asm_exit_,     DSTACK(0,0), RSTACK(0,0), M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
/* ( addr u -- ) store assembly code at ASM_HERE and update ASM_HERE */
WORD_NOASM(asm_comma,   _asm_exit_,     DSTACK(2,0), RSTACK(0,0), WORD_IMPURE)
/* ( -- addr u ) mark code in ASM buffer as READ+EXEC, and return its range.
 * also updates ASM-HERE */
WORD_START(asm_make_func,    asm_comma)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        user_var_m4th,
        _c_locals_save_,
            _c_arg_1_, _c_call_, CELL(m4th_asm_make_func), _c_ret_2_,
        _c_locals_load_, exit
    )
WORD_END(asm_make_func)
/* ( len -- ) reserve at least len bytes in ASM buffer, and mark it as READ+WRITE+EXEC */
WORD_START(asm_reserve,    asm_make_func)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        user_var_m4th, swap,
        _c_locals_save_,
            _c_arg_2_, _c_call_, CELL(m4th_asm_reserve), _c_ret_0_,
        _c_locals_load_, exit
    )
WORD_END(asm_reserve)
/* ( nt -- u true | 0 false ) get name ASM asm_len */
WORD(name_to_asm_n,        asm_reserve,    DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
/* ( u nt -- ) set name ASM asm_len */
WORD(name_to_asm_n_store,  name_to_asm_n,  DSTACK(2,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
/* ( tok -- addr u | 0 0 ) get token ASM address and len */
WORD_START(token_to_asm,   name_to_asm_n_store)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        CALL(_token_to_asm_replace_),                   /* ( token'         ) */
        dup, token_to_asm_addr,                     /* ( token m4func|0 ) */
        _q_if0_, T(4),                              /* ( token 0        ) */
            nip, dup, exit,                         /* ( 0 0            ) */
        then,                                       /* ( token m4func   ) */
        swap, token_to_name, name_to_asm_n,         /* ( m4func u t|f   ) */
        _if0_, T(4),                                /* ( m4func 0       ) */
            nip, dup, exit,                         /* ( 0 0            ) */
        then, exit                                  /* ( m4func u       ) */
    )
WORD_END(token_to_asm)
/* ( token -- u true | 0 false ) get token ASM len */
WORD_START(token_to_asm_n,     token_to_asm)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        CALL(token_to_asm),                         /* ( addr u | 0 0            ) */
        swap, zero_ne, exit                         /* ( u true | 0 false        ) */
    )
WORD_END(token_to_asm_n)
/* ( tok -- tok' ) get replacement token for compiling token to ASM */
WORD_START(_token_to_asm_replace_, token_to_asm_n)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_token_to_asm_replace_,
      WORD_CODE_TOKENS(
        _ip_to_data_,                               /* ( token &data n  )               */
        bounds,                                     /* ( token end beg  )               */
        do,                                         /* ( token          ) ( R: end pos) */
            dup, i, token_fetch, equal,             /* ( token t|f      ) ( R: end pos) */
            _if_, T(6),                             /* ( token          ) ( R: end pos) */
                /* found a replacement token, return it */
                drop, i, token_fetch_1,             /* ( token'         ) ( R: end pos) */
                _leave_, T(5),                      /* ( token          )               */
            then,                                   /* ( token          ) ( R: end pos) */
            two, tokens,                            /* ( token          ) ( R: end pos) */
        _plus_loop_, T(-14),                        /* ( token          )               */
        exit                                        /* ( token          )               */
      ),
      WORD_DATA_TOKENS(
        exit, _asm_exit_        /* 'exit' becomes '(asm-exit)' in native ASM */
      )
    )
WORD_END(_token_to_asm_replace_)
WORD(token_to_asm_addr,_token_to_asm_replace_, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- ) attempt to compile to native ASM all tokens between XT and HERE */
WORD_START(xt_to_asm,      token_to_asm_addr)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        // exit,  /* TO BE TESTED */

        /* attempt to compile to ASM only functions containing > 3 tokens                  */
        _num_compiled_,                             /* ( #compiled_tokens                ) */
        three, less_equal,                          /* ( t|f                             ) */
        _if_, T(2),                                 /* (                                 ) */
            exit,                                   /* (                                 ) */
        then,                                       /* (                                 ) */

        CALL(xt_to_asm_n),                          /* ( asm_len t|f                  ) */
        _if0_, T(3),                                /* ( asm_len                      ) */
            nip, exit,                              /* (                                 ) */
        then,                                       /* ( asm_len                      ) */
        CALL(asm_reserve),                          /* (                                 ) */

        here, state_fetch,                          /* ( here xt                         ) */
        do,                                         /* (                 ) ( R: end pos  ) */
            i, token_fetch, dup,                    /* ( tok tok         ) ( R: end pos  ) */
            CALL(token_to_asm),                     /* ( tok addr u      ) ( R: end pos  ) */
            asm_comma,                              /* ( tok             ) ( R: end pos  ) */
            token_to_name, name_to_flags, flags_to_consumed_tokens,
            one_plus, tokens,                       /* ( consumed_bytes  ) ( R: end pos  ) */
        _plus_loop_, T(-12-nCALLt),                 /* (                 )                 */

        CALL(_xt_to_asm_finish_), exit              /* (                 )                 */
    )
WORD_END(xt_to_asm)
/* ( -- ) register already-compiled ASM code for current XT */
WORD_START(_xt_to_asm_finish_, xt_to_asm)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        CALL(asm_make_func),                        /* ( asm-addr asm-len)                 */
        latest, name_to_asm_n_store, to_r,          /* (                 ) ( asm-addr    ) */

        one_cell, div_token, two_plus,              /* ( token-offset    ) ( R: asm-addr ) */
        CALL(xt_shift_tokens),                      /* (                 ) ( R: asm-addr ) */

        here, dup, state_fetch, sub,                /* ( here xt-here    ) ( R: asm-addr ) */
        allot,                     /* reset HERE = XT  ( here            ) ( R: asm-addr ) */

        _lit_comma_, _call_native_,/* compile '(call-native)'  ( here    ) ( R: asm-addr ) */
        r_from, comma,             /* compile asm-addr         ( here    )                 */
        _lit_comma_, exit,         /* compile 'exit'           ( here    )                 */

        here, minus, allot,        /* restore HERE             (         )                 */

        latest, name_to_flags,                      /* ( m4flags         )                 */
        _lit2s_, SHORT(M4FLAG_INLINE_ALWAYS|M4FLAG_CALL_ASM),
        or,                                         /* ( m4flags'        )                 */
        latest, name_to_flags_store, exit           /* (                 )                 */
    )
WORD_END(_xt_to_asm_finish_)
/* ( -- u t|f ) return required len and true if all tokens between XT and HERE
 * can be compiled to native ASM, otherwise 0 and false */
WORD_START(xt_to_asm_n,    _xt_to_asm_finish_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(/* generated from asm.forth - see source and comments there */
        zero, here, state_fetch,
        _q_do_, T(20+nCALLt),
            i, token_fetch, dup,
            CALL(token_to_asm_n),
            _if0_, T(4),
                unloop, nip, exit,
            then,
            rot, plus, swap,
            token_to_name, name_to_flags, flags_to_consumed_tokens,
            one_plus, tokens,
        _plus_loop_, T(-20-nCALLt),
        true, exit
    )
WORD_END(xt_to_asm_n)
/* ( token-offset -- ) move forward by specified token offset
 * all tokens between XT and HERE. updates HERE */
WORD_START(xt_shift_tokens,    xt_to_asm_n)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        tokens, state_fetch, tuck, plus,            /* ( xt xt+off           ) */
        _num_compiled_, tokens,                     /* ( xt xt+off len       ) */
        minus_cmove_count,                          /* ( here here+off       ) */
        sub, allot, exit                            /* (                     ) */
    )
WORD_END(xt_shift_tokens)
#undef LASTWORD
#define LASTWORD xt_to_asm_n
