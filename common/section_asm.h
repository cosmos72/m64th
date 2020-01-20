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

#ifndef M4TH_COMMON_SECTION_ASM_H
#define M4TH_COMMON_SECTION_ASM_H

#define SECTION_FUNC() .text

/*
 * work around Android linker message
 * "warning: creating a DT_TEXTREL in a shared object"
 * because it produces non-working executable that fail with
 * CANNOT LINK EXECUTABLE: "/cmd/full/path" has text relocations
 */
#if defined(__ELF__) && !defined(__ANDROID__)
#define SECTION_RODATA() .section .rodata
#else
#define SECTION_RODATA() .data
#endif

#endif /* M4TH_COMMON_SECTION_ASM_H */
