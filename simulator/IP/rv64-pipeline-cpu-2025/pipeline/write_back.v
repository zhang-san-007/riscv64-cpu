module write_back(      
       input  wire [13:0]   regW_i_opcode_info,
       input  wire [5:0]    regW_i_csrrw_info,
       input  wire [6:0]    regW_i_system_info,
       input  wire [19:0]   regW_i_amo_info,
       //data
       input  wire [63:0]   regW_i_alu_result,
       input  wire [63:0]   regW_i_mem_rdata,
       input  wire [63:0]   regW_i_pc,
       input wire [63:0]    regW_i_csr_rdata1,

       //csrcsr
       input wire [11:0]    regW_i_csr_wid,
       input wire           regW_i_csr_wen,
       //reg
       input wire           regW_i_reg_wen,
       input wire [4:0]     regW_i_reg_rd, 

       //wb_csr
       output wire          wb_o_csr_wen,
       output wire [63:0]   wb_o_csr_wdata,
       output wire [11:0]   wb_o_csr_wid,
       output wire [6:0]    wb_o_system_info,

       //wb_reg
       output wire [4:0]    wb_o_reg_rd,
       output wire [63:0]   wb_o_reg_wdata,
       output wire          wb_o_reg_wen
);


wire op_csrrw        = regW_i_opcode_info[12];
wire op_jal          = regW_i_opcode_info[9];
wire op_jalr         = regW_i_opcode_info[8];
wire op_load         = regW_i_opcode_info[3];
wire op_system       = regW_i_opcode_info[0];
wire inst_amoswapw   = regW_i_amo_info[17];



//reg
assign wb_o_reg_wdata       = (op_jal || op_jalr) ? regW_i_pc + 64'd4 : 
                              (op_load)           ? regW_i_mem_rdata    : 
                              (op_csrrw)          ? regW_i_csr_rdata1   : 
                              (inst_amoswapw)     ? regW_i_mem_rdata    : regW_i_alu_result;
assign wb_o_reg_rd          = regW_i_reg_rd;
assign wb_o_reg_wen         = regW_i_reg_wen;

//csr
assign wb_o_csr_wen         = regW_i_csr_wen;
assign wb_o_csr_wid         = regW_i_csr_wid;
assign wb_o_csr_wdata       = regW_i_alu_result;

endmodule



