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

#include "../../dispatch/sz.mh" /* SZ SZt */
#include "../../include/asm.mh"
#include "../../include/dict.mh"
#include "../../include/err.mh"
#include "../../include/hashmap.mh"
#include "../../include/locals.mh"
#include "../../include/m64th/dict.mh"
#include "../../include/opt2_hash.mh"
#include "../../include/opt2_midprio_hash.mh"
#include "../../include/opt3_hash.mh"
#include "../../include/opt_rules.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m64th-impl -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

WORD_START(_plus_loop_, _plus_loop_)
    WORD_DSTACK(1,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(1,0) /* stack effect when jumping */
    WORD_RSTACK(2,2)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP |M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(plus_loop), exit)
WORD_END(_plus_loop_)
WORD_START(_q_continue_if_, _plus_loop_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _q_continue_if_, _continue_, exit)
WORD_END(_q_continue_if_)
WORD_START(_q_continue_if0_, _q_continue_if_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _q_continue_if0_, _continue_, exit)
WORD_END(_q_continue_if0_)
WORD_START(_q_do_, _q_continue_if0_)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _q_do_, _do_, exit)
WORD_END(_q_do_)
WORD_START(_q_if_, _q_do_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _q_if_, _if_, exit)
WORD_END(_q_if_)
WORD_START(_q_if0_, _q_if_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _q_if0_, _if_, exit)
WORD_END(_q_if0_)
WORD_START(_q_until_, _q_if0_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _lit_tok_, _q_until_,
        CALL(_until_comma_), exit
    )
WORD_END(_q_until_)
WORD_START(_q_until0_, _q_until_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _lit_tok_, _q_until0_,
        CALL(_until_comma_), exit
    )
WORD_END(_q_until0_)
WORD_START(_q_while_, _q_until0_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _check_lit_tok_, begin,             /* ( sys ) topmost must be 'begin' */
        _compile_jump_lit_, _q_while_, _while_,
        cs_swap, exit                       /* ( while-sys begin-sys )         */
    )
WORD_END(_q_while_)
WORD_START(_q_while0_, _q_while_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _check_lit_tok_, begin,             /* ( sys ) topmost must be 'begin' */
        _compile_jump_lit_, _q_while0_, _while_,
        cs_swap, exit                       /* ( while-sys begin-sys )         */
    )
WORD_END(_q_while0_)
/* ( x c-addr u -- ) runtime part of abort" - if x is not zero, stores string as exception message and throws -2 */
WORD_START(_abort_quote_,  _q_while0_)
    WORD_DSTACK(3,0)   /* stack effect if not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,-1)   /* stack effect if jumping */
    WORD_RSTACK(0,-1)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_MAY_JUMP | M6FLAG_INLINE)
    WORD_CODE(
        rot,                                       /* ( c-addr u x     ) */
        _if_, T(4),                                /* ( c-addr u       ) */
            ex_message_store, minus_two, throw,    /* (                ) */
        then,                                      /* ( c-addr u       ) */
        two_drop, exit                             /* (                ) */
    )
WORD_END(_abort_quote_)
WORD_START(_again_,        _abort_quote_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(again), exit)
WORD_END(_again_)
WORD_START(_ahead_,        _again_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(ahead), exit)
WORD_END(_ahead_)
WORD_START(_break_,        _ahead_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
       CALL(break), exit
    )
WORD_END(_break_)
WORD_START(_call_asm_, _break_)
    WORD_DSTACK(-1,-1) /* stack effect of called code */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()  /* stack effect when calling */
    WORD_ASM_NONE() /* (call-asm) uses tail-call optimization: cannot inline into native code */
    WORD_FLAGS(M6FLAG_CONSUMES_IP_SZ | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(
        _call_asm_, CELL(FUNC(noop)), exit
    )
WORD_END(_call_asm_)
WORD_START(_call_,  _call_asm_)
    WORD_DSTACK(-1,-1) /* stack effect of called XT */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0)   /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZ | M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP)
    WORD_CODE(
        _call_, XT(noop), exit
    )
WORD_END(_call_)
WORD_START(_catch_beg_,  _call_)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(0,3)
    WORD_DSTACK(1,0)   /* stack effect when jumping */
    WORD_RSTACK(0,3)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE_ALWAYS | M6FLAG_MAY_JUMP)
    WORD_CODE(_catch_beg_, exit)
WORD_END(_catch_beg_)
WORD_START(_catch_end_,  _catch_beg_)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(3,0)   /* one cell consumed by word's 'exit' */
    WORD_STACK_NONE()
    WORD_ASM_LEN(_catch_end_)
    WORD_FLAGS(M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_catch_end_, exit)
WORD_END(_catch_end_)
/* ( -- ) throw on stack or return stack underflow */
WORD_START(_check_stacks_, _catch_end_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        /* depth 0<                                    ( t|f           )
         *    M6ERR_STACK_UNDERFLOW and throw          (               )
         * rdepth 0<                                   ( t|f           )
         *    M6ERR_RETURN_STACK_UNDERFLOW and throw   (               )
         * then
         */
        depth, zero_less,
            _lit_, T(M6ERR_STACK_UNDERFLOW), and, throw,
        rdepth, zero_less,
            _lit_, T(M6ERR_RETURN_STACK_UNDERFLOW), and, throw,
        exit
    )
WORD_END(_check_stacks_)
WORD_START(_continue_, _catch_end_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
       CALL(continue), exit
    )
WORD_END(_continue_)
WORD_START(_continue_if_, _continue_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _continue_if_, _continue_, exit)
WORD_END(_continue_if_)
WORD_START(_continue_if0_, _continue_if_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _continue_if0_, _continue_, exit)
WORD_END(_continue_if0_)
/* ( m6flags -- sys ) read non-blanks string, create a new word for it. set LATEST */
WORD_START(_create_,   _continue_if0_)
    WORD_DSTACK(1,2)   /* stack effect if not jumping */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        state_fetch, zero_ne,                          /* ( m6flags t|f                  ) */
            _lit_, T(M6ERR_COMPILER_NESTING), and, throw,
        CALL(parse_name),                              /* ( m6flags c-addr u             ) */
        dup, zero_equal,                               /* ( m6flags c-addr u t|f         ) */
            _lit_, T(M6ERR_ZERO_LENGTH_NAME), and, throw,
        name_comma,                                    /* ( m6flags nt                   ) */
        CALL(_latest_optimize_),                       /* ( m6flags nt                   ) */
        dup, to_latest,                                /* ( m6flags nt                   ) */
        trail, name_to_flags_store,                    /* ( m6flags                      ) */
        _lit_tok_, colon,                              /* ( colon-sys                    ) */
        CALL(_user_locals_clear_), exit                /* ( colon-sys                    ) */
    )
WORD_END(_create_)
WORD_START(_do_,       _create_)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _do_, _do_, exit)
WORD_END(_do_)
WORD_START(_else_,     _do_)
    WORD_STACK_NONE()  /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(else), exit)
WORD_END(_else_)
/* ( nt -1|1 -- ) interpret or compile name. dtop == -1 if name is immediate */
WORD_START(_eval_name_,_else_)
    WORD_DSTACK(-1,-1) /* stack effect when not jumping */
    WORD_RSTACK(-1,-1)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        /* over name> -rot                              ( xt nt 1|-1               )
         * state @                                      ( xt nt -1|1 compiling|0   )
         * 0= if                   (   interpreting   ) ( xt nt -1|1               )
         *    drop name>flags                           ( xt m6flags               )
         *    M6FLAG_COMPILE_ONLY and                   ( xt flag                  )
         *    if                                        ( xt                       )
         *       (throw-compile-only-xt)                (                          )
         *    then                                      ( xt                       )
         *    execute exit                              ( ??                       )
         * then                    (    compiling     ) ( xt nt -1|1               )
         * nip 1+                                       ( xt 0|2                   )
         * if                                           ( xt                       )
         *    execute exit                              ( ??                       )
         * then                                         ( xt                       )
         * compile, exit                                (                          )
         */
        over, name_to_xt, minus_rot,
        state_fetch,
        _if0_, T(12+nCALLt),
            drop, name_to_flags,
            _lit_, T(M6FLAG_COMPILE_ONLY), and,
            _if_, T(2+nCALLt),
                CALL(_throw_compile_only_xt_),
            then,
            execute, exit,
        then,
        nip, one_plus,
        _if_, T(3),
            execute, exit,
        then,
        CALL(compile_comma), exit
    )
WORD_END(_eval_name_)
WORD_START(_eval_number_, _eval_name_)
    WORD_DSTACK(1,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        /* state @                                   ( x compiling|0            )
         * if                   (    compiling     ) ( x                        )
         *    postpone literal                       (                          )
         * then                                      ( x | --                   )
         */
        state_fetch,
        _if_, T(2+nCALLt),
            CALL(literal),
        then, exit
    )
WORD_END(_eval_number_)
WORD_START(_exec_token_, _eval_number_)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* (exec-token) uses tail-call optimization: cannot inline into native code */
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(_exec_token_, exit)
WORD_END(_exec_token_)
/* jump to next 'of' inside a 'case' */
WORD_START(_fallthrough_,      _exec_token_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        CALL(fallthrough), exit
    )
WORD_END(_fallthrough_)
/* (hashmap-entry@/cell) ( vec u -- key &val next ) fetch u-th entry in hashmap buckets. */
/* next is -1 for 'no_entry', or -2 for 'no_next_entry' */
WORD_START(_hashmap_entry_fetch_cell_, _fallthrough_)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    WORD_CODE(
        _lit_, T(M6HASHMAP_ENTRY_SZ_CELL), times, plus,    /* ( vec'         )           */
        dup_to_r,                                          /* ( vec          ) ( R: vec ) */
#if M6HASHMAP_ENTRY_OFF_KEY_CELL == SZ
        cell_fetch_1,                                      /* ( key          ) ( R: vec ) */
#else
        _lit_, T(M6HASHMAP_ENTRY_OFF_KEY_CELL), plus, fetch, /* same */
#endif
        r_fetch,                                           /* ( key vec      ) ( R: vec ) */
#if M6HASHMAP_ENTRY_OFF_VAL_CELL != 0
        _lit_, T(M6HASHMAP_ENTRY_OFF_VAL_CELL), plus,
#endif
        r_from,                                            /* ( key &val vec )          */
#if M6HASHMAP_ENTRY_OFF_NEXT_CELL == SZ2
        cell_fetch_2,                                      /* ( key &val next)          */
#else
        _lit_, T(M6HASHMAP_ENTRY_OFF_NEXT_CELL), plus, fetch, /* same */
#endif
        /* if no_entry, next is -1. if no_next_entry, next is -2 */
        exit
    )
WORD_END(_hashmap_entry_fetch_int_)
/* (hashmap-entry@/int) ( vec u -- key &val next ) fetch u-th entry in hashmap buckets. */
/* next is -1 for 'no_entry', or -2 for 'no_next_entry' */
WORD_START(_hashmap_entry_fetch_int_, _hashmap_entry_fetch_cell_)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    WORD_CODE(
        _lit_, T(M6HASHMAP_ENTRY_SZ_INT), times, plus,     /* ( vec'         )           */
        dup_to_r,                                          /* ( vec          ) ( R: vec ) */
#if M6HASHMAP_ENTRY_OFF_KEY_INT == 8
        int_fetch_2,                                       /* ( key          ) ( R: vec ) */
#else
        _lit_, T(M6HASHMAP_ENTRY_OFF_KEY_INT), plus, int_fetch, /* same */
#endif
        r_fetch,                                           /* ( key vec      ) ( R: vec ) */
#if M6HASHMAP_ENTRY_OFF_VAL_INT != 0
        _lit_, T(M6HASHMAP_ENTRY_OFF_VAL_INT), plus,
#endif
        r_from,                                            /* ( key &val vec )           */
#if M6HASHMAP_ENTRY_OFF_NEXT_INT == 12
        int_fetch_3,                                       /* ( key &val next)           */
#else
        _lit_, T(M6HASHMAP_ENTRY_OFF_NEXT_INT), plus, int_fetch, /* same */
#endif
#if SZ > 4
        /* if no_entry, next is -1. if no_next_entry, next is -2 */
        /* we must truncate all other values to unsigned 32-bit  */
        dup, minus_two, u_less,                           /* ( key &val next t|f       ) */
        _if_, T(2),                                       /* ( key &val next           ) */
            to_uint,                                 /* truncate next to unsigned 32-bit */
        then,                                             /* ( key &val next           ) */
#endif /* SZ > 4 */
        exit
    )
WORD_END(_hashmap_entry_fetch_int_)
/* (hashmap-indexof/cell) ( map key -- pos ) get bucket index for key in hashmap/cell */
WORD_START(_hashmap_indexof_cell_, _hashmap_entry_fetch_int_)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    WORD_CODE(
        /* given x = key^hash, return (x ^ (x >> lcap)) & (cap - 1); */
        dup, crc_cell, xor, swap,                      /* ( x=key^hash map              ) */
#if M6HASHMAP_OFF_LCAP_CELL == SZ
        cell_fetch_1,                                  /* ( x lcap                      ) */
#else
        _lit_, T(M6HASHMAP_OFF_LCAP_CELL), plus, fetch /* ( x lcap                      ) */
#endif
        one, over, lshift, one_minus,                  /* ( x lcap cap-1                ) */
        minus_rot, trail,                              /* ( cap-1 x x lcap              ) */
        rshift,                                        /* ( cap-1 x x>>lcap             ) */
        xor,                                           /* ( cap-1 x^(x>>lcap)           ) */
        and, exit                                      /* ( cap-1 & (x^(x>>lcap))       ) */
    )
WORD_END(_hashmap_indexof_cell_)
/* (hashmap-indexof/int) ( map key -- pos ) get bucket index for key in hashmap/int  */
WORD_START(_hashmap_indexof_int_, _hashmap_indexof_cell_)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    WORD_CODE(
        /* given x = key^hash, return (x ^ (x >> lcap)) & (cap - 1); */
        dup, crc_cell, xor, swap,                      /* ( x=key^hash map              ) */
#if M6HASHMAP_OFF_LCAP_INT == 4
        uint_fetch_1,                                  /* ( x lcap                      ) */
#else
        _lit_, T(M6HASHMAP_OFF_LCAP_INT), plus,        /* ( x &map.lcap                 ) */
        uint_fetch,                                    /* ( x lcap                      ) */
#endif
        one, over, lshift, one_minus,                  /* ( x lcap cap-1                ) */
        minus_rot, trail,                              /* ( cap-1 x x lcap              ) */
        rshift,                                        /* ( cap-1 x x>>lcap             ) */
        xor,                                           /* ( cap-1 x^(x>>lcap)           ) */
        and, exit                                      /* ( cap-1 & (x^(x>>lcap))       ) */
    )
WORD_END(_hashmap_indexof_int_)
WORD_START(_if_, _hashmap_indexof_int_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _if_, _if_, exit)
WORD_END(_if_)
WORD_START(_if0_, _if_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(_compile_jump_lit_, _if0_, _if_, exit)
WORD_END(_if0_)
WORD_START(_ignore_, _if0_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE)
    WORD_CODE(_compile_sys_lit_, _ignore_, _ignore_, exit)
WORD_END(_ignore_)
WORD_START(_ip_, _ignore_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_ip_, exit)
WORD_END(_ip_)
WORD_START(_ip_to_data_, _ip_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_ip_to_data_, exit)
WORD_END(_ip_to_data_)
WORD_START(_ip_to_data_addr_, _ip_to_data_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_ip_to_data_addr_, exit)
WORD_END(_ip_to_data_addr_)
WORD_START(_leave_, _ip_to_data_addr_)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(2,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(leave), exit)
WORD_END(_leave_)
WORD_START(_lit_comma_, _leave_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_comma_, T(-1), exit)
WORD_END(_lit_comma_)
WORD_START(_lit2s_, _lit_comma_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_2 | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit2s_, SHORT(-1), exit)
WORD_END(_lit2s_)
WORD_START(_lit4s_, _lit2s_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_4 | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit4s_, INT(-1), exit)
WORD_END(_lit4s_)
WORD_START(_lit8s_, _lit4s_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_8 | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit8s_, CELL(-1), exit)
WORD_END(_lit8s_)
WORD_START(_lit_nt_, _lit8s_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZ | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_nt_, NT(noop), exit)
WORD_END(_lit_nt_)
WORD_START(_lit_nt_body_, _lit_nt_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZ | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_nt_body_, NT(noop), exit)
WORD_END(_lit_nt_body_)
WORD_START(_lit_string_, _lit_nt_body_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_JUMP | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(LIT_STRING(0, ""), exit)
WORD_END(_lit_string_)
WORD_START(_lit_tok_, _lit_string_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_tok_, noop, exit)
WORD_END(_lit_tok_)
WORD_START(_lit_xt_, _lit_tok_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZ | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_xt_, XT(noop), exit)
WORD_END(_lit_xt_)
WORD(_l0_,    _lit_xt_,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l1_,    _l0_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l2_,    _l1_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l3_,    _l2_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l4_,    _l3_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l5_,    _l4_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l6_,    _l5_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l7_,    _l6_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l8_,    _l7_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_l9_,    _l8_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_la_,    _l9_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_lb_,    _la_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_lc_,    _lb_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_ld_,    _lc_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_le_,    _ld_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_lf_,    _le_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_lx_,    _lf_,      DSTACK(0,1), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
WORD(_drop_l0_,     _lx_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l1_,_drop_l0_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l2_,_drop_l1_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l3_,_drop_l2_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l4_,_drop_l3_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l5_,_drop_l4_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l6_,_drop_l5_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l7_,_drop_l6_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l8_,_drop_l7_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_l9_,_drop_l8_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_la_,_drop_l9_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_lb_,_drop_la_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_lc_,_drop_lb_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_ld_,_drop_lc_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_le_,_drop_ld_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_lf_,_drop_le_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_drop_lx_,_drop_lf_,DSTACK(1,1), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
WORD(_to_l0_,  _drop_lx_,DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l1_,  _to_l0_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l2_,  _to_l1_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l3_,  _to_l2_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l4_,  _to_l3_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l5_,  _to_l4_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l6_,  _to_l5_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l7_,  _to_l6_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l8_,  _to_l7_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_l9_,  _to_l8_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_la_,  _to_l9_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_lb_,  _to_la_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_lc_,  _to_lb_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_ld_,  _to_lc_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_le_,  _to_ld_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_lf_,  _to_le_,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_to_lx_,  _to_lf_,  DSTACK(1,0), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
WORD(_dup_to_l0_,_to_lx_,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l1_,_dup_to_l0_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l2_,_dup_to_l1_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l3_,_dup_to_l2_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l4_,_dup_to_l3_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l5_,_dup_to_l4_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l6_,_dup_to_l5_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l7_,_dup_to_l6_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l8_,_dup_to_l7_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_l9_,_dup_to_l8_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_la_,_dup_to_l9_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_lb_,_dup_to_la_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_lc_,_dup_to_lb_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_ld_,_dup_to_lc_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_le_,_dup_to_ld_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_lf_,_dup_to_le_,DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
WORD(_dup_to_lx_,_dup_to_lf_,DSTACK(1,1), RSTACK(0,0), M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
/* ( -- ls ) create a new m6locals data structure and initialize it */
WORD_START(_locals_allocate_,  _dup_to_lx_)
    WORD_DSTACK(3,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        _lit_, T(LOCALS_SZ + 16 * (LOCAL_SZ + 255)),   /* ( sizeof(m6locals) + capacity     ) */
        dup, CALL(allocate), throw,                    /* ( cap ls                          ) */
        tuck, cell_store_2,      /* set ls.cap */      /* ( ls                              ) */
        zero, over, store,       /* set ls.n   */      /* ( ls                              ) */
        zero, over, cell_store_1,/* set ls.end */      /* ( ls                              ) */
        exit
    )
WORD_END(_locals_allocate_)
/* ( ls c-addr u -- ) create a new local variable. */
WORD_START(_locals_add_,  _locals_allocate_)
    WORD_DSTACK(3,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* throw if ls == 0 */
        hop, zero_equal,                       /* ( ls c-addr u t|f            ) */
        _lit_, T(M6ERR_INVALID_MEMORY_ADDRESS),/* ( ls c-addr u t|f err        ) */
        and, throw,                            /* ( ls c-addr u                ) */
        /* throw if name too long */
        dup, dup, to_char, ne,                 /* ( ls c-addr u t|f            ) */
        _if_, T(5),                            /* ( ls c-addr u                ) */
            ex_message_store,                  /* ( ls                         ) */
            _lit_, T(M6ERR_DEFINITION_NAME_TOO_LONG),/* ( ls                   ) */
            throw,                             /* (                            ) */
        then,                                  /* ( ls c-addr u                ) */
        /* throw if too many names */
        rot, dup, fetch,                       /* ( c-addr u ls n              ) */
        _lit_, T(0xff), more_equal,            /* ( c-addr u ls t|f            ) */
        _lit_, T(M6ERR_LOCALS_OVERFLOW), and,  /* ( c-addr u ls err|0          ) */
        throw,                                 /* ( c-addr u ls                ) */
        /* throw if locals array overflow */
        dup, cell_fetch_1,                     /* ( c-addr u ls ls.end         ) */
        over, cell_fetch_2,                    /* ( c-addr u ls ls.end ls.cap  ) */
        sub,                                   /* ( c-addr u ls avail_bytes    ) */
        hop, two_plus,                         /* ( c-addr u ls avail_bytes u' ) */
        u_less,                                /* ( c-addr u ls t|f            ) */
        _lit_, T(M6ERR_LOCALS_OVERFLOW), and,  /* ( c-addr u ls err|0          ) */
        throw,                                 /* ( c-addr u ls                ) */
        /* add new local variable */
        over, two_plus, to_r,                  /* ( c-addr u ls      ) ( R: u+2    ) */
        dup_to_r,                              /* ( c-addr u ls      ) ( R: u+2 ls ) */
        cell_fetch_1,                          /* ( c-addr u end     ) ( R: u+2 ls ) */
        r_fetch, three, cells, plus,           /* ( c-addr u end vec ) ( R: u+2 ls ) */
        plus,                                  /* ( c-addr u l       ) ( R: u+2 ls ) */
        zero, over, c_store, /* set l.idx         ( c-addr u l       ) ( R: u+2 ls ) */
        one_plus,            /*                   ( c-addr u l+1     ) ( R: u+2 ls ) */
        two_dup, c_store,    /* set l.n           ( c-addr u l+1     ) ( R: u+2 ls ) */
        one_plus,            /*                   ( c-addr u l+2     ) ( R: u+2 ls ) */
        swap, cmove,         /* set l chars       (                  ) ( R: u+2 ls ) */
        one, r_fetch,        /*                   ( 1 ls             ) ( R: u+2 ls ) */
        plus_store,          /* set locals.n      (                  ) ( R: u+2 ls ) */
        two_r_from,          /*                   ( u+2 ls           )              */
        cell_plus, plus_store, /* set locals.end  (                  )              */
        exit
    )
WORD_END(_locals_add_)
/* ( ls -- ) remove all local variables from specified m6locals struct */
WORD_START(_locals_clear_,_locals_add_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        _q_if0_, T(3),                         /* ( 0                ) */
            drop, exit,                        /* (                  ) */
        then,                                  /* ( ls               ) */
        zero, over, store,   /* set l.n */     /* ( ls               ) */
        zero, swap,                            /* ( 0 ls             ) */
        cell_store_1, exit   /* set l.end */   /* (                  ) */
    )
WORD_END(_locals_clear_)
WORD(      _lenter_1_,    _locals_clear_,   DSTACK(0,0), RSTACK(0,2), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD(      _lenter_2_,    _lenter_1_, DSTACK(0,0), RSTACK(0,3), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD(      _lenter_3_,    _lenter_2_, DSTACK(0,0), RSTACK(0,4), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_4_,    _lenter_3_, DSTACK(0,0), RSTACK(0,5), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_5_,    _lenter_4_, DSTACK(0,0), RSTACK(0,6), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_6_,    _lenter_5_, DSTACK(0,0), RSTACK(0,7), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_7_,    _lenter_6_, DSTACK(0,0), RSTACK(0,8), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_8_,    _lenter_7_, DSTACK(0,0), RSTACK(0,9), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_9_,    _lenter_8_, DSTACK(0,0), RSTACK(0,10), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_a_,    _lenter_9_, DSTACK(0,0), RSTACK(0,11), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_b_,    _lenter_a_, DSTACK(0,0), RSTACK(0,12), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_c_,    _lenter_b_, DSTACK(0,0), RSTACK(0,13), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_d_,    _lenter_c_, DSTACK(0,0), RSTACK(0,14), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_e_,    _lenter_d_, DSTACK(0,0), RSTACK(0,-1), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_f_,    _lenter_e_, DSTACK(0,0), RSTACK(0,-1), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lenter_g_,    _lenter_f_, DSTACK(0,0), RSTACK(0,-1), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_START(_lenter_x_,   _lenter_g_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,-1)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lenter_x_, T(0), exit)
WORD_END(_lenter_x_)
WORD_START(_lexit_x_,   _lenter_x_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(-1,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_lexit_x_, T(0), exit)
WORD_END(_lexit_x_)
WORD      (_lexit_1_,    _lexit_x_, DSTACK(0,0), RSTACK(2,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD      (_lexit_2_,    _lexit_1_, DSTACK(0,0), RSTACK(3,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD(      _lexit_3_,    _lexit_2_, DSTACK(0,0), RSTACK(4,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_4_,    _lexit_3_, DSTACK(0,0), RSTACK(5,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_5_,    _lexit_4_, DSTACK(0,0), RSTACK(6,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_6_,    _lexit_5_, DSTACK(0,0), RSTACK(7,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_7_,    _lexit_6_, DSTACK(0,0), RSTACK(8,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_8_,    _lexit_7_, DSTACK(0,0), RSTACK(9,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_9_,    _lexit_8_, DSTACK(0,0), RSTACK(10,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_a_,    _lexit_9_, DSTACK(0,0), RSTACK(11,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_b_,    _lexit_a_, DSTACK(0,0), RSTACK(12,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_c_,    _lexit_b_, DSTACK(0,0), RSTACK(13,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_d_,    _lexit_c_, DSTACK(0,0), RSTACK(14,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_e_,    _lexit_d_, DSTACK(0,0), RSTACK(-1,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_f_,    _lexit_e_, DSTACK(0,0), RSTACK(-1,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
WORD_NOASM(_lexit_g_,    _lexit_f_, DSTACK(0,0), RSTACK(-1,0), M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS)
/* ( ls c-addr u -- idx|-1 ) find local variable */
WORD_START(_locals_find_, _lexit_g_)
    WORD_DSTACK(3,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        two_to_r,                              /* ( ls                  ) ( R: c-addr u ) */
        CALL(_locals_first_),                  /* ( ls l|0              ) ( R: c-addr u ) */
        begin,                                 /* ( ls l|0              ) ( R: c-addr u ) */
        _q_while_, T(28+nCALLt),               /* ( ls l                ) ( R: c-addr u ) */
            dup, one_plus, count,              /* ( ls l c-addr' u'     ) ( R: c-addr u ) */
            dup, r_fetch, equal,               /* ( ls l c-addr' u' t|f ) ( R: c-addr u ) */
            _if_, T(15),                       /* ( ls l c-addr' u'     ) ( R: c-addr u ) */
                r2nd_fetch, swap,              /* ( ls l c-addr' c-addr u' ) ( R: c-addr u ) */
                string_ci_equal, nip, nip, nip,/* ( ls l t|f            ) ( R: c-addr u ) */
                _if_, T(5),                    /* ( ls l                ) ( R: c-addr u ) */
                    nip, two_r_from_two_drop,  /* ( l                   )                */
                    c_fetch, exit,             /* ( idx                 )                */
                then,                          /* ( ls l                ) ( R: c-addr u ) */
            _else_, T(2),                      /* ( ls l c-addr' u'     ) ( R: c-addr u ) */
                two_drop,                      /* ( ls l                ) ( R: c-addr u ) */
            then,                              /* ( ls l                ) ( R: c-addr u ) */
            CALL(_locals_next_),               /* ( ls l'|0             ) ( R: c-addr u ) */
        _repeat_, T(-30-nCALLt),               /* ( ls 0                ) ( R: c-addr u ) */
        nip, two_r_from_two_drop,              /* ( 0                   )                */
        one_minus, exit                        /* ( -1                  )                */
    )
WORD_END(_locals_find_)
/* ( ls -- ls l|0  ) get first local variable */
WORD_START(_locals_first_,     _locals_find_)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        _q_if0_, T(3),                         /* ( 0                )           */
            dup, exit,                         /* ( 0 0              )           */
        then,                                  /* ( ls               )           */
        dup, fetch, zero_ne,                   /* ( ls t|f           )           */
        over, cell_fetch_1, zero_ne, and,      /* ( ls t|f'          )           */
        over, three, cells, plus,              /* ( ls t|f l         )           */
        and, exit                              /* ( ls l|0           )           */
    )
WORD_END(_locals_first_)
/* ( ls l -- ls l'|0 ) get next local variable */
WORD_START(_locals_next_,      _locals_first_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        dup, char_fetch_1, plus, two_plus,     /* ( ls l'               )        */
        over, cell_fetch_1,                    /* ( ls l ls.end         )        */
        hop, three, cells, plus,               /* ( ls l ls.end ls.vec  )        */
        plus,                                  /* ( ls l ls.vec+ls.end  )        */
        over, more,                            /* ( ls l t|f            )        */
        and, exit                              /* ( ls l|0              )        */
    )
WORD_END(_locals_next_)
/* ( ls -- ) compute indexes of existing variables. */
WORD_START(_locals_set_idx_,  _locals_next_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        _q_if0_, T(3),                         /* ( 0                )           */
            drop, exit,                        /* ( 0                )           */
        then,                                  /* ( ls               )           */
        dup, fetch, to_r,                      /* ( ls               ) ( R: n   ) */
        CALL(_locals_first_),                  /* ( ls l|0           ) ( R: n   ) */
        begin,                                 /* ( ls l|0           ) ( R: i   ) */
        _q_while_, T(7+nCALLt),                /* ( ls l             ) ( R: i   ) */
            r_one_minus, r_fetch,              /* ( ls l i-1         ) ( R: i'  ) */
            over, c_store,                     /* ( ls l             ) ( R: i   ) */
            CALL(_locals_next_),               /* ( ls l'|0          ) ( R: i   ) */
        _repeat_, T(-9-nCALLt),                /* ( ls 0             ) ( R: i   ) */
        two_drop, r_from_drop, exit            /* (                  )           */
    )
WORD_END(_locals_set_idx_)
WORD_START(_loop_,     _locals_set_idx_)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(2,2)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP |M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(loop), exit)
WORD_END(_loop_)
WORD(_missing_,        _loop_,         DSTACK(0,0), RSTACK(0,0), WORD_IMPURE | M6FLAG_JUMP)
WORD_START(_recurse_,  _missing_)
    WORD_DSTACK(-1,-1)  /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0)    /* stack effect when jumping */
    WORD_RSTACK(0,1)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt| M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(recurse), exit)
WORD_END(_recurse_)
WORD_START(_repeat_,   _recurse_)
    WORD_STACK_NONE() /* dummy, always jumps       */
    WORD_DSTACK(0,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP | M6FLAG_IMMEDIATE | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(CALL(repeat), exit)
WORD_END(_repeat_)
/* ( -- ) type " ok\n" if interpreting, otherwise type " compiled\n" */
WORD_START(_repl_type_ack_, _repeat_)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_STACK_NONE() /* stack effect when jumping */
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        state_fetch,
        _if_, T(3+nSTRt(10)),
            LIT_STRING(10, " compiled\n"),
        _else_, T(2+nSTRt(4)),
            LIT_STRING(4, " ok\n"),
        then,
        type, exit
    )
WORD_END(_repl_type_ack_)
/* (>lx,) ( c-addr u idx -- ) compile a store to local variable */
WORD_START(_to_lx_comma_, _repl_type_ack_)
    WORD_DSTACK(3,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        state_fetch,                                         /* ( c-addr u idx flag   ) */
        _if0_, T(6),                                         /* ( c-addr u idx        ) */
            drop, ex_message_store,                          /* (                     ) */
            _lit_, T(M6ERR_INTERPRETING_COMPILE_ONLY_WORD),  /* (                     ) */
            throw,                                           /* (                     ) */
        then,                                                /* ( c-addr u idx        ) */
        nip, nip,                                            /* (idx                  ) */
        _lit_comma_, _to_lx_,    /* compile (>lx)   */
        token_comma, exit        /* compile T(idx)  */
    )
WORD_END(_to_lx_comma_)
/* (to-value) ( nt -- ) execute or compile a store to a VALUE */
WORD_START(_to_value_, _to_lx_comma_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        state_fetch,                                          /* ( nt flag            ) */
        _if0_, T(3),                                          /* ( nt                 ) */
            /* interpreting. store immediately to nt body        ( x nt               ) */
            name_to_data_addr,                                /* ( x addr             ) */
            store, exit,                                      /* (                    ) */
        then,                                                 /* ( nt                 ) */
        /* compiling. compile a store to nt body                 ( nt                 ) */
        _lit_comma_, _lit_nt_body_,/* compile '(lit-nt>body)' ( nt                 ) */
        comma,                        /* compile nt              (                    ) */
        _lit_comma_, store,           /* compile '!'             (                    ) */
        exit
    )
WORD_END(_to_value_)
WORD_START(_until_, _to_value_)
    WORD_DSTACK(1,0) /* runtime stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* runtime stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _lit_tok_, _until_,
        CALL(_until_comma_), exit
    )
WORD_END(_until_)
WORD_START(_until0_, _until_)
    WORD_DSTACK(1,0) /* runtime stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* runtime stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _lit_tok_, _until0_,
        CALL(_until_comma_), exit
    )
WORD_END(_until0_)
/* common implementation to compile 'until' '(until)' '(until0)' */
WORD_START(_until_comma_, _until0_)
    WORD_DSTACK(3,0) /* runtime stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        to_r,                                    /* ( sys              ) ( R: tok  )     */
        _check_lit_tok_, begin,                  /* ( sys              ) must be 'begin' */
        r_from, _lit_tok_, _until_,              /* ( sys tok category )                 */
        _compile_jump_,                          /* ( sys sys-until    )                 */
        CALL(_resolve_jump_there_), /* resolve jump offset from 'until' to 'begin'       */
        exit                                     /* ( sys              )                 */
    )
WORD_END(_until_comma_)
WORD_START(_while_, _until_comma_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _check_lit_tok_, begin,             /* ( sys ) topmost must be 'begin' */
        _compile_jump_lit_, _while_, _while_,
        cs_swap, exit                       /* ( while-sys begin-sys )         */
    )
WORD_END(_while_)
WORD_START(_while0_, _while_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _check_lit_tok_, begin,             /* ( sys ) topmost must be 'begin' */
        _compile_jump_lit_, _while0_, _while_,
        cs_swap, exit                       /* ( while-sys begin-sys )         */
    )
WORD_END(_while0_)
/**
 * find an optimized sequence to replace a single token being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens | 0 )
 */
WORD_START(_optimize_1token_, _while0_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_N_AUTO(_optimize_1token_)
    WORD_DATA_N_AUTO(_optimize_1token_)
    WORD_CODE_START(_optimize_1token_)
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        /*28*/ _ip_to_data_, one_token, minus, bounds, rot, token_fetch, minus_rot,
        _do_, T(15), dup, i_token_fetch, equal, _if_, T(6), drop, i, token_plus, unloop, exit,
        then, four, tokens, _plus_loop_, T(-15), drop, zero, exit
      )
    WORD_CODE_END(_optimize_1token_)
    WORD_DATA_START(_optimize_1token_)
#define OPT1_TO_ASM_TOKENS(...)                                                                    \
        WRAP_ARGS(M6TOKEN_VAL_COMMA,                                                               \
              FIRST_ARG(__VA_ARGS__),                                                              \
              T(COUNT_ARGS(__VA_ARGS__) - 1),                                                      \
              SKIP_FIRST_ARG(FIRST_3_ARGS(__VA_ARGS__, _missing_, _missing_, _missing_)))

        CAT3(.,SZt,byte) OPT1_RULES(OPT1_TO_ASM_TOKENS) M6TOKEN_VAL(_missing_);

    WORD_DATA_END(_optimize_1token_)
WORD_END(_optimize_1token_)
/**
 * find an optimized sequence to replace two tokens being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens | 0 )
 */
WORD_START(_optimize_2token_, _optimize_1token_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE|M6FLAG_DATA_TOKENS)
    WORD_CODE_N_AUTO(_optimize_2token_)
    WORD_DATA_N_AUTO(_optimize_2token_)
    WORD_CODE_START(_optimize_2token_)
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        /*17*/ _ip_to_data_addr_, swap, dup, token_fetch, swap, token_fetch_1,
        eight, tokens, lshift, or, CALL(hashmap_find_int), nip, exit
      )
    WORD_CODE_END(_optimize_2token_)
    WORD_DATA_START(_optimize_2token_)
#define H2_START(size, lcap) WORD_DATA_INTS(size, lcap) WORD_DATA_CELLS(.+ 8)
#define H2_ENTRY(key, val, next) WORD_DATA_CELLS(val) WORD_DATA_INTS(key, next)
      OPT2_HASHMAP(H2_START, H2_ENTRY)
#undef H2_START
#undef H2_ENTRY
    WORD_DATA_END(_optimize_2token_)
WORD_END(_optimize_2token_)
/**
 * find a medium-priority optimized sequence to replace two tokens being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens | 0 )
 */
WORD_START(_optimize_2token_midprio_, _optimize_2token_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE|M6FLAG_DATA_TOKENS)
    WORD_CODE_N_AUTO(_optimize_2token_midprio_)
    WORD_DATA_N_AUTO(_optimize_2token_midprio_)
    WORD_CODE_START(_optimize_2token_midprio_)
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        /*17*/ _ip_to_data_addr_, swap, dup, token_fetch, swap, token_fetch_1,
        eight, tokens, lshift, or, CALL(hashmap_find_int), nip, exit
      )
    WORD_CODE_END(_optimize_2token_midprio_)
    WORD_DATA_START(_optimize_2token_midprio_)
#define H2_START(size, lcap) WORD_DATA_INTS(size, lcap) WORD_DATA_CELLS(.+ 8)
#define H2_ENTRY(key, val, next) WORD_DATA_CELLS(val) WORD_DATA_INTS(key, next)
      OPT2_MIDPRIO_HASHMAP(H2_START, H2_ENTRY)
#undef H2_START
#undef H2_ENTRY
    WORD_DATA_END(_optimize_2token_midprio_)
WORD_END(_optimize_2token_midprio_)
/**
 * find a low-priority optimized sequence to replace two tokens being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens | 0 )
 */
WORD_START(_optimize_2token_lowprio_, _optimize_2token_midprio_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE|M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_optimize_2token_lowprio_,
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        /*24*/ _ip_to_data_addr_, swap, uint_fetch, to_r,
        begin,
            dup, uint_fetch,
        _q_while_, T(13),
            r_fetch, ne,
        _while_, T(5),
            four, tokens, plus,
        _repeat_, T(-13),
            zero, swap, uint_plus,
        then,
        nip, r_from_drop, exit
      ),
      WORD_DATA_TOKENS(
        drop, drop, /*=>*/ T(1), two_drop,
        over, over, /*=>*/ T(1), two_dup,
        T(0), T(0)
      )
    )
WORD_END(_optimize_2token_lowprio_)
/**
 * find an optimized sequence to replace three tokens being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens | 0 )
 */
WORD_START(_optimize_3token_, _optimize_2token_lowprio_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_N_AUTO(_optimize_3token_)
    WORD_DATA_N_AUTO(_optimize_3token_)
    WORD_CODE_START(_optimize_3token_)
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        /*24*/ _ip_to_data_addr_, swap, dup_to_r, token_fetch, i, token_fetch_1, eight, tokens, lshift, or,
        r_from, token_fetch_2, _lit2s_, T(12+nCALLt), tokens, lshift, or, CALL(hashmap_find_cell),
        nip, exit
      )
    WORD_CODE_END(_optimize_3token_)
    WORD_DATA_START(_optimize_3token_)
#define H3_START(size, lcap) WORD_DATA_CELLS(size, lcap, .+ 8)
#define H3_ENTRY(key, val, next) WORD_DATA_CELLS(val, key, next)
      OPT3_HASHMAP(H3_START, H3_ENTRY)
#undef H3_START
#undef H3_ENTRY
    WORD_DATA_END(_optimize_3token_)
WORD_END(_optimize_3token_)
/**
 * find an optimized sequence to replace three tokens being compiled,
 * which may be part of control flow i.e. 'if' 'else' 'case' etc.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens|0 )
 */
WORD_START(_optimize_3jump_, _optimize_3token_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_optimize_3jump_,
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        /*38*/ _ip_to_data_addr_, swap, dup, token_fetch, swap, token_fetch_2,
        eight, tokens, lshift, or, to_r,
        begin,
            dup, token_fetch,
        _q_while_, T(20),
            over, token_fetch_1, eight, tokens, lshift, or,
            i, ne,
        _while_, T(5),
            four, tokens, plus,
        _repeat_, T(-19),
            zero, swap, token_plus, token_plus,
        then,
        nip, r_from_drop, exit
      ),
      WORD_DATA_TOKENS(
          _if_,    /*T(n)*/ then, /*=>*/ T(1), drop,
          _if0_,   /*T(n)*/ then, /*=>*/ T(1), drop,
          _q_if_,  /*T(n)*/ then, /*=>*/ T(0), _missing_,
          _q_if0_, /*T(n)*/ then, /*=>*/ T(0), _missing_,
          _else_,  /*T(n)*/ then, /*=>*/ T(1), then,
          _if_,    /*T(n)*/ _else_, /*=>*/ T(1), _if0_,
          _if0_,   /*T(n)*/ _else_, /*=>*/ T(1), _if_,
          _q_if_,  /*T(n)*/ _else_, /*=>*/ T(1), _q_if0_,
          _q_if0_, /*T(n)*/ _else_, /*=>*/ T(1), _q_if_,
          T(0)
      )
    )
WORD_END(_optimize_3jump_)
/**
 * find an optimized sequence to replace three tokens being compiled,
 * related to local variables.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens|0 )
 */
WORD_START(_optimize_3local_, _optimize_3jump_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_optimize_3local_,
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        /*38*/
        _ip_to_data_addr_, over,                    /* ( tok-addr &data tok-addr ) */
        token_fetch, _lit_tok_, _lx_, equal, and,   /* ( tok-addr &data|0        ) */
        swap, token_fetch_2, _lit_tok_, drop, equal,/* ( &data|0 t|f             ) */
        and, exit                                   /* ( &data|0                 ) */
        /* '(lx) T(n) drop' optimizes to a noop */
      ),
      WORD_DATA_TOKENS(
          T(0)
      )
    )
WORD_END(_optimize_3local_)
/**
 * find an optimized sequence to replace four tokens being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens|0 )
 */
WORD_START(_optimize_4token_, _optimize_3local_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_optimize_4token_,
      WORD_CODE_TOKENS(
        _ip_to_data_, bounds,                          /* ( addr end beg        )                */
        do,                                            /* ( addr                ) ( R: end pos ) */
            dup, token_fetch,                          /* ( addr tok0           ) ( R: end pos ) */
            i_token_fetch, equal,                      /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(21),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_2,                        /* ( addr tok2           ) ( R: end pos ) */
            i, token_fetch_2, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(14),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_3,                        /* ( addr tok3           ) ( R: end pos ) */
            i, token_fetch_3, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(7),                          /* ( addr                ) ( R: end pos ) */
            drop, i, four, tokens, plus,               /* ( counted-tokens      ) ( R: end pos ) */
            unloop, exit,                              /* ( counted-tokens      )                */

            six, tokens,                               /* ( addr +loop-offset   ) ( R: end pos ) */
        _plus_loop_, T(-31),                           /* ( addr                )                */
        drop, zero, exit                               /* ( 0                   )                */
      ),
      WORD_DATA_TOKENS(
        _q_if_, T(0), dup, then, /*=>*/ T(1), question_dup
      )
    )
WORD_END(_optimize_4token_)
/**
 * find an optimized sequence to replace five tokens being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens|0 )
 */
WORD_START(_optimize_5token_, _optimize_4token_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_optimize_5token_,
      WORD_CODE_TOKENS(
        _ip_to_data_, bounds,                          /* ( addr end beg        )                */
        do,                                            /* ( addr                ) ( R: end pos ) */
            dup, token_fetch,                          /* ( addr tok0           ) ( R: end pos ) */
            i_token_fetch, equal,                      /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(21),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_2,                        /* ( addr tok2           ) ( R: end pos ) */
            i, token_fetch_2, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(14),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_4,                        /* ( addr tok3           ) ( R: end pos ) */
            i, token_fetch_4, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(7),                          /* ( addr                ) ( R: end pos ) */
            drop, i, five, tokens, plus,               /* ( counted-tokens      ) ( R: end pos ) */
            unloop, exit,                              /* ( counted-tokens      )                */

            eight, tokens,                             /* ( addr +loop-offset   ) ( R: end pos ) */
        _plus_loop_, T(-31),                           /* ( addr                )                */
        drop, zero, exit                               /* ( 0                   )                */
      ),
      WORD_DATA_TOKENS(
        /* the final '_missing_' must be a token consuming no IP. */
        /* it will be replaced with correct jump offset by [recompile] */
        _if_, T(0), _continue_, T(0), then, /*=>*/ T(2), _continue_if_, _missing_,
        _if0_, T(0), _continue_, T(0), then, /*=>*/ T(2), _continue_if0_, _missing_,
        _q_if_, T(0), _continue_, T(0), then, /*=>*/ T(2), _q_continue_if_, _missing_,
        _q_if0_, T(0), _continue_, T(0), then, /*=>*/ T(2), _q_continue_if0_, _missing_
      )
    )
WORD_END(_optimize_5token_)
/**
 * find an optimized sequence to replace seven tokens being compiled.
 * if no optimized sequence was found, return 0
 * ( tok-addr -- counted-tokens|0 )
 */
WORD_START(_optimize_7token_, _optimize_5token_)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_optimize_7token_,
      WORD_CODE_TOKENS(
        _ip_to_data_, bounds,                          /* ( addr end beg        )                */
        do,                                            /* ( addr                ) ( R: end pos ) */
            dup, token_fetch,                          /* ( addr tok0           ) ( R: end pos ) */
            i_token_fetch, equal,                      /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(35),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_2,                        /* ( addr tok2           ) ( R: end pos ) */
            i, token_fetch_2, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(28),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_3,                        /* ( addr tok3           ) ( R: end pos ) */
            i, token_fetch_3, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(21),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_5,                        /* ( addr tok5           ) ( R: end pos ) */
            i, token_fetch_5, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(14),                         /* ( addr                ) ( R: end pos ) */
            dup, token_fetch_6,                        /* ( addr tok5           ) ( R: end pos ) */
            i, token_fetch_6, equal,                   /* ( addr t|f            ) ( R: end pos ) */
        _continue_if0_, T(7),                          /* ( addr                ) ( R: end pos ) */
            drop, i, seven, tokens, plus,              /* ( counted-tokens      ) ( R: end pos ) */
            unloop, exit,                              /* ( counted-tokens      )                */

            _lit_, T(12), tokens,                      /* ( addr +loop-offset   ) ( R: end pos ) */
        _plus_loop_, T(-46),                           /* ( addr                )                */
        drop, zero, exit                               /* ( 0                   )                */
      ),
      WORD_DATA_TOKENS(
        _if_,    T(0), drop, _else_, T(0), nip,  then, /*=>*/ T(1), choose, T(0), T(0), T(0),
        _if0_,   T(0), drop, _else_, T(0), nip,  then, /*=>*/ T(2), zero_equal, choose, T(0), T(0),
        _if_,    T(0), nip,  _else_, T(0), drop, then, /*=>*/ T(2), zero_equal, choose, T(0), T(0),
        _if0_,   T(0), nip,  _else_, T(0), drop, then, /*=>*/ T(1), choose, T(0), T(0), T(0),
        _q_if_,  T(0), drop, _else_, T(0), nip,  then, /*=>*/ T(2), dup, choose, T(0), T(0),
        _q_if0_, T(0), drop, _else_, T(0), nip,  then, /*=>*/ T(3), dup, zero_equal, choose, T(0),
        _q_if_,  T(0), nip,  _else_, T(0), drop, then, /*=>*/ T(3), dup, zero_equal, choose, T(0),
        _q_if0_, T(0), nip,  _else_, T(0), drop, then, /*=>*/ T(2), dup, choose, T(0), T(0)
      )
    )
WORD_END(_optimize_7token_)
/**
 * find an optimized sequence to replace N tokens being compiled.
 * return address of optimized sequence and u' = number of consumed tokens, or 0 0
 * ( tok-addr u opts -- counted-tokens u' | 0 0 )
 */
WORD_START(_optimize_tokens_, _optimize_7token_)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(_optimize_tokens_,
      WORD_CODE_TOKENS(/* generated from file impl.forth - see source and comments there */
        _ip_to_data_addr_, swap, to_r, minus_rot, two_to_r,
        begin,
            dup, token_fetch, dup,
            r3rd_fetch, and, swap, to_char,
        _q_while_, T(31),
            r_fetch, u_less_equal,
        _while_, T(25),
            _if_, T(7),
                r2nd_fetch, over,
                token_plus, fetch, execute,
            _else_, T(2),
                zero,
            then,
        _q_while0_, T(5),
            drop, token_plus, cell_plus,
        _repeat_, T(-31),
            swap, token_fetch, to_char,
            two_r_from_two_drop, r_from_drop, exit,
        then,
            zero,
        then,
        nip, two_drop, zero, zero,
        two_r_from_two_drop, r_from_drop, exit
      ),
      WORD_DATA_TOKENS(
        /* must be ordered by increasing length of optimized sequence */
        T(1|M6OPTS_PRIO_HIGH), XT(_optimize_1token_),
        T(2|M6OPTS_PRIO_HIGH), XT(_optimize_2token_),
        T(2|M6OPTS_PRIO_MID),  XT(_optimize_2token_midprio_),
        T(2|M6OPTS_PRIO_LOW),  XT(_optimize_2token_lowprio_),
        T(3|M6OPTS_PRIO_HIGH), XT(_optimize_3token_),
        T(3|M6OPTS_PRIO_HIGH), XT(_optimize_3jump_),
        T(3|M6OPTS_PRIO_HIGH), XT(_optimize_3local_),
        T(4|M6OPTS_PRIO_HIGH), XT(_optimize_4token_),
        T(5|M6OPTS_PRIO_HIGH), XT(_optimize_5token_),
        T(7|M6OPTS_PRIO_HIGH), XT(_optimize_7token_),
        T(0)
      )
    )
WORD_END(_optimize_tokens_)
/**
 * copy and optimize at least one token from src to HERE. updates HERE.
 * return number of consumed tokens, and true if an optimized sequence was found, else false.
 * ( src u opts -- u' t|f )
 */
WORD_START(_optimize_tokens_comma_, _optimize_tokens_)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(/* generated from file impl.forth - see source and comments there */
        over,
        _if0_, T(5),
            drop, nip, false, exit,
        then,
        to_r, trail, r_from,
        CALL(_optimize_tokens_), swap,
        _q_if_, T(13+3*nCALLt),
            flip, over, tokens, plus, rot, dup,
            CALL(countedtokens_comma),
            CALL(countedtokens_to_last),
            CALL(_token_consumed_ip_comma_),
            plus, true,
        _else_, T(11+nCALLt),
            two_drop, dup, token_plus,
            swap, token_fetch, dup, token_comma,
            CALL(_token_consumed_ip_comma_),
            one_plus, false,
        then, exit
    )
WORD_END(_optimize_tokens_comma_)
/* ( x -- token t | x f ) try to optimize '[ x ] literal' */
WORD_START(_optimize_literal_, _optimize_tokens_comma_)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_DATA_TOKENS) /* multiple exits => cannot inline */
    WORD_CODE_AND_DATA(
      _optimize_literal_,
      WORD_CODE_TOKENS(
        _ip_to_data_, bounds, _do_, T(16),             /* loop on this word's data    */
            dup, i_short_fetch, equal,                 /* ( x t|f   ) ( R: end addr ) */
            _if_, T(8),                                /* ( x       ) ( R: end addr ) */
                drop, i, token_plus, token_fetch,      /* ( token   ) ( R: end addr ) */
                true, unloop, exit,                    /* ( token true )              */
            then,                                      /* ( x       ) ( R: end addr ) */
            one_token,                                 /* ( x SZt   ) ( R: end addr ) */
        _plus_loop_, T(-16),                           /* ( x       )                 */
        false, exit                                    /* ( x false )                 */
      ),
      WORD_DATA_TOKENS(
        T(-2), minus_two, T(-1), minus_one,
        T(0), zero, T(1), one, T(2), two, T(3), three,
        T(4), four, T(5), five, T(6), six, T(7), seven,
        T(8), eight, T(16), sixteen, T(32), bl
      )
    )
WORD_END(_optimize_literal_)
WORD(_num_compiled_,_optimize_literal_,DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_COMPILE_ONLY)
/* ( x -- x ) followed by e = expected x. throws if x <> e */
WORD_START(_check_lit_tok_, _num_compiled_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* consumes IP and uses IP-relative JUMP(), cannot inline in native code */
    WORD_FLAGS(M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_check_lit_tok_, _missing_,  exit)
WORD_END(_check_lit_tok_)
/*
 * ( token category -- sys )
 * append unresolved jump to XT being compiled i.e. token and T(-1),
 * then push sys to dstack i.e. jump_location (= # of tokens of XT being compiled) and category.
 */
WORD_START(_compile_jump_, _check_lit_tok_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses IP-relative TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(_compile_jump_, exit)
WORD_END(_compile_jump_)
/*
 * ( -- sys ) must be followed by m6token and its category.
 * append unresolved jump to XT being compiled i.e. m6token and T(-1),
 * then push sys to dstack i.e. jump_location (= # of tokens of XT being compiled) and category.
 */
WORD_START(_compile_jump_lit_, _compile_jump_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* consumes IP and uses IP-relative TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt2 | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_compile_jump_lit_, T(-1), T(-1), exit)
WORD_END(_compile_jump_lit_)
/*
 * ( -- sys ) must be followed by m6token and its category.
 * append the token to XT being compiled,
 * then push sys to dstack i.e. jump_location (= # of tokens of XT being compiled) and category.
 */
WORD_START(_compile_sys_lit_, _compile_jump_lit_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* consumes IP and uses IP-relative TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt2 | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_compile_sys_lit_, T(-1), T(-1), exit)
WORD_END(_compile_sys_lit_)
/*
 * [compile-local]   ( idx -- )
 * compile a local variable fetch
 */
WORD_START(_compile_local_, _compile_sys_lit_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        _lit_comma_, _lx_,          /* compile '(lx)'  ( idx                        ) */
        token_comma, exit           /* compile T(idx)  (                            ) */
    )
WORD_END(_compile_local_)
/*
 * [compile-lenter]   ( n1_before_pipe n2_after_pipe -- )
 * compile code to initialize local variables
 */
WORD_START(_compile_lenter_, _compile_local_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        tuck, plus,                   /*               ( n2 n=n1+n2                 ) */
        _q_if0_, T(3),                /*               ( 0 0                        ) */
            two_drop, exit,           /*               (                            ) */
        then,                         /*               ( n2 n                       ) */
        _lit_comma_, _lenter_x_,/* compile '(lenter)'                     */
        tuck,                         /*               ( n n2 n                     ) */
        token_comma,                  /* compile T(n)  ( n n2                       ) */
        _q_do_, T(6),                 /*               (                 ) ( R: n i ) */
            _lit_comma_, _to_lx_,     /* compile '(>lx)'  (              ) ( R: n i ) */
            i, token_comma,           /* compile T(i)  (                 ) ( R: n i ) */
        _loop_, T(-6),                /*               (                            ) */
        exit
    )
WORD_END(_compile_lenter_)
/*
 * ( sys+ -- sys+ cs-depth ) must be followed by category.
 * find category in control stack and return its cs-depth.
 * Stops at colon-sys, throws if not found.
 */
WORD_START(_cs_find_lit_, _compile_lenter_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* consumes IP and uses IP-relative JUMP(), cannot inline in native code */
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS)
    WORD_CODE(_cs_find_lit_, T(-1),  exit)
WORD_END(_cs_find_lit_)
/* throw M6ERR_DEFER_UNINITIALIZED */
WORD_START(_defer_uninitialized_, _cs_find_lit_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(_lit_, T(M6ERR_DEFER_UNINITIALIZED), throw, exit)
WORD_END(_defer_uninitialized_)
/* ( -- ) replace execution semantics of latest word, setting it to code after caller's IP */
WORD_START(_does_,     _defer_uninitialized_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        /*                               ( RTOP contains return IP i.e. caller's IP )
         * r@ token+                                   ( IP of code following does> )
         *
         * latest dup 0=                               ( IP nt t|f                  )
         *    M6ERR_ZERO_LENGTH_NAME and throw         ( IP nt                      )
         * dup name>flags                              ( IP nt flags                )
         * M6FLAG_CREATE and 0=                        ( IP nt t|f                  )
         *    M6ERR_NOT_CREATED and throw              ( IP nt                      )
         * name>xt                                     ( IP xt                      )
         *
         *          ( xt of CREATEd words contains 'ip>data>addr (call) XT exit' )
         * token+ token+                               ( IP xt-addr                 )
         * !                                           (                            )
         */
        r_fetch, token_plus,
        latest, dup, zero_equal,
            _lit_, T(M6ERR_ZERO_LENGTH_NAME), and, throw,
        dup, name_to_flags,
        _lit_, T(M6FLAG_CREATE), and, zero_equal,
            _lit_, T(M6ERR_NOT_CREATED), and, throw,
        name_to_xt,
        token_plus, token_plus,
        store,
        exit
    )
WORD_END(_does_)
/* alias of exit. used immediately after (does) */
WORD_START(_does_exit_, _does_)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(1,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE_ALWAYS | M6FLAG_JUMP)
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(_does_exit_, exit)
WORD_END(_does_exit_)
WORD_START(_endof_,    _does_exit_)
    WORD_DSTACK(2,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        CALL(endof), exit
    )
WORD_END(_endof_)
/* ( sys -- xt| ) finish compiling a word, make it findable. */
/* return xt if word is created with :noname */
WORD_START(_finish_, _endof_)
    WORD_DSTACK(2,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        _check_lit_tok_, colon,                        /* ( colon-sys          ) */
        CALL(exit), /* compile 'exit' */               /* ( colon-sys          ) */
        drop, dup, _lit_, T(M6FLAG_OPT_MASK), and,     /* ( m6flags flag       ) */
        _lit_, T(M6FLAG_NOASM), two_dup, less,         /* ( m6flags flag noasm t|f ) */
        minus_rot, less_equal,                         /* ( m6flags <noasm <=noasm ) */
        _if_, T(7+2*nCALLt),                           /* ( m6flags <noasm     ) */
        /* optimize only if (nt.flags & M6FLAG_OPT_MASK) <= M6FLAG_NOASM         */
            CALL(_optimize_),                          /* ( m6flags <noasm     ) */
            _if_, T(2+nCALLt),                         /* ( m6flags            ) */
            /* compile to ASM only if (nt.flags & M6FLAG_OPT_MASK) < M6FLAG_NOASM*/
                CALL(xt_to_asm_comma),                 /* ( m6flags            ) */
            then,                                      /* ( m6flags            ) */
        _else_, T(2),                                  /* ( m6flags <noasm     ) */
            drop,                                      /* ( m6flags            ) */
        then,                                          /* ( m6flags            ) */
        CALL(_user_locals_clear_),                     /* ( m6flags            ) */
        left_bracket,        /* stop compiling, set state[0] = XT = 0 */
        align,               /* align HERE to current word's data  */
        latest, get_current, wordlist_add,             /* ( m6flags            ) */
        _lit4s_, INT(M6FLAG_NONAME), and,              /* ( flag               ) */
        _if_, T(3),                                    /* (                    ) */
            latest, name_to_xt,                        /* ( xt                 ) */
        then, exit
    )
WORD_END(_finish_)
/* ( nt -- ) inline a call to word into XT being compiled */
WORD_START(_inline_, _finish_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY) /* multiple exits => cannot inline */
    WORD_CODE(
        dup, name_to_flags,                            /* ( nt m6flags         ) */
        _lit_, T(M6FLAG_OPT_MASK), and,                /* ( nt flag            ) */
        dup, _lit_, T(M6FLAG_VALUE), equal,            /* ( nt flag t|f        ) */
        _if_, T(4+nCALLt),                             /* ( nt flag            ) */
            drop, CALL(_inline_value_), exit,          /* (                    ) */
        then,                                          /* ( nt flag            ) */
        _lit_, T(M6FLAG_VAR), equal,                   /* ( nt t|f             ) */
        _if_, T(3+nCALLt),                             /* ( nt                 ) */
            CALL(_inline_var_), exit,                  /* (                    ) */
        then,                                          /* ( nt                 ) */

        /* also skip 'exit' at the end of XT */
        dup,  name_to_code, one_minus,                 /* ( nt code n-1        ) */
        dup, zero, less_equal, _if_, T(4),             /* ( nt code n-1        ) */
            nip, two_drop, exit,/* inline length is <= 0  (                    ) */
        then,                                          /* ( nt code u          ) */
        rot, name_to_flags,                            /* ( code u m6flags     ) */
        _lit_, T(M6FLAG_ASM), and,                     /* ( code u flag        ) */
        _if_, T(18),                                   /* ( code u             ) */
            /* word contains '(call-asm) CELL(address) exit ...tokens... exit'   */
            /* if tokens len > 5 then inline '(call-asm) CELL(address)'          */
            /* otherwise inline '...tokens...'                                   */
            dup, _lit_, T(nCALLt+7), more,             /* ( code u t|f         ) */
            _if_, T(5),                                /* ( code u             ) */
                /* keep only '(call-asm) CELL(address)'                          */
                drop, _lit_, T(nCALLt+1),              /* ( code u'            ) */
            _else_, T(6),                              /* ( code u             ) */
                /* keep only '...tokens...'                                      */
                tokens, _lit_, T(SZ+2*SZt),            /* ( code nbytes nskip  ) */
                div_string, div_token,                 /* ( code' u'           ) */
            then,                                      /* ( code u             ) */
        then,                                          /* ( code u             ) */
        zero, do,                                      /* ( code       ) ( R: u pos ) */
            dup, token_fetch,                          /* ( code token ) ( R: u pos ) */
            token_comma,                               /* ( code       ) ( R: u pos ) */
            token_plus,                                /* ( code'      ) ( R: u pos ) */
        _loop_, T(-6), drop, exit                      /* (            )         */
    )
WORD_END(_inline_)
/* ( nt -- ) inline a VALUE into XT being compiled */
WORD_START(_inline_value_,     _inline_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY|M6FLAG_INLINE)
    WORD_CODE(
        _lit_comma_, _lit_nt_body_, comma,  /* compile '(lit-nt>body)' nt     */
        _lit_comma_, fetch,                    /* compile '@'                    */
        exit
    )
WORD_END(_inline_value_)
/* ( nt -- ) inline a VARIABLE into XT being compiled */
WORD_START(_inline_var_,     _inline_value_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY|M6FLAG_INLINE)
    WORD_CODE(
        _lit_comma_, _lit_nt_body_, comma,  /* compile '(lit-nt>body)' nt     */
        exit
    )
WORD_END(_inline_var_)
/**
 * [latest-optimize] ( -- ) try to optimize latest word.
 * called when defining the following word: latest can no longer be modified with 'does>'
 */
WORD_START(_latest_optimize_,  _inline_var_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        latest, question_dup,                  /* ( nt nt | 0                  ) */
        _if0_, T(2),                           /* (                            ) */
            exit,                              /* (                            ) */
        then,                                  /* ( nt                         ) */
        dup, name_to_flags,                    /* ( nt m6flags                 ) */
        _lit_, T(M6FLAG_OPT_MASK), and,        /* ( nt flags                   ) */
        _lit_, T(M6FLAG_CREATE), equal,        /* ( nt t|f                     ) */
        _if0_, T(3),                           /* ( nt                         ) */
            /* not defined with CREATE */
            drop, exit,                        /* (                            ) */
        then,                                  /* ( nt                         ) */
        dup, name_to_xt,                       /* ( nt xt                      ) */
        dup, token_fetch_1,                    /* ( nt xt tok                  ) */
        _lit_tok_, _call_, equal,              /* ( nt xt t|f                  ) */
        _if0_, T(3),                           /* ( nt xt                      ) */
            /* _call_ not found    */
            two_drop, exit,                    /* (                            ) */
        then,                                  /* ( nt xt                      ) */
        token_plus, token_plus, fetch,         /* ( nt call_arg                ) */
        _lit_xt_, XT(noop), equal,             /* ( nt t|f                     ) */
        _if0_, T(3),                           /* ( nt                         ) */
            /* XT(noop) not found  */
            drop, exit,                        /* (                            ) */
        then,                                  /* ( nt                         ) */
        dup, name_to_xt, token_plus,           /* ( nt &_call_                 ) */
        /* remove CALL(noop)       */
        _lit_tok_, exit, over, token_store,    /* ( nt &_call_                 ) */
        token_plus, _lit_tok_, _missing_, swap,/* ( nt tok &XT(noop)           ) */
        one_cell, bounds,                      /* ( nt tok end beg             ) */
        do,                                    /* ( nt tok          ) ( R: end pos ) */
            dup, i, token_store,               /* ( nt tok          ) ( R: end pos ) */
            one_token,                         /* ( nt tok +loop    ) ( R: end pos ) */
        _plus_loop_, T(-6),                    /* ( nt tok                     ) */
        drop,                                  /* ( nt                         ) */
        /* we cannot update nt.code_n : it skews name>data>addr computation      */

        /* update m6flags          */
        dup, name_to_flags,                    /* ( nt m6flags                 ) */
        _lit_, T(M6FLAG_OPT_MASK), invert, and,/* ( nt m6flags'                ) */
        _lit_, T(M6FLAG_INLINE_ALWAYS|M6FLAG_VAR), or, /* ( nt m6flags''       ) */
        swap, name_to_flags_store, exit        /* (                            ) */
    )
WORD_END(_latest_optimize_)
WORD_START(_of_,               _latest_optimize_)
    WORD_DSTACK(2,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_CONSUMES_IP_SZt | M6FLAG_INLINE_ALWAYS | M6FLAG_IMMEDIATE | M6FLAG_MAY_JUMP | M6FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        CALL(of), exit
    )
WORD_END(_of_)
/**
 * call [optimize-prio] three times:
 * first for high priority optimizations,
 * then for medium priority optimizations,
 * finally for low priority optimizations. updates HERE.
 * ( -- )
 */
WORD_START(_optimize_, _of_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        _lit_, T(M6OPTS_PRIO_HIGH), CALL(_optimize_opts_),
        _lit_, T(M6OPTS_PRIO_MID),  CALL(_optimize_opts_),
        _lit_, T(M6OPTS_PRIO_LOW),  CALL(_optimize_opts_),
        exit
    )
WORD_END(_optimize_)
/* ( opts -- ) call [optimize-once] repeatedly until there is nothing left optimize. */
/* updates HERE. */
WORD_START(_optimize_opts_, _optimize_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        begin,
            dup, CALL(_optimize_once_),
        _until0_, T(-4-nCALLt),
        drop, CALL(_recompile_), exit
    )
WORD_END(_optimize_opts_)
/**
 * optimize exactly HERE-XT tokens starting from XT. optimized tokens
 * are initially written to HERE and up, then copied back to XT and up.
 * updates HERE. return t if something was optimized, else false
 * ( opts -- t|f )
 */
WORD_START(_optimize_once_, _optimize_opts_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(/* generated from file impl.forth - see source and comments there */
        /*23*/ zero, state_fetch, here, dup_to_r,
        sub, two_div, rot, CALL(_optimize_xt_comma_),
        r_from, state_fetch, over,
        here, sub, cmove_count, nip,
        here, minus, allot, exit
    )
WORD_END(_optimize_once_)
/**
 * copy and optimize exactly u tokens from XT+offset to HERE. updates HERE.
 * return true if something was optimized, else false
 * ( offset u opts -- t|f )
 */
WORD_START(_optimize_xt_comma_, _optimize_once_)
    WORD_DSTACK(3,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(/* generated from file impl.forth - see source and comments there */
        /*30*/ zero, two_to_r,
        begin,
        _q_while_, T(17+nCALLt),
            over, two_times, state_fetch, plus, over,
            r2nd_fetch, CALL(_optimize_tokens_comma_),
            r_fetch, or, r_store, tuck, minus, flip, plus, swap,
        _repeat_, T(-19-nCALLt),
        two_drop, r_from, r_from_drop, exit
    )
WORD_END(_optimize_xt_comma_)
/* rebuild XT jump offsets after optimization */
WORD_START(_recompile_, _optimize_xt_comma_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        /* here dup state @ sub allot ( set here = xt )( here            )
         * >r 0 ' colon                                ( sys             ) ( R: here )
         * begin                                       ( ...             ) ( R: here )
         *   here r@ u<                                ( t|f             ) ( R: here )
         * while                                       (                 ) ( R: here )
         *   [recompile-token]                         ( ...             ) ( R: here )
         * repeat                                      (                 ) ( R: here )
         * ' colon (check)                             ( sys             ) ( R: here )
         * cs-drop r> drop                             (                 )
         */
        here, dup, state_fetch, sub, allot,
        to_r, zero, _lit_tok_, colon,
        begin,
            here, r_fetch, u_less,
        _while_, T(3+nCALLt),
            CALL(_recompile_token_),
        _repeat_, T(-8-nCALLt),
        _check_lit_tok_, colon,
        cs_drop, r_from_drop, exit
    )
WORD_END(_recompile_)
/*
 * ( -- ) recompile a single token at 'here' after optimization.
 * update 'here' considering also IP consumed by token
 * as for example jumps, literals, calls.
 */
WORD_START(_recompile_token_, _recompile_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        /* here token@ token>name                      ( nt|0            )
         * dup 0= if                                   ( 0               )
         *   drop 1token allot exit                    (                 )
         * then                                        ( nt              )
         * dup name>flags                              ( nt flags        )
         * M6FLAG_REEXEC_AFTER_OPTIMIZE and            ( nt reexec-flag  )
         * if                                          ( nt              )
         *    name>xt execute exit                     ( ...             )
         * then                                        ( nt              )
         * name>flags flags>consumed-tokens            ( u               )
         * 1+ tokens allot                             (                 )
         */
        here, token_fetch, token_to_name,
        _q_if0_, T(5),
            drop, one_token, allot, exit,
        then,
        dup, name_to_flags,
        _lit_, T(M6FLAG_REEXEC_AFTER_OPTIMIZE), and,
        _if_, T(4),
            name_to_xt, execute, exit,
        then,
        name_to_flags, flags_to_consumed_tokens,
        one_plus, tokens, allot, exit
    )
WORD_END(_recompile_token_)
/**
 * Resolve all jumps in 'begin..again' 'begin..repeat' and 'begin..until'
 * Called by 'again' 'repeat' and 'until'
 */
WORD_START(_resolve_begin_repeat_, _recompile_token_)
    WORD_DSTACK(-1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        exit /* TODO */
    )
WORD_END(_resolve_begin_repeat_)
/**
 * Resolve the most recent unresolved jump, setting its destination to 'here'.
 * Called by 'else' and 'then' to resolve the jump offset of a preceding 'if' or 'else'.
 * Called by '[resolve-loop]' to resolve the jump offset of a preceding 'leave' or '?do'
 * ( jump_location jump_category -- )
 */
WORD_START(_resolve_jump_here_, _resolve_begin_repeat_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(                          /* ( #tokens jump_category ) */
        drop, dup, _num_compiled_, sub, /* ( #tokens IP-offset )     */
        swap, one_minus, tokens,        /* ( IP-offset toffset ) toffset of token after (if) or (else) */
        latest, name_to_xt, plus,       /* ( IP-offset taddr   ) taddr   of token after (if) or (else) */
        token_store, exit
    )
WORD_END(_resolve_jump_here_)
/**
 * Resolve a jump from orig to dest. Called by 'again' and '[resolve-loop]'
 * ( dest orig -- )
 */
WORD_START(_resolve_jump_there_, _resolve_jump_here_)
    WORD_DSTACK(4,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        drop, nip,                        /* ( dest_location orig_location ) */
        tuck, minus, swap,                /* ( distance orig_location      ) */
        one_minus, tokens, state_fetch,   /* ( distance orig_location-1 xt ) */
        plus,                             /* ( distance addr ) addr of orig-1 */
        token_store, exit
    )
WORD_END(_resolve_jump_there_)
/**
 * called by 'loop': resolve the jump offsets of a single 'do' or '?do',
 * zero or more 'leave' and one 'loop' or '+loop'
 * ( do-sys leave-sys* loop-sys -- )
 */
WORD_START(_resolve_loop_, _resolve_jump_there_)
    WORD_DSTACK(-1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        /* ' (loop) check cs>r                         ( do-sys leave-sys*     ) ( R: loop-sys )
         * begin                                       ( do-sys leave-sys*     ) ( R: loop-sys )
         *    dup ' (leave) =                          ( do-sys leave-sys* t|f ) ( R: loop-sys )
         * while                                       ( do-sys leave-sys+     ) ( R: loop-sys )
         *    [resolve-jump-here]                      ( do-sys leave-sys*     ) ( R: loop-sys )
         * repeat                                      ( do-sys                ) ( R: loop-sys )
         * ' (do) check                                ( do-sys                ) ( R: loop-sys )
         * cs-dup [resolve-jump-here]                  ( do-sys                ) ( R: loop-sys )
         * csr>                                        ( do-sys loop-sys       )
         * [resolve-jump-there]                        (                       )
         */
        _check_lit_tok_, _loop_,
        cs_to_r,
        begin,
            dup, _lit_, _leave_, equal,
        _while_, T(3+nCALLt),
            CALL(_resolve_jump_here_),
        _repeat_, T(-9-nCALLt),
        _check_lit_tok_, _do_,
        cs_dup, CALL(_resolve_jump_here_),
        cs_r_from, CALL(_resolve_jump_there_), exit
    )
WORD_END(_resolve_loop_)
/* (skip-until:}) ( -- ) parse words and skip them until :} is found */
WORD_START(_skip_until_colon_brace_, _resolve_loop_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(/* generated from file impl.forth - see source and comments there */
        /*25*/
        zero, zero,
        begin,
            two_drop, in_to_ibuf, CALL(ibuf_find_nonblanks),
        _q_while_, T(5+nSTRt(2)+nCALLt),
            LIT_STRING(2, ":}"), CALL(string2_equal),
        _until_, T(-9-nSTRt(2)-2*nCALLt),
        then,
        two_drop, exit
    )
WORD_END(_skip_until_colon_brace_)
/* ( xt -- ) always throws M6ERR_INTERPRETING_COMPILE_ONLY_WORD */
WORD_START(_throw_compile_only_xt_, _skip_until_colon_brace_)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(1,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_JUMP)
    WORD_CODE(
        /* xt>name name>string ex-message!
         * M6ERR_INTERPRETING_COMPILE_ONLY_WORD throw
         */
        xt_to_name, name_to_string, ex_message_store,
        _lit_, T(M6ERR_INTERPRETING_COMPILE_ONLY_WORD), throw,
        exit
    )
WORD_END(_throw_compile_only_xt_)
/* ( -- ) throws M6ERR_INTERPRETING_COMPILE_ONLY_WORD if not in compile mode */
WORD_START(_throw_if_not_compiling_, _throw_compile_only_xt_)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(0,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MAY_JUMP)
    WORD_CODE(
        /* state @ 0=
         * M6ERR_INTERPRETING_COMPILE_ONLY_WORD and throw
         */
        state_fetch, zero_equal,
        _lit_, T(M6ERR_INTERPRETING_COMPILE_ONLY_WORD), and, throw,
        exit
    )
WORD_END(_throw_if_not_compiling_)
/* ( src tok -- ) compile consumed IP at src after a token 'if' 'else' 'while' etc. */
WORD_START(_token_consumed_ip_comma_,  _throw_if_not_compiling_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(/* generated from file impl.forth - see source and comments there */
        /*20*/ token_to_name,
        _q_if0_, T(3),
            nip, exit,
        then,
        name_to_flags, flags_to_consumed_tokens, tuck, zero,
        _q_do_, T(6),
            dup, token_fetch, token_comma, token_plus,
        _loop_, T(-6),
        drop, exit
    )
WORD_END(_token_consumed_ip_comma_)
/* ( -- ls ) allocate m64th->locals data structure if not present */
WORD_START(_user_locals_allocate_,     _token_consumed_ip_comma_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY)
    WORD_CODE(
        user_var, T(M64TH_USER_VAR_LOCALS), dup, fetch, /* ( &ls ls|0                        ) */
        _q_if_, T(3),                                  /* ( &ls ls                          ) */
            nip, exit,                                 /* ( ls                              ) */
        then,                                          /* ( &ls 0                           ) */
        drop,                                          /* ( &ls                             ) */
        CALL(_locals_allocate_),                       /* ( &ls ls                          ) */
        tuck, swap,                                    /* ( ls ls &ls                       ) */
        store, exit              /* set m64th.locals */ /* ( ls                              ) */
    )
WORD_END(_user_locals_allocate_)
/* ( -- )    remove all local variables from m64th->locals */
WORD_START(_user_locals_clear_,_user_locals_allocate_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        user_var, T(M64TH_USER_VAR_LOCALS), fetch,
        CALL(_locals_clear_), exit
    )
WORD_END(_user_locals_clear_)
/* ( -- ) set indexes of local variables in m64th->locals */
WORD_START(_user_locals_set_idx_,      _user_locals_clear_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_INLINE)
    WORD_CODE(
        user_var, T(M64TH_USER_VAR_LOCALS), fetch,
        CALL(_locals_set_idx_), exit
    )
WORD_END(_user_locals_set_idx_)
/* ({:found|) ( i j -- ^j i ) update {: internal state to remember that | was found */
WORD_START(_brace_colon_found_pipe_,   _user_locals_set_idx_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(/* generated from file impl.forth - see source and comments there */
        /*11*/ invert, swap, dup, zero_less,
        _if_, T(4),
            _lit2s_, T(M6ERR_CONTROL_STRUCTURE_MISMATCH), throw,
        then, exit
    )
WORD_END(_brace_colon_found_pipe_)
WORD(minus_two,_brace_colon_found_pipe_,DSTACK(0,1),RSTACK(0,0), WORD_PURE)
WORD(minus_one,        minus_two,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(zero,             minus_one,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(one,              zero,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two,              one,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(three,            two,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four,             three,          DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(five,             four,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(six,              five,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(seven,            six,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(eight,            seven,          DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(sixteen,          eight,          DSTACK(0,1), RSTACK(0,0), WORD_PURE)
/* ( ch -- n )  convert '#' to 10, '$' to 16, '%' to 2, else 0 */
WORD_START(char_to_base, sixteen)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_PURE) /* multiple exits & uses (ip) to access its body => cannot inline */
    WORD_CODE_AND_DATA(
      char_to_base,
      WORD_CODE_TOKENS(
        /* (ip>data>addr) swap to-char '#' - dup 2 <= if
         *    chars + c@ exit
         * then drop drop 0
         */
        _ip_to_data_addr_, swap, to_char,      /* ( body ch )               */
        _lit_, T('#'), minus, dup, two,      /* ( body ch-'#' ch-'#' 2 )  */
        less_equal, _if_, T(5),                /* ( body ch-'#' )           */
            chars, plus, c_fetch, exit,
        then,                                  /* ( body ch-'#' )           */
        two_drop, zero, exit
      ),
      WORD_DATA_BYTES(10, 16, 2)
    )
WORD_END(char_to_base)
/* ( ch -- n )  convert one digit in base 2..36 from char to unsigned number, else -1 */
WORD_START(char_to_u, char_to_base)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_PURE) /* multiple exits => cannot inline */
    WORD_CODE(
        /* dup '0' ':' within if        \ ':' == '9' + 1
         *   '0' - exit
         * then dup 'A' '[' within if   \ '[' == 'Z' + 1
         *   55 - exit
         * then dup 'a' '{' within if   \ '{' == 'z' + 1
         *   87 - exit
         * then -1
         */
        dup, _lit_, T('0'), _lit_, T('9'+1),  /* ( ch ch '0' '9'+1         ) */
        within, _if_, T(5),                   /* ( ch                      ) */
            _lit_, T('0'), minus, exit,       /* ( ch-'0'                  ) */
        then,
        dup, _lit_, T('A'), _lit_, T('Z'+1),  /* ( ch ch 'A' 'Z'+1         ) */
        within, _if_, T(5),                   /* ( ch                      ) */
            _lit_, T('A'-10), minus, exit,    /* ( ch-'A'+10               ) */
        then,
        dup, _lit_, T('a'), _lit_, T('z'+1),  /* ( ch ch 'a' 'z'+1         ) */
        within, _if_, T(5),                   /* ( ch                      ) */
            _lit_, T('a'-10), minus, exit,    /* ( ch-'a'+10               ) */
        then,
        drop, minus_one, exit                 /* ( -1                      ) */
    )
WORD_END(char_to_u)
/* lp_fetch        ( -- addr-of-locals ) get current local variables address */
WORD(lp_fetch,         char_to_u,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* rp_fetch ( R: x y -- x y ) ( -- &x ) get current return stack address */
WORD(rp_fetch,         lp_fetch,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/*
 * string>base ( caddr n -- caddr' n' base )
 * if string starts with # $ or % consume it and return corresponding base, else return current base
 */
WORD_START(string_to_base, rp_fetch)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_CODE(
        /* ?if                             ( caddr n       )
         *    over c@ char>base            ( caddr n base  )
         *    ?if                          ( caddr n base  )
         *       >r                        ( caddr n       ) ( R: base )
         *       1- swap char+ swap        ( caddr' n'     ) ( R: base )
         *       r> exit                   ( caddr n' base )
         *    then
         *    drop                         ( caddr n       )
         * then
         * base @ exit                     ( caddr n base  )
         */
        _q_if_, T(15+nCALLt),
           over, c_fetch, CALL(char_to_base),
           _q_if_, T(8),
              to_r,
              one_minus, swap, char_plus, swap,
              r_from, exit,
           then,
           drop,
        then,
        base, fetch, exit
    )
WORD_END(string_to_base)
/* ( caddr n -- caddr' n' ch )  convert three-character string "'x'" to char 'x' for any x, else -1 */
WORD_START(string_to_char, string_to_base)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_CODE(
        /* dup 3 =                         ( caddr   n   t|f     )
         * if                              ( caddr   n           )
         *    drop dup c@ ''' =            ( caddr   t|f         )
         *    if                           ( caddr               )
         *       2+ dup c@ ''' =           ( caddr+2  t|f  )
         *       if                        ( caddr+2             )
         *          1+ dup 2- c@           ( caddr+3 ch          )
         *          0 swap exit            ( caddr+3 n-3 ch      )
         *       then                      ( caddr+2             )
         *       2-                        ( caddr               )
         *    then                         ( caddr               )
         *    3                            ( caddr   n           )
         * then                            ( caddr   n           )
         * -1 ;                            ( caddr   n   -1      )
         */
        dup, three, equal,
        _if_, T(28),
            drop, dup, c_fetch, _lit_, T('\''), equal,
            _if_, T(18),
                two_plus, dup, c_fetch, _lit_, T('\''), equal,
                _if_, T(8),
                    one_plus, dup, two_minus, c_fetch,
                    zero, swap, exit,
                then,
                two_minus,
            then,
            three,
        then,
        minus_one, exit
    )
WORD_END(string_to_char)
/**
 * string&base>u ( caddr n base -- caddr' n' u )
 * convert string from base to unsigned number
 */
WORD_START(string_base_to_u, string_to_char)
    WORD_DSTACK(3,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_CODE(
        /* over if0                            ( caddr n base      )
         *    drop 0 exit                      ( caddr n 0         )
         * then
         * >r 0 -rot 0                         ( u caddr n 0       ) ( R: base     )
         * do                                  ( u caddr           ) ( R: base n 0 )
         *    dup c@ char>u dup 0 j within     ( u caddr digit t|f ) ( R: base n i )
         *    if0                              ( u caddr digit     ) ( R: base n i )
         *       drop swap                     ( caddr u           ) ( R: base n i )
         *       i' i - unloop r> drop         ( caddr u n'        )
         *       swap exit                     ( caddr n u         )
         *    then                             ( u caddr digit     ) ( R: base n i )
         *    rot j * +                        ( caddr u'          ) ( R: base n i )
         *    swap char+                       ( u caddr'          ) ( R: base n i )
         * loop
         * swap 0 swap                         ( caddr 0 u         ) ( R: base     )
         * r> drop ;                           ( caddr 0 u         )
         */
        over, _if0_, T(4),
            drop, zero, exit,
        then,
        to_r, zero, minus_rot, zero,
        do,
            dup, c_fetch, CALL(char_to_u), dup, zero, j/*NON-PORTABLE*/, within,
            _if0_, T(10),
                drop, swap,
                i_prime, i, minus, unloop, r_from_drop,
                swap, exit,
            then,
            rot, j/*NON-PORTABLE*/, times, plus,
            swap, char_plus,
        _loop_, T(-27-nCALLt),
        swap, zero, swap,
        r_from_drop, exit
    )
WORD_END(string_base_to_u)
/**
 * string>sign ( caddr n -- caddr' n' sign ) parse '-' prefix and return -1, else return 1
 */
WORD_START(string_to_sign, string_base_to_u)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_CODE(
       /* ?if0                                ( caddr n           )
        *    one exit                         ( caddr n 1         )
        * then
        * over c@ '-' <>                      ( caddr n t|f       )
        * if
        *    one exit                         ( caddr n 1         )
        * then
        * 1- swap char+ swap                  ( caddr' n'         )
        * -1 ;                                ( caddr n -1        )
        */
        _q_if0_, T(3),
            one, exit,
        then,
        over, c_fetch, _lit_, T('-'), ne,
        _if_, T(3),
            one, exit,
        then,
        one_minus, swap, char_plus, swap,
        minus_one, exit
    )
WORD_END(string_to_sign)
/* ( u -- ch )  convert unsigned number to char in current base */
WORD_START(u_to_char, string_to_sign)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_PURE) /* multiple exits => cannot inline */
    WORD_CODE(
        /* dup 10 u< if
         *   '0' + exit
         * then dup 36 u< if
         *   ('a'-10) + exit
         * then '?'
         */
        dup, _lit_, T(10), u_less,               /* ( u t|f                  ) */
        _if_, T(5),                            /* ( u                      ) */
            _lit_, T('0'), plus, exit,         /* ( u+'0'                  ) */
        then,                                  /* ( u                      ) */
        dup, _lit_, T(36), u_less,               /* ( u t|f                  ) */
        _if_, T(5),                            /* ( u                      ) */
            _lit_, T('a'-10), plus, exit,      /* ( u+'a'-10               ) */
        then,
        drop, _lit_, T('?'), exit              /* ( '?'                    ) */
    )
WORD_END(u_to_char)

#undef LASTWORD
#define LASTWORD u_to_char
