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
#include <stdlib.h>
#include <assert.h>
#include <stdarg.h>


//lexer interface
extern FILE *yyin;
extern bool were_lexer_errors;
int yylex_destroy(void);

//parser interface
int yyparse();
extern ast_program *final_program;

ast_program *ast_parse(FILE *fp)
{
	yyin = fp;
	were_lexer_errors = false;
	if (yyparse() != 0 || were_lexer_errors)
	{
		yylex_destroy();
		return NULL;
	}
	
	yylex_destroy();
	return final_program;
}

static void phi_src_list_delete(ast_phi_src_list list)
{
	ast_phi_src *src = list.first_src;
	while (src != NULL)
	{
		free(src->reg_name);
		free(src->label);
		ast_phi_src *temp = src->next;
		free(src);
		src = temp;
	}
}

static void reg_delete(ast_alu_reg reg)
{
	if (reg.type == ast_reg_type_named)
		free(reg.reg.name);
}

static void instr_delete(ast_instr *instr)
{
	switch (instr->type)
	{
		case qpu_instr_type_alu:
		{
			ast_alu_instr *alu_instr = (ast_alu_instr *)instr;
			for (unsigned i = 0; i < alu_instr->num_inputs; i++)
				if (!alu_instr->inputs[i].is_immediate)
					reg_delete(alu_instr->inputs[i].reg);
			reg_delete(alu_instr->output.reg);
			free(alu_instr);
			break;
		}
		
		case qpu_instr_type_branch:
		{
			ast_branch_instr *branch_instr = (ast_branch_instr *)instr;
			if (branch_instr->dest.has_offset)
				reg_delete(branch_instr->dest.offset);
			free(branch_instr->dest.label);
			reg_delete(branch_instr->dest_reg);
			free(branch_instr);
			break;
		}
		
		case qpu_instr_type_ldi:
		{
			ast_ldi_instr *ldi_instr = (ast_ldi_instr *)instr;
			reg_delete(ldi_instr->output);
			free(ldi_instr);
			break;
		}
		
		case qpu_instr_type_phi:
		{
			ast_phi_instr *phi_instr = (ast_phi_instr *)instr;
			phi_src_list_delete(phi_instr->src_list);
			free(phi_instr->dest_name);
			break;
		}
		
		case qpu_instr_type_semaphore:
		{
			ast_semaphore_instr *sema_instr = (ast_semaphore_instr *)instr;
			free(sema_instr);
			break;
		}
		
		case qpu_instr_type_signal:
		{
			ast_signal_instr *signal_instr = (ast_signal_instr *)instr;
			free(signal_instr);
			break;
		}
		
		default:
			assert(0);
	}
}

static void block_delete(ast_block *block)
{
	ast_instr *instr = block->first_instr;
	while (instr != NULL)
	{
		ast_instr *temp = instr->next;
		instr_delete(instr);
		instr = temp;
	}
	
	free(block->label);
	free(block);
}

void ast_program_delete(ast_program *prog)
{
	ast_block *block = prog->first_block;
	while (block != NULL)
	{
		ast_block *temp = block->next;
		block_delete(block);
		block = temp;
	}
	
	free(prog);
}
