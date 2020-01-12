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

#include "asm.h"


FUNC_START(m4abs)
        /* TODO */
FUNC_END(m4abs)


FUNC_START(m4c_fetch) /* c@ */
        ldrb DTOPw, [DTOP];
FUNC_END(m4c_store)


FUNC_START(m4c_store) /* c! */
        DPOP(REG1)
        strb REG1w, [DTOP];
        DPOP(DTOP)
FUNC_END(m4c_store)


FUNC_START(m4equal)   /* = */
        /* TODO */
FUNC_END(m4equal)


FUNC_START(m4greater_equal_than)   /* >= */
        /* TODO */
FUNC_END(m4less_than)


FUNC_START(m4greater_than)   /* > */
        /* TODO */
FUNC_END(m4less_than)


FUNC_START(m4less_equal_than)   /* <= */
        /* TODO */
FUNC_END(m4less_than)


FUNC_START(m4less_than)   /* < */
        /* TODO */
FUNC_END(m4less_than)


FUNC_START(m4max)
        /* TODO */
FUNC_END(m4min)


FUNC_START(m4min)
        /* TODO */
FUNC_END(m4min)
        
/* mod is unsigned remainder */
FUNC_START(m4mod)
        /* TODO */
FUNC_END(m4mod)


FUNC_START(m4not_equal)   /* <> */
        /* TODO */
FUNC_END(m4not_equal)


FUNC_START(m4slash) /* / */
        DPOP(REG1)
        DIV3(REG1, DTOP, DTOP)
FUNC_END(m4slash)

/* /mod is signed divide & remainder */
FUNC_START(m4slash_mod)
        /* TODO */
FUNC_END(m4slash_mod)


FUNC_START(m4two_slash) /* 2/ */
        add  DTOP, DTOP, DTOP, lsr IMM(63)
        asr  DTOP, DTOP, IMM(1)
FUNC_END(m4two_slash)


FUNC_START(m4two_star) /* 2* */
        lsl  DTOP, DTOP, IMM(1)
FUNC_END(m4two_star)


FUNC_START(m4zero_equal)   /* 0= */
        /* TODO */
FUNC_END(m4equal)


FUNC_START(m4zero_greater_than)   /* 0> */
        /* TODO */
FUNC_END(m4equal)


FUNC_START(m4zero_less_than)   /* 0< */
        asr   DTOP, DTOP, IMM(63)
FUNC_END(m4equal)
