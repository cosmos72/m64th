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


FUNC_START(name_to_prev) /* ( nt -- nt'|0 ) */
        LD_uw( REG1_uw,    AT(DTOP, WORD_OFF_PREV_OFF)) /* a = nt.prev_off  */
        SUB2(  REG1,       DTOP)               /* dtop = nt'               */
        cmp    REG1,       IMM(0);
        csel   DTOP,       DTOP,   xzr,    ne; /* dtop = nt'|0             */
FUNC_END(name_to_prev)


/* iobuf-empty? ( io -- t|f ) true if iobuf is currently empty */
FUNC_START(iobuf_empty_query)
        LOAD(  REG1,   AT(DTOP, IOBUF_OFF_POS))    /* a = iobuf.pos     */
        LOAD(  REG2,   AT(DTOP, IOBUF_OFF_SIZE))   /* b = iobuf.size    */
        cmp    REG1,   REG2;
        csetm  DTOP,   ge;
FUNC_END(iobuf_empty_query)


FUNC_START(wordlist_last) /* ( wid -- nt ) */
        LOAD(  DTOP,       AT(DTOP, WORDLIST_OFF_DICT))     /* dtop = wid.dict        */
        LOAD(  REG1_uw,    AT(DTOP, DICT_OFF_LASTWORD_OFF)) /* a = dict.last_word_off */
        SUB2(  REG1,       DTOP)               /* dtop = nt               */
        cmp    REG1,       IMM(0);
        csel   DTOP,       DTOP,   xzr,    ne; /* dtop = nt|0             */
FUNC_END(wordlist_last)
