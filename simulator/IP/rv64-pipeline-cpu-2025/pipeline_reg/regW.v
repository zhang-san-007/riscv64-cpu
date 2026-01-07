`include "define.v"
module regW(
    input wire        clk,                    // 时钟信号
    input wire        rst,                    // 复位信号
    input wire        regW_bubble,            // 气泡信号，用于清空当前阶段
    input wire        regW_stall,             // 停滞信号，用于暂停当前阶段的更新
    //info
    input wire [12:0]       regM_i_opcode_info,
    input wire [5 :0]       regM_i_csrrw_info,
    input wire [6:0]        regM_i_system_info,

    //data
    input wire [63:0]       regM_i_alu_result,
    input wire [63:0]       memory_i_mem_rdata,
    input wire [63:0]       regM_i_pc,
    input wire [63:0]       regM_i_regdata2,
    input wire [63:0]       regM_i_csr_rdata,

    //reg
    input wire  [11:0]      regM_i_csr_id,
    input wire              regM_i_csr_wen,
    input wire  [4:0]       regM_i_reg_rd,
    input wire              regM_i_reg_wen,

    //commit
    input wire  [160:0]     regM_i_commit_info,
//-------------output---------------------
    //info
    output reg  [12:0]      regW_o_opcode_info,
    output reg  [5:0]       regW_o_csrrw_info,
    output reg  [6:0]       regW_o_system_info,
    //data
    output reg  [63:0]      regW_o_alu_result,
    output reg  [63:0]      regW_o_mem_rdata,
    output reg  [63:0]      regW_o_pc,
    output reg  [63:0]      regW_o_csr_rdata,
    output reg  [63:0]      regW_o_regdata2,

    //reg&csr
    output reg  [4:0]       regW_o_reg_rd,
    output reg              regW_o_reg_wen,
    output reg  [11:0]      regW_o_csr_id,
    output reg              regW_o_csr_wen,
    //commit
    output reg  [160:0]     regW_o_commit_info
);

    always @(posedge clk) begin
        if(rst || regW_bubble) begin
            regW_o_opcode_info  <= `nop_opcode_info;
            regW_o_csrrw_info   <=  `nop_csrrw_info;
            regW_o_system_info  <=  `nop_system_info;
            regW_o_alu_result   <=  `nop_alu_result;
            regW_o_mem_rdata    <=  `nop_mem_rdata;
            regW_o_pc           <=  `nop_pc;
            regW_o_csr_rdata    <=  `nop_csr_rdata;
            regW_o_regdata2     <=  `nop_regdata2;
            regW_o_reg_rd       <=  `nop_reg_rd;
            regW_o_reg_wen      <=  `nop_reg_wen;
            regW_o_csr_id       <=  `nop_csr_id;
            regW_o_csr_wen      <=  `nop_csr_wen;
            regW_o_commit_info  <=  `nop_commit_info;
        end 
        else if (regW_stall) begin
            // 如果存在停滞信号，则保持当前值不变
            // 这里不需要显式赋值，因为Verilog中未赋值的reg类型会保持原值
        end else begin
            regW_o_opcode_info  <=  regM_i_opcode_info;
            regW_o_csrrw_info   <=  regM_i_csrrw_info;
            regW_o_system_info  <=  regM_i_system_info;
            regW_o_alu_result   <=  regM_i_alu_result;
            regW_o_mem_rdata    <=  memory_i_mem_rdata;
            regW_o_pc           <=  regM_i_pc;
            regW_o_csr_rdata    <=  regM_i_csr_rdata;
            regW_o_regdata2     <=  regM_i_regdata2;
            regW_o_reg_rd       <=  regM_i_reg_rd;
            regW_o_reg_wen      <=  regM_i_reg_wen;
            regW_o_csr_id       <=  regM_i_csr_id;
            regW_o_csr_wen      <=  regM_i_csr_wen;
            regW_o_commit_info  <=  regM_i_commit_info;
        end
    end

endmodule