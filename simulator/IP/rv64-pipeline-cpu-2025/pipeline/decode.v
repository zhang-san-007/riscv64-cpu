
module decode(
    input wire clk,                      // 时钟信号
    input wire rst,                      // 复位信号
	input wire [63:0]   regD_i_pc,       //这个pc是为了方便看波形
    input wire [31:0]   regD_i_instr,    // 输入指令

	//execute阶段数据前递
	input wire [63:0]	execute_i_alu_result,
	input wire [4:0] 	regE_i_reg_rd,
	input wire 			regE_i_reg_wen,
	//memory数据前递
	input wire [13:0] 	regM_i_opcode_info,
	input wire [63:0] 	regM_i_alu_result,
	input wire [63:0]	memory_i_mem_rdata,
	input wire  [4:0]	regM_i_reg_rd,
	input wire 			regM_i_reg_wen,
	//wb数据前递
	input wire [13:0]	regW_i_opcode_info,
	input wire [63:0]	regW_i_pc,
	input wire [63:0]   regW_i_alu_result,
	input wire [63:0]	regW_i_mem_rdata,
	input wire [63:0]   regW_i_csr_rdata1,
	input wire  [4:0]	regW_i_reg_rd,
	input wire  		regW_i_reg_wen,

	//wb_reg
	input wire 		  	wb_i_reg_wen,
	input wire [4:0]  	wb_i_reg_rd,
	input wire [63:0] 	wb_i_reg_wdata,
	//wb_csr
	input wire 			wb_i_csr_wen,
	input wire [11:0]	wb_i_csr_wid,
	input wire [63:0]	wb_i_csr_wdata,
	input wire [6:0]	wb_i_system_info,
	
	//info
	output wire [27:0]  decode_o_alu_info,
	output wire [13:0]	decode_o_opcode_info,
	output wire [5 :0]	decode_o_branch_info,
	output wire [10:0]  decode_o_load_store_info,
	output wire [5 :0]	decode_o_csrrw_info,
	output wire [6 :0]	decode_o_system_info,
	output wire [19 :0]	decode_o_amo_info,



	//译码得出来的数据信息
    output wire [63:0]  decode_o_regdata1,   
    output wire [63:0]  decode_o_regdata2,   
	output wire [63:0]	decode_o_csr_rdata1,
	output wire [63:0]  decode_o_csr_rdata2,
	output wire [63:0]  decode_o_imm,
	//wb_csr
	output wire [11:0]  decode_o_csr_wid,
	output wire 		decode_o_csr_wen,

	//wb_reg
	output wire [4:0]	decode_o_reg_rd,
	output wire 	   	decode_o_reg_wen,
	output wire [4:0]	decode_o_reg_rs1,
	output wire [4:0] 	decode_o_reg_rs2
);


wire [31:0] instr   	= regD_i_instr;
wire [6:0]  opcode  	= instr[6:0];
wire [4:0]	rd 	    	= instr[11:7];
wire [2:0]  func3   	= instr[14:12]; 
wire [4:0]  rs1     	= instr[19:15];
wire [4:0]  rs2     	= instr[24:20];
wire [6:0]  func7  	 	= instr[31:25];
wire [11:0] csr_id  	= instr[31:20];
wire [4 :0] amo_func5 	= instr[31:27];
wire 		amo_aq		= instr[26];
wire 		amo_rl		= instr[25];

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
wire amo_op_add   			= (amo_func5 == 5'b00000);
wire amo_op_swap  			= (amo_func5 == 5'b00001);
wire amo_op_lr    			= (amo_func5 == 5'b00010);
wire amo_op_sc   			= (amo_func5 == 5'b00011);
wire amo_op_xor   			= (amo_func5 == 5'b00100);
wire amo_op_or    			= (amo_func5 == 5'b01000);
wire amo_op_and   			= (amo_func5 == 5'b01100);
wire amo_op_min   			= (amo_func5 == 5'b10000);
wire amo_op_max  			= (amo_func5 == 5'b10100);
wire amo_op_minu  			= (amo_func5 == 5'b11000);
wire amo_op_maxu  			= (amo_func5 == 5'b11100);


wire inst_lui            	= (opcode == 7'b01101_11); 
wire inst_auipc				= (opcode == 7'b00101_11); 
wire inst_jal				= (opcode == 7'b11011_11);
wire inst_jalr				= (opcode == 7'b11001_11); 
wire inst_alu_reg			= (opcode == 7'b01100_11);
wire inst_alu_regw			= (opcode == 7'b01110_11);
wire inst_alu_imm			= (opcode == 7'b00100_11); 
wire inst_alu_immw			= (opcode == 7'b00110_11); 
wire inst_load				= (opcode == 7'b00000_11); 
wire inst_store 			= (opcode == 7'b01000_11); 
wire inst_branch		    = (opcode == 7'b11000_11);
wire inst_system			= (opcode == 7'b11100_11); 
wire inst_amo				= (opcode == 7'b01011_11);
//异常处理
wire inst_valid = inst_lui      | inst_auipc    | inst_jal      | 
                  inst_jalr     | inst_alu_reg  | inst_alu_regw | 
                  inst_alu_imm  | inst_alu_immw | inst_load     | 
                  inst_store    | inst_branch   | inst_system;
wire exception_illegal_instruction = !inst_valid;

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
wire inst_mul				= (inst_alu_reg & func3_000  & func7_0000001);
wire inst_mulh				= (inst_alu_reg & func3_001  & func7_0000001);
wire inst_mulhsu			= (inst_alu_reg & func3_010  & func7_0000001);
wire inst_mulhu				= (inst_alu_reg & func3_011  & func7_0000001);
wire inst_div				= (inst_alu_reg & func3_100  & func7_0000001);
wire inst_divu				= (inst_alu_reg & func3_101  & func7_0000001);
wire inst_rem				= (inst_alu_reg & func3_110  & func7_0000001);
wire inst_remu				= (inst_alu_reg & func3_111  & func7_0000001);

//alu_reg_w
wire inst_addw				= (inst_alu_regw & func3_000 & func7_0000000);
wire inst_subw				= (inst_alu_regw & func3_000 & func7_0100000);
wire inst_sllw				= (inst_alu_regw & func3_001 & func7_0000000);
wire inst_srlw				= (inst_alu_regw & func3_101 & func7_0000000);
wire inst_sraw				= (inst_alu_regw & func3_101 & func7_0100000);
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
wire inst_srli  			= (inst_alu_imm & func3_101 & instr[31:26] == 6'b000_000);
wire inst_srai  			= (inst_alu_imm & func3_101 & instr[31:26] == 6'b010_000);
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

//system
wire inst_csrrw  			= (inst_system & func3_001);
wire inst_csrrs             = (inst_system & func3_010);
wire inst_csrrc 			= (inst_system & func3_011);
wire inst_csrrwi			= (inst_system & func3_101);
wire inst_csrrsi            = (inst_system & func3_110);
wire inst_csrrci            = (inst_system & func3_111);


wire inst_ecall				= (instr == 32'b00000_00_00000_00000_000_00000_11100_11);
wire inst_ebreak            = (instr == 32'b00000_00_00001_00000_000_00000_11100_11);
wire inst_uret				= (instr == 32'b00000_00_00010_00000_000_00000_11100_11);
wire inst_sret				= (instr == 32'b00010_00_00010_00000_000_00000_11100_11);
wire inst_mret				= (instr == 32'b00110_00_00010_00000_000_00000_11100_11);
wire inst_wfi			    = (instr == 32'b00010_00_00101_00000_000_00000_11100_11);
wire inst_sfence_vma		= (inst_system & (instr[31:27] == 5'b00010) & (instr[14:12] == 3'b000));

wire inst_csr_instr			=  inst_csrrw | inst_csrrs  | inst_csrrc | inst_csrrwi | inst_csrrsi | inst_csrrci;
wire inst_system_instr		=  inst_ecall | inst_ebreak | inst_uret	 | inst_sret   | inst_mret	 | inst_wfi   | inst_sfence_vma; 	 



wire inst_lrw			= inst_amo		&	(func3_010)		&	amo_op_lr;
wire inst_scw			= inst_amo		&	(func3_010)		&	amo_op_sc;
wire inst_amoswapw		= inst_amo		&	(func3_010)		&	amo_op_swap;
wire inst_amoaddw		= inst_amo		&	(func3_010)		&	amo_op_add;
wire inst_amoxorw		= inst_amo		&	(func3_010)		&	amo_op_xor;
wire inst_amoandw		= inst_amo		&	(func3_010)		&	amo_op_and;
wire inst_amoorw		= inst_amo		&	(func3_010)		&	amo_op_or;
wire inst_amominw		= inst_amo		&	(func3_010)		&	amo_op_min;
wire inst_amomaxw		= inst_amo		&	(func3_010)		&	amo_op_max;
wire inst_amominuw		= inst_amo		&	(func3_010)		&	amo_op_minu;
wire inst_amomaxuw		= inst_amo		&	(func3_010)		&	amo_op_maxu;

wire inst_lrd			= inst_amo		&	(func3_011)		&	amo_op_lr;
wire inst_scd			= inst_amo		&	(func3_011)		&	amo_op_sc;
wire inst_amoswapd		= inst_amo		&	(func3_011)		&	amo_op_swap;
wire inst_amoaddd		= inst_amo		&	(func3_011)		&	amo_op_add;
wire inst_amoxord		= inst_amo		&	(func3_011)		&	amo_op_xor;
wire inst_amoandd		= inst_amo		&	(func3_011)		&	amo_op_and;
wire inst_amoord		= inst_amo		&	(func3_011)		&	amo_op_or	;
wire inst_amomind		= inst_amo		&	(func3_011)		&	amo_op_min	;
wire inst_amomaxd		= inst_amo		&	(func3_011)		&	amo_op_max	;
wire inst_amominud		= inst_amo		&	(func3_011)		&	amo_op_minu	;
wire inst_amomaxud		= inst_amo		&	(func3_011)		&	amo_op_maxu	;


//------------------------------------译码结束-------------------------------------------
assign decode_o_opcode_info = {
	inst_amo,			//13
	inst_csr_instr,		//12
	inst_lui,			//11
	inst_auipc,			//10
	inst_jal,			//9
	inst_jalr,			//8
	inst_alu_reg,		//7
	inst_alu_regw,		//6
	inst_alu_imm,		//5
	inst_alu_immw,		//4
	inst_load,   		//3
	inst_store, 		//2
	inst_branch,		//1
	inst_system_instr	//0
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
assign decode_o_csrrw_info = {
	inst_csrrw,
	inst_csrrs,
	inst_csrrc,
	inst_csrrwi,
	inst_csrrsi,
	inst_csrrci
};

assign decode_o_system_info = {
	inst_ecall,
	inst_ebreak,
	inst_uret,
	inst_sret,
	inst_mret,
	inst_wfi,
	inst_sfence_vma
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
assign decode_o_amo_info = {
	inst_lrw		,	//19
	inst_scw	  	,	//18
	inst_amoswapw	,	//17
	inst_amoaddw	,	//16
	inst_amoxorw	,	//15
	inst_amoorw		,	//14
	inst_amominw	,	//13
	inst_amomaxw	,	//12
	inst_amominuw	,	//11
	inst_amomaxuw	,	//10
	inst_lrd		,	//9
	inst_scd		,	//8
	inst_amoswapd	,	//7
	inst_amoaddd	,	//6
	inst_amoxord	,	//5
	inst_amoord		,	//4
	inst_amomind	,	//3
	inst_amomaxd	,	//2
	inst_amominud	,	//1
	inst_amomaxud		//0
};

//立即数
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

assign decode_o_imm 	= 	inst_i_type ? inst_i_imm : 
							inst_s_type ? inst_s_imm :
							inst_b_type ? inst_b_imm :
							inst_j_type ? inst_j_imm :
							inst_u_type ? inst_u_imm : 
							inst_r_type ? inst_r_imm : 64'd0;

//辅助信号
wire   csr_rw			=  inst_csrrw | inst_csrrs | inst_csrrc | inst_csrrwi | inst_csrrsi | inst_csrrci;



//-------------------------------------------reg-begin---------------------------------
assign decode_o_reg_rs1 		=  rs1; 
assign decode_o_reg_rs2 		=  rs2;
assign decode_o_reg_wen 	= inst_i_type | inst_u_type | inst_r_type | inst_j_type | csr_rw | inst_amo;
assign decode_o_reg_rd  	=  rd;
wire [63:0] 	regfile_o_regdata1;
wire [63:0] 	regfile_o_regdata2;

regfile u_regfile(
	.clk                	( clk          ),
	.rst                	( rst          ),
	.wb_i_reg_rd        	( wb_i_reg_rd         ),
	.wb_i_reg_wdata     	( wb_i_reg_wdata      ),
	.wb_i_reg_wen       	( wb_i_reg_wen        ),
	.decode_i_reg_rs1   	( decode_o_reg_rs1    ),
	.decode_i_reg_rs2   	( decode_o_reg_rs2    ),
	.regfile_o_regdata1 	( regfile_o_regdata1  ),
	.regfile_o_regdata2 	( regfile_o_regdata2  )
);
//------------------------------------------reg-end-------------------------------------


//------------------------------------------数据前递-begin-------------------------------------------------------------------
wire regM_sel_mem_rdata 	= regM_i_opcode_info[3];
wire regM_sel_alu_result    = regM_i_opcode_info[1] | regM_i_opcode_info[4] | regM_i_opcode_info[5] | regM_i_opcode_info[6]|
							  regM_i_opcode_info[7] | regM_i_opcode_info[10] | regM_i_opcode_info[11];

wire regW_sel_mem_rdata		= regW_i_opcode_info[3];
wire regW_sel_pc			= regW_i_opcode_info[8] | regW_i_opcode_info[9];
wire regW_sel_alu_result    = regW_i_opcode_info[1] | regW_i_opcode_info[4]  | regW_i_opcode_info[5] | regW_i_opcode_info[6]|
							  regW_i_opcode_info[7] | regW_i_opcode_info[10] | regW_i_opcode_info[11];
wire regW_sel_csr_rdata		= regW_i_opcode_info[12];

assign decode_o_regdata1 = regE_i_reg_rd != 5'd0 && regE_i_reg_wen && regE_i_reg_rd == rs1 ? execute_i_alu_result 	: 
						   regM_i_reg_rd != 5'd0 && regM_i_reg_wen && regM_i_reg_rd == rs1 && regM_sel_alu_result	? regM_i_alu_result     : 
						   regM_i_reg_rd != 5'd0 && regM_i_reg_wen && regM_i_reg_rd == rs1 && regM_sel_mem_rdata  	? memory_i_mem_rdata 	: 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs1 && regW_sel_alu_result 	? regW_i_alu_result 	: 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs1 && regW_sel_mem_rdata	? regW_i_mem_rdata 		: 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs1 && regW_sel_pc			? regW_i_pc + 64'd4     : 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs1 && regW_sel_csr_rdata	? regW_i_csr_rdata1	    : regfile_o_regdata1; 


assign decode_o_regdata2 = regE_i_reg_rd != 5'd0 && regE_i_reg_wen && regE_i_reg_rd == rs2 ? execute_i_alu_result 	: 
						   regM_i_reg_rd != 5'd0 && regM_i_reg_wen && regM_i_reg_rd == rs2 && regM_sel_alu_result	? regM_i_alu_result     : 
						   regM_i_reg_rd != 5'd0 && regM_i_reg_wen && regM_i_reg_rd == rs2 && regM_sel_mem_rdata  	? memory_i_mem_rdata 	: 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs2 && regW_sel_alu_result 	? regW_i_alu_result 	: 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs2 && regW_sel_mem_rdata     ? regW_i_mem_rdata 	: 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs2 && regW_sel_pc			? regW_i_pc + 64'd4     : 
						   regW_i_reg_rd != 5'd0 && regW_i_reg_wen && regW_i_reg_rd == rs2 && regW_sel_pc			? regW_i_csr_rdata1     : regfile_o_regdata2; 
//------------------------------------------数据前递-end-------------------------------------------------------------------


//--------------------------------csr----begin---------------------------------------------------------------------------
wire [63:0] 	csr_o_csr_rdata1;
wire [63:0]     csr_o_csr_rdata2;

wire [11:0] csr_rid1 			= (inst_mret) ? `mstatus : csr_id;
wire [11:0] csr_rid2 			= (inst_mret) ? `mepc 	 : csr_id;

assign decode_o_csr_wid			=  (inst_mret) ? `mstatus : csr_id;
assign decode_o_csr_wen			=  (inst_mret) ? 1'b1     : csr_rw;



csrfile u_csrfile(
	.clk             	( clk              		),
	.rst             	( rst              		),
	.wb_i_system_info	( wb_i_system_info      ),
	.wb_i_csr_wen    	( wb_i_csr_wen     		),
	.wb_i_csr_wid     	( wb_i_csr_wid      	),
	.wb_i_csr_wdata  	( wb_i_csr_wdata   		),
	.decode_i_csr_rid1 	( csr_rid1 				),
	.decode_i_csr_rid2  ( csr_rid2				),
	.csr_o_csr_rdata1 	( decode_o_csr_rdata1   ),
	.csr_o_csr_rdata2	(decode_o_csr_rdata2)
);

//--------------------------------csr----end------------------------------------------------------------------------------

endmodule



