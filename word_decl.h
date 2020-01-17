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

#ifndef M4TH_WORD_DECL_H
#define M4TH_WORD_DECL_H

#ifdef __cplusplus
extern "C" {
#endif

#include "m4th.h"

/**
 * The following functions use m4th calling convention, not C !
 *
 * Do not attempt to invoke them directly from C - the only useful
 * operation is taking their address and appending it to m4th->code
 */

extern const m4word m4word_store;             /* !    */
extern const m4word m4word__1_;               /* (1)     m4th */
extern const m4word m4word__question_do_;     /* (?do)   m4th */
extern const m4word m4word__call_;            /* (call)  m4th */
extern const m4word m4word__do_;              /* (do)    m4th */
extern const m4word m4word__lit_;             /* (lit)   m4th */
extern const m4word m4word__leave_;           /* (leave) m4th */
extern const m4word m4word__loop_;            /* (loop)  m4th */
extern const m4word m4word_star;              /* *    */
extern const m4word m4word_plus;              /* +    */
extern const m4word m4word_plus_store;        /* +!   */
extern const m4word m4word_minus;             /* -    */
extern const m4word m4word_slash;             /* /    */
extern const m4word m4word_slash_mod;         /* /mod */
extern const m4word m4word_zero_less;         /* 0<   */
extern const m4word m4word_zero_not_equals;   /* 0<>  core ext */
extern const m4word m4word_zero_equals;       /* 0=   */
extern const m4word m4word_zero_greater_than; /* 0>   */
extern const m4word m4word_one_plus;          /* 1+   */
extern const m4word m4word_one_minus;         /* 1-   */
extern const m4word m4word_two_star;          /* 2*   */
extern const m4word m4word_two_plus;          /* 2+   m4th */
extern const m4word m4word_two_minus;         /* 2-   m4th */
extern const m4word m4word_two_slash;         /* 2/   */
extern const m4word m4word_less_than;         /* <    */
extern const m4word m4word_not_equals;        /* <>   core ext */
extern const m4word m4word_equals;            /* =    */
extern const m4word m4word_greater_than;      /* >    */
extern const m4word m4word_to_r;              /* >r   */
extern const m4word m4word_question_dupe;     /* ?dup */
extern const m4word m4word_fetch;             /* @    */
extern const m4word m4word_abs;               /* abs  */
extern const m4word m4word_and;               /* and  */
extern const m4word m4word_bl;                /* bl   */
extern const m4word m4word_bye;               /* bye  tools ext */
extern const m4word m4word_c_store;           /* c!   */
extern const m4word m4word_c_fetch;           /* c@   */
extern const m4word m4word_depth;             /* depth */
extern const m4word m4word_drop;              /* drop */
extern const m4word m4word_dup;               /* dup  */
extern const m4word m4word_false;             /* false i.e. 0 */
extern const m4word m4word_i;                 /* i    */
extern const m4word m4word_i_star;            /* i*   m4th */
extern const m4word m4word_i_plus;            /* i+   m4th */
extern const m4word m4word_i_minus;           /* i-   m4th */
extern const m4word m4word_i_prime;           /* i'   */
extern const m4word m4word_invert;            /* invert  */
extern const m4word m4word_j;                 /* j    */
extern const m4word m4word_literal;           /* literal */
extern const m4word m4word_lshift;            /* lshift  */
extern const m4word m4word_max;               /* max  */
extern const m4word m4word_min;               /* min  */
extern const m4word m4word_mod;               /* mod  */
extern const m4word m4word_negate;            /* negate */
extern const m4word m4word_nip;               /* nip  core ext */
extern const m4word m4word_noop;              /* noop m4th */
extern const m4word m4word_or;                /* or   */
extern const m4word m4word_over;              /* over */
extern const m4word m4word_r_from;            /* r>   */
extern const m4word m4word_rot;               /* rot  */
extern const m4word m4word_rshift;            /* rshift  */
extern const m4word m4word_swap;              /* swap */
extern const m4word m4word_true;              /* true i.e. -1 */
extern const m4word m4word_unloop;            /* unloop */
extern const m4word m4word_xor;               /* xor  */

#ifdef __cplusplus
}
#endif

#endif /* M4TH_WORD_DECL_H */
