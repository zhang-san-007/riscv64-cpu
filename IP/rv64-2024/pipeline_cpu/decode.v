
module decode
#(parameter WIDTH=64, INSTR_SIZE=32, COMMIT_SIZE=161, OP_SIZE=12, GPR_SIZE=5,LS_SIZE=11, ALU_SIZE=28)
(
    input wire clk,                    // 时钟信号
    input wire rst,                     // 复位信号
    input wire [31:0]  				regD_instr,    // 输入指令
	//execute阶段数据前递
	input wire [WIDTH-1:0]			execute_alu_result,
	input wire [GPR_SIZE-1:0] 		regE_rd,
	input wire 						regE_reg_wen,

	input wire [OP_SIZE-1:0] 		regM_opcode_info,
	input wire [WIDTH - 1:0]		regM_alu_result,
	input wire [WIDTH-1:0]			memory_memdata,
	input wire [GPR_SIZE-1:0]		regM_rd,
	input wire 						regM_reg_wen,

	input wire [OP_SIZE-1:0]		regW_opcode_info,
	input wire [WIDTH-1:0]			regW_pc,
	input wire [WIDTH-1:0]  		regW_alu_result,
	input wire [WIDTH-1:0]			regW_memdata,
	input wire  [GPR_SIZE-1:0]		regW_rd,
	input wire  					regW_reg_wen,
	//要写回的数据信息
	input wire [WIDTH-1:0] 			write_back_data,
	input wire [GPR_SIZE-1:0]  		write_back_rd,
	input wire 		  				write_back_reg_wen,

	
	output wire [ALU_SIZE-1:0]  	decode_alu_info,
	output wire [OP_SIZE-1:0]		decode_opcode_info,
	output wire [5:0]				decode_branch_info,
	output wire [10:0]  			decode_load_store_info,

	//译码得出来的数据信息
    output wire [WIDTH-1:0]  		 decode_regdata1,   
    output wire [WIDTH-1:0]  		 decode_regdata2,   
	output wire [WIDTH-1:0]  		 decode_imm,

	output wire [GPR_SIZE-1:0]		 decode_rs1,
	output wire [GPR_SIZE-1:0]   	 decode_rs2,

	
	output wire [GPR_SIZE-1:0]		 decode_rd,//要写回的数据
	output wire 	   		 		 decode_reg_wen
);


wire [31:0] instr  = regD_instr;
wire [6:0]  opcode = instr[6:0];
wire [GPR_SIZE-1:0]	rd 	   = instr[OP_SIZE-1:7];
wire [2:0]  func3  = instr[14:12]; 
wire [GPR_SIZE-1:0]  rs1    = instr[19:15];
wire [GPR_SIZE-1:0]  rs2    = instr[24:20];
wire [6:0]  func7  = instr[31:25];
//====================================func3=======func7===imm=====================================
wire func3_000 				= (func3 == 3'b000);
wire func3_001  			= (func3 == 3'b001);
wire func3_010  			= (func3 == 3'b010);
wire func3_011  			= (func3 == 3'b011);
wire func3_100 				= (func3 == 3'b100);
wire func3_101  			= (func3 == 3'b101);
wire func3_110				= (func3 == 3'b110);
wire func3_111				= (func3 == 3'b111);
wire func7_0000000 			= (func7 == 7'b0000000);
wire func7_0100000          = (func7 == 7'b0100000);
wire func7_0000001			= (func7 == 7'b0000001);



wire inst_lui            	= (opcode == 7'b01_101_11); 
wire inst_auipc				= (opcode == 7'b00_101_11); 
wire inst_jal				= (opcode == 7'b11_011_11);
wire inst_jalr				= (opcode == 7'b11_001_11); 
wire inst_alu_reg			= (opcode == 7'b01_100_11);
wire inst_alu_regw			= (opcode == 7'b01_110_11);
wire inst_alu_imm			= (opcode == 7'b00_100_11); 
wire inst_alu_immw			= (opcode == 7'b00_110_11); 
wire inst_load				= (opcode == 7'b00_000_11); 
wire inst_store 			= (opcode == 7'b01_000_11); 
wire inst_branch		    = (opcode == 7'b11_000_11);
wire inst_system			= (opcode == 7'b11_100_11); 

//alu_reg
wire inst_add  				= (inst_alu_reg & func3_000 & func7_0000000);
wire inst_sub  				= (inst_alu_reg & func3_000 & func7_0100000);
wire inst_sll  				= (inst_alu_reg & func3_001 & func7_0000000);
wire inst_slt  				= (inst_alu_reg & func3_010 & func7_0000000);
wire inst_sltu 				= (inst_alu_reg & func3_011 & func7_0000000);
wire inst_xor  				= (inst_alu_reg & func3_100 & func7_0000000);
wire inst_srl  				= (inst_alu_reg & func3_101 & func7_0000000);
wire inst_sra  				= (inst_alu_reg & func3_101 & func7_0100000);
wire inst_or   				= (inst_alu_reg & func3_110 & func7_0000000);
wire inst_and  				= (inst_alu_reg & func3_111 & func7_0000000);
wire inst_addw				= (inst_alu_regw & func3_000 & func7_0000000);
wire inst_subw				= (inst_alu_regw & func3_000 & func7_0100000);
wire inst_sllw				= (inst_alu_regw & func3_001 & func7_0000000);
wire inst_srlw				= (inst_alu_regw & func3_101 & func7_0000000);
wire inst_sraw				= (inst_alu_regw & func3_101 & func7_0100000);



//alu_reg_w
wire inst_mul				= (inst_alu_reg & func3_000  & func7_0000001);
wire inst_mulh				= (inst_alu_reg & func3_001  & func7_0000001);
wire inst_mulhsu			= (inst_alu_reg & func3_010  & func7_0000001);
wire inst_mulhu				= (inst_alu_reg & func3_011  & func7_0000001);
wire inst_div				= (inst_alu_reg & func3_100  & func7_0000001);
wire inst_divu				= (inst_alu_reg & func3_101  & func7_0000001);
wire inst_rem				= (inst_alu_reg & func3_110  & func7_0000001);
wire inst_remu				= (inst_alu_reg & func3_111  & func7_0000001);
wire inst_mulw				= (inst_alu_regw & func3_000 & func7_0000001);
wire inst_divw				= (inst_alu_regw & func3_100 & func7_0000001);
wire inst_divuw				= (inst_alu_regw & func3_101 & func7_0000001);
wire inst_remw				= (inst_alu_regw & func3_110 & func7_0000001);
wire inst_remuw				= (inst_alu_regw & func3_111 & func7_0000001);

//alu_imm
wire inst_addi  			= (inst_alu_imm & func3_000);
wire inst_slli 	 			= (inst_alu_imm & func3_001);
wire inst_slti  			= (inst_alu_imm & func3_010);
wire inst_sltiu 			= (inst_alu_imm & func3_011);
wire inst_xori  			= (inst_alu_imm & func3_100);
wire inst_srli  			= (inst_alu_imm & func3_101 & func7_0000000);
wire inst_srai  			= (inst_alu_imm & func3_101 & func7_0100000);
wire inst_ori   			= (inst_alu_imm & func3_110);
wire inst_andi 			   	= (inst_alu_imm & func3_111);

//alu_imm_w
wire inst_addiw				= (inst_alu_immw & func3_000);
wire inst_slliw				= (inst_alu_immw & func3_001 & func7_0000000);
wire inst_srliw				= (inst_alu_immw & func3_101 & func7_0000000);
wire inst_sraiw				= (inst_alu_immw & func3_101 & func7_0100000);

//load
wire inst_lb          		= (inst_load & func3_000);
wire inst_lh           		= (inst_load & func3_001);
wire inst_lw           		= (inst_load & func3_010);
wire inst_ld           		= (inst_load & func3_011);
wire inst_lbu          		= (inst_load & func3_100);
wire inst_lhu          		= (inst_load & func3_101);
wire inst_lwu          		= (inst_load & func3_110);

//system
wire inst_csrrw  			= (inst_system & func3_001);
wire inst_csrrs  			= (inst_system & func3_010);
wire inst_csrrc  			= (inst_system & func3_011);
wire inst_csrrwi 			= (inst_system & func3_101);
wire inst_csrrsi 			= (inst_system & func3_110);
wire inst_csrrci 			= (inst_system & func3_111);

//store
wire inst_sb				= (inst_store & func3_000);
wire inst_sh				= (inst_store & func3_001);
wire inst_sw				= (inst_store & func3_010);
wire inst_sd				= (inst_store & func3_011);

//branch
wire inst_beq				= (inst_branch & func3_000);
wire inst_bne				= (inst_branch & func3_001);
wire inst_blt				= (inst_branch & func3_100);
wire inst_bge				= (inst_branch & func3_101);
wire inst_bltu				= (inst_branch & func3_110);
wire inst_bgeu				= (inst_branch & func3_111);


//------------------------------------译码结束-------------------------------------------
assign decode_opcode_info = {
	inst_lui,		//OP_SIZE-1
	inst_auipc,		//10
	inst_jal,		//9
	inst_jalr,		//8
	inst_alu_reg,	//7
	inst_alu_regw,	//6
	inst_alu_imm,	//5
	inst_alu_immw,	//GPR_SIZE-1
	inst_load,   	//3
	inst_store, 	//2
	inst_branch,	//1
	inst_system 	//0
};
assign decode_branch_info = {
	inst_beq,  // 5
	inst_bne,  // GPR_SIZE-1
	inst_blt,  // 3
	inst_bge,  // 2
	inst_bltu, // 1
	inst_bgeu  // 0		
};

assign decode_load_store_info = {
	inst_lb,  
	inst_lh,  
	inst_lw,  
	inst_ld, 
	inst_lbu,
	inst_lhu,
	inst_lwu,
	inst_sb,  
	inst_sh,  
	inst_sw,
	inst_sd								
};
assign decode_alu_info = {
			     (inst_add  	| inst_addi ),  // 9
			     (inst_sub                  ),  // 8
			  	 (inst_sll  	| inst_slli ),
			     (inst_slt  	| inst_slti ),
			     (inst_sltu 	| inst_sltiu),  
			     (inst_xor  	| inst_xori ),  
			     (inst_srl  	| inst_srli ),  
			     (inst_sra  	| inst_srai ),
			     (inst_or   	| inst_ori  ),  
			     (inst_and  	| inst_andi ),
				 (inst_addw 	| inst_addiw),
				 (inst_subw					),
				 (inst_sllw 	| inst_slliw),
				 (inst_srlw 	| inst_srliw),
				 (inst_sraw 	| inst_sraiw), 
				 (inst_mul  			    ),
				 (inst_mulh 				),
				 (inst_mulhsu				),
				 (inst_mulhu				),
				 (inst_mulw					),
				 (inst_div					),
				 (inst_divu					),
				 (inst_divw					),
				 (inst_divuw				),
				 (inst_rem					),
				 (inst_remu					),
				 (inst_remw					),
				 (inst_remuw				) 
};
wire [WIDTH-1:0] inst_i_imm = { {52{instr[31]}}, instr[31:20] };		
wire [WIDTH-1:0] inst_s_imm = { {52{instr[31]}}, instr[31:25], instr[OP_SIZE-1:7] };	
wire [WIDTH-1:0] inst_b_imm = { {51{instr[31]}}, instr[31],    instr[7],      instr[30:25], instr[OP_SIZE-1:8 ], 1'b0};
wire [WIDTH-1:0] inst_j_imm = { {43{instr[31]}}, instr[31],    instr[19:12],  instr[20],    instr[30:21], 1'b0};	
wire [WIDTH-1:0] inst_u_imm = { {32{instr[31]}}, instr[31:12], 12'd0};		
wire [WIDTH-1:0] inst_r_imm =   64'd0;	

wire inst_i_type = inst_load | inst_jalr | inst_alu_imm | inst_alu_immw;
wire inst_u_type = inst_lui  | inst_auipc;
wire inst_j_type = inst_jal;
wire inst_r_type = inst_alu_reg | inst_alu_regw;
wire inst_s_type = inst_store;
wire inst_b_type = inst_branch;

assign decode_imm = 	inst_i_type ? inst_i_imm : 
						inst_s_type ? inst_s_imm :
						inst_b_type ? inst_b_imm :
						inst_j_type ? inst_j_imm :
						inst_u_type ? inst_u_imm : 
						inst_r_type ? inst_r_imm : 64'd0;

assign decode_rd  		=  rd;
assign decode_rs1 		=  rs1; 
assign decode_rs2 		=  rs2;

assign decode_reg_wen = inst_i_type | inst_u_type | inst_r_type | inst_j_type;



wire [WIDTH-1:0] regfile_regdata1;
wire [WIDTH-1:0] regfile_regdata2;
regfile u_regfile(
	.clk                     	(clk                 ),
	.rst                     	(rst                 ),
	.write_back_rd      		(write_back_rd      		),
	.write_back_data    		(write_back_data     		),
	.write_back_reg_wen 		(write_back_reg_wen  		),
	.decode_rs1            		(rs1             			),
	.decode_rs2            		(rs2             			),
	.regfile_regdata1      		(regfile_regdata1     		),
	.regfile_regdata2      		(regfile_regdata2       	)
);
//execute阶段数据前递


wire regM_sel_memdata 			= regM_opcode_info[3];
wire regM_sel_alu_result    	= regM_opcode_info[1] | regM_opcode_info[GPR_SIZE-1] | regM_opcode_info[5] | regM_opcode_info[6]|
							  	  regM_opcode_info[7] | regM_opcode_info[10] | regM_opcode_info[OP_SIZE-1];

wire regW_sel_memdata			= regW_opcode_info[3];
wire regW_sel_pc				= regW_opcode_info[8] | regW_opcode_info[9];
wire regW_sel_alu_result    	= regW_opcode_info[1] | regW_opcode_info[GPR_SIZE-1]  | regW_opcode_info[5] | regW_opcode_info[6]|
							  	   regW_opcode_info[7] | regW_opcode_info[10] | regW_opcode_info[OP_SIZE-1];

assign decode_regdata1 	 	= 		regE_rd != 5'd0 && regE_reg_wen && regE_rd == rs1 ? execute_alu_result 	: 
						   			regM_rd != 5'd0 && regM_reg_wen && regM_rd == rs1 && regM_sel_alu_result	? regM_alu_result     	: 
						   			regM_rd != 5'd0 && regM_reg_wen && regM_rd == rs1 && regM_sel_memdata  	? memory_memdata 		: 
						   			regW_rd != 5'd0 && regW_reg_wen && regW_rd == rs1 && regW_sel_alu_result ? regW_alu_result 		: 
						   			regW_rd != 5'd0 && regW_reg_wen && regW_rd == rs1 && regW_sel_memdata	? regW_memdata 			: 
						   			regW_rd != 5'd0 && regW_reg_wen && regW_rd == rs1 && regW_sel_pc			? regW_pc + 64'd4     	: regfile_regdata1; 

assign decode_regdata2 		=   regE_rd != 5'd0  && regE_reg_wen && regE_rd == rs2 ? execute_alu_result 	: 
						   		regM_rd != 5'd0 && regM_reg_wen && regM_rd == rs2 && regM_sel_alu_result	? regM_alu_result     	: 
						   		regM_rd != 5'd0 && regM_reg_wen && regM_rd == rs2 && regM_sel_memdata  	? memory_memdata 		: 
						   		regW_rd != 5'd0 && regW_reg_wen && regW_rd == rs2 && regW_sel_alu_result ? regW_alu_result 		: 
						   		regW_rd != 5'd0 && regW_reg_wen && regW_rd == rs2 && regW_sel_memdata	? regW_memdata 			: 
						   		regW_rd != 5'd0 && regW_reg_wen && regW_rd == rs2 && regW_sel_pc			? regW_pc + 64'd4     	: regfile_regdata2; 

endmodule
