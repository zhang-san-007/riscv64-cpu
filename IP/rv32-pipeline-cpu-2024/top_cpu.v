module CPU(
    input  wire clk,
    input  wire rst,
    output wire [63:0]          cur_pc,

    output wire                 commit,
    output wire [63:0]          commit_pc,
    output wire [63:0]          commit_pre_pc
);
assign commit = 1;
assign commit_pc = 64'800000000;
assign commit_pre_pc = 64'h800000000;




endmodule