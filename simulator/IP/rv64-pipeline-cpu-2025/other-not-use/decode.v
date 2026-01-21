// module decode(
// 	//
// 	input          clk,
// 	input          rst,
// 	input  [31:0]  inst_i,
	
// 	//from write back stage
// 	input          wb_rd_write_en_i,
// 	input  [4 :0]  wb_rd_id_i,
// 	input  [31:0]  wb_rd_write_data_i,         
	
// 	//rs1 rs2 rd 
// 	output [ 4:0]  decode_rs1_id_o,
// 	output [ 4:0]  decode_rs2_id_o,
// 	output [ 4:0]  decode_rd_id_o,
// 	output [11:0]  decode_csr_id_o,
	
// 	//to execute
// 	output [ 9:0]  decode_opcode_info_o,
// 	output [ 9:0]  decode_alu_info_o,
// 	output [ 5:0]  decode_branch_info_o,
// 	output [ 7:0]  decode_load_store_info_o,
// 	output [ 5:0]  decode_csr_info_o,
	
// 	// read data from regfile
// 	output [31:0]  regfile_rs1_rdata_o,
// 	output [31:0]  regfile_rs2_rdata_o,
	
// 	//to write back stage
// 	output         decode_rd_write_en_o,
// 	output [31:0]  decode_imm_o
        
// 	//for moniter
// );

// //这部分已经搞懂
// wire [6:0] opcode = inst_i[ 6: 0];
// wire [4:0] rd     = inst_i[11: 7];
// wire [2:0] func3  = inst_i[14:12];
// wire [4:0] rs1    = inst_i[19:15];
// wire [4:0] rs2    = inst_i[24:20];
// wire [6:0] func7  = inst_i[31:25];

// //
// assign decode_rs1_id_o = rs1;
// assign decode_rs2_id_o = rs2;
// assign decode_rd_id_o  = rd;
// assign decode_csr_id_o = inst_i[31:20];

// wire inst_jal       	= (opcode == 7'b11011_11); 	//opcode=11011    	jal		
// wire inst_jalr      	= (opcode == 7'b11001_11); 	//opcode=11001    	jalr	
// wire inst_lui       	= (opcode == 7'b01101_11); 	//opcode=01101    	lui    
// wire inst_auipc     	= (opcode == 7'b00101_11); 	//opcode=00101    	auipc  
// wire inst_alu_reg_imm   = (opcode == 7'b00100_11); 	//opcode=00100    	ori  andi slli  addi slti sltiu xori srli  srai  
// wire inst_alu_reg_immw  = (opcode == 7'b00110_11);  //opcode=00110		addiw slliw srliw sraiw 
// wire inst_alu_reg_reg   = (opcode == 7'b01100_11); 	//opcode=01100    	add  sub  sll  slt  sltu xor srl   sra  or and mul mulh mulhsu mulhu div  divu  rem  remu 
// wire inst_alu_reg_regw  = (opcode == 7'b01110_11); 	//opcode=01110    	addw subw sllw               srlw  sraw        mulw                  divw divuw remw remuw
// wire inst_branch   	 	= (opcode == 7'b11000_11); 	//opcode=11000 	 	beq, bne, blt, bge bltu bgeu
// wire inst_load      	= (opcode == 7'b00000_11); 	//opcode=00000		lb	lh	lw	lbu	lhu lwu ld
// wire inst_store     	= (opcode == 7'b01000_11);	//opcode=01000		sb,sh,sw sd
// wire inst_system    	= (opcode == 7'b11100_11);	//opcode=11100		csrrw  csrrs  csrrc  uret sret  mret
// 													//                  csrrwi csrrsi csrrci ecall  ebreak   wfi sfence.vma 
// wire inst_fence     	= (opcode == 7'b00011_11);  //opcode=00011      fence fence.i
// wire inst_amo			= (opcode == 7'b01011_11);	//opcode=01011		lrw scw amoswapw amoaddw amoxorw amoandw amoorw amominw amomaxw amominuw amomaxuw
// 													//					lrd scd amoswapd amoaddd amoxord amoandd amoord amomind amomaxd amominud amomaxuw


// //alu_reg_imm
// wire inst_addi  = inst_alu_reg_imm   & (func3 == 3'b000);
// wire inst_slli  = inst_alu_reg_imm   & (func3 == 3'b001)  & (func7 == 7'b0000000);
// wire inst_slti  = inst_alu_reg_imm   & (func3 == 3'b010);
// wire inst_sltiu = inst_alu_reg_imm   & (func3 == 3'b011);
// wire inst_xori  = inst_alu_reg_imm   & (func3 == 3'b100);
// wire inst_srli  = inst_alu_reg_imm   & (func3 == 3'b101)  & (func7 == 7'b0000000);
// wire inst_srai  = inst_alu_reg_imm   & (func3 == 3'b101)  & (func7 == 7'b0100000);
// wire inst_ori   = inst_alu_reg_imm   & (func3 == 3'b110);
// wire inst_andi  = inst_alu_reg_imm   & (func3 == 3'b111);
// //alu_reg_immw
// wire inst_addiw = inst_alu_reg_immw  & (func3 == 3'b000)
// wire inst_slliw = inst_alu_reg_immw  & (func3 == 3'b001)
// wire inst_srliw = inst_alu_reg_immw  & (func3 == 3'b101)  & (func7 == 7'b0100000);
// wire inst_sraiw = inst_alu_reg_immw	 & (func3 == 3'b101)  & (func7 == 7'b0100000);
// //alu_reg_reg  加减法
// wire inst_add    = inst_alu_reg_reg   & (func3 == 3'b000) & (func7 == 7'b0000000);
// wire inst_sub    = inst_alu_reg_reg   & (func3 == 3'b000) & (func7 == 7'b0100000);
// wire inst_sll    = inst_alu_reg_reg   & (func3 == 3'b001) & (func7 == 7'b0000000);
// wire inst_slt    = inst_alu_reg_reg   & (func3 == 3'b010) & (func7 == 7'b0000000);
// wire inst_sltu   = inst_alu_reg_reg   & (func3 == 3'b011) & (func7 == 7'b0000000);
// wire inst_xor    = inst_alu_reg_reg   & (func3 == 3'b100) & (func7 == 7'b0000000);
// wire inst_srl    = inst_alu_reg_reg   & (func3 == 3'b101) & (func7 == 7'b0000000);
// wire inst_sra    = inst_alu_reg_reg   & (func3 == 3'b101) & (func7 == 7'b0100000);
// wire inst_or     = inst_alu_reg_reg   & (func3 == 3'b110) & (func7 == 7'b0000000);
// wire inst_and    = inst_alu_reg_reg   & (func3 == 3'b111) & (func7 == 7'b0000000);
// //alu_reg_reg 乘除法
// wire inst_mul    = inst_alu_reg_reg   & (func3 == 3'b000) & (func7 == 7'b0000001);
// wire inst_mulh   = inst_alu_reg_reg   & (func3 == 3'b001) & (func7 == 7'b0000001);
// wire inst_mulhsu = inst_alu_reg_reg   & (func3 == 3'b010) & (func7 == 7'b0100001);
// wire inst_mulhu  = inst_alu_reg_reg   & (func3 == 3'b011) & (func7 == 7'b0000001);
// wire inst_div    = inst_alu_reg_reg   & (func3 == 3'b100) & (func7 == 7'b0000001);
// wire inst_divu   = inst_alu_reg_reg   & (func3 == 3'b101) & (func7 == 7'b0000001);
// wire inst_rem    = inst_alu_reg_reg   & (func3 == 3'b110) & (func7 == 7'b0000001);
// wire inst_remu   = inst_alu_reg_reg   & (func3 == 3'b111) & (func7 == 7'b0000001);

// //alu_reg_regw
// wire inst_addw  =  inst_alu_reg_regw  & (func3 == 3'b000) & (func7 == 7'b0000000);
// wire inst_subw  =  inst_alu_reg_regw  & (func3 == 3'b000) & (func7 == 7'b0100000);
// wire inst_sllw	=  inst_alu_reg_regw  & (func3 == 3'b001) & (func7 == 7'b0000000);
// wire inst_srlw  =  inst_alu_reg_regw  & (func3 == 3'b101) & (func7 == 7'b0000000);
// wire inst_sraw  =  inst_alu_reg_regw  & (func3 == 3'b101) & (func7 == 7'b0100000);
// //alu_reg_regw乘除法
// wire inst_mulw	=  inst_alu_reg_regw  & (func3 == 3'b000) & (func7 == 7'b0000001);
// wire inst_divw  =  inst_alu_reg_regw  & (func3 == 3'b100) & (func7 == 7'b0000001);
// wire inst_divuw =  inst_alu_reg_regw  	& (func3 == 3'b101) & (func7 == 7'b0100001);
// wire inst_remw	=  inst_alu_reg_regw  	& (func3 == 3'b110) & (func7 == 7'b0000001);
// wire inst_remuw =  inst_alu_reg_regw  	& (func3 == 3'b111) & (func7 == 7'b0000001);

// //brach
// wire inst_beq   =  inst_branch 		  	& (func3 == 3'b000);
// wire inst_bne   =  inst_branch 		  	& (func3 == 3'b001);
// wire inst_blt   =  inst_branch 		  	& (func3 == 3'b100);
// wire inst_bge   =  inst_branch 		  	& (func3 == 3'b101);
// wire inst_bltu  =  inst_branch 		 	& (func3 == 3'b110);
// wire inst_bgeu  =  inst_branch 		  	& (func3 == 3'b111);

// //load instruction
// wire inst_lb  			= inst_load  	& (func3 == 3'b000);
// wire inst_lh  			= inst_load  	& (func3 == 3'b001);
// wire inst_lw  			= inst_load  	& (func3 == 3'b010);
// wire inst_ld  			= inst_load  	& (func3 == 3'b011);
// wire inst_lbu 			= inst_load  	& (func3 == 3'b100);
// wire inst_lhu 			= inst_load  	& (func3 == 3'b101);
// wire inst_lwu 			= inst_load  	& (func3 == 3'b110);

// //store
// wire inst_sb  			= inst_store 	& (func3 == 3'b000);
// wire inst_sh  			= inst_store 	& (func3 == 3'b001);
// wire inst_sw  			= inst_store 	& (func3 == 3'b010);
// wire inst_sd  			= inst_store 	& (func3 == 3'b011);

// //system
// wire inst_ecall  		= inst_system 	& 	inst_i == 32'b00000_00_00000_00000_000_00000_11100_11;
// wire inst_ebreak 		= inst_system 	& 	inst_i == 32'b00000_00_00001_00000_000_00000_11100_11;
// wire inst_uret   		= inst_system 	& 	inst_i == 32'b00000_00_00010_00000_000_00000_11100_11;
// wire inst_sret   		= inst_system 	& 	inst_i == 32'b00010_00_00010_00000_000_00000_11100_11;
// wire inst_mret          = inst_system 	& 	inst_i == 32'b00110_00_00010_00000_000_00000_11100_11;
// wire inst_wfi			= inst_system 	& 	inst_i == 32'b00010_00_00101_00000_000_00000_11100_11;
// wire inst_sfence_vma 	= inst_system 	& 	(func3 == 3'b000) & (inst_i[31:25] == 7'b0001001);
// wire inst_csrrw  		= inst_system 	& 	(func3 == 3'b001);
// wire inst_csrrs  		= inst_system 	& 	(func3 == 3'b010);
// wire inst_csrrc  		= inst_system 	& 	(func3 == 3'b011);
// wire inst_csrrwi 		= inst_system 	& 	(func3 == 3'b101);
// wire inst_csrrsi 		= inst_system 	& 	(func3 == 3'b110);
// wire inst_csrrci 		= inst_system 	& 	(func3 == 3'b111);
// //fence
// wire inst_fence         = inst_fence  	& 	inst_i[31:28] ==  4'b000 & inst_i[19:0] == 20'b00000_000_00000_00011_11; 
// wire inst_fence_i		= inst_fence  	& 	inst_i[31: 0] == 32'b00000_00_00000_00000_001_00000_00011_11;

// //amo	
// wire inst_lrw			= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b00010);
// wire inst_scw			= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b00011);
// wire inst_amoswapw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b00001);
// wire inst_amoaddw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b00000);
// wire inst_amoxorw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b00100);
// wire inst_amoandw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b01100);
// wire inst_amoorw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b01000);
// wire inst_amominw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b10000);
// wire inst_amomaxw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b10100);
// wire inst_amominuw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b11000);
// wire inst_amomaxuw		= inst_amo		&	(inst_i[14:12]==3'b010)		&	(inst_i[31:27] == 5'b11100);

// wire inst_lrd			= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b00100);
// wire inst_scd			= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b00011);
// wire inst_amoswapd		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b00001);
// wire inst_amoaddd		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b00000);
// wire inst_amoxord		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b00100);
// wire inst_amoandd		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b01100);
// wire inst_amoord		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b01000);
// wire inst_amomind		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b10000);
// wire inst_amomaxd		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b10100);
// wire inst_amominud		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b11000);
// wire inst_amomaxud		= inst_amo		&	(inst_i[14:12]==3'b011)		&	(inst_i[31:27] == 5'b11100);



// //这个是opcode
// assign decode_opcode_info_o = {
// 	inst_jal,			//12
// 	inst_jalr,			//11
// 	inst_lui,			//10
// 	inst_auipc,			//9
// 	inst_alu_reg_imm,	//8
// 	inst_alu_reg_immw,	//7
// 	inst_alu_reg_reg,	//6
// 	inst_alu_reg_regw,	//5
// 	inst_branch,		//4
// 	inst_load,			//3
// 	inst_store,  		//2
// 	inst_system, 		//1
// 	inst_fence  		//0
// };

// //这个我还不懂
// assign decode_alu_info_o = {
// 	(inst_add  | inst_addi ),  // 14
// 	(inst_sub              ),  // 13
// 	(inst_sll  | inst_slli ),  // 12
// 	(inst_slt  | inst_slti ),  // 11
// 	(inst_sltu | inst_sltiu),  // 10
// 	(inst_xor  | inst_xori ),  // 9
// 	(inst_srl  | inst_srli ),  // 8
// 	(inst_sra  | inst_srai ),  // 7
// 	(inst_or   | inst_ori  ),  // 6
// 	(inst_and  | inst_andi ),  // 5   	
//     (inst_addw			   ),  // 4
// 	(inst_subw			   ),  // 3
// 	(inst_sllw			   ),  // 2
// 	(inst_srlw			   ),  // 1
// 	(inst_sraw             )   // 0
// };
// assign decode_mul_info_o = {
// 	(inst_mul ),
//     (inst_mulw),
// 	(inst_mulh),
// 	(inst_mulhsu),
// 	(inst_mulhu),
// 	(inst_div),
// 	(inst_divu),
// 	(inst_rem),
// 	(inst_remu)
// };


// assign decode_branch_info_o = {
// 	inst_beq,  // 5
// 	inst_bne,  // 4
// 	inst_blt,  // 3
// 	inst_bge,  // 2
// 	inst_bltu, // 1
// 	inst_bgeu  // 0						
// };

// assign decode_load_store_info_o = {
// 	inst_lb,  // 7 
// 	inst_lh,  // 6
// 	inst_lw,  // 5
// 	inst_ld,  // 
// 	inst_lbu, // 4
// 	inst_lhu, // 3
// 	inst_lwu,

// 	inst_sb,  // 2
// 	inst_sh,  // 1
// 	inst_sw,  // 0
// 	inst_sd								
// };

// assign decode_system_info_o = {
// 	inst_ecall,
// 	inst_ebreak,
// 	inst_uret,
// 	inst_sret,
// 	inst_wfi,
// 	inst_sfence_vma,
// 	inst_csrrw,
// 	inst_csrrs,
// 	inst_csrrc,
// 	inst_csrrwi,
// 	inst_csrrsi,
// 	inst_csrrci
// }
// assign decode_amo_info_o ={
// 	inst_lrw,
// 	inst_scw,
// 	inst_amoswapw,
// 	inst_amoaddw,
// 	inst_amoxorw,
// 	inst_amoandw,
// 	inst_amoorw,
// 	inst_amominw,
// 	inst_amomaxw,
// 	inst_amominuw,
// 	inst_amomaxuw,
// 	inst_amolrd,
// 	inst_amoscd,
// 	inst_amoswapd,
// 	inst_amoaddd,
// 	inst_amoxord,
// 	inst_amoandd,
// 	inst_amoord,
// 	inst_amomind,
// 	inst_amomaxd,
// 	inst_amominud,
// 	inst_amomaxud
// }



// //下面的信息都还没有搞懂
// wire inst_need_rs1 = (~inst_lui)    	& (~inst_auipc)  & (~inst_jal)    &
//   					 (~inst_csrrwi) 	& (~inst_csrrsi) & (~inst_csrrci) &
// 		    		 (~inst_ecall)  	& (~inst_ebreak) & (~inst_mret)   ;
// wire inst_need_rs2 = ( inst_alu_reg_reg | inst_branch | inst_store);
// wire inst_need_rd  = (~inst_ecall)  	& (~inst_ebreak) & (~inst_mret) &
//                      (~inst_branch) 	& (~inst_store);
// wire inst_need_csr =   inst_csrrw  | inst_csrrs  | inst_csrrc |
//                        inst_csrrwi | inst_csrrsi | inst_csrrci;
// // to write back stage
// assign decode_rd_write_en_o  = inst_need_rd;

// //assign decode_csr_wen_o = inst_need_csr;	


// wire [31:0] inst_i_imm = { {20{inst_i[31]}}, inst_i[31:20] };		
// wire [31:0] inst_s_imm = { {20{inst_i[31]}}, inst_i[31:25], inst_i[11:7] };	
// wire [31:0] inst_b_imm = { {19{inst_i[31]}}, inst_i[31],    inst_i[7],      inst_i[30:25], inst_i[11:8 ], 1'b0};
// wire [31:0] inst_j_imm = { {11{inst_i[31]}}, inst_i[31],    inst_i[19:12],  inst_i[20],    inst_i[30:21], 1'b0};	
// wire [31:0] inst_u_imm = { inst_i[31:12], 12'b0};			 

// wire inst_imm_sel_i = inst_alu_imm | inst_load | inst_jalr;
// wire inst_imm_sel_s = inst_store;
// wire inst_imm_sel_b = inst_branch;
// wire inst_imm_sel_j = inst_jal;
// wire inst_imm_sel_u = inst_lui | inst_auipc;

// wire [31:0] inst_imm = ({32{inst_imm_sel_i}} & inst_i_imm) |
    // 				       ({32{inst_imm_sel_s}} & inst_s_imm) |
    // 				       ({32{inst_imm_sel_b}} & inst_b_imm) |
    // 		   		       ({32{inst_imm_sel_j}} & inst_j_imm) |
    // 		               ({32{inst_imm_sel_u}} & inst_u_imm);
						 
// assign decode_imm_o = inst_imm;

// regfile regfile_module(
// 		.clk               (clk),
//         .rst               (rst),		
// 		// rs1 rs2 
// 		.rs1_id_i          (decode_rs1_id_o),
// 		.rs2_id_i          (decode_rs2_id_o),
		
// 		.rs1_rdata_o       (regfile_rs1_rdata_o),
// 		.rs2_rdata_o       (regfile_rs2_rdata_o),
		
// 		// write data to regfile
// 		.w_en              (wb_rd_write_en_i),
// 		.rd_id_i           (wb_rd_id_i),
// 		.rd_write_data_i   (wb_rd_write_data_i)

// 		//for minitor
// );


// endmodule





