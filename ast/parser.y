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
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>

//the result of parsing
ast_program *final_program;

#define YYERROR_VERBOSE

%}

%union {
	char *name;
	uint32_t immediate;
	
	unsigned index;
	bool b;
	
	qpu_alu_op alu_op;
	ast_ldi_op ldi_op;
	ast_semaphore_op semaphore_op;
	qpu_signal signal_op;
	
	qpu_alu_cond alu_cond;
	qpu_branch_cond branch_cond;
	ast_pack_op pack_op;
	qpu_rotation rotation;
	ast_special_reg special_reg;
	
	ast_alu_reg alu_reg;
	ast_alu_output alu_output;
	ast_alu_input alu_input;
	
	ast_branch_dest branch_dest;
	
	ast_phi_src_list phi_src_list;
	ast_phi_src *phi_src;
	
	
	ast_instr *instr;
	ast_alu_instr *alu_instr;
	ast_branch_instr *branch_instr;
	ast_ldi_instr *ldi_instr;
	ast_signal_instr *signal_instr;
	ast_semaphore_instr *semaphore_instr;
	ast_phi_instr *phi_instr;
	
	ast_block *block;
	ast_program *prog;
}

%{

//Note: we have to put this after the %union so that YYLTYPE and yylloc are defined

void yyerror(const char *s, ...)
{
	va_list ap;
	va_start(ap, s);
	
	fprintf(stderr, "error: %d.%d-%d.%d: ", yylloc.first_line, yylloc.first_column,
			yylloc.last_line, yylloc.last_column);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}

void lyyerror(YYLTYPE location, char *s, ...) __attribute__ ((format (printf, 2, 3)));

void lyyerror(YYLTYPE location, char *s, ...)
{
	va_list ap;
	va_start(ap, s);
	
	fprintf(stderr, "error: %d.%d-%d.%d: ", location.first_line,
			location.first_column, location.last_line, location.last_column);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}

extern int yylex(); //to fix compiler warning about implicit declaration

%}

%token <name> NAME
%token <immediate> IMMEDIATE
%token <alu_op> ALU_OP
%token <ldi_op> LDI_OP
%token <semaphore_op> SEMAPHORE_OP
%token <signal_op> SIGNAL_OP
%token BRANCH_OP PHI_OP
%token <alu_cond> ALU_COND
%token <pack_op> PACK
%token <rotation> ROTATE
%token <index> ACCUM_REG
%token <special_reg> SPECIAL_REG
%token <branch_cond> BRANCH_COND
%token SETF

%type <alu_reg> alu_reg
%type <alu_output> alu_output
%type <alu_input> alu_input
%type <alu_cond> opt_alu_cond
%type <rotation> opt_rotate
%type <pack_op> opt_pack
%type <b> opt_setf

%type <branch_dest> branch_dest
%type <branch_cond> opt_branch_cond

%type <phi_src> phi_source
%type <phi_src_list> phi_source_list

%type <alu_instr> alu_instruction
%type <branch_instr> branch_instruction
%type <ldi_instr> ldi_instruction
%type <signal_instr> signal_instruction
%type <semaphore_instr> semaphore_instruction
%type <phi_instr> phi_instruction

%type <instr> instruction
%type <block> basic_block
%type <prog> program

%start final_program

%%

final_program:
	  program
	{ final_program = $1; }

program:
	  basic_block
	{
		$$ = calloc(1, sizeof(ast_program));
		$$->first_block = $$->last_block = $1;
	}
	| program basic_block
	{
		$1->last_block->next = $2;
		$1->last_block = $2;
		$$ = $1;
	}

basic_block:
	  NAME ':'
	{
		$$ = calloc(1, sizeof(ast_block));
		$$->label = $1;
	}
	| basic_block instruction
	{
		if ($1->first_instr == NULL)
			$1->first_instr = $1->last_instr = $2;
		else
		{
			$1->last_instr->next = $2;
			$1->last_instr = $2;
		}
		$$ = $1;
	}

instruction:
	  alu_instruction			{ $$ = &$1->base; }
	| ldi_instruction			{ $$ = &$1->base; }
	| semaphore_instruction		{ $$ = &$1->base; }
	| signal_instruction		{ $$ = &$1->base; }
	| branch_instruction		{ $$ = &$1->base; }
	| phi_instruction			{ $$ = &$1->base; }

alu_instruction:
	  ALU_OP opt_alu_cond opt_setf alu_output ',' alu_input
	{
		$$ = calloc(1, sizeof(ast_alu_instr));
		$$->base.type = qpu_instr_type_alu;
		$$->op = $1;
		$$->num_inputs = 1;
		$$->cond = $2;
		$$->set_flags = $3;
		$$->output = $4;
		$$->inputs[0] = $6;
		$$->location = @$;
	}
	| ALU_OP opt_alu_cond opt_setf alu_output ',' alu_input ',' alu_input
	{
		$$ = calloc(1, sizeof(ast_alu_instr));
		$$->base.type = qpu_instr_type_alu;
		$$->op = $1;
		$$->num_inputs = 2;
		$$->cond = $2;
		$$->set_flags = $3;
		$$->output = $4;
		$$->inputs[0] = $6;
		$$->inputs[1] = $8;
		$$->location = @$;
	}

opt_alu_cond:
	  /* empty */
	{ $$ = qpu_alu_cond_always; }
	| ALU_COND

opt_setf:
	  /* empty */
	{ $$ = false; }
	| SETF
	{ $$ = true; }

alu_output:
	  alu_reg opt_pack opt_rotate
	{
		$$.reg = $1;
		$$.pack = $2;
		$$.rotate = $3;
		$$.pack_location = @2;
	}

opt_rotate:
	  /* empty */
	{ $$ = qpu_rot0; }
	| ROTATE

alu_input:
	  alu_reg opt_pack
	{
		$$.is_immediate = false;
		$$.reg = $1;
		$$.pack = $2;
		$$.pack_location = @2;
	}
	| IMMEDIATE /* small immediates */
	{
		$$.is_immediate = true;
		$$.immediate = $1;
		$$.imm_location = @1;
	}

opt_pack:
	  /* empty */
	{ $$ = ast_pack_none; }
	| PACK

alu_reg:
	  ACCUM_REG
	{
		$$.type = ast_reg_type_acc;
		$$.reg.acc_index = $1;
		$$.location = @$;
	}
	| '%' NAME
	{
		$$.type = ast_reg_type_named;
		$$.reg.name = $2;
		$$.location = @$;
	}
	| SPECIAL_REG
	{
		$$.type = ast_reg_type_special;
		$$.reg.special_reg = $1;
		$$.location = @$;
	}
	| '-' /* nop */
	{
		$$.type = ast_reg_type_nop;
		$$.location = @$;
	}

ldi_instruction:
	  LDI_OP opt_alu_cond alu_reg ',' IMMEDIATE
	{
		$$ = calloc(1, sizeof(ast_ldi_instr));
		$$->base.type = qpu_instr_type_ldi;
		$$->op = $1;
		$$->cond = $2;
		$$->output = $3;
		$$->immediate = $5;
	}

semaphore_instruction:
	  SEMAPHORE_OP IMMEDIATE
	{
		$$ = calloc(1, sizeof(ast_semaphore_instr));
		$$->base.type = qpu_instr_type_semaphore;
		if ($2 > 15)
		{
			lyyerror(@2, "semaphore index must be an integer from 0 to 15, is %u", $2);
			YYABORT;
		}
		
		$$->index = $2;
	}

signal_instruction:
	  SIGNAL_OP
	{
		$$ = calloc(1, sizeof(ast_signal_instr));
		$$->base.type = qpu_instr_type_signal;
		$$->signal = $1;
	}

branch_instruction:
	  BRANCH_OP opt_branch_cond branch_dest
	{
		$$ = calloc(1, sizeof(ast_branch_instr));
		$$->base.type = qpu_instr_type_branch;
		$$->cond = $2;
		$$->dest_reg.type = ast_reg_type_nop;
		$$->dest = $3;
	}
	| BRANCH_OP opt_branch_cond alu_reg ',' branch_dest
	{
		$$ = calloc(1, sizeof(ast_branch_instr));
		$$->base.type = qpu_instr_type_branch;
		$$->cond = $2;
		$$->dest_reg = $3;
		$$->dest = $5;
	}

branch_dest:
	  NAME
	{
		$$.has_offset = false;
		$$.label = $1;
		$$.label_location = @1;
	}
	| NAME '+' alu_reg
	{
		$$.has_offset = true;
		$$.offset = $3;
		$$.label = $1;
		$$.label_location = @1;
	}

opt_branch_cond:
	  /* empty */
	{ $$ = qpu_branch_cond_always; }
	| '.' BRANCH_COND
	{ $$ = $2; }

phi_instruction:
	  PHI_OP '%' NAME ',' phi_source_list
	{
		$$ = calloc(1, sizeof(ast_phi_instr));
		$$->base.type = qpu_instr_type_phi;
		$$->dest_name = $3;
		$$->src_list = $5;
		$$->dest_location.first_line = @2.first_line;
		$$->dest_location.first_column = @2.first_column;
		$$->dest_location.last_line = @3.last_line;
		$$->dest_location.last_column = @3.last_column;
	}

phi_source_list:
	  phi_source
	{
		$$.first_src = $$.last_src = $1;
	}
	| phi_source_list ',' phi_source
	{
		$1.last_src->next = $3;
		$1.last_src = $3;
		$$ = $1;
	}

phi_source:
	  '%' NAME ':' NAME
	{
		$$ = calloc(1, sizeof(ast_phi_src));
		$$->reg_name = $2;
		$$->label = $4;
		$$->name_location = @2;
		$$->label_location = @4;
	}
