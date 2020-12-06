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


/* attempt to narrow a double-width unsigned number            */
/* ?du>u ( du -- u t | du f )                                  */
FUNC_START(du_to_u_q)
        JNZ(   DTOP,   TO(du_to_u_q.false))    /* dtop = du.high               */

LABEL(du_to_u_q.true)
#ifdef RFFF
        MOVE(  RFFF,   DTOP)                   /* ( u t                      ) */
#else
        MOVI(  -1,     DTOP)                   /* ( u t                      ) */
#endif
        JUMP(  FUNC_RET(du_to_u_q))

LABEL(du_to_u_q.false)
        DPUSH__DTOP()                          /* ( du _                     ) */
        ZERO(DTOP)                             /* ( du f                     ) */
FUNC_END(du_to_u_q)


/* attempt to narrow two double-width unsigned numbers         */
/* 2du>2u? ( du1 du2 -- u1 u2 t | du1 du2 f )                  */
FUNC_START(two_du_to_2u_q)
        JNZ(   DTOP,   TO(two_du_to_2u_q.false))  /* dtop = du2.high              */
        LOAD(  REG1,   AT(DSTK, SZ))           /* a = du1.high                 */
        JNZ(   REG1,   TO(two_du_to_2u_q.false))

LABEL(two_du_to_2u_q.true)
        LOAD(  REG2,   AT(DSTK))               /* b = du2.low                  */
#ifdef RFFF
        MOVE(  RFFF,   DTOP)                   /* ( u1 _ _ t                 ) */
#else
        MOVI(  -1,     DTOP)                   /* ( u1 _ _ t                 ) */
#endif
        STOR(  REG2,   AT(DSTK, SZ))           /* ( u1 u2 _ t                ) */
        ADD2(IMM(SZ),  DSTK)                   /* ( u1 u2 t                  ) */
        JUMP(  FUNC_RET(two_du_to_2u_q))

LABEL(two_du_to_2u_q.false)
        DPUSH__DTOP()                          /* ( du1 du2 _                ) */
        ZERO(DTOP)                             /* ( du1 du2 f                ) */
FUNC_END(two_du_to_2u_q)


FUNC_START(two_drop)       /* 2drop    */
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(  IMM(SZ2),   DSTK)
FUNC_END(two_drop)


FUNC_START(two_dup)        /* 2dup     */
        LOAD(  REG1,   AT(DSTK))
        DPUSH2(DTOP,   REG1)
FUNC_END(two_dup)

#ifndef M4FTWO_NIP
FUNC_START(two_nip)        /* 2nip     m4th-user */
        LOAD(  REG1,   AT(DSTK))
        STOR(  REG1,   AT(DSTK, SZ2))
        ADD2(  IMM(SZ2),   DSTK)
FUNC_END(two_nip)
#endif


FUNC_START(two_over)       /* 2over    ( a b c d -- a b c d a b ) */
        LOAD(  REG1,   AT(DSTK, SZ2))  /* a        */
        DPUSH2(DTOP,   REG1)           /* ( a b c d a _ ) */
        LOAD(  DTOP,   AT(DSTK, SZ3))  /* ( a b c d a b ) */
FUNC_END(two_over)


#ifndef M4FTWO_ROT
FUNC_START(two_rot)       /* 2rot      ( a b c d e f -- c d e f a b ) */
        LOAD(  REG1,   AT(DSTK, SZ4))  /* a        */
        LOAD(  REG2,   AT(DSTK, SZ3))  /* b        */
        LOAD(  REG3,   AT(DSTK, SZ2))  /* c        */
        LOAD(  REG4,   AT(DSTK, SZ))   /* d        */
        LOAD(  REG0,   AT(DSTK))       /* e        */
        STOR(  REG3,   AT(DSTK, SZ4))  /* ( c _ _ _ _ _ ) */
        STOR(  REG4,   AT(DSTK, SZ3))  /* ( c d _ _ _ _ ) */
        STOR(  REG0,   AT(DSTK, SZ2))  /* ( c d e _ _ _ ) */
        STOR(  DTOP,   AT(DSTK, SZ))   /* ( c d e f _ _ ) */
        STOR(  REG1,   AT(DSTK))       /* ( c d e f a _ ) */
        MOVE(  REG2,   DTOP)           /* ( c d e f a b ) */
FUNC_END(two_rot)
#endif


#ifndef M4FMINUS_TWO_ROT
FUNC_START(minus_two_rot)  /* -2rot    ( a b c d e f -- e f a b c d ) */
        LOAD(  REG0,   AT(DSTK))       /* e        */
        LOAD(  REG4,   AT(DSTK, SZ))   /* d        */
        LOAD(  REG3,   AT(DSTK, SZ2))  /* c        */
        LOAD(  REG2,   AT(DSTK, SZ3))  /* b        */
        LOAD(  REG1,   AT(DSTK, SZ4))  /* a        */
        STOR(  REG3,   AT(DSTK))       /* ( _ _ _ _ c _ ) */
        STOR(  REG2,   AT(DSTK, SZ))   /* ( _ _ _ b c _ ) */
        STOR(  REG1,   AT(DSTK, SZ2))  /* ( _ _ a b c _ ) */
        STOR(  DTOP,   AT(DSTK, SZ3))  /* ( _ f a b c _ ) */
        STOR(  REG0,   AT(DSTK, SZ4))  /* ( e f a b c _ ) */
        MOVE(  REG4,   DTOP)           /* ( e f a b c d ) */
FUNC_END(minus_two_rot)
#endif


#ifndef M4FTWO_SWAP
/* remember: x86 instruction 'xchg' with memory operand is SLOW */
FUNC_START(two_swap)       /* 2swap    ( a b c d -- c d a b ) */
        LOAD(  REG1,   AT(DSTK))
        LOAD(  REG2,   AT(DSTK, SZ))
        LOAD(  REG3,   AT(DSTK, SZ2))
        STOR(  DTOP,   AT(DSTK, SZ))
        STOR(  REG1,   AT(DSTK, SZ2))
        STOR(  REG3,   AT(DSTK))
        MOVE(  REG2,   DTOP)
FUNC_END(two_swap)
#endif



#ifndef M4FTWO_TUCK
/* ( a b c d -- c d a b c d ) */
FUNC_START(two_tuck)
        LOAD(  REG3,   AT(DSTK))           /* load c                             */
        LOAD(  REG2,   AT(DSTK, SZ))       /* load b                             */
        LOAD(  REG1,   AT(DSTK, SZ2))      /* load a                             */
        STOR(  DTOP,   AT(DSTK, SZ))       /* ( _ d _ _                        ) */
        STOR(  REG3,   AT(DSTK, SZ2))      /* ( c d _ _                        ) */
        STOR(  REG1,   AT(DSTK))           /* ( c d a _                        ) */
        DPUSH2(REG2,   REG3)               /* ( c d a b c _                    ) */
FUNC_END(two_tuck)
#endif


#ifndef M4FTWO_DUP_TWO_TO_R
FUNC_START(two_dup_two_to_r)   /* 2dup 2>r  ( a b -- a b ) ( R: -- a b ) m4th-user */
        LOAD(  REG1,       AT(DSTK))
        RPUSH2(RTOP,       REG1)
        MOVE(  DTOP,       RTOP)
FUNC_END(two_dup_two_to_r)
#endif


#ifndef M4FTWO_TO_R
FUNC_START(two_to_r)           /* 2>r      */
        DPOP(  REG1)
        RPUSH2(RTOP,       REG1)
        MOVE(  DTOP,       RTOP)
        DPOP___DTOP()
FUNC_END(two_to_r)
#endif


#ifndef M4FTWO_R_FROM
FUNC_START(two_r_from)         /* 2r>      */
        DPUSH__DTOP()
        MOVE(  RTOP,       DTOP)
        RPOP2( REG1,       RTOP)
        DPUSH( REG1)
FUNC_END(two_r_from)
#endif


FUNC_START(two_r_from_two_drop)/* 2r>2drop  m4th-user */
        LOAD(  RTOP,       AT(RSTK, SZ))
        ADD2(  IMM(SZ2),   RSTK)
FUNC_END(two_r_from_two_drop)


#ifndef M4FTWO_R_FETCH
FUNC_START(two_r_fetch)        /* 2r@      */
        STOR(  DTOP,       AT(DSTK, -SZ))
        LOAD(  REG1,       AT(RSTK))
        MOVE(  RTOP,       DTOP)
        STOR(  REG1,       AT(DSTK, -SZ2))
        SUB2(  IMM(SZ2),   DSTK)
FUNC_END(two_r_fetch)
#endif
