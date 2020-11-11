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
    m4err_ok = M4ERR_OK,                                                         /* 0 SUCCESS */
    m4err_abort = M4ERR_ABORT,                                                   /* -1 */
    m4err_abort_quote = M4ERR_ABORT_QUOTE,                                       /* -2 */
    m4err_stack_overflow = M4ERR_STACK_OVERFLOW,                                 /* -3 */
    m4err_stack_underflow = M4ERR_STACK_UNDERFLOW,                               /* -4 */
    m4err_return_stack_overflow = M4ERR_RETURN_STACK_OVERFLOW,                   /* -5 */
    m4err_return_stack_underflow = M4ERR_RETURN_STACK_UNDERFLOW,                 /* -6 */
    m4err_too_many_nested_do_loop = M4ERR_TOO_MANY_NESTED_DO_LOOP,               /* -7 */
    m4err_wordlist_overflow = M4ERR_WORDLIST_OVERFLOW,                           /* -8 */
    m4err_invalid_memory_address = M4ERR_INVALID_MEMORY_ADDRESS,                 /* -9 */
    m4err_division_by_zero = M4ERR_DIVISION_BY_ZERO,                             /* -10 */
    m4err_result_out_of_range = M4ERR_RESULT_OUT_OF_RANGE,                       /* -11 */
    m4err_argument_type_mismatch = M4ERR_ARGUMENT_TYPE_MISMATCH,                 /* -12 */
    m4err_undefined_word = M4ERR_UNDEFINED_WORD,                                 /* -13 */
    m4err_interpreting_compile_only_word = M4ERR_INTERPRETING_COMPILE_ONLY_WORD, /* -14 */
    m4err_invalid_forget = M4ERR_INVALID_FORGET,                                 /* -15 */
    m4err_zero_length_name = M4ERR_ZERO_LENGTH_NAME,                             /* -16 */
    m4err_parsed_string_overflow = M4ERR_PARSED_STRING_OVERFLOW,                 /* -18 */
    m4err_definition_name_too_long = M4ERR_DEFINITION_NAME_TOO_LONG,             /* -19 */
    m4err_write_to_readonly_location = M4ERR_WRITE_TO_READONLY_LOCATION,         /* -20 */
    m4err_unsupported_operation = M4ERR_UNSUPPORTED_OPERATION,                   /* -21 */
    m4err_control_structure_mismatch = M4ERR_CONTROL_STRUCTURE_MISMATCH,         /* -22 */
    m4err_address_alignment_exception = M4ERR_ADDRESS_ALIGNMENT_EXCEPTION,       /* -23 */
    m4err_invalid_numeric_argument = M4ERR_INVALID_NUMERIC_ARGUMENT,             /* -24 */
    m4err_return_stack_imbalance = M4ERR_RETURN_STACK_IMBALANCE,                 /* -25 */
    m4err_loop_parameters_unavailable = M4ERR_LOOP_PARAMETERS_UNAVAILABLE,       /* -26 */
    m4err_invalid_recursion = M4ERR_INVALID_RECURSION,                           /* -27 */
    m4err_user_interrupt = M4ERR_USER_INTERRUPT,                                 /* -28 */
    m4err_compiler_nesting = M4ERR_COMPILER_NESTING,                             /* -29 */
    /* ... */
    m4err_file_io_exception = M4ERR_FILE_IO_EXCEPTION, /* -37 */
    m4err_non_existent_file = M4ERR_NON_EXISTENT_FILE, /* -38 */
    m4err_unexpected_eof = M4ERR_UNEXPECTED_EOF,       /* -39 */
    /* ... */
    m4err_quit = M4ERR_QUIT,                                                     /* -56 */
    m4err_exception_in_send_or_recv_char = M4ERR_EXCEPTION_IN_SEND_OR_RECV_CHAR, /* -57 */
    /* ... */
    m4err_defer_uninitialized = M4ERR_DEFER_UNINITIALIZED, /* -256 */
    m4err_not_created = M4ERR_NOT_CREATED,                 /* -257 */
    m4err_out_of_memory = M4ERR_OUT_OF_MEMORY,             /* -258 */

    m4err_c_errno = M4ERR_C_ERRNO, /* error is M4ERR_C_ERRNO - errno */
} m4err_id;

#endif /* M4TH_INCLUDE_ERR_MH */
