`include "define.v"
module pc_select (
    input  wire [63:0] pc_select_i_seq_pc,
    input  wire [63:0] pc_select_i_alu_out,
    input  wire        decode_i_jump,

    output wire [63:0] pc_select_o_pc 
);
    
assign pc_select_o_pc = (decode_i_jump) ? pc_select_i_alu_out : pc_select_i_seq_pc;
endmodule