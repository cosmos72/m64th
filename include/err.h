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

#ifndef M64TH_INCLUDE_ERR_H
#define M64TH_INCLUDE_ERR_H

#include "err.mh"

/* the values below must match the s in file err.mh */
typedef enum m6err_id_e {
    m6err_ok = M6ERR_OK,                                                         /* 0 SUCCESS */
    m6err_abort = M6ERR_ABORT,                                                   /* -1 */
    m6err_abort_quote = M6ERR_ABORT_QUOTE,                                       /* -2 */
    m6err_stack_overflow = M6ERR_STACK_OVERFLOW,                                 /* -3 */
    m6err_stack_underflow = M6ERR_STACK_UNDERFLOW,                               /* -4 */
    m6err_return_stack_overflow = M6ERR_RETURN_STACK_OVERFLOW,                   /* -5 */
    m6err_return_stack_underflow = M6ERR_RETURN_STACK_UNDERFLOW,                 /* -6 */
    m6err_too_many_nested_do_loop = M6ERR_TOO_MANY_NESTED_DO_LOOP,               /* -7 */
    m6err_wordlist_overflow = M6ERR_WORDLIST_OVERFLOW,                           /* -8 */
    m6err_invalid_memory_address = M6ERR_INVALID_MEMORY_ADDRESS,                 /* -9 */
    m6err_division_by_zero = M6ERR_DIVISION_BY_ZERO,                             /* -10 */
    m6err_result_out_of_range = M6ERR_RESULT_OUT_OF_RANGE,                       /* -11 */
    m6err_argument_type_mismatch = M6ERR_ARGUMENT_TYPE_MISMATCH,                 /* -12 */
    m6err_undefined_word = M6ERR_UNDEFINED_WORD,                                 /* -13 */
    m6err_interpreting_compile_only_word = M6ERR_INTERPRETING_COMPILE_ONLY_WORD, /* -14 */
    m6err_invalid_forget = M6ERR_INVALID_FORGET,                                 /* -15 */
    m6err_zero_length_name = M6ERR_ZERO_LENGTH_NAME,                             /* -16 */
    m6err_parsed_string_overflow = M6ERR_PARSED_STRING_OVERFLOW,                 /* -18 */
    m6err_definition_name_too_long = M6ERR_DEFINITION_NAME_TOO_LONG,             /* -19 */
    m6err_write_to_readonly_location = M6ERR_WRITE_TO_READONLY_LOCATION,         /* -20 */
    m6err_unsupported_operation = M6ERR_UNSUPPORTED_OPERATION,                   /* -21 */
    m6err_control_structure_mismatch = M6ERR_CONTROL_STRUCTURE_MISMATCH,         /* -22 */
    m6err_address_alignment_exception = M6ERR_ADDRESS_ALIGNMENT_EXCEPTION,       /* -23 */
    m6err_invalid_numeric_argument = M6ERR_INVALID_NUMERIC_ARGUMENT,             /* -24 */
    m6err_return_stack_imbalance = M6ERR_RETURN_STACK_IMBALANCE,                 /* -25 */
    m6err_loop_parameters_unavailable = M6ERR_LOOP_PARAMETERS_UNAVAILABLE,       /* -26 */
    m6err_invalid_recursion = M6ERR_INVALID_RECURSION,                           /* -27 */
    m6err_user_interrupt = M6ERR_USER_INTERRUPT,                                 /* -28 */
    m6err_compiler_nesting = M6ERR_COMPILER_NESTING,                             /* -29 */
    m6err_obsolescent_feature = M6ERR_OBSOLESCENT_FEATURE,                       /* -30 */
    m6err_not_created = M6ERR_NOT_CREATED,                                       /* -31 */
    m6err_invalid_to_name = M6ERR_INVALID_TO_NAME,                               /* -32 */
    /* ... */                                                                    /*     */
    m6err_file_io_exception = M6ERR_FILE_IO_EXCEPTION,                           /* -37 */
    m6err_non_existent_file = M6ERR_NON_EXISTENT_FILE,                           /* -38 */
    m6err_unexpected_eof = M6ERR_UNEXPECTED_EOF,                                 /* -39 */
    /* ... */                                                                    /*     */
    m6err_quit = M6ERR_QUIT,                                                     /* -56 */
    m6err_failed_to_send_or_recv_char = M6ERR_FAILED_TO_SEND_OR_RECV_CHAR,       /* -57 */
    /* ... */                                                                    /*     */
    m6err_failed_to_allocate = M6ERR_FAILED_TO_ALLOCATE,                         /* -59 */
    /* ... */                                                                    /*     */
    m6err_not_defer = M6ERR_NOT_DEFER,                                           /* -256 */
    m6err_defer_uninitialized = M6ERR_DEFER_UNINITIALIZED,                       /* -257 */
    m6err_locals_overflow = M6ERR_LOCALS_OVERFLOW,                               /* -258 */
    m6err_asm_overflow = M6ERR_ASM_OVERFLOW,                                     /* -259 */
    /* ... */                                                                    /*      */
    m6err_c_errno = M6ERR_C_ERRNO, /* error is M6ERR_C_ERRNO - errno               -3500 */
} m6err_id;

#endif /* M64TH_INCLUDE_ERR_MH */
