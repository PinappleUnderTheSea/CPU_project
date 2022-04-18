`ifndef __CORE_SV
`define __CORE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "pipeline/regfile/regfile.sv"
`include "pipeline/decode/decode.sv"
`include "pipeline/fetch/fetch.sv"
`include "pipeline/fetch/pcselect.sv"
`include "pipeline/execute/execute.sv"
`include "pipeline/memory/memory.sv"
`include "pipeline/writeback/writeback.sv"
`include "pipeline/regs/F_TO_D.sv"
`include "pipeline/regs/D_TO_E.sv"
`include "pipeline/regs/E_TO_M.sv"
`include "pipeline/regs/M_TO_W.sv"
`include "pipeline/regs/hazard.sv"



`else

`endif

module core 
	import common::*;
	import pipes::*;(
	input logic clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp
);
	/* TODO: Add your pipeline here. */
	u64 pc,pc_nxt;
	// logic cc;
	always_ff @(posedge clk)begin
		if(reset)
			pc<=64'h8000_0000;
		else 
			pc <= pc_nxt;

	end
	assign ireq.addr = pc;

	u32 raw_instr;
	assign raw_instr = iresp.data;
	
	
	fetch_data_t dataF,dataFH;
	decode_data_t dataD,dataDH,dataDH1,dataDN;
	execute_data_t dataE,dataEH;
	memory_data_t dataM,dataMH;
	writeback_data_t dataW;

	creg_addr_t ra1,ra2;
	word_t rd1,rd2;
	word_t result;
	word_t dout;//imm out
	logic branch;
	
	 always_ff@(posedge clk)begin
		dataDN<=dataD;
	 end


	hazard hazard(
		.dataF,
		.dataFH,
		.dataD,
		.dataDH,
		.dataE,
		.dataEH,
		.dataM,
		.dataMH,
		.clk,
		.reset,
		.dataDN,
		.branch

	);

	fetch fetch (
		.dataF(dataF),
		.raw_instr(raw_instr),
		.pc
	);

	// F_TO_D f_to_d(
	// 	.dataF,
	// 	.dataF1,
	// 	.clk,
	// 	.reset
	// );

	decode decode(
		.dataF(dataFH),
		.dataD,
		.ra1,.ra2,.rd1,.rd2,
		.dataE,
		.dataM,
		.dataMH
	);

	pcselect pcselect(
		.pc(pc),
		.pc_nxt(pc_nxt),
		.dataD,
		.cc_e(dataE.cc),
		.cc_m(dataM.cc),
		.cc_w(dataW.cc),
		.dataE,
		.dataM,
		.dataW,
		.branch
	);
	
	// D_TO_E d_to_e(
	// 	.dataD,
	// 	.dataD1,
	// 	.clk,
	// 	.reset
	// );

	always_comb begin
		dataDH1=(dataDH.cc)?dataDH:'0;
	end

	execute execute(
		.dataD(dataDH1),
		.dataE
		
	);

	// E_TO_M e_to_m(
	// 	.dataE,
	// 	.dataE1,
	// 	.clk,
	// 	.reset
	// );

	memory memory(
		.dataE(dataEH),
		.dataM,
		.dreq,
		.dresp
	);

	// M_TO_W m_to_w(
	// 	.dataM,
	// 	.dataM1,
	// 	.clk,
	// 	.reset
	// );

	//assign dreq.addr=dataM.m_write_addr;
	writeback writeback(
		.dataM(dataMH),
		.dataW,
		.dresp
	);
	
	assign result=dataW.write_result;
	//assign result=rd1+{{44{raw_instr[31]}},raw_instr[31:12]};


	regfile regfile(
		.clk, .reset,
		.ra1,
		.ra2,
		.rd1,
		.rd2,
		.wvalid(dataW.ctl.regwrite),
		.wa(dataW.dst),
		.wd(result)
	);

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (~reset&&dataW.go),
		.pc                 (dataW.pc),
		.instr              (0),
		.skip               (dataW.ctl.skip),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataW.ctl.regwrite),
		.wdest              ({3'b0,dataW.dst}),
		.wdata              (result)
	);
	      
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);
	      
	DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);
	      
	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	      );
	      
	DifftestArchFpRegState DifftestArchFpRegState(
		.clock              (clk),
		.coreid             (0),
		.fpr_0              (0),
		.fpr_1              (0),
		.fpr_2              (0),
		.fpr_3              (0),
		.fpr_4              (0),
		.fpr_5              (0),
		.fpr_6              (0),
		.fpr_7              (0),
		.fpr_8              (0),
		.fpr_9              (0),
		.fpr_10             (0),
		.fpr_11             (0),
		.fpr_12             (0),
		.fpr_13             (0),
		.fpr_14             (0),
		.fpr_15             (0),
		.fpr_16             (0),
		.fpr_17             (0),
		.fpr_18             (0),
		.fpr_19             (0),
		.fpr_20             (0),
		.fpr_21             (0),
		.fpr_22             (0),
		.fpr_23             (0),
		.fpr_24             (0),
		.fpr_25             (0),
		.fpr_26             (0),
		.fpr_27             (0),
		.fpr_28             (0),
		.fpr_29             (0),
		.fpr_30             (0),
		.fpr_31             (0)
	);
	
`endif
endmodule
`endif