`include "define.v"
module regD(
    input wire         clk,               // 时钟信号
    input wire         rst,               // 复位信号
    input wire         regD_bubble,
    input wire         regD_stall,
//------------input--------------------
    //data
    input wire [63:0]  fetch_i_pc,
    input wire [31:0]  fetch_i_instr,
    //commit
    input wire [160:0] fetch_i_commit_info,
//------------output---------------------
    output reg [63:0]  regD_o_pc,
    output reg [31:0]  regD_o_instr,      
    output reg [160:0] regD_o_commit_info
);
    always @(posedge clk) begin
        if(rst || regD_bubble) begin
            regD_o_pc               <= `nop_pc;
            regD_o_instr            <= `nop_instr;    
            regD_o_commit_info      <= `nop_commit_info;
        end 
        else if(~regD_stall) begin
            regD_o_pc               <= fetch_i_pc;
            regD_o_instr            <= fetch_i_instr;          
            regD_o_commit_info      <= fetch_i_commit_info;
        end
    end
endmodule