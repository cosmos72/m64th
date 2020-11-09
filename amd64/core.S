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
#include "../include/dict.mh"
#include "../include/wordlist.mh"

/* clang-format off */

#define M4FEX_STRING_STORE
FUNC_START(ex_message_store)
        LOAD(  REG1,   AT(DSTK))
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_EX_STRING_N))
        STOR(  REG1,   AT(M4TH, M4TH_OFF_EX_STRING_ADDR))
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(IMM(SZ2), DSTK)
FUNC_END(ex_message_store)


#define M4FEX_STRING_FETCH
FUNC_START(ex_message_fetch)
        STOR(  DTOP,   AT(DSTK, -SZ))
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_EX_STRING_ADDR))
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_EX_STRING_N))
        STOR(  REG1,   AT(DSTK, -SZ2))
        SUB2(IMM(SZ2), DSTK)
FUNC_END(ex_message_fetch)


/* iobuf-empty? ( io -- t|f ) true if iobuf is currently empty */
FUNC_START(iobuf_empty_query)
        LOAD(  REG1,   AT(DTOP, IOBUF_OFF_POS))        /* a = iobuf.pos          */
        LOAD(  REG2,   AT(DTOP, IOBUF_OFF_END))        /* b = iobuf.end         */
        ZERO(  DTOP)
        cmp    REG2,   REG1;
        cmovge RFFF,   DTOP;
FUNC_END(iobuf_empty_query)


FUNC_START(name_to_prev) /* ( nt -- nt'|0 ) */
        LOAD(  REG1,   AT(DTOP, WORD_OFF_PREV_OFF))    /* a = w.prev_off         */
        SUB2(  REG1,   DTOP)                           /* dtop = nt'             */
        test   REG1,   REG1;
        cmovz  REG1,   DTOP;                           /* dtop = nt'|0           */
FUNC_END(name_to_prev)


FUNC_START(wordlist_last) /* ( wid -- nt ) */
        LOAD(  REG1,   AT(DTOP, M4WORDLIST_OFF_LAST))    /* b = nt = wid.last      */
        test   REG1,   REG1;
        cmovnz REG1,   DTOP;                           /* dtop = nt|wid          */
        jnz            FUNC_RET(wordlist_last);
        LOAD(  DTOP,   AT(DTOP, M4WORDLIST_OFF_DICT))    /* dtop = wid.dict        */
        LD_uw( REG1,   AT(DTOP, DICT_OFF_LASTWORD_OFF))/* a = dict.last_word_off */
        SUB2(  REG1,   DTOP)                           /* dtop = nt              */
        test   REG1,   REG1;
        cmovz  REG1,   DTOP;                           /* dtop = nt|0            */
FUNC_END(wordlist_last)
