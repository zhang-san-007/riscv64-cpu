`include "define.v"
module regD(
    input  wire         clk,
    input  wire         rst,
    input  wire         pipeline_flush,    // 新增：流水线冲刷信号
    input  wire         pc_o_valid,
    output wire         regD_o_allowin,
    output wire         regD_o_valid,
    input  wire         regE_allowin,
    input  wire [63:0]  fetch_i_pc,
    input  wire [31:0]  fetch_i_instr,
    input  wire [160:0] fetch_i_commit_info,
    output reg  [63:0]  regD_o_pc,
    output reg  [31:0]  regD_o_instr,      
    output reg  [160:0] regD_o_commit_info
);
    reg         regD_valid;
    wire        regD_ready_go;

    assign regD_ready_go  = 1'b1;
    assign regD_o_allowin = !regD_valid || (regD_ready_go && regE_allowin);
    assign regD_o_valid   = regD_valid && regD_ready_go;

    always @(posedge clk) begin
        if (rst || pipeline_flush) begin    // 冲刷时清空 valid
            regD_valid <= 1'b0;
        end else if (regD_o_allowin) begin
            regD_valid <= pc_o_valid;
        end

        if (pc_o_valid && regD_o_allowin && !pipeline_flush) begin // 确保冲刷时不锁存新数据
            regD_o_pc          <= fetch_i_pc;
            regD_o_instr       <= fetch_i_instr;
            regD_o_commit_info <= fetch_i_commit_info;
        end
    end

endmodule