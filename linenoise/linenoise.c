/* linenoise.c -- guerrilla line editing library against the idea that a
 * line editing lib needs to be 20,000 lines of C code.
 *
 * You can find the latest source code at:
 *
 *   http://github.com/antirez/linenoise
 *
 * Does a number of crazy assumptions that happen to be true in 99.9999% of
 * the 2010 UNIX computers around.
 *
 * ------------------------------------------------------------------------
 *
 * Copyright (c) 2010-2016, Salvatore Sanfilippo <antirez at gmail dot com>
 * Copyright (c) 2010-2013, Pieter Noordhuis <pcnoordhuis at gmail dot com>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *  *  Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *  *  Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ------------------------------------------------------------------------
 *
 * References:
 * - http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
 * - http://www.3waylabs.com/nw/WWW/products/wizcon/vt220.html
 *
 * Todo list:
 * - Filter bogus Ctrl+<char> combinations.
 * - Win32 support
 *
 * Bloat:
 * - History search like Ctrl+r in readline?
 *
 * List of escape sequences used by this program, we do everything just
 * with three sequences. In order to be so cheap we may have some
 * flickering effect with some slow terminal, but the lesser sequences
 * the more compatible.
 *
 * EL (Erase Line)
 *    Sequence: ESC [ n K
 *    Effect: if n is 0 or missing, clear from cursor to end of line
 *    Effect: if n is 1, clear from beginning of line to cursor
 *    Effect: if n is 2, clear entire line
 *
 * CUF (CUrsor Forward)
 *    Sequence: ESC [ n C
 *    Effect: moves cursor forward n chars
 *
 * CUB (CUrsor Backward)
 *    Sequence: ESC [ n D
 *    Effect: moves cursor backward n chars
 *
 * The following is used to get the terminal width if getting
 * the width with the TIOCGWINSZ ioctl fails
 *
 * DSR (Device Status Report)
 *    Sequence: ESC [ 6 n
 *    Effect: reports the current cusor position as ESC [ n ; m R
 *            where n is the row and m is the column
 *
 * When multi line mode is enabled, we also use an additional escape
 * sequence. However multi line editing is disabled by default.
 *
 * CUU (Cursor Up)
 *    Sequence: ESC [ n A
 *    Effect: moves cursor up of n chars.
 *
 * CUD (Cursor Down)
 *    Sequence: ESC [ n B
 *    Effect: moves cursor down of n chars.
 *
 * When linenoiseClearScreen() is called, two additional escape sequences
 * are used in order to clear the screen and position the cursor at home
 * position.
 *
 * CUP (Cursor position)
 *    Sequence: ESC [ H
 *    Effect: moves the cursor to upper left corner
 *
 * ED (Erase display)
 *    Sequence: ESC [ 2 J
 *    Effect: clear the whole screen
 *
 */

#include "linenoise.h"
#include <ctype.h>
#include <errno.h>
#include <limits.h> /* CHAR_MIN */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <termios.h>
#include <unistd.h>

#define LINENOISE_DEFAULT_HISTORY_MAX_LEN 100
#ifndef LINENOISE_MAX_LINE
#define LINENOISE_MAX_LINE 4096
#endif
static char *unsupported_term[] = {"dumb", "cons25", "emacs", NULL};
static linenoiseStrings completions = {0, 0, NULL};
static linenoiseCompletionCallback *completionCallback = NULL;
static void *completionCallbackUserData = NULL;
static linenoiseHintsCallback *hintsCallback = NULL;
static linenoiseFreeHintsCallback *freeHintsCallback = NULL;

static struct termios orig_termios; /* In order to restore at exit.*/
static int rawmode = 0;             /* For atexit() function to check if restore is needed*/
static int mlmode = 0;              /* Multi line mode. Default is single line. */
static int atexit_registered = 0;   /* Register atexit just 1 time. */
static int history_max_len = LINENOISE_DEFAULT_HISTORY_MAX_LEN;
static int history_len = 0;
static char **history = NULL;

enum KEY_ACTION {
    CTRL_AT = 0,    /* Ctrl+@ i.e. NIL */
    CTRL_A = 1,     /* Ctrl+a */
    CTRL_B = 2,     /* Ctrl-b */
    CTRL_C = 3,     /* Ctrl-c */
    CTRL_D = 4,     /* Ctrl-d */
    CTRL_E = 5,     /* Ctrl-e */
    CTRL_F = 6,     /* Ctrl-f */
    CTRL_H = 8,     /* Ctrl-h */
    TAB = 9,        /* Tab */
    CTRL_J = 10,    /* Ctrl+j i.e. LF */
    CTRL_K = 11,    /* Ctrl+k */
    CTRL_L = 12,    /* Ctrl+l */
    ENTER = 13,     /* Enter */
    CTRL_N = 14,    /* Ctrl-n */
    CTRL_P = 16,    /* Ctrl-p */
    CTRL_T = 20,    /* Ctrl-t */
    CTRL_U = 21,    /* Ctrl+u */
    CTRL_W = 23,    /* Ctrl+w */
    ESC = 27,       /* Escape */
    CTRL_BACK = 31, /* Ctrl+backspace */
    BACKSPACE = 127 /* Backspace */
};

/* We define a very simple "append buffer" structure, that is an heap
 * allocated string where we can append to. This is useful in order to
 * write all the escape sequences in a buffer and flush them to the standard
 * output in a single call, to avoid flickering effects. */
typedef struct abuf {
    int len;
    int cap;
    char *addr;
} abuf;

/* The linenoiseState structure represents the state during line editing.
 * We pass this state to functions implementing specific editing
 * functionalities. */
typedef struct linenoiseState {
    int ifd;                    /* Terminal stdin file descriptor. */
    int ofd;                    /* Terminal stdout file descriptor. */
    char *buf;                  /* Edited line buffer. */
    size_t buflen;              /* Edited line buffer size. */
    linenoiseString prompt;     /* Prompt to display. */
    abuf abuf;                  /* Write buffer. */
    size_t pos;                 /* Current cursor position. */
    size_t oldpos;              /* Previous refresh cursor position. */
    size_t len;                 /* Current edited line length. */
    linenoiseString stem;       /* Stem to be hidden when showing completions. */
    linenoiseString completion; /* Current completion to show. */
    size_t cols;                /* Number of columns in terminal. */
    size_t maxrows;             /* Maximum num of rows used so far (multiline mode) */
    int history_index;          /* The history index we are currently editing. */
} linenoiseState;

static void linenoiseAtExit(void);
int linenoiseHistoryAdd(const char *line);
static void refreshLine(linenoiseState *l);
/* also return effective cursor position due to current completion */
static size_t abAppendInputAndCompletion(abuf *ab, linenoiseState *l);

static int imax2(int a, int b) {
    return a > b ? a : b;
}

static size_t min2(size_t a, size_t b) {
    return a < b ? a : b;
}

/* Debugging macro. */
#if 0
FILE *lndebug_fp = NULL;
#define lndebug(...)                                                                               \
    do {                                                                                           \
        if (lndebug_fp == NULL) {                                                                  \
            lndebug_fp = fopen("/tmp/lndebug.txt", "a");                                           \
            fprintf(lndebug_fp, "[%d %d %d] p: %d, rows: %d, rpos: %d, max: %d, oldmax: %d\n",     \
                    (int)l->len, (int)l->pos, (int)l->oldpos, plen, rows, rpos, (int)l->maxrows,   \
                    old_rows);                                                                     \
        }                                                                                          \
        fprintf(lndebug_fp, ", " __VA_ARGS__);                                                     \
        fflush(lndebug_fp);                                                                        \
    } while (0)
#else
#define lndebug(fmt, ...)
#endif

/* ======================= Low level terminal handling ====================== */

/* Set if to use or not the multi line mode. */
void linenoiseSetMultiLine(int ml) {
    mlmode = ml;
}

/* Return true if the terminal name is in the list of terminals we know are
 * not able to understand basic escape sequences. */
static int isUnsupportedTerm(void) {
    char *term = getenv("TERM");
    int j;

    if (term == NULL)
        return 0;
    for (j = 0; unsupported_term[j]; j++)
        if (!strcasecmp(term, unsupported_term[j]))
            return 1;
    return 0;
}

/* BUG: on x86_64 with optimizations enabled, clang uses %xmm registers */
/* in function termiosRawMode() to read&write 'raw' fields.             */
/* this works only if the pointer 'raw' is aligned at 16 bytes - which is not always true */
/* defining termiosRawMode() as noinline seems to trick clang into aligning it */
#ifdef __clang__
__attribute__((noinline))
#endif
static void
/* Raw mode: 1960 magic shit. */
termiosRawMode(struct termios *raw, const struct termios *orig) {
    *raw = *orig;
    /* input modes: no break, no CR to NL, no parity check, no strip char,
     * no start/stop output control. */
    raw->c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    /* control modes - set 8 bit chars */
    raw->c_cflag |= (CS8);
    /* output modes - disable post processing */
    raw->c_oflag &= ~(OPOST);
    /* local modes - echo off, canonical off, no extended functions,
     * no signal chars (^Z,^C) */
    raw->c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
    /* control chars - set return condition: min number of bytes and timer.
     * We want read to return every single byte, without timeout. */
    raw->c_cc[VMIN] = 1;
    raw->c_cc[VTIME] = 0; /* 1 byte, no timer */
}

static int enableRawMode(int fd) {
    struct termios raw;

    if (!isatty(STDIN_FILENO)) {
        errno = ENOTTY;
        return -1;
    }
    if (!atexit_registered) {
        atexit(linenoiseAtExit);
        atexit_registered = 1;
    }
    if (tcgetattr(fd, &orig_termios) == -1) {
        return -1;
    }
    termiosRawMode(&raw, &orig_termios);

    /* put terminal in raw mode */
    if (tcsetattr(fd, TCSANOW, &raw) < 0) {
        return -1;
    }
    rawmode = 1;
    return 0;
}

static void disableRawMode(int fd) {
    /* Don't even check the return value as it's too late. */
    if (rawmode && tcsetattr(fd, TCSANOW, &orig_termios) != -1) {
        rawmode = 0;
    }
}

/* Use the ESC [6n escape sequence to query the horizontal cursor position
 * and return it. On error -1 is returned, on success the position of the
 * cursor. */
static int getCursorPosition(int ifd, int ofd) {
    char buf[32];
    int cols, rows;
    unsigned int i = 0;

    /* Report cursor location */
    if (write(ofd, "\x1b[6n", 4) != 4)
        return -1;

    /* Read the response: ESC [ rows ; cols R */
    while (i < sizeof(buf) - 1) {
        if (read(ifd, buf + i, 1) != 1)
            break;
        if (buf[i] == 'R')
            break;
        i++;
    }
    buf[i] = '\0';

    /* Parse it. */
    if (buf[0] != ESC || buf[1] != '[')
        return -1;
    if (sscanf(buf + 2, "%d;%d", &rows, &cols) != 2)
        return -1;
    return cols;
}

/* Try to get the number of columns in the current terminal, or assume 80
 * if it fails. */
static int getColumns(int ifd, int ofd) {
    struct winsize ws;

    if (ioctl(ofd, TIOCGWINSZ, &ws) == -1 || ws.ws_col == 0) {
        /* ioctl() failed. Try to query the terminal itself. */
        int start, cols;

        /* Get the initial position so we can restore it later. */
        start = getCursorPosition(ifd, ofd);
        if (start == -1)
            goto failed;

        /* Go to right margin and get position. */
        if (write(ofd, "\x1b[999C", 6) != 6)
            goto failed;
        cols = getCursorPosition(ifd, ofd);
        if (cols == -1)
            goto failed;

        /* Restore position. */
        if (cols > start) {
            char seq[32];
            snprintf(seq, 32, "\x1b[%dD", cols - start);
            if (write(ofd, seq, strlen(seq)) == -1) {
                /* Can't recover... */
            }
        }
        return cols;
    } else {
        return ws.ws_col;
    }

failed:
    return 80;
}

/* Try to get the number of columns in the current terminal, or assume 80
 * if it fails. */
int linenoiseGetTerminalColumns(void) {
    return getColumns(STDIN_FILENO, STDOUT_FILENO);
}

/* Clear the screen. Used to handle ctrl+l */
void linenoiseClearScreen(void) {
    if (write(STDOUT_FILENO, "\x1b[H\x1b[2J", 7) <= 0) {
        /* nothing to do, just to avoid warning. */
    }
}

/* Beep, used for completion when there is nothing to complete or when all
 * the choices were already shown. */
static void linenoiseBeep(void) {
    fprintf(stderr, "\x7");
    fflush(stderr);
}

/* ============================== Completion ================================ */

/* set current completion in linenoiseState */
static void setCurrentCompletion(linenoiseState *ls, linenoiseString stem,
                                 linenoiseString completion) {
    ls->stem = stem;
    ls->completion = completion;
}

/* remove current completion from linenoiseState */
static void clearCurrentCompletion(linenoiseState *ls) {
    ls->completion.len = ls->stem.len = 0;
    ls->completion.addr = ls->stem.addr = NULL;
}

/* clear the completion options populated by linenoiseAddCompletion(). */
static void clearCompletions(linenoiseStrings *lc) {
    lc->size = 0;
}

/* free the completion options populated by linenoiseAddCompletion(). */
void linenoiseFreeCompletions(linenoiseStrings *lc) {
    lc->capacity = lc->size = 0;
    free(lc->vec);
    lc->vec = NULL;
}

static linenoiseString makeString(size_t len, const char *addr) {
    linenoiseString str = {len, addr};
    return str;
}

/* This is an helper function for linenoiseEdit() and is called when the
 * user types the <tab> key in order to complete the string currently in the
 * input.
 *
 * The state of the editing is encapsulated into the pointed linenoiseState
 * structure as described in the structure definition. */
static int completeLine(linenoiseState *ls) {
    linenoiseStrings *lc = &completions;
    linenoiseString stem;
    int nread, nwritten;
    char c = 0;

    stem = completionCallback(makeString(ls->pos, ls->buf), lc, completionCallbackUserData);
    if (lc->size == 0) {
        linenoiseBeep();
    } else {
        size_t stop = 0, i = 0;

        while (!stop) {
            /* Show completion or original buffer */
            if (i < lc->size) {
                setCurrentCompletion(ls, stem, lc->vec[i]);
            }
            refreshLine(ls);
            clearCurrentCompletion(ls);

            nread = read(ls->ifd, &c, 1);
            if (nread <= 0) {
                clearCompletions(lc);
                return -1;
            }

            switch (c) {
            case TAB:
                i = (i + 1) % (lc->size + 1);
                if (i == lc->size)
                    linenoiseBeep();
                break;
            default:
                /* accept current completion: Update buffer and return */
                if (i < lc->size) {
                    abuf *ab = &ls->abuf;
                    size_t cursor;
                    ab->len = 0;

                    setCurrentCompletion(ls, stem, lc->vec[i]);
                    cursor = abAppendInputAndCompletion(ab, ls);
                    clearCurrentCompletion(ls);

                    nwritten = min2(ls->buflen, ab->len);
                    memcpy(ls->buf, ab->addr, nwritten);
                    ab->len = 0;
                    ls->buf[nwritten] = '\0';
                    ls->len = nwritten;
                    ls->pos = cursor;
                }
                stop = 1;
                break;
            }
        }
    }

    clearCompletions(lc);
    return c; /* Return last read character */
}

/* Register a callback function to be called for tab-completion. */
void linenoiseSetCompletionCallback(linenoiseCompletionCallback *fn, void *userData) {
    completionCallback = fn;
    completionCallbackUserData = userData;
}

/* Register a hints function to be called to show hints to the user at the
 * right of the prompt. */
void linenoiseSetHintsCallback(linenoiseHintsCallback *fn) {
    hintsCallback = fn;
}

/* Register a function to free the hints returned by the hints callback
 * registered with linenoiseSetHintsCallback(). */
void linenoiseSetFreeHintsCallback(linenoiseFreeHintsCallback *fn) {
    freeHintsCallback = fn;
}

/* This function is used by the callback function registered by the user
 * in order to add completion options given the input string when the
 * user typed <tab>. See the example.c source code for a very easy to
 * understand example. */
void linenoiseAddCompletion(linenoiseStrings *lc, linenoiseString str) {
    linenoiseString *vec = lc->vec;
    if (lc->size >= lc->capacity) {
        size_t capacity = lc->capacity ? lc->capacity * 2 : 10;
        vec = realloc(vec, sizeof(linenoiseString) * capacity);
        if (vec == NULL) {
            return;
        }
        lc->vec = vec;
        lc->capacity = capacity;
    }
    lc->vec[lc->size++] = str;
}

/* =========================== Line editing ================================= */

static void abFree(abuf *ab) {
    free(ab->addr);
    ab->cap = ab->len = 0;
    ab->addr = NULL;
}

static void abAppend(abuf *ab, const char *s, int len) {
    char *addr = ab->addr;
    if (len > ab->cap - ab->len) {
        int capacity = imax2(ab->len + len, ab->cap ? ab->cap * 2 : 40);
        addr = realloc(addr, capacity);
        if (addr == NULL) {
            return;
        }
        ab->addr = addr;
        ab->cap = capacity;
    }
    memcpy(addr + ab->len, s, len);
    ab->len += len;
}

/* also return effective cursor position due to current completion */
static size_t abAppendInputAndCompletion(abuf *ab, linenoiseState *l) {
    size_t cursor = l->pos;
    if (l->completion.len != 0 && l->completion.addr != NULL) {
        int pos1 = cursor, pos2 = pos1;
        cursor += l->completion.len;
        if (l->stem.len != 0 && l->stem.addr != NULL && l->stem.addr >= l->buf &&
            l->stem.addr + l->stem.len <= l->buf + l->len) {
            /* input text between pos1 and pos2 is not shown,
             * because it is replaced with completion */
            pos1 = l->stem.addr - l->buf;
            pos2 = pos1 + l->stem.len;
            cursor -= l->stem.len;
        }
        abAppend(ab, l->buf, pos1);
        abAppend(ab, l->completion.addr, l->completion.len);
        abAppend(ab, l->buf + pos2, l->len - pos2);

    } else {
        abAppend(ab, l->buf, l->len);
    }
    return cursor;
}

/* Helper of refreshSingleLine() and refreshMultiLine() to show hints
 * to the right of the current input. */
void refreshShowHints(abuf *ab, linenoiseString input, linenoiseState *l) {
    char seq[64];
    int plen = l->prompt.len;
    if (hintsCallback && plen + l->len < l->cols) {
        int color = -1, bold = 0;
        char *hint = hintsCallback(input, &color, &bold);
        if (hint) {
            int hintlen = strlen(hint);
            int hintmaxlen = l->cols - (plen + l->len);
            if (hintlen > hintmaxlen)
                hintlen = hintmaxlen;
            if (bold == 1 && color == -1)
                color = 37;
            if (color != -1 || bold != 0)
                snprintf(seq, 64, "\033[%d;%d;49m", bold, color);
            else
                seq[0] = '\0';
            abAppend(ab, seq, strlen(seq));
            abAppend(ab, hint, hintlen);
            if (color != -1 || bold != 0)
                abAppend(ab, "\033[0m", 4);
            /* Call the function to free the returned hint. */
            if (freeHintsCallback)
                freeHintsCallback(hint);
        }
    }
}

/* Single line low level line refresh.
 *
 * Rewrite the currently edited line accordingly to the buffer content,
 * cursor position, and number of columns of the terminal. */
static void refreshSingleLine(linenoiseState *l) {
    char seq[64];
    abuf *ab = &l->abuf;
    char *buf = l->buf;
    size_t len = l->len;
    size_t pos = l->pos;
    size_t cursor;
    int fd = l->ofd;
    int plen = l->prompt.len;
    int abstart;

    while ((plen + pos) >= l->cols) {
        buf++;
        len--;
        pos--;
    }
    while (plen + len > l->cols) {
        len--;
    }

    /* Cursor to left edge */
    abAppend(ab, "\r", 1);
    /* Write the prompt and the current buffer content */
    abAppend(ab, l->prompt.addr, l->prompt.len);
    abstart = ab->len;
    cursor = abAppendInputAndCompletion(ab, l);
    /* Show hints if any. */
    refreshShowHints(ab, makeString(ab->len - abstart, ab->addr + abstart), l);
    /* Erase to right */
    abAppend(ab, "\x1b[0K", 4);
    /* Move cursor to original position. */
    cursor -= l->pos - pos;
    snprintf(seq, 64, "\r\x1b[%dC", (int)(cursor + plen));
    abAppend(ab, seq, strlen(seq));
    if (write(fd, ab->addr, ab->len) == -1) {
    } /* Can't recover from write error. */
    ab->len = 0;
}

/* Multi line low level line refresh.
 *
 * Rewrite the currently edited line accordingly to the buffer content,
 * cursor position, and number of columns of the terminal. */
static void refreshMultiLine(linenoiseState *l) {
    char seq[64];
    abuf *ab = &l->abuf;
    size_t cursor; /* effective cursor position due to completion */
    int plen = l->prompt.len;
    int rows = (plen + l->len + l->cols - 1) / l->cols; /* rows used by current buf. */
    int rpos = (plen + l->oldpos + l->cols) / l->cols;  /* cursor relative row. */
    int rpos2;                                          /* rpos after refresh. */
    int col;                                            /* colum position, zero-based. */
    int old_rows = l->maxrows;
    int fd = l->ofd, j;
    int abstart; /* start of currently shown input inside ab */

    /* Update maxrows if needed. */
    if (rows > (int)l->maxrows)
        l->maxrows = rows;

    /* First step: clear all the lines used before. To do so start by
     * going to the last row. */
    if (old_rows - rpos > 0) {
        lndebug("go down %d", old_rows - rpos);
        snprintf(seq, 64, "\x1b[%dB", old_rows - rpos);
        abAppend(ab, seq, strlen(seq));
    }

    /* Now for every row clear it, go up. */
    for (j = 0; j < old_rows - 1; j++) {
        lndebug("clear+up");
        abAppend(ab, "\r\x1b[0K\x1b[1A", 9);
    }

    /* Clean the top line. */
    lndebug("clear");
    abAppend(ab, "\r\x1b[0K", 5);

    /* Write the prompt, current buffer content and current completion */
    abAppend(ab, l->prompt.addr, l->prompt.len);
    abstart = ab->len;
    cursor = abAppendInputAndCompletion(ab, l);

    /* Show hints if any. */
    refreshShowHints(ab, makeString(ab->len - abstart, ab->addr + abstart), l);

    /* If we are at the very end of the screen with our prompt, we need to
     * emit a newline and move the prompt to the first column. */
    if (cursor && cursor == l->len && (cursor + plen) % l->cols == 0) {
        lndebug("<newline>");
        abAppend(ab, "\r\n", 2);
        rows++;
        if (rows > (int)l->maxrows)
            l->maxrows = rows;
    }

    /* Move cursor to correct position. */
    rpos2 = (plen + cursor + l->cols) / l->cols; /* current cursor relative row. */
    lndebug("rpos2 %d", rpos2);

    /* Go up till we reach the expected positon. */
    if (rows - rpos2 > 0) {
        lndebug("go-up %d", rows - rpos2);
        snprintf(seq, 64, "\x1b[%dA", rows - rpos2);
        abAppend(ab, seq, strlen(seq));
    }

    /* Set column. */
    col = (plen + (int)cursor) % (int)l->cols;
    lndebug("set col %d", 1 + col);
    abAppend(ab, "\r", 1);
    if (col) {
        snprintf(seq, 64, "\x1b[%dC", col);
        abAppend(ab, seq, strlen(seq));
    }

    lndebug("\n");
    l->oldpos = l->pos;

    if (write(fd, ab->addr, ab->len) == -1) {
    } /* Can't recover from write error. */
    ab->len = 0;
}

/* Calls the two low level functions refreshSingleLine() or
 * refreshMultiLine() according to the selected mode. */
static void refreshLine(linenoiseState *l) {
    if (mlmode)
        refreshMultiLine(l);
    else
        refreshSingleLine(l);
}

/* Insert the character 'c' at cursor current position.
 *
 * On error writing to the terminal -1 is returned, otherwise 0. */
static int editInsert(linenoiseState *l, char c) {
    /* leave space for ENTER */
    if (l->len + 1 < l->buflen) {
        if (l->len == l->pos) {
            l->buf[l->pos] = c;
            l->pos++;
            l->len++;
            l->buf[l->len] = '\0';
            if ((!mlmode && l->prompt.len + l->len < l->cols && !hintsCallback)) {
                /* Avoid a full update of the line in the
                 * trivial case. */
                if (write(l->ofd, &c, 1) == -1)
                    return -1;
            } else {
                refreshLine(l);
            }
        } else {
            memmove(l->buf + l->pos + 1, l->buf + l->pos, l->len - l->pos);
            l->buf[l->pos] = c;
            l->len++;
            l->pos++;
            l->buf[l->len] = '\0';
            refreshLine(l);
        }
    }
    return 0;
}

/* Move cursor on the left. */
static void moveLeft(linenoiseState *l) {
    if (l->pos > 0) {
        l->pos--;
        refreshLine(l);
    }
}

/* Move cursor on the right. */
static void moveRight(linenoiseState *l) {
    if (l->pos != l->len) {
        l->pos++;
        refreshLine(l);
    }
}

/* Move cursor to the start of the line. */
static void moveHome(linenoiseState *l) {
    if (l->pos != 0) {
        l->pos = 0;
        refreshLine(l);
    }
}

/* Move cursor to the end of the line. */
static void moveEnd(linenoiseState *l) {
    if (l->pos != l->len) {
        l->pos = l->len;
        refreshLine(l);
    }
}

/* return non-zero if ch is alphanumeric i.e.
 * an uppercase letter A...Z
 * or a lower case letter a..z
 * or a decimal digit 0...9
 * or is part of an UTF-8 sequence
 */
static int isAlphaOrDigit(char ch) {
    return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9') ||
#if CHAR_MIN < 0
           ch < 0;
#else
           ch >= 128;
#endif
}

/* Move cursor to beginning of previous word. */
static void movePrevWord(linenoiseState *l) {
    if (l->pos != 0) {
        while (l->pos > 0 && !isAlphaOrDigit(l->buf[l->pos - 1]))
            l->pos--;
        while (l->pos > 0 && isAlphaOrDigit(l->buf[l->pos - 1]))
            l->pos--;
        refreshLine(l);
    }
}

/* Move cursor to beginning of next word. */
static void moveNextWord(linenoiseState *l) {
    if (l->pos < l->len) {
        while (l->pos < l->len && !isAlphaOrDigit(l->buf[l->pos]))
            l->pos++;
        while (l->pos < l->len && isAlphaOrDigit(l->buf[l->pos]))
            l->pos++;
        refreshLine(l);
    }
}

/* Substitute the currently edited line with the next or previous history
 * entry as specified by 'dir'. */
#define LINENOISE_HISTORY_NEXT 0
#define LINENOISE_HISTORY_PREV 1
void editHistoryNext(linenoiseState *l, int dir) {
    if (history_len > 1) {
        /* Update the current history entry before to
         * overwrite it with the next one. */
        free(history[history_len - 1 - l->history_index]);
        history[history_len - 1 - l->history_index] = strdup(l->buf);
        /* Show the new entry */
        l->history_index += (dir == LINENOISE_HISTORY_PREV) ? 1 : -1;
        if (l->history_index < 0) {
            l->history_index = 0;
            return;
        } else if (l->history_index >= history_len) {
            l->history_index = history_len - 1;
            return;
        }
        strncpy(l->buf, history[history_len - 1 - l->history_index], l->buflen);
        l->buf[l->buflen - 1] = '\0';
        l->len = l->pos = strlen(l->buf);
        refreshLine(l);
    }
}

/* Delete the character at the right of the cursor without altering the cursor
 * position. Basically this is what happens with the "Delete" keyboard key. */
void editDelete(linenoiseState *l) {
    if (l->len > 0 && l->pos < l->len) {
        memmove(l->buf + l->pos, l->buf + l->pos + 1, l->len - l->pos - 1);
        l->len--;
        l->buf[l->len] = '\0';
        refreshLine(l);
    }
}

/* Backspace implementation. */
void editBackspace(linenoiseState *l) {
    if (l->pos > 0 && l->len > 0) {
        memmove(l->buf + l->pos - 1, l->buf + l->pos, l->len - l->pos);
        l->pos--;
        l->len--;
        l->buf[l->len] = '\0';
        refreshLine(l);
    }
}

/* Delete the next word, maintaining the cursor at the start of the
 * current word. */
void editDeleteNextWord(linenoiseState *l) {
    size_t pos = l->pos, len = l->len;
    size_t n = 0;
    while (pos + n < len && !isAlphaOrDigit(l->buf[pos + n]))
        n++;
    while (pos + n < len && isAlphaOrDigit(l->buf[pos + n]))
        n++;
    if (n != 0) {
        memmove(l->buf + pos, l->buf + pos + n, len - pos + 1);
        l->len -= n;
        refreshLine(l);
    }
}

/* Delete the previous word, maintaining the cursor at the start of the
 * current word. */
void editDeletePrevWord(linenoiseState *l) {
    size_t pos = l->pos;
    size_t n = 0;

    while (pos > n && !isAlphaOrDigit(l->buf[pos - n - 1]))
        n++;
    while (pos > n && isAlphaOrDigit(l->buf[pos - n - 1]))
        n++;
    if (n != 0) {
        memmove(l->buf + pos - n, l->buf + pos, l->len - pos + 1);
        l->len -= n;
        l->pos -= n;
        refreshLine(l);
    }
}

/* This function is the core of the line editing capability of linenoise.
 * It expects 'fd' to be already in "raw mode" so that every key pressed
 * will be returned ASAP to read().
 *
 * The resulting string is put into 'buf' when the user type enter, or
 * when ctrl+d is typed.
 *
 * The function returns the length of the current buffer. */
static int linenoiseEdit(int stdin_fd, int stdout_fd, char *buf, size_t buflen,
                         const char *prompt) {
    linenoiseState l;
    int ret;

    if (buflen == 0) {
        return 0;
    }
    /* Populate the linenoise state that we pass to functions implementing
     * specific editing functionalities. */
    l.ifd = stdin_fd;
    l.ofd = stdout_fd;
    l.buf = buf;
    l.buflen = buflen;
    l.prompt.addr = prompt;
    l.prompt.len = strlen(prompt);
    l.abuf.cap = l.abuf.len = 0;
    l.abuf.addr = NULL;
    l.oldpos = l.pos = 0;
    l.len = 0;
    l.stem.len = 0;
    l.stem.addr = NULL;
    l.completion.len = 0;
    l.completion.addr = NULL;
    l.cols = getColumns(stdin_fd, stdout_fd);
    l.maxrows = 0;
    l.history_index = 0;

    /* Buffer starts empty. */
    l.buf[0] = '\0';
    l.buflen--; /* Make sure there is always space for the nulterm */

    /* The latest history entry is always our current buffer, that
     * initially is just an empty string. */
    linenoiseHistoryAdd("");

    if (write(l.ofd, prompt, l.prompt.len) == -1) {
        return -1;
    }
    for (;;) {
        int nread;
        char seq[3];
        char c;

        nread = read(l.ifd, &c, 1);
        if (nread <= 0) {
            ret = l.len;
            goto out;
        }

        /* Only autocomplete when the callback is set. It returns < 0 when
         * there was an error reading from fd. Otherwise it will return the
         * character that should be handled next. */
        if (c == TAB && completionCallback != NULL) {
            int n = completeLine(&l);
            /* Return on errors */
            if (n < 0) {
                ret = l.len;
                goto out;
            }
            /* Read next character when 0 */
            if (n == 0)
                continue;
            c = (char)n;
        }

        switch (c) {
        case CTRL_A: /* Ctrl+a, go to the start of the line */
            moveHome(&l);
            break;
        case CTRL_B: /* ctrl-b */
            moveLeft(&l);
            break;
        case CTRL_C: /* ctrl-c */
            errno = EAGAIN;
            ret = -1;
            goto out;
        case CTRL_D: /* ctrl-d, remove char at right of cursor, or if the
                        line is empty, act as end-of-file. */
            if (l.len > 0) {
                editDelete(&l);
            } else {
                history_len--;
                free(history[history_len]);
                errno = 0;
                ret = -1; /* EOF */
                goto out;
            }
            break;
        case CTRL_E: /* ctrl+e, go to the end of the line */
            moveEnd(&l);
            break;
        case CTRL_F: /* ctrl-f */
            moveRight(&l);
            break;
        case CTRL_H:    /* ctrl-h */
        case BACKSPACE: /* backspace */
        case CTRL_BACK: /* backspace */
            editBackspace(&l);
            break;
        case CTRL_J:
        case ENTER: /* enter */
            history_len--;
            free(history[history_len]);
            if (mlmode)
                moveEnd(&l);
            if (hintsCallback) {
                /* Force a refresh without hints to leave the previous
                 * line as the user typed it after a newline. */
                linenoiseHintsCallback *hc = hintsCallback;
                hintsCallback = NULL;
                refreshLine(&l);
                hintsCallback = hc;
            }
            ret = l.len;
            goto out;
        case CTRL_K: /* Ctrl+k, delete from current to end of line. */
            buf[l.pos] = '\0';
            l.len = l.pos;
            refreshLine(&l);
            break;
        case CTRL_L: /* ctrl+l, clear screen */
            linenoiseClearScreen();
            refreshLine(&l);
            break;
        case CTRL_N: /* ctrl-n */
            editHistoryNext(&l, LINENOISE_HISTORY_NEXT);
            break;
        case CTRL_P: /* ctrl-p */
            editHistoryNext(&l, LINENOISE_HISTORY_PREV);
            break;
        case CTRL_T: /* ctrl-t, swaps current character with previous. */
            if (l.pos > 0 && l.pos < l.len) {
                int aux = buf[l.pos - 1];
                buf[l.pos - 1] = buf[l.pos];
                buf[l.pos] = aux;
                if (l.pos != l.len - 1)
                    l.pos++;
                refreshLine(&l);
            }
            break;
        case CTRL_U: /* Ctrl+u, delete the whole line. */
            buf[0] = '\0';
            l.pos = l.len = 0;
            refreshLine(&l);
            break;
        case CTRL_W: /* ctrl+w, delete previous word */
            editDeletePrevWord(&l);
            break;
        case ESC: /* escape sequence */
            /* Read the next two bytes representing the escape sequence.
             * Use two calls to handle slow terminals returning the two
             * chars at different times. */
            if (read(l.ifd, seq, 1) == -1) {
                break;
            }
            switch (seq[0]) {
            case BACKSPACE: /* Alt+backspace, delete previous word */
                editDeletePrevWord(&l);
                continue;
            case 'B':
            case 'b': /* Alt+B move to prev word */
                movePrevWord(&l);
                continue;
            case 'D':
            case 'd': /* Alt+D delete next word */
                editDeleteNextWord(&l);
                continue;
            case 'F':
            case 'f': /* Alt+F move to next word */
                moveNextWord(&l);
                continue;
            }
            if (read(l.ifd, seq + 1, 1) == -1) {
                break;
            }
            /* ESC [ sequences. */
            if (seq[0] == '[') {
                if (seq[1] >= '0' && seq[1] <= '9') {
                    /* Extended escape, read additional byte. */
                    if (read(l.ifd, seq + 2, 1) == -1)
                        break;
                    if (seq[2] == '~') {
                        switch (seq[1]) {
                        case '1': /* Home key. */
                            moveHome(&l);
                            break;
                        case '3': /* Delete key. */
                            editDelete(&l);
                            break;
                        case '4': /* End key. */
                            moveEnd(&l);
                            break;
                        }
                    }
                } else {
                    switch (seq[1]) {
                    case 'A': /* Up */
                        editHistoryNext(&l, LINENOISE_HISTORY_PREV);
                        break;
                    case 'B': /* Down */
                        editHistoryNext(&l, LINENOISE_HISTORY_NEXT);
                        break;
                    case 'C': /* Right */
                        moveRight(&l);
                        break;
                    case 'D': /* Left */
                        moveLeft(&l);
                        break;
                    case 'H': /* Home */
                        moveHome(&l);
                        break;
                    case 'F': /* End*/
                        moveEnd(&l);
                        break;
                    }
                }
            }

            /* ESC O sequences. */
            else if (seq[0] == 'O') {
                switch (seq[1]) {
                case 'H': /* Home */
                    moveHome(&l);
                    break;
                case 'F': /* End */
                    moveEnd(&l);
                    break;
                }
            }
            break;
        default:
#if CHAR_MIN < 0
            if (c >= 0 && c < ' ')
#else
            if (c < ' ')
#endif
            {
                c = ' ';
            }
            if (editInsert(&l, c)) {
                ret = -1;
                goto out;
            }
            break;
        }
    }
out:
    abFree(&l.abuf);
    return ret;
}

/* This special mode is used by linenoise in order to print scan codes
 * on screen for debugging / development purposes. It is implemented
 * by the linenoise_example program using the --keycodes option. */
void linenoisePrintKeyCodes(void) {
    char quit[4];

    printf("Linenoise key codes debugging mode.\n"
           "Press keys to see scan codes. Type 'quit' at any time to exit.\n");
    if (enableRawMode(STDIN_FILENO) == -1)
        return;
    memset(quit, ' ', 4);
    while (1) {
        char c;
        int nread;

        nread = read(STDIN_FILENO, &c, 1);
        if (nread <= 0)
            continue;
        memmove(quit, quit + 1, sizeof(quit) - 1); /* shift string to left. */
        quit[sizeof(quit) - 1] = c;                /* Insert current char on the right. */
        if (memcmp(quit, "quit", sizeof(quit)) == 0)
            break;

        printf("'%c' %02x (%d) (type quit to exit)\n", isprint(c) ? c : '?', (int)c, (int)c);
        printf("\r"); /* Go left edge manually, we are in raw mode. */
        fflush(stdout);
    }
    disableRawMode(STDIN_FILENO);
}

static int linenoiseFgets(char *buf, size_t buflen, const char *prompt) {
    if (prompt[0]) {
        fputs(prompt, stdout);
        fflush(stdout);
    }
    int ret;
    if (fgets(buf, buflen, stdin) == NULL) {
        ret = -1;
    } else if ((ret = strlen(buf)) == 0) {
        errno = 0;
        ret = -1;
    }
    return ret;
}

/* This function calls the line editing function linenoiseEdit() using
 * the STDIN file descriptor set in raw mode. */
static int linenoiseRaw(char *buf, size_t buflen, const char *prompt) {
    if (enableRawMode(STDIN_FILENO) == 0) {
        int count = linenoiseEdit(STDIN_FILENO, STDOUT_FILENO, buf, buflen, prompt);
        disableRawMode(STDIN_FILENO);
        return count;
    }
    return linenoiseFgets(buf, buflen, prompt);
}

/* The high level function that is the main API of the linenoise library.
 * This function checks if the terminal has basic capabilities, just checking
 * for a blacklist of stupid terminals, and later either calls the line
 * editing function or uses dummy fgets() so that you will be able to type
 * something even in the most desperate of the conditions. */
int linenoise(char *buf, size_t buflen, const char *prompt) {
    int tty;
    if (buflen == 0) {
        errno = EINVAL;
        return -1;
    }
    tty = isatty(STDIN_FILENO);
    if (!tty || !prompt) {
        prompt = "";
    }
    if (!tty || isUnsupportedTerm()) {
        return linenoiseFgets(buf, buflen, prompt);
    }
    return linenoiseRaw(buf, buflen, prompt);
}

/* ================================ History ================================= */

/* Free the history, but does not reset it. Only used when we have to
 * exit() to avoid memory leaks are reported by valgrind & co. */
static void freeHistory(void) {
    if (history) {
        int j;
        for (j = 0; j < history_len; j++)
            free(history[j]);
        free(history);
        history = NULL;
    }
}

/* At exit we'll try to fix the terminal to the initial conditions. */
static void linenoiseAtExit(void) {
    disableRawMode(STDIN_FILENO);
    freeHistory();
    linenoiseFreeCompletions(&completions);
}

/* This is the API call to add a new entry in the linenoise history.
 * It uses a fixed array of char pointers that are shifted (memmoved)
 * when the history max length is reached in order to remove the older
 * entry and make room for the new one, so it is not exactly suitable for huge
 * histories, but will work well for a few hundred of entries.
 *
 * Using a circular buffer is smarter, but a bit more complex to handle. */
int linenoiseHistoryAdd(const char *line) {
    char *linecopy;

    if (history_max_len == 0)
        return 0;

    /* Initialization on first call. */
    if (history == NULL) {
        history = malloc(sizeof(char *) * history_max_len);
        if (history == NULL)
            return 0;
        memset(history, 0, (sizeof(char *) * history_max_len));
    }

    /* Don't add duplicated lines. */
    if (history_len && !strcmp(history[history_len - 1], line))
        return 0;

    /* Add an heap allocated copy of the line in the history.
     * If we reached the max length, remove the older line. */
    linecopy = strdup(line);
    if (!linecopy)
        return 0;
    if (history_len == history_max_len) {
        free(history[0]);
        memmove(history, history + 1, sizeof(char *) * (history_max_len - 1));
        history_len--;
    }
    history[history_len] = linecopy;
    history_len++;
    return 1;
}

/* Set the maximum length for the history. This function can be called even
 * if there is already some history, the function will make sure to retain
 * just the latest 'len' elements if the new history length value is smaller
 * than the amount of items already inside the history. */
int linenoiseHistorySetMaxLen(int len) {
    char **new;

    if (len < 1)
        return 0;
    if (history) {
        int tocopy = history_len;

        new = malloc(sizeof(char *) * len);
        if (new == NULL)
            return 0;

        /* If we can't copy everything, free the elements we'll not use. */
        if (len < tocopy) {
            int j;

            for (j = 0; j < tocopy - len; j++)
                free(history[j]);
            tocopy = len;
        }
        memset(new, 0, sizeof(char *) * len);
        memcpy(new, history + (history_len - tocopy), sizeof(char *) * tocopy);
        free(history);
        history = new;
    }
    history_max_len = len;
    if (history_len > history_max_len)
        history_len = history_max_len;
    return 1;
}

/* Save the history in the specified file. On success 0 is returned
 * otherwise -1 is returned. */
int linenoiseHistorySave(const char *filename) {
    mode_t old_umask = umask(S_IXUSR | S_IRWXG | S_IRWXO);
    FILE *fp;
    int j;

    fp = fopen(filename, "w");
    umask(old_umask);
    if (fp == NULL)
        return -1;
    chmod(filename, S_IRUSR | S_IWUSR);
    for (j = 0; j < history_len; j++)
        fprintf(fp, "%s\n", history[j]);
    fclose(fp);
    return 0;
}

/* Load the history from the specified file. If the file does not exist
 * zero is returned and no operation is performed.
 *
 * If the file exists and the operation succeeded 0 is returned, otherwise
 * on error -1 is returned. */
int linenoiseHistoryLoad(const char *filename) {
    FILE *fp = fopen(filename, "r");
    char buf[LINENOISE_MAX_LINE];

    if (fp == NULL)
        return -1;

    while (fgets(buf, LINENOISE_MAX_LINE, fp) != NULL) {
        char *p;

        p = strchr(buf, '\r');
        if (!p)
            p = strchr(buf, '\n');
        if (p)
            *p = '\0';
        linenoiseHistoryAdd(buf);
    }
    fclose(fp);
    return 0;
}
