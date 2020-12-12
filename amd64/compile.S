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

#include "../include/err.mh"
#include "../dispatch/asm.mh"

/* clang-format off */

#define M4FIMMEDIATE
/* immediate ( -- ) mark last defined word as 'immediate' */
FUNC_START(immediate)
        LOAD(  REG1,   AT(M4TH, M4TH_OFF_LASTW))                 /* a = w = m64th.lastw    */
        orw    IMM(M4FLAG_IMMEDIATE),  AT(REG1, WORD_OFF_FLAGS); /* w.flags |= m4flag_immediate */
FUNC_END(immediate)
