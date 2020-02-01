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
WORD(less,             two_div,    DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(ne,               less,       DSTACK(2,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(equal,            ne,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(more,             equal,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(to_r,             more,       DSTACK(1,0), RSTACK(0,1), WORD_R_PURE)
WORD(question_dup,     to_r,       DSTACK(1,-1),RSTACK(0,0), WORD_PURE)
WORD(fetch,          question_dup, DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(abs,              fetch,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(and,              abs,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(bl,               and,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(c_store,          bl,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD_START(bye, c_store) /* tools ext */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_DSTACK(0,-1)  /* data   stack may be altered from outside */
    WORD_RSTACK(0,-1)  /* return stack may be altered from outside */
    WORD_DSTACK(0,-1)
    WORD_RSTACK(0,-1)
    WORD_NATIVE_NONE()
    WORD_CODE(bye, exit) /* exit is reachable by subsequent m4th_run_vm() */
WORD_END(bye)
WORD(c_fetch,          bye,        DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(cell_plus,        c_fetch,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(cells,            cell_plus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(char_plus,        cells,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(chars,            char_plus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)

WORD_DECL_SYM(_inline_)        /* forward declarations */
WORD_DECL_SYM(_optimize_)
WORD_START(compile_comma, chars)
    WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_CODE(_compile_lit_token_, _call_, /* compile (call) */
               _compile_xt_,
#if 0
               _call_, XT(_inline_),
               _call_, XT(_optimize_),
#endif
               exit
   )
WORD_END(compile_comma)
WORD(depth,    compile_comma,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(drop,             depth,      DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,              drop,       DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(else, dup)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_CODE_N_AUTO(else)
    WORD_DATA_N(0)
    WORD_CODE_START(else)
    WORD_CODE_BODY(
        _compile_lit_token_, _else_,
        _compile_lit_token_, T(-1),
        _call_, XT(_resolve_if_else_),         /* resolve jump offset of previous 'if' */
        _num_compiled_,                        /* ( #tokens ) push our jump offset     */
        exit
    )
    WORD_CODE_END(else)
WORD_END(else)
WORD_START(exit, else)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
    WORD_DSTACK(0,-1) /* stack effect when not jumping */
    WORD_RSTACK(0,-1)
    WORD_DSTACK(0, 0) /* stack effect when jumping */
    WORD_RSTACK(0,-1) /* we do not yet track the return address stored in rstack */
    WORD_NATIVE_NONE()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
    WORD_CODE(exit, exit)
WORD_END(exit)
WORD(false,            exit,       DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(i,                false,      DSTACK(0,1), RSTACK(1,1), WORD_R_PURE)
WORD_START(if, i)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_CODE_N_AUTO(if)
    WORD_DATA_N(0)
    WORD_CODE_START(if)
    WORD_CODE_BODY(
        _compile_lit_token_, _if_,
        _compile_lit_token_, T(-1),
        _num_compiled_,                        /* ( #tokens )   */
        exit
    )
    WORD_CODE_END(if)
WORD_END(if)
WORD(invert,           if,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(j,                invert,     DSTACK(0,1), RSTACK(3,3), WORD_R_PURE)
WORD_START(literal, j)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE | M4FLAG_DATA_TOKENS)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_CODE_N_AUTO(literal)
    WORD_DATA_N_AUTO(literal)
    WORD_CODE_START(literal)
    WORD_CODE_BODY(
        _ip_, xt_to_data, div_token,      /* ( n taddr tn )            */
        _call_, XT(_any_token_gives_cell_q_),
        _if_, T(3), _compile_token_,     /* if executing token gives n */
            exit,                        /* append token to XT, exit   */
        _then_, 
        dup, dup, to_short,
        _if_equal_, T(5),                /* if n == to_short(n)        */
            _compile_lit_token_,
            _literal2s_,                 /* append _literal2s_ to XT   */
            _compile2s_, exit,           /* append (int16)n    to XT   */
        _then_,
        dup, dup, to_int,
        _if_equal_, T(5),                /* if n == to_int(n)          */
            _compile_lit_token_,
            _literal4s_,                 /* append _literal4s_ to XT   */
            _compile4s_, exit,           /* append (int32)n    to XT   */
        _then_,
        _compile_lit_token_, _lit_cell_, /* append _lit_cell_  to XT   */
        _compile_cell_,                  /* append dtop to XT          */
        exit
    )
    WORD_CODE_END(literal)
    WORD_DATA_START(literal)
        WORD_DATA_TOKENS(zero, one, minus_one, two, three, four, eight)
    WORD_DATA_END(literal)
WORD_END(literal)
WORD(lshift,           literal,    DSTACK(2,1), RSTACK(0,0), WORD_PURE)
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
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_NOJUMP()
    WORD_NATIVE_NONE()
    WORD_CODE(
        _compile_lit_token_, _then_,
        _call_, XT(_resolve_if_else_), exit
    )
WORD_END(then)
WORD(true,             then,       DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(unloop,           true,       DSTACK(0,0), RSTACK(2,0), WORD_R_PURE)
WORD(xor,              unloop,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)

DICT_BODY(forth, xor)
DICT_END(forth)
