#include <riscv.h>
#include <common.h> //types.h
#include <defs.h>
#include <npc.h>

extern TOP_NAME dut;  		

#include <types.h>
u64 sim_clk_count   = 0;
u64 sim_instr_count = 0;


u64  get_sim_clk_count()      {  return sim_clk_count;    }
void update_sim_clk_count()   {         sim_clk_count++;  } 
void update_instr_count()     {         sim_instr_count++;}




void check_ebreak(const commit_t *commit) {
    if (commit->instr == inst_ebreak) { 
        printf("\n\033[1;33m[NEMU Trap]\033[0m HIT ebreak at pc = 0x%016lx\n", commit->pc);
        printf("Termination: ebreak encountered. Simulation stops as per protocol.\n");
        sim_exit("hit ebreak");
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

    sim_instr_count++;
    if(sim_instr_count % 1000000 == 0){
      printf("处理器已经执行了%ld条指令\n", sim_instr_count);
    }

    instr_trace_dispatch(commit.pc, commit.instr, sim_instr_count);
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


