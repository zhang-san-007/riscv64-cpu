
module write_back(      
       input  wire [12:0]   regW_i_opcode_info,
       input  wire [5:0]    regW_i_csrrw_info,
       input  wire [6:0]    regW_i_system_info,

       input  wire [63:0]   regW_i_alu_result,
       input  wire [63:0]   regW_i_memdata,
       input  wire [4:0]    regW_i_rd,
       input  wire [63:0]   regW_i_pc,
       //csr
       input wire [11:0]    regW_i_csrid,
       input wire [63:0]    regW_i_csrdata,

       //

       output wire [4:0]    wb_o_reg_rd,
       output wire [63:0]   wb_o_reg_wdata,
       output wire          wb_o_reg_wen
       //csr写入
       output wire          wb_o_csr_wen,
       output wire [63:0]   wb_o_csr_wdata,
       output wire [11:0]   wb_o_csr_id,

);


wire op_csrrw  = regW_i_opcode_info[12];
wire op_system = regW_i_system_info[11];
wire op_jal    = regW_i_opcode_info[9];
wire op_jalr   = regW_i_opcode_info[8];
wire op_load   = regW_i_opcode_info[3];



//reg
assign wb_o_reg_wdata       = (op_jal || op_jalr) ? regW_i_pc + 64'd4 : 
                              (op_load)           ? regW_i_memdata    : regW_i_alu_result;
                              (op_csrrw)          ? regW_i_cs
assign wb_o_reg_rd          = regW_i_rd;
assign wb_o_reg_wen         = regW_i_reg_wen;

//csr
assign wb_o_csr_wen         = regW_i_csr_wen;
assign wb_o_csr_id          =
endmodule






// wb_o_reg_wdata = csr_rdata | reg_data1   (ALU)
//      reg_wen   =
//      reg_wrd   =


//      csr_wid   = 
//      csr_wen   = 
// wb_o_csr_wdata = csr_rdata | 