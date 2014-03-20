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

int yycolumn = 1;

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

fadd		{ return ALU_OP; }
fsub		{ return ALU_OP; }
fmin		{ return ALU_OP; }
fmax		{ return ALU_OP; }
fminabs		{ return ALU_OP; }
fmaxabs		{ return ALU_OP; }
ftoi		{ return ALU_OP; }
itof		{ return ALU_OP; }
add			{ return ALU_OP; }
sub			{ return ALU_OP; }
shr			{ return ALU_OP; }
asr			{ return ALU_OP; }
ror			{ return ALU_OP; }
shl			{ return ALU_OP; }
min			{ return ALU_OP; }
max			{ return ALU_OP; }
and			{ return ALU_OP; }
or			{ return ALU_OP; }
xor			{ return ALU_OP; }
not			{ return ALU_OP; }
clz			{ return ALU_OP; }
v8adds		{ return ALU_OP; }
v8subs		{ return ALU_OP; }

fmul		{ return ALU_OP; }
mul24		{ return ALU_OP; }
v8muld		{ return ALU_OP; }
v8min		{ return ALU_OP; }
v8max		{ return ALU_OP; }

never		{ return ALU_COND; }
zs			{ return ALU_COND; }
zc			{ return ALU_COND; }
ns			{ return ALU_COND; }
nc			{ return ALU_COND; }
cs			{ return ALU_COND; }
cc			{ return ALU_COND; }

16a			{ return PACK; } /* float32 <=> float32 */
16b			{ return PACK; }
16as		{ return PACK; } /* int32 <=> int32 */
16bs		{ return PACK; }
16au		{ return PACK; } /* uint32 <=> uint32 */
16bu		{ return PACK; }
8dr			{ return PACK; } /* color ([0, 255] <=> [0, 1]) */
8a			{ return PACK; }
8b			{ return PACK; }
8c			{ return PACK; }
8d			{ return PACK; }
8abcd		{ return PACK; }
8au			{ return PACK; } /* unsigned (take lowest 8 bits) */
8bu			{ return PACK; }
8cu			{ return PACK; }
8du			{ return PACK; }
8abcdu		{ return PACK; }
8as			{ return PACK; } /* saturate */
8bs			{ return PACK; }
8cs			{ return PACK; }
8ds			{ return PACK; }
8abcds		{ return PACK; }

r5rot		{ return ROTATE; }
rot1		{ return ROTATE; }
rot2		{ return ROTATE; }
rot3		{ return ROTATE; }
rot4		{ return ROTATE; }
rot5		{ return ROTATE; }
rot6		{ return ROTATE; }
rot7		{ return ROTATE; }
rot8		{ return ROTATE; }
rot9		{ return ROTATE; }
rot10		{ return ROTATE; }
rot11		{ return ROTATE; }
rot12		{ return ROTATE; }
rot13		{ return ROTATE; }
rot14		{ return ROTATE; }
rot15		{ return ROTATE; }

r0			{ return ACCUM_REG; }
r1			{ return ACCUM_REG; }
r2			{ return ACCUM_REG; }
r3			{ return ACCUM_REG; }
r4			{ return ACCUM_REG; }
r5			{ return ACCUM_REG; }

unif		{ return SPECIAL_REG; }
vary		{ return SPECIAL_REG; }
qpu_num		{ return SPECIAL_REG; }
elem_num	{ return SPECIAL_REG; }
x_coord		{ return SPECIAL_REG; }
y_coord		{ return SPECIAL_REG; }
ms_mask		{ return SPECIAL_REG; }
rev_flag	{ return SPECIAL_REG; }
vpm			{ return SPECIAL_REG; }
vr_busy		{ return SPECIAL_REG; } /* VPM read busy */
vw_busy		{ return SPECIAL_REG; } /* VPM write busy */
vr_wait		{ return SPECIAL_REG; }
vw_wait		{ return SPECIAL_REG; }
mutex_acq	{ return SPECIAL_REG; }

tmurs		{ return SPECIAL_REG; }
r5quad		{ return SPECIAL_REG; }
r5rep		{ return SPECIAL_REG; }
int			{ return SPECIAL_REG; }
unif_addr	{ return SPECIAL_REG; }
stencil		{ return SPECIAL_REG; }
tlbz		{ return SPECIAL_REG; }
tlbm		{ return SPECIAL_REG; }
tlbc		{ return SPECIAL_REG; }
tlba		{ return SPECIAL_REG; } /* ??? not in disassembler, but in docs */
vr_setup	{ return SPECIAL_REG; }
vw_setup	{ return SPECIAL_REG; }
vr_addr		{ return SPECIAL_REG; }
vw_addr		{ return SPECIAL_REG; }
mutex_rel	{ return SPECIAL_REG; }
rcp			{ return SPECIAL_REG; }
rsqrt		{ return SPECIAL_REG; }
exp			{ return SPECIAL_REG; }
log			{ return SPECIAL_REG; }
t0s			{ return SPECIAL_REG; }
t0t			{ return SPECIAL_REG; }
t0r			{ return SPECIAL_REG; }
t0b			{ return SPECIAL_REG; }
t1s			{ return SPECIAL_REG; }
t1t			{ return SPECIAL_REG; }
t1r			{ return SPECIAL_REG; }
t1b			{ return SPECIAL_REG; }

ldi			{ return LDI_OP; }
ldis		{ return LDI_OP; }
ldiu		{ return LDI_OP; }

sacq		{ return SEMAPHORE_OP; }
srel		{ return SEMAPHORE_OP; }

bkpt		{ return SIGNAL_OP; }
thrsw		{ return SIGNAL_OP; }
thrend		{ return SIGNAL_OP; }
sbwait		{ return SIGNAL_OP; }
sbdone		{ return SIGNAL_OP; }
lthrsw		{ return SIGNAL_OP; }
loadcv		{ return SIGNAL_OP; }
loadc		{ return SIGNAL_OP; }
ldcend		{ return SIGNAL_OP; }
ldtmul0		{ return SIGNAL_OP; }
ldtmul1		{ return SIGNAL_OP; }
loadam		{ return SIGNAL_OP; }

bra			{ return BRANCH_OP; }

allz		{ return BRANCH_COND; }
allnz		{ return BRANCH_COND; }
anyz		{ return BRANCH_COND; }
anynz		{ return BRANCH_COND; }
alln		{ return BRANCH_COND; }
allnn		{ return BRANCH_COND; }
anyn		{ return BRANCH_COND; }
anynn		{ return BRANCH_COND; }
allc		{ return BRANCH_COND; }
allnc		{ return BRANCH_COND; }
anyc		{ return BRANCH_COND; }
anync		{ return BRANCH_COND; }

phi			{ return PHI_OP; }

"-"?([1-9][0-9]*|0)("."[0-9]*)?([eE]"-"?[0-9]+)? {
	return IMMEDIATE;
}

"-"?0[0-9]* {
	return IMMEDIATE;
}

0x[0-9a-fA-F]+ {
	return IMMEDIATE;
}

[_a-zA-Z][_0-9a-zA-Z]* {
	return NAME;
}


