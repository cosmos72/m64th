/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

/* clang-format off */

DICT_WORDS_FORTH_TOOLS_EXT(WORDNAME)

WORD_START(ahead,      LASTWORD)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE)
    WORD_CODE(_compile_jump_lit_, _ahead_, _ahead_, exit)
WORD_END(ahead)
WORD_START(bye,        ahead)
    WORD_DSTACK(0,-1)  /* data   stack may be altered from outside */
    WORD_RSTACK(0,-1)  /* return stack may be altered from outside */
    WORD_DSTACK(0,-1)
    WORD_RSTACK(0,-1)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MAY_JUMP)
    WORD_CODE(bye, exit) /* exit is reachable by subsequent m64th_run() */
WORD_END(bye)
WORD_START(cs_pick,    bye)
    WORD_DSTACK(1,2) /* DSTACK(x+1,x+2) */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_LEN(two_pick)
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_COMPILE_ONLY)
    WORD_CODE(cs_pick, exit)
WORD_END(cs_pick)
WORD_START(cs_roll,    cs_pick)
    WORD_DSTACK(1,0) /* DSTACK(x+1,x) */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses %rip-relative TOKEN_CALL_NOTHROW */
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_COMPILE_ONLY)
    WORD_CODE(cs_roll, exit)
WORD_END(cs_roll)
WORD(name_to_string,   cs_roll,  DSTACK(1,2), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)

#undef LASTWORD
#define LASTWORD name_to_string
