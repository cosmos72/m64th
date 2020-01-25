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
WORD(to_r,             more,       DSTACK(1,0), RSTACK(0,1), WORD_PURE | M4FLAG_COMPILE_ONLY)
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
    WORD_NATIVE_NONE()
    /* exit is reachable by subsequent m4th_run() */
    WORD_ENUMS(bye, exit)
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
   WORD_NATIVE_NONE()
   WORD_ENUMS(_lit_enum_, _call_, _compile_enum_, /* compile (call) */
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
WORD_START(exit, dup)
   WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_INLINE_ALWAYS | M4FLAG_JUMP)
   WORD_DSTACK(0,-1)
   WORD_RSTACK(0,-1) /* we do not yet track the return address pushed (call) */
   WORD_NATIVE_NONE()
   /* make inliner happy: it skips the final 'exit' of a word's code when inlining */
   WORD_ENUMS(exit, exit)
WORD_END(exit)
WORD_START(false, exit)        /* core ext */
    WORD_FLAGS(WORD_PURE)
    WORD_DSTACK(0,1)
    WORD_RSTACK(0,0)
    WORD_NATIVE_LEN(zero)      /* false is implemented as zero */
    WORD_ENUMS(zero, exit)
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
    WORD_ENUMS(
      dup, _else_, E(7),           /* if dtop = 0                  */
        drop, _lit_enum_, zero,    /*   change dtop to 'm4zero'    */
        _compile_enum_, exit,      /*   append it to XT, exit      */
      dup, one_minus,
      _else_, E(7),                /* else if dtop = 1             */
        drop, _lit_enum_, one,     /*   change dtop to 'm4one'     */
        _compile_enum_, exit,      /*   append it to XT, exit      */
#if 0
      dup, two_minus,
      _else_, E(7),                /* else if dtop = 2             */
        drop, _lit_enum_, two,     /*   change dtop to 'm4two'     */
        _compile_enum_, exit,      /*   append it to XT, exit      */
      dup, four, equal,
      _if_, E(7),                  /* else if dtop = 4             */
        drop, _lit_enum_, four,    /*   change dtop to 'm4four'    */
        _compile_enum_, exit,      /*   append it to XT, exit      */
      dup, eight, equal,
      _if_, E(7),                  /* else if dtop = 8             */
        drop, _lit_enum_, eight,   /*   change dtop to 'm4eight'   */
        _compile_enum_, exit,      /*   append it to XT, exit      */
      dup, minus_one, equal,
      _if_, E(7),                      /* else if dtop = -1            */
        drop, _lit_enum_, minus_one,   /*   change dtop 'm4minus_one'  */
        _compile_enum_, exit,          /*   append it to XT, exit      */
#endif /* 0 */      
      _lit_enum_,  _lit_cell_,     /* push 'm4_lit_cell_' to dstack*/
      _compile_enum_,              /* append it to XT              */
      _compile_cell_,              /* append dtop to XT            */
      /* _call_, XT(_optimize_),  nothing to optimize          */
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
    WORD_ENUMS(minus_one, exit)
WORD_END(true)
WORD(unloop,           true,       DSTACK(0,0), RSTACK(2,0), WORD_PURE | M4FLAG_COMPILE_ONLY)
WORD(xor,              unloop,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)

DICT_BODY(forth, xor)
DICT_END(forth)
