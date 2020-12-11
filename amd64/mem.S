/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "../dispatch/asm.mh"

/* clang-format off */


#define M6FDIV_STRING
/* /string ( c-addr u n -- c-addr' u' )  'string' word set */
FUNC_START(div_string)
        MOVE(  DTOP,   REG1)           /* a = n       */
        DPOP___DTOP()                  /* dtop = u    */
        SUB2(  REG1,   DTOP)           /* dtop -= n   */
        ADD2(  REG1,   AT(DSTK))       /* c-addr += n */
FUNC_END(div_string)


/*
 * atomic1+! ( addr -- n' ) atomically increment cell at addr by 1.
 * return cell old value.
 */
FUNC_START(atomic_one_plus_store)
        MOVE(  DTOP,   REG1)
        MOVI(  1,      DTOP)
        lock xadd DTOP,AT(REG1);
FUNC_END(atomic_one_plus_store)


/*
 * atomic+! ( n addr -- n' ) atomically increment cell at addr by n.
 * return cell old value.
 */
FUNC_START(atomic_plus_store)
        MOVE(  DTOP,   REG1)
        DPOP___DTOP()
        lock xadd DTOP,AT(REG1);
FUNC_END(atomic_plus_store)


#define M6FCMOVE /* defined near cmove/count to encode a shorter jump */
/* cmove ( src_addr dst_addr u -- ) 'string' word set */
FUNC_START(cmove)
        TOKEN_CALL_NOTHROW(FUNC(cmove_count), cmove.0)   /* ( src' dst'    ) */
        LOAD(  DTOP,   AT(DSTK, SZ))
        ADD2(IMM(SZ2), DSTK)
FUNC_END(cmove)


/* cmove/count ( src_addr dst_addr u -- src_addr+u dst_addr+u ) m64th-user */
FUNC_START(cmove_count)
        ADDI(  DSTK,   SZ,     %rdx)   /* %rdx = DSTK + SZ           */
        LOAD(  %rdi,   AT(DSTK))       /* %rdi = dst                 */
        LOAD(  %rsi,   AT(DSTK, SZ))   /* %rsi = src: clobbers DSTK  */
        MOVE(  DTOP,   %rcx)           /* %rcx = u                   */

        cld;                           /* forward direction          */
        rep    movsb (%rsi), (%rdi);   /* copy bytes                 */

        STOR(  %rsi,   AT(%rdx))       /* ( src' dst u  )            */
        MOVE(  %rdi,   DTOP)           /* ( src' _ dst' )            */
        MOVE(  %rdx,   DSTK)           /* reload DSTK                */
FUNC_END(cmove_count)


/* -cmove/count ( src_addr dst_addr u -- src_addr+u dst_addr+u ) m64th-user */
/* backward copy u bytes from src..src+u-1 to dst..dst+u-1 and return updated addresses */
FUNC_START(minus_cmove_count)
        ADDI(  DSTK,   SZ,     %rdx)   /* %rdx = DSTK + SZ           */
        LOAD(  %rdi,   AT(DSTK))       /* %rdi = dst                 */
        LOAD(  %rsi,   AT(DSTK, SZ))   /* %rsi = src: clobbers DSTK  */
        MOVE(  DTOP,   %rcx)           /* %rcx = u                   */
        lea   -1(%rsi,DTOP),   %rsi;   /* %rsi = src + u - 1         */
        lea   -1(%rdi,DTOP),   %rdi;   /* %rdi = dst + u - 1         */

        std;                           /* backward direction         */
        rep    movsb (%rsi), (%rdi);   /* copy bytes                 */
        cld;                           /* restore direction flag     */
                                       /* %rsi = src - 1             */
                                       /* %rdi = dst - 1             */

        lea    1(%rsi,DTOP),   %rsi;   /* %rsi = src + u             */
        lea    1(%rdi,DTOP),   DTOP;   /* ( _ _ dst+u     )          */
        STOR(  %rsi,   AT(%rdx))       /* ( src+u _ dst+u )          */
        MOVE(  %rdx,   DSTK)           /* ( src+u dst+u   )          */
FUNC_END(minus_cmove_count)


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


/* crc-cell/simd ( x -- crc ) m64th-user: compute CRC32c of a cell */
FUNC_START(crc_cell_simd)
        MOVE(  DTOP,   REG1)
        MOVE(  RFFFw,  DTOPw)          /* dtop = 0xffffffff          */
        crc32q REG1,   DTOP;
        NOT1(  DTOPw)
FUNC_END(crc_cell_simd)


/* crc-string/simd ( c-addr u -- crc ) m64th-user: compute CRC32c of a string */
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
        ADDROF_1M(TO(crc_string_simd.jumps), REG4)
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


/* string= m64th-user: compare two strings */
/* ( c-addr1 c-addr2 u -- c-addr1 c-addr2 u t|f ) */
FUNC_START(string_equal)
        LOAD(  REG2,   AT(DSTK))       /* b = c-addr2 */
        LOAD(  REG1,   AT(DSTK, SZ))   /* a = c-addr1 */
        DPUSH__DTOP()
        JEQ(   REG1,   REG2,    TO(string_equal.true))   /* c-addr1 == c-addr2 */
        JZ(    DTOP,            TO(string_equal.true))   /* u == 0             */
        ZERO(  REG4)
        JB(    DTOP,   IMM(SZ), TO(string_equal.byte))   /* < SZ bytes         */
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
