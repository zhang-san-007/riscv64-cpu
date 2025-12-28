`include "define.v"
module regfile(
    input wire clk,
    input wire rst,

    //write back
    input wire        write_back_i_reg_wen,
    input wire [4:0]  write_back_i_reg_rd,
    input wire [63:0] write_back_i_reg_data,

    //read reg
    input  wire [4:0]  decode_i_read_rs1,
    input  wire [4:0]  decode_i_read_rs2,
    output wire [63:0] regfile_o_valA,
    output wire [63:0] regfile_o_valB
);
import "DPI-C" function void dpi_read_regfile(input logic [63 : 0] a []);

reg [63:0] regfile[31:0];
initial begin
    dpi_read_regfile(regfile);
end

initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
        regfile[i] = {32'b0, i}; // Initializing with index values. Adjust as necessary.
    end
    //regfile[1] = 64'h80000020; 
end

//read
assign regfile_o_valA = decode_i_read_rs1 == 5'd0 ? 64'd0 :  regfile[decode_i_read_rs1];
assign regfile_o_valB = decode_i_read_rs2 == 5'd0 ? 64'd0 : regfile[decode_i_read_rs2];

//write
always @(posedge clk) begin
    if (rst) begin
        regfile[0]  <= 64'd0;
    end
    else if (write_back_i_reg_wen) begin
        regfile[write_back_i_reg_rd] <= write_back_i_reg_data;
    end
    regfile[0]  <= 64'd0;
end

endmodule