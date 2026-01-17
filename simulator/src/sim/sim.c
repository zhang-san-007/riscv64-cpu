#include <riscv.h>
#include <common.h>
#include <defs.h>

void sim_exit(const char *msg){
    npc_single_cycle();
    npc_close_simulation();
    Log("%s\n", msg);
    exit(1);
}