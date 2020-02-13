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
#include <stddef.h> /* size_t    */

void *word_to_xt(m4word *w) {
    return w->data + w->code_off;
}

void foo(const size_t *data);

void bar() {
    size_t data[1];
    foo(data);
}

size_t string_equal(const char *a, const char *b, size_t n) {
    size_t i = 0;
    if (n == 0 || a == b) {
        return (size_t)-1;
    }
    if (n >= 8) {
        n -= 8;
        do {
            const size_t *sa = (const size_t *)(a + i);
            const size_t *sb = (const size_t *)(b + i);
            if (sa[0] != sb[0]) {
                return 0;
            }
        } while ((i += 8) < n);
        const size_t *sa = (const size_t *)(a + n);
        const size_t *sb = (const size_t *)(b + n);
        if (sa[0] != sb[0]) {
            return 0;
        }
    } else {
        do {
            if (a[i] != b[i]) {
                return 0;
            }
        } while (++i < n);
    }
    return (size_t)-1;
}

int main(void) {
}
