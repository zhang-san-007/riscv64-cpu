module write_back
#(parameter WIDTH=64, OP_SIZE=12, GPR_SIZE=5)
(      
       input  wire [OP_SIZE-1:0]          regW_opcode_info,
       input  wire [WIDTH-1:0]     regW_alu_result,
       input  wire [WIDTH-1:0]     regW_memdata,
       input  wire [GPR_SIZE-1:0]           regW_rd     ,
       input  wire [WIDTH-1:0]     regW_pc     ,
       input  wire          regW_reg_wen,

       output wire [GPR_SIZE-1:0]    write_back_rd,
       output wire [WIDTH-1:0]   write_back_data,
       output wire          write_back_reg_wen
);

wire op_jal  = regW_opcode_info[9];
wire op_jalr = regW_opcode_info[8];
wire op_load = regW_opcode_info[3];


assign write_back_data    = (op_jal || op_jalr) ? regW_pc + 64'd4 : 
                              (op_load)           ? regW_memdata    : regW_alu_result;

assign write_back_rd      = regW_rd;
assign write_back_reg_wen = regW_reg_wen;
endmodule
