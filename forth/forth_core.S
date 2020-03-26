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

#define LASTWORD store

WORD(store,            LASTWORD,   DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(times,            store,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus,             times,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus_store,       plus,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(comma,            plus_store, DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
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
        /* state @ 0=                                  ( t|f             )
         *    M4ERR_COMPILER_NESTING and throw         (                 )
         * parse-name                                  ( c-addr u        )
         * dup 0=                                      ( c-addr u t|f    )
         *    M4ERR_ZERO_LENGTH_NAME and throw         ( c-addr u        )
         * name, set-latest                            (                 )
         * postpone ]
         * 0 M4right_bracket              ( colon-sys: 0 M4right_bracket )
         */
        state, fetch, zero_equal,
            _lit_, T(M4ERR_COMPILER_NESTING), and, throw,
        CALL(parse_name),
        dup, zero_equal,
            _lit_, T(M4ERR_ZERO_LENGTH_NAME), and, throw,
        name_comma, set_latest,
        right_bracket,
        zero, _lit_, right_bracket, exit
    )
WORD_END(colon)
WORD_START(semi,       colon)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        /* state @ 0=                                  ( t|f             )
         *    M4ERR_INTERPRETING_COMPILE_ONLY_WORD and throw (           )
         * 2drop latest                                ( nt              )
         * ' exit compile, [                           ( nt              )
         * get-current wordlist-add ( name is now findable by parse-name )
         */
        state, fetch, zero_equal,
            _lit_, T(M4ERR_INTERPRETING_COMPILE_ONLY_WORD), and, throw,
        then,
        two_drop, latest,
        _compile_lit_, exit, left_bracket,
        get_current, wordlist_add, exit
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
        _compile_lit_, begin, _num_compiled_, _lit_, begin, exit
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
WORD(depth,            count,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD_START(do, depth)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,2)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_lit_, do, _num_compiled_, _lit_, do, exit
    )
WORD_END(do)
WORD(drop,             do,         DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,              drop,       DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(find, dup)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_CODE(
#if 0 /* TODO */
        dup, count, CALL(string_to_name),   /* ( c-addr nt|0 -1|0|1 ) */
        _q_if0_, T(5), nip, exit,                /* ( c-addr 0           ) */
        then,                                        /* ( c-addr nt -1|1     ) */
        to_r, nip, name_to_xt, r_from,                  /* ( xt     -1|1        ) */
#endif /* 0 */
        exit
    )
WORD_END(find)
WORD_START(else, find)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_unresolved_jump_, _else_, _else_, /* compile our unresolved jump */
        two_swap,                           /* move our jump_info out of the way  */
        CALL(_resolve_jump_here_),          /* resolve jump of previous 'if'      */
        exit
    )
WORD_END(else)
WORD_START(emit, else)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE() /* uses ip-relative ADDROF() and ASM_CALL(), cannot inline in native code */
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
WORD(here,             exit,       DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(i,                here,       DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD_START(if, i)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_unresolved_jump_, _if_, _if_, exit
    )
WORD_END(if)
WORD(invert,           if,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(j,                invert,     DSTACK(0,1), RSTACK(3,3), WORD_R_PURE)
WORD_START(leave, j)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_unresolved_jump_, _leave_, _leave_, exit
    )
WORD_END(leave)
WORD_START(literal, leave)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    /* multiple exits & uses (ip) to access its body => cannot inline */
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE | M4FLAG_DATA_TOKENS)
    WORD_DATA_AND_CODE(
      literal,
      WORD_DATA_TOKENS(
        zero, one, minus_one, two, three, four, eight
      ),
      WORD_CODE_TOKENS(
        _ip_to_data_, div_token,         /* ( n taddr tn )             */
        CALL(_any_token_gives_cell_q_),
        _if_, T(3),                      /* if executing token gives n */
            token_comma, exit,           /* append token to XT, exit   */
        then,
        dup, dup, to_short,
        equal, _if_, T(5),               /* if n == to_short(n)        */
            _compile_lit_, _lit_short_,  /* append _lit_short_ to XT   */
            short_comma, exit,           /* append (int16)n    to XT   */
        then,
        dup, dup, to_int,
        equal, _if_, T(5),               /* if n == to_int(n)          */
            _compile_lit_, _lit_int_,    /* append _lit_int_   to XT   */
            int_comma, exit,             /* append (int32)n    to XT   */
        then,
        _compile_lit_, _lit_cell_,       /* append _lit_cell_  to XT   */
        comma,                           /* append dtop        to XT   */
        exit
      )
    )
WORD_END(literal)
WORD_START(loop, literal)
    WORD_DSTACK(0,0)  /* stack effect if not jumping */
    WORD_RSTACK(2,2)
    WORD_DSTACK(0,0)  /* stack effect if jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_MAY_JUMP | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_unresolved_jump_, _loop_, _loop_,
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
WORD(r_from,           over,       DSTACK(0,1), RSTACK(1,0), WORD_R_PURE)
WORD(r_fetch,          r_from,     DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD(rot,              r_fetch,    DSTACK(3,3), RSTACK(0,0), WORD_PURE)
WORD(rshift,           rot,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(space, rshift)
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
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_lit_, then,
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
WORD(xor,              unloop,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(left_bracket,     unloop,     DSTACK(0,0), RSTACK(0,0), M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
WORD(right_bracket,  left_bracket, DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)

#undef LASTWORD
#define LASTWORD right_bracket
