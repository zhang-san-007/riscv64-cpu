module top_cpu
#(parameter WIDTH=64, INSTR=32, COMMIT=161)
(
    input  wire clk,
    input  wire rst,
    output wire                 commit,
    output wire [31:0]          commit_instr,
    output wire [63:0]          commit_pc,
    output wire [63:0]          commit_pre_pc,
    output wire [63:0]          cur_pc
);


endmodule



