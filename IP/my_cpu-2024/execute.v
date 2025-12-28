`include "define.v"
module execute(
	input wire [63:0]	regE_i_valA,
	input wire [63:0]	regE_i_valB,
	input wire [63:0]	regE_i_imm,
	input wire			regE_i_alu_W_instr,
	input wire [63:0]	regE_i_pc,

    input wire [1:0]	regE_i_alu_valA_sel,
    input wire [1:0]	regE_i_alu_valB_sel,
    input wire [3:0] 	regE_i_alu_func_sel,
	input wire  		regE_i_need_jump,
	input wire          regE_i_is_jalr,

	input wire  [63:0]	regE_i_pre_pc,
	output wire [63:0]	execute_o_pre_pc,
    output wire [63:0] 	execute_o_valE,
	output wire 		execute_o_need_jump
);

//judgment the operation
wire [63:0] alu_valA = 	(regE_i_alu_valA_sel == `alu_valA_sel_valA) ?  regE_i_valA : 
						(regE_i_alu_valA_sel == `alu_valA_sel_pc  )	?  regE_i_pc   : 
						(regE_i_alu_valA_sel == `alu_valA_sel_zero) ?  64'd0 	   : regE_i_valA;

wire [63:0] alu_valB = 	(regE_i_alu_valB_sel == `alu_valB_sel_valB) ?  regE_i_valB : 
						(regE_i_alu_valB_sel == `alu_valB_sel_imm)  ?  regE_i_imm  : regE_i_valB;

//expr
wire [63:0] tem_valE =	(regE_i_alu_func_sel == `alu_func_add 		)   ?  alu_valA + alu_valB							:
						(regE_i_alu_func_sel == `alu_func_sub 		)   ?  alu_valA - alu_valB							:
						(regE_i_alu_func_sel == `alu_func_sll 		)   ?  alu_valA << alu_valB		 					:
						(regE_i_alu_func_sel == `alu_func_slt  		)   ?  ($signed(alu_valA)   < $signed(alu_valB))   ? 64'd1 : 64'd0	:
						(regE_i_alu_func_sel == `alu_func_sltu		)   ?  ($unsigned(alu_valA) < $unsigned(alu_valB)) ? 64'd1 : 64'd0	:
						(regE_i_alu_func_sel == `alu_func_xor		)   ?  {alu_valA[63:0]	^ alu_valB[63:0]}						  	:
						(regE_i_alu_func_sel == `alu_func_srl		) 	?  {$unsigned(alu_valA) >>  alu_valB}			:
						(regE_i_alu_func_sel == `alu_func_sra		)  	?  {$signed(alu_valA)   >>> alu_valB}  			:
						(regE_i_alu_func_sel == `alu_func_or 		)  	?  alu_valA | alu_valB							:
						(regE_i_alu_func_sel == `alu_func_and 		)  	?  alu_valA & alu_valB							: 64'd0;

wire [31:0] tem_srilw = (regE_i_alu_W_instr && regE_i_alu_func_sel == `alu_func_srl) ?  {$unsigned(alu_valA[31:0]) >>  alu_valB}	: 
						(regE_i_alu_W_instr && regE_i_alu_func_sel == `alu_func_sll) ?  {alu_valA[31:0] <<  alu_valB[4:0]	}	: 32'b0;

assign execute_o_valE = (regE_i_alu_W_instr && regE_i_alu_func_sel == `alu_func_sll) ? {{32{tem_srilw[31]}}, tem_srilw[31:0]} 	:
						(regE_i_alu_W_instr && regE_i_alu_func_sel == `alu_func_srl) ? {{32{tem_srilw[31]}}, tem_srilw[31:0]} 	:	
						(regE_i_alu_W_instr ) ? {{32{tem_valE[31]}}, tem_valE[31:0]} 	: tem_valE;

assign execute_o_need_jump = regE_i_need_jump;
assign execute_o_pre_pc    = regE_i_is_jalr   ? (execute_o_valE  & ~1) :
						  	 regE_i_need_jump ?  execute_o_valE        : regE_i_pre_pc;

endmodule