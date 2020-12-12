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

#include "../include/m64th.h"

#if defined(__i386__) && defined(__GNUC__)
#define FASTCALL __attribute__((regparm(1)))
#define ARGS m6arg *x
typedef m6cell (*m6func_c)(ARGS) FASTCALL;
struct m6arg_s {
    m6cell dtop;
    m6cell *dstk;
    m64th m64th;
};
#define DTOP (x->dtop)
#define DSTK (x->dstk)
#define M64TH (x->m64th)
#define IP (M64TH.ip)
#define FTBL ((m6func_c *)M64TH.ftable)
#define NEXT()                                                                                     \
    do {                                                                                           \
        const m6token t = *IP++;                                                                   \
        return FTBL[t](x);                                                                         \
    } while (0);

#else /* not __i386__ */
#define FASTCALL
#define ARGS m6cell DTOP, m6cell RTOP, m6cell *DSTK, m6cell *RSTK, const m6token *IP, m64th *M64TH
typedef m6cell (*m6func_c)(ARGS);
#define NEXT()                                                                                     \
    do {                                                                                           \
        const m6func_c *FTBL = (m6func_c *)M64TH->ftable;                                           \
        const m6token t = *IP++;                                                                   \
        return FTBL[t](DTOP, RTOP, DSTK, RSTK, IP, M64TH);                                          \
    } while (0);
#endif

#define FUNC_START(name) FASTCALL m6cell m6f##name(ARGS) {
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
    DPUSH__DTOP()
FUNC_END(dup)


FUNC_START(one_plus)
    INC1(DTOP)
FUNC_END(one_plus)
