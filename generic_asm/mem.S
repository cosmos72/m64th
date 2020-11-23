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


/* ----------------------- fetch ----------------------- */

/* byte@    ( addr -- n )   m4th-user */
FUNC_START(byte_fetch)
        LD_sb(DTOP,    AT(DTOP))
FUNC_END(byte_fetch)


/* c@       ( addr -- u )   forth-core */
FUNC_START(c_fetch)
        LD_ub(DTOP,    AT(DTOP))
FUNC_END(c_fetch)


/* short@   ( addr -- n )   m4th-user */
FUNC_START(short_fetch)
        LD_sh(DTOP,    AT(DTOP))
FUNC_END(short_fetch)


/* ushort@  ( addr -- u )  m4th-user */
FUNC_START(ushort_fetch)
        LD_uh(DTOP,    AT(DTOP))
FUNC_END(ushort_fetch)


/* int@     ( addr -- n )  m4th-user */
FUNC_START(int_fetch)
        LD_sw(DTOP,    AT(DTOP))
FUNC_END(int_fetch)


/* uint@    ( addr -- u )  m4th-user */
FUNC_START(uint_fetch)
        LD_uw(DTOP,    AT(DTOP))
FUNC_END(uint_fetch)


/* @        ( addr -- x )  forth-core */
FUNC_START(fetch)
        LOAD(  DTOP, AT(DTOP))
FUNC_END(fetch)


/* 2@     ( addr -- y x )  forth-core */
FUNC_START(two_fetch)
        LOAD(  REG1, AT(DTOP, SZ))
        LOAD(  DTOP, AT(DTOP))
        DPUSH( REG1)
FUNC_END(two_fetch)


/* ----------------------- store ----------------------- */

#ifndef M4FC_STORE
/* c!      ( u addr -- )    forth-core */
FUNC_START(c_store)
        DPOP(  REG1)
        STORb( REG1,  AT(DTOP))
        DPOP___DTOP()
FUNC_END(c_store)
#endif


/* count    ( c-addr -- c-addr' u ) forth-core */
FUNC_START(count)
        ADDI(  DTOP,   1,      REG1)                  /* a = c-addr'                 */
        LD_ut( DTOP,   AT(DTOP))                      /* dtop = u                    */
        DPUSH( REG1)                                  /* ( c-addr' u               ) */
FUNC_END(count)


#ifndef M4FSHORT_STORE
/* short!   ( n addr -- ) m4th-user */
FUNC_START(short_store)
        DPOP(  REG1)
        STORh( REG1,  AT(DTOP))
        DPOP___DTOP()
FUNC_END(short_store)
#endif


#ifndef M4FINT_STORE
/* int!     ( n addr -- )   m4th-user */
FUNC_START(int_store)
        DPOP(  REG1)
        STORw( REG1,   AT(DTOP))
        DPOP___DTOP()
FUNC_END(int_store)
#endif


#ifndef M4FSTORE
/* !        ( n addr -- )   forth-core */
FUNC_START(store)
        DPOP(  REG1)
        STOR(  REG1,   AT(DTOP))
        DPOP___DTOP()
FUNC_END(store)
#endif


/* 2!       ( y x addr -- ) forth-core */
FUNC_START(two_store)
        LOAD(  REG1,   AT(DSTK))
        LOAD(  REG2,   AT(DSTK, SZ))
        STOR(  REG1,   AT(DTOP))
        STOR(  REG2,   AT(DTOP, SZ))
        LOAD(  DTOP,   AT(DSTK, SZ2))
        ADD2(IMM(SZ3), DSTK)
FUNC_END(two_store)


/* ----------------------- fetch[n] -------------------- */

#define DEF_FUNC_FETCH_TYP_OFF(typ, offset, LD_xx, size) \
FUNC_START(typ##_fetch_##offset)               \
        LD_xx(DTOP,    AT(DTOP, offset*size))  \
FUNC_END(typ##_fetch_##offset)

#define DEF_FUNC_FETCH_TYP(typ, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 1, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 2, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 3, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 4, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 5, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 6, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 7, LD_xx, size) \
        DEF_FUNC_FETCH_TYP_OFF(typ, 8, LD_xx, size)

#define DEF_FUNC_FETCH() \
        DEF_FUNC_FETCH_TYP(char,   LD_ub, 1) \
        DEF_FUNC_FETCH_TYP(byte,   LD_sb, 1) \
        DEF_FUNC_FETCH_TYP(short,  LD_sh, 2) \
        DEF_FUNC_FETCH_TYP(ushort, LD_uh, 2) \
        DEF_FUNC_FETCH_TYP(int,    LD_sw, 4) \
        DEF_FUNC_FETCH_TYP(uint,   LD_uw, 4) \
        DEF_FUNC_FETCH_TYP(cell,   LOAD, SZ)

DEF_FUNC_FETCH()

/* ----------------------- store[n] -------------------- */

#define DEF_FUNC_STORE_TYP_OFF(typ, offset, ST_xx, size) \
FUNC_START(typ##_store_##offset)                         \
        DPOP(  REG1)                                     \
        ST_xx( REG1, AT(DTOP, offset*size))              \
        DPOP___DTOP()                                    \
FUNC_END(typ##_store_##offset)

#define DEF_FUNC_STORE_TYP(typ, ST_xx, size) \
        DEF_FUNC_STORE_TYP_OFF(typ, 1, ST_xx, size) \
        DEF_FUNC_STORE_TYP_OFF(typ, 2, ST_xx, size) \
        DEF_FUNC_STORE_TYP_OFF(typ, 3, ST_xx, size) \
        DEF_FUNC_STORE_TYP_OFF(typ, 4, ST_xx, size) \
        DEF_FUNC_STORE_TYP_OFF(typ, 5, ST_xx, size) \
        DEF_FUNC_STORE_TYP_OFF(typ, 6, ST_xx, size) \
        DEF_FUNC_STORE_TYP_OFF(typ, 7, ST_xx, size)

#define DEF_FUNC_STORE() \
        DEF_FUNC_STORE_TYP(char,   STORb, 1) \
        DEF_FUNC_STORE_TYP(short,  STORh, 2) \
        DEF_FUNC_STORE_TYP(int,    STORw, 4) \
        DEF_FUNC_STORE_TYP(cell,   STOR, SZ)

DEF_FUNC_STORE()

/* ----------------------- misc ------------------------ */

#ifndef M4FCMOVE
/* cmove ( src_addr dst_addr u -- ) 'string' word set */
FUNC_START(cmove)
        TOKEN_CALL_NOTHROW(FUNC(cmove_count), cmove.0)   /* ( src' dst'    ) */
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(IMM(SZ2), DSTK)
FUNC_END(cmove)
#endif /* M4FCMOVE */


/* crc-cell ( x -- crc ) m4th-user: compute CRC32c of a cell */
FUNC_START(crc_cell)
        DPUSH__DTOP()                          /* ( x _                  ) */
        STOR(  DSTK,   AT(DSTK, -SZ))
        SUB2( IMM(SZ), DSTK)                   /* ( x &x _               ) */
        MOVE( IMM(SZ), DTOP)                   /* ( x &x SZ              ) */
        TOKEN_CALL_NOTHROW(FUNC(crc_string), crc_cell.0) /* ( x crc                ) */
        ADD2( IMM(SZ), DSTK)                   /* ( crc                  ) */
FUNC_END(crc_cell)


#ifndef M4FDIV_STRING
/* /string ( c-addr u n -- c-addr' u' )  forth-string */
FUNC_START(div_string)
        MOVE(  DTOP,   REG1)           /* a = n       */
        DPOP___DTOP()                  /* dtop = u    */
        LOAD(  REG2,   AT(DSTK))       /* b = c-addr  */
        SUB2(  REG1,   DTOP)           /* dtop -= n   */
        ADD2(  REG1,   REG2)           /* c-addr += n */
        STOR(  REG2,   AT(DSTK))
FUNC_END(div_string)
#endif /* M4FDIV_STRING */


/* ( c-addr u ch -- u' ) get index of char or CR */
FUNC_START(line_find_char)
        ZERO(  REG1)                   /* a = index = 0 */
        DPOP2( REG2,   REG3)           /* b = max = u,  c = c-addr    */
        JZ(    REG2,   TO(line_find_char.done))
LABEL(line_find_char.loop)
        LD_ub( REG4,   AT(REG3, REG1, 1)) /* d = c-addr[index] */
        JEQ(   REG4,   DTOP,   TO(line_find_char.done))
        JEQ(   REG4,   IMM(10),TO(line_find_char.done))
        JEQ(   REG4,   IMM(13),TO(line_find_char.done))
        INC1(  REG1)
        JB(    REG1,   REG2,   TO(line_find_char.loop))
LABEL(line_find_char.done)
        MOVE(  REG1,   DTOP)
FUNC_END(line_find_char)


#ifndef M4FROLL
/* ( xu xu_1 ... x1 x0 u -- xu_1 ... x1 x0 xu ) */
FUNC_START(roll)
        LOAD(  REG1,   AT(DSTK, DTOP, SZ)) /* a = xu                             */
        ADDI(  DSTK,   SZ,   REG2)         /* b = address of x1                  */
        STOR(  REG1,   AT(DSTK, -SZ))      /* ( xu xu_1 ... x1 x0 xu u         ) */
        STOR(  DSTK,   AT(DSTK, -SZ2))     /* ( xu xu_1 ... x1 x0 xu &x0 u     ) */
        STOR(  REG2,   AT(DSTK, -SZ3))     /* ( xu xu_1 ... x1 x0 xu &x0 &x1 u ) */
        SUB2(IMM(SZ3), DSTK)
        TOKEN_CALL_NOTHROW(FUNC(move), roll.0)       /* ( xu_1 ... x1 x0 x0 xu )           */
        ADD2(IMM(SZ),  DSTK)               /* ( xu_1 ... x1 x0 xu    )           */
FUNC_END(roll)
#endif


#ifndef M4FMINUS_ROLL
/* ( xu xu_1 ... x1 x0 u -- x0 xu xu_1 ... x1 ) */
FUNC_START(minus_roll)
        ADD4(  DSTK,   DTOP, PSZ, REG0)    /* @ = address of xu   */
        LOAD(  REG1,   AT(DSTK))           /* a = x0              */
        ADDI(  DSTK,   SZ,   REG2)         /* b = address of x1   */
        STOR(  REG1,   AT(DSTK, -SZ))      /* ( xu xu_1 ... x1 x0 x0 u             ) */
        STOR(  REG0,   AT(DSTK, -SZ2))     /* ( xu xu_1 ... x1 x0 x0 &xu u         ) */
        STOR(  REG2,   AT(DSTK, -SZ3))     /* ( xu xu_1 ... x1 x0 x0 &xu &x1 u     ) */
        STOR(  DSTK,   AT(DSTK, -SZ4))     /* ( xu xu_1 ... x1 x0 x0 &xu &x1 &x0 u ) */
        SUB2(IMM(SZ4), DSTK)
        TOKEN_CALL_NOTHROW(FUNC(move), minus_roll.0) /* ( xu xu xu_1 ... x1 x0 &xu           ) */
        JUMP(  FUNC(store))                /* ( x0 xu xu_1 ... x1                  ) */
FUNC_RAWEND(minus_roll)
#endif


#ifndef M4FTWO_ROLL
/* ( du du_1 ... d1 d0 u -- du_1 ... d1 d0 du ) */
FUNC_START(two_roll)
        SHL2(IMM(1),   DTOP)               /* dtop <<= 1                         */
        ADDI(  DSTK,   SZ2,  REG1)         /* a = address of d1                  */
        ADD4(  DSTK,   DTOP, PSZ, REG2)    /* b = address of du                  */
        LOAD(  REG3,   AT(REG2))           /* c = xu  \ du = ( yu xu )           */
        LOAD(  REG4,   AT(REG2, SZ))       /* d = yu  /                          */
        STOR(  REG4,   AT(DSTK, -SZ))      /* ( du ... d0 yu u                 ) */
        STOR(  REG3,   AT(DSTK, -SZ2))     /* ( du ... d0 du u                 ) */
        STOR(  DSTK,   AT(DSTK, -SZ3))     /* ( du ... d0 du &d0 u             ) */
        STOR(  REG1,   AT(DSTK, -SZ4))     /* ( du ... d0 du &d0 &d1 u         ) */
        SUB2(IMM(SZ4), DSTK)
        TOKEN_CALL_NOTHROW(FUNC(move), two_roll.0)   /* ( du_1 ... d0 d0 du              ) */
        JUMP(    FUNC(two_nip))            /* ( du_1 ... d0 du                 ) */
FUNC_RAWEND(two_roll)
#endif


#ifndef M4FMINUS_TWO_ROLL
/* ( dx_u ... d1 d0 u -- d0 dx_u ... d1 ) */
FUNC_START(minus_two_roll)
        SHL2(IMM(1),   DTOP)               /* dtop <<= 1                         */
        ADD4(  DSTK,   DTOP, PSZ, REG0)    /* @ = address of du                  */
        LOAD(  REG1,   AT(DSTK))           /* a = x0  \ d0 = ( y0 x0 )           */
        LOAD(  REG2,   AT(DSTK, SZ))       /* b = y0  /                          */
        ADDI(  DSTK,   SZ2,   REG3)        /* c = address of x1                  */
        STOR(  REG2,   AT(DSTK, -SZ))      /* ( du ... d0 y0 u                 ) */
        STOR(  REG1,   AT(DSTK, -SZ2))     /* ( du ... d0 d0 u                 ) */
        STOR(  REG0,   AT(DSTK, -SZ3))     /* ( du ... d0 d0 &du u             ) */
        STOR(  REG3,   AT(DSTK, -SZ4))     /* ( du ... d0 d0 &du &d1 u         ) */
        STOR(  DSTK,   AT(DSTK, -SZ5))     /* ( du ... d0 d0 &du &d1 &d0 u     ) */
        SUB2(IMM(SZ5), DSTK)
        TOKEN_CALL_NOTHROW(FUNC(move), minus_two_roll.0) /* ( du du ... d1 d0 &du            ) */
        JUMP(    FUNC(two_store))              /* ( d0 du ... d1                   ) */
FUNC_RAWEND(minus_two_roll)
#endif


/* ----------------------- string ---------------------- */

/**
 * string-ci=  ( c-addr1 c-addr2 u -- c-addr1 c-addr2 u t|f )
 * m4th-user: compare two strings, ignoring case
 */
FUNC_START(string_ci_equal)
        LOAD(  REG2,   AT(DSTK))       /* b = addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = addr1 */
        DPUSH__DTOP()
#ifdef __x86_64__ /* we need an additional register */
#define M4FSTRING_CI_EQUAL_USE_RTOP
#endif
#ifdef M4FSTRING_CI_EQUAL_USE_RTOP
        RPUSH( RTOP)
#endif
        JEQ(   REG1,   REG2,    TO(string_ci_equal.true))   /* addr1 == addr2 */
        JZ(    DTOP,            TO(string_ci_equal.true))   /* u == 0         */
        ZERO(  REG0)
        JB(    DTOP,   IMM(SZ), TO(string_ci_equal.byte))

        SUB2(IMM(SZ),  DTOP)
#ifdef M4FSTRING_CI_EQUAL_USE_RTOP
        movabs IMM(0x2020202020202020), RTOP;
#endif
LABEL(string_ci_equal.cell)
        LOAD(  REG3,   AT(REG1, REG0, 1))
        LOAD(  REG4,   AT(REG2, REG0, 1))
        JNE(   REG3,   REG4,    TO(string_ci_equal.cell.fallback))
        ADD2(IMM(SZ),  REG0)
        JBE(   REG0,   DTOP,    TO(string_ci_equal.cell))
        ADD2(IMM(SZ),  DTOP)
        JB(    REG0,   DTOP,    TO(string_ci_equal.byte))
LABEL(string_ci_equal.true)
        MOVE(  IMM_1,  DTOP)
        JUMP(  TO(string_ci_equal.done))

LABEL(string_ci_equal.cell.fallback)
#ifdef M4FSTRING_CI_EQUAL_USE_RTOP
        ORR2(  RTOP,   REG3)
        ORR2(  RTOP,   REG4)
#else
        ORR2(  IMM(0x2020202020202020), REG3)
        ORR2(  IMM(0x2020202020202020), REG4)
#endif
        JNE(   REG3,   REG4,    TO(string_ci_equal.false))
        ADD2(IMM(SZ),  DTOP)

LABEL(string_ci_equal.byte)
        LD_ub( REG3,   AT(REG1, REG0, 1))
        LD_ub( REG4,   AT(REG2, REG0, 1))
        JNE(   REG3w,  REG4w,   TO(string_ci_equal.slow))
LABEL(string_ci_equal.byte.next)
        INC1(  REG0)
        JB(    REG0,   DTOP,    TO(string_ci_equal.byte))
        MOVE(  IMM_1,  DTOP)
        JUMP(  TO(string_ci_equal.done))

LABEL(string_ci_equal.slow)
        ORR2(  IMM('a'-'A'), REG3w)
        ORR2(  IMM('a'-'A'), REG4w)
        JNE(   REG3w,  REG4w,   TO(string_ci_equal.false))
        JB(    REG3w,  IMM('a'),TO(string_ci_equal.false))
        JA(    REG3w,  IMM('z'),TO(string_ci_equal.false))
        JB(    REG4w,  IMM('a'),TO(string_ci_equal.false))
        JA(    REG4w,  IMM('z'),TO(string_ci_equal.false))
        JUMP(  TO(string_ci_equal.byte.next))

LABEL(string_ci_equal.false)
        ZERO(  DTOP)

LABEL(string_ci_equal.done)
#ifdef M4FSTRING_CI_EQUAL_USE_RTOP
        RPOP(  RTOP)          /* restore RTOP */
#endif
FUNC_END(string_ci_equal)


/**
 * string-find-blank ( c-addr u -- u' )
 * m4th-user: return index of first blank (i.e. char <= 32) in string.
 * return string length if not found.
 */
FUNC_START(string_find_blank)
        DPOP(  REG2)                                   /* b = addr */
        JZ(    DTOP,   FUNC_RET(string_find_blank))   /* u == 0   */
        ZERO(  REG1)
LABEL(string_find_blank.loop)
        LD_ub( REG3,   AT(REG2, REG1, 1))
        JBE(   REG3w,  IMM(32),TO(string_find_blank.found))
        INC1(  REG1)
        JB(    REG1,   DTOP,   TO(string_find_blank.loop))
LABEL(string_find_blank.found)
        MOVE(  REG1,   DTOP)
FUNC_END(string_find_blank)


/**
 * string-find-char ( c-addr u ch -- u' )
 * m4th-user: return index of first ch in string.
 * return string length if not found.
 */
FUNC_START(string_find_char)
        DPOP2( REG4,   REG2)                            /* @ = u,  b = addr */
        ZERO(  REG1)
        JZ(    REG4,   TO(string_find_char.found))      /* u == 0           */
LABEL(string_find_char.loop)
        LD_ub( REG3,   AT(REG2, REG1, 1))
        JEQ(   REG3w,  DTOPw,  TO(string_find_char.found))
        INC1(  REG1)
        JB(    REG1,   REG4,   TO(string_find_char.loop))
LABEL(string_find_char.found)
        MOVE(  REG1,   DTOP)
FUNC_END(string_find_char)

/*
 * string-find-nonblank ( c-addr u -- u' )
 * m4th-user: get index of first non-blank (i.e. char > 32) in string.
 * return string length if not found.
 */
FUNC_START(string_find_nonblank)
        DPOP(  REG2)                                   /* b = addr      */
        JZ(    DTOP,   FUNC_RET(string_find_nonblank))/* u == 0       */
        ZERO(  REG1)                                   /* a = index = 0 */
LABEL(string_find_nonblank.loop)
        LD_ub( REG3,   AT(REG2, REG1, 1))              /* c = addr[index] */
        JA(    REG3w,  IMM(32),TO(string_find_nonblank.found))
        INC1(  REG1)
        JB(    REG1,   DTOP,   TO(string_find_nonblank.loop))
LABEL(string_find_nonblank.found)
        MOVE(  REG1,   DTOP)
FUNC_END(string_find_nonblank)


/*
 * string>lower ( c-addr-src c-addr-dst u -- c-addr-dst u )
 * m4th-user: copy a string converting it to lower case
 */
FUNC_START(string_to_lower)
        LOAD(  REG2,   AT(DSTK))           /* b = dst = c-addr-dst   */
        LOAD(  REG1,   AT(DSTK, SZ))       /* a = src = c-addr-src   */
        STOR(  DTOP,   AT(DSTK))           /* ( c-addr-src u u     ) */
        STOR(  REG2,   AT(DSTK, SZ))       /* ( c-addr-dst u u     ) */
        JZ(    DTOP,            TO(string_to_lower.done))
        ADD2(  DTOP,   REG2)               /* b = dst + u            */
        ADD2(  DTOP,   REG1)               /* a = src + u            */
        NEG1(  DTOP)                       /* n = -u                 */
        JA(    DTOP,   IMM(-SZ),TO(string_to_lower.byte))   /* < SZ bytes         */
#ifdef __x86_64__
#define M4FSTRING_TO_LOWER_USE_REG0
        movabs IMM(0x2020202020202020), REG0;
#endif
LABEL(string_to_lower.cell)
        /* copy SZ bytes at time */
#ifdef M4FSTRING_TO_LOWER_USE_REG0
        MOVE(  REG0,   REG4)               /* d = mask               */
        LOAD(  REG3,   AT(REG1, DTOP, 1))  /* c = src[i..i+7]        */
        ORR2(  REG3,   REG4)               /* d = src[i..i+7] | mask */
#elif defined(ORR3) && SZ == 8
        LOAD(  REG3,   AT(REG1, DTOP, 1))  /* c = src[i..i+7]        */
        ORR3(  REG3,   IMM(0x2020202020202020),REG4) /* d = src[i..i+7] | mask */
#else
#error unsupported architecture, please fix 'string_to_lower'
#endif
        JNE(   REG3,   REG4,    TO(string_to_lower.byte))
        STOR(  REG3,   AT(REG2, DTOP, 1))  /* dst[i..i+7] = src[i..i+7] */
        ADD2(IMM(SZ),  DTOP)               /* n += SZ                */
        JAE(   DTOP,   IMM(-SZ),TO(string_to_lower.cell))
        JZ(    DTOP,            TO(string_to_lower.done))

LABEL(string_to_lower.byte)
        /* copy 1 byte at time */
        MOVI(  0x20,   REG4)               /* d = mask               */
        LD_ub( REG3,   AT(REG1, DTOP, 1))  /* c = ch = src[i]        */
        ORR2(  REG3,   REG4)               /* d = ch | mask          */
        JNE(   REG3,   REG4,    TO(string_to_lower.slow))
        STORb( REG3,   AT(REG2, DTOP, 1))  /* dst[i] = ch            */
        INC1(  DTOP)                       /* n++                    */
        JNZ(   DTOP,            TO(string_to_lower.byte))
        JUMP(                   TO(string_to_lower.done))

LABEL(string_to_lower.slow)
        /* lowercase and copy 1 byte at time */
        LD_ub( REG3,   AT(REG1, DTOP, 1))  /* c = ch = src[i]        */
        JB(    REG3,   IMM('A'),TO(string_to_lower.copy))
        JA(    REG3,   IMM('Z'),TO(string_to_lower.copy))
        ORR2(IMM(0x20),REG3)               /* c = lower(ch)          */
LABEL(string_to_lower.copy)
        STORb( REG3,   AT(REG2, DTOP, 1))  /* dst[i] = lower(ch)     */
        INC1(  DTOP)                       /* n++                    */
        JNZ(   DTOP,            TO(string_to_lower.slow))

LABEL(string_to_lower.done)
        DPOP___DTOP()                      /* ( c-addr-dst u       ) */
FUNC_END(string_to_lower)
