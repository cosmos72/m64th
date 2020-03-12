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


/* [word] ( -- w ) push to dstack word being compiled */
FUNC_START(_word_)
        DPUSH( DTOP)
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_LASTW))       /* w = word             */
FUNC_END(_word_)


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


/**
 * Initialize m4th.lastw.code_off and update HERE.
 * Also initialize m4th.xt if it's null.
 * Must be called (at least) once per word, before calling any other m4func [compile*]
 */
FUNC_START(_compile_init_)
        /* TODO check if enough space */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_LASTW))   /* a = m4th.lastw        */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_OFF))/* b = w.code_off        */
        JNZ(   REG2,       TO(_compile_init_.finish))
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_DATA_N))  /* b = w.data_n          */
        JNZ(   REG2,       TO(_compile_init_.full))
LABEL(_compile_init_.simple)
        /* word.data_n == 0, simple initialization                              */
        MOVE(  IMM(WORD_OFF_DATA),     REG2w)          /* b = w.code - w        */
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_OFF))/* w.code_off = b        */
        ADD4(  REG2,       REG1,   0,  HERE)           /* here = xt             */
        JUMP(              TO(_compile_init_.finish))
LABEL(_compile_init_.full)
        /* word.data_n != 0, full initialization                                */
        ADDI(  REG1,       WORD_OFF_DATA,  REG3)       /* c = w.data            */
        ADD2(  REG2,       REG3)                       /* c = w.data + w.data_n */
        ALIGN( 4,          REG3)               /* c = align@4(w.data + w.data_n)*/
        ADDI(  REG3,       4,          HERE)           /* here = w.code = xt    */
#ifdef SUB3
        SUB3(  HERE,       REG1,       REG3)           /* c = code_off          */
#else
        MOVE(  HERE,       REG3)
        SUB2(  REG1,       REG3)                       /* c = code_off          */
#endif
        STORh( REG3h,  AT(REG1, WORD_OFF_CODE_OFF))    /* w.code_off = code_off */

        ADDI(  REG3,   -WORD_OFF_DATA, REG2) /* b = w.code_off - WORD_OFF_DATA  */
        STORw( REG2w,      AT(HERE, -4))               /* xt[-1] = b            */
LABEL(_compile_init_.finish)
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_XT))
        JNZ(   REG1,       FUNC_NEXT(_compile_init_))
        /* set m4th.xt only if it's NULL */
        STOR(  HERE,       AT(M4TH, M4TH_OFF_XT))      /* m4th.xt = here = xt   */
FUNC_END(_compile_init_)


/** ( -- ) must be followed by m4token, append it to XT being compiled. */
FUNC_START(_compile_lit_)    /* [compile-lit] */
        LD_ut( REG3_ut,    AT(IP))                     /* c = m4token             */
        STORt( REG3t,      AT(HERE))                   /* *here = c               */
        ADD2(  IMM(SZt),   HERE)                       /* here += SZt             */
        NEXTT()                                        /* skip m4token            */
FUNC_RAWEND(_compile_lit_)


/** (int16 -- ) pop int16 from dstack and append it to XT being compiled. */
FUNC_START(_compile2s_)    /* [compile-2s,] */
        STORh( DTOPh,      AT(HERE))                   /* *here = (int16)DTOP     */
        ADD2(  IMM(2),     HERE)                       /* here += 2               */
        DPOP(  DTOP)
FUNC_END(_compile2s_)


/** (int32 -- ) pop int32 from dstack and append it to XT being compiled. */
FUNC_START(_compile4s_)    /* (compile-4s,) */
        STORw( DTOPw,      AT(HERE))                   /* *here = (int32)DTOP     */
        ADD2(  IMM(4),     HERE)                       /* here += 4               */
        DPOP(  DTOP)
FUNC_END(_compile4s_)


/** (int64 -- ) pop int64 from dstack and append it to XT being compiled. */
FUNC_START(_compile8s_)    /* (compile-8s,) */
        STOR(  DTOP,       AT(HERE))                   /* *here = (int64)DTOP     */
        ADD2(  IMM(8),     HERE)                       /* here += 8               */
        DPOP(  DTOP)
FUNC_END(_compile8s_)


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


FUNC_START(state)
        DPUSH( DTOP)
        ADDI(  M4TH, M4TH_OFF_XT, DTOP) /* we use m4th->xt as state */
FUNC_END(state)
