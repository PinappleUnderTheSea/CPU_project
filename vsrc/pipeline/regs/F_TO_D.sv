`ifndef __F_TO_D_SV
`define __F_TO_D_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module F_TO_D
    import common::*;
    import pipes::*;(
        input fetch_data_t dataF,
        output fetch_data_t dataF1,
        input logic clk,reset
    );
    always_ff @(posedge clk)begin
        if(reset)
            dataF1<=0;
        else 
            dataF1<=dataF;
    end
endmodule
`endif