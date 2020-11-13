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

#include "../dispatch/sz.mh" /* SZ SZt */
#include "../include/asm.mh"
#include "../include/dict.mh"
#include "../include/dict_m4th.mh"
#include "../include/err.mh"
#include "../include/hashmap.mh"
#include "../include/opt2_hash.mh"
#include "../include/opt3_hash.mh"
#include "../include/opt_rules.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-impl -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

WORD_START(_plus_loop_, _plus_loop_)
    WORD_DSTACK(1,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(1,0) /* stack effect when jumping */
    WORD_RSTACK(2,2)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(CALL(plus_loop), exit)
WORD_END(_plus_loop_)
WORD_START(_q_do_, _plus_loop_)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _q_do_, _do_, exit)
WORD_END(_q_do_)
WORD_START(_q_if_, _q_do_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _q_if_, _if_, exit)
WORD_END(_q_if_)
WORD_START(_q_if0_, _q_if_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _q_if0_, _if_, exit)
WORD_END(_q_if0_)
WORD_START(_q_until_, _q_if0_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(exit) /* TODO */
WORD_END(_q_until_)
WORD_START(_q_until0_, _q_until_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(exit) /* TODO */
WORD_END(_q_until0_)
WORD_START(_q_while_, _q_until0_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _q_while_, _while_, exit)
WORD_END(_q_while_)
WORD_START(_q_while0_, _q_while_)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _q_while0_, _while_, exit)
WORD_END(_q_while0_)
/* ( x c-addr u -- ) runtime part of abort" - if x is not zero, stores string as exception message and throws -2 */
WORD_START(_abort_quote_,  _q_while0_)
    WORD_DSTACK(3,0)   /* stack effect if not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,-1)   /* stack effect if jumping */
    WORD_RSTACK(0,-1)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_MAY_JUMP | M4FLAG_INLINE)
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(CALL(again), exit)
WORD_END(_again_)
WORD_START(_break_,        _again_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
       CALL(break), exit
    )
WORD_END(_break_)
WORD_START(_call_native_, _break_)
    WORD_DSTACK(-1,-1) /* stack effect of called code */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()  /* stack effect when calling */
    WORD_NATIVE_NONE() /* (call-native) uses tail-call optimization: cannot inline into native code */
    WORD_FLAGS(M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_call_native_, exit)
WORD_END(_call_native_)
WORD_START(_call_xt_,  _call_native_)
    WORD_DSTACK(-1,-1) /* stack effect of called XT */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0)   /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(_call_xt_, exit)
WORD_END(_call_xt_)
WORD_START(_catch_beg_,  _call_xt_)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(0,3)
    WORD_DSTACK(1,0)   /* stack effect when jumping */
    WORD_RSTACK(0,3)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_CODE(_catch_beg_, exit)
WORD_END(_catch_beg_)
WORD_START(_catch_end_,  _catch_beg_)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(3,0)   /* one cell consumed by word's 'exit' */
    WORD_STACK_NONE()
    WORD_NATIVE_LEN(_catch_end_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_catch_end_, exit)
WORD_END(_catch_end_)
/* ( -- ) throw on stack or return stack underflow */
WORD_START(_check_stacks_, _catch_end_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* depth 0<                                    ( t|f           )
         *    M4ERR_STACK_UNDERFLOW and throw          (               )
         * rdepth 0<                                   ( t|f           )
         *    M4ERR_RETURN_STACK_UNDERFLOW and throw   (               )
         * then
         */
        depth, zero_less,
            _lit_, T(M4ERR_STACK_UNDERFLOW), and, throw,
        rdepth, zero_less,
            _lit_, T(M4ERR_RETURN_STACK_UNDERFLOW), and, throw,
        exit
    )
WORD_END(_check_stacks_)
WORD_START(_continue_, _catch_end_)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
       CALL(continue), exit
    )
WORD_END(_continue_)
/* ( m4flags -- sys ) read non-blanks string, create a new word for it. set LATEST */
WORD_START(_create_, _continue_)
    WORD_DSTACK(1,2)   /* stack effect if not jumping */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        dup, CALL(parse_name),                         /* ( m4flags m4flags c-addr u     ) */
        dup, zero_equal,                               /* ( m4flags m4flags c-addr u t|f ) */
            _lit_, T(M4ERR_ZERO_LENGTH_NAME), and, throw,
        name_comma, dup, set_latest,                   /* ( m4flags m4flags nt           ) */
        name_to_flags_store,                           /* ( m4flags                      ) */
        _lit_tok_, colon, exit                         /* ( colon-sys                    ) */
    )
WORD_END(_create_)
WORD_START(_do_, _create_)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _do_, _do_, exit)
WORD_END(_do_)
WORD_START(_else_, _do_)
    WORD_STACK_NONE()  /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(CALL(else), exit)
WORD_END(_else_)
/* ( nt -1|1 -- ) interpret or compile name. dtop == -1 if name is immediate */
WORD_START(_eval_name_, _else_)
    WORD_DSTACK(-1,-1) /* stack effect when not jumping */
    WORD_RSTACK(-1,-1)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* over name> -rot                              ( xt nt 1|-1               )
         * state @                                      ( xt nt -1|1 compiling|0   )
         * 0= if                   (   interpreting   ) ( xt nt -1|1               )
         *    drop name>flags                           ( xt m4flags               )
         *    M4FLAG_COMPILE_ONLY and                   ( xt flag                  )
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
        state, fetch,
        _if0_, T(12+nCALLt),
            drop, name_to_flags,
            _lit2s_, SHORT(M4FLAG_COMPILE_ONLY), and,
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* state @                                   ( x compiling|0            )
         * if                   (    compiling     ) ( x                        )
         *    postpone literal                       (                          )
         * then                                      ( x | --                   )
         */
        state, fetch,
        _if_, T(2+nCALLt),
            CALL(literal),
        then, exit
    )
WORD_END(_eval_number_)
WORD_START(_exec_token_, _eval_number_)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* (exec-token) uses tail-call optimization: cannot inline into native code */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(_exec_token_, exit)
WORD_END(_exec_token_)
WORD_START(_exec_xt_from_native_, _exec_token_)
    WORD_DSTACK(-1,-1) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)   /* stack effect when jumping */
    WORD_RSTACK(0,1)
    /*
     * (exec-xt-from-native) uses %rip-relative call to m4f_vm_ and has embedded data after ret:
     * cannot inline into native code
     */
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_CODE(_exec_xt_from_native_, exit)
WORD_END(_exec_xt_from_native_)
/* (hashmap-entry@/int) ( vec u -- key val next ) fetch u-th entry in hashmap buckets. */
/* next is -1 for 'no_entry', or -2 for 'no_next_entry' */
WORD_START(_hashmap_entry_fetch_int_, _exec_xt_from_native_)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_CODE(
        _lit_, T(M4HASHMAP_ENTRY_SZ_INT), times, plus,     /* ( vec'         )           */
        dup_to_r,                                          /* ( vec          ) (R: vec ) */
#if M4HASHMAP_ENTRY_OFF_KEY_INT == 8
        int_fetch_2,                                       /* ( key          ) (R: vec ) */
#else
        _lit_, T(M4HASHMAP_ENTRY_OFF_KEY_INT), plus, int_fetch, /* same */
#endif
        r_fetch,                                           /* ( key vec      ) (R: vec ) */
#if M4HASHMAP_ENTRY_OFF_VAL_INT != 0
        _lit_, T(M4HASHMAP_ENTRY_OFF_VAL_INT), plus,
#endif
        fetch, r_from,                                     /* ( key val vec  )           */
#if M4HASHMAP_ENTRY_OFF_NEXT_INT == 12
        int_fetch_3,                                       /* ( key val next )           */
#else
        _lit_, T(M4HASHMAP_ENTRY_OFF_NEXT_INT), plus, int_fetch, /* same */
#endif
#if SZ > 4
        /* if no_entry, next is -1. if no_next_entry, next is -2 */
        /* we must truncate all other values to unsigned 32-bit  */
        dup, minus_two, u_less,                           /* ( key val next t|f        ) */
        _if_, T(2),                                       /* ( key val next            ) */
            to_uint,                                 /* truncate next to unsigned 32-bit */
        then,                                             /* ( key val next            ) */
#endif /* SZ > 4 */
        exit
    )
WORD_END(_hashmap_entry_fetch_int_)
/* (hashmap-index-of/int) ( map key -- pos ) get bucket position for key  */
WORD_START(_hashmap_indexof_int_, _hashmap_entry_fetch_int_)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MEM_FETCH)
    WORD_CODE(
        /* given x = key^hash, return (x ^ (x >> lcap)) & (cap - 1); */
        dup, crc_cell, xor, swap,                      /* ( x=key^hash map              ) */
#if M4HASHMAP_OFF_LCAP_INT == 4
        uint_fetch_1,                                  /* ( x lcap                      ) */
#else
        _lit_, T(M4HASHMAP_OFF_LCAP_INT), plus,        /* ( x &map.lcap                 ) */
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _if_, _if_, exit)
WORD_END(_if_)
WORD_START(_if0_, _if_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _if0_, _if_, exit)
WORD_END(_if0_)
WORD_START(_ip_, _if0_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_ip_, exit)
WORD_END(_ip_)
WORD_START(_ip_to_data_, _ip_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_ip_to_data_, exit)
WORD_END(_ip_to_data_)
WORD_START(_ip_to_data_addr_, _ip_to_data_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_ip_to_data_addr_, exit)
WORD_END(_ip_to_data_addr_)
WORD_START(_leave_, _ip_to_data_addr_)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(CALL(leave), exit)
WORD_END(_leave_)
WORD_START(_lit_comma_, _leave_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_comma_, T(-1), exit)
WORD_END(_lit_comma_)
WORD_START(_lit2s_, _lit_comma_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_2 | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit2s_, SHORT(-1), exit)
WORD_END(_lit2s_)
WORD_START(_lit4s_, _lit2s_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_4 | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit4s_, INT(-1), exit)
WORD_END(_lit4s_)
WORD_START(_lit8s_, _lit4s_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_8 | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit8s_, CELL(-1), exit)
WORD_END(_lit8s_)
WORD_START(_lit_string_, _lit8s_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(LIT_STRING(0, ""), exit)
WORD_END(_lit_string_)
WORD_START(_lit_tok_, _lit_string_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_tok_, noop, exit)
WORD_END(_lit_tok_)
WORD_START(_lit_xt_, _lit_tok_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_lit_xt_, XT(noop), exit)
WORD_END(_lit_xt_)
WORD(_local_0_,    _lit_string_,   DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_1_,    _local_0_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_2_,    _local_1_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_3_,    _local_2_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_4_,    _local_3_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_5_,    _local_4_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_6_,    _local_5_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_7_,    _local_6_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_8_,    _local_7_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_9_,    _local_8_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_a_,    _local_9_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_b_,    _local_a_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_c_,    _local_b_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_d_,    _local_c_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_e_,    _local_d_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_f_,    _local_e_,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_local_n_,    _local_f_,      DSTACK(0,1), RSTACK(0,0), M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
WORD_START(_local_alloc_,_local_n_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_local_alloc_, T(0), exit)
WORD_END(_local_alloc_)
WORD(_local_free_, _local_alloc_, DSTACK(0,0), RSTACK(0,0), M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS)
WORD_START(_loop_, _local_free_)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(2,2)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(CALL(loop), exit)
WORD_END(_loop_)
WORD(_missing_,        _loop_,         DSTACK(0,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_JUMP)
WORD_START(_repeat_, _missing_)
    WORD_STACK_NONE() /* dummy, always jumps       */
    WORD_DSTACK(0,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(CALL(repeat), exit)
WORD_END(_repeat_)
/* ( -- ) if interpreting type " ok\n", otherwise type " compiled\n" */
WORD_START(_repl_type_ack_, _repeat_)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_STACK_NONE() /* stack effect when jumping */
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        state, fetch,
        _if_, T(3+nSTRt(10)),
            LIT_STRING(10, " compiled\n"),
        _else_, T(2+nSTRt(4)),
            LIT_STRING(4, " ok\n"),
        then,
        type, exit
    )
WORD_END(_repl_type_ack_)
WORD_START(_return_to_native_, _repl_type_ack_)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(0,0)  /* stack effect when jumping */
    WORD_RSTACK(1,0)
    WORD_NATIVE_LEN(_return_to_native_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    WORD_CODE(_return_to_native_, exit)
WORD_END(_return_to_native_)
WORD(_to_local_0_,_return_to_native_,DSTACK(1,0),RSTACK(0,0),WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_1_, _to_local_0_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_2_, _to_local_1_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_3_, _to_local_2_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_4_, _to_local_3_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_5_, _to_local_4_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_6_, _to_local_5_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_7_, _to_local_6_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_8_, _to_local_7_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_9_, _to_local_8_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_a_, _to_local_9_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_b_, _to_local_a_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_c_, _to_local_b_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_d_, _to_local_c_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_e_, _to_local_d_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_f_, _to_local_e_,   DSTACK(1,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_to_local_n_, _to_local_f_,   DSTACK(1,0), RSTACK(0,0), M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_CONSUMES_IP_SZt)
WORD_START(_until_, _to_local_n_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(CALL(until), exit)
WORD_END(_until_)
WORD_START(_until0_, _until_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(exit) /* TODO */
WORD_END(_until0_)
WORD_START(_while_, _until_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _while_, _while_, exit)
WORD_END(_while_)
WORD_START(_while0_, _while_)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _while0_, _while_, exit)
WORD_END(_while0_)
/* ( src dst src-end -- src' dst' ) optimize single tokens being compiled  */                  \
WORD_START(_optimize_1_, _while0_)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* >r                                          ( src dst      ) (R: src-end )
         * begin                                       ( src dst      ) (R: src-end )
         *    over r@ <                                ( src dst t|f  ) (R: src-end )
         * while                                       ( src dst      ) (R: src-end )
         *    false (optimize-1token)                  ( src' dst' n  ) (R: src-end )
         *    0< 1token and                            ( src dst SZt|0) (R: src-end )
         *    cmove*                                   ( src' dst'    ) (R: src-end )
         * repeat                                      ( src' dst'    ) (R: src-end )
         * r> drop  ( optimized code is at dst...dst' )
         */
        to_r,
        begin,
            over, r_fetch, less,
        _while_, T(8+nCALLt),
            false, CALL(_optimize_1token_),
            zero_less, one_token, and,
            cmove_star,
        _repeat_, T(-13-nCALLt),
        r_from_drop, exit
    )
WORD_END(_optimize_1_)
/*
 * (optimize-1token) ( src-addr dst-addr direction-flag -- src-addr' dst-addr' n )
 * fetch a single token from src-addr, and store at dst-addr an optimized token sequence
 * equivalent to it.
 *
 * if direction-flag = 0, dst-addr is post-incremented after each stored token,
 * otherwise (if direction-flag <> 0), dst-addr is pre-decremented after each stored token.
 *
 * n is the length of the optimized sequence, in tokens.
 * if no optimized sequence was found, returns n = -1 and does not copy any token,
 * thus src-addr and dst-addr are returned verbatim.
 */
WORD_START(_optimize_1token_, _optimize_1_)
    WORD_DSTACK(3,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_DATA_TOKENS)
    WORD_CODE_AND_DATA(
      _optimize_1token_,
      WORD_CODE_TOKENS(
        /* (ip>data) rot >r 2>r                        ( src dst                 ) (R: dir data u        )
         * over token@                                 ( src dst tok             ) (R: dir data u        )
         * 2r> 1token - bounds                         ( src dst tok data-end data ) (R: dir             )
         * do                                          ( src dst tok             ) (R: dir data-end data )
         *    dup i token+ token@ =                    ( src dst tok t|f         ) (R: dir data-end data )
         *    if                                       ( src dst tok             ) (R: dir data-end data )
         *       drop i token+ token+                  ( src dst opt-toks        ) (R: dir data-end data )
         *       i token@ unloop r> swap >r            ( src dst opt-toks dir    ) (R: u )
         *       if                                    ( src dst opt-toks        ) (R: u )
         *         r@ tokens +                         ( src dst opt-toks'       ) (R: u )
         *         swap r@ tokens                      ( src opt-toks dst u'     ) (R: u )
         *         cmove*                              ( src opt-toks' dst'      ) (R: u )
         *       else                                  ( src dst opt-toks        ) (R: u )
         *         swap r@ tokens                      ( src opt-toks dst u'     ) (R: u )
         *         -cmove*                             ( src opt-toks' dst'      ) (R: u )
         *       then                                  ( src opt-toks' dst'      ) (R: u )
         *       nip                                   ( src dst                 ) (R: u )
         *       swap token+ swap                      ( src' dst                ) (R: u )
         *       r> exit                               ( src' dst u              )
         *    then                                     ( src dst tok             ) (R: dir data-end data )
         *    4 tokens                                 ( src dst tok 4*SZt       ) (R: dir data-end data )
         * +loop                                       ( src dst tok             ) (R: dir               )
         *              \ no optimization available, just return -1
         * drop r> drop -1                             ( src dst -1              )
         */
#if 0 /* do not optimize */
        drop, minus_one, exit,                            /* ( src dst -1          ) */
#endif
        _ip_to_data_, rot, to_r, two_to_r,
        over, token_fetch,
        two_r_from, one_token, minus, bounds,
        do,
            dup, i, token_plus, token_fetch, equal,
            _if_, T(33),
                drop, i, token_plus, token_plus,
                i, token_fetch, unloop, r_from, swap, to_r,
                _if_, T(9),
                    r_fetch, tokens, plus,
                    swap, r_fetch, tokens,
                    minus_cmove_star,
                _else_, T(5),
                    swap, r_fetch, tokens,
                    cmove_star,
                then,
                nip,
                swap, token_plus, swap,
                r_from, exit,
            then,
            four, tokens,
        _plus_loop_, T(-44),
        drop, r_from_drop, minus_one, exit
      ),
      WORD_DATA_TOKENS(
        OPT1_RULES(OPT1_TO_ASM_TOKENS) _missing_
      )
    )
WORD_END(_optimize_1token_)
/* ( src dst src-end -- src' dst' ) optimize tokens pairs being compiled  */                  \
WORD_START(_optimize_2_, _optimize_1token_)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* >r                                          ( src dst      ) (R: src-end )
         * begin                                       ( src dst      ) (R: src-end )
         *    over token+ r@ <                         ( src dst t|f  ) (R: src-end )
         * while                                       ( src dst      ) (R: src-end )
         *    (optimize-2token) drop                   ( src' dst'    ) (R: src-end )
         * repeat                                      ( src dst      ) (R: src-end )
         * over r> sub                                 ( src dst u    )
         * cmove*                                      ( src' dst'    )
         */
        to_r,
        begin,
            over, token_plus, r_fetch, less,
        _while_, T(4+nCALLt),
            CALL(_optimize_2token_), drop,
        _repeat_, T(-10-nCALLt),
        over, r_from, sub,
        cmove_star, exit
    )
WORD_END(_optimize_2_)
/* ( src-addr dst-addr -- src-addr' dst-addr' t|f ) optimize token pairs being compiled */
WORD_START(_optimize_2token_, _optimize_2_)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_DATA_TOKENS)
    WORD_CODE_N_AUTO(_optimize_2token_)
    WORD_DATA_N_AUTO(_optimize_2token_)
    WORD_CODE_START(_optimize_2token_)
      WORD_CODE_TOKENS(
        /* (ip>data>addr) >r                           ( src dst               ) (R: hashmap )
         * over token@ hop token+ token@               ( src dst tok0 tok1     ) (R: hashmap )
         * 8 tokens lshift or                          ( src dst tok0|tok1<<16 ) (R: hashmap )
         * r> swap                                     ( src dst hashmap key  )
         * hashmap-find/int                           ( src dst key' val' t|f )
         * 0= if                                       ( src dst key' val'     )
         *    2drop 1token                             ( src dst SZt           )
         *    cmove* false exit                        ( src' dst' false       )
         * then                                        ( src dst key val       )
         * nip dup 8 tokens rshift swap to-token 0     ( src dst val>>16 len 0 )
         * ?do                                         ( src dst toks          ) (R: len 0    )
         *    tuck to-token                            ( src toks dst toki     ) (R: len i    )
         *    over token!                              ( src toks dst          ) (R: len i    )
         *    token+                                   ( src toks dst'         ) (R: len i    )
         *    swap 8 tokens rshift                     ( src dst toks>>16      ) (R: len i    )
         * loop                                        ( src dst 0             )
         * drop swap token+ token+ swap true           ( src' dst true         )
         */
        _ip_to_data_addr_, to_r,
        over, token_fetch, hop, token_plus, token_fetch,
        eight, tokens, lshift, or,
        r_from, swap,
        CALL(hashmap_find_int),
        _if0_, T(6),
            two_drop, one_token,
            cmove_star, false, exit,
        then,
        nip, dup, eight, tokens, rshift, swap, to_token, zero,
        _q_do_, T(11),
            tuck, to_token,
            over, token_store,
            token_plus,
            swap, eight, tokens, rshift,
        _loop_, T(-11),
        drop, swap, token_plus, token_plus, swap, true, exit
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
/* ( src-addr dst-addr -- src-addr' dst-addr' t|f ) optimize token triplets being compiled */
WORD_START(_optimize_3token_, _optimize_2token_)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_DATA_TOKENS)
    WORD_CODE_N_AUTO(_optimize_3token_)
    WORD_DATA_N_AUTO(_optimize_3token_)
    WORD_CODE_START(_optimize_3token_)
      WORD_CODE_TOKENS(exit)
    WORD_CODE_END(_optimize_3token_)
    WORD_DATA_START(_optimize_3token_)
#define H3_START(size, lcap) WORD_DATA_CELLS(size, lcap, .+ 8)
#define H3_ENTRY(key, val, next) WORD_DATA_CELLS(val, key, next)
      OPT3_HASHMAP(H3_START, H3_ENTRY)
#undef H3_START
#undef H3_ENTRY
    WORD_DATA_END(_optimize_3token_)
WORD_END(_optimize_3token_)
/* ( x -- token t | x f ) try to optimize '[ x ] literal' */
WORD_START(_optimize_literal_, _optimize_3token_)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_DATA_TOKENS) /* multiple exits => cannot inline */
    WORD_CODE_AND_DATA(
      _optimize_literal_,
      WORD_CODE_TOKENS(
        _ip_to_data_, bounds, _do_, T(17),             /* loop on this word's data   */
            dup, i, short_fetch, equal,                /* ( x t|f   ) (R: end addr ) */
            _if_, T(8),                                /* ( x       ) (R: end addr ) */
                drop, i, token_plus, token_fetch,      /* ( token   ) (R: end addr ) */
                true, unloop, exit,                    /* ( token true )             */
            then,                                      /* ( x       ) (R: end addr ) */
            one_token,                                 /* ( x SZt   ) (R: end addr ) */
        _plus_loop_, T(-17),                           /* ( x       )                */
        false, exit                                    /* ( x false )                */
      ),
      WORD_DATA_TOKENS(
        T(-2), minus_two, T(-1), minus_one,
        T(0), zero, T(1), one, T(2), two, T(3), three,
        T(4), four, T(8), eight, T(32), bl
      )
    )
WORD_END(_optimize_literal_)
WORD(_num_compiled_,_optimize_literal_,DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
/* ( x -- x ) followed by e = expected x. throws if x <> e */
WORD_START(_check_lit_tok_, _num_compiled_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* consumes IP and uses IP-relative JUMP(), cannot inline in native code */
    WORD_FLAGS(M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_check_lit_tok_, _missing_,  exit)
WORD_END(_check_lit_tok_)
/*
 * ( token category -- sys )
 * append unresolved jump to XT being compiled i.e. token and T(-1),
 * then push sys to dstack i.e. jump_address (= # of tokens of XT being compiled) and category.
 */
WORD_START(_compile_jump_, _check_lit_tok_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses IP-relative TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(_compile_jump_, exit)
WORD_END(_compile_jump_)
/*
 * ( -- sys ) must be followed by m4token and its category.
 * append unresolved jump to XT being compiled i.e. m4token and T(-1),
 * then push sys to dstack i.e. jump_address (= # of tokens of XT being compiled) and category.
 */
WORD_START(_compile_jump_lit_, _compile_jump_)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* consumes IP and uses IP-relative TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt2 | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_compile_jump_lit_, T(-1), T(-1), exit)
WORD_END(_compile_jump_lit_)
/*
 * ( sys+ -- sys+ cs-depth ) must be followed by category.
 * find category in control stack and return its cs-depth.
 * Stops at colon-sys, throws if not found.
 */
WORD_START(_cs_find_lit_, _compile_jump_lit_)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* consumes IP and uses IP-relative JUMP(), cannot inline in native code */
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_CODE(_cs_find_lit_, T(-1),  exit)
WORD_END(_cs_find_lit_)
/* throw M4ERR_DEFER_UNINITIALIZED */
WORD_START(_defer_uninitialized_, _num_compiled_)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(_lit2s_, SHORT(M4ERR_DEFER_UNINITIALIZED), throw, exit)
WORD_END(_defer_uninitialized_)
/* ( -- ) replace execution semantics of latest word, setting it to code after caller's IP */
WORD_START(_does_, _defer_uninitialized_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY)
    WORD_CODE(
        /*                               ( RTOP contains return IP i.e. caller's IP )
         * r@ token+                                   ( IP of code following does> )
         *
         * latest dup 0=                               ( IP nt t|f                  )
         *    M4ERR_ZERO_LENGTH_NAME and throw         ( IP nt                      )
         * dup name>flags                              ( IP nt flags                )
         * M4FLAG_CREATE and 0=                        ( IP nt t|f                  )
         *    M4ERR_NOT_CREATED and throw              ( IP nt                      )
         * name>xt                                     ( IP xt                      )
         *
         *          ( xt of CREATEd words contains 'ip>data>addr (call-xt) XT exit' )
         * token+ token+                               ( IP xt-addr                 )
         * !                                           (                            )
         */
        r_fetch, token_plus,
        latest, dup, zero_equal,
            _lit_, T(M4ERR_ZERO_LENGTH_NAME), and, throw,
        dup, name_to_flags,
        _lit_, T(M4FLAG_CREATE), and, zero_equal,
            _lit_, T(M4ERR_NOT_CREATED), and, throw,
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(_does_exit_, exit)
WORD_END(_does_exit_)
/* ( sys -- ) finish compiling a word, make it findable */
WORD_START(_finish_, _does_exit_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(
        _check_lit_tok_, colon,
        _lit_comma_, exit, /* compile 'exit' */
        drop, _lit_, T(M4FLAG_NOOPT_MASK), and,
        /* optimize only if (word.flags & M4FLAG_NOOPT_MASK) == 0 */
        _if0_, T(2+nCALLt),
            CALL(_optimize_),
        then,
        left_bracket, align, /* also align HERE to current word's data */
        latest, get_current, wordlist_add_name, exit
    )
WORD_END(_finish_)
WORD_START(_inline_, _finish_)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY) /* multiple exits => cannot inline */
    WORD_CODE(
        name_to_code, one_minus, /* ( code n-1 )  skip 'exit' at the end of XT */
        dup, zero, less_equal, _if_, T(2),
            exit,              /* inline length is <= 0 */
        then,                  /* ( code n-1 )   */
        zero, do,
            dup, token_fetch,  /* ( code token ) */
            token_comma,
            token_plus,        /* ( code++ )     */
        _loop_, T(-6), drop, exit
    )
WORD_END(_inline_)
WORD_START(_optimize_, _inline_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(
        /* state @ here dup                            ( xt here here  )
         *    ( original code is at xt...xt' )
         * (optimize-1)                                ( xt' here'     )
         *    ( optimized code is at here...here'  )
         * nip here state @ rot                        ( here xt here' )
         * (optimize-2)                                ( here' xt'     )
         *    ( optimized code is now at xt...xt'  )
         * nip here                                    ( xt' here     )
         * - allot        \ update HERE, set it to xt' (              )
         * [recompile]
         */
        state, fetch, here, dup,
        CALL(_optimize_1_),
        nip, here, state, fetch, rot,
        CALL(_optimize_2_),
        nip, here,
        minus, allot,
        CALL(_recompile_), exit
    )
WORD_END(_optimize_)
/* rebuild jump offsets after optimization */
WORD_START(_recompile_, _optimize_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(
        /* here dup state @ sub allot ( set here = xt )( here            )
         * >r 0 ' colon                                ( sys             ) (R: here )
         * begin                                       ( ...             ) (R: here )
         *   here r@ <                                 ( t|f             ) (R: here )
         * while                                       (                 ) (R: here )
         *   [recompile-token]                         ( ...             ) (R: here )
         * repeat                                      (                 ) (R: here )
         * ' colon (check)                             ( sys             ) (R: here )
         * cs-drop r> drop                             (                 )
         */
        here, dup, state, fetch, sub, allot,
        to_r, zero, _lit_tok_, colon,
        begin,
            here, r_fetch, less,
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(
        /* here token@ token>name                      ( nt|0            )
         * dup 0= if                                   ( 0               )
         *   drop 1token allot exit                    (                 )
         * then                                        ( nt              )
         * dup name>flags                              ( nt flags        )
         * M4FLAG_IMMEDIATE and                        ( nt immediate    )
         * if                                          ( nt              )
         *    name>xt execute execute exit             ( ...             )
         * then                                        ( nt              )
         * name>flags flags>consumed-tokens            ( u               )
         * 1+ tokens allot                             (                 )
         */
        here, token_fetch, token_to_name,
        _q_if0_, T(5),
            drop, one_token, allot, exit,
        then,
        dup, name_to_flags,
        _lit_, T(M4FLAG_IMMEDIATE), and,
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(
        exit /* TODO */
    )
WORD_END(_resolve_begin_repeat_)
/**
 * Resolve the most recent unresolved jump, setting its destination to 'here'.
 * Called by 'else' and 'then' to resolve the jump offset of a preceding 'if' or 'else'.
 * Called by '[resolve-loop]' to resolve the jump offset of a preceding 'leave' or '?do'
 * ( jump_address jump_category -- )
 */
WORD_START(_resolve_jump_here_, _resolve_begin_repeat_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(                          /* ( #tokens jump_category ) */
        drop, dup, _num_compiled_, sub, /* ( #tokens IP-offset )     */
        swap, one_minus, tokens,        /* ( IP-offset toffset ) toffset of token after (if) or (else) */
        latest, name_to_xt, plus,       /* ( IP-offset taddr   ) taddr   of token after (if) or (else) */
        token_store, exit
    )
WORD_END(_resolve_jump_here_)
/**
 * Resolve a jump from here[-1] to topmost jump-sys on control stack.
 * Called by 'again' and '[resolve-loop]'
 * ( jump_address jump_category -- )
 */
WORD_START(_resolve_jump_there_, _resolve_jump_here_)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(
                                          /* ( #tokens jump_category ) */
        drop, _num_compiled_, minus,      /* ( IP-offset )             */
        here, minus_one, tokens, plus,    /* ( IP-offset taddr ) taddr of here-1 */
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_CODE(
        /* ' (loop) check                              ( do-sys leave-sys* loop-sys )
         * cs-drop                                     ( do-sys leave-sys*          )
         * begin                                       ( do-sys leave-sys*          )
         *    dup ' (leave) =                          ( do-sys leave-sys* t|f      )
         * while                                       ( do-sys leave-sys+          )
         *    [resolve-jump-here]                      ( do-sys leave-sys*          )
         * repeat                                      ( do-sys                     )
         * ' (do) check                                ( do-sys                     )
         * cs-dup [resolve-jump-here]                  ( do-sys                     )
         * [resolve-jump-there]                        (                            )
         */
        _check_lit_tok_, _loop_,
        cs_drop,
        begin,
            dup, _lit_, _leave_, equal,
        _while_, T(3+nCALLt),
            CALL(_resolve_jump_here_),
        _repeat_, T(-9-nCALLt),
        _check_lit_tok_, _do_,
        cs_dup, CALL(_resolve_jump_here_),
        CALL(_resolve_jump_there_), exit
    )
WORD_END(_resolve_loop_)
/* ( xt -- ) always throws M4ERR_INTERPRETING_COMPILE_ONLY_WORD */
WORD_START(_throw_compile_only_xt_, _resolve_loop_)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(1,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_JUMP)
    WORD_CODE(
        /* xt>name name>string ex-message!
         * M4ERR_INTERPRETING_COMPILE_ONLY_WORD throw
         */
        xt_to_name, name_to_string, ex_message_store,
        _lit_, T(M4ERR_INTERPRETING_COMPILE_ONLY_WORD), throw,
        exit
    )
WORD_END(_throw_compile_only_xt_)
/* ( -- ) throws M4ERR_INTERPRETING_COMPILE_ONLY_WORD if not in compile mode */
WORD_START(_throw_if_not_compiling_, _throw_compile_only_xt_)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(0,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_CODE(
        /* state @ 0=
         * M4ERR_INTERPRETING_COMPILE_ONLY_WORD and throw
         */
        state, fetch, zero_equal,
        _lit_, T(M4ERR_INTERPRETING_COMPILE_ONLY_WORD), and, throw,
        exit
    )
WORD_END(_throw_if_not_compiling_)
WORD(minus_two,_throw_compile_only_xt_,DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(minus_one,        minus_two,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(zero,             minus_one,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(one,              zero,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two,              one,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(three,            two,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four,             three,          DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(eight,            four,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
/* ( ch -- n )  convert '#' to 10, '$' to 16, '%' to 2, else 0 */
WORD_START(char_to_base, eight)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_PURE) /* multiple exits & uses (ip) to access its body => cannot inline */
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_PURE) /* multiple exits => cannot inline */
    WORD_CODE(
        /* dup '0' ':' within if        \ ':' == '9' + 1
         *   '0' - exit
         * then dup 'A' '[' within if   \ '[' == 'Z' + 1
         *   55 - exit
         * then dup 'a' '{' within if   \ '{' == 'z' + 1
         *   87 - exit
         * then -1
         */
        dup, _lit_, T('0'), _lit_, T('9'+1), /* ( ch ch '0' '9'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit_, T('0'), minus, exit,        /* ( ch-'0' )                  */
        then,
        dup, _lit_, T('A'), _lit_, T('Z'+1), /* ( ch ch 'A' 'Z'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit_, T('A'-10), minus, exit,     /* ( ch-'A'+10 )               */
        then,
        dup, _lit_, T('a'), _lit_, T('z'+1), /* ( ch ch 'a' 'z'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit_, T('a'-10), minus, exit,     /* ( ch-'a'+10 )               */
        then,
        drop, minus_one, exit                    /* ( -1 )                      */
    )
WORD_END(char_to_u)
/*
 * string>base ( caddr n -- caddr' n' base )
 * if string starts with # $ or % consume it and return corresponding base, else return current base
 */
WORD_START(string_to_base, char_to_u)
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_CODE(
        /* ?if                             ( caddr n       )
         *    over c@ char>base            ( caddr n base  )
         *    ?if                          ( caddr n base  )
         *       >r                        ( caddr n       ) (R: base )
         *       1- swap char+ swap        ( caddr' n'     ) (R: base )
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_CODE(
        /* over if0                            ( caddr n base      )
         *    drop 0 exit                      ( caddr n 0         )
         * then
         * >r 0 -rot 0                         ( u caddr n 0       ) (R: base     )
         * do                                  ( u caddr           ) (R: base n 0 )
         *    dup c@ char>u dup 0 j within     ( u caddr digit t|f ) (R: base n i )
         *    if0                              ( u caddr digit     ) (R: base n i )
         *       drop swap                     ( caddr u           ) (R: base n i )
         *       i' i - unloop r> drop         ( caddr u n'        )
         *       swap exit                     ( caddr n u         )
         *    then                             ( u caddr digit     ) (R: base n i )
         *    rot j * +                        ( caddr u'          ) (R: base n i )
         *    swap char+                       ( u caddr'          ) (R: base n i )
         * loop
         * swap 0 swap                         ( caddr 0 u         ) (R: base     )
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
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
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

#undef LASTWORD
#define LASTWORD string_to_sign
