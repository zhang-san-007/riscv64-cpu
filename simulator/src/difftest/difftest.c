
#include "simulator_state.h"
#include <dlfcn.h>
#include <utils.h>
#include <common.h>
#include <defs.h>
#include <debug.h>
#include <cpu.h>
#include <riscv/decode.h>
void isa_reg_display();

void (*ref_difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;
#ifdef CONFIG_DIFFTEST
extern CPU_state cpu;
extern SIMState sim_state;


void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);
  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);


  //函数绑定
  //将函数ref_difftest_memcpy       绑定到spike的difftest_memcpy函数
  //将函数ref_difftest_regcpy       绑定到spike的difftest_regcpy函数
  //将函数ref_difftest_exec         绑定到spike的difftest_exec函数
  //将函数ref_difftest_raise_inst   绑定到spike的difftest_raise_instr函数
  //将函数ref_difftest_init         绑定到spike的difftest_init函数
  ref_difftest_memcpy =  (void (*)(paddr_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec =  (void (*)(uint64_t))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr = (void (*)(uint64_t))dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);

  void (*ref_difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port); //do nothing

  printf("RESET_VECTOR=%lx\n", RESET_VECTOR);

  //执行spike的difftest_memcpy函数，将处理器的内存写入到spike里面
  ref_difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_size, DIFFTEST_TO_REF); 
  //执行spike的difftest_regcpy函数，将处理器的寄存器写入到spike里面
  ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);  
  Log("Difftest已打开");
}





static void display_diff_error(CPU_state *ref, u64 pc, u64 next_pc, const char *msg) {
    printf("\n%-9s\n", ANSI_FMT("DIFFTEST ERROR", ANSI_FG_YELLOW ANSI_BG_RED));         
    instr_itrace_display();
    printf("[NPC] 执行完 pc=[0x%016lx] 处的指令后出错。错误原因: %s%s%s\n", pc, ANSI_FG_RED, msg, ANSI_NONE);
    bool pc_mismatch = (ref->pc != next_pc);
    const char* pc_color = pc_mismatch ? ANSI_FG_RED : "";
    printf("[NPC] PC 状态: %s%c [参考 REF.pc]=0x%016lx | [你的 DUT.pc]=0x%016lx%s\n", pc_color, pc_mismatch ? '*' : ' ', ref->pc, next_pc, ANSI_NONE);
    printf("\n----------- 寄存器状态对比 (REF vs DUT) -----------\n");
    for (int i = 0; i < 32; i++) {
        bool mismatch = (ref->gpr[i] != cpu.gpr[i]);
        const char* color = mismatch ? ANSI_FG_RED : "";
        printf("%s%c [REF.%-3s]=0x%016lx | [DUT.%-3s]=0x%016lx%s\n", color, mismatch ? '*' : ' ', reg_name(i), ref->gpr[i], reg_name(i), cpu.gpr[i], ANSI_NONE);
    }


    npc_single_cycle();
    npc_close_simulation();
    Log("[NPC] Difftest 终止，请检查上述差异。\n");
    exit(1);
}

static void checkcsrs(CPU_state *ref, u64 pc, u64 next_pc) {
    for (int i = 0; i < NR_TARGET_CSR; i++) {
        int id = csr_map[i].id;
        const char *name = csr_map[i].name;
        if( id == cycle || id== timer || instret) {
            continue;
        }
        if (ref->csr[id] != cpu.csr[id]) {
            char buf[128];
            snprintf(buf, sizeof(buf), "CSR [%s] (0x%03x) 数值不一致! \t[REF]=0x%016lx, [DUT]=0x%016lx", name, id, ref->csr[id], cpu.csr[id]);
            display_diff_error(ref, pc, next_pc, buf);
        }
    }
}
static void checkregs(CPU_state *ref, u64 pc, u64 next_pc) {
    // 1. 检查 PC 是否匹配    
    if (next_pc != ref->pc) {
        display_diff_error(ref, pc, next_pc, "PC 出现不一致");
    }
    // 2. 检查通用寄存器是否匹配
    for (int i = 0; i < 32; i++) {
        if (ref->gpr[i] != cpu.gpr[i]) {
            char buf[64];
            snprintf(buf, sizeof(buf), "寄存器 [%s] 数值不一致", reg_name(i));
            display_diff_error(ref, pc, next_pc, buf);
        }
    }

}

#include <stdint.h>
#include <assert.h>





void load_store_info_dispaly(commit_t *commit, const char *msg){
    // if(strcmp(msg,"MMIO") == 0){

    // }else if(strcmp(msg,"RAM")==0){
    // }
    // u32 opcode = GET_OPCODE(commit->instr);
    // if(opcode == op_load){

    // }

    // //store    if (opcode == op_store && !is_mmio) {
    //     int bytes = (1 << (func3 & 0x3));
    //     word_t spike_mem_val = 0;
    //     ref_difftest_memcpy(commit->mem_addr, &spike_mem_val, bytes, DIFFTEST_TO_DUT);
    //     word_t dut_mem_val = pmem_read(commit->mem_addr, bytes);
    //     word_t mask = (bytes == 8) ? -1ULL : (1ULL << (bytes * 8)) - 1;

    //     if ((dut_mem_val & mask) != (spike_mem_val & mask)) {
    //         printf("\n[Difftest Error] Memory Consistency Mismatch at PC = 0x%lx\n", commit->pc);
    //         printf("Address: 0x%lx, Size: %d bytes\n", commit->mem_addr, bytes);
    //         printf("DUT Memory: 0x%lx | REF Memory: 0x%lx\n", 
    //                 dut_mem_val & mask, spike_mem_val & mask);
    //         Assert(0, "Store1");

    //                 sim_state.state = SIM_ABORT;
    //     }        
    //     if ((commit->mem_wdata & mask) != (dut_mem_val & mask)) {
    //         printf("[Difftest Error] Commit Data Mismatch! WData: 0x%lx, pmem: 0x%lx\n",
    //                 commit->mem_wdata & mask, dut_mem_val & mask);
    //         Assert(0, "Store2");
    //         sim_state.state = SIM_ABORT;
    //     }
    // }
    // if (opcode == op_load) {
    //     int rd = GET_RD(instr);
    //     int bytes = (1 << (funct3 & 0x3)); 

    //     u64 ref_mem_data = 0;
    //     ref_difftest_memcpy(commit->mem_addr, &ref_mem_data, bytes, DIFFTEST_TO_DUT);

    //     word_t dut_mem_data = commit->mem_rdata;
    //     word_t mask = (bytes == 8) ? -1ULL : (1ULL << (bytes * 8)) - 1;
    //     if ((dut_mem_data & mask) != (ref_mem_data & mask)) {
    //         printf("\n[Difftest Error] Load Data Mismatch at PC = 0x%lx\n", commit->pc);
    //         printf("load error: 指令希望读取内存地址%lx处的%dbytes数据\n", commit->mem_addr, bytes);
    //         printf("DUT read from memory: 0x%lx\n", dut_mem_data & mask);
    //         printf("REF expected memory: 0x%lx\n", ref_mem_data & mask);
    //     }
}

static inline bool is_mmio_address(uint64_t addr) {
    return (addr < 0x80000000) && (addr >= 0x02000000);
}
bool is_special_instr(const decode_t *decode) {
    const i32 load_store_bytes = (1 << (decode->func3 & 0x3));
    const u32 opcode  = decode->opcode;
    const u32 func3   = decode->func3;
    const u32 csr_id  = decode->csr_id;
    //commit
    const u64 pc         = decode->pc;
    const u32 instr      = decode->instr;
    const u64 mem_addr   = decode->mem_addr;
    const u64 mem_wdata  = decode->mem_wdata;
    const u64 mem_rdata  = decode->mem_rdata;

    bool is_mmio = is_mmio_address(mem_addr);
    bool special_instr = false;;
    switch(decode->opcode){
        case op_load:
            if(is_mmio){
//                printf("\033[1;33m[MMIO Load ]\033[0m PC: 0x%016lx | Instr: 0x%08x | Addr: 0x%016lx | Len: %d\n", pc, instr, mem_addr, load_store_bytes);
                special_instr = true;
            }
            break;
        case op_store:
            if(is_mmio){
//                printf("\033[1;36m[MMIO Store]\033[0m PC: 0x%016lx | Instr: 0x%08x | Addr: 0x%016lx | WData: 0x%016lx | Len: %d\n", pc, instr, mem_addr, mem_wdata, load_store_bytes);
                special_instr = true;
            }
            break;
        case op_csr:
            if(func3  == func3010 && csr_id == timer) {
                special_instr = true;
            }
            break;  
    default:
            break;
    }
    return special_instr;
}


void check_load_store_instr(){
}


void instr_decode(decode_t * decode, const commit_t *commit){    
    decode->pc          = commit->pc;
    decode->next_pc     = commit->next_pc;
    decode->instr       = commit->instr;
    decode->mem_addr    = commit->mem_addr;
    decode->mem_wdata   = commit->mem_wdata;
    decode->mem_rdata   = commit->mem_rdata;
    u32 instr = commit->instr;
    decode->opcode      = GET_OPCODE(instr);     //GET_OPCODE
    decode->csr_id      = GET_CSR_ID(instr);
    decode->func3       = GET_FUNC3 (instr);
    decode->func7       = GET_FUNC7 (instr);
    decode->rd          = GET_RD    (instr);
};

void difftest_step(const commit_t *commit) {
    CPU_state ref_r;
    decode_t decode;
    instr_decode(&decode, commit);
//     if(cpu.gpr[15] == 0x0000000080025000){
// //        isa_reg_display(&cpu, "debug");
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_single_cycle();
//         // npc_close_simulation();
//         // Log("[NPC] Difftest 终止，请检查上述差异。\n");
//         // exit(1);   
//     }

    ref_difftest_exec(1);    
    if(is_special_instr(&decode)){
        cpu.pc=decode.next_pc;
        ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);
    }
    ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
    check_load_store_instr();
    checkregs(&ref_r, decode.pc, decode.next_pc);
    checkcsrs(&ref_r, decode.pc, decode.next_pc);
}


#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif



//load_store指令
    //内存加强检测  
    //mmio特殊处理
//普通指令
//csr指令 特殊处理
//