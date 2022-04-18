`ifndef __WRITEBACK_SV
`define __WRITEBAKE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
module writeback
    import common::*;
    import pipes::*;(
        input memory_data_t dataM,
        output writeback_data_t dataW,
        input dbus_resp_t dresp
    );
    assign dataW.pc=dataM.pc;
    assign dataW.dst=dataM.dst;
    assign dataW.ctl=dataM.ctl;
    assign dataW.cc=dataM.cc;
    assign dataW.go=(dataM.ctl.op!='0)?1:0;
    always_comb begin
        unique case(dataM.ctl.memory_valid)
            2'b00:begin
                dataW.write_result=dataM.alu_out;
            end
            default:begin
                dataW.write_result=dataM.m_read_data;
            end   
        endcase
    end



endmodule

`endif