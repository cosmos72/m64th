#include "linenoise.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

linenoiseString completion(linenoiseString input, linenoiseStrings *lc, void *unused) {
    (void)unused;
    if (input.len > 0 && input.addr[0] == 'h') {
        linenoiseString helloThere = {11, "hello there"};
        linenoiseString hello = {5, helloThere.addr};
        linenoiseAddCompletion(lc, hello);
        linenoiseAddCompletion(lc, helloThere);
    }
    input.len = 1;
    return input;
}

char *hints(const linenoiseString input, int *color, int *bold) {
    if (input.len == 5 && !strncasecmp(input.addr, "hello", 5)) {
        *color = 35;
        *bold = 0;
        return " World";
    }
    return NULL;
}

int main(int argc, char **argv) {
    enum { line_maxlen = 1024 };
    char line[line_maxlen];
    char *prgname = argv[0];
    int line_len;

    /* Parse options, with --multiline we enable multi line editing. */
    while (argc > 1) {
        argc--;
        argv++;
        if (!strcmp(*argv, "--multiline")) {
            linenoiseSetMultiLine(1);
            printf("Multi-line mode enabled.\n");
        } else if (!strcmp(*argv, "--keycodes")) {
            linenoisePrintKeyCodes();
            exit(0);
        } else {
            fprintf(stderr, "Usage: %s [--multiline] [--keycodes]\n", prgname);
            exit(1);
        }
    }

    /* Set the completion callback. This will be called every time the
     * user uses the <tab> key. */
    linenoiseSetCompletionCallback(completion, NULL);
    linenoiseSetHintsCallback(hints);

    /* Load history from file. The history file is just a plain text file
     * where entries are separated by newlines. */
    linenoiseHistoryLoad("history.txt"); /* Load the history at startup */

    /* Now this is the main loop of the typical linenoise-based application.
     * The call to linenoise() will block as long as the user types something
     * and presses enter.
     */
    while ((line_len = linenoise(line, line_maxlen, "hello> ")) > 0) {
        /* Do something with the string. */
        if (line[line_len - 1] == '\n') {
            line[--line_len] = '\0';
        }
        if (line[0] != '\0' && line[0] != '/') {
            printf("\necho: '%s'\n", line);
            linenoiseHistoryAdd(line);           /* Add to the history. */
            linenoiseHistorySave("history.txt"); /* Save the history on disk. */
        } else if (!strncmp(line, "/historylen", 11)) {
            /* The "/historylen" command will change the history len. */
            int len = atoi(line + 11);
            linenoiseHistorySetMaxLen(len);
        } else if (line[0] == '/') {
            printf("\nUnrecognized command: %s\n", line);
        }
    }
    putchar('\n');
    return 0;
}
