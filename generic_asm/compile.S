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
        DPUSH__DTOP()
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


#ifndef M4F_LIT_COMMA_
/** ( -- ) must be followed by m4token, append it to XT being compiled. */
FUNC_START(_lit_comma_)    /* (lit,) */
        LD_ut( REG3,       AT(IP))                     /* c = m4token             */
        STORt( REG3,       AT(HERE))                   /* *here = c               */
        ADD2(  IMM(SZt),   HERE)                       /* here += SZt             */
        NEXTT()                                        /* skip m4token            */
FUNC_RAWEND(_lit_comma_)
#endif

/**
 * [compile-jump-lit] ( -- sys ) must be followed by m4token and its category.
 * compile an unresolved jump, i.e. append m4token and T(-1) to XT being compiled,
 * then push sys to dstack i.e. jump_address (= # of tokens of XT being compiled) and category.
 */
FUNC_START(_compile_jump_lit_)
        LD_ut( REG1,       AT(IP))                     /* a = token                  */
        DPUSH2(DTOP,       REG1)
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
        TOKEN_CALL_NOTHROW(FUNC(_num_compiled_reg0_), _compile_jump_.0) /* @ = #code_n */
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
 * [compile-sys-lit] ( -- sys ) must be followed by m4token and its category.
 * compile a non-jumping token i.e. append it to XT being compiled,
 * then push sys to dstack i.e. jump_address (= # of tokens of XT being compiled) and category.
 */
FUNC_START(_compile_sys_lit_)
        TOKEN_CALL_NOTHROW(FUNC(_num_compiled_reg0_), _compile_sys_lit_.0) /* @ = #code_n */
        LD_ut( REG1,       AT(IP))                     /* a = token                  */
        LD_ut( REG2,       AT(IP, SZt))                /* b = category               */
        ADD2( IMM(SZt2),   IP)                         /* skip two m4token           */
        STORt( REG1,       AT(HERE))                   /* here[0] = token            */
        INC1(  REG0)                                   /* @ = jump_address           */
        ADD2(  IMM(SZt),   HERE)                       /* here += SZt                */
        DPUSH2(DTOP,       REG0)                       /* ( jump_address _ )         */
        MOVE(  REG2,       DTOP)                       /* ( jump_address category )  */
FUNC_END(_compile_sys_lit_)


/**
 * ( -- cs-depth ) must be followed by jump category.
 * find jump category in control stack and return its cs-depth.
 * Stops at colon-sys, throws if not found.
 */
FUNC_START(_cs_find_lit_)    /* [cs-find] */
        DPUSH__DTOP()              /* push dtop now: avoid special case cs-depth == 0 */
        LOAD(  REG2,       AT(M4TH, M4TH_OFF_DEND))    /* b = dstack_end              */
        LD_ut( REG1,       AT(IP))                     /* a = category                */
        SUB2(  DSTK,       REG2)                       /* b = dstack depth in bytes   */
        ZERO(  DTOP)                                   /* dtop = 0                    */
        JB(    REG2,       IMM(SZ2), TO(_cs_find_lit_.throw))
        SUB2(  IMM(SZ2-1), REG2)                       /* b = dstack depth in bytes - SZ2 + 1 */
LABEL(_cs_find_lit_.loop)
        LOAD(  REG3,       AT(DSTK, DTOP, 1))
        JEQ(   REG1,       REG3,   TO(_cs_find_lit_.done))
        JEQ(   REG3,  IMM(M4colon),TO(_cs_find_lit_.throw))
        ADD2(  IMM(SZ2),   DTOP)
        JB(    DTOP,       REG2,   TO(_cs_find_lit_.loop))
LABEL(_cs_find_lit_.throw)
        MOVI(  M4ERR_CONTROL_STRUCTURE_MISMATCH,   REG0)
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
        DPOP___DTOP()
FUNC_END(allot)


#ifndef M4FC_COMMA
FUNC_START(c_comma)        /* c,   */
        STORb( DTOP,       AT(HERE))
        INC1(  HERE)
        DPOP___DTOP()
FUNC_END(c_comma)
#endif


#ifndef M4FSHORT_COMMA
FUNC_START(short_comma)    /* short,   m4th-user */
        STORh( DTOP,       AT(HERE))
        ADD2(  IMM(2),     HERE)
        DPOP___DTOP()
FUNC_END(short_comma)
#endif


#ifndef M4FINT_COMMA
FUNC_START(int_comma)      /* int,     m4th-user */
        STORw( DTOP,       AT(HERE))
        ADD2(  IMM(4),     HERE)
        DPOP___DTOP()
FUNC_END(int_comma)
#endif


#ifndef M4FCOMMA
FUNC_START(comma)          /* ,    */
        STOR(  DTOP,       AT(HERE))
        ADD2(  IMM(SZ),    HERE)
        DPOP___DTOP()
FUNC_END(comma)
#endif


/**
 * countedstring, ( c-addr u -- ) m4th-user

 * implemented in assembly because 'name,' needs it,
 * and we want 'name,' to be assembly too,
 * because it needs to know m4word internals
 */
FUNC_START(countedstring_comma)
        MOVI(  M4ERR_DEFINITION_NAME_TOO_LONG,  REG0)
        JA(    DTOP,   IMM(0xff),  FUNC(_throw_reg0_))
        STORb( DTOP,   AT(HERE))
        INC1(  HERE)                                   /* here++            */
        DPUSH( HERE)                                   /* ( c-addr here u ) */
        ADD2(  DTOP,   HERE)                           /* here += u         */
        JUMP(  FUNC(cmove))
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
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_LASTW))   /* nt = m4th.lastw       */
FUNC_END(latest)


/* set-latest ( nt -- ) set last defined word */
FUNC_START(to_latest)
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_LASTW))   /* m4th.lastw = nt       */
        /* we really should NOT be compiling now, but in some tests we are  */
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_XT))      /* a = m4th.xt           */
        JZ(    REG1,   TO(to_latest.done))
        ADD2(  IMM(WORD_OFF_XT),   DTOP)           /* dtop = nt.code        */
        STOR(  DTOP,   AT(M4TH, M4TH_OFF_XT))      /* m4th.xt = dtop        */
LABEL(to_latest.done)
        DPOP___DTOP()
FUNC_END(to_latest)


FUNC_START(state)
        DPUSH__DTOP()
        ADDI(  M4TH, M4TH_OFF_XT, DTOP)                /* &m4th.xt is also used as STATE */
FUNC_END(state)

/**
 * Temporarily switch from compiling to interpreting.
 * Update m4th.lastw.code_n (needed by ';') then set m4th.xt to 0
 */
FUNC_START(left_bracket)
        LOAD(  REG2,       AT(M4TH, M4TH_OFF_XT))
        JZ(    REG2,       FUNC_RET(left_bracket))    /* noop if interpreting  */

        XSUB2( HERE,       REG2)                       /* b = here - m4th.xt    */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = m4th.lastw        */
        SHR2(  IMM(PSZt),  REG2)                       /* b = #compiled         */
        STORh( REG2,       AT(REG1, WORD_OFF_CODE_N))  /* lastw.code_n = b      */

        init_R000_REG1()
        STOR( R000_REG1,   AT(M4TH, M4TH_OFF_XT))      /* exit compile mode     */
FUNC_END(left_bracket)


/**
 * Start or resume compiling.
 * Set state = m4th.xt to code address of m4th.lastw.
 */
FUNC_START(right_bracket)
        /* TODO check if enough space */
        MOVI(  M4ERR_ZERO_LENGTH_NAME, REG0)           /* @ = err               */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = w = m4th.lastw    */
        JZ(    REG1,       FUNC(_throw_reg0_))         /* no latest word: throw */
        MOVI(  M4ERR_COMPILER_NESTING, REG0)           /* @ = err               */
        LOAD(  REG3,       AT(M4TH, M4TH_OFF_XT))      /* c = m4th.xt           */
        ADD2(  IMM(WORD_OFF_XT),   REG1)               /* a = xt = w.code       */
        JNZ(   REG3,       FUNC(_throw_reg0_))         /* compiling: throw      */
        STOR(  REG1,       AT(M4TH, M4TH_OFF_XT))      /* m4th.xt = w.code      */
FUNC_END(right_bracket)
