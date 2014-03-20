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
 
%locations
 
 %{

#include "ast/ast.h"
#include <stdio.h>
#include <stdarg.h>

void yyerror(const char *s, ...)
{
	va_list ap;
	va_start(ap, s);
	
	fprintf(stderr, "error: %d.%d-%d.%d: ", yylloc.first_line, yylloc.first_column,
			yylloc.last_line, yylloc.last_column);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}

#define YYERROR_VERBOSE

%}

%token NAME
%token IMMEDIATE
%token ALU_OP LDI_OP SEMAPHORE_OP SIGNAL_OP BRANCH_OP PHI_OP
%token ALU_COND PACK ROTATE
%token ACCUM_REG
%token SPECIAL_REG
%token BRANCH_COND

%start program

%%

program:
	  basic_block
	| program basic_block

basic_block:
	  NAME ':'
	| basic_block instruction

instruction:
	  alu_instruction
	| ldi_instruction
	| semaphore_instruction
	| signal_instruction
	| branch_instruction
	| phi_instruction

alu_instruction:
	  ALU_OP opt_alu_cond alu_output ',' alu_input
	| ALU_OP opt_alu_cond alu_output ',' alu_input ',' alu_input

opt_alu_cond:
	  /* empty */
	| '.' ALU_COND

alu_output:
	  alu_output_reg opt_pack opt_rotate

opt_rotate:
	  /* empty */
	| ROTATE

alu_output_reg:
	  alu_reg
	| SPECIAL_REG

alu_input:
	  alu_reg opt_pack
	| IMMEDIATE /* small immediates */

opt_pack:
	  /* empty */
	| '.' PACK

alu_input_reg:
	  alu_reg
	| SPECIAL_REG

alu_reg:
	  ACCUM_REG
	| '%' NAME
	| '-' /* nop */

ldi_instruction:
	  LDI_OP opt_alu_cond alu_output_reg ',' IMMEDIATE

semaphore_instruction:
	  SEMAPHORE_OP IMMEDIATE

signal_instruction:
	  SIGNAL_OP

branch_instruction:
	  BRANCH_OP opt_branch_cond branch_dest
	| BRANCH_OP opt_branch_cond alu_output_reg ',' branch_dest

branch_dest:
	  NAME
	| NAME '+' alu_input_reg

opt_branch_cond:
	  /* empty */
	| '.' BRANCH_COND

phi_instruction:
	  PHI_OP phi_dest ',' phi_source_list

phi_source_list:
	  phi_source
	| phi_source_list ',' phi_source

phi_source:
	  '%' NAME ':' NAME

phi_dest:
	  '%' NAME
	  