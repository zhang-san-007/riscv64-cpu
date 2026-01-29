module fetch(
    input wire clk,
    input wire rst,
    input  wire  [63:0]    pc,
    output wire  [63:0]    fetch_o_pc,
    output wire  [31:0]    fetch_o_instr,
    output wire  [63:0]    fetch_o_next_pc,
    output wire  [160:0]   fetch_o_commit_info
);

import "DPI-C" function int dpi_instr_mem_read (input longint addr);

assign fetch_o_pc               =  pc;
assign fetch_o_instr            =  dpi_instr_mem_read(pc);


// // outports wire
// wire        	mmu_o_ready;
// wire [63:0] 	mmu_o_pa;
// wire        	mmu_o_valid;

// mmu u_mmu(
// 	.clk         	( clk          ),
// 	.rst         	( rst          ),
// 	.va          	( pc           ),
// 	.va_i_valid  	( pc_i_valid   ),
// 	.satp        	( satp         ),
// 	.mmu_o_ready 	( mmu_o_ready  ),
// 	.mmu_o_pa    	( mmu_o_pa     ),
// 	.mmu_o_valid 	( mmu_o_valid  )
// );


assign fetch_o_next_pc       =  fetch_o_pc + 64'd4; //这个是预测的下一条PC
assign fetch_o_commit_info   = {1'b1, fetch_o_instr, fetch_o_next_pc, fetch_o_pc};



    
endmodule