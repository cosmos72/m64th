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

/* the values below must match the #defines in file err.mh */
typedef enum m4err_id_e {
    m4num_is_word = -1, /* special case rather than an error  */
    m4err_ok = 0,       /* success */
    m4err_eof = 1,
    m4err_syntax = 2,
    m4err_bad_addr = 3,
    m4err_bad_digit = 4,
} m4err_id;

#endif /* M4TH_INCLUDE_ERR_MH */
