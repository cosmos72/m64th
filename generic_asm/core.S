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

/* clang-format off */

/**
  * push to dstack vm's current instruction pointer,
  * i.e. the address of the (ip) m6token itself inside the code being executed
  */
FUNC_START(_ip_)
        DPUSH__DTOP()
        ADDI(  IP, -SZt,   DTOP)       /* IP actually points to next instruction: fix it */
FUNC_END(_ip_)


/**
  * (ip>data) ( -- addr n ) push to dstack the data address and size of word being executed.
  * must be the first instruction in the word's code.
  */
FUNC_START(_ip_to_data_)
        ADDI(  IP, -SZt-WORD_OFF_XT,  REG1)           /* a = w                       */
        ADDI(  IP, -SZt,   REG2)                      /* b = w.code                  */
        DPUSH__DTOP()
        LD_uh( REG3,       AT(REG1, WORD_OFF_CODE_N)) /* c = w.code_n                */
        LD_uw( DTOP,       AT(REG1, WORD_OFF_DATA_N)) /* dtop = w.data_n             */
        ADD4(  REG2, REG3, PSZt,   REG2)              /* b = w.code + w.code_n       */
        ALIGN( SZ,         REG2)                      /* b = w.data                  */
        DPUSH( REG2)
FUNC_END(_ip_to_data_)


/**
  * (ip>data>addr) ( -- addr ) push to dstack the data address of word being executed.
  * must be the first instruction in the word's code.
  */
FUNC_START(_ip_to_data_addr_)
        ADDI(  IP, -SZt-WORD_OFF_XT,  REG1)           /* a = w                       */
        DPUSH__DTOP()
        ADDI(  IP, -SZt,   DTOP)                      /* dtop = w.code               */
        LD_uh( REG3,       AT(REG1, WORD_OFF_CODE_N)) /* c = w.code_n                */
        ADD4(  DTOP, REG3, PSZt,   DTOP)              /* dtop = w.code + w.code_n    */
        ALIGN( SZ,         DTOP)                      /* dtop = w.data               */
FUNC_END(_ip_to_data_addr_)


/**
  * get address and count of countedtokens
  * ( counted-tokens -- tok-addr u )
 */
FUNC_START(count_tokens)
        ADDI(  DTOP,   SZt,    REG1)                  /* a = tok-addr                */
        LD_ut( DTOP,   AT(DTOP))                      /* dtop = u                    */
        DPUSH( REG1)                                  /* ( tok-addr u              ) */
FUNC_END(count_tokens)


#ifndef M6FEX_STRING_STORE
FUNC_START(ex_message_store)
        STOR(  DTOP,   AT(M64TH, M64TH_OFF_EX_STRING_N))
        DPOP___DTOP()
        STOR(  DTOP,   AT(M64TH, M64TH_OFF_EX_STRING_ADDR))
        DPOP___DTOP()
FUNC_END(ex_message_store)
#endif /* M6FEX_STRING_STORE */


#ifndef M6FEX_STRING_FETCH
FUNC_START(ex_message_fetch)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M64TH, M64TH_OFF_EX_STRING_ADDR))
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M64TH, M64TH_OFF_EX_STRING_N))
FUNC_END(ex_message_fetch)
#endif /* M6FEX_STRING_FETCH */


/* flags>consumed-tokens ( flags -- u ) get # consumed tokens from flags */
FUNC_START(flags_to_consumed_tokens)
#ifdef __aarch64__
        MOVI(  M6FLAG_CONSUMES_IP_MASK,        REG1)
        AND2(  REG1,   DTOP)
#else
        AND2(  IMM(M6FLAG_CONSUMES_IP_MASK),   DTOP)
#endif
/* LABEL(flags_to_consumed_tokens.2) */
        JNE(   DTOP,   IMM(M6FLAG_CONSUMES_IP_2),  TO(flags_to_consumed_tokens.4))
        MOVI(  2/SZt,  DTOP)
        JUMP(  FUNC_RET(flags_to_consumed_tokens))
LABEL(flags_to_consumed_tokens.4)
        JNE(   DTOP,   IMM(M6FLAG_CONSUMES_IP_4),  TO(flags_to_consumed_tokens.8))
        MOVI(  4/SZt,  DTOP)
        JUMP(  FUNC_RET(flags_to_consumed_tokens))
LABEL(flags_to_consumed_tokens.8)
        JNE(   DTOP,   IMM(M6FLAG_CONSUMES_IP_8),  TO(flags_to_consumed_tokens.0))
        MOVI(  8/SZt,  DTOP)
        JUMP(  FUNC_RET(flags_to_consumed_tokens))
LABEL(flags_to_consumed_tokens.0)
        ZERO(  DTOP)
FUNC_END(flags_to_consumed_tokens)


/* get-current ( -- wid ) forth 'search order' word set */
FUNC_START(get_current)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M64TH, M64TH_OFF_COMPILE_WID))
FUNC_END(get_current)


/* name, ( c-addr u -- nt ) create a new name. do NOT add it to compilation wordlist */
FUNC_START(name_comma)
        JNZ(   DTOP,   TO(name_comma.str))
        ALIGN( SZ,     HERE)                           /* here = w                */
        ADD2(  IMM(SZ),DSTK)                           /* ( 0                   ) */
        JUMP(  TO(name_comma.str_done))
LABEL(name_comma.str)
        LOAD(  REG1,   AT(DSTK))                       /* a = c-addr              */
        STOR(  HERE,   AT(DSTK))                       /* ( addr u              ) */
        DPUSH2(REG1,   DTOP)                           /* ( addr c-addr u u     ) */
        DPUSH( REG1)                                   /* ( addr c-addr u c-addr u ) */
        /* prepare word>name */
        TOKEN_CALL_NOTHROW(FUNC(countedstring_comma), name_comma.0) /* ( addr c-addr u       ) */
        /* prepare word>ident */
        TOKEN_CALL_NOTHROW(FUNC(countedstring_comma), name_comma.1) /* ( addr                ) */
        ALIGN( SZ,     HERE)                           /* here = w                */
        XSUB2( HERE,   DTOP)                           /* dtop = w - addr         */
LABEL(name_comma.str_done)                             /* ( addr                ) */
        init_R000_REG1()                               /* a = 0                   */
        init_RFFF_REG2()                               /* b = -1                  */
        STOR(  R000_REG1,  AT(HERE, WORD_OFF_PREV_OFF))/* w.prev_off = 0          */
        STOR(  RFFF_REG2,  AT(HERE, WORD_OFF_NAME_OFF))/* w.name_off = nt.eff = nt.jump = nt.asm_len = -1 */
        STORh( DTOP,       AT(HERE, WORD_OFF_NAME_OFF))/* w.name_off = dtop       */
        STOR(  R000_REG1,  AT(HERE, WORD_OFF_FLAGS))   /* w.flags = w.code_n = w.data_n = 0 */
        MOVE(  HERE,       DTOP)                       /* ( w                   ) */
        ADD2(  IMM(WORD_OFF_XT), HERE)                 /* here = w.code           */
FUNC_END(name_comma)


FUNC_START(name_to_asm_n_store)  /* ( asm_len nt -- ) */
        DPOP(  REG1)                                   /* a = asm_len */
        STORh( REG1,       AT(DTOP, WORD_OFF_ASM_LEN))
        DPOP___DTOP()
FUNC_END(name_to_asm_n_store)


FUNC_START(name_to_code)   /* ( nt -- xt u ) */
        ADDI(  DTOP,       WORD_OFF_XT,   REG1)        /* a = w.code         */
        LD_uh( DTOP,       AT(DTOP, WORD_OFF_CODE_N))  /* dtop = w.code_n    */
        DPUSH( REG1)                                   /* d2   = w.code      */
FUNC_END(name_to_code)


FUNC_START(name_to_code_n) /* ( nt -- u ) */
        LD_uh( DTOP,       AT(DTOP, WORD_OFF_CODE_N))  /* DTOP = w.code_n    */
FUNC_END(name_to_code_n)


FUNC_START(name_to_code_n_store) /* ( u nt -- ) */
        DPOP(  REG1)                                   /* a = code_n         */
        STORh( REG1,       AT(DTOP, WORD_OFF_CODE_N))  /* w.code_n = a       */
        DPOP___DTOP()
FUNC_END(name_to_code_n_store)


FUNC_START(name_to_data)   /* ( nt -- addr u ) */
        ADDI(  DTOP,       WORD_OFF_XT,   REG1)        /* a = w.code         */
        LD_uh( REG2,       AT(DTOP, WORD_OFF_CODE_N))  /* b = w.code_n       */
        ADD4(  REG1,       REG2, PSZt,    REG2)        /* b = w.code + w.code_n */
        ALIGN( SZ,         REG2)                       /* b = w.data         */
        LD_uw( DTOP,       AT(DTOP, WORD_OFF_DATA_N))  /* dtop = w.data_n    */
        DPUSH( REG2)                                   /* ( addr u         ) */
FUNC_END(name_to_data)


/* followed by NT. return its data>addr */
FUNC_START(_lit_nt_body_)
        DPUSH__DTOP()
        LOAD(  DTOP,       AT(IP))
        ADD2(IMM(SZ),      IP)

FUNC_START_NESTED(name_to_data_addr)  /* ( nt -- addr ) */
        ADDI(  DTOP,       WORD_OFF_XT,   REG1)        /* a    = w.code         */
        LD_uh( DTOP,       AT(DTOP, WORD_OFF_CODE_N))  /* dtop = w.code_n       */
        ADD4(  REG1,       DTOP, PSZt,    DTOP)        /* dtop = w.code + w.code_n */
        ALIGN( SZ,         DTOP)                       /* dtop = w.data         */
FUNC_END_NESTED(name_to_data_addr)
FUNC_END(_lit_nt_body_)


/* set m6word.data_n of specified word */
FUNC_START(name_to_data_n_store) /* ( u nt -- ) */
        DPOP(  REG1)                                   /* a = u            */
        STORw( REG1,       AT(DTOP, WORD_OFF_DATA_N))  /* w.data_n = u     */
        DPOP___DTOP()
FUNC_END(name_to_data_n_store)


FUNC_START(name_to_flags)  /* ( nt -- m6flags ) */
        LD_uh( DTOP,       AT(DTOP, WORD_OFF_FLAGS)) /* dtop = m6flags    */
FUNC_END(name_to_flags)


FUNC_START(name_to_flags_store)    /* ( m6flags nt -- ) */
        DPOP(  REG1)                                 /* a = m6flags          */
        STORh( REG1,       AT(DTOP, WORD_OFF_FLAGS)) /* w.flags = m6flags    */
        DPOP___DTOP()
FUNC_END(name_to_flags_store)


FUNC_START(name_to_ident) /* ( nt -- c-addr u ) */
        TOKEN_CALL_NOTHROW(FUNC(name_to_string), name_to_ident.0)
        LOAD(  REG1,       AT(DSTK))   /* a = name.addr           */
        JZ(    REG1,       FUNC_RET(name_to_ident))
        ADD2(  REG1,       DTOP)       /* dtop = m6countedstring* */
        ADDI(  DTOP,       1,  REG1)   /* a = ident.addr          */
        LD_ub( DTOP,       AT(DTOP))   /* dtop = ident.len        */
        STOR(  REG1,       AT(DSTK))
FUNC_END(name_to_ident)


FUNC_START(name_to_string) /* ( nt -- c-addr u ) forth-tools */
        LD_uh( REG1,       AT(DTOP, WORD_OFF_NAME_OFF)) /* a = w.name_off  */
        JNZ(   REG1,       TO(name_to_string.body))
        ZERO(  DTOP)                   /* dtop = 0                */
        JUMP(              TO(name_to_string.push_reg1))
LABEL(name_to_string.body)
        SUB2(  REG1,       DTOP)       /* dtop = m6countedstring* */
        ADDI(  DTOP,       1,  REG1)   /* a = addr                */
        LD_ub( DTOP,       AT(DTOP))   /* dtop = len              */
LABEL(name_to_string.push_reg1)
        DPUSH( REG1)                   /* d1 = a = addr           */
FUNC_END(name_to_string)


FUNC_START(name_to_xt)     /* ( nt -- xt ) */
        ADD2(  IMM(WORD_OFF_XT), DTOP)         /* dtop = w.code = xt   */
FUNC_END(name_to_xt)


/* searchorder-clear ( SO: wid_u-1 .. wid_0 -- ) clear searchorder list */
FUNC_START(searchorder_clear)
        ZERO(  REG1)
        STOR(  REG1,   AT(M64TH,    M64TH_OFF_SEARCHORDER))
FUNC_END(searchorder_clear)


/* searchorder-depth ( -- u ) get length of searchorder list */
FUNC_START(searchorder_depth)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M64TH,    M64TH_OFF_SEARCHORDER))
FUNC_END(searchorder_depth)


/* searchorder-drop ( SO: wid -- ) remove first element from searchorder list */
FUNC_START(searchorder_drop)
        LOAD(  REG2,   AT(M64TH,M64TH_OFF_SEARCHORDER))/* b = searchorder.n   */
        ADDI(  M64TH,   M64TH_OFF_SEARCHORDER, REG1) /* a = &m->searchorder */
        MOVI(  M6ERR_WORDLIST_OVERFLOW,    REG0)
        JZ(    REG2,   FUNC(_throw_reg0_))
        DEC1(  REG2)                               /* b = searchorder.n-1 */
        STOR(  REG2,   AT(REG1))
FUNC_END(searchorder_drop)


/* searchorder-dup ( SO: wid -- wid wid ) duplicate first element of searchorder list */
FUNC_START(searchorder_dup)
        LOAD(  REG2,   AT(M64TH,M64TH_OFF_SEARCHORDER))/* b = searchorder.n   */
        ADDI(  M64TH,   M64TH_OFF_SEARCHORDER, REG1) /* a = &m->searchorder */
        MOVI(  M6ERR_WORDLIST_OVERFLOW,    REG0)
        JAE(   REG2,   IMM(M64TH_SEARCHORDER_MAX),  FUNC(_throw_reg0_))
        /*
         * if searchorder.n == 0 we read c = wid = searchorder->addr[-1]
         * i.e. searchorder.n which is zero. good.
         */
        LOAD(  REG3,   AT(REG1,REG2,SZ))           /* c = wid             */
        INC1(  REG2)                               /* b = searchorder.n+1 */
        STOR(  REG2,   AT(REG1))
        STOR(  REG3,   AT(REG1,REG2,SZ))           /* c = wid             */
FUNC_END(searchorder_dup)


/* searchorder-pick ( SO: wid_u .. wid_0 -- wid_u .. wid_0 ) ( u -- wid_u ) */
/* get i-th element of searchorder list */
FUNC_START(searchorder_pick)
        ADDI(  M64TH,   M64TH_OFF_SEARCHORDER, REG1) /* a = &m->searchorder */
        LOAD(  REG2,   AT(M64TH,M64TH_OFF_SEARCHORDER))/* b = searchorder.n   */
        MOVI(  M6ERR_WORDLIST_OVERFLOW,    REG0)
        JAE(   DTOP,   REG2,   FUNC(_throw_reg0_))
        SUB2(  DTOP,   REG2)                       /* b = n - i           */
        LOAD(  DTOP,   AT(REG1, REG2, SZ)) /* dtop = a[n-i] = m->searchorder.addr[n-i-1] */
FUNC_END(searchorder_pick)


/* searchorder[0]! ( wid -- ) ( SO: .. x -- .. wid ) */
/* set first element of searchorder list */
FUNC_START(searchorder_store_0)
        LOAD(  REG2,   AT(M64TH,M64TH_OFF_SEARCHORDER))/* b = searchorder.n   */
        ADDI(  M64TH,   M64TH_OFF_SEARCHORDER, REG1) /* a = &m->searchorder */
        MOVI(  M6ERR_WORDLIST_OVERFLOW,    REG0)
        JZ(    REG2,   FUNC(_throw_reg0_))
        STOR(  DTOP,   AT(REG1, REG2, SZ)) /* a[n-i] = m->searchorder.addr[n-i-1] = dtop */
        DPOP___DTOP()
FUNC_END(searchorder_store_0)


/* set-current ( wid -- ) forth-searchorder */
FUNC_START(set_current)
        STOR(  DTOP,   AT(M64TH, M64TH_OFF_COMPILE_WID))
        DPOP___DTOP()
FUNC_END(set_current)


/* token>asm>addr ( token -- asm-addr|0 ) convert token to m6func address */
FUNC_START(token_to_asm_addr)
        MOVE(  DTOP,   REG1)
        ZERO(  DTOP)
        JAE(   REG1,   IMM(M6____end), FUNC_RET(token_to_asm_addr))
        LOAD(  DTOP,   AT(FTBL, REG1, SZ))        /* dtop = ftable[token] */
FUNC_END(token_to_asm_addr)


/* token>name ( token -- nt|0 ) convert token to name */
FUNC_START(token_to_name)
        MOVE(  DTOP,   REG1)
        ZERO(  DTOP)
        JAE(   REG1,   IMM(M6____end), FUNC_RET(token_to_name))
        LOAD(  DTOP,   AT(M64TH, M64TH_OFF_WTABLE)) /* dtop = wtable               */
        LOAD(  DTOP,   AT(DTOP, REG1, SZ))        /* dtop = name = wtable[token] */
FUNC_END(token_to_name)


/* user-var ( -- addr ) must be followed by index. get address of i-th user variable  */
FUNC_START(user_var)
        DPUSH__DTOP()
        LD_ut( REG1,       AT(IP)) /* a = index */
#if M64TH_OFF_USER != 0
        ADD2(  IMM(M64TH_OFF_USER/SZ),  REG1)
#endif
        ADD4(  M64TH,       REG1,PSZ,   DTOP)
        NEXTT()
FUNC_RAWEND(user_var)


/* user-var-m64th ( -- m ) return current m64th* */
FUNC_START(user_var_m64th)
        DPUSH__DTOP()
        ADDI(  M64TH,   -M64TH_OFF_,     DTOP)
FUNC_END(user_var_m64th)


FUNC_START(wordlist_add) /* ( nt wid -- ) add name to wordlist */
        DPUSH__DTOP()                                  /* ( nt wid wid            */
        TOKEN_CALL_NOTHROW(FUNC(wordlist_to_last), wordlist_add.0)  /* ( dtop = prevnt         */
        LOAD(  REG1,   AT(DSTK, SZ))                   /* a = nt                  */
        JZ(    DTOP,   TO(wordlist_add.prevnt))
        XSUB2( REG1,   DTOP)                           /* dtop = nt-prevnt        */
LABEL(wordlist_add.prevnt)
        STOR(  DTOP,   AT(REG1, WORD_OFF_PREV_OFF))    /* nt.prev_off = dtop      */
        LOAD(  REG2,   AT(DSTK))                       /* b = wid                 */
        STOR(  REG1,   AT(REG2, M6WORDLIST_OFF_LAST))  /* wid.last = nt           */
        LOAD(  DTOP,   AT(DSTK, SZ2))
        ADD2( IMM(SZ3),DSTK)                           /* (                     ) */
FUNC_END(wordlist_add)


FUNC_START(wordlist_reset) /* ( wid -- ) */
        init_R000_REG1()
        STOR(  R000_REG1,  AT(DTOP, M6WORDLIST_OFF_LAST)) /* wid.last = 0        */
        DPOP___DTOP()
FUNC_END(wordlist_reset)


FUNC_START(wordlist_to_string) /* ( wid -- c-addr u ) */
        LOAD(  REG1,       AT(DTOP, M6WORDLIST_OFF_DICT))   /* a = dict               */
        ZERO(  DTOP)                                        /* u = dtop = 0           */
        LD_sw( REG2,       AT(REG1, DICT_OFF_NAME_OFF))     /* b = dict.name_off      */
        ZERO(  REG3)                                        /* c-addr = c = 0         */
        JZ(    REG2,       TO(wordlist_to_string.done))

        SUB2(  REG2,       REG1)                            /* a = m6countedstring*   */
        LD_ub( DTOP,       AT(REG1))                        /* u = dtop = string.n    */
        ADDI(  REG1,   1,  REG3)                            /* c-addr = c = string.addr */

LABEL(wordlist_to_string.done)
        DPUSH( REG3)                                        /* ( c-addr u           ) */
FUNC_END(wordlist_to_string)


FUNC_START(xt_to_name)     /* ( xt -- nt ) */
        SUB2(  IMM(WORD_OFF_XT), DTOP)                 /* dtop = w               */
FUNC_END(xt_to_name)
