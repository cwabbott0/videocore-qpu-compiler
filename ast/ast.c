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

#include "ast/ast.h"
#include <stdarg.h>


//lexer interface
extern FILE *yyin;

//parser interface
extern int yyparse();

bool ast_parse(FILE *fp)
{
	yyin = fp;
	if (yyparse() != 0)
		return false;
	
	//TODO
	
	return true;
}

void ast_error(YYLTYPE location, char *s, ...)
{
	va_list ap;
	va_start(ap, s);
	
	fprintf(stderr, "error: %d.%d-%d.%d: ", location.first_line,
			location.first_column, location.last_line, location.last_column);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}
