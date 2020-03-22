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

#include "../include/asm.mh"
#include "../include/dict.mh"
#include "../include/dict_forth.mh"

/* clang-format off */

DICT_WORDS_FORTH_CORE_EXT(WORDNAME)

WORD(zero_ne,          LASTWORD,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_more,        zero_ne,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_to_r,         zero_more,  DSTACK(2,0), RSTACK(0,2), WORD_R_PURE)
WORD(two_r_fetch,      two_to_r,   DSTACK(0,2), RSTACK(2,2), WORD_R_PURE)
WORD(two_r_from,      two_r_fetch, DSTACK(0,2), RSTACK(2,0), WORD_R_PURE)
WORD(ne,               two_r_from, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(question_do, ne)
    WORD_DSTACK(2,0)   /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0)   /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(_compile_unresolved_jump_, _q_do_, _q_do_, exit)
WORD_END(question_do)
WORD_START(again,      question_do)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_unresolved_jump_, _again_, repeat,
        CALL(_resolve_begin_repeat_), /* resolve all jump offsets of begin.. */
        exit
    )
WORD_END(again)
WORD_START(compile_comma, again)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY) /* multiple exits => cannot inline */
    WORD_CODE(
        /* dup xt>name name-inline?                    ( xt t|f        )
         * if0                                         ( xt            )
         *    ' (call-xt) compile,                     ( xt            )
         *    (compile-xt,) exit                       (               )
         * then                                        ( xt            )
         * xt>name [inline]
         */
        dup, xt_to_name, CALL(name_inline_query),
        _if0_, T(5),
            _compile_lit_, _call_xt_,  /* compile (call-xt) */
            xt_comma, exit,        /* compile XT        */
        then,
        xt_to_name, CALL(_inline_), exit
   )
WORD_END(compile_comma)
WORD(false,        compile_comma,  DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(nip,              false,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(parse_name, nip)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(in_to_ibuf, CALL(ibuf_find_nonblanks), exit)
WORD_END(parse_name)
WORD(pick,             parse_name, DSTACK(1,1), RSTACK(0,0), WORD_PURE) /* DSTACK(x+1,x+1) */
WORD(true,             pick,       DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(tuck,             true,       DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD(u_more,           tuck,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/*
 * within ( x lo hi -- flag )   \ true if lo <= x < hi, either signed or unsigned
 * : within over - -rot - u> ;
 */
WORD(within,           u_more,     DSTACK(3,1), RSTACK(0,0), WORD_PURE)

#undef LASTWORD
#define LASTWORD within
