module regE(
    input wire         clk,                    // 时钟信号
    input wire         rst,                    // 复位信号
    input wire         regE_bubble,            // Bubble 信号
    input wire         regE_stall,             // Stall 信号

    // 来自 regD 的提交信号

    // 来自 Decode 阶段的数据
    input wire  [63:0] decode_i_imm,           // 立即数
    input wire  [63:0] decode_i_regdata1,      // 寄存器数据1
    input wire  [63:0] decode_i_regdata2,      // 寄存器数据2
    input wire  [63:0] regD_i_pc,              // 当前指令的PC

    input wire  [4:0]  decode_i_rd,            // 目标寄存器地址
    input wire         decode_i_reg_wen,       // 寄存器写使能

    input wire   [27:0] decode_i_alu_info,          // ALU操作信息
    input wire   [10:0] decode_i_load_store_info,   // 访存操作信息
    input wire   [11:0] decode_i_opcode_info,       // 操作码信息
    input wire   [5:0]  decode_i_branch_info,       // 分支信息


    input wire  [160:0] regD_i_commit_info,


    output reg [63:0]  regE_o_regdata1,        // 寄存器数据1
    output reg [63:0]  regE_o_regdata2,        // 寄存器数据2
    output reg [63:0]  regE_o_imm,             // 立即数
    output reg [63:0]  regE_o_pc,              // 当前指令的PC

    output reg [4:0]   regE_o_rd,              // 目标寄存器地址
    output reg         regE_o_reg_wen,         // 寄存器写使能

    output reg  [27:0] regE_o_alu_info,        // ALU操作信息
    output reg  [10:0] regE_o_load_store_info, // 访存操作信息
    output reg  [11:0] regE_o_opcode_info,     // 操作码信息
    output reg  [5:0]  regE_o_branch_info,     // 分支信息
    output reg  [160:0] regE_o_commit_info

);

// 时序逻辑：控制寄存器的更新，使用时钟信号 clk
always @(posedge clk or posedge rst) begin
    if (rst || regE_bubble) begin
        // 复位所有输出信号
        regE_o_regdata1         <= 64'd0;
        regE_o_regdata2         <= 64'd0;
        regE_o_pc               <= 64'd0;
        
        regE_o_rd               <= 5'd0;
        regE_o_reg_wen          <= 1'd0;

        regE_o_alu_info         <= 28'd0;
        regE_o_load_store_info  <= 11'd0;
        regE_o_opcode_info      <= 12'd0;
        regE_o_branch_info      <= 6'd0;
        regE_o_commit_info      <= 161'd0;
    end
    else if (!regE_stall) begin
        regE_o_regdata1         <= decode_i_regdata1;
        regE_o_regdata2         <= decode_i_regdata2;
        regE_o_imm              <= decode_i_imm;
        regE_o_pc               <= regD_i_pc;

        regE_o_rd               <= decode_i_rd;
        regE_o_reg_wen          <= decode_i_reg_wen;

        regE_o_alu_info         <= decode_i_alu_info;
        regE_o_load_store_info  <= decode_i_load_store_info;
        regE_o_opcode_info      <= decode_i_opcode_info;
        regE_o_branch_info      <= decode_i_branch_info;
        regE_o_commit_info      <= regD_i_commit_info;
    end
end

endmodule
