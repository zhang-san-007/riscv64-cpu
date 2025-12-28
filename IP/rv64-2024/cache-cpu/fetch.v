module fetch(
    input wire clk,
    input wire rst,
    input wire fetch_stall,
    input wire fetch_bubble,
    input  wire  [63:0]  pc,
    output reg   [63:0]  fetch_o_pc,
    output wire  [31:0]  fetch_o_instr,
    output wire  [63:0]  fetch_o_pre_pc,
    output wire  [160:0] fetch_o_commit_info
);
wire [31:0] icache_o_instr;
icache u_icache(
    .clk            	(clk             ),
    .rst            	(rst             ),
    .bubble             (fetch_bubble    ),
    .stall              (fetch_stall     ),
    .pc             	(pc              ),
    .icache_o_instr 	(icache_o_instr  )
);

reg commit;
//这是一个流水线
always @(posedge clk) begin
    if(rst || fetch_bubble) begin
        fetch_o_pc  <= 64'd0;
        commit      <= 1'b0;
    end 
    else if(~fetch_stall)begin
        fetch_o_pc  <= pc;
        commit      <= 1'b1;
    end
end


assign fetch_o_instr        =  icache_o_instr;
assign fetch_o_pre_pc       =  fetch_o_pc + 64'd4;
assign fetch_o_commit_info  = {commit, icache_o_instr, fetch_o_pre_pc, fetch_o_pc};
endmodule