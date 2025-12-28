
module ctrl(
    input  wire          execute_i_need_jump,

    //加载使用
    input wire  [11:0]   regE_i_opcode_info,
    input  wire [4:0]    regE_i_rd,
    input  wire [4:0]    decode_i_rs1,
    input  wire [4:0]    decode_i_rs2,

    output wire          fetch_stall,
    output wire          regF_stall,
    output wire          regD_stall,
    output wire          regE_stall,
    output wire          regM_stall,
    output wire          regW_stall,
   
    output wire          fetch_bubble,
    output wire          regF_bubble,
    output wire          regD_bubble,
    output wire          regE_bubble,
    output wire          regM_bubble,
    output wire          regW_bubble
);

wire inst_load          = regE_i_opcode_info[3];

wire load_use           = (regE_i_rd == decode_i_rs1 || regE_i_rd == decode_i_rs2) && inst_load;
wire branch_bubble      = execute_i_need_jump;

assign regF_bubble      = 1'b0;
assign fetch_bubble     = branch_bubble;
assign regD_bubble      = branch_bubble;
assign regE_bubble      = branch_bubble || load_use;
assign regM_bubble      = 1'b0;
assign regW_bubble      = 1'b0;

assign fetch_stall      = load_use;
assign regF_stall       = load_use;
assign regD_stall       = load_use;
assign regE_stall       = 1'b0;
assign regM_stall       = 1'b0;
assign regW_stall       = 1'b0;
endmodule