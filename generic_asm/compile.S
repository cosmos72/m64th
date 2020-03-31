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
        SUB2(  AT(M4TH, M4TH_OFF_XT),  DTOP)           /* dtop = here - m4th.xt */
#else
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_XT))      /* dtop = m4th.xt        */
        XSUB2( HERE,       DTOP)                       /* dtop = here - m4th.xt */
#endif
        SHR2(  IMM(PSZt),  DTOP)
FUNC_END(_num_compiled_)


/** [#compiled.reg0] ( -- ) set reg0 = code size i.e. # of tokens in XT being compiled  */
FUNC_START(_num_compiled_reg0_)
#ifdef __x86_64__
        MOVE(  HERE,       REG0)                       /* @ = here           */
        SUB2(  AT(M4TH, M4TH_OFF_XT),  REG0)           /* @ = here - m4th.xt */
#else
        LOAD(  REG0,       AT(M4TH, M4TH_OFF_XT))      /* @ = m4th.xt        */
        XSUB2( HERE,       REG0)                       /* @ = here - m4th.xt */
#endif
        SHR2(  IMM(PSZt),  REG0)
FUNC_END(_num_compiled_reg0_)


/** ( -- ) must be followed by m4token, append it to XT being compiled. */
FUNC_START(_compile_lit_)    /* [compile-lit] */
        LD_ut( REG3,       AT(IP))                     /* c = m4token             */
        STORt( REG3,       AT(HERE))                   /* *here = c               */
        ADD2(  IMM(SZt),   HERE)                       /* here += SZt             */
        NEXTT()                                        /* skip m4token            */
FUNC_RAWEND(_compile_lit_)


/**
 * [compile-jump-lit] ( -- sys ) must be followed by m4token and its category.
 * compile an unresolved jump, i.e. append m4token and T(-1) to XT being compiled,
 * then push sys to dstack i.e. jump_address (= # of tokens of XT being compiled) and category.
 */
FUNC_START(_compile_jump_lit_)
        LD_ut( REG1,       AT(IP))                     /* a = token                  */
        DPUSH( DTOP)
        DPUSH( REG1)
        LD_ut( DTOP,       AT(IP, SZt))                /* dtop = category            */
        ADD2( IMM(SZt2),   IP)                         /* skip two m4token           */
        /* FALLTHROUGH */
/* FUNC_RAWEND(_compile_jump_lit_) */


/**
 * [compile-jump] ( token category -- sys )
 * compile an unresolved jump, i.e. append token and T(-1) to XT being compiled,
 * then push sys to dstack i.e. jump_address (= # of tokens of XT being compiled) and category.
 */
FUNC_DEF(_compile_jump_)
/* FUNC_START(_compile_jump_) */
                                                       /* ( token category         ) */
        ASM_CALL(          FUNC(_num_compiled_reg0_))  /* @ = #code_n                */
        LOAD(  REG1,       AT(DSTK))                   /* a = token                  */
        ADD2(  IMM(2),     REG0)                       /* @ = jump_address           */
        init_RFFF_REG2()                               /* b = -1                     */
        STORt( REG1,       AT(HERE))                   /* here[0] = token            */
        STORt( RFFF_REG2,  AT(HERE, SZt))              /* here[1] = -1               */
        ADD2(  IMM(SZt2),  HERE)                       /* here += 2 * SZt            */
        STOR(  REG0,       AT(DSTK))                   /* ( jump_address category )  */
FUNC_END(_compile_jump_)
FUNC_SIZE(_compile_jump_lit_)

/**
 * ( -- cs-depth ) must be followed by jump category.
 * find jump category in control stack and return its cs-depth.
 * Stops at colon-sys, throws if not found.
 */
FUNC_START(_cs_find_lit_)    /* [cs-find] */
        DPUSH( DTOP)               /* push dtop now: avoid special case cs-depth == 0 */
        LOAD(  REG2,       AT(M4TH, M4TH_OFF_DEND))    /* b = dstack_end              */
        LD_ut( REG1,       AT(IP))                     /* a = category                */
        SUB2(  DSTK,       REG2)                       /* b = dstack depth in bytes   */
        ZERO(  DTOPw)                                  /* dtop = 0                    */
        JB(    REG2,       IMM(SZ2), TO(_cs_find_lit_.throw))
        SUB2(  IMM(SZ2-1), REG2)                       /* b = dstack depth in bytes - SZ2 + 1 */
LABEL(_cs_find_lit_.loop)
        LOAD(  REG3,       AT(DSTK, DTOP, 1))
        JEQ(   REG1,       REG3,   TO(_cs_find_lit_.done))
        JEQ(   REG3,  IMM(M4colon),TO(_cs_find_lit_.throw))
        ADD2(  IMM(SZ2),   DTOP)
        JB(    DTOP,       REG2,   TO(_cs_find_lit_.loop))
LABEL(_cs_find_lit_.throw)
        MOVE(  IMM(M4ERR_CONTROL_STRUCTURE_MISMATCH), REG0)
        JUMP(  FUNC(_throw_reg0_))
LABEL(_cs_find_lit_.done)
        SHR2(  IMM(PSZ+1), DTOP)
        NEXTT()                                        /* skip m4token                */
FUNC_RAWEND(_cs_find_lit_)


FUNC_START(short_align)    /* short-align */
        ALIGN( 2,          HERE)
FUNC_END(short_align)


FUNC_START(int_align)      /* int-align */
        ALIGN( 4,          HERE)
FUNC_END(int_align)


FUNC_START(align)          /* align */
        ALIGN( SZ,         HERE)
FUNC_END(align)


FUNC_START(allot)          /* allot */
        ADD2(  DTOP,       HERE)
        DPOP(  DTOP)
FUNC_END(allot)


#ifndef M4FC_COMMA
FUNC_START(c_comma)        /* c,   */
        STORb( DTOP,       AT(HERE))
        INC1(  HERE)
        DPOP(  DTOP)
FUNC_END(c_comma)
#endif


#ifndef M4FSHORT_COMMA
FUNC_START(short_comma)    /* short,   m4th-user */
        STORh( DTOP,       AT(HERE))
        ADD2(  IMM(2),     HERE)
        DPOP(  DTOP)
FUNC_END(short_comma)
#endif


#ifndef M4FINT_COMMA
FUNC_START(int_comma)      /* int,     m4th-user */
        STORw( DTOP,       AT(HERE))
        ADD2(  IMM(4),     HERE)
        DPOP(  DTOP)
FUNC_END(int_comma)
#endif


#ifndef M4FCOMMA
FUNC_START(comma)          /* ,    */
        STOR(  DTOP,       AT(HERE))
        ADD2(  IMM(SZ),    HERE)
        DPOP(  DTOP)
FUNC_END(comma)
#endif


/**
 * countedstring, ( c-addr u -- ) m4th-user

 * implemented in assembly because 'name,' needs it,
 * and we want 'name,' to be assembly too,
 * because it needs to know m4word internals
 */
FUNC_START(countedstring_comma)
        JA(    DTOP,   IMM(0xff),  TO(countedstring_comma.throw))
        STORb( DTOP,   AT(HERE))
        INC1(  HERE)                                   /* here++            */
        DPUSH( HERE)                                   /* ( c-addr here u ) */
        ADD2(  DTOP,   HERE)                           /* here += u         */
        JUMP(  FUNC(cmove))
LABEL(countedstring_comma.throw)
        MOVE(  IMM(M4ERR_DEFINITION_NAME_TOO_LONG),  DTOP)
        JUMP(  FUNC(throw))
FUNC_RAWEND(countedstring_comma)


#ifndef M4FIMMEDIATE
/* immediate ( -- ) mark last defined word as 'immediate' */
FUNC_START(immediate)
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_LASTW))   /* a = w = m4th.lastw    */
        LD_uh( REG2,   AT(REG1, WORD_OFF_FLAGS))   /* b = w.flags           */
        ORR2(  IMM(M4FLAG_IMMEDIATE), REG2)        /* b |= m4flag_immediate */
        STORh( REG2,   AT(REG1, WORD_OFF_FLAGS))   /* w.flags = b           */
FUNC_END(immediate)
#endif


/* latest ( -- nt ) get last defined word */
FUNC_START(latest)
        DPUSH( DTOP)
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_LASTW))   /* nt = m4th.lastw       */
FUNC_END(latest)


/* set-latest ( nt -- ) set last defined word */
FUNC_START(set_latest)
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_LASTW))   /* m4th.lastw = nt       */
        /* we really should NOT be compiling now, but in some tests we are  */
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_XT))      /* a = m4th.xt           */
        JZ(    REG1,   TO(set_latest.done))
        LD_uw( REG2,   AT(DTOP, WORD_OFF_CODE_OFF))/* b = nt.code_off       */
        ADD2(  REG2,   DTOP)                       /* dtop = nt.code.addr   */
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_XT))      /* m4th.xt = dtop        */
LABEL(set_latest.done)
        DPOP(  DTOP)
FUNC_END(set_latest)


FUNC_START(state)
        DPUSH( DTOP)
        ADDI(  M4TH, M4TH_OFF_XT, DTOP)                /* &m4th.xt is also used as STATE */
FUNC_END(state)

/**
 * Temporarily switch from compiling to interpreting.
 * Update m4th.lastw.code_n (needed by ';') then set m4th.xt to 0
 */
FUNC_START(left_bracket)
        LOAD(  REG2,       AT(M4TH, M4TH_OFF_XT))
        JZ(    REG2,       FUNC_NEXT(left_bracket))    /* noop if interpreting  */

        XSUB2( HERE,       REG2)                       /* b = here - m4th.xt    */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = m4th.lastw        */
        SHR2(  IMM(PSZt),  REG2)                       /* b = #compiled         */
        STORh( REG2,       AT(REG1, WORD_OFF_CODE_N))  /* lastw.code_n = b      */

        init_R000_REG1()
        STOR( R000_REG1,   AT(M4TH, M4TH_OFF_XT))      /* exit compile mode     */
FUNC_END(left_bracket)


FUNC_START(_latest_sync_data_n_)
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = w = m4th.lastw    */
        ADDI(  REG1,       WORD_OFF_DATA, REG2)        /* b = w.data            */
        XSUB2( HERE,       REG2)                       /* b = data_n            */
        STOR(  REG2,       AT(REG1, WORD_OFF_DATA_N))  /* w.data_n = data_n     */
FUNC_END(_latest_sync_data_n_)


FUNC_START(_latest_sync_code_off_)
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = w = m4th.lastw    */
        LOAD(  REG2,       AT(REG1, WORD_OFF_DATA_N))  /* b = w.data_n          */
        JNZ(   REG2,       TO(_latest_sync_code_off_.full))

        /* word.data_n == 0, simple initialization                              */
        MOVE(  IMM(WORD_OFF_DATA),     REG2w)          /* b = w.code - w        */
        STORh( REG2,       AT(REG1, WORD_OFF_CODE_OFF))/* w.code_off = b        */
        ADD4(  REG2,       REG1,   0,  HERE)           /* here = xt             */
        JUMP(              FUNC_NEXT(_latest_sync_code_off_))

        /* word.data_n != 0, full initialization                                */
LABEL(_latest_sync_code_off_.full)
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
        STORh( REG2,   AT(REG1, WORD_OFF_CODE_OFF))    /* w.code_off = code_off */

        ADDI(  REG2,   -WORD_OFF_DATA, REG3) /* c = w.code_off - WORD_OFF_DATA  */
        STORw( REG3,       AT(HERE, -4))               /* xt[-1] = c            */
FUNC_END(_latest_sync_code_off_)

/**
 * Start or resume compiling.
 * If needed, initialize m4th.lastw.code_off and update HERE.
 * Set state = m4th.xt to code address of m4th.lastw.
 */
FUNC_START(right_bracket)
        /* TODO check if enough space */
        MOVE(  IMM(M4ERR_ZERO_LENGTH_NAME), REG0)      /* ( err )               */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = m4th.lastw        */
        JZ(    REG1,       FUNC(_throw_reg0_))         /* no latest word: throw */
        MOVE(  IMM(M4ERR_COMPILER_NESTING), REG0)      /* ( err )               */
        LOAD(  REG3,       AT(M4TH, M4TH_OFF_XT))      /* c = m4th.xt           */
        JNZ(   REG3,       FUNC(_throw_reg0_))         /* compiling: throw      */
        LD_uh( REG2,       AT(REG1, WORD_OFF_CODE_OFF))/* b = w.code_off        */
        JNZ(   REG2,       FUNC_NEXT(right_bracket))
        ASM_CALL_PREPARE()
        ASM_CALL_BODY(     FUNC(_latest_sync_data_n_))
        ASM_CALL_BODY(     FUNC(_latest_sync_code_off_))
        ASM_CALL_CLEANUP()
        STOR(  HERE,       AT(M4TH, M4TH_OFF_XT))      /* m4th.xt = xt          */
FUNC_END(right_bracket)
