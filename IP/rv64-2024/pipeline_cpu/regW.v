module regW
#(parameter WIDTH=64, INSTR_SIZE=32, COMMIT_SIZE=161, OP_SIZE=12, GPR_SIZE=5)
(
    input wire clk,
    input wire rst,
    input regM_to_regW_valid,
    output regW_allow_in
);

reg    regW_valid;
wire   regW_ready_go       = 1'b1;
assign regW_allow_in       = !regW_valid || regW_ready_go;

always @(posedge clk) begin
    if(rst) begin
        regW_valid <= 1'b0;
    end
    else if(regW_allow_in) begin
        regW_valid <= regM_to_regW_valid;
    end
    if(regM_to_regW_valid && regW_allow_in) begin

    end
end

endmodule