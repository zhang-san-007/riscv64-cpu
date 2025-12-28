module regfile(
	input            clk,
	input            rst,	
	//from decode
	input   [ 4:0]   rs1_id_i,
	input   [ 4:0]   rs2_id_i,	
	output  [31:0]   rs1_rdata_o,
	output  [31:0]   rs2_rdata_o,
	//write 
	input            w_en,        //write enable
	input   [ 4:0]   rd_id_i,
	input   [31:0]   rd_write_data_i
	//for moniter regfile status 
);


endmodule