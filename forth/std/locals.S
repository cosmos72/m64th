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

/* clang-format off */

DICT_WORDS_FORTH_LOCALS(WORDNAME)


WORD_START(_local_,            LASTWORD)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        CALL(_user_locals_allocate_),          /* ( c-addr u ls              ) */
        minus_rot,                             /* ( ls c-addr u              ) */
        _q_if0_, T(4+nCALLt),                  /* ( ls c-addr u                */
            /* end-of-locals marker: compute indexes */
            two_drop,                          /* ( ls                       ) */
            CALL(_locals_set_idx_), exit,      /* (                          ) */
        then,                                  /* ( ls c-addr u              ) */
        CALL(_locals_add_), exit               /* (                          ) */
    )
WORD_END(_local_)
/* parse syntax "{: in1 in2 ... inn | local1 local2 ... localn -- out1 out2 ... outn :}" */
/* and compile code to initialize corresponding local variables                          */
WORD_START(_brace_colon_,      _local_)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M4FLAG_COMPILE_ONLY | M4FLAG_IMMEDIATE)
    WORD_CODE(/* generated from file impl.forth - see source and comments there */
        /*94*/ zero, zero, two_to_r,
        begin,
            in_to_ibuf, CALL(ibuf_find_nonblanks),
        _q_while_, T(27+nSTRt(2)+nSTRt(2)+nSTRt(1)+6*nCALLt),
            LIT_STRING(2, ":}"), CALL(string2_equal),
        _while0_, T(23+nSTRt(2)+nSTRt(1)+5*nCALLt),
            LIT_STRING(2, "--"), CALL(string2_equal),
        _while0_, T(16+nSTRt(1)+3*nCALLt),
            LIT_STRING(1, "|"),  CALL(string2_equal),
            _if0_, T(4+nCALLt),
                CALL(_local_), r_one_plus,
            _else_, T(5+nCALLt),
                two_drop, two_r_from,
                CALL(_brace_colon_found_pipe_),
                two_to_r,
            then,
        _again_, T(-27-nSTRt(2)-nSTRt(2)-nSTRt(1)-6*nCALLt),
        then,
            CALL(_skip_until_colon_brace_),
        then,
        then,
        two_drop,
        zero, zero, CALL(_local_),
        two_r_from, over, zero_less,
        _if_, T(3),
            swap, invert,
        then,
        swap, CALL(_compile_lenter_), exit
    )
WORD_END(_brace_colon_)

#undef LASTWORD
#define LASTWORD _brace_colon_
