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


/** ( -- xt ) XT of word currently being compiled */
FUNC_START(_xt_) /* [xt] */
        DPUSH( DTOP)
        MOVE(  RXT,    DTOP)
FUNC_END(_xt_)


#if 0
FUNC_START(xt_code_n_fetch) /* (xt -- xt.code_n) */
        LD_uh( DTOP_uh,   AT(DTOP, XT_OFF_CODE_N))
FUNC_END(xt_code_n_fetch)
#endif /* 0 */

/** ( -- [xt].code_n) code size i.e. # of tokens in word being compiled  */
FUNC_START(_num_compiled_)  /* [#compiled] */
        DPUSH( DTOP)
        LD_uh( DTOP_uh,    AT(RXT, XT_OFF_CODE_N))
FUNC_END(_num_compiled_)


#ifndef M4F_COMPILE2S_
/** (int16 -- ) pop int16 from dstack and append it to XT being compiled. */
FUNC_START(_compile2s_)    /* [compile-2s,] */
        /* TODO check if enough space */
        LD_uh( REG1_uh,    AT(RXT, XT_OFF_CODE_N))     /* xt.code_n */
        STORh( DTOPh,      AT(RXT, REG1, SZt))         /* xt[xt.code_n] = (int16)DTOP */
        ADD2(  IMM(2/SZt), REG1)
        DPOP(  DTOP)
        STORh( REG1h,      AT(RXT, XT_OFF_CODE_N))     /* xt.code_n += 2/SZt */
FUNC_END(_compile2s_)
#endif


#ifndef M4F_COMPILE_LIT2S_
/** ( -- ) must be followed by int16, append it to XT being compiled. */
FUNC_START(_compile_lit2s_)    /* [compile-lit-2s] */
        /* TODO check if enough space */
        LD_sh( REG2_sh,    AT(IP))                     /* b = int16             */
        LD_uh( REG1_uh,    AT(RXT, XT_OFF_CODE_N))     /* xt.code_n             */
        STORh( REG2h,      AT(RXT, REG1, SZt))         /* xt[xt.code_n] = b     */
        ADD2(  IMM(2/SZt), REG1)
        STORh( REG1h,      AT(RXT, XT_OFF_CODE_N))     /* xt.code_n ++          */
        NEXT2()                                        /* skip int16            */
FUNC_RAWEND(_compile_lit2s_)
#endif


#ifndef M4F_COMPILE_UNRESOLVED_JUMP
/**
 * ( -- jump_address jump_token ) must be followed by m4token, append it and T(-1) to XT being compiled,
 * then push to dstack jump_address (= # of tokens of XT being compiled) and m4token.
 */
FUNC_START(_compile_unresolved_jump_)    /* [compile-unresolved-jump] */
        /* TODO check if enough space */
        DPUSH( DTOP)
        LD_ut( REG2_ut,    AT(IP))                     /* b = jump_token             */
        LD_uh( DTOP_uh,    AT(RXT, XT_OFF_CODE_N))     /* dtop = code_n = xt.code_n  */
        STORt( REG2t,      AT(RXT, DTOP, SZt))         /* xt[code_n] = b             */
        INC1(  DTOP)                                   /* code_n ++                  */
#ifdef RFFFt
        STORt( RFFFt,      AT(RXT, DTOP, SZt))         /* xt[code_n] = -1            */
#else
        MOVE(  IMM(-1),    REG1)                       /* a = -1                     */
        STORt( REG1t,      AT(RXT, DTOP, SZt))         /* xt[code_n] = a             */
#endif
        INC1(  DTOP)                                   /* code_n ++                  */
        STORh( DTOPh,      AT(RXT, XT_OFF_CODE_N))     /* xt.code_n = code_n         */
        DPUSH( DTOP)                                   /* d2 = jump_address = code_n */
        MOVE(  REG2,       DTOP)                       /* dtop = jump_token = b      */
        NEXTT()                                        /* skip m4token               */
FUNC_RAWEND(_compile_unresolved_jump_)
#endif

