#include <common.h> //types.h
#include <riscv.h>
#include <difftest.h>
#include <defs.h>


void check_ebreak(const commit_t *commit){
  if(commit->instr == inst_ebreak){
    instr_trace(    commit->pc , commit->instr);
    printf("由于仿真框架将[ebreak]指令看作是程序结束的指令，执行[ebreak]指令之后，我们退出程序\n");
    sim_state.state = SIM_END;
  }

}

//si 1执行一条指令就确定是一次commit, 而不是多次clk
void execute(uint64_t n){
  for (   ;n > 0; n --) {
    CPU_state gold_cpu;
    memcpy(&gold_cpu, &cpu, sizeof(CPU_state));

    while(dut.commit != 1){      
      npc_single_cycle();
    }
    // get_commit_info(&dut_diff.commit, &dut);
    // get_decode_info(&dut_diff.decode, dut_diff.commit.instr);

    npc_single_cycle();                  
    update_cpu_state();
    // get_cpu_info  (&dut_diff.cpu, cpu);

    // if(inst_exec_one_million()){
    //   printf("已经执行了%ld条指令\n", g_nr_guest_inst);
    // }
    // IFDEF(CONFIG_TRACE_LOG, instr_trace_log(commit.pc, commit.instr));
    // IFDEF(CONFIG_ITRACE,    instr_itrace(commit.pc , commit.instr));
    // IFDEF(CONFIG_DIFFTEST,  difftest_step(&commit));  
    
  }
}

void statistic() {
  npc_close_simulation();
  #define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("你的处理器执行了" NUMBERIC_FMT "条指令(不含nop指令)", g_nr_guest_inst);
  Log("你的处理器执行了" NUMBERIC_FMT "个时钟周期", clk_count);
  if (g_timer > 0) {
    Log("你处理器的执行频率是" NUMBERIC_FMT " instr/s", g_nr_guest_inst * 1000000 / g_timer);
  }else{
    Log("Finish running in less than 1 us and can not calculate the simulation frequency");
  }
}
void cpu_exec(uint64_t n) {
  switch (sim_state.state) {
    case SIM_END: 
    case SIM_ABORT:
      printf("Program execution has ended. To restart the program, exit  and run again.\n");
      return;
    default: sim_state.state = SIM_RUNNING;
  }
  uint64_t timer_start = get_time();
  execute(n); 

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (sim_state.state) {
    case SIM_RUNNING: sim_state.state = SIM_STOP; break;
    case SIM_END: 
    case SIM_ABORT:
      Log("SIM: %s at pc = [pc值信息有误,待修复]" FMT_WORD,
          (sim_state.state == SIM_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
          (sim_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
          ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          sim_state.halt_pc);
    case SIM_QUIT: 
        statistic();
  }
}

void sim_exit(const char *msg){
    npc_single_cycle();
    npc_close_simulation();
    Log("%s\n", msg);
    exit(1);
}