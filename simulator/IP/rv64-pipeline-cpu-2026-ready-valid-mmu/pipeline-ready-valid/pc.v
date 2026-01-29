module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire        regF_stall,
    input  wire        regF_bubble,

    input  wire        execute_i_branch_need_jump,
    input  wire [63:0] execute_i_branch_next_pc,
    input  wire        execute_i_mret_need_jump,
    input  wire [63:0] execute_i_mret_next_pc,

    input  wire [63:0] fetch_i_next_pc,

    //ready-valid
    input  wire        regD_i_allowin,
    output wire        pc_o_allowin,   // 修改：变为 output 信号
    output wire        pc_o_valid,
    output reg  [63:0] pc
);

    reg        pc_valid;
    wire       pc_ready_go;
    assign pc_ready_go  = !regF_stall; 
    assign pc_o_allowin = !pc_valid || (pc_ready_go && regD_i_allowin);
    assign pc_o_valid   =  pc_valid && pc_ready_go;

    always @(posedge clk) begin
        if (rst) begin
            pc_valid <= 1'b0;
            pc       <= 64'h80000000;
        end 
        else if (pc_o_allowin) begin
            pc_valid <= 1'b1;
            if (pc_valid) begin
                pc <=  execute_i_mret_need_jump   ? execute_i_mret_next_pc   :
                       execute_i_branch_need_jump ? execute_i_branch_next_pc : fetch_i_next_pc;
            end
        end
    end
endmodule


