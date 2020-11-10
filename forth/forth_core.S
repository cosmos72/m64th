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

/* clang-format off */

#include "../include/err.mh" /* M4ERR_STACK_UNDERFLOW */

DICT_WORDS_FORTH_CORE(WORDNAME)

WORD(store,            LASTWORD,   DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD_START(tick,       store)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* parse-xt                                    ( xt -1|1                  )
         * drop dup xt>name name>flags                 ( xt flags                 )
         * M4FLAG_COMPILE_ONLY and                     ( xt flag|0                )
         * if                    ( compile-only word ) ( xt                       )
         *    (throw-compile-only-xt)                  (                          )
         * then                                        ( xt                       )
         */
        CALL(parse_xt),
        drop, dup, xt_to_name, name_to_flags,
        _lit_, T(M4FLAG_COMPILE_ONLY), and,
        _if_, T(2+nCALLt),
            CALL(_throw_compile_only_xt_),
        then,
        exit
    )
WORD_END(tick)
WORD(times,            tick,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus,             times,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus_store,       plus,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD_START(plus_loop, plus_store)
    WORD_DSTACK(-1,-1)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _plus_loop_, _loop_,
        CALL(_resolve_loop_), exit
    )
WORD_END(plus_loop)
WORD(comma,            plus_loop,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD(minus,            comma,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(dot,        minus)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* depth 0<=
         * M4ERR_STACK_UNDERFLOW and throw
         * out>obuf dup obuf-flush drop     ( ensure enough space )  ( n io          )
         * (c-arg-2) (c-call) m4th_dot (c-ret-0)                     (               )
         */
        depth, zero_less_equal,
        _lit_, T(M4ERR_STACK_UNDERFLOW), and, throw,
        out_to_obuf, dup, CALL(obuf_flush), drop,
        _c_arg_2_, _c_call_, CELL(m4th_dot), _c_ret_0_,
        exit
    )
WORD_END(dot)
WORD(div,              dot,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(div_mod,          div,        DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD(zero_less,        div_mod,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_equal,       zero_less,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_plus,         zero_equal, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_minus,        one_plus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_store,        one_minus,  DSTACK(3,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(two_times,        two_store,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_div,          two_times,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_fetch,        two_div,    DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(two_drop,         two_fetch,  DSTACK(2,0), RSTACK(0,0), WORD_PURE)
WORD(two_dup,          two_drop,   DSTACK(2,4), RSTACK(0,0), WORD_PURE)
WORD(two_over,         two_dup,    DSTACK(4,6), RSTACK(0,0), WORD_PURE)
WORD(two_swap,         two_over,   DSTACK(4,4), RSTACK(0,0), WORD_PURE)
WORD_START(colon,      two_swap)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* state @ 0<>                                 ( t|f             )
         *    M4ERR_COMPILER_NESTING and throw         (                 )
         * 0 (create)                               ( colon-sys: 0 colon )
         * postpone ]
         */
        state, fetch, zero_ne,
            _lit_, T(M4ERR_COMPILER_NESTING), and, throw,
#if 1
        /* temporarily disable optimizer, it does not recompute jump offsets */
        _lit_, T(M4FLAG_NOOPT),
#else
        zero,
#endif
        CALL(_create_),
        right_bracket, exit
    )
WORD_END(colon)
WORD_START(semi,       colon)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        /* [throw-if-not-compiling]    ( colon-sys       )
         * [finish]                 ( name is now findable by parse-name )
         */
        CALL(_throw_if_not_compiling_),
        CALL(_finish_), exit
    )
WORD_END(semi)
WORD(less,             semi,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(equal,            less,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(more,             equal,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(to_in,      more)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(in_to_ibuf, iobuf_pos, exit)
WORD_END(to_in)
/*
 * >number ( ud caddr n -- ud caddr n )  \ convert string from base to number
 */
WORD_START(to_number, to_in)
    WORD_DSTACK(4,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* 2swap 2>r base @                    ( caddr n base ) (R: ud )
         * string&base>u                       ( caddr' n' u  ) (R: ud )
         *
         *
         * then
         * rot >r base >r 0
         * do
         *    dup c@ char>u dup 0 j within
         *    if
         *       drop i' i - unloop
         *       r> drop -rot exit
         *    then
         *    rot j * + swap char+
         * loop
         * r> drop r> swap 0
         */
        /* TODO */
        exit
    )
WORD_END(to_number)
WORD(to_r,             to_number,  DSTACK(1,0), RSTACK(0,1), WORD_R_PURE)
WORD(question_dup,     to_r,       DSTACK(1,-1),RSTACK(0,0), WORD_PURE)
WORD_START(cr, question_dup)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(_lit_, T('\n'), emit, exit)
WORD_END(cr)
WORD(fetch,            cr,         DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(abs,              fetch,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(and,              abs,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(align,            and,        DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(aligned,          align,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(allot,            aligned,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD(base,             allot,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD_START(begin, base)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _lit_comma_, begin, _num_compiled_, _lit_tok_, begin, exit
    )
WORD_END(begin)
WORD(bl,               begin,      DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(c_store,          bl,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(c_comma,          c_store,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD(c_fetch,          c_comma,    DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(cell_plus,        c_fetch,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(cells,            cell_plus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(char_plus,        cells,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(chars,            char_plus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(count,            chars,      DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD_START(constant,   count)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        zero, CALL(_create_), right_bracket,   /* create word, start compiling         */
        rot, CALL(literal),                    /* compile number                       */
        CALL(_finish_), exit                   /* finish compiling, make word findable */
    )
WORD_END(constant)
WORD_START(create,     constant)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit2s_, SHORT(M4FLAG_CREATE),
        CALL(_create_),                        /* create word, mark it M4FLAG_CREATE   */
        right_bracket,                         /* start compiling                      */
        _lit_comma_, _ip_to_data_addr_,        /* compile (ip>data>addr)               */
        _lit_comma_, _call_xt_,                /* compile (call-xt)                    */
        _lit_xt_, XT(noop), xt_comma,          /* compile XT(noop). placeholder set by DOES> */
        CALL(_finish_), exit                   /* finish compiling, make word findable */
    )
WORD_END(create)
WORD_START(decimal,    create)
    WORD_DSTACK(0,0)   /* stack effect if not jumping */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit_, T(10), base, store, exit
    )
WORD_END(decimal)
WORD(depth,            decimal,    DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD_START(do, depth)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,2)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _do_, _do_, exit
    )
WORD_END(do)
WORD_START(does,       do)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        /* [throw-if-not-compiling]                    ( colon-sys       )
         * ' : check                   ( check that colon-sys is present )
         * ' (does) compile,           ( compile '(does)'                )
         * ' exit compile,             ( compile 'exit'                  )
         *
         * TODO
         */
        CALL(_throw_if_not_compiling_),
        _check_lit_tok_, colon,
        _lit_comma_, _call_xt_,                        /* compile '(call-xt)'    */
        _lit_xt_, XT(_does_), xt_comma,                /* compile XT of '(does)' */
        _lit_comma_, _does_exit_,                      /* compile '(does-exit)'  */
        exit
    )
WORD_END(does)
WORD(drop,             does,       DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,              drop,       DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(find, dup)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_CODE(
#if 0 /* TODO */
        dup, count, CALL(string_to_name), nip,         /* ( c-addr nt|0 -1|0|1 ) */
        _q_if0_, T(5), nip, exit,                      /* ( c-addr 0           ) */
        then,                                          /* ( c-addr nt -1|1     ) */
        to_r, nip, name_to_xt, r_from,                 /* ( xt     -1|1        ) */
#endif /* 0 */
        exit
    )
WORD_END(find)
WORD_START(else,       find)
    WORD_DSTACK(2,2)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _else_, _else_, /* compile our unresolved jump */
        cs_swap,                            /* move our jump_info out of the way  */
        CALL(_resolve_jump_here_),          /* resolve jump of previous 'if'      */
        exit
    )
WORD_END(else)
WORD_START(emit, else)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses ip-relative ADDROF() and TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(emit, exit)
WORD_END(emit)
WORD_START(execute, emit)
    WORD_DSTACK(-1,-1) /* pops XT + stack effects of called XT */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0) /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_CODE(execute, exit)
WORD_END(execute)
WORD_START(exit, execute)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(1,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(exit, exit)
WORD_END(exit)
WORD(fill,             exit,       DSTACK(3,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(here,             fill,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(i,                here,       DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD_START(if, i)
    WORD_DSTACK(0,2)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _if_, _if_, exit
    )
WORD_END(if)
WORD(immediate,        if,         DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(invert,           immediate,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(j,                invert,     DSTACK(0,1), RSTACK(3,3), WORD_R_PURE)
WORD_START(leave, j)
    WORD_DSTACK(0,2)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _leave_, _leave_,
        _cs_find_lit_, _do_, one_minus, minus_cs_roll,
        exit
    )
WORD_END(leave)
WORD_START(literal, leave)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    /* multiple exits => cannot inline */
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        CALL(_optimize_literal_),        /* ( token t | n f          ) */
        _if_, T(3),                      /* optimized token, use it    */
            token_comma, exit,           /* append token to XT, exit   */
        then,                            /* ( n                      ) */
        dup, dup, to_short,              /* ( n n to_short(n)        ) */
        equal, _if_, T(5),               /* if n == to_short(n)        */
            _lit_comma_, _lit_short_,    /* append _lit_short_ to XT   */
            short_comma, exit,           /* append (int16)n    to XT   */
        then,                            /* ( n                      ) */
        dup, dup, to_int,                /* ( n n to_int(n)          ) */
        equal, _if_, T(5),               /* if n == to_int(n)          */
            _lit_comma_, _lit_int_,      /* append _lit_int_   to XT   */
            int_comma, exit,             /* append (int32)n    to XT   */
        then,                            /* ( n                      ) */
        _lit_comma_, _lit_cell_,         /* append _lit_cell_  to XT   */
        comma, exit                      /* append dtop        to XT   */
    )
WORD_END(literal)
WORD_START(loop, literal)
    WORD_DSTACK(-1,-1)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _loop_, _loop_,
        CALL(_resolve_loop_), exit
    )
WORD_END(loop)
WORD(lshift,           loop,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(max,              lshift,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(min,              max,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(mod,              min,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(move,             mod,        DSTACK(3,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH | M4FLAG_MEM_STORE)
WORD(negate,           move,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(or,               negate,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(over,             or,         DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD_START(postpone,   over)
    WORD_DSTACK(0,0)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        /* parse-xt                                    ( xt -1|1               )
         * invert                  ( -2 if immediate ) ( xt 0|-2               )
         * if0                       ( not immediate ) ( xt                    )
         *   postpone literal                          (                       )
         *   ' compile,                                ( xt                    )
         * then                                        ( xt                    )
         * compile,                                    (                       )
         */
        CALL(parse_xt),
        invert,
        _if0_, T(5+nCALLt),
        /* avoid CALL(literal) because it compiles (lit-[1248]s) instead of (lit-xt) */
            _lit_comma_, _lit_xt_,                     /* compiles (lit-xt)   */
            xt_comma,                                  /* xt,                 */
            _lit_xt_, XT(compile_comma),               /* ' compile,          */
        then,
        CALL(compile_comma), exit
    )
WORD_END(postpone)
WORD(r_from,           postpone,   DSTACK(0,1), RSTACK(1,0), WORD_R_PURE)
WORD(r_fetch,          r_from,     DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD_START(repeat,     r_fetch)
    WORD_DSTACK(4,0)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, begin,         /* ( while-sys begin-sys ) topmost must be 'begin'      */
        _compile_jump_lit_, _repeat_, _repeat_,
        cs_drop,                    /* we only need the compiled '(repeat)' not the cs data */
        CALL(_resolve_jump_there_), /* resolve jump from '(repeat)' to 'begin'              */
        _check_lit_tok_, _while_,       /* ( while-sys ) must be '(while)'                      */
        CALL(_resolve_jump_here_),  /* resolve jump from '(while)' to here                  */
        exit
    )
WORD_END(repeat)
WORD(rot,              repeat,     DSTACK(3,3), RSTACK(0,0), WORD_PURE)
WORD(rshift,           rot,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(s_quote, rshift)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        /* in>ibuf ibuf-skip-1blank                    (               )
         * in>ibuf '"' ibuf-find-char                  ( c-addr u      )
         * compile-string,                             (               )
         */
        in_to_ibuf, CALL(ibuf_skip_1blank),
        in_to_ibuf, _lit_, T('"'), CALL(ibuf_find_char),
        CALL(compile_string_comma), exit
    )
WORD_END(s_quote)
WORD_START(space, s_quote)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(bl, emit, exit)
WORD_END(space)
WORD(state,            space,     DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* source ( -- c-addr u ) get entire content of input buffer (including already parsed data) */
WORD_START(source,     state)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(in_to_ibuf, iobuf_all_data, exit)
WORD_END(source)
WORD(swap,             source,     DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD_START(then, swap)
    WORD_DSTACK(2,0)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _lit_comma_, then,
        CALL(_resolve_jump_here_), exit
    )
WORD_END(then)
WORD_START(type, then)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* cannot inline in native code, uses ip-relative call */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(type, exit)
WORD_END(type)
WORD(u_less,           type,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(unloop,           u_less,     DSTACK(0,0), RSTACK(2,0), WORD_R_PURE)
WORD_START(until,      unloop)
    WORD_DSTACK(2,0)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, begin,             /* ( sys ) must be 'begin' */
        _compile_jump_lit_, _until_, _until_,
        cs_drop,                    /* we only need the compiled '(until)' not the cs data */
        CALL(_resolve_jump_there_), /* resolve jump offset from '(until)' to 'begin'       */
        exit
    )
WORD_END(until)
WORD_START(variable,   until)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        zero, CALL(_create_),                  /* create word                          */
        right_bracket,                         /* start compiling                      */
        _lit_comma_, _ip_to_data_addr_,        /* compile (ip>data>addr)               */
        CALL(_finish_),                        /* finish compiling, make word findable */
        one_cell, allot, exit                  /* allocate one cell                    */
    )
WORD_END(variable)
WORD_START(while,     variable)
    WORD_DSTACK(4,0)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, begin,             /* ( sys ) topmost must be 'begin' */
        _compile_jump_lit_, _while_, _while_,
        cs_swap, exit                   /* ( while-sys begin-sys )         */
    )
WORD(xor,              while,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(left_bracket,     xor,        DSTACK(0,0), RSTACK(0,0), M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
WORD_START(bracket_tick,  left_bracket)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        CALL(tick),                    /* '                                          */
        /* avoid CALL(literal) because it compiles (lit-[1248]s) instead of (lit-xt) */
        _lit_comma_, _lit_xt_,         /* compiles (lit-xt)                          */
        xt_comma, exit                 /* xt,                                        */
    )
WORD_END(bracket_tick)
WORD_START(right_bracket,  bracket_tick)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* used %ip-relative JUMP(), cannot inline into native code */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(right_bracket, exit)
WORD_END(right_bracket)

#undef LASTWORD
#define LASTWORD right_bracket
