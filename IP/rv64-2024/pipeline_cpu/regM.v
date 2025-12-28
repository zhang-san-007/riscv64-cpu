module regM
#(parameter WIDTH=64, INSTR_SIZE=32, COMMIT_SIZE=161, OP_SIZE=12, GPR_SIZE=5)
(
    input wire clk,
    input wire rst,
    input regE_to_regM_valid,
    input regW_allow_in,

    output regM_to_regW_valid,
    output regM_allow_in
);

reg     regM_valid;
wire    regM_ready_go       = 1'b1;
assign  regM_allow_in       = !regM_valid || regM_ready_go && regW_allow_in;
assign  regM_to_regW_valid  =  regM_valid && regM_ready_go;

always @(posedge clk) begin
    if(rst) begin
        regM_valid <= 1'b0;
    end
    else if(regM_allow_in) begin
        regM_valid <= regE_to_regM_valid;
    end
    if(regE_to_regM_valid && regM_allow_in) begin
       
    end
end

endmodule