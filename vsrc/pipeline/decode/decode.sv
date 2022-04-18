`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`else

`endif
module decode
    import common::*;
    import pipes::*;(
    input fetch_data_t dataF,
    output decode_data_t dataD,
    output creg_addr_t ra1,ra2,
    input word_t rd1,rd2,
    input execute_data_t dataE,
    input memory_data_t dataM,dataMH

);
    control_t ctl;
    word_t dreq_data;
    u64 pc_out;
    logic wsw_cc1,wsw_cc2;
    decoder decoder(
        .raw_instr(dataF.raw_instr),
        .ctl(ctl),
        .dout(dataD.dout),
        .ra1,
        .ra2,
        .rd1,
        .rd2,
        .dreq_data,
        .pc(dataF.pc),
        .pc_out(pc_out),
        .wsw_cc1,
        .wsw_cc2
    );
    assign dataD.dst=dataF.raw_instr[11:7];
    assign dataD.ctl=ctl;
    assign dataD.srca = rd1;
    assign dataD.srcb = rd2;
    assign dataD.pc = dataF.pc;
    assign dataD.dreq_data=dreq_data;
    assign dataD.pc_out=(ctl.op==JALR)?pc_out+rd1:pc_out;
    assign dataD.cc=(((ra1!=dataE.dst&&ra1!=dataM.dst&&ra1!=dataMH.dst)||ra1=='0||wsw_cc1=='1)&&((ra2!=dataE.dst&&ra2!=dataM.dst&&ra2!=dataMH.dst)||ra2=='0||wsw_cc2=='1))?1:0;
endmodule
`endif