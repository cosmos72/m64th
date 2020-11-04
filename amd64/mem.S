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


#define M4FDIV_STRING
/* /string ( c-addr u n -- c-addr' u' )  'string' word set */
FUNC_START(div_string)
        MOVE(  DTOP,   REG1)           /* a = n       */
        DPOP___DTOP()                  /* dtop = u    */
        SUB2(  REG1,   DTOP)           /* dtop -= n   */
        ADD2(  REG1,   AT(DSTK))       /* c-addr += n */
FUNC_END(div_string)


#define M4FCMOVE /* defined near cmove* to encode a shorter jump */
/* cmove ( src_addr dst_addr u -- ) 'string' word set */
FUNC_START(cmove)
        TOKEN_CALL(    FUNC(cmove_star), cmove.0)   /* ( src' dst'    ) */
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(IMM(SZ2), DSTK)
FUNC_END(cmove)


/* cmove* ( src_addr dst_addr u -- src_addr+u dst_addr+u ) m4th-user */
FUNC_START(cmove_star)
        ADDI(  DSTK,   SZ,     %rdx)   /* %rdx = DSTK + SZ           */
        LOAD(  %rdi,   AT(DSTK))       /* %rdi = dst                 */
        LOAD(  %rsi,   AT(DSTK, SZ))   /* %rsi = src: clobbers DSTK  */
        MOVE(  DTOP,   %rcx)           /* %rcx = u                   */

        cld;                           /* forward direction          */
        rep    movsb (%rsi), (%rdi);   /* copy bytes                 */

        STOR(  %rsi,   AT(%rdx))       /* ( src' dst u  )            */
        MOVE(  %rdi,   DTOP)           /* ( src' _ dst' )            */
        MOVE(  %rdx,   DSTK)           /* reload DSTK                */
FUNC_END(cmove_star)


/* -cmove* ( src_addr dst_addr u -- src_addr-u dst_addr-u ) m4th-user */
/* backward copy u bytes from src-1..src-u to dst-1..dst-u and return updated addresses */
FUNC_START(minus_cmove_star)
        ADDI(  DSTK,   SZ,     %rdx)   /* %rdx = DSTK + SZ           */
        LOAD(  %rdi,   AT(DSTK))       /* %rdi = dst                 */
        LOAD(  %rsi,   AT(DSTK, SZ))   /* %rsi = src: clobbers DSTK  */
        MOVE(  DTOP,   %rcx)           /* %rcx = u                   */
        DEC1(  %rsi)
        DEC1(  %rdi)

        std;                           /* backward direction         */
        rep    movsb (%rsi), (%rdi);   /* copy bytes                 */
        cld;                           /* restore direction flag     */

        INC1(  %rsi)
        ADDI(  %rdi,   1, DTOP)        /* ( src  _ dst' )            */
        STOR(  %rsi,   AT(%rdx))       /* ( src' _ dst' )            */
        MOVE(  %rdx,   DSTK)           /* reload DSTK                */
FUNC_END(minus_cmove_star)


/* move ( src_addr dst_addr u -- ) */
FUNC_START(move)
        MOVE(  DSTK,   %rdx)           /* save DSTK == %rsi          */
        LOAD(  %rdi,   AT(DSTK))       /* %rdi = dst                 */
        LOAD(  %rsi,   AT(DSTK, SZ))   /* %rsi = src: clobbers DSTK  */
        MOVE(  DTOP,   %rcx)           /* n                          */

        cld;                           /* forward direction          */
        JAE(   %rsi,   %rdi,    TO(move.loop))
        lea    -SZ(%rsi, %rcx, SZ),    %r8;    /* %r8 = src top      */
        JB(    %r8,    %rdi,    TO(move.loop)) /* overlapping?       */

        std;                           /* backward direction         */
        MOVE(  %r8,    %rsi)           /*      copy from src top     */
        lea    -SZ(%rdi, %rcx, SZ),    %rdi;/* copy to   dst top     */

LABEL(move.loop)
        rep    movsq (%rsi), (%rdi);   /* copy 8 bytes per iteration */
        cld;
        ADDI(  %rdx,   SZ3,    DSTK)   /* reload DSTK                */
        LOAD(  DTOP,   AT(%rdx,SZ2))   /* reload dstack top          */
FUNC_END(move)


/* crc-cell/simd ( x -- crc ) m4th-user: compute CRC32c of a cell */
FUNC_START(crc_cell_simd)
        MOVE(  DTOP,   REG1)
        MOVE(  RFFFw,  DTOPw)          /* dtop = 0xffffffff          */
        crc32q REG1,   DTOP;
        NOT1(  DTOPw)
FUNC_END(crc_cell_simd)


/* crc-string ( c-addr u -- crc ) m4th-user: compute CRC32c of a string */
FUNC_START(crc_string)
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


/* crc-string/simd ( c-addr u -- crc ) m4th-user: compute CRC32c of a string */
FUNC_START(crc_string_simd)
        ZERO(  REG1)                       /* a = 0                    */
        MOVE(  DTOP,       REG2)           /* b = u                    */
        LOAD(  REG3,       AT(DSTK))       /* c = c-addr               */
        MOVE(  RFFFw,      DTOPw)          /* dtop = 0xffffffff        */
        JB(    REG2,       IMM(8),  TO(crc_string_simd.upto7))
#if 1
        JB(    REG2,       IMM(64), TO(crc_string_simd.by8))

        MOVE(  REG2,       REG4)           /* d = u                    */
        SUB2(  IMM(64),    REG2)
FUNC_ALIGN()
LABEL(crc_string_simd.by64.loop)
        crc32q (REG3,      REG1, 1),    DTOP;
        crc32q 8(REG3,     REG1, 1),    DTOP;
        crc32q 16(REG3,    REG1, 1),    DTOP;
        crc32q 24(REG3,    REG1, 1),    DTOP;
        crc32q 32(REG3,    REG1, 1),    DTOP;
        crc32q 40(REG3,    REG1, 1),    DTOP;
        crc32q 48(REG3,    REG1, 1),    DTOP;
        crc32q 56(REG3,    REG1, 1),    DTOP;
        ADD2(  IMM(64),    REG1)
        JBE(   REG1,       REG2,    TO(crc_string_simd.by64.loop))
        SUB2(  REG1,       REG4)           /* d = left = u - i         */
        ADD2(  IMM(64),    REG2)
        JB(    REG4,       IMM(8),  TO(crc_string_simd.upto7))

LABEL(crc_string_simd.by8)
#endif /* 1 */

        SUB2(  IMM(8),     REG2)
FUNC_ALIGN()
LABEL(crc_string_simd.by8.loop)
        crc32q (REG3,      REG1, 1),    DTOP;
        ADD2(  IMM(8),     REG1)
        JBE(   REG1,       REG2,    TO(crc_string_simd.by8.loop))
        ADD2(  IMM(8),     REG2)

LABEL(crc_string_simd.upto7)
        lea    TO(crc_string_simd.jumps)(%rip), REG4
        ADD2(  REG2,       REG3)           /* c = c-addr + u           */
        SUB2(  REG1,       REG2)           /* b = left = u - i         */
        ADD4(  REG4, REG2, 1, REG4) /* each jmp below occupies 2 bytes */
        ADD2(  IMM(SZ),    DSTK)

        jmp    *REG4;

LABEL(crc_string_simd.jumps)
        /* a jump table containing absolute addresses would cause      */
        /* linker warning: relocation in read-only section `.text'     */
        jmp    TO(crc_string_simd.0)
        jmp    TO(crc_string_simd.1)
        jmp    TO(crc_string_simd.2)
        jmp    TO(crc_string_simd.3)
        jmp    TO(crc_string_simd.4)
        jmp    TO(crc_string_simd.5)
        jmp    TO(crc_string_simd.6)
        /* jmp    TO(crc_string_simd.7) */ /* fallthrough */

LABEL(crc_string_simd.7)
        crc32l -7(REG3),   DTOPw;
LABEL(crc_string_simd.3)
        crc32w -3(REG3),   DTOPw;
LABEL(crc_string_simd.1)
        crc32b -1(REG3),   DTOPw;
        NOT1(  DTOPw)
        NEXT0()
LABEL(crc_string_simd.5)
        crc32b -5(REG3),   DTOPw;
LABEL(crc_string_simd.4)
        crc32l -4(REG3),   DTOPw;
        NOT1(  DTOPw)
        NEXT0()
LABEL(crc_string_simd.6)
        crc32l -6(REG3),   DTOPw;
LABEL(crc_string_simd.2)
        crc32w -2(REG3),   DTOPw;
LABEL(crc_string_simd.0)
        NOT1(  DTOPw)
        NEXT0()
FUNC_RAWEND(crc_string_simd)


/* fill ( c-addr u char -- ) core */
FUNC_START(fill)
        LOAD(  %rcx,   AT(DSTK))       /* b {%rcx} = u               */
        LOAD(  %rdi,   AT(DSTK, SZ))   /* a {%rdi} = c-addr          */
        cld;                           /* forward direction          */
        rep stosb %al, (%rdi);
        LOAD(  DTOP,   AT(DSTK, SZ2))  /* reload DTOP                */
        ADD2(IMM(SZ3), DSTK)           /* drop 3 cells from DSTK     */
FUNC_END(fill)


FUNC_START(string_equal)   /* string=  ( addr1 addr2 u -- addr1 addr2 u t|f ) m4th-user */
        LOAD(  REG2,   AT(DSTK))       /* b = addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = addr1 */
        DPUSH__DTOP()
        JEQ(   REG1,   REG2,    TO(string_equal.true))   /* addr1 == addr2 */
        JZ(    DTOP,            TO(string_equal.true))   /* u == 0         */
        ZERO(  REG4)
        JB(    DTOP,   IMM(SZ), TO(string_equal.byte))   /* < SZ bytes     */
        SUB2(IMM(SZ),  DTOP)
LABEL(string_equal.cell)
        LOAD(  REG3,   AT(REG1, REG4, 1))
        JNE(   REG3,   AT(REG2, REG4, 1),  TO(string_equal.false)) /* x86 specific */
        ADD2(IMM(SZ),  REG4)
        JB(    REG4,   DTOP,    TO(string_equal.cell))      /* >= SZ bytes left ? */
        LOAD(  REG3,   AT(REG1, DTOP, 1))                   /* compare last SZ bytes */
        JNE(   REG3,   AT(REG2, DTOP, 1),  TO(string_equal.false)) /* x86 specific */
LABEL(string_equal.true)
        MOVE(  RFFF,   DTOP)
        JUMP(  FUNC_RET(string_equal))

LABEL(string_equal.byte)
        LD_ub( REG3,   AT(REG1, REG4, 1))
        JNE(   REG3b,  AT(REG2, REG4, 1),  TO(string_equal.false)) /* x86 specific */
        INC1(  REG4)
        JB(    REG4,   DTOP,    TO(string_equal.byte))
        MOVE(  RFFF,   DTOP)
        JUMP(  FUNC_RET(string_equal))

LABEL(string_equal.false)
        ZERO(  DTOP)
FUNC_END(string_equal)
