/* See LICENSE file for copyright and license details. */
#define _XOPEN_SOURCE 700

#include <sys/stat.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <regex.h>

typedef struct {
	const char *regex;
	const char *action;
} Pair;

#include "config.h"


int main(int argc, char *argv[])
{
	struct stat s;
	regex_t regex;
	size_t g, h, i;
	const char *act, *fileURI = "file://";
	char cmd[BUFSIZ + 32], sharg[BUFSIZ];

	/* we only take one argument */
	if (argc != 2) return EXIT_FAILURE;

	/* make arg shell-ready, strong quote, escape single quotes, and null terminate */
	sharg[0] = '\'';
	for (g = 0, h = 1; argv[1][g] && h < BUFSIZ - 6; g++, h++) {
		sharg[h] = argv[1][g];
		if (argv[1][g] == '\'') {
			sharg[++h] = '\\';
			sharg[++h] = '\'';
			sharg[++h] = '\'';
		}
	}
	sharg[h] = '\'';
	sharg[++h] = '\0';

	/* special case for directories and file:// URI */
	size_t len = strlen(fileURI);
	if (((!strncmp(argv[1], fileURI, len) && !lstat(((char *)argv[1]) + len, &s))
				|| !lstat(argv[1], &s)) && S_ISDIR(s.st_mode))
	{
		act = dircmd;
		goto run;
	}

	/* check regex and launch action if it matches argv[1] */
	for (i = 0; i < sizeof(pairs) / sizeof(*pairs); i++) {
		if (regcomp(&regex, pairs[i].regex, REG_EXTENDED|REG_NOSUB)) {
			fprintf(stderr, "invalid regex: %s\n", pairs[i].regex);
			break;
		}
		if (!regexec(&regex, argv[1], 0, NULL, 0)) {
			act = (char *)pairs[i].action;
			regfree(&regex);
			goto run;
		}
		regfree(&regex);
	}

	/* fall back to xdg-open */
	act = "xdg-open_ %s";
run:
	snprintf(cmd, sizeof(cmd), act, sharg); // NOLINT
	system(cmd);
	return EXIT_SUCCESS;
}
