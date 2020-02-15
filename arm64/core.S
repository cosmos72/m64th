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

#include "../include/dict.mh"
#include "../include/wordlist.mh"
#include "asm.mh"

/* clang-format off */


FUNC_START(word_to_prev) /* ( w -- w'|0 ) */
        LD_uw( REG1_uw,    AT(DTOP, WORD_OFF_PREV_OFF)) /* a = w.prev_off  */
        SUB2(  REG1,       DTOP)               /* dtop = w'               */
        cmp    REG1,       IMM(0);
        csel   DTOP,       DTOP,   xzr,    ne; /* dtop = w'|0             */
FUNC_END(word_to_prev)


FUNC_START(wordlist_last) /* ( l -- w ) */
        LOAD(  DTOP,       AT(DTOP, WORDLIST_OFF_DICT))     /* dtop = dict            */
        LOAD(  REG1_uw,    AT(DTOP, DICT_OFF_LASTWORD_OFF)) /* a = dict.last_word_off */
        SUB2(  REG1,       DTOP)               /* dtop = w                */
        cmp    REG1,       IMM(0);
        csel   DTOP,       DTOP,   xzr,    ne; /* dtop = w|0             */
FUNC_END(wordlist_last)