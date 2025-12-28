`include "define.v"
module regM(
    input wire clk,
    input wire rst,
    //execute阶段传来的信号
    input wire [63:0]   execute_i_valE,
    input wire [63:0]   execute_i_pre_pc,
    //regE寄存器直接传来的信号
    input wire [2:0]    regE_i_load_type,
    input wire          regE_i_mem_ren,
    input wire          regE_i_mem_wen,
    input wire [3:0]    regE_i_mem_wmask,
    input wire          regE_i_wb_reg_wen,
    input wire [4:0]    regE_i_wb_rd,
    input wire [1:0]    regE_i_wb_valD_sel,
    input wire [63:0]   regE_i_valB,
    //commit for simulator
    input wire  [31:0]  regE_i_instr,
    input wire  [63:0]  regE_i_pc,
    input wire          regE_i_commit,

    output reg [63:0]   regM_o_valE,
    output reg [63:0]   regM_o_valB,
    output reg [2:0]    regM_o_load_type,
    output reg          regM_o_mem_ren,
    output reg          regM_o_mem_wen,
    output reg [3:0]    regM_o_mem_wmask,
    output reg          regM_o_wb_reg_wen,
    output reg [4:0]    regM_o_wb_rd,
    output reg [1:0]    regM_o_wb_valD_sel,

    //commit for simulator
    output reg [31:0]   regM_o_instr,
    output reg [63:0]   regM_o_pc,
    output reg          regM_o_commit,
    output reg [63:0]   regM_o_pre_pc
);

always @(posedge clk) begin
    if(rst) begin
        regM_o_valE         <= 64'd0;
        regM_o_load_type    <= 3'b0;
        regM_o_mem_ren      <= 1'b0;
        regM_o_mem_wen      <= 1'b0;
        regM_o_mem_wmask    <= 4'b0;
        regM_o_wb_reg_wen   <= `reg_wen_no_w;
        regM_o_wb_rd        <= 5'd0;
        regM_o_wb_valD_sel  <= `wb_valD_sel_valE;
        regM_o_valB         <= 64'd0;
        //commit for simulator
        regM_o_pc           <= 64'd0;
        regM_o_commit       <= 1'd0;
        regM_o_pre_pc       <= 64'd0;
    end
    else begin
        regM_o_load_type    <= regE_i_load_type;
        regM_o_mem_ren      <= regE_i_mem_ren;
        regM_o_mem_wen      <= regE_i_mem_wen;
        regM_o_mem_wmask    <= regE_i_mem_wmask;
        regM_o_valE         <= execute_i_valE;
        regM_o_wb_reg_wen   <= regE_i_wb_reg_wen;
        regM_o_wb_rd        <= regE_i_wb_rd;
        regM_o_wb_valD_sel  <= regE_i_wb_valD_sel;
        regM_o_valB         <= regE_i_valB;

        //commit for simulator
        regM_o_instr        <= regE_i_instr;
        regM_o_pc           <= regE_i_pc;
        regM_o_pre_pc       <= execute_i_pre_pc;
        regM_o_commit       <= regE_i_commit;
    end
end

endmodule