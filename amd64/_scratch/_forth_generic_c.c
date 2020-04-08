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

#include "../m4th.h"

#if defined(__i386__) && defined(__GNUC__)
#define FASTCALL __attribute__((regparm(1)))
#define ARGS m4arg *x
typedef m4cell (*m4func_c)(ARGS) FASTCALL;
struct m4arg_s {
    m4cell dtop;
    m4cell *dstk;
    m4th m4th;
};
#define DTOP (x->dtop)
#define DSTK (x->dstk)
#define M4TH (x->m4th)
#define IP (M4TH.ip)
#define FTBL ((m4func_c *)M4TH.ftable)
#define NEXT()                                                                                     \
    do {                                                                                           \
        const m4token t = *IP++;                                                                   \
        return FTBL[t](x);                                                                         \
    } while (0);

#else /* not __i386__ */
#define FASTCALL
#define ARGS m4cell DTOP, m4cell RTOP, m4cell *DSTK, m4cell *RSTK, const m4token *IP, m4th *M4TH
typedef m4cell (*m4func_c)(ARGS);
#define NEXT()                                                                                     \
    do {                                                                                           \
        const m4func_c *FTBL = (m4func_c *)M4TH->ftable;                                           \
        const m4token t = *IP++;                                                                   \
        return FTBL[t](DTOP, RTOP, DSTK, RSTK, IP, M4TH);                                          \
    } while (0);
#endif

#define FUNC_START(name) FASTCALL m4cell m4f##name(ARGS) {
#define FUNC_RAWEND(name) }
#define FUNC_END(name)                                                                             \
    NEXT()                                                                                         \
    FUNC_RAWEND(name)

#define DPUSH(val) *--DSTK = (val);
#define DPOP(val) (val) = *DSTK++;
#define INC1(reg) ++reg;

/* clang-format off */

FUNC_START(noop)
FUNC_END(noop)


FUNC_START(dup)
    DPUSH(DTOP)
FUNC_END(dup)


FUNC_START(one_plus)
    INC1(DTOP)
FUNC_END(one_plus)
