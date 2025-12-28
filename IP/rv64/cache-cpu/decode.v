
module decode(
    input wire clk,                    // 时钟信号
    input wire rst,                    // 复位信号
    input wire [31:0] regD_i_instr,    // 输入指令

	//execute阶段数据前递
	input wire [63:0]	execute_i_alu_result,
	input wire [4:0] 	regE_i_rd,
	input wire 			regE_i_reg_wen,

	input wire [11:0] 	regM_i_opcode_info,
	input wire [63:0] 	regM_i_alu_result,
	input wire [63:0]	memory_i_memdata,
	input wire  [4:0]	regM_i_rd,
	input wire 			regM_i_reg_wen,

	input wire [11:0]	regW_i_opcode_info,
	input wire [63:0]	regW_i_pc,
	input wire [63:0]   regW_i_alu_result,
	input wire [63:0]	regW_i_memdata,
	input wire  [4:0]	regW_i_rd,
	input wire  		regW_i_reg_wen,
	//要写回的数据信息
	input wire [63:0] 	write_back_i_data,
	input wire [4:0]  	write_back_i_rd,
	input wire 		  	write_back_i_reg_wen,

	
	output wire [27:0]  decode_o_alu_info,
	output wire [11:0]	decode_o_opcode_info,
	output wire [5:0]	decode_o_branch_info,
	output wire [10:0]  decode_o_load_store_info,

	//译码得出来的数据信息
    output wire [63:0]  decode_o_regdata1,   
    output wire [63:0]  decode_o_regdata2,   
	output wire [63:0]  decode_o_imm,

	output wire [4:0]	decode_o_rs1,
	output wire [4:0]   decode_o_rs2,

	//要写回的数据
	output wire [4:0]	decode_o_rd,
	output wire 	   	decode_o_reg_wen
);


wire [31:0] instr  = regD_i_instr;
wire [6:0]  opcode = instr[6:0];
wire [4:0]	rd 	   = instr[11:7];
wire [2:0]  func3  = instr[14:12]; 
wire [4:0]  rs1    = instr[19:15];
wire [4:0]  rs2    = instr[24:20];
wire [6:0]  func7  = instr[31:25];


//====================================func3=======func7===imm=====================================
wire func3_000 					= (func3 == 3'b000);
wire func3_001  				= (func3 == 3'b001);
wire func3_010  				= (func3 == 3'b010);
wire func3_011  				= (func3 == 3'b011);
wire func3_100 					= (func3 == 3'b100);
wire func3_101  				= (func3 == 3'b101);
wire func3_110					= (func3 == 3'b110);
wire func3_111					= (func3 == 3'b111);
wire func7_0000000 				= (func7 == 7'b0000000);
wire func7_0100000              = (func7 == 7'b0100000);
wire func7_0000001				= (func7 == 7'b0000001);



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
assign decode_o_opcode_info = {
	inst_lui,		//11
	inst_auipc,		//10
	inst_jal,		//9
	inst_jalr,		//8
	inst_alu_reg,	//7
	inst_alu_regw,	//6
	inst_alu_imm,	//5
	inst_alu_immw,	//4
	inst_load,   	//3
	inst_store, 	//2
	inst_branch,	//1
	inst_system 	//0
};
assign decode_o_branch_info = {
	inst_beq,  // 5
	inst_bne,  // 4
	inst_blt,  // 3
	inst_bge,  // 2
	inst_bltu, // 1
	inst_bgeu  // 0		
};

assign decode_o_load_store_info = {
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
assign decode_o_alu_info = {
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
wire [63:0] inst_i_imm = { {52{instr[31]}}, instr[31:20] };		
wire [63:0] inst_s_imm = { {52{instr[31]}}, instr[31:25], instr[11:7] };	
wire [63:0] inst_b_imm = { {51{instr[31]}}, instr[31],    instr[7],      instr[30:25], instr[11:8 ], 1'b0};
wire [63:0] inst_j_imm = { {43{instr[31]}}, instr[31],    instr[19:12],  instr[20],    instr[30:21], 1'b0};	
wire [63:0] inst_u_imm = { {32{instr[31]}}, instr[31:12], 12'd0};		
wire [63:0] inst_r_imm =   64'd0;	

wire inst_i_type = inst_load | inst_jalr | inst_alu_imm | inst_alu_immw;
wire inst_u_type = inst_lui  | inst_auipc;
wire inst_j_type = inst_jal;
wire inst_r_type = inst_alu_reg | inst_alu_regw;
wire inst_s_type = inst_store;
wire inst_b_type = inst_branch;

assign decode_o_imm = 	inst_i_type ? inst_i_imm : 
						inst_s_type ? inst_s_imm :
						inst_b_type ? inst_b_imm :
						inst_j_type ? inst_j_imm :
						inst_u_type ? inst_u_imm : 
						inst_r_type ? inst_r_imm : 64'd0;

assign decode_o_rd  		=  rd;
assign decode_o_rs1 		=  rs1; 
assign decode_o_rs2 		=  rs2;

assign decode_o_reg_wen = inst_i_type | inst_u_type | inst_r_type | inst_j_type;



wire [63:0] regfile_o_regdata1;
wire [63:0] regfile_o_regdata2;
regfile u_regfile(
	.clk                     	(clk                      	),
	.rst                     	(rst                      	),
	.write_back_i_rd      		(write_back_i_rd      		),
	.write_back_i_data    		(write_back_i_data     		),
	.write_back_i_reg_wen 		(write_back_i_reg_wen  		),
	.decode_i_rs1            	(rs1             			),
	.decode_i_rs2            	(rs2             			),
	.regfile_o_regdata1      	(regfile_o_regdata1     	),
	.regfile_o_regdata2      	(regfile_o_regdata2       	)
);
//execute阶段数据前递


wire regM_sel_memdata 		= regM_i_opcode_info[3];
wire regM_sel_alu_result    = regM_i_opcode_info[1] | regM_i_opcode_info[4] | regM_i_opcode_info[5] | regM_i_opcode_info[6]|
							  regM_i_opcode_info[7] | regM_i_opcode_info[10] | regM_i_opcode_info[11];

wire regW_sel_memdata		= regW_i_opcode_info[3];
wire regW_sel_pc			= regW_i_opcode_info[8] | regW_i_opcode_info[9];
wire regW_sel_alu_result    = regW_i_opcode_info[1] | regW_i_opcode_info[4]  | regW_i_opcode_info[5] | regW_i_opcode_info[6]|
							  regW_i_opcode_info[7] | regW_i_opcode_info[10] | regW_i_opcode_info[11];

assign decode_o_regdata1 = regE_i_rd != 5'd0 && regE_i_reg_wen && regE_i_rd == rs1 ? execute_i_alu_result 	: 
						   regM_i_rd != 5'd0 && regM_i_reg_wen && regM_i_rd == rs1 && regM_sel_alu_result	? regM_i_alu_result     : 
						   regM_i_rd != 5'd0 && regM_i_reg_wen && regM_i_rd == rs1 && regM_sel_memdata  	? memory_i_memdata 		: 
						   regW_i_rd != 5'd0 && regW_i_reg_wen && regW_i_rd == rs1 && regW_sel_alu_result 	? regW_i_alu_result 	: 
						   regW_i_rd != 5'd0 && regW_i_reg_wen && regW_i_rd == rs1 && regW_sel_memdata		? regW_i_memdata 		: 
						   regW_i_rd != 5'd0 && regW_i_reg_wen && regW_i_rd == rs1 && regW_sel_pc			? regW_i_pc + 64'd4     : regfile_o_regdata1; 

assign decode_o_regdata2 = regE_i_rd != 5'd0 && regE_i_reg_wen && regE_i_rd == rs2 ? execute_i_alu_result 	: 
						   regM_i_rd != 5'd0 && regM_i_reg_wen && regM_i_rd == rs2 && regM_sel_alu_result	? regM_i_alu_result     : 
						   regM_i_rd != 5'd0 && regM_i_reg_wen && regM_i_rd == rs2 && regM_sel_memdata  	? memory_i_memdata 		: 
						   regW_i_rd != 5'd0 && regW_i_reg_wen && regW_i_rd == rs2 && regW_sel_alu_result 	? regW_i_alu_result 	: 
						   regW_i_rd != 5'd0 && regW_i_reg_wen && regW_i_rd == rs2 && regW_sel_memdata		? regW_i_memdata 		: 
						   regW_i_rd != 5'd0 && regW_i_reg_wen && regW_i_rd == rs2 && regW_sel_pc			? regW_i_pc + 64'd4     : regfile_o_regdata2; 

endmodule
