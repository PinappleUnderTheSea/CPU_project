`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"

`else

`endif

module decoder
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    output control_t ctl,
    output word_t dout,
    output creg_addr_t ra1,ra2,
    input word_t rd1,rd2,
    output word_t dreq_data,
    input u64 pc,
    output u64 pc_out,
    output logic wsw_cc1,wsw_cc2
    );
    wire [6:0] f7 = raw_instr[6:0];
    wire [2:0] f3 = raw_instr[14:12];
    wire [6:0] f07=raw_instr[31:25];
    assign ra1=raw_instr[19:15];
    assign ra2=raw_instr[24:20];
    always_comb begin
           ctl = '0;
           //ra1='0;
           //ra2='0;
           dout='0;
           dreq_data='0;
           pc_out='0;
           wsw_cc1='0;
           wsw_cc2='0;
        unique case (f7)
 
            F7_ADDI:begin
            wsw_cc2='1;
                unique case (f3)
                    F3_ADDI:begin
                        ctl.op=ADDI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc=ALU_ADD;
                        ctl.mux_select=1'b0;
                        //ra1=raw_instr[19:15];
                        dout={{52{raw_instr[31]}},raw_instr[31:20]};
                    end

                    F3_XORI:begin
                        ctl.alufunc=ALU_XOR;
                        ctl.mux_select=1'b0;
                        ctl.op=XORI;
                        ctl.regwrite=1'b1;
                        dout={{52{raw_instr[31]}},raw_instr[31:20]};
                        //ra1=raw_instr[19:15];
                    end

                    F3_ORI:begin
                        ctl.alufunc=ALU_OR;
                        ctl.op=ORI;
                        ctl.regwrite=1'b1;
                        ctl.mux_select=1'b0;
                        dout={{52{raw_instr[31]}},raw_instr[31:20]};
                        //ra1=raw_instr[19:15];
                    end

                    F3_ANDI:begin
                        ctl.alufunc=ALU_AND;
                        ctl.op=ANDI;
                        ctl.regwrite=1'b1;
                        ctl.mux_select=1'b0;
                        dout={{52{raw_instr[31]}},raw_instr[31:20]};
                        //ra1 = raw_instr[19:15];
                    end
                default :begin
                    end
                endcase
            end
            F7_LUI:begin
                wsw_cc1='1;
                wsw_cc2='1;
                ctl.op = LUI;
                ctl.regwrite = 1'b1;
                ctl.mux_select=1'b0;
                ctl.alufunc=ALU_IMM;
                dout={{32{raw_instr[31]}},raw_instr[31:12],{12{1'b0}}};             
            end
            F7_ADD:begin
                unique case(f3)
                    F3_ADDI:begin
                        ctl.op=ADD;
                        ctl.regwrite=1'b1;
                        ctl.mux_select=1'b1;
                        unique case(f07)
                            F07_ADD: ctl.alufunc=ALU_ADD;
                            F07_SUB:begin 
                                ctl.alufunc=ALU_SUB;
                                ctl.op=SUB;
                            end
                            default:begin
                            end
                        endcase
                        //ra1=raw_instr[19:15];
                        //ra2=raw_instr[24:20];
                    end
                    F3_ORI:begin
                        ctl.op=OR;
                        ctl.regwrite=1'b1;
                        ctl.alufunc=ALU_OR;
                        ctl.mux_select=1'b1;
                        //ra1=raw_instr[19:15];
                        //ra2=raw_instr[24:20];
                    end

                    F3_ANDI:begin
                        ctl.op=AND;
                        ctl.regwrite=1'b1;
                        ctl.alufunc=ALU_AND;
                        ctl.mux_select=1'b1;
                    end

                    F3_XORI:begin
                        ctl.op=XOR;
                        ctl.regwrite=1'b1;
                        ctl.alufunc=ALU_XOR;
                        ctl.mux_select=1'b1;
                    end
                    F3_SLL:begin
                        ctl.regwrite=1'b1;
                        ctl.mux_select=1'b1;
                        unique case(f07)
                            F07_ADD:begin
                                ctl.alufunc=SLL;
                                ctl.op=SLL;
                            end
                            default:begin
                            end
                        endcase                        
                    end
                    F3_SLT:begin
                        unique case(f07)
                            F07_ADD:begin
                                ctl.op=SLT;
                                ctl.regwrite=1'b1;
                                ctl.mux_select=1'b1;
                                ctl.alufunc=ALU_SLT;
                            end
                            default:begin
                            end
                        endcase
                    end
                    F3_STLU:begin
                        unique case(f07)
                            F07_ADD:begin
                                ctl.op=SLTU;
                                ctl.regwrite=1'b1;
                                ctl.mux_select=1'b1;
                                ctl.alufunc=ALU_SLTU;
                            end
                            default:begin
                            end
                        endcase
                    end
                    default:begin

                    end
                endcase

            end
            F7_SD:begin
                unique case(f3)
                    F3_SD:begin
                        ctl.op=SD;
                        ctl.regwrite=1'b0;
                        ctl.alufunc=ALU_ADD;
                        ctl.mux_select=1'b0;
                        dout={{52{raw_instr[31]}},raw_instr[31:25],raw_instr[11:7]};
                        //ra1=raw_instr[19:15];
                        //ra2=raw_instr[24:20];
                        ctl.memory_valid=WRITE;
                        dreq_data=rd2;
                    end
                    default:begin
                    end
                endcase
            end
            F7_LD:begin
                wsw_cc2='1;
                unique case(f3)
                    F3_SD:begin
                        ctl.op=LD;
                        ctl.regwrite=1'b1;
                        ctl.memory_valid=READ;
                        dout={{52{raw_instr[31]}},raw_instr[31:20]};
                        //ra1=raw_instr[19:15];
                        ctl.alufunc=ALU_ADD;
                        ctl.mux_select=1'b0;
                    end
                    default:begin
                    end
                endcase
            end
           
           F7_AUIPC:begin
                wsw_cc1='1;
                wsw_cc2='1;
                ctl.op=AUIPC;
                ctl.regwrite=1'b1;
                ctl.alufunc=ALU_ADD;
                ctl.mux_select=1'b0;
                dout={{32{raw_instr[31]}},raw_instr[31:12],{12{1'b0}}};  
                ctl.mux_pc=1'b1;           
           end
           F7_BEQ:begin
                unique case(f3)
                    F3_BEQ:begin
                        ctl.op=BEQ;
                        ctl.regwrite='0;
                        ctl.alufunc=ALU_IMM;
                        ctl.pc_select=1'b1;
                        pc_out={{51{raw_instr[31]}},raw_instr[31],raw_instr[7],raw_instr[30:25],raw_instr[11:8],1'b0};
                        dout='0;
                    end
                    default:begin
                    end
                endcase
           end

           F7_JAL:begin
                wsw_cc1='1;
                wsw_cc2='1;
                ctl.op=JAL;
                ctl.regwrite=1'b1;
                ctl.alufunc=ALU_IMM;
                ctl.pc_select=1'b1;
                pc_out={{43{raw_instr[31]}},raw_instr[31],raw_instr[19:12],raw_instr[20],raw_instr[30:21],1'b0};
                dout=pc+4;
           end
            F7_JALR:begin
                wsw_cc2='1;
                unique case(f3)
                    F3_JALR:begin
                        ctl.op=JALR;
                        ctl.regwrite=1'b1;
                        ctl.alufunc =ALU_IMM;
                        ctl.pc_select=1'b1;
                        pc_out={{52{raw_instr[31]}},raw_instr[31:20]};
                        dout=pc+4;
                    end 
                    default:begin
                    end
                endcase
           end     
            

            default: begin
            
            end
        endcase
    end


endmodule
`endif