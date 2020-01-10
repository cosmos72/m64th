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

void m4th_at(void);
void m4th_bye(void);
void m4th_drop(void);
void m4th_dup(void);
void m4th_literal(void);
void m4th_minus(void);
void m4th_mod(void);
void m4th_noop(void);
void m4th_over(void);
void m4th_plus(void);
void m4th_rot(void);
void m4th_slash(void);
void m4th_slash_mod(void);
void m4th_star(void);
void m4th_swap(void);

#endif /* M4TH_DECL_H */
