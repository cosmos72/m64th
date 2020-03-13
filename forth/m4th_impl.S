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

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-impl -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
DICT_START(m4th_impl)

DICTNAME(9, "m4th-impl", m4th_impl)

DICT_WORDS_M4TH_IMPL(WORDNAME)

WORD_START(_q_do_, _q_do_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _q_do_, _q_do_, exit)
WORD_END(_q_do_)
WORD_START(_q_if_, _q_do_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _q_if_, _if_, exit)
WORD_END(_q_if_)
WORD_START(_q_if0_, _q_if_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _q_if0_, _if_, exit)
WORD_END(_q_if0_)
WORD_START(_q_until_, _q_if0_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(exit) /* TODO */
WORD_END(_q_until_)
WORD_START(_q_until0_, _q_until_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(exit) /* TODO */
WORD_END(_q_until0_)
WORD_START(_q_while_, _q_until0_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _q_while_, _while_, exit)
WORD_END(_q_while_)
WORD_START(_q_while0_, _q_while_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,1) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _q_while0_, _while_, exit)
WORD_END(_q_while0_)
WORD_START(_again_,      _q_while0_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(CALL(again), exit)
WORD_END(_again_)
WORD_START(_break_,    _again_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
       CALL(break), exit
    )
WORD_END(_break_)
WORD_START(_call_,     _break_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0)   /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_NATIVE_NONE()
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(_call_, exit)
WORD_END(_call_)
WORD_START(_call_xt_,  _call_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZ | M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(-1,-1) /* stack effect of called XT */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0)   /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_NATIVE_NONE()
    /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(_call_xt_, exit)
WORD_END(_call_xt_)
WORD_START(_catch_beg_,  _call_xt_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS | M4FLAG_MAY_JUMP)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(0,2)   /* one cell consumed by word's 'exit' */
    WORD_DSTACK(1,0)   /* stack effect when jumping */
    WORD_RSTACK(0,3)
    WORD_NATIVE_NONE()
    WORD_CODE(_catch_beg_, exit)
WORD_END(_catch_beg_)
WORD_START(_catch_end_,  _catch_beg_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(-1,-1) /* stack effect of called word */
    WORD_RSTACK(2,0)   /* one cell consumed by word's 'exit' */
    WORD_STACK_NONE()
    WORD_NATIVE_LEN(_catch_end_)
    WORD_CODE(_catch_end_, exit)
WORD_END(_catch_end_)
/* ( -- ) throw on stack or return stack underflow */
WORD_START(_check_stacks_, _catch_end_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* depth 0< if                                 (               )
         *    M4ERR_STACK_UNDERFLOW throw              (               )
         * then
         * rdepth 0< if                                (               )
         *    M4ERR_RETURN_STACK_UNDERFLOW throw       (               )
         * then
         */
        depth, zero_less, _if_, T(4),
            _lit_, T(M4ERR_STACK_UNDERFLOW), throw,
        then,
        rdepth, zero_less, _if_, T(4),
            _lit_, T(M4ERR_RETURN_STACK_UNDERFLOW), throw,
        then, exit
    )
WORD_END(_check_stacks_)
WORD_START(_continue_, _catch_end_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
       CALL(continue), exit
    )
WORD_END(_continue_)
WORD_START(_else_, _continue_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE()  /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(CALL(else), exit)
WORD_END(_else_)
/* ( nt -1|1 -- ) interpret or compile name. dtop == -1 if name is immediate */
WORD_START(_eval_name_, _else_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1) /* stack effect when not jumping */
    WORD_RSTACK(-1,-1)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
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
        _if0_, T(12+SZ/SZt),
            drop, name_to_flags,
            _lit_, T(M4FLAG_COMPILE_ONLY), and,
            _if_, T(2+SZ/SZt),
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
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(1,0) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* state @                                   ( x compiling|0            )
         * if                   (    compiling     ) ( x                        )
         *    postpone literal                       (                          )
         * then                                      ( x | --                   )
         */
        state, fetch,
        _if_, T(2+SZ/SZt),
            CALL(literal),
        then, exit
    )
WORD_END(_eval_number_)
WORD_START(_exec_native_, _eval_number_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* (exec-native) uses tail-call optimization: cannot inline into native code */
    WORD_CODE(_exec_native_, exit)
WORD_END(_exec_native_)
WORD_START(_exec_token_, _exec_native_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* (exec-token) uses tail-call optimization: cannot inline into native code */
    WORD_CODE(_exec_token_, exit)
WORD_END(_exec_token_)
WORD_START(_exec_xt_from_native_, _exec_token_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_DSTACK(-1,-1) /* stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)   /* stack effect when jumping */
    WORD_RSTACK(0,1)
    /*
     * (exec-xt-from-native) uses %rip-relative call to m4f_vm_ and has embedded data after ret:
     * cannot inline into native code
     */
    WORD_NATIVE_NONE()
    WORD_CODE(_exec_xt_from_native_, exit)
WORD_END(_exec_xt_from_native_)
WORD_START(_if_, _exec_xt_from_native_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _if_, _if_, exit)
WORD_END(_if_)
WORD_START(_if0_, _if_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _if0_, _if_, exit)
WORD_END(_if0_)
WORD_START(_ip_, _if0_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_ip_, exit)
WORD_END(_ip_)
WORD_START(_ip_to_data_, _ip_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_ip_to_data_, exit)
WORD_END(_ip_to_data_)
WORD_START(_ip_to_data_addr_, _ip_to_data_)
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_ip_to_data_addr_, exit)
WORD_END(_ip_to_data_addr_)
WORD_START(_leave_, _ip_to_data_addr_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _leave_, _leave_, exit)
WORD_END(_leave_)
WORD_START(_lit2s_, _leave_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_2 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_lit2s_, SHORT(-1), exit)
WORD_END(_lit2s_)
WORD_START(_lit4s_, _lit2s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_4 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_lit4s_, INT(-1), exit)
WORD_END(_lit4s_)
WORD_START(_lit8s_, _lit4s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_8 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_lit8s_, CELL(-1), exit)
WORD_END(_lit8s_)
WORD_START(_lit_string_, _lit8s_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(LIT_STRING(0, ""), exit)
WORD_END(_lit_string_)
WORD_START(_loop_, _lit_string_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(0,0) /* stack effect when not jumping */
    WORD_RSTACK(2,0)
    WORD_DSTACK(0,0) /* stack effect when jumping */
    WORD_RSTACK(2,2)
    WORD_NATIVE_NONE()
    WORD_CODE(exit) /* TODO */
WORD_END(_loop_)
WORD(_missing_,        _loop_,         DSTACK(0,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_JUMP)
WORD_START(_repeat_, _missing_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_JUMP | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(0,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(/* TODO CALL(repeat), */ exit)
WORD_END(_repeat_)
/* ( -- ) if interpreting type " ok\n", otherwise type " compiled\n" */
WORD_START(_repl_type_ack_, _repeat_)
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_STACK_NONE() /* stack effect when jumping */
    WORD_NATIVE_NONE()
    WORD_CODE(
        state, fetch,
        _if_, T(4+(10+SZt-1)/SZt),
            LIT_STRING(10, " compiled\n"),
        _else_, T(3+(4+SZt-1)/SZt),
            LIT_STRING(4, " ok\n"),
        then,
        type, exit
    )
WORD_END(_repl_type_ack_)
WORD_START(_return_to_native_, _repl_type_ack_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(0,0)  /* stack effect when jumping */
    WORD_RSTACK(1,0)
    WORD_NATIVE_NONE() /* (return-to-native) messes with %rsp to redirect ret: cannot inline into native code */
    WORD_CODE(_return_to_native_, exit)
WORD_END(_return_to_native_)
WORD_START(_until_, _return_to_native_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(exit) /* TODO */
WORD_END(_until_)
WORD_START(_until0_, _until_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(exit) /* TODO */
WORD_END(_until0_)
WORD_START(_while_, _until_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _while_, _while_, exit)
WORD_END(_while_)
WORD_START(_while0_, _while_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0) /* token stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0) /* token stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, _while0_, _while_, exit)
WORD_END(_while0_)
/**
 * test whether executing one of the tokens taddr[0...tn-1] produces the given cell value
 * ( x taddr tn -- token true | x false )
 */
WORD_START(_any_token_gives_cell_q_, _while0_)
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        zero, _q_do_, T(14+SZ/SZt),          /* loop if tn != 0          */
                                             /* ( x taddr )              */
            dup_to_r, token_fetch,           /* ( x token ) (R taddr )   */
            CALL(_token_gives_cell_q_),/* ( token true | x false ) (R taddr ) */
            _if_, T(5),
                r_from_drop, true,           /* ( token true )           */
                unloop, exit,                /* exit                     */
            then,
            r_from, token_plus,              /* ( x taddr )              */
        _loop_, T(-14-SZ/SZt),
        drop, false, exit                    /* ( x false )              */
    )
WORD_END(_any_token_gives_cell_q_)
WORD(_num_compiled_,_any_token_gives_cell_q_,DSTACK(0,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD(_compile_init_,   _num_compiled_, DSTACK(0,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_COMPILE_ONLY)
WORD_START(_compile_lit_, _compile_init_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_lit_, T(-1), exit)
WORD_END(_compile_lit_)
WORD_START(_compile_resolved_jump_, _compile_lit_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt2 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_init_, _compile_resolved_jump_, T(-1), T(-1), exit)
WORD_END(_compile_resolved_jump_)
WORD_START(_compile_unresolved_jump_, _compile_resolved_jump_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt2 | M4FLAG_INLINE_ALWAYS)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* consumes IP and uses IP-relative ASM_CALL(), cannot inline in native code */
    WORD_CODE(_compile_init_, _compile_unresolved_jump_, T(-1), T(-1), exit)
WORD_END(_compile_unresolved_jump_)
WORD_START(_inline_, _compile_unresolved_jump_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY) /* multiple exits => cannot inline */
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        name_to_code, one_minus, /* ( code n-1 )  skip 'exit' at the end of XT */
        dup, zero, less_equal, _if_, T(2),
            exit,              /* inline length is <= 0 */
        then,                  /* ( code n-1 )   */
        _compile_init_,
        zero, do,
            dup, token_fetch,  /* ( code token ) */
            token_comma,
            token_plus,        /* ( code++ )     */
        _loop_, T(-6), drop, exit
    )
WORD_END(_inline_)
WORD_START(_optimize_, _inline_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(exit) /* currently does nothing */
WORD_END(_optimize_)
/**
 * Resolve all jumps in 'begin..again' 'begin..repeat' and 'begin..until'
 * Called by 'again' 'repeat' and 'until'
 */
WORD_START(_resolve_begin_repeat_, _optimize_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(-1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        exit /* TODO */
    )
WORD_END(_resolve_begin_repeat_)
/**
 * Resolve the most recent unresolved jump, setting its destination to 'here'.
 * Called by 'else' and 'then' to resolve the jump offset of a preceding 'if' or 'else'.
 * ( jump_address jump_token -- )
 */
WORD_START(_resolve_jump_here_, _resolve_begin_repeat_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        drop, dup, negate, _num_compiled_, plus, /* ( #tokens IP-offset )    */
        swap, one_minus, tokens,           /* ( IP-offset toffset ) toffset of token after (if) or (else) */
        latest, name_to_xt, plus,          /* ( IP-offset taddr   ) taddr   of token after (if) or (else) */
        token_store, exit
    )
WORD_END(_resolve_jump_here_)
/**
 * called by 'loop': resolve the jump offsets of one 'loop', zero or more 'leave' and one 'do'
 * ( ctrl-loop -- )
 */
WORD_START(_resolve_loop_, _resolve_jump_here_)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE)
    WORD_DSTACK(-1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* TODO */ exit
    )
WORD_END(_resolve_loop_)
/**
 * test whether executing a token produces the given cell value
 * ( x token -- token true | x false )
 */
WORD_START(_token_gives_cell_q_, _resolve_loop_)
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        two_dup,                           /* ( x token x token ) */
        _exec_token_, equal, _if_, T(4),   /* ( x token )         */
            nip, true, exit,               /* ( token true )      */
        then,
        drop, false, exit                  /* ( x false )         */
    )
WORD_END(_token_gives_cell_q_)
/* ( xt -- ) always throws */
WORD_START(_throw_compile_only_xt_, _token_gives_cell_q_)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_JUMP)
    WORD_STACK_NONE() /* stack effect when not jumping */
    WORD_DSTACK(1,0)  /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* xt>name name>string ex-string!
         * M4ERR_INTERPRETING_COMPILE_ONLY_WORD throw
         */
        xt_to_name, name_to_string, ex_string_store,
        _lit_, T(M4ERR_INTERPRETING_COMPILE_ONLY_WORD), throw,
        exit
    )
WORD_END(_throw_compile_only_xt_)
WORD(minus_one,_throw_compile_only_xt_,DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(zero,             minus_one,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(one,              zero,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(two,              one,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(three,            two,            DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(four,             three,          DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(eight,            four,           DSTACK(0,1), RSTACK(0,0), WORD_PURE)
/* ( ch -- n )  convert '#' to 10, '$' to 16, '%' to 2, else 0 */
WORD_START(char_to_base, eight)
    WORD_FLAGS(M4FLAG_PURE) /* multiple exits & uses (ip) to access its body => cannot inline */
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_DATA_AND_CODE(
      char_to_base,
      WORD_DATA_BYTES(10, 16, 2),
      WORD_CODE_TOKENS(
        /* (ip>data>addr) swap to-char '#' - dup 2 <= if
         *    chars + c@ exit
         * then drop drop 0
         */
        _ip_to_data_addr_, swap, to_char,      /* ( body ch )               */
        _lit2s_, T('#'), minus, dup, two,      /* ( body ch-'#' ch-'#' 2 )  */
        less_equal, _if_, T(5),                /* ( body ch-'#' )           */
            chars, plus, c_fetch, exit,
        then,                                  /* ( body ch-'#' )           */
        two_drop, zero, exit
      )
    )
WORD_END(char_to_base)
/* ( ch -- n )  convert one digit in base 2..36 from char to unsigned number, else -1 */
WORD_START(char_to_u, char_to_base)
    WORD_FLAGS(M4FLAG_PURE) /* multiple exits => cannot inline */
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* dup '0' ':' within if        \ ':' == '9' + 1
         *   '0' - exit
         * then dup 'A' '[' within if   \ '[' == 'Z' + 1
         *   55 - exit
         * then dup 'a' '{' within if   \ '{' == 'z' + 1
         *   87 - exit
         * then -1
         */
        dup, _lit2s_, T('0'), _lit2s_, T('9'+1), /* ( ch ch '0' '9'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit2s_, T('0'), minus, exit,        /* ( ch-'0' )                  */
        then,
        dup, _lit2s_, T('A'), _lit2s_, T('Z'+1), /* ( ch ch 'A' 'Z'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit2s_, T('A'-10), minus, exit,     /* ( ch-'A'+10 )               */
        then,
        dup, _lit2s_, T('a'), _lit2s_, T('z'+1), /* ( ch ch 'a' 'z'+1 )         */
        within, _if_, T(5),                      /* ( ch )                      */
            _lit2s_, T('a'-10), minus, exit,     /* ( ch-'a'+10 )               */
        then,
        drop, minus_one, exit                    /* ( -1 )                      */
    )
WORD_END(char_to_u)
/*
 * string>base ( caddr n -- caddr' n' base )
 * if string starts with # $ or % consume it and return corresponding base, else return current base
 */
WORD_START(string_to_base, char_to_u)
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
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
        _q_if_, T(15+SZ/SZt),
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
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
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
            drop, dup, c_fetch, _lit2s_, T('\''), equal,
            _if_, T(18),
                two_plus, dup, c_fetch, _lit2s_, T('\''), equal,
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
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_DSTACK(3,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
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
        _loop_, T(-27-SZ/SZt),
        swap, zero, swap,
        r_from_drop, exit
    )
WORD_END(string_base_to_u)
/**
 * string>sign ( caddr n -- caddr' n' sign ) parse '-' prefix and return -1, else return 1
 */
WORD_START(string_to_sign, string_base_to_u)
    WORD_FLAGS(M4FLAG_MEM_FETCH) /* multiple exits => cannot inline */
    WORD_DSTACK(2,3)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
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

DICT_BODY(m4th_impl, string_to_sign)
DICT_END(m4th_impl)
