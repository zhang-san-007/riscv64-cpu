#include <common.h>
#include <riscv.h>

void instr_decode(decode_t * decode, u32 instr){    
    decode->opcode      = GET_OPCODE(instr);     //GET_OPCODE
    decode->csr_id      = GET_CSR_ID(instr);
    decode->func3       = GET_FUNC3 (instr);
    decode->func7       = GET_FUNC7 (instr);
    decode->rd          = GET_RD    (instr);
};
