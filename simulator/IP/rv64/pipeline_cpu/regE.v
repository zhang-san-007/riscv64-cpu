//pipeline stage2

module regE
#(parameter WIDTH=64, INSTR_SIZE=32, COMMIT_SIZE=161)
(
    input wire clk,
    input wire rst,
    input wire regD_to_regE_valid,
    input wire regM_allow_in,

    output wire regE_to_regM_valid,
    output wire regE_allow_in
);

reg    regE_valid;
wire   regE_ready_go       = 1'b1;
assign regE_allow_in       = !regE_valid || regE_ready_go && regM_allow_in;
assign regE_to_regM_valid  = regE_valid && regE_ready_go;

always @(posedge clk) begin
    if(rst) begin
        regE_valid <= 1'b0;
    end
    else if(regE_allow_in) begin
        regE_valid <= regD_to_regE_valid;
    end
    if(regD_to_regE_valid && regE_allow_in) begin
        
    end
end

endmodule