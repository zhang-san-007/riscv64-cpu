`include "define.v"
module ctrl(
    input  wire          execute_i_need_jump,

    input  wire          regM_i_mem_ren,
    input  wire   [4:0]  decode_i_rs1,
    input  wire   [4:0]  decode_i_rs2,
    input  wire   [4:0]  regE_i_rd,

    output wire          ctrl_o_regD_stall,
    output wire          ctrl_o_regF_stall,

    output wire          ctrl_o_regD_flush,
    output wire          ctrl_o_regE_flush
);

wire load                   = regM_i_mem_ren;
wire decode_equal_rd        = (decode_i_rs1 == regE_i_rd) || (decode_i_rs2 == regE_i_rd);

assign ctrl_o_regF_stall    = (load && decode_equal_rd) ? 1'b1 : 1'b0;
assign ctrl_o_regD_stall    = (load && decode_equal_rd) ? 1'b1 : 1'b0;

//因为只有mem和regfile会影响整个状态，所以遇到错误的时候只需要在mem和regfile前面的寄存器冲刷流水线就行
//fetch->regD->decodce->regE->execute->regM->memory
assign ctrl_o_regD_flush    = execute_i_need_jump;
assign ctrl_o_regE_flush    = execute_i_need_jump || (decode_equal_rd&&load);

endmodule