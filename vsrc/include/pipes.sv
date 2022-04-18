`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif


package pipes;
	import common::*;
/* Define instrucion decoding rules here */

// parameter F7_RI = 7'bxxxxxxx;
parameter WRITE=2'b01;
parameter READ =2'b10;
parameter NUL  =2'b00;

parameter F7_ADDI=7'b0010011;
parameter F3_ADDI=3'b000;
parameter F7_LUI =7'b0110111;
parameter F3_XORI=3'b100;
parameter F7_ADD =7'b0110011;
parameter F3_ORI =3'b110;
parameter F3_ANDI=3'b111;
parameter F7_SD  =7'b0100011;
parameter F3_SD  =3'b011;
parameter F7_LD  =7'b0000011;
parameter F7_AUIPC=7'b0010111;
parameter F07_ADD=7'b0000000;
parameter F07_SUB=7'b0100000;
parameter F7_BEQ =7'b1100011;
parameter F3_BEQ =3'b000;
parameter F7_JALR=7'b1100111;
parameter F3_JALR=3'b000;
parameter F7_JAL =7'b1101111;
parameter F3_SLL =3'b001;
parameter F3_SLT =3'b010;
parameter F3_STLU=3'b011 ;
/* Define pipeline structures here */


typedef enum logic [4:0] {
	ALU_ADD,ALU_XOR,ALU_OR,ALU_AND,ALU_IMM,ALU_SUB,ALU_SLL,ALU_SLT,ALU_SLTU
} alufunc_t;

typedef struct packed {
	u32 raw_instr;
	u64 pc;
} fetch_data_t;

typedef enum logic [5:0]{
	UNKNOWN, ADDI,LUI,XORI,ADD,SUB,ORI,ANDI,SD,LD,AUIPC,OR,AND,XOR,BEQ,JALR,JAL,SLL,SLT,SLTU
}decoded_op_t;

typedef struct packed{
   decoded_op_t op;
   alufunc_t alufunc;
   u1 regwrite;
   logic mux_select;
   u2 memory_valid;
   logic mux_pc;
   logic skip;
   logic pc_select;
}control_t;

typedef struct packed {
	word_t srca,srcb;
	control_t ctl;
	creg_addr_t dst;
	u64 pc;
	word_t dreq_data;
	word_t dout;
	u64 pc_out;
	logic cc;
} decode_data_t;

typedef struct packed {
	u64 pc;
	u64 alu_out;
	control_t ctl;
	word_t dreq_data;
	word_t dout;
	creg_addr_t dst;
	logic cc;
} execute_data_t;

typedef struct packed {
	u64 pc;
	word_t m_write_addr;//memory address
	word_t m_read_data;
	word_t alu_out;
	control_t ctl;
	creg_addr_t dst;
	logic cc;
} memory_data_t;

typedef struct packed {
	u64 pc;
	word_t write_result;
	creg_addr_t dst;
	control_t ctl;
	logic cc;
	logic go;
} writeback_data_t;

endpackage

`endif
