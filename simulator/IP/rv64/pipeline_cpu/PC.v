module PC
#( parameter WIDTH = 64)
(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 regD_allow_in,
    output wire                 pc_to_regD_valid,
    output wire                 pc_allow_in,
    output reg  [WIDTH-1:0]     pc
);

//如果pc_valid是0，那么pc_allow_in永远都会是1
//如果pc_valid为1，那么pc_allow_in的值取决于pc_ready_go 和 regD_allow_in


reg    pc_valid;
wire   pc_ready_go       = 1'b1;
assign pc_allow_in       = !pc_valid || pc_ready_go && regD_allow_in;
assign pc_to_regD_valid  =  pc_valid && pc_ready_go;

always @(posedge clk) begin
    if(rst) begin
        pc <= 64'h80000000;
        pc_valid <= 1'b0;
    end
    else if(pc_allow_in) begin
        pc_valid <= 1'b1;
        pc       <= pc + 64'd4;
    end
    //如果pc_allow_in在复位后立即是高电平，那么它
end

endmodule