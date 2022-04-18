`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`include "pipeline/execute/mux.sv"
`else

`endif
module execute
    import common::*;
    import pipes::*;(
        output execute_data_t dataE,
        input decode_data_t dataD
    );
    word_t alu_a;
    word_t alu_b;
    // decode_data_t dataD;
    // assign dataD=(dataD.cc)?dataD:'0;
    mux mux (
        .dout(dataD.dout),
        .sb(dataD.srcb),
        .mux_select(dataD.ctl.mux_select),
        .alu_b
    );

    mux muxa(
        .dout(dataD.srca),
        .sb(dataD.pc),
        .mux_select(dataD.ctl.mux_pc),
        .alu_b(alu_a)
    );
    
    alu alu (
        .a(alu_a),
        .b(alu_b),
        .c(dataE.alu_out),
        .alufunc(dataD.ctl.alufunc)
    );
    assign dataE.pc=dataD.pc;
    assign dataE.ctl=dataD.ctl;
    assign dataE.dreq_data = dataD.dreq_data;
    assign dataE.dout=dataD.dout;
    assign dataE.dst=dataD.dst;
    assign dataE.cc=dataD.cc;

endmodule





`endif