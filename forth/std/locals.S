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

/* clang-format off */

DICT_WORDS_FORTH_LOCALS(WORDNAME)

WORD_START(_local_, LASTWORD)
    WORD_DSTACK(2,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_NATIVE_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        _q_if0_, T(3),                         /* ( c-addr u                 ) */
            two_drop, exit,                    /* (                          ) */
        then,                                  /* ( c-addr u                 ) */
        two_dup, to_char, ne,                  /* ( c-addr u t|f             ) */
        _if_, T(5),                            /* ( c-addr u                 ) */
            ex_message_store,                  /* (                          ) */
            _lit_, T(M4ERR_DEFINITION_NAME_TOO_LONG),/* (                    ) */
            throw,                             /* (                          ) */
        then,                                  /* ( c-addr u                 ) */
        user_var, T(M4TH_USER_VAR_LOCALNAMES), /* ( c-addr u &l              ) */
        dup, fetch,                            /* ( c-addr u &l l|0          ) */
        _if0_, T(2+nCALLt),                    /* ( c-addr u &l              ) */
            CALL(_local_allocate_),            /* ( c-addr u &l              ) */
        then,                                  /* ( c-addr u &l              ) */
        fetch,                                 /* ( c-addr u l               ) */
        exit
    )
WORD_END(_local_)

#undef LASTWORD
#define LASTWORD _local_
