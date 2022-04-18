`ifndef __M_TO_W_SV
`define __M_TO_W_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module M_TO_W
    import common::*;
    import pipes::*;(
        input memory_data_t dataM,
        output memory_data_t dataM1,
        input logic clk,reset
    );
    always_ff @(posedge clk)begin
        if(reset)
            dataM1<=0;
        else
            dataM1<=dataM;
    end
endmodule
`endif