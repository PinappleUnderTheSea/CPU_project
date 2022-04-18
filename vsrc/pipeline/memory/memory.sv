`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
module memory 
    import common::*;
    import pipes::*;(
        input execute_data_t dataE,
        output memory_data_t dataM,
        output dbus_req_t dreq,
        input dbus_resp_t dresp
    );
        assign dataM.pc=dataE.pc;
        assign dreq.addr=dataE.alu_out;
        assign dataM.alu_out=dataE.alu_out;
        assign dataM.dst=dataE.dst;
        assign dataM.cc=dataE.cc;
        assign dreq.valid='0;
        always_comb begin
            dataM.ctl.skip='0;
            dreq.strobe='1;
            dataM.m_write_addr='0;
            dreq.data='0;
            dataM.m_read_data='0;
            dataM.ctl=dataE.ctl;
            unique case(dataE.ctl.memory_valid)
                READ:begin
                    dataM.m_read_data=dresp.data;
                    dataM.ctl.skip=1'b1;
                    dreq.strobe='0;
                end
                WRITE:begin
                    dataM.m_write_addr=dataE.alu_out;
                    dataM.ctl.skip=1'b1;
                    dreq.data=dataE.dreq_data;
                    dreq.strobe='1;
                end
                default:begin

                end
            endcase
        end
endmodule


`endif