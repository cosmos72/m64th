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

#include "impl.h"
#include "include/dict_fwd.h" /* m4dict_... */
#include "include/word_fwd.h" /* m4w_... */
#include "m4th.h"

#include <stdio.h>
#include <string.h>

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

const char license[] = "/**\n\
 * Copyright (C) 2020 Massimiliano Ghilardi\n\
 *\n\
 * This file is part of m4th.\n\
 *\n\
 * m4th is free software: you can redistribute it and/or modify\n\
 * it under the terms of the GNU Lesser General Public License\n\
 * as published by the Free Software Foundation, either version 3\n\
 * of the License, or (at your option) any later version.\n\
 *\n\
 * m4th is distributed in the hope that it will be useful,\n\
 * but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
 * GNU Lesser General Public License for more details.\n\
 *\n\
 * You should have received a copy of the GNU Lesser General Public License\n\
 * along with m4th.  If not, see <https://www.gnu.org/licenses/>.\n\
 */\n\n\
\n\
/**\n\
 * For the curious: this output has the same copyright and license\n\
 * as the program m4th, because it's an extract of m4th sources.\n\
 */\n\n";

#define N_OF(array) (sizeof(array) / sizeof((array)[0]))

static void word_print_crc(const m4word *w, FILE *out) {
    const m4string str = m4word_name(w);
    const uint32_t crc = m4th_crcstring(str);
    const uint32_t crc2 = m4th_crcstring(str);
    fprintf(out, "%08x %08x %.*s\n", (unsigned)crc, (unsigned)crc2, (int)str.n,
            (const char *)str.addr);
}

static void dict_print_crc(const m4dict *dict, FILE *out) {
    const m4word *w = m4dict_lastword(dict);
    while (w) {
        word_print_crc(w, out);
        w = m4word_prev(w);
    }
}

static inline void dpush(m4th *m, m4cell val) {
    *--m->dstack.curr = val;
}

static void run_benchmark() {
    const m4token code[] = {m4do, m4two_dup, m4crc_string, m4drop, m4_loop_, (m4token)-5, m4bye};
    m4th *m = m4th_new();

    fputs("benchmark: crc-string 1e7 iterations... ", stdout);
    fflush(stdout);
    m->ip = code;
    dpush(m, (m4cell) "immediate");
    dpush(m, 9);
    dpush(m, 100000000); /* 1e7 iterations */
    dpush(m, 0);
    m4th_run(m);
    m4th_del(m);
    fputs("done.\n", stdout);
}

int main(int argc, char *argv[]) {
    const m4dict *dict[] = {
        &m4dict_forth, &m4dict_m4th_user, &m4dict_m4th_c, &m4dict_m4th_core, &m4dict_m4th_impl,
    };
    m4cell show_crc = argc == 2 && !strcmp(argv[1], "crc");
    m4cell benchmark = argc == 2 && !strcmp(argv[1], "benchmark");
    m4cell i;

    m4th_crcinit(m4th_crctable);
    if (show_crc) {
        for (i = 0; i < (m4cell)N_OF(dict); i++) {
            dict_print_crc(dict[i], stdout);
        }
    } else if (!benchmark) {
        fputs(license, stdout);
        for (i = 0; i < (m4cell)N_OF(dict); i++) {
            m4dict_print(dict[i], NULL, stdout);
        }
    }

    if (show_crc || benchmark) {
        switch (m4th_cpu_has_crc32c_asm_instructions()) {
        case tfalse:
            fputs("# this CPU does not have crc32c asm instructions\n", stdout);
            break;
        case ttrue:
            fputs("# this CPU has crc32c asm instructions\n", stdout);
            break;
        default:
            fputs("# no support to detect crc32c asm instructions on this CPU/OS\n", stdout);
        }
    }
    if (benchmark) {
        run_benchmark();
    }
    return 0;
}
