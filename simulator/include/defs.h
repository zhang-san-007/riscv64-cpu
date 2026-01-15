#ifndef  DEFS_H_
#define  DEFS_H_
#include <cpu.h>
#include <common.h>
void 		engine_start();
int  		is_exit_status_bad();
void set_sim_state(int state, vaddr_t pc, int halt_ret);
#define SIMTRAP(thispc, code) set_sim_state(SIM_END, thispc, code)


//sdb.c
void 		sdb_set_batch_mode();

//cpu.c
void 		cpu_exec(uint64_t n);
const char* reg_name(int idx);
int 	check_reg_idx(int idx);
int 	check_csr_idx(int idx);
void isa_csr_display(CPU_state *, const char *);
void isa_reg_display(CPU_state *, const char *);
#define pc_self  (cpu.pc)
#define gpr(idx) (cpu.gpr[check_reg_idx(idx)])
#define csr(idx) (cpu.csr[check_csr_idx(idx)])
void 		get_cpu_state_from_npc();
void 		init_regex();




//init_monitor.c
void 		init_monitor(int , char **);
void 		init_log(const char *log_file);
void 		init_difftest(char *ref_so_file, long img_size, int port);
void 		init_disasm(const char *triple);
void 		init_trace();
void 		disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

//timer.c
void		init_rand();



//disasm.cc
void        difftest_step(const commit_t *commit);
bool        isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc);


uint64_t get_time();

//npc.c
void npc_open_simulation();
void npc_close_simulation();
void update_cpu_state();
void npc_single_cycle();
void npc_reset(int n);
void npc_init();
void npc_exec_once();
void npc_get_clk_count();

//memory.c
void 	 init_mem();
uint8_t* guest_to_host(paddr_t paddr);
word_t	 pmem_read(paddr_t addr, int len);
void	 pmem_write(paddr_t addr, int len, word_t data);
//trace----->instr_trace
void     instr_trace(u64 pc, u32 commit_instr);
void     instr_itrace_display();
void     instr_itrace(u64 pc, u32 instr);
void     instr_trace_log(u64 pc, u32 instr);

//trace---->instr_profile
void instr_coverage_display();
void mark_instr_executed(u32 instr);

//sim
void     sim_exit(const char *msg);

#endif
