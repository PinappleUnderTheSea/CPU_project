`ifndef __HAZARD_SV
`define __HAZARD_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module hazard
    import common::*;
    import pipes::*;(
        input fetch_data_t dataF,
        input decode_data_t dataD,dataDN,
        input execute_data_t dataE,
        input memory_data_t dataM,
        output fetch_data_t dataFH,
        output decode_data_t dataDH,
        output execute_data_t dataEH,
        output memory_data_t dataMH,
        input logic clk,
        input logic reset,
        input logic branch
    );
    always_ff @(posedge clk) begin
        if(reset)begin
            dataFH<='0;
            dataDH<='0;
            dataEH<='0;
            dataMH<='0;
        end
        else begin
            dataMH<=(dataM.cc)?dataM:'0;
            dataEH<=(dataE.cc)?dataE:'0;
            dataDH<=(dataDN.cc||(dataD.cc&&~dataE.cc)||dataD.ctl.op==JAL||dataD.ctl.op==BEQ
                    ||dataE.pc==64'h8000_0000
                    ||dataM.pc==64'h8000_0000
                    ||dataMH.pc==64'h8000_0000
                    ||dataD.pc==64'h8000_0000)?dataD:dataDH;
            dataFH<=(dataD.ctl.op==JAL)?0:
                        (dataD.ctl.op==BEQ
                            &&dataD.cc=='1&&branch)?0:
                                (dataD.ctl.op==JALR
                                    &&dataD.cc=='1&&branch)?0:
                                    (dataD.cc)?dataF:dataFH;
        end
    end

endmodule
`endif