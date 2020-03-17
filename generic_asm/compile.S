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
#include "../include/err.mh"

/* clang-format off */


/** [#compiled] ( -- u ) code size i.e. # of tokens in XT being compiled  */
FUNC_START(_num_compiled_)
        DPUSH( DTOP)
#ifdef __x86_64__
        MOVE(  HERE,       DTOP)                       /* dtop = here           */
        SUB2(  AT(M4TH, M4TH_OFF_XT),  DTOP)           /* dtop = here - [xt]    */
#else
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_XT))      /* dtop = [xt]           */
        SUB3(  HERE,       DTOP,   DTOP)               /* dtop = here - [xt]    */
#endif
        SHR2(  IMM(PSZt),  DTOP)
FUNC_END(_num_compiled_)



/** ( -- ) must be followed by m4token, append it to XT being compiled. */
FUNC_START(_compile_lit_)    /* [compile-lit] */
        LD_ut( REG3_ut,    AT(IP))                     /* c = m4token             */
        STORt( REG3t,      AT(HERE))                   /* *here = c               */
        ADD2(  IMM(SZt),   HERE)                       /* here += SZt             */
        NEXTT()                                        /* skip m4token            */
FUNC_RAWEND(_compile_lit_)


FUNC_START(_compile_resolved_jump_)    /* [compile-resolved-jump] */
        /* TODO */
        NEXTT2()                                       /* skip two m4token           */
FUNC_RAWEND(_compile_resolved_jump_)

/**
 * ( -- jump_address jump_category ) must be followed by m4token and its category.
 * append m4token and T(-1) to XT being compiled,
 * then push to dstack jump_address (= # of tokens of XT being compiled) and category.
 */
FUNC_START(_compile_unresolved_jump_)    /* [compile-unresolved-jump] */
        ASM_CALL(  FUNC(_num_compiled_))               /* dtop = w.code_n            */
        LD_ut( REG3_ut,    AT(IP))                     /* c = jump_token             */
        ADD2(  IMM(2),     DTOP)                       /* dtop = jump_address        */
        STORt( REG3t,      AT(HERE))                   /* here[0] = jump_token       */
#ifdef RFFFt
        STORt( RFFFt,      AT(HERE, SZt))              /* here[1] = -1               */
#else
        MOVE(  IMM_1,      REG1)                       /* a = -1                     */
        STORt( REG1t,      AT(HERE, SZt))              /* here[1] = a                */
#endif
        DPUSH( DTOP)                                   /*                            */
        ADD2(  IMM(2*SZt), HERE)                       /* here += 2 * SZt            */
        LD_ut( DTOP_ut,    AT(IP, SZt))                /* dtop = category            */
        NEXTT2()                                       /* skip two m4token           */
FUNC_RAWEND(_compile_unresolved_jump_)


FUNC_START(align)          /* align */
        ALIGN( SZ,         HERE)
FUNC_END(align)


FUNC_START(allot)          /* allot */
        ADD2(  DTOP,       HERE)
        DPOP(  DTOP)
FUNC_END(allot)


FUNC_START(c_comma)        /* c,   */
        STORb( DTOPb,      AT(HERE))
        INC1(  HERE)
        DPOP(  DTOP)
FUNC_END(c_comma)


FUNC_START(short_comma)    /* short,   m4th-user */
        STORh( DTOPh,      AT(HERE))
        ADD2(  IMM(2),     HERE)
        DPOP(  DTOP)
FUNC_END(short_comma)


FUNC_START(int_comma)      /* int,     m4th-user */
        STORw( DTOPw,      AT(HERE))
        ADD2(  IMM(4),     HERE)
        DPOP(  DTOP)
FUNC_END(int_comma)


FUNC_START(comma)          /* ,    */
        STOR(  DTOP,       AT(HERE))
        ADD2(  IMM(SZ),    HERE)
        DPOP(  DTOP)
FUNC_END(comma)


/* countedstring, ( c-addr u -- ) m4th-user */
FUNC_START(countedstring_comma)
        JA(    DTOP,   IMM(0xff),  TO(countedstring_comma.throw))
        STORb( DTOPb,  AT(HERE))
        INC1(  HERE)                                   /* here++            */
        DPUSH( HERE)                                   /* ( c-addr here u ) */
        ADD2(  DTOP,   HERE)                           /* here += u         */
        JUMP(  FUNC(cmove))
LABEL(countedstring_comma.throw)
        MOVE(  IMM(M4ERR_DEFINITION_NAME_TOO_LONG),  DTOP)
        JUMP(  FUNC(throw))
FUNC_RAWEND(countedstring_comma)


/* latest ( -- nt ) get last defined word */
FUNC_START(latest)
        DPUSH( DTOP)
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_LASTW))   /* nt = m4th.lastw       */
FUNC_END(latest)


/* set-latest ( nt -- ) set last defined word */
FUNC_START(set_latest)
        STOR(  DTOP,       AT(M4TH, M4TH_OFF_LASTW))   /* m4th.lastw = nt       */
        /* we really should NOT be compiling now, but in some tests we are      */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_XT))      /* a = m4th.xt           */
        JZ(    REG1,       TO(set_latest.done))
        LD_uw( REG2_uw,    AT(DTOP, WORD_OFF_CODE_OFF))/* b = nt.code_off       */
        ADD2(  REG2,       DTOP)                       /* dtop = nt.code.addr   */
        STOR(  DTOP,       AT(M4TH, M4TH_OFF_XT))      /* m4th.xt = dtop        */
LABEL(set_latest.done)
        DPOP(  DTOP)
FUNC_END(set_latest)


/**
 * Temporarily switch from compiling to interpreting.
 */
FUNC_START(left_bracket)
        initR000_w(REG1w)
        STOR(  R000_r(REG1),   AT(M4TH, M4TH_OFF_XT))
FUNC_END(left_bracket)


/**
 * If needed, initialize m4th.lastw.code_off and update HERE.
 * Set state = m4th.xt to code address of m4th.lastw.
 */
FUNC_START(right_bracket)
        /* TODO check if enough space */
        LOAD(  REG3,       AT(M4TH, M4TH_OFF_XT))      /* c = m4th.xt           */
        JZ(    REG3,       TO(right_bracket.nothrow))
        DPUSH( DTOP)
        MOVE(  IMM(M4ERR_COMPILER_NESTING), DTOP)      /* ( err )               */
        JUMP(              FUNC(throw))
LABEL(right_bracket.nothrow)
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = m4th.lastw        */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_OFF))/* b = w.code_off        */
        JNZ(   REG2,       TO(right_bracket.finish))
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_DATA_N))  /* b = w.data_n          */
        JNZ(   REG2,       TO(right_bracket.full))
LABEL(right_bracket.simple)
        /* word.data_n == 0, simple initialization                              */
        MOVE(  IMM(WORD_OFF_DATA),     REG2w)          /* b = w.code - w        */
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_OFF))/* w.code_off = b        */
        ADD4(  REG2,       REG1,   0,  HERE)           /* here = xt             */
        JUMP(              TO(right_bracket.finish))
LABEL(right_bracket.full)
        /* word.data_n != 0, full initialization                                */
        ADDI(  REG1,       WORD_OFF_DATA,  REG3)       /* c = w.data            */
        ADD2(  REG2,       REG3)                       /* c = w.data + w.data_n */
        ALIGN( 4,          REG3)               /* c = align@4(w.data + w.data_n)*/
        ADDI(  REG3,       4,          HERE)           /* here = w.code = xt    */
#ifdef SUB3
        SUB3(  HERE,       REG1,       REG2)           /* b = code_off          */
#else
        MOVE(  HERE,       REG2)
        SUB2(  REG1,       REG2)                       /* b = code_off          */
#endif
        STORh( REG2h,  AT(REG1, WORD_OFF_CODE_OFF))    /* w.code_off = code_off */

        ADDI(  REG2,   -WORD_OFF_DATA, REG3) /* c = w.code_off - WORD_OFF_DATA  */
        STORw( REG3w,      AT(HERE, -4))               /* xt[-1] = c            */
LABEL(right_bracket.finish)
        ADD2(  REG2,       REG1)                       /* a = w + w.code_off = xt */
        STOR(  REG1,       AT(M4TH, M4TH_OFF_XT))      /* m4th.xt = xt          */
FUNC_END(right_bracket)


FUNC_START(state)
        DPUSH( DTOP)
        ADDI(  M4TH, M4TH_OFF_XT, DTOP)                /* &m4th.xt is also used as STATE */
FUNC_END(state)
