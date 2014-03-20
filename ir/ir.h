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

#ifndef _IR_H_
#define _IR_H_

typedef enum {
	qpu_alu_op_fadd,
	qpu_alu_op_fsub,
	qpu_alu_op_fmin,
	qpu_alu_op_fmax,
	qpu_alu_op_fminabs,
	qpu_alu_op_fmaxabs,
	qpu_alu_op_fmul,
	qpu_alu_op_ftoi,
	qpu_alu_op_itof,
	qpu_alu_op_add,
	qpu_alu_op_sub,
	qpu_alu_op_shr,
	qpu_alu_op_asr,
	qpu_alu_op_ror,
	qpu_alu_op_shl,
	qpu_alu_op_min,
	qpu_alu_op_max,
	qpu_alu_op_and,
	qpu_alu_op_or,
	qpu_alu_op_xor,
	qpu_alu_op_not,
	qpu_alu_op_clz,
	qpu_alu_op_mul24,
	qpu_alu_op_v8adds,
	qpu_alu_op_v8subs,
	qpu_alu_op_v8muld,
	qpu_alu_op_v8min,
	qpu_alu_op_v8max
} qpu_alu_op;

#endif
