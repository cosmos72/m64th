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

void m4at(void);
void m4bye(void);
void m4drop(void);
void m4dup(void);
void m4literal(void);
void m4minus(void);
void m4mod(void);
void m4noop(void);
void m4over(void);
void m4plus(void);
void m4rot(void);
void m4slash(void);
void m4slash_mod(void);
void m4star(void);
void m4swap(void);

#endif /* M4TH_DECL_H */
