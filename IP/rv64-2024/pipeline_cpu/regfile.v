
//regfile模块的作用就是
module regfile
#(parameter WIDTH=64, INSTR_SIZE=32, COMMIT_SIZE=161, OP_SIZE=12, GPR_SIZE=5)
(
    input   wire            clk,
    input   wire            rst,
    //写回的数据
    input   wire [GPR_SIZE-1:0]         write_back_rd,
    input   wire [WIDTH-1:0]            write_back_data,
    input   wire                        write_back_reg_wen,
    //译码来的数据
    input   wire [GPR_SIZE-1 :0]        decode_rs1,        
    input   wire [GPR_SIZE-1 :0]        decode_rs2,        
    output  wire [WIDTH-1:0]            regfile_regdata1, 
    output  wire [WIDTH-1:0]            regfile_regdata2  
);
reg [WIDTH-1:0] regfile[31:0]; // Changed the register file to hold 32 entries of 64-bit each.
import "DPI-C" function void dpi_read_regfile(input logic [WIDTH-1 : 0] a []); // Updated DPI function for 64-bit.

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

assign regfile_regdata1 = decode_rs1 == 5'd0 ? 64'd0 : regfile[decode_rs1];
assign regfile_regdata2 = decode_rs2 == 5'd0 ? 64'd0 : regfile[decode_rs2];

always @(posedge clk) begin
    if(rst) begin
        regfile[0]  <= 64'd0;
    end
    else if(write_back_reg_wen && write_back_rd != 5'd0) begin // Check for non-zero destination register.
        regfile[write_back_rd] <= write_back_data;
    end
end

endmodule