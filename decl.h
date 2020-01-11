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

void m4abs(void);
void m4at(void);          /* @    */
void m4bye(void);
void m4drop(void);
void m4dup(void);
void m4literal(void);
void m4i(void);
void m4i_prime(void);     /* i'   */
void m4j(void);
void m4max(void);
void m4min(void);
void m4minus(void);       /* -    */
void m4mod(void);
void m4negate(void);
void m4noop(void);
void m4one_minus(void);   /* 1-   */
void m4one_plus(void);    /* 1+   */
void m4over(void);
void m4plus(void);        /* +    */
void m4r_from(void);      /* r>   */
void m4rot(void);
void m4slash(void);       /* /    */
void m4slash_mod(void);   /* /mod */
void m4star(void);        /* *    */
void m4swap(void);
void m4to_r(void);        /* >r   */
void m4two_minus(void);   /* 2-   */
void m4two_plus(void);    /* 2+   */
void m4two_slash(void);   /* 2/   */
void m4two_star(void);    /* 2*   */

#endif /* M4TH_DECL_H */
