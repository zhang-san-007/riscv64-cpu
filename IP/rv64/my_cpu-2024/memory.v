`include "define.v"
module memory(
	input wire clk,
	input wire rst,
    input wire  [31:0]  regM_o_instr,
    input wire  [2:0]   regM_i_load_type,
    input wire  	    regM_i_mem_ren,
    input wire  	    regM_i_mem_wen,
    input wire  [3:0]   regM_i_mem_wmask,
	input wire  [63:0]	regM_i_valE,
	input wire  [63:0]	regM_i_valB,

	input wire [63:0] regM_o_pc,
	output wire [63:0]	memory_o_valM       //the result of read memory 
);
import "DPI-C" function void    dpi_mem_write(input longint addr, input longint data, int len, input int inst,input longint pc);
import "DPI-C" function longint dpi_mem_read (input longint addr, input int len, input int inst);

//read mem

reg [63:0] mem_read_val;// = (regM_i_mem_ren!=1) ? dpi_mem_read(regM_i_valE, 8) : 64'b0 ;

wire [31:0] load_len =  (regM_i_load_type == `lb ) ?  32'd1 	:
                    	(regM_i_load_type == `lh ) ? 32'd2	:
					    (regM_i_load_type == `lw ) ? 32'd4  : 
						(regM_i_load_type == `lwu) ? 32'd4  : 
                        (regM_i_load_type == `ld ) ? 32'd8	: 
			    		(regM_i_load_type == `lbu) ? 32'd1 	:
				    	(regM_i_load_type == `lhu) ? 32'd2  : 32'b0;


always @(*) begin
	if(~regM_i_mem_ren) begin
		mem_read_val = 64'd0;
	end
	else if(regM_i_mem_ren)  begin
		mem_read_val = dpi_mem_read(regM_i_valE, load_len, regM_o_instr);
		//mem_read_val = dpi_mem_read(regM_i_valE, 8, regM_o_instr);
	end
	else begin
		mem_read_val = 64'd0;
	end
end

assign memory_o_valM  =     (regM_i_load_type == `lb ) ? {{56{mem_read_val[7] }}, mem_read_val[7:0]	} 	:
                    	    (regM_i_load_type == `lh ) ? {{48{mem_read_val[15]}}, mem_read_val[15:0]}	:
						    (regM_i_load_type == `lw ) ? {{32{mem_read_val[31]}}, mem_read_val[31:0]}   : 
                            (regM_i_load_type == `ld ) ? mem_read_val 							 	    : 
				    		(regM_i_load_type == `lbu) ? {56'd0 , mem_read_val[7:0]					} 	:
					    	(regM_i_load_type == `lhu) ? {48'd0 , mem_read_val[15:0]				} 	: 
							(regM_i_load_type == `lw ) ? {32'd0, mem_read_val[31:0]					}   : 64'b0;
							// (regM_i_load_type == `lb ) ? {{56{mem_read_val[7] }}, mem_read_val[7:0]	} 	:
                    	    // (regM_i_load_type == `lh ) ? {{48{mem_read_val[15]}}, mem_read_val[15:0]}	:
						    // (regM_i_load_type == `lw ) ? {{32{mem_read_val[31]}}, mem_read_val[31:0]}   : 
                            // (regM_i_load_type == `ld ) ? mem_read_val 							 	    : 
				    		// (regM_i_load_type == `lbu) ? {56'd0 , mem_read_val[7:0]					} 	:
					    	// (regM_i_load_type == `lhu) ? {48'd0 , mem_read_val[15:0]				} 	: 
							// (regM_i_load_type == `lw ) ? {32'd0, mem_read_val[31:0]					}   : 64'b0;

//assign memory_o_valM = (regM_i_mem_ren) ? {32'd0, mem_tem_valM} : 64'd0;

//write mem
wire [31:0] write_byte = {28'b0, regM_i_mem_wmask};
always @(posedge clk)begin
    if(regM_i_mem_wen==1 && regM_i_mem_wmask != `zero_byte) begin
        dpi_mem_write(regM_i_valE, regM_i_valB, write_byte, regM_o_instr, regM_o_pc);
    end
end


endmodule