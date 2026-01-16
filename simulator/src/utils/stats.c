#include <types.h>



u64 g_nr_guest_inst = 0;
void update_instr_count(){
    g_nr_guest_inst++;
}
bool inst_exec_one_million(){
  return (g_nr_guest_inst % 1000000 == 0);
}  

