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

#ifndef M4TH_M4TH_MACRO_H
#define M4TH_M4TH_MACRO_H

/* macros that are part of m4th public API */

#define M4FLAG_IMMEDIATE (1 << 0)     /* word has interpretation semantics */
#define M4FLAG_INLINE (1 << 1)        /* can inline forth code of word     */
#define M4FLAG_INLINE_NATIVE (1 << 2) /* can inline native code of word    */

#endif /* M4TH_M4TH_MACRO_H */
