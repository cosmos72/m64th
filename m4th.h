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

#ifndef M4TH_M4TH_H
#define M4TH_M4TH_H

#include <stddef.h>    /* size_t  */
#include <sys/types.h> /* ssize_t */

typedef size_t m_uint;
typedef ssize_t m_int;

struct m4th_s {
    m_int* dstack0; /* pointer to bottom of data stack */
    m_int* dstack;  /* pointer to top    of data stack */
    m_int* rstack0; /* pointer to bottom of return stack */
    m_int* rstack;  /* pointer to top    of return stack */
    m_int* code;    /* executable code */
    m_int* c_stack; /* saved here by m4th_enter */
};

typedef struct m4th_s m4th;

m4th* m4th_new();
void  m4th_free(m4th* interp);

/* main entry point from C. implemented in assembly */
void m4th_enter(m4th* interp);

#endif /* M4TH_M4TH_H */
