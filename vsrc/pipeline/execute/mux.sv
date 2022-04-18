`ifndef __MUX_SV
`define __MUX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
module mux
    import common::*;
    import pipes::*;(
        input word_t dout,sb,
        output word_t alu_b,
        input logic mux_select
    );
    assign alu_b = (mux_select)? sb:dout;

endmodule
`endif