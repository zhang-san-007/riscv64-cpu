#include <types.h>
u64 sim_clk_count   = 0;
u64 sim_instr_count = 0;


u64  get_sim_clk_count()      {  return sim_clk_count;    }
void update_sim_clk_count()   {         sim_clk_count++;  } 
void update_instr_count()     {         sim_instr_count++;}

bool instr_exec_one_million(){
  return (sim_instr_count % 1000000 == 0);
}  

