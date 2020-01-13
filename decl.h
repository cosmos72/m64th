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

#ifndef M4TH_DECL_H
#define M4TH_DECL_H

/**
 * The following functions use m4th calling convention, not C !
 *
 * Do not attempt to invoke them directly from C - the only useful
 * operation is taking their address and appending it to m4th->code
 */

void m4abs(void);               /* abs  */
void m4bye(void);               /* bye  */
void m4c_fetch(void);           /* c@   */
void m4c_store(void);           /* c!   */
void m4do(void);                /* do   */
void m4drop(void);              /* drop */
void m4dup(void);               /* dup  */
void m4equal(void);             /* =    */
void m4fetch(void);             /* @    */
void m4greater_than(void);      /* >    */
void m4i(void);                 /* i    */
void m4i_prime(void);           /* i'   */
void m4less_than(void);         /* <    */
void m4literal(void);           /* must be followed by number */
void m4literal_1(void);         /* -1   */
void m4literal0(void);          /* 0    */
void m4literal1(void);          /* 1    */
void m4loop_(void);             /* must be followed by IP offset to jump (usually < 0) */
void m4j(void);                 /* j    */
void m4max(void);               /* max  */
void m4min(void);               /* min  */
void m4minus(void);             /* -    */
void m4mod(void);               /* mod  */
void m4negate(void);            /* negate */
void m4noop(void);              /* noop */
void m4not_equal(void);         /* <>   */
void m4one_minus(void);         /* 1-   */
void m4one_plus(void);          /* 1+   */
void m4not_equal(void);         /* <>   */
void m4over(void);              /* over */
void m4plus(void);              /* +    */
void m4plus_store(void);        /* +!   */
void m4r_from(void);            /* r>   */
void m4rot(void);               /* rot  */
void m4slash(void);             /* /    */
void m4slash_mod(void);         /* /mod */
void m4star(void);              /* *    */
void m4store(void);             /* !    */
void m4swap(void);              /* swap */
void m4to_r(void);              /* >r   */
void m4two_minus(void);         /* 2-   */
void m4two_plus(void);          /* 2+   */
void m4two_slash(void);         /* 2/   */
void m4two_star(void);          /* 2*   */
void m4unloop(void);            /* unloop */
void m4xor(void);               /* xor  */
void m4zero_equal(void);        /* 0=   */
void m4zero_not_equal(void);    /* 0<>  */
void m4zero_greater_than(void); /* 0>   */
void m4zero_less_than(void);    /* 0<   */

#endif /* M4TH_DECL_H */
