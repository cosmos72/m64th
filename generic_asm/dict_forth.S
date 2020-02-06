/**
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

/* ---------------------------------------------------------------------------------------------- */
DICT_START(forth)

DICTNAME(5, "forth", forth)

DICT_WORDS_FORTH(WORDNAME)

WORD(store,            store,      DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(times,            store,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus,             times,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus_store,       plus,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(minus,            plus_store, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(div,              minus,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(div_mod,          div,        DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD(zero_less,        div_mod,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_ne,          zero_less,  DSTACK(1,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(zero_equal,       zero_ne,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_more,        zero_equal, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_plus,         zero_more,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_minus,        one_plus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_times,        one_minus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_div,          two_times,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_drop,         two_div,    DSTACK(2,0), RSTACK(0,0), WORD_PURE)
WORD(two_dup,          two_drop,   DSTACK(2,4), RSTACK(0,0), WORD_PURE)
WORD(less,             two_dup,    DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(ne,               less,       DSTACK(2,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(equal,            ne,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(more,             equal,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/*
 * >number ( ud caddr n -- ud caddr n )  \ convert string from base to unsigned number
 */
WORD_START(to_number, more)
    WORD_FLAGS(0)
    WORD_DSTACK(4,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        /* dup 0 <=
         * if
         *    exit
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
        dup, zero, _if_less_equal_, T(2),      /* ( ud caddr n     )                   */
            exit,                              /* ( ud caddr n     )                   */
        _then_,
        /* TODO: handle high cell */
        rot, to_r,                             /* ( ul caddr n 0   ) (R: uh          ) */
        _call_, XT(base), fetch, to_r, zero,   /* ( ul caddr n 0   ) (R: uh base     ) */
        do,                                    /* ( ul caddr       ) (R: uh base n 0 ) */
            dup, c_fetch,                      /* ( ul caddr ch    ) (R: uh base n i ) */
            _call_, XT(char_to_u),             /* ( ul caddr digit ) (R: uh base n i ) */
            dup, zero, j/*NON-PORTABLE*/, within,
            _if_zero_, T(10),                  /* ( ul caddr digit ) (R: uh base n i ) */
                drop, i_prime, i, minus,       /* ( ul caddr n'    ) (R: uh base n i)  */
                unloop, r_from_drop,           /* ( ul caddr n'    ) (R: uh            */
                r_from, minus_rot, exit,       /* ( ud caddr n'    )                   */
            _then_,                            /* ( ul caddr digit ) (R: uh base n i ) */
            rot,                               /* ( caddr digit ul ) (R: uh base n i ) */
            /* TODO: handle high cell */
            j/*NON-PORTABLE*/, times, plus,    /* ( caddr ul'      ) (R: uh base n i ) */
            swap, char_plus,                   /* ( ul caddr'      ) (R: uh base n i ) */
        _loop_, T(-27-SZ/SZt),                 /* ( ul caddr       ) (R: uh base     ) */
        r_from_drop, r_from, swap, zero, exit  /* ( ud caddr 0     )                   */
    )
WORD_END(to_number)
WORD(to_r,             to_number,  DSTACK(1,0), RSTACK(0,1), WORD_R_PURE)
WORD_START(question_do, to_r)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_CONSUMES_IP_SZt | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(2,0) /* stack effect when not jumping */
    WORD_RSTACK(0,2)
    WORD_DSTACK(2,0) /* stack effect when jumping */
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_unresolved_jump_, _question_do_, exit)
WORD_END(question_do)
WORD(question_dup,   question_do,  DSTACK(1,-1),RSTACK(0,0), WORD_PURE)
WORD(fetch,          question_dup, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(abs,              fetch,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(and,              abs,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(bl,               and,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(c_store,          bl,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD_START(base, c_store)
    WORD_FLAGS(0)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE_AND_DATA(
      base,
      WORD_CODE_TOKENS(
        _ip_, xt_to_data_addr, noop/*padding to align at 8*/, exit
      ),
      WORD_DATA_CELLS(10)
    )
WORD_END(base)
WORD_START(bye, base) /* tools ext */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_DSTACK(0,-1)  /* data   stack may be altered from outside */
    WORD_RSTACK(0,-1)  /* return stack may be altered from outside */
    WORD_DSTACK(0,-1)
    WORD_RSTACK(0,-1)
    WORD_NATIVE_NONE()
    WORD_CODE(bye, exit) /* exit is reachable by subsequent m4th_run() */
WORD_END(bye)
WORD(c_fetch,          bye,        DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(cell_plus,        c_fetch,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(cells,            cell_plus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(char_plus,        cells,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(chars,            char_plus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(cmove,            chars,      DSTACK(3,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH | M4FLAG_MEM_STORE) /* core ext */

WORD_START(compile_comma, cmove)
    WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        dup, _call_, XT(xt_inline_query), _if_zero_, T(5),
            _compile_lit_, _call_,     /* compile (call) */
            _compile_xt_, exit,        /* compile XT     */
        _then_,
        _call_, XT(_inline_), exit
   )
WORD_END(compile_comma)
WORD(depth,    compile_comma,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD_START(do, depth)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,2)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_lit_, do, _num_compiled_, _lit_, do, exit
    )
WORD_END(do)
WORD(drop,             do,         DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,              drop,       DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(else, dup)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_lit_, _else_,           /* compile our unresolved jump */
        _compile_lit_, T(-1),
        _call_, XT(_resolve_jump_here_), /* resolve jump offset of previous 'if' */
        _num_compiled_, _lit_, _else_,   /* ( code_n _else_ ) push our unresolved jump */
        exit
    )
WORD_END(else)
WORD_START(execute, else)
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_DSTACK(-1,-1) /* pops XT + stack effects of called XT */
    WORD_RSTACK(0,0)
    WORD_DSTACK(0,0) /* stack effect when calling */
    WORD_RSTACK(0,1)
    WORD_NATIVE_NONE()
    WORD_CODE(execute, exit)
WORD_END(execute)
WORD_START(exit, execute)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(1,0)
    WORD_NATIVE_NONE()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(exit, exit)
WORD_END(exit)
WORD(false,            exit,       DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(i,                false,      DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD_START(if, i)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_unresolved_jump_, _if_, exit
    )
WORD_END(if)
WORD(invert,           if,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(j,                invert,     DSTACK(0,1), RSTACK(3,3), WORD_R_PURE)
WORD_START(leave, j)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_JUMP | M4FLAG_IMMEDIATE)
    WORD_STACK_NONE() /* dummy, token always jumps */
    WORD_DSTACK(0,0)   /* stack effect when jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_unresolved_jump_, _leave_, exit
    )
WORD_END(leave)
WORD_START(literal, leave)
    /* cannot be inlined, uses (ip) to access its body */
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE | M4FLAG_DATA_TOKENS)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE_AND_DATA(
      literal,
      WORD_CODE_TOKENS(
        _ip_, xt_to_data, div_token,     /* ( n taddr tn )             */
        _call_, XT(_any_token_gives_cell_q_),
        _if_, T(3), _compile_token_,     /* if executing token gives n */
            exit,                        /* append token to XT, exit   */
        _then_, 
        dup, dup, to_short,
        _if_equal_, T(5),                /* if n == to_short(n)        */
            _compile_lit_, _lit2s_,      /* append _lit2s_     to XT   */
            _compile2s_, exit,           /* append (int16)n    to XT   */
        _then_,
        dup, dup, to_int,
        _if_equal_, T(5),                /* if n == to_int(n)          */
            _compile_lit_, _lit4s_,      /* append _lit4s_     to XT   */
            _compile4s_, exit,           /* append (int32)n    to XT   */
        _then_,
        _compile_lit_, _lit_cell_,       /* append _lit_cell_  to XT   */
        _compile_cell_,                  /* append dtop        to XT   */
        exit
      ),
      WORD_DATA_TOKENS(
        zero, one, minus_one, two, three, four, eight
      )
    )
WORD_END(literal)
WORD_START(loop, literal)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_MAY_JUMP | M4FLAG_IMMEDIATE)
    WORD_DSTACK(0,0)  /* stack effect if not jumping */
    WORD_RSTACK(2,2)
    WORD_DSTACK(0,0)  /* stack effect if jumping */
    WORD_RSTACK(2,0)
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_unresolved_jump_, _loop_,
        _call_, XT(_resolve_loop_), exit
    )
WORD_END(loop)
WORD(lshift,           loop,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(max,              lshift,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(min,              max,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(mod,              min,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(negate,           mod,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(nip,              negate,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(or,               nip,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(over,             or,         DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD(r_from,           over,       DSTACK(0,1), RSTACK(1,0), WORD_R_PURE)
WORD(r_fetch,          r_from,     DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD(rot,              r_fetch,    DSTACK(3,3), RSTACK(0,0), WORD_PURE)
WORD(rshift,           rot,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(swap,             rshift,     DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD_START(then, swap)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_lit_, _then_,
        _call_, XT(_resolve_jump_here_), exit
    )
WORD_END(then)
WORD(true,             then,       DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(tuck,             true,       DSTACK(2,3), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(u_less,           tuck,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(u_more,           u_less,     DSTACK(2,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(unloop,           u_more,     DSTACK(0,0), RSTACK(2,0), WORD_R_PURE)
/*
 * within ( x lo hi -- flag )   \ true if lo <= x < hi, either signed or unsigned
 * : within over - -rot - u> ;
 */
WORD(within,           unloop,     DSTACK(3,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(xor,              within,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)

DICT_BODY(forth, xor)
DICT_END(forth)
