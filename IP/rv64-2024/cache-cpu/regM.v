module regM(
    input wire        clk,                    // 时钟信号
    input wire        rst,                    // 复位信号
    input wire        regM_bubble,            // 气泡信号，用于清空当前阶段
    input wire        regM_stall,             // 停滞信号，用于暂停当前阶段的更新

    input wire  [63:0]  regE_i_pc,            // 输入的程序计数器值

    input wire  [10:0]  regE_i_load_store_info,
    input wire  [11:0]  regE_i_opcode_info,
    input wire  [63:0]  regE_i_regdata2,
    input wire  [63:0]  execute_i_alu_result,

    input wire  [4:0]   regE_i_rd,
    input wire          regE_i_reg_wen,
    input wire  [160:0] execute_i_commit_info,

    output reg   [10:0] regM_o_load_store_info,
    output reg   [11:0] regM_o_opcode_info,

    output reg   [63:0] regM_o_regdata2,
    output reg   [63:0] regM_o_alu_result,

    output reg  [63:0]  regM_o_pc,            // 输出的程序计数器值
    output reg  [4:0]   regM_o_rd,
    output reg          regM_o_reg_wen,
    output reg  [160:0] regM_o_commit_info
);

    always @(posedge clk) begin
        if (rst || regM_bubble) begin
            // 在复位或气泡信号时，清零所有输出信号
            regM_o_load_store_info  <= 11'd0;
            regM_o_opcode_info      <= 12'd0;
            regM_o_regdata2         <= 64'd0;
            regM_o_alu_result       <= 64'd0;
            regM_o_rd               <= 5'd0;
            regM_o_reg_wen          <= 1'b0;
            regM_o_commit_info      <= 161'd0;
            regM_o_pc               <= 64'd0;  // 清零程序计数器
        end else if (regM_stall) begin
            // 在停滞信号时，保持当前值不变
            // Verilog中未赋值的reg类型会保持原值，因此这里不需要显式赋值
        end else begin
            // 正常情况下，将输入信号传递到输出信号
            regM_o_load_store_info  <= regE_i_load_store_info;
            regM_o_opcode_info      <= regE_i_opcode_info;
            regM_o_regdata2         <= regE_i_regdata2;
            regM_o_alu_result       <= execute_i_alu_result;
            regM_o_rd               <= regE_i_rd;
            regM_o_reg_wen          <= regE_i_reg_wen;
            regM_o_commit_info      <= execute_i_commit_info;
            regM_o_pc               <= regE_i_pc;  // 更新程序计数器
        end
    end

endmodule