module commit(
    // 来自 Write Back 级的提交信息
    input wire [160:0]  regW_i_commit_info,
    input wire [63:0]   regW_i_regdata2,
    input wire [63:0]   regW_i_mem_rdata,
    input wire [63:0]   regW_i_alu_result,
    
    // 关键：检测流水线寄存器传过来的 valid 信号
    input wire          regW_i_valid,

    // 输出给顶层/仿真器的提交信号
    output wire [63:0]  commit_o_mem_rdata,
    output wire [63:0]  commit_o_mem_wdata,
    output wire [63:0]  commit_o_mem_addr,

    output wire         commit_o_commit,
    output wire [31:0]  commit_o_instr,
    output wire [63:0]  commit_o_pc,
    output wire [63:0]  commit_o_next_pc
);

    // 解析 commit_info 的内部字段
    // [160]     : 预留的 info 有效位
    // [159:128] : 指令码 (instr)
    // [127:64]  : 下一条 PC (next_pc)
    // [63:0]    : 当前 PC (pc)
    wire        info_valid   = regW_i_commit_info[160];
    wire [31:0] info_instr   = regW_i_commit_info[159:128];
    wire [63:0] info_next_pc = regW_i_commit_info[127:64];
    wire [63:0] info_pc      = regW_i_commit_info[63:0];

    // --- 核心逻辑 ---
    // 只有流水线寄存器标记为有效(1)，且 fetch 时标记的 valid 也为 1，才触发 commit
    assign commit_o_commit = regW_i_valid && info_valid;

    // 如果 commit 无效，则输出 0，这能防止 DiffTest 框架读取到错误的跳转中间状态
    assign commit_o_instr   = commit_o_commit ? info_instr   : 32'd0;
    assign commit_o_pc      = commit_o_commit ? info_pc      : 64'd0;
    assign commit_o_next_pc = commit_o_commit ? info_next_pc : 64'd0;

    // 内存访问信息透传 (用于访存追踪)
    assign commit_o_mem_rdata = regW_i_mem_rdata;
    assign commit_o_mem_wdata = regW_i_regdata2;
    assign commit_o_mem_addr  = regW_i_alu_result;

endmodule