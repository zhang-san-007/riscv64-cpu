`include "define.v"
module regE(
    input  wire         clk,
    input  wire         rst,
    input  wire         pipeline_flush,    // 新增：流水线冲刷信号
    input  wire [13:0]  decode_i_opcode_info,
    input  wire [5:0]   decode_i_branch_info,
    input  wire [10:0]  decode_i_load_store_info,
    input  wire [27:0]  decode_i_alu_info,
    input  wire [5:0]   decode_i_csrrw_info,
    input  wire [6:0]   decode_i_system_info,
    input  wire [19:0]  decode_i_amo_info,
    input  wire [63:0]  regD_i_pc,
    input  wire [63:0]  decode_i_csr_rdata1,
    input  wire [63:0]  decode_i_csr_rdata2,
    input  wire [63:0]  decode_i_regdata1,
    input  wire [63:0]  decode_i_regdata2,
    input  wire [63:0]  decode_i_imm,
    input  wire [11:0]  decode_i_csr_wid,
    input  wire         decode_i_csr_wen,
    input  wire [4:0]   decode_i_reg_rd,
    input  wire         decode_i_reg_wen,
    input  wire [160:0] regD_i_commit_info,
    input  wire         regD_o_valid,
    output wire         regE_o_allowin,
    output wire         regE_o_valid,
    input  wire         regM_allowin,
    output reg  [13:0]  regE_o_opcode_info,
    output reg  [5:0]   regE_o_branch_info,
    output reg  [10:0]  regE_o_load_store_info,
    output reg  [27:0]  regE_o_alu_info,
    output reg  [5:0]   regE_o_csrrw_info,
    output reg  [6:0]   regE_o_system_info,
    output reg  [19:0]  regE_o_amo_info,
    output reg  [63:0]  regE_o_pc,
    output reg  [63:0]  regE_o_csr_rdata1,
    output reg  [63:0]  regE_o_csr_rdata2,
    output reg  [63:0]  regE_o_regdata1,
    output reg  [63:0]  regE_o_regdata2,
    output reg  [63:0]  regE_o_imm,
    output reg  [11:0]  regE_o_csr_wid,
    output reg          regE_o_csr_wen,
    output reg  [4:0]   regE_o_reg_rd,
    output reg          regE_o_reg_wen,
    output reg  [160:0] regE_o_commit_info
);
    reg         regE_valid;
    wire        regE_ready_go;

    assign regE_ready_go  = 1'b1;
    assign regE_o_allowin = !regE_valid || (regE_ready_go && regM_allowin);
    assign regE_o_valid   = regE_valid && regE_ready_go;

    always @(posedge clk) begin
        if (rst || pipeline_flush) begin    // 发生跳转时，将当前准备执行的指令置为无效
            regE_valid <= 1'b0;
        end else if (regE_o_allowin) begin
            regE_valid <= regD_o_valid;
        end

        if (regD_o_valid && regE_o_allowin && !pipeline_flush) begin
            regE_o_opcode_info     <= decode_i_opcode_info;
            regE_o_branch_info     <= decode_i_branch_info;
            regE_o_load_store_info <= decode_i_load_store_info;
            regE_o_alu_info        <= decode_i_alu_info;
            regE_o_csrrw_info      <= decode_i_csrrw_info;
            regE_o_system_info     <= decode_i_system_info;
            regE_o_amo_info        <= decode_i_amo_info;
            regE_o_pc              <= regD_i_pc;
            regE_o_csr_rdata1      <= decode_i_csr_rdata1;
            regE_o_csr_rdata2      <= decode_i_csr_rdata2;
            regE_o_regdata1        <= decode_i_regdata1;
            regE_o_regdata2        <= decode_i_regdata2;
            regE_o_imm             <= decode_i_imm;
            regE_o_csr_wid         <= decode_i_csr_wid;
            regE_o_csr_wen         <= decode_i_csr_wen;
            regE_o_reg_rd          <= decode_i_reg_rd;
            regE_o_reg_wen         <= decode_i_reg_wen;
            regE_o_commit_info     <= regD_i_commit_info;
        end
    end

endmodule