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

/* #> ( xd -- c-addr u ) drop xd, return the pictured numeric output
 * as a user-modifiable string */
FUNC_START(num_end)
        LD_ub( DTOP,   AT(M4TH, M4TH_OFF_PICT_START))   /* dtop = pict_start       */
        ADD4(  HERE,   DTOP,0, REG2)                   /* b = c-addr             */
        SUB2(  IMM(M4TH_PICT_MAXSIZE), DTOP)            /* dtop = -u              */
        STOR(  REG2,   AT(DSTK))                       /* ( c-addr -u          ) */
        NEG1(  DTOP)                                   /* ( c-addr u           ) */
FUNC_END(num_end)


/* <# ( -- ) initialize the pictured numeric output */
FUNC_START(num_start)
        MOVI(  M4TH_PICT_MAXSIZE,       REG1)
        STORb( REG1,   AT(M4TH, M4TH_OFF_PICT_START))   /* pict_start = initial value */
FUNC_END(num_start)


/* emit ( ch -- ) write one char to current output */
FUNC_START(emit)
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_OUT))         /* a = io                 */
        DPUSH( REG1)                                   /* dstk ( io ch         ) */
        TOKEN_CALL_NOTHROW(FUNC(obuf_write_char), emit.0) /* dstk ( err        ) */
        DPOP___DTOP()                                  /* dstk (               ) */
FUNC_END(emit)


/* hold ( ch -- ) add one char to the beginning of pictured numeric output */
FUNC_START(hold)
        LD_ub( REG1,   AT(M4TH, M4TH_OFF_PICT_START))   /* a = pict_start          */
        MOVI(M4ERR_PICTURED_NUMERIC_OUTPUT_STRING_OVERFLOW, REG0)
        JZ(    REG1,   FUNC(_throw_reg0_))
LABEL(hold.ok)
        DEC1(  REG1)                                   /* a = pict_start - 1      */
        STORb( DTOP,   AT(HERE, REG1,1))               /* here[pict_start-1] = ch */
        STORb( REG1,   AT(M4TH, M4TH_OFF_PICT_START))   /* --pict_start            */
        DPOP___DTOP()
FUNC_END(hold)


/* holds ( c-addr u -- ) add a string to the beginning of pictured numeric output */
FUNC_START(holds)
        LD_ub( REG1,   AT(M4TH, M4TH_OFF_PICT_START))   /* a = pict_start          */
        MOVI(M4ERR_PICTURED_NUMERIC_OUTPUT_STRING_OVERFLOW, REG0)
        JB(    REG1,   DTOP,   FUNC(_throw_reg0_))
LABEL(holds.ok)
        SUB2(  DTOP,   REG1)                           /* a = pict_start - u      */
        STORb( REG1,   AT(M4TH, M4TH_OFF_PICT_START))   /* pict_start -= u         */
        ADD2(  HERE,   REG1)                           /* a = here + pict_start'  */
        DPUSH( REG1)                                   /* ( c-addr pic-out u   ) */
        JUMP(  FUNC(cmove))                            /* (                    ) */
FUNC_RAWEND(holds)


/* in>ibuf ( -- io ) get current input as iobuf */
FUNC_START(in_to_ibuf)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_IN))
FUNC_END(in_to_ibuf)


/* iobuf>addr ( io -- c-addr ) get start of iobuf data */
FUNC_START(iobuf_addr)
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_ADDR))
FUNC_END(iobuf_addr)


/* iobuf>all-data ( io -- c-addr u ) get iobuf entire content, i.e. from 0 to iobuf>end */
FUNC_START(iobuf_all_data)
        LOAD(  REG1,   AT(DTOP, IOBUF_OFF_ADDR))   /* a = iobuf.addr    */
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_END))    /* dtop = iobuf.end */
        DPUSH( REG1)
FUNC_END(iobuf_all_data)


/* iobuf>data ( io -- c-addr u ) get iobuf current content, i.e. from iobuf>pos to iobuf>end */
FUNC_START(iobuf_data)
        LOAD(  REG1,   AT(DTOP, IOBUF_OFF_ADDR))   /* a = iobuf.addr    */
        LOAD(  REG2,   AT(DTOP, IOBUF_OFF_POS))    /* b = iobuf.pos     */
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_END))    /* dtop = iobuf.end  */
        ADD2(  REG2,   REG1)     /* a = c-addr = iobuf.addr + iobuf.pos */
        SUB2(  REG2,   DTOP)     /* dtop =  u  = iobuf.end - iobuf.pos  */
        DPUSH( REG1)
FUNC_END(iobuf_data)


/* iobuf>data>n ( io -- u ) get iobuf current length, i.e. the distance iobuf>end - iobuf>pos */
FUNC_START(iobuf_data_n)
        LOAD(  REG2,   AT(DTOP, IOBUF_OFF_POS))    /* b = iobuf.pos     */
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_END))    /* dtop = iobuf.end  */
        SUB2(  REG2,   DTOP)     /* dtop =  u  = iobuf.end - iobuf.pos  */
FUNC_END(iobuf_data_n)


/* iobuf>free-data ( io -- c-addr u ) get iobuf free space, i.e. from iobuf>end to iobuf>max */
FUNC_START(iobuf_free_data)
        LOAD(  REG1,   AT(DTOP, IOBUF_OFF_ADDR))   /* a = iobuf.addr    */
        LOAD(  REG2,   AT(DTOP, IOBUF_OFF_END))    /* b = iobuf.end     */
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_MAX))    /* dtop = iobuf.max  */
        ADD2(  REG2,   REG1)     /* a = c-addr = iobuf.addr + iobuf.end */
        SUB2(  REG2,   DTOP)     /* dtop =  u  = iobuf.max  - iobuf.end */
        DPUSH( REG1)
FUNC_END(iobuf_free_data)


/* iobuf>err ( io -- addr ) get address of iobuf.err */
FUNC_START(iobuf_err)
        ADD2(  IMM(IOBUF_OFF_ERR), DTOP)
FUNC_END(iobuf_err)


/* iobuf>func ( io -- addr ) get address of iobuf I/O function  */
FUNC_START(iobuf_func)
#if IOBUF_OFF_FUNC != 0
        ADD2(  IMM(IOBUF_OFF_FUNC), DTOP)
#endif
FUNC_END(iobuf_func)


/* iobuf>handle ( io -- addr ) get address of iobuf handle  */
FUNC_START(iobuf_handle)
        ADD2(  IMM(IOBUF_OFF_HANDLE), DTOP)
FUNC_END(iobuf_handle)


/* iobuf>max ( io -- u ) get iobuf max size i.e. capacity */
FUNC_START(iobuf_max)
        LOAD(  DTOP,   AT(DTOP, IOBUF_OFF_MAX))
FUNC_END(iobuf_max)


/* iobuf>pos ( io -- addr ) get address of iobuf.pos */
FUNC_START(iobuf_pos)
        ADD2(  IMM(IOBUF_OFF_POS), DTOP)
FUNC_END(iobuf_pos)


/* iobuf>end ( io -- addr ) get address of iobuf.end */
FUNC_START(iobuf_end)
        ADD2(  IMM(IOBUF_OFF_END), DTOP)
FUNC_END(iobuf_end)


/* ( -- char ) receive one character */
FUNC_START(key)
        DPUSH__DTOP()
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_IN))
        LOAD(  REG2,   AT(REG1, IOBUF_OFF_POS))
        LOAD(  REG3,   AT(REG1, IOBUF_OFF_END))
        MOVE(  IMM_1,  DTOP)
        /* TODO refill input buffer */
        JAE(   REG2,   REG3,  FUNC_RET(key))
        LOAD(  REG4,   AT(REG1, IOBUF_OFF_ADDR))   /* d = iobuf.addr    */
        LD_ub( DTOP,   AT(REG4, REG2, 1))
        INC1(  REG2)
        STOR(  REG2,   AT(REG1, IOBUF_OFF_POS))
FUNC_END(key)


/* obuf-write-char ( io ch -- err ) write one char iobuf */
FUNC_START(obuf_write_char)
        LOAD(  REG1,   AT(DSTK))                       /* a = io                 */
        LOAD(  REG2,   AT(REG1, IOBUF_OFF_END))        /* b = io.end             */
        /* check if enough space in iobuf, i.e. io.end < io.max */
#ifdef JUMP_ARG2_AT
        JAE(   REG2,   AT(REG1, IOBUF_OFF_MAX), TO(obuf_write_char.slow))
#else
        LOAD(  REG3,   AT(REG1, IOBUF_OFF_MAX))        /* c = io.max              */
        JAE(   REG2,   REG3, TO(obuf_write_char.slow))
#endif
        LOAD(  REG4,   AT(REG1, IOBUF_OFF_ADDR))       /* d = io.addr             */
        STORb( DTOP,   AT(REG4, REG2, 1))              /* io.addr[io.end] = dtop  */
        INC1(  REG2)
        STOR(  REG2,   AT(REG1, IOBUF_OFF_END))        /* io.end++                */
        ZERO(  DTOP)                                   /* dtop = 0                */
        ADD2(  IMM(SZ), DSTK)                          /* dstk ( 0              ) */
        NEXT0()
LABEL(obuf_write_char.slow)
        /* not enough space, call forth word (obuf-flush-write-char) */
        ADDROF_4G( WORD_SYM(_obuf_flush_write_char_), REG2) /* b = word           */
        DPUSH__DTOP()                                  /* dstk ( io ch _        ) */
        ADDI(  REG2,   WORD_OFF_XT, DTOP)              /* dstk ( io ch xt       ) */
        ASM_CALL(FUNC(_asm_vm_execute_))             /* dstk ( err            ) */
FUNC_END(obuf_write_char)


/* obuf-write-string ( io c-addr u -- err ) write string to iobuf */
FUNC_START(obuf_write_string)
        LOAD(  REG1,   AT(DSTK, SZ))                   /* a = io                  */
        LOAD(  REG2,   AT(REG1, IOBUF_OFF_END))        /* b = io.end              */
        ADD4(  DTOP,   REG2, 0, REG3)                  /* c = io.end + u          */
        /* check if enough space in iobuf, i.e. io.end + u <= io.max */
#ifdef JUMP_ARG2_AT
        JA(    REG3,   AT(REG1, IOBUF_OFF_MAX), TO(obuf_write_string.slow))
#else
        LOAD(  REG4,   AT(REG1, IOBUF_OFF_MAX))        /* d = io.max              */
        JA(    REG3,   REG4, TO(obuf_write_string.slow))
#endif
        STOR(  REG3,   AT(REG1, IOBUF_OFF_END))        /* io.end += u             */
        LOAD(  REG1,   AT(REG1, IOBUF_OFF_ADDR))       /* a = io.addr             */
        ADD2(  REG2,   REG1)                           /* a = dst = io.addr + end */
        LOAD(  REG2,   AT(DSTK))                       /* b = c-addr              */
        STOR(  REG1,   AT(DSTK))                       /* ( io dst u            ) */
        STOR(  REG2,   AT(DSTK, SZ))                   /* ( c-addr dst u        ) */
        TOKEN_CALL_NOTHROW(FUNC(cmove), obuf_write_string.0) /* (               ) */
        DPUSH__DTOP()                                  /* ( _                   ) */
        ZERO(  DTOP)                                   /* ( 0                   ) */
        NEXT0()
LABEL(obuf_write_string.slow)
        /* not enough space, call forth word (obuf-flush-write-string) */
        ADDROF_4G( WORD_SYM(_obuf_flush_write_string_), REG2) /* b = word           */
        DPUSH__DTOP()                                  /* dstk ( io c-addr u _    ) */
        ADDI(  REG2,   WORD_OFF_XT, DTOP)              /* dstk ( io c-addr u xt   ) */
        ASM_CALL(FUNC(_asm_vm_execute_))             /* dstk ( err              ) */
FUNC_END(obuf_write_string)


/* out>obuf ( -- io ) get current output as iobuf */
FUNC_START(out_to_obuf)
        DPUSH__DTOP()
        LOAD(  DTOP,   AT(M4TH, M4TH_OFF_OUT))
FUNC_END(out_to_obuf)


/* type ( c-addr u -- ) write string to current output */
FUNC_START(type)
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_OUT))         /* a = io                 */
        LOAD(  REG2,   AT(DSTK))                       /* b = c-addr             */
        STOR(  REG1,   AT(DSTK))                       /* dstk ( io u          ) */
        DPUSH( REG2)                                   /* dstk ( io c-addr u   ) */
        TOKEN_CALL_NOTHROW(FUNC(obuf_write_string), type.0)  /* dstk ( err           ) */
        DPOP___DTOP()                                  /* dstk (               ) */
FUNC_END(type)
