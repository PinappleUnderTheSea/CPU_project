`ifndef __D_TO_E_SV
`define __D_TO_E_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module D_TO_E
    import common::*;
    import pipes::*;(
        input decode_data_t dataD,
        output decode_data_t dataD1,
        input logic clk,reset
    );
    always_ff @(posedge clk)begin
        if(reset)
            dataD1<=0;
        else
            dataD1<=dataD;
    end
endmodule
`endif