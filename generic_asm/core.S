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


/* ( -- addr ) get address of m4th.ex */
FUNC_START(m4th_ex)
        DPUSH( DTOP)
        ADDI(  M4TH,   M4TH_OFF_EX,   DTOP)
FUNC_END(m4th_ex)


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
        ADDI(  M4TH,       M4TH_OFF_SEARCHORDER, DTOP)
FUNC_END(searchorder_n)


FUNC_START(word_to_code) /* ( w -- taddr n ) */
        LD_uw( REG1_uw,    AT(DTOP, WORD_OFF_CODE_OFF)) /* REG1 = w.code_off  */
        ADD2(  DTOP,       REG1)                        /* REG1 = w.code      */
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_CODE_N))   /* DTOP = w.code_n    */
        DPUSH( REG1)                                    /*  d2  = w.code      */
FUNC_END(word_to_code)


/* user-var ( -- addr ) must be followed by index. get address of i-th user variable  */
FUNC_START(user_var)
        DPUSH( DTOP)
        LD_ut( REG1_ut,    AT(IP)) /* a = index */
#ifdef __x86_64__
        lea    M4TH_OFF_USER(M4TH, REG1, SZ), DTOP;
#else
        ADD2(  IMM(M4TH_OFF_USER/SZ), REG1)
        ADD4(  M4TH,       REG1, PSZ, DTOP)
#endif
        NEXTT()
FUNC_RAWEND(user_var)


FUNC_START(word_to_code_n) /* ( w -- n ) */
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_CODE_N)) /* DTOP = w.code_n    */
FUNC_END(word_to_code_n)


FUNC_START(word_to_flags) /* ( w -- m4flags ) */
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_FLAGS)) /* dtop = m4flags    */
FUNC_END(word_to_flags)


FUNC_START(word_to_name) /* ( w -- addr n ) */
        LD_uh( REG1_uh,    AT(DTOP, WORD_OFF_NAME_OFF)) /* a = w.name_off  */
        JNZ(   REG1,       TO(word_to_name.body))
        ZERO(  DTOPw)                  /* dtop = 0               */
        JUMP(              TO(word_to_name.push_reg1))
LABEL(word_to_name.body)
        SUB2(  REG1,       DTOP)       /* dtop = m4countedstring* */
        ADDI(  DTOP,       1,  REG1)   /* a = addr                */
        LD_ub( DTOP_ub,    AT(DTOP))   /* dtop = len              */
LABEL(word_to_name.push_reg1)
        DPUSH( REG1)                   /* d1 = a = addr           */
FUNC_END(word_to_name)


FUNC_START(word_to_xt) /* ( w -- xt ) */
        LD_uw( REG1_uw,    AT(DTOP, WORD_OFF_CODE_OFF)) /* a = w.code_off     */
        ADD2(  REG1,       DTOP)                        /* dtop = w.code      */
FUNC_END(word_to_xt)


FUNC_START(xt_to_word) /* ( XT -- w ) */
        LD_uw( REG1_uw,    AT(DTOP, XT_OFF_DATA_OFF)) /* REG1 = xt.data_off */
        SUB2(  REG1,       DTOP)                      /* DTOP = w.data      */
        SUB2(  IMM(WORD_OFF_DATA), DTOP)              /* DTOP = w           */
FUNC_END(xt_to_word)
