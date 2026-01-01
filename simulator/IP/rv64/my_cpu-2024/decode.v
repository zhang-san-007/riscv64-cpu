`include "define.v"
module decode(
	input wire clk,
	input wire rst,
	input  wire [31:0]  regD_i_instr,

	//写回阶段
	input wire  [63:0]	regW_i_valE,
	input wire  [63:0]	regW_i_valM,
	input wire 	[1:0]	regW_i_wb_valD_sel,
	input wire 	[4:0]	regW_i_wb_rd,
	input wire 			regW_i_wb_reg_wen,
	input wire  [63:0]  regW_i_pc,
	//访存阶段数据前递
	input  wire	[63:0]	regM_i_valE,
	input  wire [63:0]	memory_i_valM,
	input  wire [1:0]	regM_i_wb_valD_sel,
	input  wire [4:0] 	regM_i_wb_rd,
	input  wire 		regM_i_wb_reg_wen,

	//执行阶段数据前递
	input  wire 		regE_i_wb_reg_wen,
	input  wire [4:0]	regE_i_wb_rd,
	input  wire [63:0]	execute_i_valE,

	//write_back
	input wire 		  	write_back_i_wb_reg_wen,
	input wire [4:0] 	write_back_i_wb_rd,
	input wire [63:0] 	write_back_i_wb_valD,

	//execute	
    output wire [63:0] 	decode_o_valA,
    output wire [63:0] 	decode_o_valB,
    output wire [63:0] 	decode_o_imm,
	output wire			decode_o_alu_W_instr,
	output wire [1:0]  	decode_o_alu_valA_sel,
	output wire [1:0] 	decode_o_alu_valB_sel,
	output wire [3:0] 	decode_o_alu_func_sel,

	//memory
	output wire	[3:0]	decode_o_mem_wmask,
	output wire [2:0]	decode_o_load_type,
	output wire   		decode_o_mem_ren,
	output wire			decode_o_mem_wen,
	//write_back
    output wire        	decode_o_wb_reg_wen,
	output wire [4:0]  	decode_o_wb_rd,
	output wire [1:0]  	decode_o_wb_valD_sel,
	output wire [4:0]	decode_o_rs1,
	output wire [4:0]	decode_o_rs2,

	output wire 		decode_o_need_jump,
	output wire 		decode_o_is_jalr

);
//++++++++++++++++++++++++++++++++++++++++16 bit instr++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 	//opcode == 10
// wire [4:0] rv64IC_rd			= rv64I_instr[11:7];
// wire [4:0] rv64IC_rs1			= rv64I_instr[11:7];
// wire [4:0] rv64IC_rs2			= rv64I_instr[6:2];

// wire rv64IC_op_10				= (rv64I_instr[1:0]   == 2'b10	) ? 1'b1 : 1'b0;
// wire rv64IC_func4_1000			= (rv64I_instr[15:12] == 4'b1000) ? 1'b1 : 1'b0;
// wire rv64IC_func4_1001			= (rv64I_instr[15:12] == 4'b1001) ? 1'b1 : 1'b0;

// wire rv64IC_func3_000			= (rv64I_instr[15:13] == 3'b000 ) ? 1'b1 : 1'b0;
// wire rv64IC_func3_001			= (rv64I_instr[15:13] == 3'b001 ) ? 1'b1 : 1'b0;
// wire rv64IC_func3_010			= (rv64I_instr[15:13] == 3'b010 ) ? 1'b1 : 1'b0;
// wire rv64IC_func3_011			= (rv64I_instr[15:13] == 3'b011 ) ? 1'b1 : 1'b0;
// wire rv64IC_func3_111			= (rv64I_instr[15:13] == 3'b111 ) ? 1'b1 : 1'b0;

// wire rv64IC_c_add				= (rv64IC_op_10 && rv64IC_func4_1001 && rv64IC_rs2 != 5'b00000) ? 1'b1 : 1'b0;	//R
// wire rv64IC_c_jalr				= (rv64IC_op_10 && rv64IC_func4_1001 && rv64IC_rs2 == 5'b00000) ? 1'b1 : 1'b0;	//R
// wire rv64IC_c_jr				= (rv64IC_op_10 && rv64IC_func4_1000 && rv64IC_rs2 == 5'b00000) ? 1'b1 : 1'b0;	//R
// wire rv64IC_c_mv				= (rv64IC_op_10 && rv64IC_func4_1000 && rv64IC_rs2 != 5'b00000) ? 1'b1 : 1'b0;	//R
// wire rv64IC_c_ldsp				= (rv64IC_op_10 && rv64IC_func3_011	 						  ) ? 1'b1 : 1'b0;	//I
// wire rv64IC_c_lwsp				= (rv64IC_op_10 && rv64IC_func3_010	 						  ) ? 1'b1 : 1'b0;	//I
// wire rv64IC_c_slli				= (rv64IC_op_10 && rv64IC_func3_000	 						  ) ? 1'b1 : 1'b0;	//I
// wire rv64IC_c_sdsp				= (rv64IC_op_10 && rv64IC_func3_111	 						  ) ? 1'b1 : 1'b0;	//S
// wire rv64IC_c_swsp				= (rv64IC_op_10 && rv64IC_func3_110	 						  ) ? 1'b1 : 1'b0;	//S

	//opcode == 00

//+++++++++++++++++++++++++++++++++++++++++32 bit instr++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire [31:0]rv64I_instr 			= regD_i_instr;
wire [6:0] rv64I_opcode			= rv64I_instr[6:0]; 
wire [4:0] rv64I_rd     		= rv64I_instr[11:7];
wire [2:0] rv64I_func3  		= rv64I_instr[14:12];
wire [4:0] rv64I_rs1    		= rv64I_instr[19:15];
wire [4:0] rv64I_rs2    		= rv64I_instr[24:20];
wire [6:0] rv64I_func7  		= rv64I_instr[31:25];
wire [5:0] rv64I_I_special      = rv64I_instr[31:26];

	//------------------------opcode&TYPE----------------------------------------------------------
wire rv64I_B_TYPE   = (rv64I_opcode == 7'b1100011);
wire rv64I_J_TYPE   = (rv64I_opcode == 7'b1101111);
wire rv64I_S_TYPE   = (rv64I_opcode == 7'b0100011);
wire rv64I_R_TYPE   = (opcode_R_NORMAL | opcode_R_W_INST);   
wire rv64I_U_TYPE 	= (opcode_U_lui | opcode_U_auipc);
wire rv64I_I_TYPE   = (opcode_I_Logic_Operator | opcode_I_LOAD | opcode_I_CSR | opcode_I_JALR | opcode_I_W_INST);

wire rv64I_I_Logic_Operator     =   opcode_I_Logic_Operator;
wire rv64I_I_LOAD				= 	opcode_I_LOAD;
wire rv64I_I_JALR               =   opcode_I_JALR;
wire rv64I_I_CSR				= 	opcode_I_CSR;
wire rv64I_I_W_INST				= 	opcode_I_W_INST;
wire rv64I_R_W_INST				= 	opcode_R_W_INST;

//judge type
wire opcode_U_lui    = (rv64I_opcode == 7'b0110111);
wire opcode_U_auipc  = (rv64I_opcode == 7'b0010111);

wire opcode_I_Logic_Operator 	= (rv64I_opcode == 7'b0010011);
wire opcode_I_LOAD  			= (rv64I_opcode == 7'b0000011);
wire opcode_I_CSR   			= (rv64I_opcode == 7'b1110011);
wire opcode_I_JALR  			= (rv64I_opcode == 7'b1100111);
wire opcode_I_W_INST            = (rv64I_opcode == 7'b0011011);

wire opcode_R_NORMAL            = (rv64I_opcode == 7'b0110011);
wire opcode_R_W_INST            = (rv64I_opcode == 7'b0111011);

	//------------------------func3-----------------------------------------------------------------
wire func3_000                  = (rv64I_func3 == 3'b000);
wire func3_001                  = (rv64I_func3 == 3'b001);
wire func3_010                  = (rv64I_func3 == 3'b010);
wire func3_011                  = (rv64I_func3 == 3'b011);
wire func3_100                  = (rv64I_func3 == 3'b100);
wire func3_101                  = (rv64I_func3 == 3'b101);
wire func3_110                  = (rv64I_func3 == 3'b110);
wire func3_111                  = (rv64I_func3 == 3'b111);

		//B_type
wire func3_B_beq                = func3_000;
wire func3_B_bne                = func3_001;
wire func3_B_blt                = func3_100;
wire func3_B_bge                = func3_101;
wire func3_B_bltu               = func3_110;
wire func3_B_bgeu               = func3_111;

		//S_type
wire func3_S_sb             	= func3_000;
wire func3_S_sh             	= func3_001;
wire func3_S_sw             	= func3_010;
wire func3_S_sd                 = func3_011;

		//I_type
wire func3_I_addi               = func3_000;
wire func3_I_slli               = func3_001;
wire func3_I_slti               = func3_010;
wire func3_I_sltiu              = func3_011;
wire func3_I_xori               = func3_100;
wire func3_I_srl_sra            = func3_101;
wire func3_I_ori                = func3_110;
wire func3_I_andi               = func3_111;

wire func3_I_lb                 = func3_000;
wire func3_I_lh                 = func3_001;
wire func3_I_lw                 = func3_010;
wire func3_I_ld                 = func3_011;
wire func3_I_lbu                = func3_100;
wire func3_I_lhu                = func3_101;
wire func3_I_lwu                = func3_110;

wire func3_I_addiw              = func3_000;
wire func3_I_slliw              = func3_001;
wire func3_I_srliw_or_sraiw     = func3_101; 

wire func3_I_csrrw              = func3_001;
wire func3_I_csrrs              = func3_010;

		//R_TYPE
wire func3_R_add_sub            = func3_000;
wire func3_R_sll                = func3_001;
wire func3_R_slt                = func3_010;
wire func3_R_sltu               = func3_011;
wire func3_R_xor                = func3_100;
wire func3_R_srl_sra            = func3_101;
wire func3_R_or                 = func3_110;
wire func3_R_and                = func3_111;

wire func3_R_addw_or_subw       = func3_000;
wire func3_R_sllw               = func3_001;
wire func3_R_srlw_or_sraw       = func3_101;

	//-----------------------------------func7-------------------------------
wire func7_0000000              = (rv64I_func7 == 7'b0000000);
wire func7_0100000              = (rv64I_func7 == 7'b0100000);

		//R_TYPE
wire func7_sra                  = func7_0100000;
wire func7_srl                  = func7_0000000;
wire func7_add                  = func7_0000000;
wire func7_sub                  = func7_0100000;
wire func7_srlw                 = func7_0000000;
wire func7_addw                 = func7_0100000;
wire func7_subw                 = func7_0100000;
wire func7_sraw					= func7_0100000;
	//-------------------------------func_special-----------------------------
wire func_special_000000        = (rv64I_I_special == 6'b000000 );
wire func_special_010000        = (rv64I_I_special == 6'b010000 );

//I_TYPE
wire func_I_srai                = func_special_010000;
wire func_I_srli                = func_special_000000;
wire func_I_sraiw               = func_special_010000;
wire func_I_srliw               = func_special_000000;
wire func_I_slliw               = func_special_000000;

	//-----------------------------------rv64I-instr-----------------------------------
		//U_TYPE
wire rv64I_U_lui    			= (opcode_U_lui);
wire rv64I_U_auipc  			= (opcode_U_auipc);

		//I_TYPE
wire rv64I_I_addi  				= (opcode_I_Logic_Operator & func3_I_addi                    );
wire rv64I_I_slli  				= (opcode_I_Logic_Operator & func3_I_slli                    );
wire rv64I_I_slti 				= (opcode_I_Logic_Operator & func3_I_slti                    );
wire rv64I_I_sltiu 				= (opcode_I_Logic_Operator & func3_I_sltiu                   ); 
wire rv64I_I_xori  				= (opcode_I_Logic_Operator & func3_I_xori                    );
wire rv64I_I_srli  				= (opcode_I_Logic_Operator & func3_I_srl_sra & func_I_srli   );
wire rv64I_I_srai  				= (opcode_I_Logic_Operator & func3_I_srl_sra & func_I_srai   ); 
wire rv64I_I_ori   				= (opcode_I_Logic_Operator & func3_I_ori                     );
wire rv64I_I_andi  				= (opcode_I_Logic_Operator & func3_I_andi                    );

wire rv64I_I_lb    				= (opcode_I_LOAD & func3_I_lb);
wire rv64I_I_lh    				= (opcode_I_LOAD & func3_I_lh);
wire rv64I_I_lw    				= (opcode_I_LOAD & func3_I_lw);
wire rv64I_I_ld                 = (opcode_I_LOAD & func3_I_ld);
wire rv64I_I_lwu   				= (opcode_I_LOAD & func3_I_lwu);
wire rv64I_I_lbu   				= (opcode_I_LOAD & func3_I_lbu);
wire rv64I_I_lhu   				= (opcode_I_LOAD & func3_I_lhu);

wire rv64I_I_sraiw              = (opcode_I_W_INST & func3_I_srl_sra & func_I_sraiw   	);
wire rv64I_I_srliw              = (opcode_I_W_INST & func3_I_srl_sra & func_I_srliw   	);
wire rv64I_I_slliw              = (opcode_I_W_INST & func3_I_slliw   & func_I_slliw   	);
wire rv64I_I_addiw              = (opcode_I_W_INST & func3_I_addiw                    	);


wire rv64I_I_jalr  				= (rv64I_I_JALR);

wire rv64I_ecall	    		= (rv64I_instr == 32'h00000073);
wire rv64I_mret  	    		= (rv64I_instr == 32'h30200073);
wire rv64I_I_csrrw 			    = (rv64I_I_TYPE & func3_I_csrrw); //I型指令
wire rv64I_I_csrrs 			    = (rv64I_I_TYPE & func3_I_csrrw); //I型指令

//B_TYPE
wire rv64I_B_beq   				= (rv64I_B_TYPE & func3_B_beq);
wire rv64I_B_bne   				= (rv64I_B_TYPE & func3_B_bne);
wire rv64I_B_blt   				= (rv64I_B_TYPE & func3_B_blt);
wire rv64I_B_bge  				= (rv64I_B_TYPE & func3_B_bge);
wire rv64I_B_bltu  				= (rv64I_B_TYPE & func3_B_bltu);
wire rv64I_B_bgeu  				= (rv64I_B_TYPE & func3_B_bgeu);

//R_TYPE
wire rv64I_R_add    			= (opcode_R_NORMAL & func3_R_add_sub & func7_add   	);
wire rv64I_R_sub    			= (opcode_R_NORMAL & func3_R_add_sub & func7_sub    ); 
wire rv64I_R_sll    			= (opcode_R_NORMAL & func3_R_sll 	                );
wire rv64I_R_slt    			= (opcode_R_NORMAL & func3_R_slt 		            );
wire rv64I_R_sltu   			= (opcode_R_NORMAL & func3_R_sltu 	                );
wire rv64I_R_xor    			= (opcode_R_NORMAL & func3_R_xor 	 		        );
wire rv64I_R_srl    			= (opcode_R_NORMAL & func3_R_srl_sra & func7_srl   	);
wire rv64I_R_sra    			= (opcode_R_NORMAL & func3_R_srl_sra & func7_sra   	); 
wire rv64I_R_or     			= (opcode_R_NORMAL & func3_R_or		            	);
wire rv64I_R_and    			= (opcode_R_NORMAL & func3_R_and 	 	            );

wire rv64I_R_addw               = (opcode_R_W_INST & func3_R_addw_or_subw & func7_addw   );
wire rv64I_R_subw               = (opcode_R_W_INST & func3_R_addw_or_subw & func7_subw   );
wire rv64I_R_sllw               = (opcode_R_W_INST & func3_R_sllw                        );
wire rv64I_R_srlw               = (opcode_R_W_INST & func3_R_srlw_or_sraw & func7_srlw   ); 
wire rv64I_R_sraw               = (opcode_R_W_INST & func3_R_srlw_or_sraw & func7_sraw   ); 

		//S_TYPE
wire rv64I_S_sb    				= (rv64I_S_TYPE & func3_S_sb);
wire rv64I_S_sh    				= (rv64I_S_TYPE & func3_S_sh);
wire rv64I_S_sw    				= (rv64I_S_TYPE & func3_S_sw);
wire rv64I_S_sd                 = (rv64I_S_TYPE & func3_S_sd);
		//J_TYPE
wire rv64I_J_jal   				= (rv64I_J_TYPE);

	//--------------------------------------imm---------------------------------------------
wire [63:0] imm_SHAMT = { 58'd0, rv64I_instr[25:20]};
wire [63:0] imm_I_TYPE 	= { {52{rv64I_instr[31]}}, rv64I_instr[31:20] };		
wire [63:0] imm_S_TYPE 	= { {52{rv64I_instr[31]}}, rv64I_instr[31:25], rv64I_instr[11:7] };	
wire [63:0] imm_B_TYPE 	= { {51{rv64I_instr[31]}}, rv64I_instr[31],    rv64I_instr[7],      rv64I_instr[30:25], rv64I_instr[11:8 ], 1'b0};
wire [63:0] imm_J_TYPE 	= { {43{rv64I_instr[31]}}, rv64I_instr[31],    rv64I_instr[19:12],  rv64I_instr[20],    rv64I_instr[30:21], 1'b0};	
wire [63:0] imm_U_TYPE 	= { {32{rv64I_instr[31]}}, rv64I_instr[31:12], 12'd0};		
wire [63:0] imm_R_TYPE 	=   64'd0;	
	//-------------------------------------read-regfile--------------------------------------------
wire [63:0] regfile_o_valA;
wire [63:0] regfile_o_valB;

regfile u_regfile (
	.clk					(clk),
	.rst					(rst),
	//write back
	.write_back_i_reg_wen	(write_back_i_wb_reg_wen),
	.write_back_i_reg_rd	(write_back_i_wb_rd),
	.write_back_i_reg_data	(write_back_i_wb_valD),
	//read reg
	.decode_i_read_rs1		(rv64I_rs1),
	.decode_i_read_rs2		(rv64I_rs2),
    .regfile_o_valA         (regfile_o_valA           	),
    .regfile_o_valB         (regfile_o_valB           	)
);

assign decode_o_rs1 = (rv64I_U_TYPE | rv64I_J_TYPE) ? 5'd0 :
   					  (rv64I_I_TYPE | rv64I_B_TYPE | rv64I_S_TYPE | rv64I_R_TYPE) ? rv64I_rs1  : 5'd0;

assign decode_o_rs2 = (rv64I_I_TYPE | rv64I_U_TYPE | rv64I_J_TYPE) ? 5'd0:
					  (rv64I_B_TYPE | rv64I_S_TYPE | rv64I_R_TYPE) ? rv64I_rs2 : 5'd0;

	//-------------------------------------------output-------------------------------------------------------------------------------
assign decode_o_load_type = (rv64I_I_LOAD && func3_I_lb	) ? `lb  :
							(rv64I_I_LOAD && func3_I_lbu) ? `lbu :
							(rv64I_I_LOAD && func3_I_lh	) ?	`lh  :
							(rv64I_I_LOAD && func3_I_lhu) ?	`lhu :
							(rv64I_I_LOAD && func3_I_lw	) ?	`lw  :
							(rv64I_I_LOAD && func3_I_lwu) ?	`lwu :
							(rv64I_I_LOAD && func3_I_ld	) ?	`ld  : `mem_no_read;

assign decode_o_valA = (decode_o_rs1  == regE_i_wb_rd && regE_i_wb_rd != 5'd0 &&  regE_i_wb_reg_wen) ? execute_i_valE : //在EX阶段已经计算出结果，没有内存访问，结果还未来得及写回。 
						   (decode_o_rs1  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 &&  regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valM) ? memory_i_valM 	: //在MEM阶段从内存中读取数据，数据还没写回寄存器。
						   (decode_o_rs1  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 &&  regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valE) ? regM_i_valE 		: //有些指令并不访问内存，访存阶段只是经过而不改变数据。
						   (decode_o_rs1  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valE) ? regW_i_valE  		: //写回 同上面逻辑
						   (decode_o_rs1  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valM) ? regW_i_valM  		: //写回 同上面逻辑
						   (decode_o_rs1  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valP) ? regW_i_pc + 64'd4 : regfile_o_valA; 
		//可能取指有pc，imm,rs1---------当数据冲突
assign decode_o_valB = (decode_o_rs2  == regE_i_wb_rd && regE_i_wb_rd != 5'd0 && regE_i_wb_reg_wen) ? execute_i_valE : 
						   (decode_o_rs2  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 && regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valM) ? memory_i_valM 	 	: 
						   (decode_o_rs2  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 && regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valE) ? regM_i_valE  		:
						   (decode_o_rs2  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 && regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valE) ? regW_i_valE  		: 
						   (decode_o_rs2  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 && regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valM) ? regW_i_valM  		: 
						   (decode_o_rs2  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valP) ? regW_i_pc + 64'd4 : regfile_o_valB; 

assign decode_o_imm      = (rv64I_R_TYPE) ? imm_R_TYPE	:
						   (rv64I_U_TYPE) ? imm_U_TYPE	: 
 					  	   (rv64I_I_TYPE) ? (rv64I_I_slli | rv64I_I_srli | rv64I_I_srai | rv64I_I_slli | rv64I_I_sraiw) ? imm_SHAMT : imm_I_TYPE :
						   (rv64I_S_TYPE) ? imm_S_TYPE	: 
	 					   (rv64I_B_TYPE) ? imm_B_TYPE	:
						   (rv64I_J_TYPE) ? imm_J_TYPE	:  64'd0;


assign  decode_o_alu_valA_sel   =   (rv64I_I_TYPE | rv64I_R_TYPE  | rv64I_S_TYPE ) ?  `alu_valA_sel_valA  : 
					  				(rv64I_J_TYPE | rv64I_B_TYPE  | rv64I_U_auipc) ?  `alu_valA_sel_pc    : 
									(rv64I_U_lui)                                  ?  `alu_valA_sel_zero  : `alu_valA_sel_zero;    

assign  decode_o_alu_valB_sel   =   (rv64I_R_TYPE) ? `alu_valB_sel_valB:
				  					(rv64I_I_TYPE | rv64I_S_TYPE | rv64I_B_TYPE | rv64I_U_TYPE | rv64I_J_TYPE) ? `alu_valB_sel_imm : `alu_valB_sel_valB;

assign  decode_o_alu_func_sel   = 	(rv64I_R_add  | rv64I_I_addi  					)  ? `alu_func_add:
								    (rv64I_R_sub  | rv64I_R_subw  					)  ? `alu_func_sub:
								    (rv64I_R_sll  | rv64I_I_slli  | rv64I_R_sllw	| rv64I_I_slliw)  ? `alu_func_sll:
								    (rv64I_R_slt  | rv64I_I_slti  					)  ? `alu_func_slt:
							 	    (rv64I_R_sltu | rv64I_I_sltiu 					)  ? `alu_func_sltu:
								    (rv64I_R_xor  | rv64I_I_xori  					)  ? `alu_func_xor:
									(rv64I_R_srl  | rv64I_I_srli  | rv64I_I_srliw	| rv64I_R_srlw )  ? `alu_func_srl:
							   		(rv64I_R_sra  | rv64I_I_srai  | rv64I_I_sraiw	| rv64I_R_sraw )  ? `alu_func_sra:
								    (rv64I_R_or   | rv64I_I_ori   					)  ? `alu_func_or  :
							    	(rv64I_R_and  | rv64I_I_andi  					)  ? `alu_func_and : `alu_func_add;

assign decode_o_alu_W_instr		=	(rv64I_I_W_INST| rv64I_R_W_INST) ? `alu_func_out_cut : `alu_func_out_normal ;

//memory
	//read enable
assign decode_o_mem_ren	   		= (rv64I_I_LOAD) ? `mem_read_allow : `mem_read_stop;

	//wirte
assign decode_o_mem_wen 		= (rv64I_S_TYPE) ? `mem_write_allow : `mem_write_stop;

assign decode_o_wb_reg_wen 		= (rv64I_I_TYPE | rv64I_R_TYPE | rv64I_U_TYPE | rv64I_J_TYPE) ? `reg_wen_w : `reg_wen_no_w;
assign decode_o_wb_rd   		=  rv64I_rd;
assign  decode_o_wb_valD_sel 	=   (rv64I_R_TYPE | rv64I_I_Logic_Operator | rv64I_U_TYPE | opcode_I_W_INST)	? `wb_valD_sel_valE :
		    					 	(rv64I_I_LOAD)                  						    				? `wb_valD_sel_valM :
									(rv64I_I_jalr   | rv64I_J_TYPE)               			    				? `wb_valD_sel_valP : `wb_valD_sel_valM;

assign decode_o_need_jump  		= (rv64I_B_beq  && ($signed(decode_o_valA)  ==  $signed(decode_o_valB)))   ? 1'b1:
							  	  (rv64I_B_bne  && ($signed(decode_o_valA)  !=  $signed(decode_o_valB)))   ? 1'b1:
							  	  (rv64I_B_blt  && ($signed(decode_o_valA)  <   $signed( decode_o_valB)))  ? 1'b1:
							  	  (rv64I_B_bge  && ($signed(decode_o_valA)   >= $signed(decode_o_valB)))   ? 1'b1:
							  	  (rv64I_B_bltu && ($unsigned(decode_o_valA) <  $unsigned(decode_o_valB))) ? 1'b1:
							  	  (rv64I_B_bgeu && ($unsigned(decode_o_valA) >= $unsigned(decode_o_valB))) ? 1'b1:
							  	  (rv64I_J_jal | rv64I_I_jalr) ? 1'b1 : 1'b0;

assign decode_o_is_jalr 		=  rv64I_I_jalr;		
assign decode_o_mem_wmask 		= (rv64I_S_TYPE && rv64I_S_sb) ?	`one_byte	:
							  	  (rv64I_S_TYPE && rv64I_S_sh) ?	`two_byte	:
							  	  (rv64I_S_TYPE && rv64I_S_sw) ?	`four_byte 	:
							  	  (rv64I_S_TYPE && rv64I_S_sd) ?	`eight_byte : `zero_byte;

endmodule