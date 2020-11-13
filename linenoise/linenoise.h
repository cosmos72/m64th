/* linenoise.h -- VERSION 1.0
 *
 * Guerrilla line editing library against the idea that a line editing lib
 * needs to be 20,000 lines of C code.
 *
 * See linenoise.c for more information.
 *
 * ------------------------------------------------------------------------
 *
 * Copyright (c) 2010-2014, Salvatore Sanfilippo <antirez at gmail dot com>
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
 */

#ifndef __LINENOISE_H
#define __LINENOISE_H

#include <stddef.h> /* size_t */

#ifdef __cplusplus
extern "C" {
#endif

typedef struct linenoiseString {
    size_t len;
    const char *addr;
} linenoiseString;

typedef struct linenoiseStrings {
    size_t size;
    size_t capacity;
    linenoiseString *vec;
} linenoiseStrings;

/**
 * main entry point: read up to buflen bytes from standard input with line-editing,
 * and store them into buf. Shows prompt at start of input line.
 * Returns number of bytes actually read, or < 0 on error.
 */
int linenoise(char *buf, size_t buflen, const char *prompt);
int linenoiseHistoryAdd(const char *line);
int linenoiseHistorySetMaxLen(int len);
int linenoiseHistorySave(const char *filename);
int linenoiseHistoryLoad(const char *filename);
void linenoiseClearScreen(void);
void linenoiseSetMultiLine(int ml);
void linenoisePrintKeyCodes(void);

/**
 * signature of programmer-provided completion callback. it receives as arguments:
 * currentInput: text received from standard input, up to the cursor
 * completions:  a buffer where to add possible completions
 * userData:     a opaque pointer to programmer-configured data:
 *               the additional value passed to linenoiseSetCompletionCallback()
 *
 * a callback is expected to call linenoiseAddCompletion(completions, ...)
 * filling possible completions, then return the substring of currentInput
 * that was used as stem for all completions.
 */
typedef linenoiseString(linenoiseCompletionCallback)(linenoiseString currentInput,
                                                     linenoiseStrings *completions, void *userData);
void linenoiseSetCompletionCallback(linenoiseCompletionCallback *fn, void *userData);
/* does not make a copy of toAdd */
void linenoiseAddCompletion(linenoiseStrings *completions, linenoiseString toAdd);
/*
 * deallocate internal linenoiseString[] array.
 * does not deallocate each linenoiseString,
 * does not deallocate linenoiseString*
*/
void linenoiseFreeCompletions(linenoiseStrings *completions);

typedef char *(linenoiseHintsCallback)(linenoiseString currentInput, int *color, int *bold);
typedef void(linenoiseFreeHintsCallback)(void *);
void linenoiseSetHintsCallback(linenoiseHintsCallback *fn);
void linenoiseSetFreeHintsCallback(linenoiseFreeHintsCallback *fn);

/* Try to get the number of columns in the current terminal, or assume 80
 * if it fails. */
int linenoiseGetTerminalColumns(void);

#ifdef __cplusplus
}
#endif

#endif /* __LINENOISE_H */
