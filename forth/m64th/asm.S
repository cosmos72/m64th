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

/* ( C: -- do-sys ) */
WORD_START(_asm_q_do_,     _asm_q_do_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_q_do_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(ASMFUNC(_asm_q_do_)), T(ASMFUNC_SIZE(_asm_q_do_)),
        asm_size, _lit_tok_, _asm_q_do_,
        CALL(asm_align_comma), exit
    )
WORD_END(_asm_q_do_)
/* ( C: -- orig ) */
WORD_START(_asm_q_if_,     _asm_q_do_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_q_if_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(ASMFUNC(_asm_q_if_)), T(ASMFUNC_SIZE(_asm_q_if_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_q_if_)
/* ( C: -- orig ) */
WORD_START(_asm_q_if0_,    _asm_q_if_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_q_if0_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(ASMFUNC(_asm_q_if0_)), T(ASMFUNC_SIZE(_asm_q_if0_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_q_if0_)
/* ( C: -- do-sys ) */
WORD_START(_asm_do_,       _asm_q_if0_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_LEN(_asm_do_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(FUNC(do)), T(FUNC_SIZE(do)),
        asm_size, _lit_tok_, _asm_do_,
        CALL(asm_align_comma), exit
    )
WORD_END(_asm_do_)
/* ( C: orig1 -- orig2 ) */
WORD_START(_asm_else_,     _asm_do_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_LEN(_asm_else_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(ASMFUNC(_asm_else_)), T(ASMFUNC_SIZE(_asm_else_)),/* ( orig            ) */
        asm_size, _lit_tok_, _asm_else_, cs_swap,                               /* ( else-orig orig  ) */
        CALL(_asm_resolve_jump_here_), exit                                     /* ( else-orig       ) */
    )
WORD_END(_asm_else_)
/* ( C: -- orig ) */
WORD_START(_asm_if_,       _asm_else_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_if_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(ASMFUNC(_asm_if_)), T(ASMFUNC_SIZE(_asm_if_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_if_)
/* ( C: -- orig ) */
WORD_START(_asm_if0_,       _asm_if_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_if0_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(ASMFUNC(_asm_if0_)), T(ASMFUNC_SIZE(_asm_if0_)),
        asm_size, _lit_tok_, _asm_if_, exit
    )
WORD_END(_asm_if0_)
/* ( C: -- orig ) */
WORD_START(_asm_loop_,       _asm_if0_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_LEN(_asm_if0_)
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _asm_lit_comma_, CELL(ASMFUNC(_asm_loop_)), T(ASMFUNC_SIZE(_asm_loop_)),
        asm_size, _lit_tok_, _asm_loop_,
        CALL(_asm_resolve_loop_), exit
    )
WORD_END(_asm_if0_)
/* ( -- ) return from ASM to ASM */
WORD(_asm_ret_,            _asm_if0_,  DSTACK(0,0), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP)
/* ( C: orig -- ) */
WORD_START(_asm_then_,     _asm_ret_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_LEN(_asm_then_)
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
/* ( -- ) return from VM to ASM code */
WORD_NOASM(_vm_return_to_asm_, _asm_vm_execute_,   DSTACK(0,0), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP)
/**
 * ( -- t|f ) if all tokens between XT and HERE can be compiled to ASM
 * then initialize ASM buffer and return true
 */
WORD_START(_xt_to_asm_init_,   _vm_return_to_asm_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* attempt to compile to ASM only functions containing > 3 tokens                  */
        _num_compiled_,                             /* ( #compiled_tokens                ) */
        three, more,                                /* ( t|f                             ) */
        _q_if0_, T(2),                              /* ( false                           ) */
            exit,                                   /* ( false                           ) */
        then,                                       /* ( true                            ) */
        drop, CALL(xt_to_asm_n),                    /* ( asm_len t|f                     ) */
        _q_if0_, T(3),                              /* ( asm_len false                   ) */
            nip, exit,                              /* ( false                           ) */
        then,                                       /* ( asm_len true                    ) */
        swap, CALL(asm_reserve), exit               /* ( true                            ) */
    )
WORD_END(_xt_to_asm_init_)
/* ( -- ) main part of 'xt>asm,' can be called only after (xt>asm-init) */
WORD_START(_xt_to_asm_body_,   _xt_to_asm_init_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        here, state_fetch,                          /* ( here xt                         ) */
        do,                                         /* ( sys*            ) ( R: end pos  ) */
            i,                                      /* ( sys* tok-addr   ) ( R: end pos  ) */
            CALL(token_to_asm_comma),               /* ( sys'*           ) ( R: end pos  ) */
            i_token_fetch,                          /* ( sys* tok        ) ( R: end pos  ) */
            token_to_name, name_to_flags, flags_to_consumed_tokens,
            one_plus, tokens,                   /* ( sys* consumed_bytes ) ( R: end pos  ) */
        _plus_loop_, T(-10-nCALLt),                 /* (                 )                 */
        exit                                        /* (                 )                 */
    )
WORD_END(_xt_to_asm_body_)
/* ( -- ) register already-compiled ASM code into current XT */
WORD_START(_xt_to_asm_finish_, _xt_to_asm_body_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        CALL(asm_make_func),                        /* ( asm-addr asm-len)                 */
        latest, name_to_asm_n_store, to_r,          /* (                 ) ( asm-addr    ) */

        one_cell, div_token, two_plus,              /* ( token-offset    ) ( R: asm-addr ) */
        CALL(xt_shift_tokens),                      /* (                 ) ( R: asm-addr ) */

        here, dup, state_fetch, sub,                /* ( here xt-here    ) ( R: asm-addr ) */
        allot,                  /* reset HERE = XT     ( here            ) ( R: asm-addr ) */

        _lit_comma_, _call_asm_,/*compile '(call-asm)' ( here            ) ( R: asm-addr ) */
        r_from, comma,          /* compile asm-addr    ( here            )                 */
        _lit_comma_, exit,      /* compile 'exit'      ( here            )                 */

        here, minus, allot,     /* restore HERE        (                 )                 */

        latest, name_to_flags,                      /* ( m6flags         )                 */
        _lit_, T(M6FLAG_INLINE_ASM|M6FLAG_ASM),
        or,                                         /* ( m6flags'        )                 */
        latest, name_to_flags_store, exit           /* (                 )                 */
    )
WORD_END(_xt_to_asm_finish_)
/* followed by CELL(asm-addr) T(len) just calls asm_bytes_comma with specified args */
WORD_NOASM(_asm_lit_comma_,    _xt_to_asm_finish_, DSTACK(0,0), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS | M6FLAG_CONSUMES_IP_SZ_SZt)
/**
 * called by '(asm/loop)' and '(asm/+loop)': resolve the jump offsets of
 *  * a single 'do' or '(asm/?do)',
 *  * zero or more '(asm/leave)'
 *  * one '(asm/loop)' or '(asm/+loop)'
 * ( do-sys leave-sys* loop-sys -- )
 */
WORD_START(_asm_resolve_loop_, _asm_lit_comma_)
    WORD_DSTACK(-1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        _check_lit_tok_, _asm_loop_,                /** TODO: also support _asm_plus_loop_       */
        cs_to_r,                                    /* ( do-sys leave-sys*     ) ( R: loop-sys ) */
        begin,                                      /* ( do-sys leave-sys*     ) ( R: loop-sys ) */
            dup, _lit_, _asm_leave_, equal,         /* ( do-sys leave-sys* t|f ) ( R: loop-sys ) */
        _while_, T(5),                              /* ( do-sys leave-sys*     ) ( R: loop-sys ) */
            _lit_, T(M6ERR_UNSUPPORTED_OPERATION), throw, /** TODO: support _asm_leave_ */
        _repeat_, T(-11),                           /* ( do-sys leave-sys*     ) ( R: loop-sys ) */

        dup, _lit_tok_, _asm_q_do_, equal,          /* ( do-sys t|f            ) ( R: loop-sys ) */
        _if_, T(8+nCALLt),                          /* ( do-sys                ) ( R: loop-sys ) */
            /* adjust do-sys to point immediately after jump offset inside _asm_q_do_ */
            over, _lit_, T(TO(_asm_q_do_.jump) - ASMFUNC_RET(_asm_q_do_)), plus, over,
                                       /* ( do-sys jump_location jump_category ) ( R: loop-sys ) */
            CALL(_asm_resolve_jump_here_),          /* ( do-sys                ) ( R: loop-sys ) */
        _else_, T(3),                               /* ( do-sys                ) ( R: loop-sys ) */
            _check_lit_tok_, _asm_do_,              /* ( do-sys                ) ( R: loop-sys ) */
        then,                                       /* ( do-sys                ) ( R: loop-sys ) */
        cs_r_from,                                  /* ( do-sys loop-sys       )                 */
        _check_lit_tok_, _asm_loop_,                /** TODO: support _asm_plus_loop_            */
        /* adjust loop-sys to point immediately after jump offset inside _asm_loop_              */
        swap, _lit_, T(TO(_asm_loop_.jump) - ASMFUNC_RET(_asm_loop_)), plus, swap,
                                                    /* ( do-sys loop-sys       )                 */
        CALL(_asm_resolve_jump_there_),             /* (                       )                 */
        exit
    )
WORD_END(_asm_resolve_loop_)
/* ( addr u -- ) store assembly code at ASM_HERE and update ASM_HERE */
WORD_NOASM(asm_bytes_comma, _asm_resolve_loop_,  DSTACK(2,0), RSTACK(0,0), WORD_IMPURE)
/* ( -- ) forget current code in ASM buffer i.e. set ASM_HERE = ASM_FUNC */
WORD(asm_clear,      asm_bytes_comma,  DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
/* ( -- addr ) get ASM_HERE = current ASM address */
WORD(asm_here,             asm_clear,  DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- addr u ) mark code in ASM buffer as READ+EXEC, and return its range.
 * also updates ASM_HERE */
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
/* ( -- u    ) get ASM_HERE - ASM_FUNC in bytes  */
WORD(asm_size,         asm_make_func,  DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- addr ) get ASM_FUNC = start of ASM code  */
WORD(asm_func,            asm_size,    DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* ( len -- ) reserve at least len bytes in ASM buffer, and mark it as READ+WRITE+EXEC */
WORD_START(asm_reserve,    asm_func)
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
/* ( tok-addr -- n ) read literal value following a token (lit[248]s) */
WORD_START(lit_to_n,       asm_reserve)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(/* generated from file asm.forth - see source and comments there */
        /*35*/
        dup, token_plus, swap, token_fetch, token_to_name,
        _q_if_, T(4),
            name_to_flags, flags_to_consumed_tokens, tokens,
        then,
        case,
            two, _of_, T(3), short_fetch, _endof_, T(16),
            four, _of_, T(3), int_fetch, _endof_, T(10),
            one_cell, _of_, T(3), fetch, _endof_, T(4),
            _lit_, T(M6ERR_ARGUMENT_TYPE_MISMATCH), throw,
        endcase, exit
    )
WORD_END(lit_to_n)
/* ( nt -- u true | 0 false ) get nt.asm_len */
WORD(name_to_asm_n,        lit_to_n,       DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)
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
/* ( sys* tok-addr -- sys'* ) compile token to ASM */
WORD_START(token_to_asm_comma,   token_to_asm)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* token nt and m6flags are the original ones, while */
        /* token' nt' and m6flags' are the replacements found by token>asm-replace */
        dup, CALL(token_to_asm_replace),            /* ( sys* tok-addr token'             ) */
        dup, token_to_name,                         /* ( sys* tok-addr token' nt'         ) */
        dup, name_to_flags,                         /* ( sys* tok-addr token' nt' m6flags') */
        _lit_, T(M6FLAG_REEXEC_AFTER_OPTIMIZE), and,/* ( sys* tok-addr token' nt' flag    ) */
        _if0_, T(6+nCALLt),                         /* ( sys* tok-addr token' nt'         ) */
            /* simply append ASM code of token */
            drop, nip,                              /* ( sys* token'                      ) */
            CALL(token_to_asm),                     /* ( sys* addr|0 u|0                  ) */
            asm_bytes_comma, exit,                  /* ( sys*                             ) */
        then,                                       /* ( sys* tok-addr token' nt'         ) */
        /* replacement token is marked 'reexec-after-optimize'                              */
        nip, over, token_fetch,                     /* ( sys* tok-addr nt' token          ) */
        token_to_name, name_to_flags,               /* ( sys* tok-addr nt' m6flags        ) */
        _lit_, T(M6FLAG_REEXEC_AFTER_OPTIMIZE), and,/* ( sys* tok-addr nt' flag           ) */
        /**
         * if both original and replacement tokens are marked 'reexec-after-optimize',
         * then it must be a jump, as for example '(if)' '(else)' '(while)' ...
         * the replacement word expects only sys* to be on the stack, so drop tok-addr.
         *
         * otherwise, only the replacement token is marked 'reexec-after-optimize'
         * it must be a '(lit*)' '(call)' or similar, where the replacement word
         * needs the data stored after the original token, so leave tok-addr on the stack.
         */
        _if_, T(2),                                 /* ( sys* tok-addr nt'                ) */
            nip,                                    /* ( sys* nt'                         ) */
        then,                                       /* ( sys* tol-addr* nt'               ) */
        name_to_xt, execute, exit                   /* ( sys'*                            ) */
    )
WORD_END(token_to_asm_comma)
/* ( tok-addr -- u true | 0 false ) get token ASM len */
WORD_START(token_to_asm_n,     token_to_asm_comma)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        CALL(token_to_asm_replace),                 /* ( token'              ) */
        CALL(token_to_asm),                         /* ( addr u | 0 0        ) */
        swap, zero_ne, exit                         /* ( u true | 0 false    ) */
    )
WORD_END(token_to_asm_n)
/* ( tok-addr -- tok' ) get replacement token for compiling token to ASM */
WORD_START(token_to_asm_replace, token_to_asm_n)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(token_to_asm_replace,
      WORD_CODE_TOKENS(
        _ip_to_data_,                               /* ( tok-addr &data n  )            */
        bounds,                                     /* ( tok-addr end beg  )            */
        rot, token_fetch, minus_rot,                /* ( token end beg     )            */
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
        _q_if_, _asm_q_if_,      /* '(?if)'      becomes '(asm/?if)'    in ASM */
        _q_if0_,_asm_q_if0_,     /* '(?if0)'     becomes '(asm/?if0)'   in ASM */
        _call_asm_, _asm_call_,  /* '(call-asm)' becomes '(asm/call)'   in ASM */
        _do_,  _asm_do_,         /* '(do)'       becomes '(asm/do)      in ASM */
        _else_,_asm_else_,       /* '(else)'     becomes '(asm/else)'   in ASM */
        _if_, _asm_if_,          /* '(if)'       becomes '(asm/if)'     in ASM */
        _if0_,_asm_if0_,         /* '(if0)'      becomes '(asm/if0)'    in ASM */
        _lit2s_,_asm_lit8s_,     /* '(lit2s)'    becomes '(asm/lit8s)'  in ASM - refined later */
        _lit4s_,_asm_lit8s_,     /* '(lit4s)'    becomes '(asm/lit8s)'  in ASM - refined later */
        _lit8s_,_asm_lit8s_,     /* '(lit8s)'    becomes '(asm/lit8s)'  in ASM */
        _lit_nt_to_body_, _asm_lit_nt_to_body_, /* '(lit-nt>body)' becomes '(asm/lit-nt>body)' */
        _loop_, _asm_loop_,      /* '(loop)'     becomes '(asm/loop)    in ASM */
        _recurse_, _asm_recurse_,/* '(recurse)'  becomes '(asm/recurse) in ASM */
        do,   _asm_do_,          /* 'do'         becomes '(asm/do)      in ASM */
        then, _asm_then_,        /* 'then'       becomes '(asm/then)    in ASM */
        exit, _asm_ret_          /* 'exit'       becomes '(asm/ret)     in ASM */
      )
    )
WORD_END(token_to_asm_replace)
WORD(token_to_asm_addr,  token_to_asm_replace, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE)
/* ( -- ) attempt to compile to ASM all tokens between XT and HERE */
WORD_START(xt_to_asm_comma,    token_to_asm_addr)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        CALL(_xt_to_asm_init_),                     /* ( t|f                             ) */
        _if0_, T(2),                                /* (                                 ) */
            exit,                                   /* (                                 ) */
        then,                                       /* (                                 ) */
        _lit_xt_, XT(_xt_to_asm_body_),             /* ( xt                              ) */
        _catch_beg_, _catch_end_,                   /* ( err|0                           ) */
        _if_, T(3),                                 /* (                                 ) */
            asm_clear,                              /* (                                 ) */
        _else_, T(2+nCALLt),                        /* (                                 ) */
            CALL(_xt_to_asm_finish_),               /* (                                 ) */
        then, exit                                  /* (                                 ) */
    )
WORD_END(xt_to_asm_comma)
/* ( -- u t|f ) return required len and true if all tokens between XT and HERE
 * can be compiled to ASM, otherwise 0 and false */
WORD_START(xt_to_asm_n,        xt_to_asm_comma)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(/* generated from asm.forth - see source and comments there */
        zero, here, state_fetch,
        _q_do_, T(16+nCALLt),
            i, CALL(token_to_asm_n),
            _if0_, T(3),
                unloop, exit,
            then,
            plus, i_token_fetch, token_to_name,
            name_to_flags, flags_to_consumed_tokens,
            one_plus, tokens,
        _plus_loop_, T(-16-nCALLt),
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
