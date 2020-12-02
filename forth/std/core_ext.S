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
#include "../../include/std/dict.mh"

/* clang-format off */

DICT_WORDS_FORTH_CORE_EXT(WORDNAME)

WORD(zero_ne,          LASTWORD,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_more,        zero_ne,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_to_r,         zero_more,  DSTACK(2,0), RSTACK(0,2), WORD_R_PURE)
WORD(two_r_fetch,      two_to_r,   DSTACK(0,2), RSTACK(2,2), WORD_R_PURE)
WORD(two_r_from,       two_r_fetch,DSTACK(0,2), RSTACK(2,0), WORD_R_PURE)
WORD(ne,               two_r_from, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(question_do, ne)
    WORD_DSTACK(2,0)   /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0)   /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _q_do_, _do_, exit)
WORD_END(question_do)
WORD_START(again,      question_do)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, begin,         /* ( sys ) must be 'begin' */
        _compile_jump_lit_, _again_, _again_,
        cs_drop,                    /* we only need the compiled '(again)', not the cs data */
        CALL(_resolve_jump_there_), /* resolve jump offset from '(again)' to 'begin'        */
        exit
    )
WORD_END(again)
WORD_START(action_of, again)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        state, fetch,
        _if_, T(7+2*nCALLt),                     /* compiling          */
            CALL(bracket_tick),                  /* execute [']        */
            _lit_comma_, _call_,
            _lit_xt_, XT(defer_fetch), xt_comma, /* compile 'defer@'   */
        _else_, T(3+2*nCALLt),
            CALL(tick),                          /* ( xt             ) */
            CALL(defer_fetch),                   /* ( xt'            ) */
        then, exit
   )
WORD_END(action_of)
WORD_START(buffer_colon,       action_of)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        CALL(create), allot, exit
    )
WORD_END(buffer_colon)
WORD_START(case,               buffer_colon)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE | M4FLAG_INLINE_ALWAYS | M4FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _compile_sys_lit_, case, case, exit            /* ( case-sys            ) */
    )
WORD_END(case)
WORD_START(compile_comma, case)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY) /* multiple exits => cannot inline */
    WORD_CODE(
        /* dup xt>name name-inline?                    ( xt t|f        )
         * if0                                         ( xt            )
         *    ' (call) token,                          ( xt            )
         *    xt, exit                                 (               )
         * then                                        ( xt            )
         * xt>name [inline]
         */
        dup, xt_to_name, CALL(name_inline_query),
        _if0_, T(5),
            _lit_comma_, _call_,               /* compile (call) */
            xt_comma, exit,                    /* compile XT        */
        then,
        xt_to_name, CALL(_inline_), exit
   )
WORD_END(compile_comma)
WORD_START(defer, compile_comma)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        _lit_, T(M4FLAG_DEFER),
        CALL(_create_),        /* create word, mark it M4FLAG_DEFER ( sys                 ) */
        right_bracket,         /* start compiling                   ( sys                 ) */
        _lit_comma_, _call_,   /* compile '(call)                   ( sys                 ) */
        _lit_xt_, XT(_defer_uninitialized_),                     /* ( sys xt              ) */
        xt_comma,             /* compile '(defer-uninitialized)'    ( sys                 ) */
        CALL(_finish_), exit                                     /* (                     ) */
   )
WORD_END(defer)
WORD_START(defer_store, defer)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        swap, xt_to_validate, swap,                              /* ( xt2 xt1             ) */
        CALL(defer_to_validate),                                 /* ( xt2 xt1             ) */
        token_plus,                                              /* ( xt2 xt1+SZt         ) */
        store, exit                                              /* (                     ) */
   )
WORD_END(defer_store)
WORD_START(defer_fetch, defer_store)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        CALL(defer_to_validate),                                 /* ( xt                  ) */
        token_plus,                                              /* ( xt+SZt              ) */
        fetch, dup,                                              /* ( xt1 xt1             ) */
        _lit_xt_, XT(_defer_uninitialized_), ne,                 /* ( xt1 t|f             ) */
        and, exit                                                /* ( xt1|0               ) */
   )
WORD_END(defer_fetch)
WORD_START(endcase,    defer_fetch)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE | M4FLAG_INLINE_ALWAYS | M4FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _lit_comma_, endcase,                          /* compile 'endcase'           */
        dup, _lit_tok_, _fallthrough_, equal,          /* ( case-sys sys* t|f       ) */
        _if_, T(3+nCALLt),                             /* ( case-sys endof-sys* fallthrough-sys ) */
            zero, CALL(_resolve_jump_to_),             /* ( case-sys endof-sys*     ) */
        then,                                          /* ( case-sys endof-sys*     ) */
        begin,                                         /* ( case-sys endof-sys*     ) */
            dup, _lit_tok_, _endof_, equal,            /* ( case-sys endof-sys* t|f ) */
        _while_, T(3+nCALLt),                          /* ( case-sys endof-sys*     ) */
            CALL(_resolve_jump_here_),                 /* ( case-sys endof-sys'     ) */
        _repeat_, T(-9-nCALLt),                        /* ( case-sys                ) */
        _check_lit_tok_, case,                         /* ( case-sys                ) */
        cs_drop, exit                                  /* (                         ) */
    )
WORD_END(endcase)
WORD_START(endof,      endcase)
    WORD_DSTACK(2,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, _of_,                         /* ( of-sys              ) */
        _compile_jump_lit_, _endof_, _endof_,          /* ( of-sys endof-sys    ) */
        cs_swap,                                       /* ( endof-sys of-sys    ) */
        CALL(_resolve_jump_here_),                     /* ( endof-sys           ) */
        exit                                           /* ( endof-sys           ) */
    )
WORD_END(endof)
WORD(false,            endof,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD_START(hex,        false)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit_, T(16), base, store, exit
    )
WORD_END(hex)
WORD_START(holds,      hex)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(holds, exit)
WORD_END(holds)
WORD_START(is,         holds)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        state, fetch,
        _if_, T(7+2*nCALLt),                     /* compiling          */
            CALL(bracket_tick),                  /* execute [']        */
            _lit_comma_, _call_,
            _lit_xt_, XT(defer_store), xt_comma, /* compile 'defer!'   */
        _else_, T(3+2*nCALLt),
            CALL(tick),                          /* ( xt2 xt1        ) */
            CALL(defer_store),                   /* (                ) */
        then, exit
   )
WORD_END(is)
WORD(nip,              is,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(of, nip)
    WORD_DSTACK(2,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        dup, _lit_tok_, _fallthrough_, equal, to_r,    /* ( _                ) (R: t|f ) */
        _compile_jump_lit_, _of_, _of_, r_from,        /* ( _ of-sys t|f     )           */
        _if_, T(3+nCALLt),                             /* ( fallthrough-sys of-sys )     */
            cs_swap, CALL(_resolve_jump_here_),        /* ( of-sys           )           */
        then, exit
    )
WORD_END(of)
/* ( char "ccc<char>" -- c-addr u ) read from current input a string ended by specified char */
WORD_START(parse,      of)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        in_to_ibuf, CALL(ibuf_skip_1blank),         /* (               ) */
        in_to_ibuf, swap, CALL(ibuf_find_char),     /* ( c-addr u      ) */
        exit
    )
WORD_END(parse)
WORD_START(parse_name, parse)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(in_to_ibuf, CALL(ibuf_find_nonblanks), exit)
WORD_END(parse_name)
WORD(pick,             parse_name, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE) /* DSTACK(x+1,x+1) */
WORD_START(roll,       pick)
    WORD_DSTACK(1,0) /* DSTACK(x+1,x)   */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses %rip-relative TOKEN_CALL_NOTHROW, cannot inline in native code */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(roll, exit)
WORD_END(roll)
WORD_START(to,         roll)
    WORD_DSTACK(-1,0)  /* depends on cell size of parsed name */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_IMMEDIATE) /* can also be interpreted */
    WORD_CODE(
        CALL(parse_name), two_dup, CALL(string_to_local),        /* ( c-addr u idx|-1 t|f ) */
        _if_, T(3+nCALLt),                                       /* ( c-addr u idx        ) */
            CALL(_to_lx_comma_), exit,                           /* (                     ) */
        then,                                                    /* ( c-addr u -1         ) */
        drop,                                                    /* ( c-addr u            ) */
        two_dup, CALL(string_to_name), nip,                      /* ( c-addr u nt|0 -1|0|1) */
        _q_if_, T(10),                                           /* ( c-addr u nt -1|1    ) */
            drop, dup, name_to_flags,                            /* ( c-addr u nt m4flags ) */
            _lit_, T(M4FLAG_NOOPT_MASK), and,                    /* ( c-addr u nt mask    ) */
            _lit_, T(M4FLAG_VALUE), equal,                       /* ( c-addr u nt t|f     ) */
        then,                                                    /* ( c-addr u nt|0 t|f   ) */
        _if_, T(5+nCALLt),                                       /* ( c-addr u nt         ) */
            nip, nip,                                            /* ( nt                  ) */
            CALL(_to_value_), exit,                              /* (                     ) */
        then,                                                    /* ( c-addr u 0          ) */
        drop, ex_message_store,                                  /* (                     ) */
        _lit_, T(M4ERR_INVALID_TO_NAME), throw, exit             /* (                     ) */
    )
WORD_END(to)
WORD(true,             to,         DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(tuck,             true,       DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD(u_more,           tuck,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(value,      u_more)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit_, T(M4FLAG_VALUE),
        CALL(_create_),                 /* create word, mark it M4FLAG_VALUE                */
        right_bracket,                  /* start compiling          ( x sys               ) */
        _lit_comma_, _ip_to_data_addr_, /* compile '(ip>data>addr)  ( x sys               ) */
        _lit_comma_, fetch,             /* compile '@'              ( x sys               ) */
        CALL(_finish_),                 /*                          ( x                   ) */
        comma,                          /* store initial value      (                     ) */
        CALL(latest_sync), exit         /* update word.data_n       (                     ) */
    )
WORD_END(value)
/*
 * within ( x lo hi -- flag )   \ true if lo <= x < hi, either signed or unsigned
 * : within over - -rot - u> ;
 */
WORD(within,           value,      DSTACK(3,1), RSTACK(0,0), WORD_PURE)
/* \      ( -- )   read and skip input until end-of-line. does not refill */
WORD_START(backslash,  within)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE|M4FLAG_IMMEDIATE)
    WORD_CODE(
        _lit_, T('\n'), CALL(parse), two_drop, exit
    )
WORD_END(backslash)

#undef LASTWORD
#define LASTWORD backslash
