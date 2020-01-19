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

#ifndef M4TH_FUNC_FWD_H
#define M4TH_FUNC_FWD_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct m4arg_s m4arg; /* intentionally incomplete type, cannot be instantiated */

/**
 * The following functions use m4th calling convention, not C !
 *
 * Do not attempt to invoke them directly from C - the only useful
 * operation from C is taking their address and appending it to m4th->code
 */

void m4store(m4arg _); /* !    */
/* (?do) m4th: must be followed by IP offset of 1st instruction after (loop) */
void m4_question_do_(m4arg _);
void m4_call_(m4arg _); /* (call) m4th: must be followed by IP of forth function */
void m4_do_(m4arg _);   /* (do)   m4th     */
void m4_lit_(m4arg _);  /* (lit)  m4th: must be followed by number */
/* (leave) m4th: must be followed by IP offset of 1st instruction after (loop) */
void m4_leave_(m4arg _);
/* (loop) m4th: must be followed by IP offset of 1st instruction after (do) */
void m4_loop_(m4arg _);
void m4star(m4arg _);              /* *    */
void m4plus(m4arg _);              /* +    */
void m4plus_store(m4arg _);        /* +!   */
void m4minus(m4arg _);             /* -    */
void m4minus_one(m4arg _);         /* -1   m4th */
void m4slash(m4arg _);             /* /    */
void m4slash_mod(m4arg _);         /* /mod */
void m4zero(m4arg _);              /* 0    m4th */
void m4zero_less(m4arg _);         /* 0<   */
void m4zero_not_equals(m4arg _);   /* 0<>  core ext */
void m4zero_equals(m4arg _);       /* 0=   */
void m4zero_greater_than(m4arg _); /* 0>   */
void m4one(m4arg _);               /* 1    m4th */
void m4one_plus(m4arg _);          /* 1+   */
void m4one_minus(m4arg _);         /* 1-   */
void m4two(m4arg _);               /* 2    m4th */
void m4two_star(m4arg _);          /* 2*   */
void m4two_plus(m4arg _);          /* 2+   m4th */
void m4two_minus(m4arg _);         /* 2-   m4th */
void m4two_slash(m4arg _);         /* 2/   */
void m4less_than(m4arg _);         /* <    */
void m4not_equals(m4arg _);        /* <>   core ext */
void m4equals(m4arg _);            /* =    */
void m4greater_than(m4arg _);      /* >    */
void m4to_r(m4arg _);              /* >r   */
void m4question_dupe(m4arg _);     /* ?dup */
void m4fetch(m4arg _);             /* @    */
void m4abs(m4arg _);               /* abs  */
void m4and(m4arg _);               /* and  */
void m4bl(m4arg _);                /* bl   */
void m4bye(m4arg _);               /* bye  tools ext */
void m4c_store(m4arg _);           /* c!   */
void m4c_fetch(m4arg _);           /* c@   */
void m4cell_plus(m4arg _);         /* cell+   */
void m4cells(m4arg _);             /* cells   */
#define m4char_plus m4one_plus     /* char+   */
#define m4chars m4noop             /* chars   */
void m4depth(m4arg _);             /* depth   */
void m4drop(m4arg _);              /* drop */
void m4dup(m4arg _);               /* dup  */
void m4exit(m4arg _);              /* exit */
#define m4false m4zero             /* false   */
void m4i(m4arg _);                 /* i    */
void m4i_star(m4arg _);            /* i*   m4th */
void m4i_plus(m4arg _);            /* i+   m4th */
void m4i_minus(m4arg _);           /* i-   m4th */
void m4i_prime(m4arg _);           /* i'   */
void m4invert(m4arg _);            /* invert  */
void m4j(m4arg _);                 /* j    */
void m4literal(m4arg _);           /* literal */
void m4lshift(m4arg _);            /* lshift  */
void m4max(m4arg _);               /* max  */
void m4min(m4arg _);               /* min  */
void m4mod(m4arg _);               /* mod  */
void m4negate(m4arg _);            /* negate */
void m4nip(m4arg _);               /* nip  core ext */
void m4noop(m4arg _);              /* noop m4th */
void m4or(m4arg _);                /* or   */
void m4over(m4arg _);              /* over */
void m4r_from(m4arg _);            /* r>   */
void m4rot(m4arg _);               /* rot  */
void m4rshift(m4arg _);            /* rshift  */
void m4swap(m4arg _);              /* swap */
#define m4true m4minus_one         /* true */
void m4unloop(m4arg _);            /* unloop */
void m4xor(m4arg _);               /* xor  */

#ifdef __cplusplus
}
#endif

#endif /* M4TH_FUNC_FWD_H */
