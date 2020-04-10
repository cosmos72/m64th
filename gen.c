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
#include "include/hash_map.h" /* m4dict_... */
#include "include/opt.mh"     /* OPT2_BODY  */
#include "include/word_fwd.h" /* m4w_...    */
#include "m4th.h"

#include <assert.h>
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

#define OPT1_TO_TOKENS(...)                                                                        \
    {WRAP_ARGS(M4TOKEN_SYM_COMMA, T(COUNT_ARGS(__VA_ARGS__) - 1),                                  \
               FIRST_3_ARGS(__VA_ARGS__, _missing_, _missing_))},
#define OPT2_TO_TOKENS(...)                                                                        \
    {WRAP_ARGS(M4TOKEN_SYM_COMMA, T(COUNT_ARGS(__VA_ARGS__) - 2),                                  \
               FIRST_4_ARGS(__VA_ARGS__, _missing_, _missing_))},
#define OPT3_TO_TOKENS(...)                                                                        \
    {WRAP_ARGS(M4TOKEN_SYM_COMMA, T(COUNT_ARGS(__VA_ARGS__) - 3),                                  \
               FIRST_5_ARGS(__VA_ARGS__, _missing_, _missing_))},

static void genopt2_add(m4hash_map *map, const m4token opt[5]) {
    m4hash_key key = opt[1] | ((m4hash_key)opt[2] << 16);
    m4hash_key val = opt[0] | ((m4hash_key)opt[3] << 16) | ((m4hash_key)opt[4] << 24);
    assert(m4hash_map_find(map, key) == NULL);
    assert(m4hash_map_insert(map, key, val));
}

static void run_genopt(void) {
    static const m4token opt2[][5] = {OPT2_BODY(OPT2_TO_TOKENS)};
    m4hash_map *map = m4hash_map_new(N_OF(opt2) / 2);
    m4cell i, cap;

    for (i = 0; i < (m4cell)N_OF(opt2); i++) {
        genopt2_add(map, opt2[i]);
    }
    cap = 2u << map->lcap;
    for (i = 0; i < cap; i++) {
        const m4hash_entry *e = map->vec + i;
        fprintf(stdout, "{0x%x,\t0x%x,\t0x%x},\n", (unsigned)e->key, (unsigned)e->val,
                (unsigned)e->next_index);
    }
}

static void run_show_words(void) {
    const m4dict *dict[] = {
        &m4dict_forth, &m4dict_m4th_user, &m4dict_m4th_c, &m4dict_m4th_core, &m4dict_m4th_impl,
    };
    m4cell i;
    fputs(license, stdout);
    for (i = 0; i < (m4cell)N_OF(dict); i++) {
        m4dict_print(dict[i], NULL, stdout);
    }
}

static inline void dpush(m4th *m, m4cell x) {
    *--m->dstack.curr = x;
}

static void run_benchmark(void) {
    static const m4token code[] = {m4do,     m4two_dup,   m4crc_string, m4drop,
                                   m4_loop_, (m4token)-5, m4bye};
    m4th *m = m4th_new();
#ifdef __x86_64__
    const double n = 1e9f;
#else
    const double n = 1e8f;
#endif
    fprintf(stdout, "benchmark: crc-string%s %g iterations... ",
            (m4th_cpu_features_enabled() & m4th_cpu_feature_crc32c ? "/simd" : ""), n);
    fflush(stdout);
    m->ip = code;
    dpush(m, (m4cell) "immediate");
    dpush(m, 9);
    dpush(m, (m4cell)n);
    dpush(m, 0);
    m4th_run(m);
    m4th_del(m);
    fputs("done.\n", stdout);
}

int main(int argc, char *argv[]) {
    m4cell show_words = argc >= 2 && !strcmp(argv[1], "words");
    m4cell benchmark = argc >= 2 && !strcmp(argv[1], "bench");
    m4cell cpu_features_disable_mask = argc >= 3 && !strcmp(argv[2], "nosimd") ? ttrue : tfalse;
    m4cell cpu_features;

    m4th_init();
    cpu_features = m4th_cpu_features_enabled();
    m4th_cpu_features_disable(cpu_features_disable_mask);

    if (benchmark) {
        if (cpu_features == m4th_cpu_feature_cannot_detect) {
            fputs("# no support to detect optional CPU features on this CPU/OS\n", stdout);
        } else if (cpu_features & m4th_cpu_feature_crc32c) {
            fputs("# this CPU has crc32c asm instructions\n", stdout);
        } else {
            fputs("# this CPU does not have crc32c asm instructions\n", stdout);
        }
        run_benchmark();
    } else if (show_words) {
        run_show_words();
    } else {
        run_genopt();
    }
    return 0;
}
