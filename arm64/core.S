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

#include "../dispatch/asm.mh"
#include "../include/dict.mh"
#include "../include/wordlist.mh"

/* clang-format off */


FUNC_START(name_to_asm_n)  /* ( nt -- asm_len true | 0 false ) */
        LD_uh( REG1,   AT(DTOP, WORD_OFF_ASM_LEN)) /* dtop = asm_len    */
        MOVI(0xffff,   REG2)
        cmp    REG1,   REG2;
        csel   REG1,   REG1,   xzr,    ne;
        csetm  DTOP,   ne;
        DPUSH( REG1)
FUNC_END(name_to_asm_n)


FUNC_START(name_to_prev) /* ( nt -- nt'|0 ) */
        LOAD(  REG1,   AT(DTOP, WORD_OFF_PREV_OFF))    /* a = nt.prev_off  */
        SUB2(  REG1,   DTOP)                           /* dtop = nt'       */
        cmp    REG1,   IMM(0);
        csel   DTOP,   DTOP,   xzr,    ne;             /* dtop = nt'|0     */
FUNC_END(name_to_prev)


/* iobuf-empty? ( io -- t|f ) true if iobuf is currently empty */
FUNC_START(iobuf_empty_query)
        LOAD(  REG1,   AT(DTOP, IOBUF_OFF_POS))        /* a = iobuf.pos     */
        LOAD(  REG2,   AT(DTOP, IOBUF_OFF_END))        /* b = iobuf.end    */
        cmp    REG1,   REG2;
        csetm  DTOP,   ge;
FUNC_END(iobuf_empty_query)


FUNC_START(wordlist_to_last) /* ( wid -- nt ) */
        LOAD(  REG1,       AT(DTOP, M4WORDLIST_OFF_LAST))   /* a = nt = wid.last      */
        cmp    REG1,       IMM(0);
        csel   DTOP,       REG1,   DTOP,   ne;              /* dtop = nt|wid          */
        b.ne               FUNC_RET(wordlist_to_last);
        LOAD(  DTOP,       AT(DTOP, M4WORDLIST_OFF_DICT))   /* dtop = wid.dict        */
        LOAD(  REG1_uw,    AT(DTOP, DICT_OFF_LASTWORD_OFF)) /* a = dict.last_word_off */
        SUB2(  REG1,       DTOP)                            /* dtop = nt              */
        cmp    REG1,       IMM(0);
        csel   DTOP,       DTOP,   xzr,    ne;              /* dtop = nt|0            */
FUNC_END(wordlist_to_last)
