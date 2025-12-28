// Pipeline stage 2 (regD)

module regD
#(parameter WIDTH=64, INSTR_SIZE=32, COMMIT_SIZE=161)
(
    input  wire clk,
    input  wire rst,
    input  wire pc_to_regD_valid,
    input  wire regE_allow_in,
    output wire regD_to_regE_valid,
    output wire regD_allow_in
);

reg    regD_valid;
wire   regD_ready_go       = 1'b1; // Replace with actual condition
assign regD_allow_in       = !regD_valid || regD_ready_go && regE_allow_in;
assign regD_to_regE_valid  =  regD_valid && regD_ready_go;

    always @(posedge clk) begin
        if (rst) begin
            regD_valid <= 1'b0;
        end
        else if (regD_allow_in) begin
            regD_valid <= pc_to_regD_valid;
        end
        if (pc_to_regD_valid && regD_allow_in) begin

        end
    end
endmodule