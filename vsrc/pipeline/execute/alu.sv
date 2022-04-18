`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alu
	import common::*;
	import pipes::*;(
	input u64 a, b,
	input alufunc_t alufunc,
	output u64 c
);
	always_comb begin
		c = '0;
		unique case(alufunc)
			ALU_ADD: c = a + b;
			ALU_XOR: c = a ^ b;
			ALU_OR : c = a | b;
			ALU_AND: c = a & b;
			ALU_IMM: c = b;
			ALU_SUB: c = a - b;
			ALU_SLL: c = a << b;
			ALU_SLT: c = ($signed(a)<$signed(b)?)1'b1:1'b0;
			ALU_SLTU c = (a<b)?1b'1:1'b0;
			default: begin
				
			end
		endcase
	end
	
endmodule

`endif
