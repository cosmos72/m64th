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

#ifndef M4TH_COMMON_WORD_ASM_H
#define M4TH_COMMON_WORD_ASM_H

#define WORD_SYM(name) m4word_##name

#define WORD_DEF_SYM(name)                                                                         \
    DATA_ALIGN().globl WORD_SYM(name);                                                             \
    .type WORD_SYM(name), @object;                                                                 \
    WORD_SYM(name) :

#define WORD_START(name, prev)                                                                     \
    WORD_DEF_SYM(name)                                                                             \
    WORD_PREV_OFF(name, prev)                                                                      \
    WORD_NAME_OFF(name)

#define WORD_PREV_OFF(name, prev) /**/ .4byte WORD_SYM(name) - WORD_SYM(prev);
#define WORD_NAME_OFF(name) /*      */ .2byte WORD_SYM(name) - COUNTEDSTRING_SYM(name);
#define WORD_FLAGS(flags) /*        */ .byte flags;
#define WORD_DSTACK(in, out) /*     */ .byte((in)&0xF) | (((out)&0xF) << 4);
#define WORD_DSTACK_UNKNOWN() /*    */ .byte 0xFF;
#define WORD_RSTACK(in, out) /*     */ .byte((in)&0xF) | (((out)&0xF) << 4);
#define WORD_RSTACK_UNKNOWN() /*    */ .byte 0xFF;
#define WORD_NATIVE_LEN(name) /*    */ .byte FUNC_SYM_NEXT(name) - FUNC_SYM(name);
#define WORD_NATIVE_LEN_NONE() /*   */ .byte 0;
#define WORD_CODE_N(n_instr) /*     */ .2byte n_instr;
#define WORD_DATA_NBYTES(n_bytes) /**/ .4byte n_bytes;
#define WORD_DATA_N(n_instr) /*     */ .4byte(n_instr)*ISZ;
#define WORD_CODE(...) /*           */ .8byte __VA_ARGS__;
#define WORD_CODE_FUNC(name) /*     */ .8byte FUNC_SYM(name);
#define WORD_DATA_1(...) /*         */ .byte __VA_ARGS__;
#define WORD_DATA_2(...) /*         */ .2byte __VA_ARGS__;
#define WORD_DATA_4(...) /*         */ .4byte __VA_ARGS__;
#define WORD_DATA_8(...) /*         */ .8byte __VA_ARGS__;
#define WORD_END(name) /*           */ .size WORD_SYM(name), .- WORD_SYM(name);

#define WORD_CODE_FUNCS(...) WORD_CODE(WRAP_ARGS_COMMA(FUNC_SYM, __VA_ARGS__))

#define WORD_FUNCS(...)                                                                            \
    WORD_CODE_N(COUNT_ARGS(__VA_ARGS__))                                                           \
    WORD_DATA_NBYTES(0)                                                                            \
    WORD_CODE_FUNCS(__VA_ARGS__)

/* clang-format off */

#define WORD_BODY_SIMPLE(name, flags, dstack, rstack)                                              \
    WORD_FLAGS(flags)                                                                              \
    WORD_##dstack                                                                                  \
    WORD_##rstack                                                                                  \
    WORD_NATIVE_LEN(name)                                                                          \
    WORD_FUNCS(name, exit)

/* clang-format on */

#define WORD_IMPURE M4FLAG_INLINE | M4FLAG_INLINE_NATIVE
#define WORD_PURE M4FLAG_INLINE | M4FLAG_INLINE_NATIVE | M4FLAG_PURE

#define WORD(name, prev, dstack, rstack, flags)                                                    \
    WORD_START(name, prev)                                                                         \
    WORD_BODY_SIMPLE(name, flags, dstack, rstack)                                                  \
    WORD_END(name)

#endif /* M4TH_COMMON_WORD_ASM_H */
