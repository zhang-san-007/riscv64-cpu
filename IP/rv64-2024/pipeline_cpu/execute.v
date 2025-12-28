module execute
#(parameter WIDTH=64)
(
    input wire  [160:0] regE_commit_info,
    //info
    input wire  [11:0]  regE_opcode_info,
    input wire  [5:0]   regE_branch_info,
    input wire  [10:0]  regE_load_store_info,
    input wire  [27:0]  regE_alu_info,

    //data
    input wire  [WIDTH-1:0]  regE_regdata1,
    input wire  [WIDTH-1:0]  regE_regdata2,
    input wire  [WIDTH-1:0]  regE_imm,
    input wire  [WIDTH-1:0]  regE_pc,

    output wire [160:0] execute_commit_info,
    output wire [WIDTH-1:0]  execute_alu_result,
    output wire         execute_need_jump,
    output wire [WIDTH-1:0]  execute_jump_pc
);

wire op_lui         = regE_opcode_info[11];
wire op_auipc       = regE_opcode_info[10];
wire op_jal         = regE_opcode_info[9];
wire op_jalr        = regE_opcode_info[8];
wire op_alu_reg     = regE_opcode_info[7];
wire op_alu_regw    = regE_opcode_info[6];
wire op_alu_imm     = regE_opcode_info[5];
wire op_alu_immw    = regE_opcode_info[4];
wire op_load        = regE_opcode_info[3];
wire op_store       = regE_opcode_info[2];
wire op_branch      = regE_opcode_info[1];
wire op_system      = regE_opcode_info[0];

wire alu_remuw      =  regE_alu_info[0];
wire alu_remw       =  regE_alu_info[1];
wire alu_remu       =  regE_alu_info[2];
wire alu_rem        =  regE_alu_info[3];

wire alu_divuw      =  regE_alu_info[4];
wire alu_divw       =  regE_alu_info[5];
wire alu_divu       =  regE_alu_info[6];
wire alu_div        =  regE_alu_info[7];

wire alu_mulw       =  regE_alu_info[8];
wire alu_mulhu      =  regE_alu_info[9];
wire alu_mulhsu     =  regE_alu_info[10];
wire alu_mulh       =  regE_alu_info[11];
wire alu_mul        =  regE_alu_info[12];

wire alu_sraw       =  regE_alu_info[13];
wire alu_srlw       =  regE_alu_info[14];
wire alu_sllw       =  regE_alu_info[15];
wire alu_subw       =  regE_alu_info[16];
wire alu_addw       =  regE_alu_info[17];

wire alu_and        =  regE_alu_info[18];
wire alu_or         =  regE_alu_info[19];
wire alu_sra        =  regE_alu_info[20];
wire alu_srl        =  regE_alu_info[21];
wire alu_xor        =  regE_alu_info[22];
wire alu_sltu       =  regE_alu_info[23];
wire alu_slt        =  regE_alu_info[24];
wire alu_sll        =  regE_alu_info[25];
wire alu_sub        =  regE_alu_info[26];
wire alu_add        =  regE_alu_info[27];

wire [WIDTH-1:0] alu_src1 = op_alu_reg | op_alu_regw ? regE_regdata1    : 
                       op_alu_imm | op_alu_immw ? regE_regdata1    : 
                       op_branch                ? regE_pc          : 
                       op_store                 ? regE_regdata1    : 
                       op_load                  ? regE_regdata1    : 
                       op_jal                   ? regE_pc          : 
                       op_jalr                  ? regE_regdata1    : 
                       op_lui                   ? 64'd0              : 
                       op_auipc                 ? regE_pc          : 64'd0;

wire [WIDTH-1:0] alu_src2 = op_alu_reg | op_alu_regw  ? regE_regdata2   : 
                       op_alu_imm | op_alu_immw  ? regE_imm        : 
                       op_branch                 ? regE_imm        : 
                       op_store                  ? regE_imm        : 
                       op_load                   ? regE_imm        : 
                       op_jal                    ? regE_imm        : 
                       op_jalr                   ? regE_imm        : 
                       op_lui                    ? regE_imm        : 
                       op_auipc                  ? regE_imm        : 64'd0;

wire [WIDTH-1:0]   signed_alu_src1 = $signed(alu_src1);
wire [WIDTH-1:0]   signed_alu_src2 = $signed(alu_src2);
wire  [127:0]   signed_ext_alu_src1 = {{64{alu_src1[WIDTH-1]}}, alu_src1}; // 进行符号扩展
wire  [127:0]   signed_ext_alu_src2 = {{64{alu_src2[WIDTH-1]}}, alu_src2}; // 进行符号扩展
wire  [127:0] unsigned_ext_alu_src1 = {64'd0, alu_src1};
wire  [127:0] unsigned_ext_alu_src2 = {64'd0, alu_src2};

wire  [127:0]    ext_mul_result = { signed_ext_alu_src1   *    signed_ext_alu_src2}; //默认是sign
wire  [127:0] su_ext_mul_result = { signed_ext_alu_src1   *  unsigned_ext_alu_src2};
wire  [127:0]  u_ext_mul_result = { unsigned_ext_alu_src1 *  unsigned_ext_alu_src2};


wire [31:0]          div_result = {$signed(alu_src1[31:0]) /   $signed(alu_src2[31:0])}; 
wire [31:0]         udiv_result = {$signed(alu_src1[31:0]) / $unsigned(alu_src2[31:0])}; 


wire [WIDTH-1:0] alu_add_result  = alu_src1 + alu_src2;
wire [WIDTH-1:0] alu_sub_result  = alu_src1 - alu_src2;
wire [WIDTH-1:0] alu_sll_result  = {$signed(alu_src1)  << $signed(alu_src2[5:0])};
wire [WIDTH-1:0] alu_sllw_result = {$signed(alu_src1)  << $signed(alu_src2[4:0])};

wire [WIDTH-1:0] alu_sra_result  =  $signed(alu_src1)    >>> alu_src2[5:0];
wire [31:0] alu_sraw_result = {$signed(alu_src1[31:0])  >>> alu_src2[4:0]};



assign execute_alu_result = op_lui    ?   {alu_src1  +  alu_src2    }                                                     :
                              op_auipc  ?   {alu_src1  +  alu_src2    }                                                     :
                              op_branch ?   {alu_src1  +  alu_src2    }                                                     : 
                              op_store  ?   {alu_src1  +  alu_src2    }                                                     : 
                              op_jal    ?   {alu_src1  +  alu_src2    }                                                     : 
                              op_jalr   ?   {alu_src1  +  alu_src2    }                                                     :
                              op_load   ?   {alu_src1  +  alu_src2    }                                                     : 
                              alu_and   ?   {alu_src1  &  alu_src2    }                                                     :
                              alu_add   ?   {alu_add_result  }                                                              : 
                              alu_addw  ?   {{32{{alu_add_result}[31]}},      { alu_add_result}[31:0] }                     : 
                              alu_sub   ?   {alu_sub_result    }                                                            : 
                              alu_subw  ?   {{32{{alu_sub_result}[31]}},      { alu_sub_result}[31:0] }                     : 
                              alu_sll   ?   {alu_sll_result  }                                                              :
                              alu_sllw  ?   {{32{alu_sllw_result [31]}}, alu_sllw_result[31:0]}                             : 
                              alu_slt   ?   ($signed(alu_src1)    <  $signed(alu_src2       )) ? 64'd1 : 64'd0              :    
                              alu_sltu  ?   ($unsigned(alu_src1)  <  $unsigned(alu_src2     )) ? 64'd1 : 64'd0              :
                              alu_xor   ?   { alu_src1 ^ alu_src2}                                                          :
                              alu_or    ?   { alu_src1 | alu_src2}                                                          :
                              alu_sra   ?    alu_sra_result                                                                 : 
                              alu_sraw  ?   {{32{alu_sraw_result[31]}}, alu_sraw_result[31:0]      }                        : 
                              alu_srl   ?   {$unsigned(alu_src1)   >>> alu_src2[5:0] }                                      :
                              alu_srlw  ?   {{32{{$unsigned(alu_src1[31:0]) >>> alu_src2[4:0] }[31]}}, {{$unsigned(alu_src1[31:0]) >>> alu_src2[4:0] }}     } :
                              alu_mul   ?   {   alu_src1 * alu_src2    }                                                    : 
                              alu_mulh  ?   {    ext_mul_result[127:64]}                                                    : 
                              alu_mulhsu?   { su_ext_mul_result[127:64]}                                                    : 
                              alu_mulhu ?   {  u_ext_mul_result[127:64]}                                                    : 
                              alu_mulw  ?   {{32{{alu_src1 * alu_src2}[31]}},      { alu_src1  *  alu_src2}[31:0] }         : 
                              alu_div   ?   ( alu_src2 == 64'd0 ? 64'hFFFFFFFFFFFFFFFF :
                                              alu_src1 == 64'h8000000000000000 && alu_src2 == 64'hFFFFFFFFFFFFFFFF ? 64'h8000000000000000   : {$signed(alu_src1) / $signed(alu_src2)})    : 
                              alu_divu  ?   ( alu_src2 == 64'd0 ? 64'hFFFFFFFFFFFFFFFF :     {$signed(alu_src1) / $unsigned(alu_src2)})    :
                              alu_divw  ?   ( alu_src2 == 64'd0 ? 64'hFFFFFFFFFFFFFFFF :
                                              alu_src1 == 64'hFFFFFFFF80000000 && alu_src2 == 64'hFFFFFFFFFFFFFFFF ? 64'hFFFFFFFF80000000   : {{32{div_result[31]}}, div_result} )    :
                              alu_divuw ?   ( alu_src2 == 64'd0 ? 64'hFFFFFFFFFFFFFFFF :     {{32{udiv_result[31]}}, udiv_result} )         : 64'd0;

wire inst_beq   = regE_branch_info[5];
wire inst_bne   = regE_branch_info[4];
wire inst_blt   = regE_branch_info[3];
wire inst_bge   = regE_branch_info[2];
wire inst_bltu  = regE_branch_info[1];
wire inst_bgeu  = regE_branch_info[0];
assign execute_need_jump = (inst_beq    && ($signed  (regE_regdata1) == $signed  (regE_regdata2)))  ? 1'b1:
							 (inst_bne  && ($signed  (regE_regdata1) != $signed  (regE_regdata2)))  ? 1'b1:
							 (inst_blt  && ($signed  (regE_regdata1) <  $signed  (regE_regdata2)))  ? 1'b1:
							 (inst_bge  && ($signed  (regE_regdata1) >= $signed  (regE_regdata2)))  ? 1'b1:
							 (inst_bltu && ($unsigned(regE_regdata1) <  $unsigned(regE_regdata2)))  ? 1'b1:
							 (inst_bgeu && ($unsigned(regE_regdata1) >= $unsigned(regE_regdata2)))  ? 1'b1:
							 (op_jal | op_jalr)                                                         ? 1'b1: 1'b0;

wire [WIDTH-1:0] tmp = op_jalr ?  (execute_alu_result & ~1) : 64'd0;
assign  execute_jump_pc   = op_jalr               ? (execute_alu_result & ~1)           : 
                              op_jal                ?  execute_alu_result                 : 
                              execute_need_jump   ?  execute_alu_result                 : 64'd0;


assign execute_commit_info = execute_need_jump ? {regE_commit_info[160], regE_commit_info[159:128], execute_jump_pc, regE_commit_info[WIDTH-1:0]} : regE_commit_info;


//commite_info
endmodule
//branch




