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

#ifndef M4TH_MACRO_H
#define M4TH_MACRO_H

#include "m4th_macro.h" /* also define public macros */

/* internal m4th macros used (mostly) by assembly */

/* clang-format off */

/* align functions at 8 bytes. */
/* on x86_64, aligning at 16 bytes should be faster, but wastes more memory */
#define P_FUNC_ALIGN 3
#define P_WORD_ALIGN 3

/* ------------- FUNC ------------- */

#define FUNC_ALIGN()                                                                               \
    .p2align P_FUNC_ALIGN;

#define FUNC_SYM(name)                                                                             \
    m4##name

#define FUNC_SYM_NEXT(name)                                                                        \
    .Lfunc.name.next

#define FUNC_START(name)                                                                           \
    FUNC_ALIGN()                                                                                   \
    .globl FUNC_SYM(name);                                                                         \
    .type FUNC_SYM(name), @function;                                                               \
    FUNC_SYM(name):                                                                                \
    .cfi_startproc;

#define FUNC_RAWEND(name)                                                                          \
    .cfi_endproc;                                                                                  \
    .size FUNC_SYM(name), . - FUNC_SYM(name);

#define FUNC_END(name)                                                                             \
    FUNC_SYM_NEXT(name):                                                                           \
    NEXT()                                                                                         \
    FUNC_RAWEND(name)

/* ------------- DICT ------------- */

#define DICT_START(name)                                                                           \
    .text;                                                                                         \
    .p2align P_WORD_ALIGN, 0;

#define DICT_RO()                      .text
#define DICT_RW()                      .data

#define DICT_END(name)

/* ------------- WORDNAME ------------- */

#define WORDNAME_SYM(name)                                                                         \
    .Lwordname.name

#define WORDNAME_START(name)                                                                       \
    .type WORDNAME_SYM(name), @object;                                                             \
    WORDNAME_SYM(name):

#define WORDNAME_LEN(strlen)           .byte  strlen;
#define WORDNAME_ASCII(str)            .asciz str;  
#define WORDNAME_END(name)

#define WORDNAME(name, strlen, str)                                                                \
    WORDNAME_START(name)                                                                           \
    WORDNAME_LEN(strlen)                                                                           \
    WORDNAME_ASCII(str)                                                                            \
    WORDNAME_END(name)

/* ------------- WORD ------------- */

#define WORD_SYM(name)                                                                             \
    m4word_##name

#define WORD_START_(strlen, str, name, ...)                                                        \
    WORDNAME(name, strlen, str)                                                                    \
    .p2align P_WORD_ALIGN, 0;                                                                      \
    .globl WORD_SYM(name);                                                                         \
    .type  WORD_SYM(name), @object;                                                                \
    WORD_SYM(name):                                                                                \
    WORD_NAME_OFF(name)

#define WORD_START(strlen, str, ...)                                                               \
    WORD_START_(strlen, str, __VA_ARGS__)                                                          \
    WORD_PREV(__VA_ARGS__)

/*
 * expand     WORD_PREV(name)      -> WORD_PREV_NONE()
 * and expand WORD_PREV(name,prev) -> WORD_PREV_OFF(name, prev)
 */
#define WORD_PREV_(name,prev,kind, ...) WORD_PREV_##kind(name, prev)
#define WORD_PREV(...)                  WORD_PREV_(__VA_ARGS__, OFF, NONE)

#define WORD_NAME_OFF(name)             .4byte WORD_SYM(name) - WORDNAME_SYM(name) ;
#define WORD_PREV_NONE(...)             .4byte 0 ;
#define WORD_PREV_OFF(name,prev)        .4byte WORD_SYM(name) - WORD_SYM(prev) ;
#define WORD_FLAGS(flags)               .byte  flags;
#define WORD_INLINE_NATIVE_LEN(name)    .byte  FUNC_SYM_NEXT(name) - FUNC_SYM(name);
#define WORD_INLINE_NATIVE_LEN_0()      .byte  0;
#define WORD_CODE_N(n_instr)            .2byte (n_instr) * ISZ;
#define WORD_DATA_NBYTES(n_bytes)       .4byte n_bytes;
#define WORD_DATA_N(n_instr)            .4byte (n_instr) * ISZ;
#define WORD_CODE(...)                  .8byte __VA_ARGS__;
#define WORD_CODE_FUNC(name)            .8byte FUNC_SYM(name);
#define WORD_DATA_1(...)                .byte  __VA_ARGS__;
#define WORD_DATA_2(...)                .2byte __VA_ARGS__;
#define WORD_DATA_4(...)                .4byte __VA_ARGS__;
#define WORD_DATA_8(...)                .8byte __VA_ARGS__;
#define WORD_END(name)                  .size WORD_SYM(name), . - WORD_SYM(name);

#define _1st(a, ...)                    a

#define WORD_INLINE_NATIVE_CODE_1(name)                                                            \
    WORD_FLAGS(M4FLAG_INLINE | M4FLAG_INLINE_NATIVE)                                               \
    WORD_INLINE_NATIVE_LEN(name)                                                                   \
    WORD_CODE_N(2)                                                                                 \
    WORD_DATA_N(0)                                                                                 \
    WORD_CODE_FUNC(name)                                                                           \
    WORD_CODE_FUNC(exit)

#define WORD_SIMPLE(strlen, str, ...)                                                              \
     WORD_START(strlen, str, __VA_ARGS__)                                                          \
     WORD_INLINE_NATIVE_CODE_1(_1st(__VA_ARGS__))                                                  \
     WORD_END(_1st(__VA_ARGS__))

/* expand AT(addr) -> AT0(addr) and AT(addr, i) -> ATx(addr, i) */
#define AT_0(addr, i)           AT0(addr)
#define AT_x(addr, i)           ATx(addr, i)
#define AT_(addr, i, kind, ...) AT_##kind(addr, i)
#define AT(...)                 AT_(__VA_ARGS__, x, 0)

/* expand IPUSH(a) -> IPUSH1(a) and IPUSH(a, b) -> IPUSH2(a, b) */
#define IPUSH_1(a, b)           IPUSH1(a)
#define IPUSH_2(a, b)           IPUSH2(a, b)
#define IPUSH_(a, b, kind, ...) IPUSH_##kind(a, b)
#define IPUSH(...)              IPUSH_(__VA_ARGS__, 2, 1)

#define OFF_DSTK    SZ   /* offset of m4th->dstack.curr */
#define OFF_DEND    SZ2  /* offset of m4th->dstack.end  */
#define OFF_RSTK    SZ4  /* offset of m4th->rstack.curr */
#define OFF_CODE    SZ6  /* offset of m4th->code.start  */
#define OFF_ISTK    SZ7  /* offset of m4th->code.curr   */
#define OFF_IP      SZ9  /* offset of m4th->ip          */
#define OFF_C_SP    SZ10 /* offset of m4th->c_sp        */
#define OFF_IN      SZ12 /* offset of m4th->in.curr     */
#define OFF_IN_END  SZ13 /* offset of m4th->in.end      */
#define OFF_OUT     SZ15 /* offset of m4th->out.curr    */
#define OFF_OUT_END SZ16 /* offset of m4th->out.end     */

/* clang-format on */

#endif /* M4TH_MACRO_H */
