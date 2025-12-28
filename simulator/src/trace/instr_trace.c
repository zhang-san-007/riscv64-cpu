#include <cpu.h>
#include <cstdint>
#include <simulator_state.h>
#include <common.h>
#include <defs.h>
#define instr_max_size 100
void instr_trace(word_t pc, word_t instr) {
    char inst_str[instr_max_size];
    disassemble(inst_str,instr_max_size, pc, (uint8_t *)&instr, 8);
    IFDEF(CONFIG_INS_TRACE,printf("处理器执行了pc=[0x%lx]处的指令instr=[0x%08lx], 其反汇编=[%s]\n", pc, instr, inst_str));
}