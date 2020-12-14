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

#include "../include/dict.mh"
#include "../include/m64th/dict.mh"

/* helper macros to define words {byte,char,short,ushort,int,uint,cell,token}_fetch* */

#define DEF_WORD_FETCH_TYP_OFF(typ, offset, prev_word)                                             \
    WORD(typ##_fetch##offset, prev_word, DSTACK(1, 1), RSTACK(0, 0), WORD_IMPURE | M6FLAG_MEM_FETCH)
#define DEF_WORD_FETCH_TYP(typ, prev_word)                                                         \
    DEF_WORD_FETCH_TYP_OFF(typ, /**/, prev_word)                                                   \
    DEF_WORD_FETCH_TYP_OFF(typ, _1, typ##_fetch)                                                   \
    DEF_WORD_FETCH_TYP_OFF(typ, _2, typ##_fetch_1)                                                 \
    DEF_WORD_FETCH_TYP_OFF(typ, _3, typ##_fetch_2)                                                 \
    DEF_WORD_FETCH_TYP_OFF(typ, _4, typ##_fetch_3)                                                 \
    DEF_WORD_FETCH_TYP_OFF(typ, _5, typ##_fetch_4)                                                 \
    DEF_WORD_FETCH_TYP_OFF(typ, _6, typ##_fetch_5)                                                 \
    DEF_WORD_FETCH_TYP_OFF(typ, _7, typ##_fetch_6)                                                 \
    DEF_WORD_FETCH_TYP_OFF(typ, _8, typ##_fetch_7)
#define DEF_WORD_FETCH(prev_word)                                                                  \
    DEF_WORD_FETCH_TYP(byte, prev_word)                                                            \
    DEF_WORD_FETCH_TYP(char, byte_fetch_8)                                                         \
    DEF_WORD_FETCH_TYP(short, char_fetch_8)                                                        \
    DEF_WORD_FETCH_TYP(ushort, short_fetch_8)                                                      \
    DEF_WORD_FETCH_TYP(int, ushort_fetch_8)                                                        \
    DEF_WORD_FETCH_TYP(uint, int_fetch_8)                                                          \
    DEF_WORD_FETCH_TYP(cell, uint_fetch_8)

#define DEF_WORD_STORE_TYP_OFF(typ, offset, prev_word)                                             \
    WORD(typ##_store##offset, prev_word, DSTACK(2, 0), RSTACK(0, 0), WORD_IMPURE | M6FLAG_MEM_STORE)
#define DEF_WORD_STORE_TYP(typ, prev_word)                                                         \
    DEF_WORD_STORE_TYP_OFF(typ, /**/, prev_word)                                                   \
    DEF_WORD_STORE_TYP_OFF(typ, _1, typ##_store)                                                   \
    DEF_WORD_STORE_TYP_OFF(typ, _2, typ##_store_1)                                                 \
    DEF_WORD_STORE_TYP_OFF(typ, _3, typ##_store_2)                                                 \
    DEF_WORD_STORE_TYP_OFF(typ, _4, typ##_store_3)                                                 \
    DEF_WORD_STORE_TYP_OFF(typ, _5, typ##_store_4)                                                 \
    DEF_WORD_STORE_TYP_OFF(typ, _6, typ##_store_5)                                                 \
    DEF_WORD_STORE_TYP_OFF(typ, _7, typ##_store_6)                                                 \
    DEF_WORD_STORE_TYP_OFF(typ, _8, typ##_store_7)
#define DEF_WORD_STORE(prev_word)                                                                  \
    DEF_WORD_STORE_TYP(char, prev_word)                                                            \
    DEF_WORD_STORE_TYP(short, char_store_8)                                                        \
    DEF_WORD_STORE_TYP(int, short_store_8)                                                         \
    DEF_WORD_STORE_TYP(cell, int_store_8)

/**/

DICT_START(m64th_asm)
DICT_WORDS_M64TH_ASM(WORDNAME)
#include "m64th/asm.S"
#include "m64th/asm_native.S"
DICT_BODY(m64th_asm, LASTWORD)
DICT_END(m64th_asm)

/**/
/**/

DICT_START(m64th_c)
DICT_WORDS_M64TH_C(WORDNAME)
#include "m64th/c.S"
DICT_BODY(m64th_c, LASTWORD)
DICT_END(m64th_c)

/**/

DICT_START(m64th_core)
DICT_WORDS_M64TH_CORE(WORDNAME)
#include "m64th/core.S"
DICT_BODY(m64th_core, LASTWORD)
DICT_END(m64th_core)

/**/

DICT_START(m64th_impl)
DICT_WORDS_M64TH_IMPL(WORDNAME)
#include "m64th/impl.S"
DICT_BODY(m64th_impl, LASTWORD)
DICT_END(m64th_impl)

/**/

DICT_START(m64th_user)
DICT_WORDS_M64TH_USER(WORDNAME)
#include "m64th/user.S"
#include "m64th/user_gen.S"
DICT_BODY(m64th_user, LASTWORD)
DICT_END(m64th_user)
