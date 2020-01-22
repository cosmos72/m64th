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

#include "../common/asm.mh"
#include "dict.mh"
#include "dict_forth.mh"

/* ---------------------------------------------------------------------------------------------- */
DICT_START(forth)

DICTNAME(5, "forth", forth)

DICT_WORDS_FORTH(WORDNAME)

WORD(store,            store,      DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(star,             store,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus,             star,       DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(plus_store,       plus,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD(minus,            plus_store, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(slash,            minus,      DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(slash_mod,        slash,      DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD(zero_less,        slash_mod,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_not_equals,  zero_less,  DSTACK(1,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(zero_equals, zero_not_equals, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_greater_than,zero_equals,DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_plus, zero_greater_than,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(one_minus,        one_plus,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_star,         one_minus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_slash,        two_star,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(less_than,        two_slash,  DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(not_equals,       less_than,  DSTACK(2,1), RSTACK(0,0), WORD_PURE) /* core ext */
WORD(equals,           not_equals, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(greater_than,     equals,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(to_r,     greater_than,       DSTACK(1,0), RSTACK(0,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(question_dupe,    to_r,       DSTACK(1,-1),RSTACK(0,0), WORD_PURE)
WORD(fetch,    question_dupe,      DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(abs,              fetch,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(and,              abs,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(bl,               and,        DSTACK(0,1), RSTACK(0,0), WORD_PURE)
WORD(c_store,          bl,         DSTACK(2,0), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_STORE)
WORD_START(bye, c_store) /* tools ext */
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_MAY_JUMP)
    WORD_DSTACK(0,-1)  /* data   stack may be altered from outside */
    WORD_RSTACK(0,-1)  /* return stack may be altered from outside */
    WORD_NATIVE_NONE()
    /* exit is reachable by subsequent m4th_run() */
    WORD_FUNCS(bye, exit)
WORD_END(bye)
WORD(c_fetch,          bye,        DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M4FLAG_MEM_FETCH)
WORD(cell_plus,        c_fetch,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(cells,            cell_plus,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD_START(char_plus,  cells)
   WORD_FLAGS(WORD_PURE)
   WORD_DSTACK(1,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_LEN(one_plus)   /* char+ is implemented as 1+ */
   WORD_FUNCS(one_plus, exit)
WORD_END(char_plus)
WORD_START(chars, char_plus)
   WORD_FLAGS(WORD_PURE)
   WORD_DSTACK(1,1)
   WORD_RSTACK(0,0)
   WORD_NATIVE_LEN_0()         /* chars is implemented as noop */
   WORD_FUNCS(exit)
WORD_END(chars)

WORD_DECL_SYM(_inline_)        /* forward declarations */
WORD_DECL_SYM(_optimize_)
WORD_START(compile_comma, chars)
   WORD_FLAGS(WORD_IMPURE | M4FLAG_COMPILE_ONLY)
   WORD_DSTACK(1,0)
   WORD_RSTACK(0,0)
   WORD_NATIVE_NONE()
   WORD_FUNCS(_compile_comma_,
              _call_, XT(_inline_),
              _call_, XT(_optimize_),
              exit
   )
WORD_END(compile_comma)
WORD(depth,    compile_comma,      DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(drop,             depth,      DSTACK(1,0), RSTACK(0,0), WORD_PURE)
WORD(dup,              drop,       DSTACK(1,2), RSTACK(0,0), WORD_PURE)
WORD_START(exit, dup)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,-1)
   WORD_RSTACK(0,-1) /* we do not yet track the return address pushed (call) */
   WORD_NATIVE_NONE()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_FUNCS(exit, exit)
WORD_END(exit)
WORD_START(false, exit)        /* core ext */
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN(zero)      /* false is implemented as zero */
    WORD_FUNCS(zero, exit)
WORD_END(false)
WORD(i,                false,      DSTACK(0,1), RSTACK(1,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(i_prime,          i,          DSTACK(0,1), RSTACK(2,2), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(invert,           i_prime,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(j,                invert,     DSTACK(0,1), RSTACK(3,3), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD_START(literal, j)
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_NATIVE_NONE()
    WORD_FUNCS(
      dup, _else_, N(7),       /* if dtop = 0                */
        drop, _lit_, zero,     /*   change dtop to 'm4zero'  */
        _compile_comma_, exit, /*   append it to XT, exit    */
      dup, one_minus,
      _else_, N(7),            /* else if dtop = 1           */
        drop, _lit_, one,      /*   change dtop to 'm4one'   */
        _compile_comma_, exit, /*   append it to XT, exit    */
#if 0
      dup, two_minus,
      _else_, N(7),            /* else if dtop = 2           */
        drop, _lit_, two,      /*   change dtop to 'm4two'   */
        _compile_comma_, exit, /*   append it to XT, exit    */
      dup, four, equals,
      _if_, N(7),              /* else if dtop = 4           */
        drop, _lit_, four,     /*   change dtop to 'm4four'  */
        _compile_comma_, exit, /*   append it to XT, exit    */
      dup, eight, equals,
      _if_, N(7),              /* else if dtop = 8           */
        drop, _lit_, eight,    /*   change dtop to 'm4eight' */
        _compile_comma_, exit, /*   append it to XT, exit    */
      dup, minus_one, equals,
      _if_, N(7),              /* else if dtop = -1           */
        drop, _lit_, minus_one,/*   change dtop 'm4minus_one' */
        _compile_comma_, exit, /*   append it to XT, exit     */
#endif /* 0 */      
      _lit_,  _lit_,           /* push 'm4_lit_' to dstack   */
      _compile_comma_,         /* append it to XT            */
      _compile_comma_,         /* append dtop to XT          */
      /* _call_, XT(_optimize_),  nothing to optimize        */
      exit
    )
WORD_END(literal)
WORD(lshift,           literal,    DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(max,              lshift,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(min,              max,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(mod,              min,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(negate,           mod,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(nip,              negate,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(or,               nip,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(over,             or,         DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD(r_from,           over,       DSTACK(0,1), RSTACK(1,0), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(rot,              r_from,     DSTACK(3,3), RSTACK(0,0), WORD_PURE)
WORD(rshift,           rot,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(swap,             rshift,     DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD_START(true, swap) /* core ext */
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN(minus_one)   /* true is implemented as minus_one */
    WORD_FUNCS(minus_one, exit)
WORD_END(true)
WORD(unloop,           true,       DSTACK(0,0), RSTACK(2,0), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(xor,              unloop,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)

DICT_BODY(forth, xor)
DICT_END(forth)
