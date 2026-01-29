`include "define.v"
module regD(
    input  wire         clk,
    input  wire         rst,
    input  wire         regD_stall,
    input  wire         regD_bubble,
    input  wire         pc_o_valid,
    input  wire         regE_i_allowin,
    input  wire [63:0]  fetch_i_pc,
    input  wire [31:0]  fetch_i_instr,
    input  wire [160:0] fetch_i_commit_info,

    output wire         regD_o_allowin,
    output wire         regD_o_valid,

    output reg  [63:0]  regD_o_pc,
    output reg  [31:0]  regD_o_instr,      
    output reg  [160:0] regD_o_commit_info
);
    reg         regD_valid;
    wire        regD_ready_go;

    assign regD_ready_go  = !regD_stall; 
    // 修正：将 regE_allowin 更改为接口名 regE_i_allowin
    assign regD_o_allowin = !regD_valid || (regD_ready_go && regE_i_allowin);
    assign regD_o_valid   =  regD_valid && regD_ready_go;

    always @(posedge clk) begin
        if (rst || regD_bubble) begin
            regD_valid          <= 1'b0;
            regD_o_pc           <= `nop_pc;
            regD_o_instr        <= `nop_instr;    
            regD_o_commit_info  <= `nop_commit_info;
        end
        else if (regD_o_allowin) begin
            if (pc_o_valid == 1'b0) begin
                regD_valid      <= pc_o_valid;
                regD_o_pc       <= `nop_pc;
                regD_o_instr    <= `nop_instr;    
                regD_o_commit_info <= `nop_commit_info;
            end else begin
                regD_valid      <= pc_o_valid;
            end
        end
        
        // 当输入有效、本级允许进入且无气泡时，更新采样数据
        if(pc_o_valid && regD_o_allowin && !regD_bubble) begin
            regD_o_pc          <= fetch_i_pc;
            regD_o_instr       <= fetch_i_instr;
            regD_o_commit_info <= fetch_i_commit_info;
        end
    end
endmodule