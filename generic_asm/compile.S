/**
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


/* [word] ( -- w ) push to dstack word being compiled */
FUNC_START(_word_)
        DPUSH( DTOP)
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_W))       /* w = word             */
FUNC_END(_word_)


/** [#compiled] ( -- [word].code_n) code size i.e. # of tokens in word being compiled  */
FUNC_START(_num_compiled_)  /*  */
        DPUSH( DTOP)
        LOAD(  DTOP,       AT(M4TH, M4TH_OFF_W))
        LD_uh( DTOP_uh,    AT(DTOP, WORD_OFF_CODE_N))
FUNC_END(_num_compiled_)


FUNC_START(_compile_common_)
        /* TODO check if enough space */
        LOAD(  REG1,       AT(M4TH, M4TH_OFF_W))       /* a = word             */
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_CODE_N))  /* code_n = word.code_n */
        JNZ(   REG2,       _compile2s_.done)
        LD_uh( REG2_uh,    AT(REG1, WORD_OFF_DATA_N))  /* b = data_n = word.data_n */
        JZ(    REG2,       _compile2s_.done)
        /* word.data_n != 0 && word.code_n = 0, we must initialize header      */
        ADDI(  REG1,       WORD_OFF_DATA,  REG3)       /* c = word.data        */
        ADD2(  REG2,       REG3)                       /* c = data + data_n    */
        ALIGN( 4,          REG3)            /* c = align@uint32(data + data_n) */
        ADDI(  REG3,       4,          HERE)           /* here = code          */
#ifdef SUB3
        SUB3(  HERE,       REG1,       REG3)           /* c = code_off         */
#else
        MOVE(  HERE,       REG3)
        SUB2(  REG1,       REG3)                       /* c = code_off         */
#endif
        STORh( REG3h,      AT(REG1, WORD_OFF_CODE_OFF)) /* word.code_off = code_off */

        ADDI(  REG3,       -WORD_OFF_DATA, REG2)  /* y = word.code_off - WORD_OFF_DATA */
        STORw( REG2w,      AT(HERE, -4))          /* code[-1] = y */
LABEL(_compile2s_.done)
FUNC_RAWEND(_compile_common_)


/** (int16 -- ) pop int16 from dstack and append it to XT being compiled. */
FUNC_START(_compile2s_)    /* [compile-2s,] */
        CALL(  _compile_common_) /* updates HERE; sets REG1 = word, REG2 = code_n */
        STORh( DTOPh,      AT(HERE))                   /* *here = (int16)DTOP     */
        ADD2(  IMM(2),     HERE)                       /* here += 2               */
        ADD2(  IMM(2/SZt), REG2)                       /* code_n += 2/SZt         */
        DPOP(  DTOP)
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* word.code_n = code_n    */
FUNC_END(_compile2s_)


/** ( -- ) must be followed by m4token, append it to XT being compiled. */
FUNC_START(_compile_lit_)    /* [compile-lit] */
        CALL(  _compile_common_) /* updates HERE; sets REG1 = word, REG2 = code_n */
        STORt( DTOPt,      AT(HERE))                   /* *here = (m4token)DTOP   */
        ADD2(  IMM(SZt),   HERE)                       /* here += SZt             */
        INC1(  REG2)                                   /* code_n ++               */
        DPOP(  DTOP)
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* word.code_n = code_n    */
FUNC_RAWEND(_compile_lit_)


/** (int32 -- ) pop int32 from dstack and append it to XT being compiled. */
FUNC_START(_compile4s_)    /* (compile-4s,) */
        CALL(  _compile_common_) /* updates HERE; sets REG1 = word, REG2 = code_n */
        STORw( DTOPw,      AT(HERE))                   /* *here = (int32)DTOP     */
        ADD2(  IMM(4),     HERE)                       /* here += 4               */
        ADD2(  IMM(4/SZt), REG2)                       /* code_n += 4/SZt         */
        DPOP(  DTOP)
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* word.code_n = code_n    */
FUNC_END(_compile4s_)


/** (int64 -- ) pop int64 from dstack and append it to XT being compiled. */
FUNC_START(_compile8s_)    /* (compile-8s,) */
        CALL(  _compile_common_) /* updates HERE; sets REG1 = word, REG2 = code_n */
        STORw( DTOPw,      AT(HERE))                   /* *here = (int64)DTOP     */
        ADD2(  IMM(8),     HERE)                       /* here += 8               */
        ADD2(  IMM(8/SZt), REG2)                       /* code_n += 8/SZt         */
        DPOP(  DTOP)
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* word.code_n = code_n    */
FUNC_END(_compile8s_)


/**
 * ( -- jump_address jump_token ) must be followed by m4token, append it and T(-1) to XT being compiled,
 * then push to dstack jump_address (= # of tokens of XT being compiled) and m4token.
 */
FUNC_START(_compile_unresolved_jump_)    /* [compile-unresolved-jump] */
        CALL(  _compile_common_) /* updates HERE; sets REG1 = word, REG2 = code_n    */
        LD_ut( REG3_ut,    AT(IP))                     /* b = jump_token             */
        DPUSH( DTOP)
        STORt( REG3t,      AT(HERE))                   /* here[0] = b                */
#ifdef RFFFt
        STORt( RFFFt,      AT(HERE, SZt))              /* here[1] = -1               */
#else
        MOVE(  IMM(-1),    DTOP)                       /* a = -1                     */
        STORt( DTOPt,      AT(HERE, SZt))              /* here[1] = a                */
#endif
        ADD2(  IMM(2),     REG2)                       /* code_n += 2                */
        STORh( REG2h,      AT(REG1, WORD_OFF_CODE_N))  /* w.code_n = code_n          */
        DPUSH( REG2)                                   /* d2 = jump_address = code_n */
        MOVE(  REG3,       DTOP)                       /* dtop = jump_token = b      */
        NEXTT()                                        /* skip m4token               */
FUNC_RAWEND(_compile_unresolved_jump_)
