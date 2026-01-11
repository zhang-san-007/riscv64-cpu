module top_cpu(
    input  wire clk,
    input  wire rst,

    output wire                 commit,
    output wire [31:0]          commit_instr,
    output wire [63:0]          commit_pc,
    output wire [63:0]          commit_next_pc,

    output wire [63:0]          commit_mem_rdata,
    output wire [63:0]          commit_mem_wdata,
    output wire [63:0]          commit_mem_addr,

    output wire [63:0]          cur_pc
);

// outports wire
wire [63:0] 	pc;
wire [63:0]  	fetch_o_next_pc;

pc u_pc(
	.clk                        	( clk                         ),
	.rst                        	( rst                         ),
	.regF_stall                 	( regF_stall                  ),
	.regF_bubble                	( regF_bubble                 ),
	.execute_i_branch_need_jump 	( execute_o_branch_need_jump  ),
	.execute_i_branch_next_pc   	( execute_o_branch_next_pc    ),
	.execute_i_mret_need_jump   	( execute_o_mret_need_jump    ),
	.execute_i_mret_next_pc     	( execute_o_mret_next_pc      ),
	.fetch_i_next_pc            	( fetch_o_next_pc             ),
	.pc                         	( pc                          )
);
// outports wire
wire [63:0]  	fetch_o_pc;
wire [31:0]  	fetch_o_instr;
wire [160:0] 	fetch_o_commit_info;

fetch u_fetch(
	.clk                 	( clk                  ),
	.rst                 	( rst                  ),
	.pc                  	( pc                   ),
	.fetch_o_pc          	( fetch_o_pc           ),
	.fetch_o_instr       	( fetch_o_instr        ),
	.fetch_o_next_pc     	( fetch_o_next_pc      ),
	.fetch_o_commit_info 	( fetch_o_commit_info  )
);
// outports wire
wire [63:0]  	regD_o_pc;
wire [31:0]  	regD_o_instr;
wire [160:0] 	regD_o_commit_info;

regD u_regD(
	.clk                 	( clk                  ),
	.rst                 	( rst                  ),
	.regD_bubble         	( regD_bubble          ),
	.regD_stall          	( regD_stall           ),
	.fetch_i_pc          	( fetch_o_pc           ),
	.fetch_i_instr       	( fetch_o_instr        ),
	.fetch_i_commit_info 	( fetch_o_commit_info  ),
	.regD_o_pc           	( regD_o_pc            ),
	.regD_o_instr        	( regD_o_instr         ),
	.regD_o_commit_info  	( regD_o_commit_info   )
);
// outports wire
wire [27:0] 	decode_o_alu_info;
wire [12:0] 	decode_o_opcode_info;
wire [5:0]  	decode_o_branch_info;
wire [10:0] 	decode_o_load_store_info;
wire [5:0]  	decode_o_csrrw_info;
wire [6:0]  	decode_o_system_info;
wire [63:0] 	decode_o_regdata1;
wire [63:0] 	decode_o_regdata2;
wire [63:0] 	decode_o_csr_rdata1;
wire [63:0] 	decode_o_csr_rdata2;
wire [63:0] 	decode_o_imm;
wire [11:0] 	decode_o_csr_wid;
wire        	decode_o_csr_wen;
wire [4:0]  	decode_o_reg_rd;
wire        	decode_o_reg_wen;
wire [4:0]  	decode_o_reg_rs1;
wire [4:0]  	decode_o_reg_rs2;

decode u_decode(
	.clk                      	( clk                       ),
	.rst                      	( rst                       ),
	.regD_i_pc                	( regD_o_pc                 ),
	.regD_i_instr             	( regD_o_instr              ),
	.execute_i_alu_result     	( execute_o_alu_result      ),
	.regE_i_reg_rd            	( regE_o_reg_rd             ),
	.regE_i_reg_wen           	( regE_o_reg_wen            ),
	.regM_i_opcode_info       	( regM_o_opcode_info        ),
	.regM_i_alu_result        	( regM_o_alu_result         ),
	.memory_i_mem_rdata       	( memory_o_mem_rdata        ),
	.regM_i_reg_rd            	( regM_o_reg_rd             ),
	.regM_i_reg_wen           	( regM_o_reg_wen            ),
	.regW_i_opcode_info       	( regW_o_opcode_info        ),
	.regW_i_pc                	( regW_o_pc                 ),
	.regW_i_alu_result        	( regW_o_alu_result         ),
	.regW_i_mem_rdata         	( regW_o_mem_rdata          ),
	.regW_i_csr_rdata1        	( regW_o_csr_rdata1         ),
	.regW_i_reg_rd            	( regW_o_reg_rd             ),
	.regW_i_reg_wen           	( regW_o_reg_wen            ),
	.wb_i_reg_wen             	( wb_o_reg_wen              ),
	.wb_i_reg_rd              	( wb_o_reg_rd               ),
	.wb_i_reg_wdata           	( wb_o_reg_wdata            ),
	.wb_i_csr_wen             	( wb_o_csr_wen              ),
	.wb_i_csr_wid             	( wb_o_csr_wid              ),
	.wb_i_csr_wdata           	( wb_o_csr_wdata            ),
    .wb_i_system_info           (wb_o_system_info),
	.decode_o_alu_info        	( decode_o_alu_info         ),
	.decode_o_opcode_info     	( decode_o_opcode_info      ),
	.decode_o_branch_info     	( decode_o_branch_info      ),
	.decode_o_load_store_info 	( decode_o_load_store_info  ),
	.decode_o_csrrw_info      	( decode_o_csrrw_info       ),
	.decode_o_system_info     	( decode_o_system_info      ),
	.decode_o_regdata1        	( decode_o_regdata1         ),
	.decode_o_regdata2        	( decode_o_regdata2         ),
	.decode_o_csr_rdata1      	( decode_o_csr_rdata1       ),
	.decode_o_csr_rdata2      	( decode_o_csr_rdata2       ),
	.decode_o_imm             	( decode_o_imm              ),
	.decode_o_csr_wid         	( decode_o_csr_wid          ),
	.decode_o_csr_wen         	( decode_o_csr_wen          ),
	.decode_o_reg_rd          	( decode_o_reg_rd           ),
	.decode_o_reg_wen         	( decode_o_reg_wen          ),
	.decode_o_reg_rs1         	( decode_o_reg_rs1          ),
	.decode_o_reg_rs2         	( decode_o_reg_rs2          )
);
// outports wire
wire [12:0]  	regE_o_opcode_info;
wire [5:0]   	regE_o_branch_info;
wire [10:0]  	regE_o_load_store_info;
wire [27:0]  	regE_o_alu_info;
wire [5:0]   	regE_o_csrrw_info;
wire [6:0]   	regE_o_system_info;
wire [63:0]  	regE_o_pc;
wire [63:0]  	regE_o_csr_rdata1;
wire [63:0]  	regE_o_csr_rdata2;
wire [63:0]  	regE_o_regdata1;
wire [63:0]  	regE_o_regdata2;
wire [63:0]  	regE_o_imm;
wire [11:0]  	regE_o_csr_wid;
wire         	regE_o_csr_wen;
wire [4:0]   	regE_o_reg_rd;
wire         	regE_o_reg_wen;
wire [160:0] 	regE_o_commit_info;

regE u_regE(
	.clk                      	( clk                       ),
	.rst                      	( rst                       ),
	.regE_bubble              	( regE_bubble               ),
	.regE_stall               	( regE_stall                ),
	.decode_i_opcode_info     	( decode_o_opcode_info      ),
	.decode_i_branch_info     	( decode_o_branch_info      ),
	.decode_i_load_store_info 	( decode_o_load_store_info  ),
	.decode_i_alu_info        	( decode_o_alu_info         ),
	.decode_i_csrrw_info      	( decode_o_csrrw_info       ),
	.decode_i_system_info     	( decode_o_system_info      ),
	.regD_i_pc                	( regD_o_pc                 ),
	.decode_i_csr_rdata1      	( decode_o_csr_rdata1       ),
	.decode_i_csr_rdata2      	( decode_o_csr_rdata2       ),
	.decode_i_regdata1        	( decode_o_regdata1         ),
	.decode_i_regdata2        	( decode_o_regdata2         ),
	.decode_i_imm             	( decode_o_imm              ),
	.decode_i_csr_wid         	( decode_o_csr_wid          ),
	.decode_i_csr_wen         	( decode_o_csr_wen          ),
	.decode_i_reg_rd          	( decode_o_reg_rd           ),
	.decode_i_reg_wen         	( decode_o_reg_wen          ),
	.regD_i_commit_info       	( regD_o_commit_info        ),
	.regE_o_opcode_info       	( regE_o_opcode_info        ),
	.regE_o_branch_info       	( regE_o_branch_info        ),
	.regE_o_load_store_info   	( regE_o_load_store_info    ),
	.regE_o_alu_info          	( regE_o_alu_info           ),
	.regE_o_csrrw_info        	( regE_o_csrrw_info         ),
	.regE_o_system_info       	( regE_o_system_info        ),
	.regE_o_pc                	( regE_o_pc                 ),
	.regE_o_csr_rdata1        	( regE_o_csr_rdata1         ),
	.regE_o_csr_rdata2        	( regE_o_csr_rdata2         ),
	.regE_o_regdata1          	( regE_o_regdata1           ),
	.regE_o_regdata2          	( regE_o_regdata2           ),
	.regE_o_imm               	( regE_o_imm                ),
	.regE_o_csr_wid           	( regE_o_csr_wid            ),
	.regE_o_csr_wen           	( regE_o_csr_wen            ),
	.regE_o_reg_rd            	( regE_o_reg_rd             ),
	.regE_o_reg_wen           	( regE_o_reg_wen            ),
	.regE_o_commit_info       	( regE_o_commit_info        )
);
// outports wire
wire [63:0]  	execute_o_alu_result;
wire         	execute_o_mret_need_jump;
wire [63:0]  	execute_o_mret_next_pc;
wire [63:0]  	execute_o_branch_next_pc;
wire         	execute_o_branch_need_jump;
wire [160:0] 	execute_o_commit_info;

execute u_execute(
	.regE_i_commit_info         	( regE_o_commit_info          ),
	.regE_i_opcode_info         	( regE_o_opcode_info          ),
	.regE_i_branch_info         	( regE_o_branch_info          ),
	.regE_i_load_store_info     	( regE_o_load_store_info      ),
	.regE_i_alu_info            	( regE_o_alu_info             ),
	.regE_i_csrrw_info          	( regE_o_csrrw_info           ),
	.regE_i_system_info         	( regE_o_system_info          ),
	.regE_i_regdata1            	( regE_o_regdata1             ),
	.regE_i_regdata2            	( regE_o_regdata2             ),
	.regE_i_imm                 	( regE_o_imm                  ),
	.regE_i_pc                  	( regE_o_pc                   ),
	.regE_i_csr_rdata1          	( regE_o_csr_rdata1           ),
	.regE_i_csr_rdata2          	( regE_o_csr_rdata2           ),
	.execute_o_alu_result       	( execute_o_alu_result        ),
	.execute_o_mret_need_jump   	( execute_o_mret_need_jump    ),
	.execute_o_mret_next_pc     	( execute_o_mret_next_pc      ),
	.execute_o_branch_next_pc   	( execute_o_branch_next_pc    ),
	.execute_o_branch_need_jump 	( execute_o_branch_need_jump  ),
	.execute_o_commit_info      	( execute_o_commit_info       )
);
// outports wire
wire [10:0]  	regM_o_load_store_info;
wire [12:0]  	regM_o_opcode_info;
wire [5:0]   	regM_o_csrrw_info;
wire [6:0]   	regM_o_system_info;
wire [63:0]  	regM_o_alu_result;
wire [63:0]  	regM_o_pc;
wire [63:0]  	regM_o_csr_rdata1;
wire [63:0]  	regM_o_regdata2;
wire [11:0]  	regM_o_csr_wid;
wire         	regM_o_csr_wen;
wire [4:0]   	regM_o_reg_rd;
wire         	regM_o_reg_wen;
wire [160:0] 	regM_o_commit_info;

regM u_regM(
	.clk                    	( clk                     ),
	.rst                    	( rst                     ),
	.regM_bubble            	( regM_bubble             ),
	.regM_stall             	( regM_stall              ),
	.regE_i_load_store_info 	( regE_o_load_store_info  ),
	.regE_i_opcode_info     	( regE_o_opcode_info      ),
	.regE_i_csrrw_info      	( regE_o_csrrw_info       ),
	.regE_i_system_info     	( regE_o_system_info      ),
	.execute_i_alu_result   	( execute_o_alu_result    ),
	.regE_i_pc              	( regE_o_pc               ),
	.regE_i_csr_rdata1      	( regE_o_csr_rdata1       ),
	.regE_i_regdata2        	( regE_o_regdata2         ),
	.regE_i_csr_wid         	( regE_o_csr_wid          ),
	.regE_i_csr_wen         	( regE_o_csr_wen          ),
	.regE_i_reg_rd          	( regE_o_reg_rd           ),
	.regE_i_reg_wen         	( regE_o_reg_wen          ),
	.execute_i_commit_info  	( execute_o_commit_info   ),
	.regM_o_load_store_info 	( regM_o_load_store_info  ),
	.regM_o_opcode_info     	( regM_o_opcode_info      ),
	.regM_o_csrrw_info      	( regM_o_csrrw_info       ),
	.regM_o_system_info     	( regM_o_system_info      ),
	.regM_o_alu_result      	( regM_o_alu_result       ),
	.regM_o_pc              	( regM_o_pc               ),
	.regM_o_csr_rdata1      	( regM_o_csr_rdata1       ),
	.regM_o_regdata2        	( regM_o_regdata2         ),
	.regM_o_csr_wid         	( regM_o_csr_wid          ),
	.regM_o_csr_wen         	( regM_o_csr_wen          ),
	.regM_o_reg_rd          	( regM_o_reg_rd           ),
	.regM_o_reg_wen         	( regM_o_reg_wen          ),
	.regM_o_commit_info     	( regM_o_commit_info      )
);
// outports wire
wire [63:0] 	memory_o_mem_rdata;

memory u_memory(
	.clk                    	( clk                     ),
	.rst                    	( rst                     ),
	.regM_i_load_store_info 	( regM_o_load_store_info  ),
	.regM_i_alu_result      	( regM_o_alu_result       ),
	.regM_i_regdata2        	( regM_o_regdata2         ),
	.memory_o_mem_rdata     	( memory_o_mem_rdata      )
);
// outports wire
wire [12:0]  	regW_o_opcode_info;
wire [5:0]   	regW_o_csrrw_info;
wire [6:0]   	regW_o_system_info;
wire [63:0]  	regW_o_alu_result;
wire [63:0]  	regW_o_mem_rdata;
wire [63:0]  	regW_o_pc;
wire [63:0]  	regW_o_csr_rdata1;
wire [63:0]  	regW_o_regdata2;
wire [4:0]   	regW_o_reg_rd;
wire         	regW_o_reg_wen;
wire [11:0]  	regW_o_csr_wid;
wire         	regW_o_csr_wen;
wire [160:0] 	regW_o_commit_info;

regW u_regW(
	.clk                	( clk                 ),
	.rst                	( rst                 ),
	.regW_bubble        	( regW_bubble         ),
	.regW_stall         	( regW_stall          ),
	.regM_i_opcode_info 	( regM_o_opcode_info  ),
	.regM_i_csrrw_info  	( regM_o_csrrw_info   ),
	.regM_i_system_info 	( regM_o_system_info  ),
	.regM_i_alu_result  	( regM_o_alu_result   ),
	.memory_i_mem_rdata 	( memory_o_mem_rdata  ),
	.regM_i_pc          	( regM_o_pc           ),
	.regM_i_regdata2    	( regM_o_regdata2     ),
	.regM_i_csr_rdata1  	( regM_o_csr_rdata1   ),
	.regM_i_csr_wid      	( regM_o_csr_wid       ),
	.regM_i_csr_wen     	( regM_o_csr_wen      ),
	.regM_i_reg_rd      	( regM_o_reg_rd       ),
	.regM_i_reg_wen     	( regM_o_reg_wen      ),
	.regM_i_commit_info 	( regM_o_commit_info  ),
	.regW_o_opcode_info 	( regW_o_opcode_info  ),
	.regW_o_csrrw_info  	( regW_o_csrrw_info   ),
	.regW_o_system_info 	( regW_o_system_info  ),
	.regW_o_alu_result  	( regW_o_alu_result   ),
	.regW_o_mem_rdata   	( regW_o_mem_rdata    ),
	.regW_o_pc          	( regW_o_pc           ),
	.regW_o_csr_rdata1  	( regW_o_csr_rdata1   ),
	.regW_o_regdata2    	( regW_o_regdata2     ),
	.regW_o_reg_rd      	( regW_o_reg_rd       ),
	.regW_o_reg_wen     	( regW_o_reg_wen      ),
	.regW_o_csr_wid      	( regW_o_csr_wid       ),
	.regW_o_csr_wen     	( regW_o_csr_wen      ),
	.regW_o_commit_info 	( regW_o_commit_info  )
);
// outports wire
wire        	wb_o_csr_wen;
wire [63:0] 	wb_o_csr_wdata;
wire [11:0] 	wb_o_csr_wid;
wire [4:0]  	wb_o_reg_rd;
wire [63:0] 	wb_o_reg_wdata;
wire        	wb_o_reg_wen;
wire [6:0]      wb_o_system_info;
write_back u_write_back(
	.regW_i_opcode_info 	( regW_o_opcode_info  ),
	.regW_i_csrrw_info  	( regW_o_csrrw_info   ),
	.regW_i_system_info 	( regW_o_system_info  ),
	.regW_i_alu_result  	( regW_o_alu_result   ),
	.regW_i_mem_rdata   	( regW_o_mem_rdata    ),
	.regW_i_pc          	( regW_o_pc           ),
	.regW_i_csr_rdata1  	( regW_o_csr_rdata1   ),
	.regW_i_csr_wid     	( regW_o_csr_wid      ),
	.regW_i_csr_wen     	( regW_o_csr_wen      ),
	.regW_i_reg_wen     	( regW_o_reg_wen      ),
	.regW_i_reg_rd      	( regW_o_reg_rd       ),
	.wb_o_csr_wen       	( wb_o_csr_wen        ),
	.wb_o_csr_wdata     	( wb_o_csr_wdata      ),
	.wb_o_csr_wid       	( wb_o_csr_wid        ),
    .wb_o_system_info       (wb_o_system_info),
	.wb_o_reg_rd        	( wb_o_reg_rd         ),
	.wb_o_reg_wdata     	( wb_o_reg_wdata      ),
	.wb_o_reg_wen       	( wb_o_reg_wen        )
);


commit u_commit(
	.regW_i_commit_info 	( regW_o_commit_info  ),
	.regW_i_regdata2    	( regW_o_regdata2     ),
	.regW_i_mem_rdata   	( regW_o_mem_rdata    ),
	.regW_i_alu_result  	( regW_o_alu_result   ),
	.commit_o_mem_rdata 	( commit_mem_rdata  ),
	.commit_o_mem_wdata 	( commit_mem_wdata  ),
	.commit_o_mem_addr  	( commit_mem_addr   ),
	.commit_o_commit    	( commit     ),
	.commit_o_instr     	( commit_instr      ),
	.commit_o_pc        	( commit_pc         ),
	.commit_o_next_pc   	( commit_next_pc    )
);
// outports wire
wire        	regF_stall;
wire        	regD_stall;
wire        	regE_stall;
wire        	regM_stall;
wire        	regW_stall;
wire        	regF_bubble;
wire        	regD_bubble;
wire        	regE_bubble;
wire        	regM_bubble;
wire        	regW_bubble;

ctrl u_ctrl(
	.execute_i_branch_need_jump 	( execute_o_branch_need_jump  ),
	.execute_i_mret_need_jump		(execute_o_mret_need_jump),
	.regE_i_opcode_info         	( regE_o_opcode_info          ),
	.regE_i_reg_rd              	( regE_o_reg_rd               ),
	.decode_i_reg_rs1           	( decode_o_reg_rs1            ),
	.decode_i_reg_rs2           	( decode_o_reg_rs2            ),
	.regF_stall                 	( regF_stall                  ),
	.regD_stall                 	( regD_stall                  ),
	.regE_stall                 	( regE_stall                  ),
	.regM_stall                 	( regM_stall                  ),
	.regW_stall                 	( regW_stall                  ),
	.regF_bubble                	( regF_bubble                 ),
	.regD_bubble                	( regD_bubble                 ),
	.regE_bubble                	( regE_bubble                 ),
	.regM_bubble                	( regM_bubble                 ),
	.regW_bubble                	( regW_bubble                 )
);
assign cur_pc = pc;


endmodule