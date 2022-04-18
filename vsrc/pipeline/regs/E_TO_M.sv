`ifndef __E_TO_M_SV
`define __E_TO_M_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module E_TO_M
    import common::*;
    import pipes::*;(
        input execute_data_t dataE,
        output execute_data_t dataE1,
        input logic clk,reset
    );
    always_ff @(posedge clk)begin
        if(reset)
            dataE1<=0;
        else
            dataE1<=dataE;
    end
endmodule
`endif