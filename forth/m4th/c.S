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

#include "../../include/asm.mh"
#include "../../include/dict.mh"
#include "../../include/m4th/dict.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m4th-c ----------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

/* c-arg-[N] are marked inline-always because on x86_64 they clobber RSTK */
WORD(_c_arg_0_,          _c_arg_0_,    DSTACK(0,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_arg_1_,          _c_arg_0_,    DSTACK(1,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_arg_2_,          _c_arg_1_,    DSTACK(2,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_arg_3_,          _c_arg_2_,    DSTACK(3,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_arg_4_,          _c_arg_3_,    DSTACK(4,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_arg_5_,          _c_arg_4_,    DSTACK(5,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_arg_6_,          _c_arg_5_,    DSTACK(6,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD_START(_c_call_,   _c_arg_6_)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE_ALWAYS | M4FLAG_CONSUMES_IP_SZ | M4FLAG_COMPILE_ONLY)
    WORD_CODE(_c_call_, CELL(0), exit)
WORD_END(_c_call_)
WORD(_c_ret_0_,          _c_call_,     DSTACK(0,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_ret_1_,          _c_ret_0_,    DSTACK(0,1), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD(_c_ret_2_,          _c_ret_1_,    DSTACK(0,2), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD_NONATIVE(_c_locals_load_,    _c_ret_2_,    DSTACK(0,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
WORD_NONATIVE(_c_locals_save_, _c_locals_load_, DSTACK(0,0), RSTACK(0,0), M4FLAG_INLINE_ALWAYS)
/* ( FILE* c-addr u -- u' err ) call C function fread(). usable for iobuf>func */
WORD_START(c_fread,      _c_locals_save_)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _c_locals_save_,
            _c_arg_3_, _c_call_, CELL(m4th_c_fread), _c_ret_2_,
        _c_locals_load_, exit
    )
WORD_END(c_fread)
/* ( FILE* c-addr u -- u' err ) call C functions fwrite() + fflush. usable for iobuf>func */
WORD_START(c_fwrite_fflush,   c_fread)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _c_locals_save_,
            _c_arg_3_, _c_call_, CELL(m4th_c_fwrite_fflush), _c_ret_2_,
        _c_locals_load_, exit)
WORD_END(c_fwrite_fflush)
/* ( prompt-addr c-addr u -- u' err ) call liblinenoise C function linenoise(). usable for iobuf>func */
WORD_START(c_linenoise,   c_fwrite_fflush)
    WORD_DSTACK(3,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(M4FLAG_INLINE)
    WORD_CODE(
        _c_locals_save_,
            _c_arg_3_, _c_call_, CELL(m4th_c_linenoise), _c_ret_2_,
        _c_locals_load_, exit)
WORD_END(c_linenoise)

#undef LASTWORD
#define LASTWORD c_linenoise
