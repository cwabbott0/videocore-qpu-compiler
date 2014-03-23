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

%{

#include "ast/ast.h"
#include "parser.h"
#include <stdint.h>

//this is to fix a compiler warning... normally, we would #define _POSIX_SOURCE
//and then #include <stdio.h> to get this declaration, but as it turns out, flex
//helpfully includes stdio before this code, meaning that we need to do this
//instead... strong work, flex developers!

int fileno(FILE *f);

//same thing, but with string.h

char *strdup(const char *s);

int yycolumn = 1;

bool were_lexer_errors;

void yyerror(char *s, ...);

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
	yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1; \
	yycolumn += yyleng;

%}

%option noyywrap
%option yylineno

%x comment

%%

[ \t]		/* whitespace */
\n			{ yycolumn = 1; }

"//"[^\n]*	/* C++ style comments */

"/*"					BEGIN(comment);
<comment>[^*\n]*		/* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*	/* eat up '*'s not followed by '/'s */
<comment>\n				{ yycolumn = 1; }
<comment>"*"+"/"        BEGIN(INITIAL);

","			{ return ','; }
"."			{ return '.'; }
"+"			{ return '+'; }
"%"			{ return '%'; }
"-"			{ return '-'; }
":"			{ return ':'; }

fadd		{ yylval.alu_op = qpu_alu_op_fadd; return ALU_OP; }
fsub		{ yylval.alu_op = qpu_alu_op_fsub; return ALU_OP; }
fmin		{ yylval.alu_op = qpu_alu_op_fmin; return ALU_OP; }
fmax		{ yylval.alu_op = qpu_alu_op_fmax; return ALU_OP; }
fminabs		{ yylval.alu_op = qpu_alu_op_fminabs; return ALU_OP; }
fmaxabs		{ yylval.alu_op = qpu_alu_op_fmaxabs; return ALU_OP; }
ftoi		{ yylval.alu_op = qpu_alu_op_ftoi; return ALU_OP; }
itof		{ yylval.alu_op = qpu_alu_op_itof; return ALU_OP; }
add			{ yylval.alu_op = qpu_alu_op_add; return ALU_OP; }
sub			{ yylval.alu_op = qpu_alu_op_sub; return ALU_OP; }
shr			{ yylval.alu_op = qpu_alu_op_shr; return ALU_OP; }
asr			{ yylval.alu_op = qpu_alu_op_asr; return ALU_OP; }
ror			{ yylval.alu_op = qpu_alu_op_ror; return ALU_OP; }
shl			{ yylval.alu_op = qpu_alu_op_shl; return ALU_OP; }
min			{ yylval.alu_op = qpu_alu_op_min; return ALU_OP; }
max			{ yylval.alu_op = qpu_alu_op_max; return ALU_OP; }
and			{ yylval.alu_op = qpu_alu_op_and; return ALU_OP; }
or			{ yylval.alu_op = qpu_alu_op_or; return ALU_OP; }
xor			{ yylval.alu_op = qpu_alu_op_xor; return ALU_OP; }
not			{ yylval.alu_op = qpu_alu_op_not; return ALU_OP; }
clz			{ yylval.alu_op = qpu_alu_op_clz; return ALU_OP; }
v8adds		{ yylval.alu_op = qpu_alu_op_v8adds; return ALU_OP; }
v8subs		{ yylval.alu_op = qpu_alu_op_v8subs; return ALU_OP; }

fmul		{ yylval.alu_op = qpu_alu_op_fmul; return ALU_OP; }
mul24		{ yylval.alu_op = qpu_alu_op_mul24; return ALU_OP; }
v8muld		{ yylval.alu_op = qpu_alu_op_v8muld; return ALU_OP; }
v8min		{ yylval.alu_op = qpu_alu_op_v8min; return ALU_OP; }
v8max		{ yylval.alu_op = qpu_alu_op_v8max; return ALU_OP; }

".never"	{ yylval.alu_cond = qpu_alu_cond_never; return ALU_COND; }
".zs"		{ yylval.alu_cond = qpu_alu_cond_zs; return ALU_COND; }
".zc"		{ yylval.alu_cond = qpu_alu_cond_zc; return ALU_COND; }
".ns"		{ yylval.alu_cond = qpu_alu_cond_ns; return ALU_COND; }
".nc"		{ yylval.alu_cond = qpu_alu_cond_nc; return ALU_COND; }
".cs"		{ yylval.alu_cond = qpu_alu_cond_cs; return ALU_COND; }
".cc"		{ yylval.alu_cond = qpu_alu_cond_cc; return ALU_COND; }

".16a"		{ yylval.pack_op = ast_pack_16a; return PACK; } /* float32 <=> float32 */
".16b"		{ yylval.pack_op = ast_pack_16b; return PACK; }
".16as"		{ yylval.pack_op = ast_pack_16as; return PACK; } /* int32 <=> int32 */
".16bs"		{ yylval.pack_op = ast_pack_16bs; return PACK; }
".16au"		{ yylval.pack_op = ast_pack_16au; return PACK; } /* uint32 <=> uint32 */
".16bu"		{ yylval.pack_op = ast_pack_16bu; return PACK; }
".8dr"		{ yylval.pack_op = ast_pack_8dr; return PACK; } /* color ([0, 255] <=> [0, 1]) */
".8a"		{ yylval.pack_op = ast_pack_8a; return PACK; }
".8b"		{ yylval.pack_op = ast_pack_8b; return PACK; }
".8c"		{ yylval.pack_op = ast_pack_8c; return PACK; }
".8d"		{ yylval.pack_op = ast_pack_8d; return PACK; }
".8abcd"	{ yylval.pack_op = ast_pack_8abcd; return PACK; }
".8au"		{ yylval.pack_op = ast_pack_8au; return PACK; } /* unsigned (take lowest 8 bits) */
".8bu"		{ yylval.pack_op = ast_pack_8bu; return PACK; }
".8cu"		{ yylval.pack_op = ast_pack_8cu; return PACK; }
".8du"		{ yylval.pack_op = ast_pack_8du; return PACK; }
".8abcdu"	{ yylval.pack_op = ast_pack_8abcdu; return PACK; }
".8as"		{ yylval.pack_op = ast_pack_8as; return PACK; } /* saturate */
".8bs"		{ yylval.pack_op = ast_pack_8bs; return PACK; }
".8cs"		{ yylval.pack_op = ast_pack_8cs; return PACK; }
".8ds"		{ yylval.pack_op = ast_pack_8ds; return PACK; }
".8abcds"	{ yylval.pack_op = ast_pack_8abcds; return PACK; }

".r5rot"	{ yylval.rotation = qpu_rot_r5; return ROTATE; }
".rot1"		{ yylval.rotation = qpu_rot1; return ROTATE; }
".rot2"		{ yylval.rotation = qpu_rot2; return ROTATE; }
".rot3"		{ yylval.rotation = qpu_rot3; return ROTATE; }
".rot4"		{ yylval.rotation = qpu_rot4; return ROTATE; }
".rot5"		{ yylval.rotation = qpu_rot5; return ROTATE; }
".rot6"		{ yylval.rotation = qpu_rot6; return ROTATE; }
".rot7"		{ yylval.rotation = qpu_rot7; return ROTATE; }
".rot8"		{ yylval.rotation = qpu_rot8; return ROTATE; }
".rot9"		{ yylval.rotation = qpu_rot9; return ROTATE; }
".rot10"	{ yylval.rotation = qpu_rot10; return ROTATE; }
".rot11"	{ yylval.rotation = qpu_rot11; return ROTATE; }
".rot12"	{ yylval.rotation = qpu_rot12; return ROTATE; }
".rot13"	{ yylval.rotation = qpu_rot13; return ROTATE; }
".rot14"	{ yylval.rotation = qpu_rot14; return ROTATE; }
".rot15"	{ yylval.rotation = qpu_rot15; return ROTATE; }

r0			{ yylval.index = 0; return ACCUM_REG; }
r1			{ yylval.index = 1; return ACCUM_REG; }
r2			{ yylval.index = 2; return ACCUM_REG; }
r3			{ yylval.index = 3; return ACCUM_REG; }
r4			{ yylval.index = 4; return ACCUM_REG; }
r5			{ yylval.index = 5; return ACCUM_REG; }

unif		{ yylval.special_reg = ast_special_reg_unif; return SPECIAL_REG; }
vary		{ yylval.special_reg = ast_special_reg_vary; return SPECIAL_REG; }
qpu_num		{ yylval.special_reg = ast_special_reg_qpu_num; return SPECIAL_REG; }
elem_num	{ yylval.special_reg = ast_special_reg_elem_num; return SPECIAL_REG; }
x_coord		{ yylval.special_reg = ast_special_reg_x_coord; return SPECIAL_REG; }
y_coord		{ yylval.special_reg = ast_special_reg_y_coord; return SPECIAL_REG; }
ms_mask		{ yylval.special_reg = ast_special_reg_ms_mask; return SPECIAL_REG; }
rev_flag	{ yylval.special_reg = ast_special_reg_rev_flag; return SPECIAL_REG; }
vpm			{ yylval.special_reg = ast_special_reg_vpm; return SPECIAL_REG; }
vr_busy		{ yylval.special_reg = ast_special_reg_vr_busy; return SPECIAL_REG; } /* VPM read busy */
vw_busy		{ yylval.special_reg = ast_special_reg_vw_busy; return SPECIAL_REG; } /* VPM write busy */
vr_wait		{ yylval.special_reg = ast_special_reg_vr_wait; return SPECIAL_REG; }
vw_wait		{ yylval.special_reg = ast_special_reg_vw_wait; return SPECIAL_REG; }
mutex_acq	{ yylval.special_reg = ast_special_reg_mutex_acq; return SPECIAL_REG; }

tmurs		{ yylval.special_reg = ast_special_reg_tmurs; return SPECIAL_REG; }
r5quad		{ yylval.special_reg = ast_special_reg_r5quad; return SPECIAL_REG; }
r5rep		{ yylval.special_reg = ast_special_reg_r5rep; return SPECIAL_REG; }
host_int	{ yylval.special_reg = ast_special_reg_host_int; return SPECIAL_REG; }
unif_addr	{ yylval.special_reg = ast_special_reg_unif_addr; return SPECIAL_REG; }
stencil		{ yylval.special_reg = ast_special_reg_stencil; return SPECIAL_REG; }
tlbz		{ yylval.special_reg = ast_special_reg_tlbz; return SPECIAL_REG; }
tlbm		{ yylval.special_reg = ast_special_reg_tlbm; return SPECIAL_REG; }
tlbc		{ yylval.special_reg = ast_special_reg_tlbc; return SPECIAL_REG; }
tlba		{ yylval.special_reg = ast_special_reg_tlba; return SPECIAL_REG; } /* ??? not in disassembler, but in docs */
vr_setup	{ yylval.special_reg = ast_special_reg_vr_setup; return SPECIAL_REG; }
vw_setup	{ yylval.special_reg = ast_special_reg_vw_setup; return SPECIAL_REG; }
vr_addr		{ yylval.special_reg = ast_special_reg_vr_addr; return SPECIAL_REG; }
vw_addr		{ yylval.special_reg = ast_special_reg_vw_addr; return SPECIAL_REG; }
mutex_rel	{ yylval.special_reg = ast_special_reg_mutex_rel; return SPECIAL_REG; }
rcp			{ yylval.special_reg = ast_special_reg_rcp; return SPECIAL_REG; }
rsqrt		{ yylval.special_reg = ast_special_reg_rsqrt; return SPECIAL_REG; }
exp			{ yylval.special_reg = ast_special_reg_exp; return SPECIAL_REG; }
log			{ yylval.special_reg = ast_special_reg_log; return SPECIAL_REG; }
t0s			{ yylval.special_reg = ast_special_reg_t0s; return SPECIAL_REG; }
t0t			{ yylval.special_reg = ast_special_reg_t0t; return SPECIAL_REG; }
t0r			{ yylval.special_reg = ast_special_reg_t0r; return SPECIAL_REG; }
t0b			{ yylval.special_reg = ast_special_reg_t0b; return SPECIAL_REG; }
t1s			{ yylval.special_reg = ast_special_reg_t1s; return SPECIAL_REG; }
t1t			{ yylval.special_reg = ast_special_reg_t1t; return SPECIAL_REG; }
t1r			{ yylval.special_reg = ast_special_reg_t1r; return SPECIAL_REG; }
t1b			{ yylval.special_reg = ast_special_reg_t1b; return SPECIAL_REG; }

ldi			{ yylval.ldi_op = ast_ldi_op_ldi; return LDI_OP; }
ldis		{ yylval.ldi_op = ast_ldi_op_ldis; return LDI_OP; }
ldiu		{ yylval.ldi_op = ast_ldi_op_ldiu; return LDI_OP; }

sacq		{ yylval.semaphore_op = ast_semaphore_op_sacq; return SEMAPHORE_OP; }
srel		{ yylval.semaphore_op = ast_semaphore_op_srel; return SEMAPHORE_OP; }

bkpt		{ yylval.signal_op = qpu_signal_bkpt; return SIGNAL_OP; }
thrsw		{ yylval.signal_op = qpu_signal_thrsw; return SIGNAL_OP; }
thrend		{ yylval.signal_op = qpu_signal_thrend; return SIGNAL_OP; }
sbwait		{ yylval.signal_op = qpu_signal_sbwait; return SIGNAL_OP; }
sbdone		{ yylval.signal_op = qpu_signal_sbdone; return SIGNAL_OP; }
lthrsw		{ yylval.signal_op = qpu_signal_lthrsw; return SIGNAL_OP; }
loadcv		{ yylval.signal_op = qpu_signal_loadcv; return SIGNAL_OP; }
loadc		{ yylval.signal_op = qpu_signal_loadc; return SIGNAL_OP; }
ldcend		{ yylval.signal_op = qpu_signal_ldcend; return SIGNAL_OP; }
ldtmul0		{ yylval.signal_op = qpu_signal_ldtmul0; return SIGNAL_OP; }
ldtmul1		{ yylval.signal_op = qpu_signal_ldtmul1; return SIGNAL_OP; }
loadam		{ yylval.signal_op = qpu_signal_loadam; return SIGNAL_OP; }

bra			{ return BRANCH_OP; }

allz		{ yylval.branch_cond = qpu_branch_cond_allz; return BRANCH_COND; }
allnz		{ yylval.branch_cond = qpu_branch_cond_allnz; return BRANCH_COND; }
anyz		{ yylval.branch_cond = qpu_branch_cond_anyz; return BRANCH_COND; }
anynz		{ yylval.branch_cond = qpu_branch_cond_anynz; return BRANCH_COND; }
alln		{ yylval.branch_cond = qpu_branch_cond_alln; return BRANCH_COND; }
allnn		{ yylval.branch_cond = qpu_branch_cond_allnn; return BRANCH_COND; }
anyn		{ yylval.branch_cond = qpu_branch_cond_anyn; return BRANCH_COND; }
anynn		{ yylval.branch_cond = qpu_branch_cond_anynn; return BRANCH_COND; }
allc		{ yylval.branch_cond = qpu_branch_cond_allc; return BRANCH_COND; }
allnc		{ yylval.branch_cond = qpu_branch_cond_allnc; return BRANCH_COND; }
anyc		{ yylval.branch_cond = qpu_branch_cond_anyc; return BRANCH_COND; }
anync		{ yylval.branch_cond = qpu_branch_cond_anync; return BRANCH_COND; }

phi			{ return PHI_OP; }

".setf"		{ return SETF; }

"-"?([1-9][0-9]*|0)"."[0-9]*([eE]"-"?[0-9]+)? {
	float imm = strtof(yytext, NULL);
	union { float f; uint32_t bits; } u;
	u.f = imm;
	yylval.immediate = u.bits;
	return IMMEDIATE;
}

"-"?[0-9]+ {
	long imm = strtol(yytext, NULL, 0);
	if (imm >= 0)
	{
		//assume unsigned, convert to uint32_t
		if (imm > UINT32_MAX)
		{
			yyerror("immediate too large for 32-bit unsigned integer");
			were_lexer_errors = true;
		}
		yylval.immediate = (uint32_t) imm;
	}
	else
	{
		//it's negative, bitcast to uint32_t (we assume our arch uses two's complement)
		if (imm < INT32_MIN)
		{
			yyerror("immediate too small for 32-bit signed integer");
			were_lexer_errors = true;
		}
		union { int32_t i; uint32_t bits; } u;
		u.i = (int32_t) imm;
		yylval.immediate = u.bits;
	}
	return IMMEDIATE;
}

0x[0-9a-fA-F]+ {
	long imm = strtol(yytext, NULL, 16);
	if (imm > UINT32_MAX)
	{
		yyerror("immediate too large for 32-bit unsigned integer");
		were_lexer_errors = true;
	}
	yylval.immediate = (uint32_t) imm;
	return IMMEDIATE;
}

[_a-zA-Z][_0-9a-zA-Z]* {
	yylval.name = strdup(yytext);
	return NAME;
}

. {
	yyerror("unknown character %c", *yytext);
	were_lexer_errors = true;
}
