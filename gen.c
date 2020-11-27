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
#include "include/dict_fwd.h"       /* m4dict_... */
#include "include/hashmap_number.h" /* m4dict_... */
#include "include/m4th.h"
#include "include/opt_rules.mh" /* OPT*_RULES */
#include "include/word_fwd.h"   /* m4w_...    */

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
               FIRST_5_ARGS(__VA_ARGS__, _missing_, _missing_, _missing_))},
#define OPT3_TO_TOKENS(...)                                                                        \
    {WRAP_ARGS(M4TOKEN_SYM_COMMA, T(COUNT_ARGS(__VA_ARGS__) - 3),                                  \
               FIRST_5_ARGS(__VA_ARGS__, _missing_, _missing_))},

static void genopt_print_n_tokens(m4ucell x, unsigned n, unsigned index, FILE *out);

static void genopt_print_1_token(m4token tok, unsigned index, FILE *out) {
    const m4string s = m4word_ident(m4token_to_word(tok));
    if (s.addr && s.n) {
        fputs(&"|(M4"[index ? 0 : 2], out);
        m4string_print(s, m4mode_user, out);
        if (index) {
            fprintf(out, "<<%u)", index * 16);
        }
    } else if (tok) {
        if (index) {
            fprintf(out, "|(%u<<%u)", (unsigned)tok, index * 16);
        } else {
            fprintf(out, "%u", (unsigned)tok);
        }
    }
}

static void genopt_print_counted_tokens(m4ucell x, FILE *out) {
    unsigned count = (unsigned)(m4token)x;
    fprintf(out, "%u", count);
    genopt_print_n_tokens(x >> 16, count, 1, out);
}

static void genopt_print_n_tokens(m4ucell x, unsigned n, unsigned index, FILE *out) {
    unsigned i;
    for (i = 0; i < n; i++) {
        genopt_print_1_token((m4token)x, index++, out);
        x >>= 16;
    }
}

static void genopt2_dump(const m4hashmap_int *map, const char *label, FILE *out) {
    m4ucell i, cap = 2u << map->lcap;
    fprintf(out,
            "/*\n"
            " * DO NOT EDIT! this file was autogenerated with command './gen'\n"
            " * any change will be lost when the command is run again.\n"
            " */\n"
            "/* clang-format off */\n"
            "#define %s_HASHMAP(start, entry)\t\\\n"
            "start(/*size*/ %u, /*lcap*/ %u)\t\\\n",
            label, (unsigned)map->size, (unsigned)map->lcap);
    for (i = 0; i < cap; i++) {
        const m4hashmap_entry_int *e = map->vec + i;
        fputs("entry(", out);
        if (e->next == m4hash_no_entry_int) {
            fputs("0,\t0", out);
        } else {
            genopt_print_n_tokens(e->key, 2, 0, out);
            fputs(",\t", out);
            genopt_print_counted_tokens(e->val, out);
        }
        fprintf(out, ",\t%d)%s\n", (int)e->next, (i + 1 == cap ? "" : "\t\\"));
    }
}

static void genopt3_dump(const m4hashmap_cell *map, const char *label, FILE *out) {
    m4ucell i, cap = 2u << map->lcap;
    fprintf(out,
            "/*\n"
            " * DO NOT EDIT! this file was autogenerated with command './gen'\n"
            " * any change will be lost when the command is run again.\n"
            " */\n"
            "/* clang-format off */\n"
            "#define %s_HASHMAP(start, entry)\t\\\n"
            "start(/*size*/ %u, /*lcap*/ %u)\t\\\n",
            label, (unsigned)map->size, (unsigned)map->lcap);
    for (i = 0; i < cap; i++) {
        const m4hashmap_entry_cell *e = map->vec + i;
        fputs("entry(", out);
        if (e->next == m4hash_no_entry_cell) {
            fputs("0,\t0", out);
        } else {
            genopt_print_n_tokens(e->key, 3, 0, out);
            fputs(",\t", out);
            genopt_print_counted_tokens(e->val, out);
        }
        fprintf(out, ",\t%d)%s\n", (int)e->next, (i + 1 == cap ? "" : "\t\\"));
    }
}

static void genopt2_add(m4hashmap_int *map, const m4token opt[6]) {
    m4cell key = opt[1] | ((m4cell)opt[2] << 16);
    m4cell val = opt[0] | ((m4cell)opt[3] << 16) | ((m4cell)opt[4] << 32) | ((m4cell)opt[5] << 48);
    const m4hashmap_entry_int *e;
    assert(opt[0] <= 3);
    e = m4hashmap_find_int(map, key);
    assert(e == NULL);
    e = m4hashmap_insert_int(map, key, val);
    assert(e != NULL);
}

static void genopt3_add(m4hashmap_cell *map, const m4token opt[6]) {
    m4cell key = opt[1] | ((m4cell)opt[2] << 16) | ((m4cell)opt[3] << 32);
    m4cell val = opt[0] | ((m4cell)opt[4] << 16) | ((m4cell)opt[5] << 32);
    const m4hashmap_entry_cell *e;
    assert(opt[0] <= 2);
    e = m4hashmap_find_cell(map, key);
    assert(e == NULL);
    e = m4hashmap_insert_cell(map, key, val);
    assert(e != NULL);
}

static void genopt2_run(FILE *out) {
    static const m4token opt[][6] = {OPT2_RULES(OPT2_TO_TOKENS)};
    m4hashmap_int *map = m4hashmap_new_int(N_OF(opt) / 2);
    m4cell i;
    for (i = 0; i < (m4cell)N_OF(opt); i++) {
        genopt2_add(map, opt[i]);
    }
    genopt2_dump(map, "OPT2", out);
}

static void genopt2_lowprio_run(FILE *out) {
    static const m4token opt[][6] = {OPT2_RULES_LOWPRIO(OPT2_TO_TOKENS)};
    m4hashmap_int *map = m4hashmap_new_int(N_OF(opt) / 2);
    m4cell i;
    for (i = 0; i < (m4cell)N_OF(opt); i++) {
        genopt2_add(map, opt[i]);
    }
    genopt2_dump(map, "OPT2_LOWPRIO", out);
}

static void genopt3_run(FILE *out) {
    static const m4token opt[][6] = {OPT3_RULES(OPT3_TO_TOKENS)};
    m4hashmap_cell *map = m4hashmap_new_cell(N_OF(opt) / 4 * 3);
    m4cell i;
    for (i = 0; i < (m4cell)N_OF(opt); i++) {
        genopt3_add(map, opt[i]);
    }
    genopt3_dump(map, "OPT3", out);
}

static void genopt_to_file(const char *path, void (*gen)(FILE *out)) {
    FILE *f = fopen(path, "w");
    gen(f);
    fclose(f);
    fprintf(stdout, "# file '%s' updated\n", path);
}

static void run_show_words(m4printmode mode, FILE *out) {
    const m4dict *dict[] = {
        /* &m4dict_forth_root, */
        &m4dict_forth, &m4dict_m4th_user, &m4dict_m4th_c, &m4dict_m4th_core, &m4dict_m4th_impl,
    };
    m4cell i;
    fputs(license, stdout);
    for (i = 0; i < (m4cell)N_OF(dict); i++) {
        m4dict_print(dict[i], NULL, mode, out);
    }
}

static inline void dpush(m4th *m, m4cell x) {
    *--m->dstack.curr = x;
}

static void run_benchmark(FILE *out) {
    static const m4token code[] = {m4do,     m4two_dup,   m4crc_string, m4drop,
                                   m4_loop_, (m4token)-5, m4bye};
    m4th *m = m4th_new(m4opt_return_stack_is_c_stack);
#ifdef __x86_64__
    const double n = 1e9f;
#else
    const double n = 1e8f;
#endif
    fprintf(out, "benchmark: crc-string%s %g iterations... ",
            (m4th_cpu_features_enabled() & m4th_cpu_feature_crc32c ? "/simd" : ""), n);
    fflush(out);
    m->ip = code;
    dpush(m, (m4cell) "1234567890123456789012345678901234567890123456789012345678901234");
    dpush(m, 64);
    dpush(m, (m4cell)n);
    dpush(m, 0);
    m4th_run(m);
    m4th_del(m);
    fputs("done.\n", out);
}

int main(int argc, char *argv[]) {
    m4cell show_words = argc >= 2 && !strcmp(argv[1], "words");
    m4cell show_disasm = argc >= 2 && !strcmp(argv[1], "disasm");
    m4cell benchmark = argc >= 2 && !strcmp(argv[1], "bench");
    m4cell cpu_features_disable_mask = argc >= 3 && !strcmp(argv[2], "nosimd") ? ttrue : tfalse;
    m4cell cpu_features;

    m4th_init();
    m4th_cpu_features_disable(cpu_features_disable_mask);
    cpu_features = m4th_cpu_features_enabled();

    if (benchmark) {
#if defined(__x86_64__)
#define ARCH_STR_ "amd64 "
#elif defined(__aarch64__)
#define ARCH_STR_ "arm64 "
#else
#define ARCH_STR_ " "
#endif
        if (cpu_features == m4th_cpu_feature_cannot_detect) {
            fputs("# no support to detect optional CPU features on this " ARCH_STR_ "CPU/OS\n",
                  stdout);
        } else if (cpu_features & m4th_cpu_feature_crc32c) {
            fputs("# this " ARCH_STR_ "CPU has crc32c asm instructions\n", stdout);
        } else {
            fputs("# this " ARCH_STR_ "CPU does not have crc32c asm instructions\n", stdout);
        }
        run_benchmark(stdout);
    } else if (show_words || show_disasm) {
        run_show_words(show_words ? m4mode_user : m4mode_c_disasm, stdout);
    } else {
        genopt_to_file("include/opt2_hash.mh", genopt2_run);
        genopt_to_file("include/opt3_hash.mh", genopt3_run);
        genopt_to_file("include/opt2_lowprio_hash.mh", genopt2_lowprio_run);
    }
    return 0;
}
