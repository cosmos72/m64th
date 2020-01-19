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

#ifndef M4TH_COMMON_MACRO_ASM_H
#define M4TH_COMMON_MACRO_ASM_H

#include "../m4th_macro.h" /* also define public macros */

#define CAT2_(a, b) a##b
#define CAT2(a, b) CAT2_(a, b)

/* works only for 1..10 arguments. broken for zero arguments */
#define COUNT_ARGS_(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, n, ...) n
#define COUNT_ARGS(...) COUNT_ARGS_(__VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

#define WRAP_ARGS_COMMA_1(x, _1) x(_1)
#define WRAP_ARGS_COMMA_2(x, _1, _2) x(_1), x(_2)
#define WRAP_ARGS_COMMA_3(x, _1, _2, _3) x(_1), x(_2), x(_3)
#define WRAP_ARGS_COMMA_4(x, _1, _2, _3, _4) x(_1), x(_2), x(_3), x(_4)
#define WRAP_ARGS_COMMA_5(x, _1, _2, _3, _4, _5) x(_1), x(_2), x(_3), x(_4), x(_5)
#define WRAP_ARGS_COMMA_6(x, _1, _2, _3, _4, _5, _6) x(_1), x(_2), x(_3), x(_4), x(_5), x(_6)
#define WRAP_ARGS_COMMA_7(x, _1, _2, _3, _4, _5, _6, _7)                                           \
    x(_1), x(_2), x(_3), x(_4), x(_5), x(_6), x(_7)
#define WRAP_ARGS_COMMA_8(x, _1, _2, _3, _4, _5, _6, _7, _8)                                       \
    x(_1), x(_2), x(_3), x(_4), x(_5), x(_6), x(_7), x(_8)
#define WRAP_ARGS_COMMA_9(x, _1, _2, _3, _4, _5, _6, _7, _8, _9)                                   \
    x(_1), x(_2), x(_3), x(_4), x(_5), x(_6), x(_7), x(_8), x(_9)
#define WRAP_ARGS_COMMA_10(x, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                             \
    x(_1), x(_2), x(_3), x(_4), x(_5), x(_6), x(_7), x(_8), x(_9), x(_10)

#define WRAP_ARGS_COMMA(x, ...) CAT2(WRAP_ARGS_COMMA_, COUNT_ARGS(__VA_ARGS__))(x, __VA_ARGS__)

/* internal m4th macros used (mostly) by assembly */

#define M4FLAG_CONSUMES_IP_SZ CAT2(M4FLAG_CONSUMES_IP_, SZ)

/* clang-format off */

/* align functions at 8 bytes. */
/* on x86_64, aligning at 16 bytes should be faster, but wastes more memory */
#define P_FUNC_ALIGN 3
#define P_DATA_ALIGN 3

#define DATA_ALIGN()                                                                               \
    .p2align P_DATA_ALIGN, 0;

/* ------------- COUNTEDSTRING ------------- */

#define COUNTEDSTRING_SYM(name)                                                                    \
    .Lcountedstring.name

#define COUNTEDSTRING_DEF_SYM(name)                                                                \
    /* no alignment */                                                                             \
    .type COUNTEDSTRING_SYM(name), @object;                                                        \
    COUNTEDSTRING_SYM(name):

#define COUNTEDSTRING_START(name)                                                                  \
    COUNTEDSTRING_DEF_SYM(name)                                                                    \

#define COUNTEDSTRING_LEN(strlen)            .byte  strlen;
#define COUNTEDSTRING_ASCII(str)             .ascii str;
#define COUNTEDSTRING_END(name)

#define COUNTEDSTRING(strlen, str, name)                                                           \
    COUNTEDSTRING_START(name)                                                                      \
    COUNTEDSTRING_LEN(strlen)                                                                      \
    COUNTEDSTRING_ASCII(str)                                                                       \
    COUNTEDSTRING_END(name)

#define DICTNAME COUNTEDSTRING
#define WORDNAME COUNTEDSTRING

/* ------------- FUNC ------------- */

#define FUNC_ALIGN()                                                                               \
    .p2align P_FUNC_ALIGN;

#define FUNC_SYM(name)                                                                             \
    m4##name

#define FUNC_SYM_NEXT(name)                                                                        \
    .Lfunc.name.next

#define FUNC_DEF_SYM(name)                                                                         \
    FUNC_ALIGN()                                                                                   \
    .globl FUNC_SYM(name);                                                                         \
    .type FUNC_SYM(name), @function;                                                               \
    FUNC_SYM(name):

#define FUNC_START(name)                                                                           \
    FUNC_DEF_SYM(name)                                                                             \
    .cfi_startproc;

#define FUNC_RAWEND(name)                                                                          \
    .cfi_endproc;                                                                                  \
    .size FUNC_SYM(name), . - FUNC_SYM(name);

#define FUNC_END(name)                                                                             \
    FUNC_SYM_NEXT(name):                                                                           \
    NEXT()                                                                                         \
    FUNC_RAWEND(name)

/* ------------- DICT ------------- */

#define DICT_SYM(name)                                                                             \
    m4dict_##name

#define DICT_DEF_SYM(name)                                                                         \
    DATA_ALIGN()                                                                                   \
    .globl DICT_SYM(name);                                                                         \
    .type  DICT_SYM(name), @object;                                                                \
    DICT_SYM(name):

#define DICT_START(name)

#define DICT_WORD_OFF(name, wordname)   .4byte DICT_SYM(name)    - WORD_SYM(wordname) ;
#define DICT_NAME_OFF(name)             .2byte DICT_SYM(name)    - COUNTEDSTRING_SYM(name) ;
#define DICT_END(name)                  .size  DICT_SYM(name), . - DICT_SYM(name) ;

#define DICT_BODY(name, last_wordname)                                                             \
    DICT_DEF_SYM(name)                                                                             \
    DICT_WORD_OFF(name, last_wordname)                                                             \
    DICT_NAME_OFF(name)

/* ------------- WORD ------------- */

#define WORD_SYM(name)                                                                             \
    m4word_##name

#define WORD_DEF_SYM(name)                                                                         \
    DATA_ALIGN()                                                                                   \
    .globl WORD_SYM(name);                                                                         \
    .type  WORD_SYM(name), @object;                                                                \
    WORD_SYM(name):

#define WORD_START(name, prev)                                                                     \
    WORD_DEF_SYM(name)                                                                             \
    WORD_PREV_OFF(name, prev)                                                                      \
    WORD_NAME_OFF(name)

#define WORD_PREV_OFF(name,prev)        .4byte WORD_SYM(name) - WORD_SYM(prev) ;
#define WORD_NAME_OFF(name)             .2byte WORD_SYM(name) - COUNTEDSTRING_SYM(name) ;
#define WORD_FLAGS(flags)               .byte  flags;
#define WORD_DSTACK(in, out)            .byte  ((in) & 0xF) | (((out) & 0xF) << 4);
#define WORD_DSTACK_UNKNOWN()           .byte  0xFF;
#define WORD_RSTACK(in, out)            .byte  ((in) & 0xF) | (((out) & 0xF) << 4);
#define WORD_RSTACK_UNKNOWN()           .byte  0xFF;
#define WORD_NATIVE_LEN(name)           .byte  FUNC_SYM_NEXT(name) - FUNC_SYM(name);
#define WORD_NATIVE_LEN_NONE()             .byte  0;
#define WORD_CODE_N(n_instr)            .2byte n_instr;
#define WORD_DATA_NBYTES(n_bytes)       .4byte n_bytes;
#define WORD_DATA_N(n_instr)            .4byte (n_instr) * ISZ;
#define WORD_CODE(...)                  .8byte __VA_ARGS__;
#define WORD_CODE_FUNC(name)            .8byte FUNC_SYM(name);
#define WORD_DATA_1(...)                .byte  __VA_ARGS__;
#define WORD_DATA_2(...)                .2byte __VA_ARGS__;
#define WORD_DATA_4(...)                .4byte __VA_ARGS__;
#define WORD_DATA_8(...)                .8byte __VA_ARGS__;
#define WORD_END(name)                  .size WORD_SYM(name), . - WORD_SYM(name);

#define WORD_CODE_FUNCS(...)                                                                       \
    WORD_CODE(WRAP_ARGS_COMMA(FUNC_SYM, __VA_ARGS__))

#define WORD_FUNCS(...)                                                                            \
    WORD_CODE_N(COUNT_ARGS(__VA_ARGS__))                                                           \
    WORD_DATA_NBYTES(0)                                                                            \
    WORD_CODE_FUNCS(__VA_ARGS__)

#define WORD_BODY_SIMPLE(name, flags, dstack, rstack)                                              \
    WORD_FLAGS(flags)                                                                              \
    WORD_##dstack                                                                                  \
    WORD_##rstack                                                                                  \
    WORD_NATIVE_LEN(name)                                                                          \
    WORD_FUNCS(name, exit)

#define WORD_IMPURE M4FLAG_INLINE|M4FLAG_INLINE_NATIVE
#define WORD_PURE   M4FLAG_INLINE|M4FLAG_INLINE_NATIVE|M4FLAG_PURE

#define WORD(name, prev, dstack, rstack, flags)                                                    \
    WORD_START(name, prev)                                                                         \
    WORD_BODY_SIMPLE(name, flags, dstack, rstack)                                                  \
    WORD_END(name)


/* expand AT(addr) -> AT0(addr) and AT(addr, i) -> ATx(addr, i) */
#define AT_0(addr, i)                   AT0(addr)
#define AT_x(addr, i)                   ATx(addr, i)
#define AT_(addr, i, kind, ...)         AT_##kind(addr, i)
#define AT(...)                         AT_(__VA_ARGS__, x, 0)

/* expand IPUSH(a) -> IPUSH1(a) and IPUSH(a, b) -> IPUSH2(a, b) */
#define IPUSH_1(a, b)                   IPUSH1(a)
#define IPUSH_2(a, b)                   IPUSH2(a, b)
#define IPUSH_(a, b, kind, ...)         IPUSH_##kind(a, b)
#define IPUSH(...)                      IPUSH_(__VA_ARGS__, 2, 1)

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

#endif /* M4TH_COMMON_MACRO_ASM_H */
