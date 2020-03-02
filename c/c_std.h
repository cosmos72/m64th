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

#ifndef M4TH_C_STD_H
#define M4TH_C_STD_H

# include "../m4th.h"

/** wrapper around C function fread(), easier to call from forth than plain fread() */
m4pair m4th_c_fread(FILE *in, void *addr, size_t len);

/** wrapper around C function fwrite(), easier to call from forth than plain fwrite() */
m4pair m4th_c_fwrite(FILE *out, const void *addr, size_t len);

#endif /* M4TH_C_STD_H */
