`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pcselect
    import common::*;
    import pipes::*;(
        input u64 pc,
        output u64 pc_nxt,
        input decode_data_t dataD,
        input execute_data_t dataE,
        input memory_data_t dataM,
        input writeback_data_t dataW,
        input logic cc_e,cc_m,cc_w,
        output logic branch
    );
        always_comb begin
            branch='0;
            if(dataD.cc==0
                &&~(dataE.pc==64'h8000_0000
                &&dataM.pc==64'h8000_0000
                &&dataW.pc==64'h8000_0000))
            begin
                pc_nxt=pc;
            end
            else begin
                unique case(dataD.ctl.op)
                        BEQ:begin
                            if( dataD.cc=='1)
                            begin
                                pc_nxt=pc-4;
                                if(dataD.srca==dataD.srcb)begin
                                    pc_nxt=pc+dataD.pc_out-4;
                                    branch='1;
                                end
                                else begin 
                                    pc_nxt=pc+4;
                                    branch='0;
                                end
                            end
                            else begin
                                pc_nxt=pc;
                            end

                        end
                        JAL:begin
                            pc_nxt=pc+dataD.pc_out-4;
                        end
                        JALR:begin
                            if(dataD.cc=='1)
                            begin
                                pc_nxt=(dataD.pc_out&~1);
                                branch='1;
                            end
                            else
                                pc_nxt=pc;
                        end
                        default:begin
                            pc_nxt=pc+4;
                        end
                endcase
            end

        end

endmodule
`endif