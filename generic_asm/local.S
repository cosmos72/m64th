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

#include "../dispatch/asm.mh"

/* clang-format off */

FUNC_START(_local_0_) /* (local-0) ( -- x ) push 0-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL))
FUNC_END(_local_0_)
FUNC_START(_local_1_) /* (local-1) ( -- x ) push 1-st local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ))
FUNC_END(_local_1_)
FUNC_START(_local_2_) /* (local-2) ( -- x ) push 2-nd local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ2))
FUNC_END(_local_2_)
FUNC_START(_local_3_) /* (local-3) ( -- x ) push 3-rd local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ3))
FUNC_END(_local_3_)
FUNC_START(_local_4_) /* (local-4) ( -- x ) push 4-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ4))
FUNC_END(_local_4_)
FUNC_START(_local_5_) /* (local-5) ( -- x ) push 5-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ5))
FUNC_END(_local_5_)
FUNC_START(_local_6_) /* (local-6) ( -- x ) push 6-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ6))
FUNC_END(_local_6_)
FUNC_START(_local_7_) /* (local-7) ( -- x ) push 7-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ7))
FUNC_END(_local_7_)
FUNC_START(_local_8_) /* (local-8) ( -- x ) push 8-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ8))
FUNC_END(_local_8_)
FUNC_START(_local_9_) /* (local-9) ( -- x ) push 9-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ9))
FUNC_END(_local_9_)
FUNC_START(_local_a_) /* (local-a) ( -- x ) push 10-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ10))
FUNC_END(_local_a_)
FUNC_START(_local_b_) /* (local-b) ( -- x ) push 11-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ11))
FUNC_END(_local_b_)
FUNC_START(_local_c_) /* (local-c) ( -- x ) push 12-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ12))
FUNC_END(_local_c_)
FUNC_START(_local_d_) /* (local-d) ( -- x ) push 13-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ13))
FUNC_END(_local_d_)
FUNC_START(_local_e_) /* (local-e) ( -- x ) push 14-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ14))
FUNC_END(_local_e_)
FUNC_START(_local_f_) /* (local-f) ( -- x ) push 15-th local variable to dstack */
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(LOCL, SZ15))
FUNC_END(_local_f_)


FUNC_START(_to_local_0_) /* (to-local-0) ( x -- ) store dstack top to 1-st local variable */
        STOR(  DTOP,   AT(LOCL))
        DPOP___DTOP()
FUNC_END(_to_local_0_)
FUNC_START(_to_local_1_) /* (to-local-1) ( x -- ) store dstack top to 1-st local variable */
        STOR(  DTOP,   AT(LOCL, SZ))
        DPOP___DTOP()
FUNC_END(_to_local_1_)
FUNC_START(_to_local_2_) /* (to-local-2) ( x -- ) store dstack top to 2-nd local variable */
        STOR(  DTOP,   AT(LOCL, SZ2))
        DPOP___DTOP()
FUNC_END(_to_local_2_)
FUNC_START(_to_local_3_) /* (to-local-3) ( x -- ) store dstack top to 3-rd local variable */
        STOR(  DTOP,   AT(LOCL, SZ3))
        DPOP___DTOP()
FUNC_END(_to_local_3_)
FUNC_START(_to_local_4_) /* (to-local-4) ( x -- ) store dstack top to 4-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ4))
        DPOP___DTOP()
FUNC_END(_to_local_4_)
FUNC_START(_to_local_5_) /* (to-local-5) ( x -- ) store dstack top to 5-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ5))
        DPOP___DTOP()
FUNC_END(_to_local_5_)
FUNC_START(_to_local_6_) /* (to-local-6) ( x -- ) store dstack top to 6-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ6))
        DPOP___DTOP()
FUNC_END(_to_local_6_)
FUNC_START(_to_local_7_) /* (to-local-7) ( x -- ) store dstack top to 7-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ7))
        DPOP___DTOP()
FUNC_END(_to_local_7_)
FUNC_START(_to_local_8_) /* (to-local-8) ( x -- ) store dstack top to 8-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ8))
        DPOP___DTOP()
FUNC_END(_to_local_8_)
FUNC_START(_to_local_9_) /* (to-local-9) ( x -- ) store dstack top to 9-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ9))
        DPOP___DTOP()
FUNC_END(_to_local_9_)
FUNC_START(_to_local_a_) /* (to-local-a) ( x -- ) store dstack top to 10-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ10))
        DPOP___DTOP()
FUNC_END(_to_local_a_)
FUNC_START(_to_local_b_) /* (to-local-b) ( x -- ) store dstack top to 11-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ11))
        DPOP___DTOP()
FUNC_END(_to_local_b_)
FUNC_START(_to_local_c_) /* (to-local-c) ( x -- ) store dstack top to 12-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ12))
        DPOP___DTOP()
FUNC_END(_to_local_c_)
FUNC_START(_to_local_d_) /* (to-local-d) ( x -- ) store dstack top to 13-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ13))
        DPOP___DTOP()
FUNC_END(_to_local_d_)
FUNC_START(_to_local_e_) /* (to-local-e) ( x -- ) store dstack top to 14-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ14))
        DPOP___DTOP()
FUNC_END(_to_local_e_)
FUNC_START(_to_local_f_) /* (to-local-f) ( x -- ) store dstack top to 15-th local variable */
        STOR(  DTOP,   AT(LOCL, SZ15))
        DPOP___DTOP()
FUNC_END(_to_local_f_)
