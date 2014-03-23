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
	qpu_instr_type_alu,
	qpu_instr_type_branch,
	qpu_instr_type_ldi,
	qpu_instr_type_signal,
	qpu_instr_type_semaphore,
	qpu_instr_type_phi
} qpu_instr_type;

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

typedef enum {
	qpu_signal_bkpt,
	qpu_signal_thrsw,
	qpu_signal_thrend,
	qpu_signal_sbwait,
	qpu_signal_sbdone,
	qpu_signal_lthrsw,
	qpu_signal_loadcv,
	qpu_signal_loadc,
	qpu_signal_ldcend,
	qpu_signal_ldtmul0,
	qpu_signal_ldtmul1,
	qpu_signal_loadam
} qpu_signal;

typedef enum {
	qpu_branch_cond_always,
	qpu_branch_cond_allz,
	qpu_branch_cond_allnz,
	qpu_branch_cond_anyz,
	qpu_branch_cond_anynz,
	qpu_branch_cond_alln,
	qpu_branch_cond_allnn,
	qpu_branch_cond_anyn,
	qpu_branch_cond_anynn,
	qpu_branch_cond_allc,
	qpu_branch_cond_allnc,
	qpu_branch_cond_anyc,
	qpu_branch_cond_anync
} qpu_branch_cond;

typedef enum {
	qpu_alu_cond_never,
	qpu_alu_cond_always,
	qpu_alu_cond_zs,
	qpu_alu_cond_zc,
	qpu_alu_cond_ns,
	qpu_alu_cond_nc,
	qpu_alu_cond_cs,
	qpu_alu_cond_cc
} qpu_alu_cond;

typedef enum {
	qpu_rot0,
	qpu_rot_r5,
	qpu_rot1,
	qpu_rot2,
	qpu_rot3,
	qpu_rot4,
	qpu_rot5,
	qpu_rot6,
	qpu_rot7,
	qpu_rot8,
	qpu_rot9,
	qpu_rot10,
	qpu_rot11,
	qpu_rot12,
	qpu_rot13,
	qpu_rot14,
	qpu_rot15,
} qpu_rotation;

#endif
