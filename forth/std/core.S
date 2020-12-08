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

#include "../../include/err.mh" /* M4ERR_STACK_UNDERFLOW */

DICT_WORDS_FORTH_CORE(WORDNAME)

WORD(store,            LASTWORD,   DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
/* # ( du -- du' ) divide du by current BASE. du' is the quotient.
 * convert the remainder u to a character and prepend it to pictured numeric output */
WORD_START(num,        store)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        base, fetch, u_to_d,                        /* ( du du-base               ) */
        CALL(du_div_mod),                           /* ( du-remainder du-quotient ) */
        two_swap, d_to_s,                           /* ( du-quotient  remainder   ) */
        CALL(u_to_char), hold, exit                 /* ( du-quotent               ) */
    )
WORD_END(num)
WORD(num_end,          num,        DSTACK(2,2), RSTACK(0,0), WORD_IMPURE)
/* #s ( du -- du' ) call # repeatedly (at least once) until du is zero. return du. */
WORD_START(num_s,      num_end)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        begin,                                      /* ( du                       ) */
            CALL(num),                              /* ( du'                      ) */
            over, zero_equal,                       /* ( du t|f                   ) */
            over, zero_equal, and,                  /* ( du t|f'                  ) */
        _until_, T(-8-nCALLt),                      /* ( du                       ) */
        exit
    )
WORD_END(num_s)
WORD_START(tick,       num_s)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
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
WORD_START(paren,      tick)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_IMMEDIATE | M4FLAG_INLINE)
    WORD_CODE(
        _lit_, T(')'), CALL(parse), two_drop, exit
    )
WORD_END(paren)
WORD(times,            paren,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus,             times,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus_store,       plus,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD_START(plus_loop, plus_store)
    WORD_DSTACK(-1,-1)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _plus_loop_, _loop_,
        CALL(_resolve_loop_), exit
    )
WORD_END(plus_loop)
WORD(comma,            plus_loop,  DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD(minus,            comma,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/* ( n -- ) display n using current base */
WORD_START(dot,        minus)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* depth 0<=                                                 ( n         )
         * M4ERR_STACK_UNDERFLOW and throw                           ( n         )
         * dup >r dup 0<                                             ( n t|f     ) ( R: n )
         * if                                                        ( -u        ) ( R: n )
         *    negate                                                 ( u         ) ( R: n )
         * then                                                      ( u         ) ( R: n )
         * <# bl hold                                                ( u         ) ( R: n )
         * u>d #s                                                    ( du        ) ( R: n )
         * r> sign                                                   ( du        )
         * #> type                                                   (           )
         */
        depth, zero_less_equal,
        _lit_, T(M4ERR_STACK_UNDERFLOW), and, throw,

        dup_to_r, dup, zero_less,
        _if_, T(2),
            negate,
        then,
        num_start, bl, hold,
        u_to_d, CALL(num_s),
        r_from, CALL(sign),
        num_end, type, exit
    )
WORD_END(dot)
/* ( -- ) read string delimited by "
 * compile code to display it */
WORD_START(dot_quote,  dot)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_IMMEDIATE)
    WORD_CODE(
        state_fetch,
        _if0_, T(6+nCALLt),       /* interpreting => type string immediately */
            _lit_, T('"'), CALL(parse),                 /* ( c-addr u      ) */
            type, exit,
        then,                     /* compiling */
        CALL(s_quote), _lit_comma_, type, exit
    )
WORD_END(dot_quote)
WORD(div,              dot_quote,  DSTACK(2,1), RSTACK(0,0), WORD_PURE)
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
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        zero, CALL(_create_), right_bracket, exit /* ( colon-sys       ) */
    )
WORD_END(colon)
WORD_START(semi,       colon)
    WORD_DSTACK(2,-1)   /* ( sys -- xt| )  xt if created with :noname */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        /* [throw-if-not-compiling]    ( colon-sys       )
         * [finish]                    ( name is now findable by parse-name )
         */
        CALL(_throw_if_not_compiling_),
        CALL(_finish_), exit
    )
WORD_END(semi)
WORD(less,             semi,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(num_start,        less,       DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(equal,            num_start,  DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(more,             equal,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(to_in,      more)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(in_to_ibuf, iobuf_pos, exit)
WORD_END(to_in)
/*
 * >number ( du caddr n -- du caddr n )  \ convert string from base to number
 */
WORD_START(to_number, to_in)
    WORD_DSTACK(4,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* 2swap 2>r base @                    ( caddr n base ) ( R: du )
         * string&base>u                       ( caddr' n' u  ) ( R: du )
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
    WORD_ASM_NONE()
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
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE | M4FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _compile_sys_lit_, begin, begin, exit
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
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit_, T(M4FLAG_INLINE|M4FLAG_PURE),
        CALL(_create_), right_bracket,   /* create word, start compiling         */
        rot, CALL(literal),                    /* compile number                       */
        CALL(_finish_), exit                   /* finish compiling, make word findable */
    )
WORD_END(constant)
WORD_START(create,     constant)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _lit2s_, SHORT(M4FLAG_CREATE),
        CALL(_create_),                        /* create word, mark it M4FLAG_CREATE   */
        right_bracket,                         /* start compiling                      */
        _lit_comma_, _ip_to_data_addr_,        /* compile (ip>data>addr)               */
        _lit_comma_, _call_,                   /* compile (call)                       */
        _lit_xt_, XT(noop), xt_comma,          /* compile XT(noop). placeholder set by DOES> */
        CALL(_finish_), exit                   /* finish compiling, make word findable */
    )
WORD_END(create)
WORD_START(decimal,    create)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_STACK_NONE()  /* stack effect if jumping */
    WORD_ASM_NONE()
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
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _do_, _do_, exit
    )
WORD_END(do)
WORD_START(does,       do)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
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
        _lit_comma_, _call_,                   /* compile '(call)'       */
        _lit_xt_, XT(_does_), xt_comma,        /* compile XT of '(does)' */
        _lit_comma_, _does_exit_,              /* compile '(does-exit)'  */
        exit
    )
WORD_END(does)
WORD(drop,             does,       DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,              drop,       DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(find, dup)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* disassembly of forth_core.forth */
        /*22*/ dup, count, _lit_xt_, XT(parse_nt), _catch_beg_, _catch_end_, nip, _if_, T(3), two_drop, _else_, T(6), rot, drop, swap, name_to_xt, swap, then, exit
    )
WORD_END(find)
WORD_START(else,       find)
    WORD_DSTACK(2,2)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
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
    WORD_ASM_NONE() /* uses ip-relative ADDROF() and TOKEN_CALL_NOTHROW(), cannot inline in native code */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(emit, exit)
WORD_END(emit)
WORD_START(execute, emit)
    WORD_DSTACK(-1,-1) /* pops XT + stack effects of called XT */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0) /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_CODE(execute, exit)
WORD_END(execute)
WORD_START(exit, execute)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(1,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE | M4FLAG_JUMP)
    WORD_CODE(
        CALL(_throw_if_not_compiling_),
        user_var, T(M4TH_USER_VAR_LOCALS), fetch,      /* ( ls|0                 ) */
        question_dup,                                  /* ( ls ls |0             ) */
        _if_, T(9),                                    /* ( ls                   ) */
            fetch, question_dup,                       /* ( ls.n ls.n | 0        ) */
            _if_, T(4),                                /* ( ls.n                 ) */
                _lit_comma_, _lexit_x_, /* compile '(lexit-x)'         */
                token_comma,                  /* compile T(ls.n)                   */
            then,                                      /* (                      ) */
        then,                                          /* (                      ) */
        _lit_comma_, exit,           /* compile 'exit'    (                      ) */
        exit
    )
WORD_END(exit)
WORD(fill,             exit,       DSTACK(3,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(here,             fill,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(hold,             here,       DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD(i,                hold,       DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD_START(if, i)
    WORD_DSTACK(0,2)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
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
    WORD_ASM_NONE()
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
    WORD_ASM_NONE()
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
    WORD_ASM_NONE()
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
    WORD_ASM_NONE()
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
WORD_START(recurse,    r_fetch)
    WORD_DSTACK(4,0)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _lit_comma_, _recurse_,
        _num_compiled_, one_plus, negate,              /* ( -IP_offset                    ) */
        token_comma, exit
    )
WORD_END(recurse)
WORD_START(repeat,     recurse)
    WORD_DSTACK(4,0)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, begin,     /* ( while-sys begin-sys ) topmost must be 'begin'      */
        _compile_jump_lit_, _repeat_, _repeat_,
        cs_drop,                    /* we only need the compiled '(repeat)' not the cs data */
        CALL(_resolve_jump_there_), /* resolve jump from '(repeat)' to 'begin'              */
        _check_lit_tok_, _while_,   /* ( while-sys ) must be '(while)'                      */
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
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _lit_, T('"'), CALL(parse),                 /* ( c-addr u      ) */
        CALL(compile_string_comma), exit
    )
WORD_END(s_quote)
/* ( n -- d ) extend signed number to double width */
WORD_START(s_to_d, s_quote)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_PURE)
    WORD_CODE(
        dup, zero_less, exit
    )
WORD_END(s_to_d)
/* ( n -- ) if n is negative, add a a minus sign to the beginning of the pictured numeric output */
WORD_START(sign, s_to_d)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        zero_less, _if_, T(4),
            _lit_, T('-'), hold,
        then, exit
    )
WORD_END(sign)
WORD(state,            sign,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/* source ( -- c-addr u ) get entire content of input buffer (including already parsed data) */
WORD_START(source,     state)
    WORD_DSTACK(0,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(in_to_ibuf, iobuf_all_data, exit)
WORD_END(source)
WORD_START(space, source)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(bl, emit, exit)
WORD_END(space)
WORD_START(spaces, space)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE_AND_DATA(spaces,
      WORD_CODE_TOKENS(                             /* ( n                 )             */
        _ip_to_data_,                               /* ( n c-addr u        )             */
        rot,                                        /* ( c-addr u n        )             */
        zero, max, to_r,                            /* ( c-addr u          ) ( R: n     ) */
        begin,                                      /* ( c-addr u          ) ( R: left  ) */
            two_dup, r_fetch, min,                  /* ( c-addr u c-addr v ) ( R: left  ) */
            dup, negate, r_plus_store,              /* ( c-addr u c-addr v ) ( R: left' ) */
            type,                                   /* ( c-addr u          ) ( R: left  ) */
            r_fetch, zero_equal,                    /* ( c-addr u t|f      ) ( R: left  ) */
        _until_, T(-11),                            /* ( c-addr u          ) ( R: 0     ) */
        two_drop, r_from_drop, exit                 /* (                   )             */
      ), WORD_DATA_STRINGS(
        "                                                                                                                                "
      )
    )
WORD_END(spaces)
WORD(swap,             spaces,     DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD_START(then, swap)
    WORD_DSTACK(2,0)  /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE | M4FLAG_REEXEC_AFTER_OPTIMIZE)
    WORD_CODE(
        _lit_comma_, then,
        CALL(_resolve_jump_here_), exit
    )
WORD_END(then)
WORD_START(type, then)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* cannot inline in native code, uses ip-relative call */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(type, exit)
WORD_END(type)
/* ( u -- ) display u using current base */
WORD_START(u_dot,      type)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        /* depth 0<=                                                 ( u         )
         * M4ERR_STACK_UNDERFLOW and throw                           ( u         )
         * <# bl hold                                                ( u         )
         * u>d #s                                                    ( du        )
         * #> type                                                   (           )
         */
        depth, zero_less_equal,
        _lit_, T(M4ERR_STACK_UNDERFLOW), and, throw,

        num_start, bl, hold,
        u_to_d, CALL(num_s),
        num_end, type, exit
    )
WORD_END(u_dot)
WORD(u_less,           u_dot,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/** ( du u -- u-rem u-quo ) divide double-width unsigned number.
 * return single-width unsigned quotient and remainder */
WORD_START(um_div_mod, u_less)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_PURE | M4FLAG_INLINE)
    WORD_CODE(
        u_to_d, CALL(du_div_mod),              /* ( du-rem du-quo                    ) */
        d_to_s, minus_rot, d_to_s, swap,       /* ( u-rem  u-quo                     ) */
        exit
    )
WORD_END(until)
WORD(unloop,           u_less,     DSTACK(0,0), RSTACK(2,0), WORD_R_PURE)
WORD_START(until,      unloop)
    WORD_DSTACK(1,0)   /* execution stack effect when not jumping */
    WORD_RSTACK(0,0)
    WORD_DSTACK(1,0)   /* execution stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _lit_tok_, _until_,
        CALL(_until_comma_), exit
    )
WORD_END(until)
WORD_START(variable,   until)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        one_cell, CALL(buffer_colon), exit
    )
WORD_END(variable)
WORD_START(while,     variable)
    WORD_DSTACK(4,0)   /* stack effect when compiling */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, begin,             /* ( sys ) topmost must be 'begin' */
        _compile_jump_lit_, _while_, _while_,
        cs_swap, exit                       /* ( while-sys begin-sys )         */
    )
WORD(xor,              while,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(left_bracket,     xor,        DSTACK(0,0), RSTACK(0,0), M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
WORD_START(bracket_tick,  left_bracket)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
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
    WORD_ASM_NONE() /* used %ip-relative JUMP(), cannot inline into native code */
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(right_bracket, exit)
WORD_END(right_bracket)

#undef LASTWORD
#define LASTWORD right_bracket
