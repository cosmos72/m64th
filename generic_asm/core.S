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

/**
  * push to dstack vm's current instruction pointer,
  * i.e. the address of the (ip) m4token itself inside the code being executed
  */
FUNC_START(_ip_)
        DPUSH( DTOP)
        ADDI(  IP, -SZt,   DTOP)       /* IP actually points to next instruction: fix it */
FUNC_END(_ip_)


/**
  * (ip>data) ( -- addr n ) push to dstack the data address and size of word being executed.
  * must be the first instruction in the word's code.
  */
FUNC_START(_ip_to_data_)
        DPUSH( DTOP)
        ADDI(  IP, -SZt,   DTOP)       /* IP actually points to next instruction: fix it */
        LD_uw( REG1_uw,    AT(DTOP, XT_OFF_DATA_OFF)) /* REG1 = xt.data_off        */
        SUB2(  REG1,       DTOP)                      /* DTOP = w.data             */
        DPUSH( DTOP)
        LD_uw( DTOP_uw,    AT(DTOP, WORD_OFF_DATA_N - WORD_OFF_DATA)) /* DTOP = w.data_n */
FUNC_END(_ip_to_data_)


/**
  * (ip>data>addr) ( -- addr ) push to dstack the data address of word being executed.
  * must be the first instruction in the word's code.
  */
FUNC_START(_ip_to_data_addr_)
        DPUSH( DTOP)
        ADDI(  IP, -SZt,   DTOP)       /* IP actually points to next instruction: fix it */
        LD_uw( REG1_uw,    AT(DTOP, XT_OFF_DATA_OFF)) /* REG1 = xt.data_off        */
        SUB2(  REG1,       DTOP)                      /* DTOP = w.data             */
FUNC_END(_ip_to_data_addr_)


#ifndef M4FEX_STRING_STORE
FUNC_START(ex_string_store)
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_EX_STRING_N))
        DPOP(  DTOP)
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_EX_STRING_ADDR))
        DPOP(  DTOP)
FUNC_END(ex_string_store)
#endif /* M4FEX_STRING_STORE */


#ifndef M4FEX_STRING_FETCH
FUNC_START(ex_string_fetch)
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_EX_STRING_ADDR))
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_EX_STRING_N))
FUNC_END(ex_string_fetch)
#endif /* M4FEX_STRING_FETCH */


/* get-current ( -- wid ) forth 'search order' word set */
FUNC_START(get_current)
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_COMPILE_WID))
FUNC_END(get_current)

/* name, ( c-addr u -- ) create a new word */
FUNC_START(name_comma)
        JNZ(   DTOP,   TO(name_comma.str))
        ALIGN( SZ,     HERE)                           /* here = nt               */
        STORh( DTOPh,  AT(HERE, WORD_OFF_NAME_OFF))    /* nt.name_off = 0         */
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(IMM(SZ2), DSTK)                           /* (                     ) */
        JUMP(  TO(name_comma.str_done))
LABEL(name_comma.str)
        RPUSH( RTOP)
        MOVE(  HERE,   RTOP)                           /* save countedstring addr */
        ASM_CALL(      FUNC(countedstring_comma))      /* (                     ) */
        ALIGN( SZ,     HERE)                           /* here = nt               */
        SUB2(  HERE,   RTOP)                           /* rtop = c_addr-nt        */
        STORh( RTOPh,  AT(HERE, WORD_OFF_NAME_OFF))    /* nt.name_off = rtop      */
        RPOP(  RTOP)
LABEL(name_comma.str_done)
        DPUSH( DTOP)                                   /* ( _                   ) */
        ZERO(  REG1w)                                  /* a = 0                   */
        MOVE(  IMM_1,  REG2)                           /* b = -1                  */
        STOR(  REG1,   AT(HERE, WORD_OFF_PREV_OFF))    /* nt.prev_off = nt.flags = 0, clobber nt.eff */
        STOR(  REG2,   AT(HERE, WORD_OFF_STK_EFF))     /* nt.eff = nt.jump = -1 = nt.native_len = -1, clobber nt.code_n */
        STORh( REG1h,  AT(HERE, WORD_OFF_CODE_N))      /* nt.code_n   = 0         */
        STOR(  REG1,   AT(HERE, WORD_OFF_CODE_OFF))    /* nt.code_off = nt.data_n = 0 */
        DPUSH( HERE)                                   /* ( nt _                ) */
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_COMPILE_WID)) /* ( nt wid              ) */
        ADD2(  IMM(WORD_OFF_DATA), HERE)               /* update HERE             */
        JUMP(  FUNC(wordlist_last_store))
FUNC_RAWEND(name_comma)


FUNC_START(name_to_code) /* ( w -- taddr n ) */
        LD_uw( REG1_uw,    AT(DTOP, WORD_OFF_CODE_OFF)) /* REG1 = w.code_off  */
        ADD2(  DTOP,       REG1)                        /* REG1 = w.code      */
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_CODE_N))   /* DTOP = w.code_n    */
        DPUSH( REG1)                                    /*  d2  = w.code      */
FUNC_END(name_to_code)


FUNC_START(name_to_code_n) /* ( nt -- n ) */
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_CODE_N)) /* DTOP = w.code_n    */
FUNC_END(name_to_code_n)


FUNC_START(name_to_flags) /* ( nt -- m4flags ) */
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_FLAGS)) /* dtop = m4flags    */
FUNC_END(name_to_flags)


FUNC_START(name_to_string) /* ( nt -- addr n ) */
        LD_uh( REG1_uh,    AT(DTOP, WORD_OFF_NAME_OFF)) /* a = w.name_off  */
        JNZ(   REG1,       TO(name_to_string.body))
        ZERO(  DTOPw)                  /* dtop = 0               */
        JUMP(              TO(name_to_string.push_reg1))
LABEL(name_to_string.body)
        SUB2(  REG1,       DTOP)       /* dtop = m4countedstring* */
        ADDI(  DTOP,       1,  REG1)   /* a = addr                */
        LD_ub( DTOP_ub,    AT(DTOP))   /* dtop = len              */
LABEL(name_to_string.push_reg1)
        DPUSH( REG1)                   /* d1 = a = addr           */
FUNC_END(name_to_string)


FUNC_START(name_to_xt)     /* ( nt -- xt ) */
        LD_uw( REG1_uw,    AT(DTOP, WORD_OFF_CODE_OFF)) /* a = w.code_off     */
        ADD2(  REG1,       DTOP)                        /* dtop = w.code      */
FUNC_END(name_to_xt)


/* searchorder-i ( u -- addr ) get address of i-th wordlist in search order */
FUNC_START(searchorder_i)
        ADDI(  M4TH, M4TH_OFF_SEARCHORDER, REG1) /* a = &m->searchorder */
        LOAD(  REG2,   AT(REG1))                 /* b = m->searchorder.n */
        SUB2(  DTOP,   REG2)                     /* b = n - i */
        ADD4(  REG1,   REG2, PSZ, DTOP) /* dtop = &a[n-i] = &m->searchorder.addr[n-i-1] */
FUNC_END(searchorder_i)


/* searchorder-n ( -- addr ) get address of searchorder count */
FUNC_START(searchorder_n)
        DPUSH( DTOP)
        ADDI(  M4TH,   M4TH_OFF_SEARCHORDER, DTOP)
FUNC_END(searchorder_n)


/* set-current ( wid -- ) forth 'search order' word set */
FUNC_START(set_current)
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_COMPILE_WID))
        DPOP(  DTOP)
FUNC_END(set_current)


/* user-var ( -- addr ) must be followed by index. get address of i-th user variable  */
FUNC_START(user_var)
        DPUSH( DTOP)
        LD_ut( REG1_ut,    AT(IP)) /* a = index */
#if M4TH_OFF_USER != 0
        ADD2(  IMM(M4TH_OFF_USER/SZ), REG1)
#endif
        ADD4(  M4TH,       REG1, PSZ, DTOP)
        NEXTT()
FUNC_RAWEND(user_var)


FUNC_START(wordlist_last_store) /* ( nt wid -- ) */
#if 0
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_COMPILE_WID)) /* ( wid                 ) */
        ASM_CALL(      FUNC(wordlist_last))            /* ( prevnt              ) */
        JZ(    DTOP,   TO(name_comma.prevnt))
        SUB2(  HERE,   DTOP)                           /* ( prevnt-nt           ) */
#endif /* 0 */
        DPOP(  REG1)                                        /* a    = nt              */
        LOAD(  DTOP,       AT(DTOP, WORDLIST_OFF_DICT))     /* dtop = wid.dict        */
        SUB2(  DTOP,       REG1)                            /* a    = nt-dict         */
        STORw( REG1w,      AT(DTOP, DICT_OFF_LASTWORD_OFF)) /* dict.last_word_off = a */
        DPOP(  DTOP)
FUNC_END(wordlist_last_store)


FUNC_START(xt_to_name)     /* ( XT -- nt ) */
        LD_uw( REG1_uw,    AT(DTOP, XT_OFF_DATA_OFF)) /* REG1 = xt.data_off */
        SUB2(  REG1,       DTOP)                      /* DTOP = w.data      */
        SUB2(  IMM(WORD_OFF_XT), DTOP)                /* DTOP = w           */
FUNC_END(xt_to_name)
