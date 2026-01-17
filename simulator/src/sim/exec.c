#include <riscv.h>
#include <common.h> //types.h
#include <defs.h>
#include <npc.h>

extern TOP_NAME dut;  		

void check_ebreak(const commit_t *commit){
  if(commit->instr == inst_ebreak){
    instr_trace(    commit->pc , commit->instr);
    printf("由于仿真框架将[ebreak]指令看作是程序结束的指令，执行[ebreak]指令之后，我们退出程序\n");
    sim_state.state = SIM_END;
  }

}

void get_commit_info(commit_t * commit){
    commit->pc         = dut.commit_pc;
    commit->next_pc    = dut.commit_next_pc;
    commit->instr      = dut.commit_instr;
    commit->mem_addr   = dut.commit_mem_addr;
    commit->mem_rdata  = dut.commit_mem_rdata;
    commit->mem_wdata  = dut.commit_mem_wdata;
}
void get_decode_info(decode_t * decode, u32 instr){
    decode->opcode  = GET_OPCODE(instr);
    decode->csr_id  = GET_CSR_ID(instr);
    decode->func3   = GET_FUNC3(instr);
    decode->func7   = GET_FUNC7(instr);
    decode->rd      = GET_RD(instr);
}
void get_cpu_info(CPU_state * diff_cpu){
  diff_cpu->pc= cpu.pc;
  memcpy(diff_cpu->gpr, cpu.gpr, sizeof(diff_cpu->gpr));
  memcpy(diff_cpu->csr, cpu.csr, sizeof(diff_cpu->csr));
}

//si 1执行一条指令就确定是一次commit, 而不是多次clk
void execute(uint64_t n){
  for (   ;n > 0; n --) {
    // CPU_state gold_cpu;
    // memcpy(&gold_cpu, &cpu, sizeof(CPU_state));

    commit_t commit = {0};
    while(dut.commit != 1){      
      npc_single_cycle();
    }
    get_commit_info(&commit);
    check_ebreak(&commit);

    npc_single_cycle();                  
    update_cpu_state();    
    IFDEF(CONFIG_TRACE_LOG, instr_trace_log(commit.pc, commit.instr));
    IFDEF(CONFIG_ITRACE,    instr_itrace(   commit.pc , commit.instr));
    IFDEF(CONFIG_DIFFTEST,  difftest_step(&commit));  
    
  }
}

void cpu_exec(uint64_t n) {
  uint64_t timer_start = get_time();
  execute(n); 
  uint64_t timer_end = get_time();
  u64 sim_time = timer_end - timer_start;

  printf("模拟器执行阶数，模拟器执行的时间为%ld", sim_time);
}


