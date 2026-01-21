
module ctrl(
    input  wire          execute_i_branch_need_jump,
    input  wire          execute_i_mret_need_jump,

    //加载使用
    input wire  [13:0]   decode_i_opcode_info,
    input wire  [13:0]   regE_i_opcode_info,
    input wire  [13:0]   regM_i_opcode_info,


    input  wire [4:0]    regE_i_reg_rd,
    input  wire [4:0]    decode_i_reg_rs1,
    input  wire [4:0]    decode_i_reg_rs2,

    output wire          regF_stall,
    output wire          regD_stall,
    output wire          regE_stall,
    output wire          regM_stall,
    output wire          regW_stall,
   
    output wire          regF_bubble,
    output wire          regD_bubble,
    output wire          regE_bubble,
    output wire          regM_bubble,
    output wire          regW_bubble
);

wire inst_load          = regE_i_opcode_info[3];
wire load_use           = (regE_i_reg_rd == decode_i_reg_rs1 || regE_i_reg_rd == decode_i_reg_rs2) && inst_load;
wire branch_bubble      =  execute_i_branch_need_jump;
wire mret_bubble        =  execute_i_mret_need_jump;

wire inst_amo_decode    =  decode_i_opcode_info[13]; 
wire inst_amo_execute   =  regE_i_opcode_info  [13];
wire inst_amo_memory    =  regM_i_opcode_info  [13];



assign regF_bubble      = 1'b0;
assign regD_bubble      = branch_bubble | mret_bubble | inst_amo_decode| inst_amo_execute | inst_amo_memory;
assign regE_bubble      = branch_bubble | load_use    | mret_bubble    | inst_amo_execute | inst_amo_memory;  
assign regM_bubble      = inst_amo_memory;
assign regW_bubble      = 1'b0;

assign regF_stall       = load_use      | inst_amo_decode | inst_amo_execute | inst_amo_memory;
assign regD_stall       = load_use;
assign regE_stall       = 1'b0;
assign regM_stall       = 1'b0;
assign regW_stall       = 1'b0;
endmodule


//对于加载使用冒险
//我在执行阶段的时候在ctrl里面检测到加载使用冒险，
//这个时候后面两条指令正在执行decode阶段和fetch阶段

//然后下一个节拍，我给regE注入一个bubble, 让regD和regF都stall一样，这样后面两条指令都还是在执行decode阶段和fetch阶段