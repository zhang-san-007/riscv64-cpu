#include <difftest.h>
#include <npc.h>


void get_commit_info(commit_t * commit, TOP_NAME *dut){
    commit->pc         = dut->commit_pc;
    commit->next_pc    = dut->commit_next_pc;
    commit->instr      = dut->commit_instr;
    commit->mem_addr   = dut->commit_mem_addr;
    commit->mem_rdata  = dut->commit_mem_rdata;
    commit->mem_wdata  = dut->commit_mem_wdata;
}