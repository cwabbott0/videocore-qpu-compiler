/*
 * Copyright (C) 2014 Connor Abbott
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <getopt.h>
#include "ast/ast.h"

#define USAGE \
"videocore-qpu-compiler source.ir [-o output.c]\n" \
"options:\n" \
"\t--output (-o) - the output file.\n" \
"\t\tdefault: a.out\n" \
"\t--format (-f) - the format of the output file.\n" \
"\t\tc - output a C file with an array containing the binary.\n" \
"\t\tbin - output a binary file with the code.\n" \
"\t\tdefault: bin\n" \
"\t--coordinate-shader (-c) - also compile a coordinate shader.\n"

void usage(void)
{
	fprintf(stderr, USAGE);
	exit(1);
}

int main(int argc, char **argv) {
	bool output_c_file = false, coord_shader = false;
	char *outfile = NULL;
	
	static struct option long_options[] = {
		{"output",            required_argument, NULL, 'o' },
		{"format",            no_argument,       NULL, 'f' },
		{"coordinate-shader", no_argument,       NULL, 'c' },
		{0, 0, 0, 0}
	};
	
	while (true)
	{
		int option_index = 0;
		
		int c = getopt_long(argc, argv, "o:fc", long_options, &option_index);
		
		if (c == -1)
			break;
		
		switch (c)
		{
			case 'o':
				if (outfile)
				{
					fprintf(stderr, "Error: output file specified more than once.\n");
					usage();
				}
				
				outfile = optarg;
				break;
				
			case 'f':
				if (strcmp(optarg, "c") == 0)
					output_c_file = true;
				else if (strcmp(optarg, "bin") != 0)
				{
					fprintf(stderr, "Error: unknown output format %s.\n", optarg);
					usage();
				}
				
				break;
				
			case 'c':
				coord_shader = true;
				break;
				
			case '?':
				usage();
				break;
				
			default:
				assert(0);
		}
	}
	
	if (outfile == NULL)
		outfile = "a.out";
	
	if (optind == argc)
	{
		fprintf(stderr, "Error: no input specified\n");
		usage();
	}
	
	if (optind < argc - 1)
	{
		fprintf(stderr, "Error: more than one input specified\n");
		usage();
	}
	
	char *infile = argv[optind];
	
	FILE *fp = fopen(infile, "r");
	if (!fp)
	{
		fprintf(stderr, "Error: could not open input file %s\n", infile);
		usage();
	}
	
	if (!ast_parse(fp))
		return 1;
	
    return 0;
}
