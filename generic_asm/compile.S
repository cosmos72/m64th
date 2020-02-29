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
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_W))       /* w = word             */
FUNC_END(_word_)


/** [#compiled] ( -- [word].code_n) code size i.e. # of tokens in word being compiled  */
FUNC_START(_num_compiled_)
        DPUSH( DTOP)
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_W))
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_CODE_N))
FUNC_END(_num_compiled_)


/**
 * Initialize [word].code_off, update HERE.
 * Must be called (at least) once per word, before calling any other m4func [compile*]
 */
FUNC_START(_compile_init_)
        /* TODO check if enough space */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_W))       /* a = [word]            */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_OFF))/* b = w.code_off        */
        JNZ(   REG2,       TO(_compile_init_.done))
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_DATA_N))  /* b = w.data_n          */
        JNZ(   REG2,       TO(_compile_init_.full))
LABEL(_compile_init_.simple)
        /* word.data_n == 0, simple initialization                              */
        MOVE(  IMM(WORD_OFF_DATA),     REG2w)          /* b = w.code - w        */
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_OFF))/* w.code_off = b        */
        JUMP(              TO(_compile_init_.done))
LABEL(_compile_init_.full)
        /* word.data_n != 0, full initialization                                */
        ADDI(  REG1,       WORD_OFF_DATA,  REG3)       /* c = w.data            */
        ADD2(  REG2,       REG3)                       /* c = w.data + w.data_n */
        ALIGN( 4,          REG3)               /* c = align@4(w.data + w.data_n)*/
        ADDI(  REG3,       4,          HERE)           /* here = w.code         */
#ifdef SUB3
        SUB3(  HERE,       REG1,       REG3)           /* c = code_off          */
#else
        MOVE(  HERE,       REG3)
        SUB2(  REG1,       REG3)                       /* c = code_off          */
#endif
        STORh( REG3h,  AT(REG1, WORD_OFF_CODE_OFF))    /* w.code_off = code_off */

        ADDI(  REG3,   -WORD_OFF_DATA, REG2) /* b = w.code_off - WORD_OFF_DATA  */
        STORw( REG2w,      AT(HERE, -4))               /* w.code[-1] = b        */
LABEL(_compile_init_.done)
FUNC_END(_compile_init_)


/** ( -- ) must be followed by m4token, append it to XT being compiled. */
FUNC_START(_compile_lit_)    /* [compile-lit] */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_W))       /* a = [word]              */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_N))  /* b = w.code_n            */
        LD_ut( REG3_ut,    AT(IP))                     /* c = m4token             */
        INC1(  REG2)                                   /* code_n ++               */
        STORt( REG3t,      AT(HERE))                   /* *here = c               */
        ADD2(  IMM(SZt),   HERE)                       /* here += SZt             */
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* w.code_n = code_n       */
        NEXTT()                                        /* skip m4token            */
FUNC_RAWEND(_compile_lit_)


/** (int16 -- ) pop int16 from dstack and append it to XT being compiled. */
FUNC_START(_compile2s_)    /* [compile-2s,] */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_W))       /* a = [word]              */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_N))  /* b = w.code_n            */
        STORh( DTOPh,      AT(HERE))                   /* *here = (int16)DTOP     */
#if SZt == 2
        INC1(  REG2)                                   /* code_n ++               */
#else
        ADD2(  IMM(2/SZt), REG2)                       /* code_n += 2/SZt         */
#endif
        ADD2(  IMM(2),     HERE)                       /* here += 2               */
        DPOP(  DTOP)
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* w.code_n = code_n      */
FUNC_END(_compile2s_)


/** (int32 -- ) pop int32 from dstack and append it to XT being compiled. */
FUNC_START(_compile4s_)    /* (compile-4s,) */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_W))       /* a = [word]              */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_N))  /* b = w.code_n            */
        STORw( DTOPw,      AT(HERE))                   /* *here = (int32)DTOP     */
        ADD2(  IMM(4/SZt), REG2)                       /* code_n += 4/SZt         */
        ADD2(  IMM(4),     HERE)                       /* here += 4               */
        DPOP(  DTOP)
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* w.code_n = code_n       */
FUNC_END(_compile4s_)


/** (int64 -- ) pop int64 from dstack and append it to XT being compiled. */
FUNC_START(_compile8s_)    /* (compile-8s,) */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_W))       /* a = [word]              */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_N))  /* b = w.code_n            */
        STOR(  DTOP,       AT(HERE))                   /* *here = (int64)DTOP     */
        ADD2(  IMM(8/SZt), REG2)                       /* code_n += 8/SZt         */
        ADD2(  IMM(8),     HERE)                       /* here += 8               */
        DPOP(  DTOP)
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* w.code_n = code_n       */
FUNC_END(_compile8s_)


FUNC_START(_compile_resolved_jump_)    /* [compile-resolved-jump] */
        /* TODO */
        NEXTT2()                                       /* skip two m4token           */
FUNC_RAWEND(_compile_resolved_jump_)

/**
 * ( -- jump_address jump_token ) must be followed by m4token and its category.
 * append m4token and T(-1) to XT being compiled,
 * then push to dstack jump_address (= # of tokens of XT being compiled) and category.
 */
FUNC_START(_compile_unresolved_jump_)    /* [compile-unresolved-jump] */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_W))       /* a = [word]                 */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_N))  /* b = w.code_n            */
        LD_ut( REG3_ut,    AT(IP))                     /* c = jump_token             */
        DPUSH( DTOP)
        STORt( REG3t,      AT(HERE))                   /* here[0] = c                */
#ifdef RFFFt
        STORt( RFFFt,      AT(HERE, SZt))              /* here[1] = -1               */
#else
        MOVE(  IMM(-1),    DTOP)                       /* d = -1                     */
        STORt( DTOPt,      AT(HERE, SZt))              /* here[1] = d                */
#endif
        ADD2(  IMM(2),     REG2)                       /* code_n += 2                */
        ADD2(  IMM(2*SZt), HERE)                       /* here += 2 * SZt            */
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* w.code_n = code_n          */
        DPUSH( REG2)                                   /* d2 = jump_address = code_n */
        LD_ut( DTOP_ut,    AT(IP, SZt))                /* dtop = category            */
        NEXTT2()                                       /* skip two m4token           */
FUNC_RAWEND(_compile_unresolved_jump_)


FUNC_START(state)
        DPUSH( DTOP)
        ADDI(  M4TH, M4TH_OFF_W, DTOP) /* we use m4th->w as state */
FUNC_END(state)
