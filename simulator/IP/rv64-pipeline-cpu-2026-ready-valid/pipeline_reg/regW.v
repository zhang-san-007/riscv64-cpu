`include "define.v"
module regW(
    input  wire         clk,
    input  wire         rst,
    input  wire [13:0]  regM_i_opcode_info,
    input  wire [5:0]   regM_i_csrrw_info,
    input  wire [6:0]   regM_i_system_info,
    input  wire [19:0]  regM_i_amo_info,
    input  wire [63:0]  regM_i_alu_result,
    input  wire [63:0]  memory_i_mem_rdata,
    input  wire [63:0]  regM_i_pc,
    input  wire [63:0]  regM_i_regdata2,
    input  wire [63:0]  regM_i_csr_rdata1,
    input  wire [11:0]  regM_i_csr_wid,
    input  wire         regM_i_csr_wen,
    input  wire [4:0]   regM_i_reg_rd,
    input  wire         regM_i_reg_wen,
    input  wire [160:0] regM_i_commit_info,
    input  wire         regM_o_valid,
    output wire         regW_o_allowin,    
    output wire         regW_o_valid,
    // 移除了 wb_ready
    output reg  [13:0]  regW_o_opcode_info,
    output reg  [5:0]   regW_o_csrrw_info,
    output reg  [6:0]   regW_o_system_info,
    output reg  [19:0]  regW_o_amo_info,
    output reg  [63:0]  regW_o_alu_result,
    output reg  [63:0]  regW_o_mem_rdata,
    output reg  [63:0]  regW_o_pc,
    output reg  [63:0]  regW_o_csr_rdata1,
    output reg  [63:0]  regW_o_regdata2,
    output reg  [4:0]   regW_o_reg_rd,
    output reg          regW_o_reg_wen,
    output reg  [11:0]  regW_o_csr_wid,
    output reg          regW_o_csr_wen,
    output reg  [160:0] regW_o_commit_info
);

    reg         regW_valid;
    wire        regW_ready_go;

    assign regW_ready_go  = 1'b1;
    // 修改：不再依赖 wb_ready，认为下游始终准备就绪
    assign regW_o_allowin = !regW_valid || regW_ready_go;
    assign regW_o_valid   =  regW_valid && regW_ready_go;

    always @(posedge clk) begin
        if (rst) begin
            regW_valid <= 1'b0;
        end else if (regW_o_allowin) begin
            regW_valid <= regM_o_valid;
        end
        if (regM_o_valid && regW_o_allowin) begin
            regW_o_opcode_info <= regM_i_opcode_info;
            regW_o_csrrw_info  <= regM_i_csrrw_info;
            regW_o_system_info <= regM_i_system_info;
            regW_o_amo_info    <= regM_i_amo_info;
            regW_o_alu_result  <= regM_i_alu_result;
            regW_o_mem_rdata   <= memory_i_mem_rdata;
            regW_o_pc          <= regM_i_pc;
            regW_o_csr_rdata1  <= regM_i_csr_rdata1;
            regW_o_regdata2    <= regM_i_regdata2;
            regW_o_reg_rd      <= regM_i_reg_rd;
            regW_o_reg_wen     <= regM_i_reg_wen;
            regW_o_csr_wid     <= regM_i_csr_wid;
            regW_o_csr_wen     <= regM_i_csr_wen;
            regW_o_commit_info <= regM_i_commit_info;
        end
    end

endmodule