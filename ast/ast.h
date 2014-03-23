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

#ifndef _AST_H_
#define _AST_H_

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include "ir/ir.h"

typedef enum {
	ast_special_reg_unif,
	ast_special_reg_vary,
	ast_special_reg_qpu_num,
	ast_special_reg_elem_num,
	ast_special_reg_x_coord,
	ast_special_reg_y_coord,
	ast_special_reg_ms_mask,
	ast_special_reg_rev_flag,
	ast_special_reg_vpm,
	ast_special_reg_vr_busy,
	ast_special_reg_vw_busy,
	ast_special_reg_vr_wait,
	ast_special_reg_vw_wait,
	ast_special_reg_mutex_acq,
	ast_special_reg_tmurs,
	ast_special_reg_r5quad,
	ast_special_reg_r5rep,
	ast_special_reg_host_int,
	ast_special_reg_unif_addr,
	ast_special_reg_stencil,
	ast_special_reg_tlbz,
	ast_special_reg_tlbm,
	ast_special_reg_tlbc,
	ast_special_reg_tlba,
	ast_special_reg_vr_setup,
	ast_special_reg_vw_setup,
	ast_special_reg_vr_addr,
	ast_special_reg_vw_addr,
	ast_special_reg_mutex_rel,
	ast_special_reg_rcp,
	ast_special_reg_rsqrt,
	ast_special_reg_exp,
	ast_special_reg_log,
	ast_special_reg_t0s,
	ast_special_reg_t0t,
	ast_special_reg_t0r,
	ast_special_reg_t0b,
	ast_special_reg_t1s,
	ast_special_reg_t1t,
	ast_special_reg_t1r,
	ast_special_reg_t1b,
} ast_special_reg;

typedef enum {
	ast_ldi_op_ldi,
	ast_ldi_op_ldis,
	ast_ldi_op_ldiu,
} ast_ldi_op;

typedef enum {
	ast_semaphore_op_sacq,
	ast_semaphore_op_srel,
} ast_semaphore_op;

typedef enum {
	ast_pack_none,
	ast_pack_16a,
	ast_pack_16b,
	ast_pack_16as,
	ast_pack_16bs,
	ast_pack_16au,
	ast_pack_16bu,
	ast_pack_8dr,
	ast_pack_8a,
	ast_pack_8b,
	ast_pack_8c,
	ast_pack_8d,
	ast_pack_8abcd,
	ast_pack_8au,
	ast_pack_8bu,
	ast_pack_8cu,
	ast_pack_8du,
	ast_pack_8abcdu,
	ast_pack_8as,
	ast_pack_8bs,
	ast_pack_8cs,
	ast_pack_8ds,
	ast_pack_8abcds,
} ast_pack_op;

typedef struct _ast_instr {
	qpu_instr_type type;
	struct _ast_instr *next;
} ast_instr;

// ALU instructions

typedef enum {
	ast_reg_type_acc,
	ast_reg_type_named,
	ast_reg_type_special,
	ast_reg_type_nop
} ast_reg_type;

typedef struct {
	ast_reg_type type;
	union {
		unsigned acc_index;
		char *name;
		ast_special_reg special_reg;
	} reg;
} ast_alu_reg;

typedef struct {
	bool is_immediate;
	uint32_t immediate;
	ast_alu_reg reg;
	ast_pack_op pack;
} ast_alu_input;

typedef struct {
	ast_alu_reg reg;
	ast_pack_op pack;
	qpu_rotation rotate;
} ast_alu_output;

typedef struct {
	ast_instr base;
	
	qpu_alu_op op;
	qpu_alu_cond cond;
	bool set_flags;
	
	ast_alu_output output;
	
	unsigned num_inputs;
	ast_alu_input inputs[2];
} ast_alu_instr;

//Branch Instructions

typedef struct {
	char *label;
	bool has_offset;
	ast_alu_reg offset;
} ast_branch_dest;

typedef struct {
	ast_instr base;
	
	qpu_branch_cond cond;
	ast_alu_reg dest_reg;
	ast_branch_dest dest;
} ast_branch_instr;

//LDI Instructions

typedef struct {
	ast_instr base;
	
	ast_ldi_op op;
	qpu_alu_cond cond;
	ast_alu_reg output;
	uint32_t immediate;
} ast_ldi_instr;

//Signal instructions

typedef struct {
	ast_instr base;
	
	qpu_signal signal;
} ast_signal_instr;

//Semaphore Instructions

typedef struct {
	ast_instr base;
	
	unsigned index;
} ast_semaphore_instr;

//Phi Instructions

typedef struct _ast_phi_src {
	char *reg_name, *label;
	struct _ast_phi_src *next;
} ast_phi_src;

typedef struct {
	ast_phi_src *first_src, *last_src;
} ast_phi_src_list;

typedef struct {
	ast_instr base;
	
	char *dest_name;
	ast_phi_src_list src_list;
} ast_phi_instr;

typedef struct _ast_block {
	struct _ast_block *next;
	ast_instr *first_instr, *last_instr;
	char *label;
} ast_block;

typedef struct {
	ast_block *first_block, *last_block;
} ast_program;

ast_program *ast_parse(FILE *fp);

void ast_program_delete(ast_program *prog);

#endif
