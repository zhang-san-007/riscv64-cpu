`include "define.v"
module regF (
    input  wire        clk,
    input  wire        rst,
    input  wire        ctrl_i_regF_stall,
    input  wire [63:0] pc_select_o_pc,

    output reg  [63:0] regF_o_pc
);
    always @(posedge clk) begin
        if(rst) begin
            regF_o_pc <= 64'h80000000;
        end
        else if (~ctrl_i_regF_stall) begin 
            regF_o_pc <= pc_select_o_pc;
        end

    end
endmodule

