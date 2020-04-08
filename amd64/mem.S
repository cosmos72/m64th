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

#define M4FSTORE
FUNC_START(store)          /* ! */
        LOAD(  REG1,  AT(DSTK))
        STOR(  REG1,  AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(store)

#define M4FC_STORE
FUNC_START(c_store)        /* c! */
        LOAD(  REG1,  AT(DSTK))
        STORb( REG1,  AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(c_store)


#define M4FSHORT_STORE
FUNC_START(short_store)    /* short! */
        LOAD(  REG1,  AT(DSTK))
        STORh( REG1,  AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(short_store)


#define M4FINT_STORE
FUNC_START(int_store)      /* int! */
        LOAD(  REG1,  AT(DSTK))
        STORw( REG1,  AT(DTOP))
        LOAD(  DTOP,  AT(DSTK, SZ))
        ADD2(  IMM(SZ2), DSTK)
FUNC_END(int_store)


#define M4FDIV_STRING
/* /string ( c-addr u n -- c-addr' u' )  'string' word set */
FUNC_START(div_string)
        MOVE(  DTOP,   REG1)           /* a = n       */
        DPOP___DTOP()                  /* dtop = u    */
        SUB2(  REG1,   DTOP)           /* dtop -= n   */
        ADD2(  REG1,   AT(DSTK))       /* c-addr += n */
FUNC_END(div_string)


/* cmove ( src_addr dst_addr u -- ) 'string' word set */
FUNC_START(cmove)
        ASM_CALL(      FUNC(cmove_star))   /* ( src' dst'    ) */
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(IMM(SZ2), DSTK)
FUNC_END(cmove)


/* cmove* ( src_addr dst_addr u -- src_addr+u dst_addr+u ) m4th-user */
FUNC_START(cmove_star)
        MOVE(  DSTK,   %rbx)           /* save DSTK == %rsi */
        MOVE(  RSTK,   %rdx)           /* save RSTK == %rdi */
        LOAD(  %rsi,   AT(%rbx, SZ))   /* src               */
        LOAD(  %rdi,   AT(%rbx))       /* dst               */
        MOVE(  DTOP,   %rcx)           /* n                 */

        cld;                           /* forward direction */
        rep    movsb (%rsi), (%rdi);   /* copy string       */

        STOR(  %rsi,   AT(%rbx, SZ))   /* ( src' dst u    ) */
        MOVE(  %rdi,   DTOP)           /* ( src' _ dst'   ) */
        ADDI(  %rbx,   SZ,     DSTK)   /* reload DSTK       */
        MOVE(  %rdx,   RSTK)           /* reload RSTK       */
FUNC_END(cmove_star)


/* move ( src_addr dst_addr u -- ) */
FUNC_START(move)
        MOVE(  DSTK,   %rbx)           /* save DSTK == %rsi */
        MOVE(  RSTK,   %rdx)           /* save RSTK == %rdi */
        LOAD(  %rsi,   AT(%rbx, SZ))   /* src               */
        LOAD(  %rdi,   AT(%rbx))       /* dst               */
        MOVE(  DTOP,   %rcx)           /* n                 */

        cld;                           /* forward direction */
        JAE(   %rsi,   %rdi,    TO(move.loop))
        lea    -SZ(%rsi, %rcx, SZ),    %r8; /* src top      */
        JB(    %r8,    %rdi,    TO(move.loop)) /* overlapping? */

        std;                           /* backward direction*/
        MOVE(  %r8,    %rsi)                /* copy from top*/
        lea    -SZ(%rdi, %rcx, SZ),    %rdi;/* copy to top  */

LABEL(move.loop)
        rep    movsq (%rsi), (%rdi);   /* copy 8 bytes per iteration */
        cld;
        ADDI(  %rbx,   SZ3,    DSTK)   /* reload DSTK       */
        LOAD(  DTOP,   AT(%rbx,SZ2))   /* reload dstack top */
        MOVE(  %rdx,   RSTK)           /* reload RSTK       */
FUNC_END(move)


/* crc-string ( c-addr u -- crc ) compute CRC32c of a string */
FUNC_START(crc_string)     /* crc-string ( c-addr u -- crc ) m4th-user */
        MOVE(  DTOP,   REG2)               /* b = u                    */
        MOVE(  RFFFw,  REG3w)              /* c = 0xffffffff           */
        DPOP___DTOP()                      /* dtop = c-addr            */
        JZ(    REG2,   TO(crc_string.done))
        ZERO(  REG0)                       /* @ = 0                    */
        ADDROF_4G(m4th_crctable,   REG4)   /* d = table                */
FUNC_ALIGN()
LABEL(crc_string.loop)
        LD_ub( REG1,   AT(DTOP, REG0, 1))  /* a = c-addr[@] = str[i]   */
        INC1(  REG0)                       /* @++                      */
        XOR2(  REG3b,  REG1b)              /* a = str[i] ^ (crc & 0xFF)*/
        SHR2(  IMM(8), REG3w)              /* crc >>= 8                */
        LD_uw( REG1,   AT(REG4, REG1, SZ)) /* a = table[a]             */
        XOR2(  REG1w,  REG3w)              /* crc ^= table[a]          */
        JB(    REG0,   REG2,   TO(crc_string.loop))
LABEL(crc_string.done)
        NOT1(  REG3w)
        MOVE(  REG3w,  DTOPw)
FUNC_END(crc_string)


FUNC_START(string_equal)   /* string=  ( addr1 addr2 u -- addr1 addr2 u t|f ) m4th-user */
        LOAD(  REG2,   AT(DSTK))       /* b = addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = addr1 */
        DPUSH( DTOP)
        JEQ(   REG1,   REG2,    TO(string_equal.true))   /* addr1 == addr2 */
        JZ(    DTOP,            TO(string_equal.true))   /* u == 0         */
        ZERO(  REG4)
        JB(    DTOP,   IMM(8),  TO(string_equal.byte))   /* < 8 bytes */
        SUB2(  IMM(8), DTOP)
LABEL(string_equal.cell)
        LOAD(  REG3,   AT(REG1, REG4, 1))
        JNE(   REG3,   AT(REG2, REG4, 1),  TO(string_equal.false)) /* x86 specific */
        ADD2(  IMM(8), REG4)
        JB(    REG4,   DTOP,    TO(string_equal.cell))      /* > 8 bytes left ? */
        LOAD(  REG3,   AT(REG1, DTOP, 1))                   /* compare last 8 bytes */
        LOAD(  REG4,   AT(REG2, DTOP, 1))
        JNE(   REG3,   REG4,    TO(string_equal.false))
        JUMP(                   TO(string_equal.true))
LABEL(string_equal.byte)
        LD_ub( REG3,   AT(REG1, REG4, 1))
        JNE(   REG3b,  AT(REG2, REG4, 1),  TO(string_equal.false)) /* x86 specific */
        INC1(  REG4)
        JB(    REG4,   DTOP,    TO(string_equal.byte))
LABEL(string_equal.true)
        MOVE(  RFFF,   DTOP)
        NEXT()
LABEL(string_equal.false)
        ZERO(  DTOP)
FUNC_END(string_equal)
