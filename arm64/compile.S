/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
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

#include "../include/err.mh"
#include "asm.mh"

/* clang-format off */

#define M4FC_COMMA
FUNC_START(c_comma)        /* c,   */
        strb   DTOPb,      [HERE], 1;
        DPOP(  DTOP)
FUNC_END(c_comma)


#define M4FSHORT_COMMA
FUNC_START(short_comma)    /* short,   m4th-user */
        strh   DTOPh,      [HERE], 2;
        DPOP(  DTOP)
FUNC_END(short_comma)


#define M4FINT_COMMA
FUNC_START(int_comma)      /* int,     m4th-user */
        str    DTOPw,      [HERE], 4;
        DPOP(  DTOP)
FUNC_END(int_comma)


#define M4FCOMMA
FUNC_START(comma)          /* ,    */
        str    DTOP,       [HERE], SZ;
        DPOP(  DTOP)
FUNC_END(comma)
