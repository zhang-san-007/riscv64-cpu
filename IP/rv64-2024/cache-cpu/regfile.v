
//regfile模块的作用就是
module regfile(
    input   wire            clk,
    input   wire            rst,

    //写回的数据
    input   wire [4:0]      write_back_i_rd,
    input   wire [63:0]     write_back_i_data,
    input   wire            write_back_i_reg_wen,

    //译码来的数据
    input   wire [4 :0]     decode_i_rs1,        
    input   wire [4 :0]     decode_i_rs2,        
    output  wire [63:0]     regfile_o_regdata1, 
    output  wire [63:0]     regfile_o_regdata2  
);
reg [63:0] regfile[31:0]; // Changed the register file to hold 32 entries of 64-bit each.

import "DPI-C" function void dpi_read_regfile(input logic [63 : 0] a []); // Updated DPI function for 64-bit.

initial begin
    dpi_read_regfile(regfile);
end

initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
        regfile[i] = {32'b0, i}; // Initializing with index values. Adjust as necessary.
    end
    regfile[1] = 64'h80000020; 
end

assign regfile_o_regdata1 = decode_i_rs1 == 5'd0 ? 64'd0 : regfile[decode_i_rs1];
assign regfile_o_regdata2 = decode_i_rs2 == 5'd0 ? 64'd0 : regfile[decode_i_rs2];

always @(posedge clk) begin
    if(rst) begin
        regfile[0]  <= 64'd0;
    end
    else if(write_back_i_reg_wen && write_back_i_rd != 5'd0) begin // Check for non-zero destination register.
        regfile[write_back_i_rd] <= write_back_i_data;
    end
end

endmodule