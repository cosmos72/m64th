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

#ifndef M4TH_INCLUDE_ERR_H
#define M4TH_INCLUDE_ERR_H

#include "err.mh"

/* the values below must match the s in file err.mh */
typedef enum m4err_id_e {
    m4err_ok = M4ERR_OK, /* SUCCESS */
    m4err_abort = M4ERR_ABORT,
    m4err_abort_quote = M4ERR_ABORT_QUOTE,
    /* ... */
    m4err_undefined_word = M4ERR_UNDEFINED_WORD,
    m4err_interpreting_compile_only_word = M4ERR_INTERPRETING_COMPILE_ONLY_WORD,
    m4err_zero_length_name = M4ERR_ZERO_LENGTH_NAME,
    /* ... */
    m4err_parsed_string_overflow = M4ERR_PARSED_STRING_OVERFLOW,
    m4err_definition_name_too_long = M4ERR_DEFINITION_NAME_TOO_LONG,
    /* ... */
    m4err_invalid_numeric_argument = M4ERR_INVALID_NUMERIC_ARGUMENT,
    m4err_return_stack_imbalance = M4ERR_RETURN_STACK_IMBALANCE,
    m4err_loop_parameters_unavailable = M4ERR_LOOP_PARAMETERS_UNAVAILABLE,
    m4err_invalid_recursion = M4ERR_INVALID_RECURSION,
    m4err_user_interrupt = M4ERR_USER_INTERRUPT,
    /* ... */
    m4err_file_io_exception = M4ERR_FILE_IO_EXCEPTION,
    m4err_non_existent_file = M4ERR_NON_EXISTENT_FILE,
    m4err_unexpected_eof = M4ERR_UNEXPECTED_EOF,
    /* ... */
    m4err_quit = M4ERR_QUIT,
    m4err_exception_in_send_or_recv_char = M4ERR_EXCEPTION_IN_SEND_OR_RECV_CHAR,
    /* ... */
    m4err_is_word = M4ERR_IS_WORD, /* special case, not an error */
    m4err_c_errno = M4ERR_C_ERRNO, /* error is M4ERR_C_ERRNO - errno */
} m4err_id;

#endif /* M4TH_INCLUDE_ERR_MH */
