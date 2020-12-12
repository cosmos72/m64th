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
/* --- m64th-asm --------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

WORD_START(_asm_q_if_,     _asm_q_if_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_q_if_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(FUNC(_asm_q_if_)), T(FUNC_SIZE(_asm_q_if_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_q_if_)
WORD_START(_asm_q_if0_,    _asm_q_if_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_q_if0_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(FUNC(_asm_q_if0_)), T(FUNC_SIZE(_asm_q_if0_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_q_if0_)
WORD_START(_asm_else_,     _asm_q_if0_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_LEN(_asm_else_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(FUNC(_asm_else_)), T(FUNC_SIZE(_asm_else_)),/* ( orig            ) */
        asm_size, _lit_tok_, _asm_else_, cs_swap,                         /* ( else-orig orig  ) */
        CALL(_asm_resolve_jump_here_), exit                               /* ( else-orig       ) */
    )
WORD_END(_asm_else_)
WORD_START(_asm_if_,       _asm_else_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_if_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(FUNC(_asm_if_)), T(FUNC_SIZE(_asm_if_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_if_)
WORD_START(_asm_if0_,       _asm_if_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_if0_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(FUNC(_asm_if0_)), T(FUNC_SIZE(_asm_if0_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_if0_)
/* ( -- ) return from ASM to ASM */
WORD(_asm_ret_,            _asm_if0_,  DSTACK(0,0), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP)
WORD_START(_asm_then_,     _asm_ret_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        CALL(_asm_resolve_jump_here_), exit
    )
WORD_END(_asm_then_)
WORD_START(_asm_vm_catch_, _asm_ret_)
    WORD_DSTACK(-1,-1) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)   /* stack effect when jumping */
    WORD_RSTACK(0,1)
    /*
     * (asm/vm-catch) uses %rip-relative call to m6f_vm_ and uses %rip-relative data:
     * cannot inline into native code
     */
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE | M6FLAG_MAY_JUMP)
    WORD_CODE(_asm_vm_catch_, exit)
WORD_END(_asm_vm_catch_)
WORD_START(_asm_vm_execute_,   _asm_vm_catch_)
    WORD_DSTACK(-1,-1) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)   /* stack effect when jumping */
    WORD_RSTACK(0,1)
    /*
     * (asm/vm-execute) uses %rip-relative call to m6f_vm_ and uses %rip-relative data:
     * cannot inline into native code
     */
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE | M6FLAG_MAY_JUMP)
    WORD_CODE(_asm_vm_execute_, exit)
WORD_END(_asm_vm_execute_)
/* ( -- ) return from VM to native ASM code */
WORD_NOASM(_vm_return_to_asm_, _asm_vm_execute_,   DSTACK(0,0), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP)
/* ( -- ) register already-compiled ASM code for current XT */
WORD_START(_xt_to_asm_finish_, _vm_return_to_asm_)
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
        allot,                   /* reset HERE = XT    ( here            ) ( R: asm-addr ) */

        _lit_comma_, _call_asm_, /* compile '(call-asm)' ( here          ) ( R: asm-addr ) */
        r_from, comma,           /* compile asm-addr     ( here          )                 */
        _lit_comma_, exit,       /* compile 'exit'       ( here          )                 */

        here, minus, allot,      /* restore HERE         (               )                 */

        latest, name_to_flags,                      /* ( m6flags         )                 */
        _lit2s_, SHORT(M6FLAG_INLINE_ALWAYS|M6FLAG_ASM),
        or,                                         /* ( m6flags'        )                 */
        latest, name_to_flags_store, exit           /* (                 )                 */
    )
WORD_END(_xt_to_asm_finish_)
/* followed by CELL(asm-addr) T(len) just calls asm_comma with specified args */
WORD_NOASM(_asm_lit_comma_,    _xt_to_asm_finish_, DSTACK(0,0), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS | M6FLAG_CONSUMES_IP_SZ_SZt)
/* ( addr u -- ) store assembly code at ASM_HERE and update ASM_HERE */
WORD_NOASM(asm_comma, _asm_lit_comma_, DSTACK(2,0), RSTACK(0,0), WORD_IMPURE)
/* ( -- addr ) get ASM_HERE = current ASM address */
WORD(asm_here,             asm_comma,  DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- addr u ) mark code in ASM buffer as READ+EXEC, and return its range.
 * also updates ASM-HERE */
WORD_START(asm_make_func,  asm_here)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        user_var_m64th,
        _c_locals_save_,
            _c_arg_1_, _c_call_, CELL(m64th_asm_make_func), _c_ret_2_,
        _c_locals_load_, exit
    )
WORD_END(asm_make_func)
/* ( -- u    ) get ASM_HERE - ASM_START in bytes  */
WORD(asm_size,         asm_make_func,  DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- addr ) get ASM_START = start of ASM code  */
WORD(asm_start,            asm_size,   DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( len -- ) reserve at least len bytes in ASM buffer, and mark it as READ+WRITE+EXEC */
WORD_START(asm_reserve,    asm_start)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        user_var_m64th, swap,
        _c_locals_save_,
            _c_arg_2_, _c_call_, CELL(m64th_asm_reserve), _c_ret_0_,
        _c_locals_load_, exit
    )
WORD_END(asm_reserve)
/* ( nt -- u true | 0 false ) get nt.asm_len */
WORD(name_to_asm_n,        asm_reserve,    DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)
/* ( u nt -- ) set name ASM asm_len */
WORD(name_to_asm_n_store,  name_to_asm_n,  DSTACK(2,2), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_STORE)
/* ( tok -- addr u | 0 0 ) get token ASM address and len */
WORD_START(token_to_asm,   name_to_asm_n_store)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        CALL(token_to_asm_replace),                   /* ( token'         ) */
        dup, token_to_asm_addr,                     /* ( token m6func|0 ) */
        _q_if0_, T(4),                              /* ( token 0        ) */
            nip, dup, exit,                         /* ( 0 0            ) */
        then,                                       /* ( token m6func   ) */
        swap, token_to_name, name_to_asm_n,         /* ( m6func u t|f   ) */
        _if0_, T(4),                                /* ( m6func 0       ) */
            nip, dup, exit,                         /* ( 0 0            ) */
        then, exit                                  /* ( m6func u       ) */
    )
WORD_END(token_to_asm)
/* ( sys* tok -- sys'* ) compile token to ASM */
WORD_START(token_to_asm_comma,   token_to_asm)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        CALL(token_to_asm),                         /* ( token'         ) */
        asm_comma, exit                             /* (                ) */
    )
WORD_END(token_to_asm_comma)
/* ( token -- u true | 0 false ) get token ASM len */
WORD_START(token_to_asm_n,     token_to_asm_comma)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        CALL(token_to_asm),                         /* ( addr u | 0 0            ) */
        swap, zero_ne, exit                         /* ( u true | 0 false        ) */
    )
WORD_END(token_to_asm_n)
/* ( tok -- tok' ) get replacement token for compiling token to ASM */
WORD_START(token_to_asm_replace, token_to_asm_n)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(token_to_asm_replace,
      WORD_CODE_TOKENS(
        _ip_to_data_,                               /* ( token &data n  )               */
        bounds,                                     /* ( token end beg  )               */
        do,                                         /* ( token          ) ( R: end pos) */
            dup, i_token_fetch, equal,              /* ( token t|f      ) ( R: end pos) */
            _if_, T(6),                             /* ( token          ) ( R: end pos) */
                /* found a replacement token, return it */
                drop, i, token_fetch_1,             /* ( token'         ) ( R: end pos) */
                _leave_, T(5),                      /* ( token          )               */
            then,                                   /* ( token          ) ( R: end pos) */
            two, tokens,                            /* ( token          ) ( R: end pos) */
        _plus_loop_, T(-15),                        /* ( token          )               */
        exit                                        /* ( token          )               */
      ),
      WORD_DATA_TOKENS(
        _if_, _asm_if_,        /* '(if)' becomes '(asm/if)' in native ASM  */
        then, _asm_then_,      /* 'then' becomes '(asm/then) in native ASM */
        exit, _asm_ret_        /* and so on ...                            */
      )
    )
WORD_END(token_to_asm_replace)
WORD(token_to_asm_addr,  token_to_asm_replace, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- ) attempt to compile to native ASM all tokens between XT and HERE */
WORD_START(xt_to_asm_comma,      token_to_asm_addr)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
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
        do,                                         /* ( sys*            ) ( R: end pos  ) */
            i, token_fetch,                         /* ( sys* tok        ) ( R: end pos  ) */
            CALL(token_to_asm_comma),               /* ( sys'*           ) ( R: end pos  ) */
            i, token_fetch,                         /* ( sys* tok        ) ( R: end pos  ) */
            token_to_name, name_to_flags, flags_to_consumed_tokens,
            one_plus, tokens,                       /* ( sys* consumed_bytes ) ( R: end pos  ) */
        _plus_loop_, T(-13-nCALLt),                 /* (                 )                 */

        CALL(_xt_to_asm_finish_), exit              /* (                 )                 */
    )
WORD_END(xt_to_asm_comma)
/* ( -- u t|f ) return required len and true if all tokens between XT and HERE
 * can be compiled to native ASM, otherwise 0 and false */
WORD_START(xt_to_asm_n,    xt_to_asm_comma)
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
#define LASTWORD xt_shift_tokens
