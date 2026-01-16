
#include <sim_state.h>
#include <dlfcn.h>
#include <utils.h>
#include <stdint.h>
#include <assert.h>
#include <common.h>
#include <defs.h>
#include <debug.h>

#include <riscv/riscv.h>



void (*ref_difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;
void isa_reg_display(CPU_state *state, const char *msg);

#ifdef CONFIG_DIFFTEST
extern CPU_state cpu;
extern SIMState sim_state;


void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);
  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);
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
    sim_exit("[NPC] Difftest 终止，请检查上述差异。");
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
    if (next_pc != ref->pc) {
        display_diff_error(ref, pc, next_pc, "PC 出现不一致");
    }
    for (int i = 0; i < 32; i++) {
        if (ref->gpr[i] != cpu.gpr[i]) {
            char buf[64];
            snprintf(buf, sizeof(buf), "寄存器 [%s] 数值不一致", reg_name(i));
            display_diff_error(ref, pc, next_pc, buf);
        }
    }

}






void load_store_info_dispaly(commit_t *commit, const char *msg){
}

static inline bool is_mmio_address(uint64_t addr) {
    return (addr < 0x80000000) && (addr >= 0x10000000);
}

bool is_special_instr(const decode_t *decode) {
    // const i32 load_store_bytes = (1 << (decode->func3 & 0x3));
    // const u32 opcode  = decode->opcode;
    // const u32 func3   = decode->func3;
    // const u32 csr_id  = decode->csr_id;
    // //commit
    // // const u64 pc         = decode->pc;
    // // const u32 instr      = decode->instr;
    // // const u64 mem_addr   = decode->mem_addr;
    // // const u64 mem_wdata  = decode->mem_wdata;
    // // const u64 mem_rdata  = decode->mem_rdata;

    // bool is_mmio = is_mmio_address(mem_addr);
    // bool special_instr = false;;
    // switch(decode->opcode){
    //     case op_load:
    //         if(is_mmio){
    //             IFDEF(CONFIG_DIFFTEST_MMIO_DEBUG, log_write("[1;33m[MMIO Load ] [0m PC: 0x%016lx | Instr: 0x%08x | Addr: 0x%016lx | Len: %d\n", pc, instr, mem_addr, load_store_bytes));
    //             special_instr = true;
    //         }
    //         break;
    //     case op_store:
    //         if(is_mmio){
    //             IFDEF(CONFIG_DIFFTEST_MMIO_DEBUG, log_write("[1;36m[MMIO Store] [0m PC: 0x%016lx | Instr: 0x%08x | Addr: 0x%016lx | WData: 0x%016lx | Len: %d\n", pc, instr, mem_addr, mem_wdata, load_store_bytes));
    //             special_instr = true;
    //         }
    //         break;
    //     case op_csr:
    //         // if(func3  == func3010 && csr_id == timer) {
    //         //     special_instr = true;
    //         // }
    //         break;  
    // default:
    //         break;
    // }
    // return special_instr;
}


void check_load_store_instr(){
}




void difftest_step(const commit_t *commit) {
    CPU_state ref_r;
    decode_t decode;
//    instr_decode(&decode, commit);

    ref_difftest_exec(1);    
    if(is_special_instr(&decode)){
//        cpu.pc=decode.next_pc;
        ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);
    }
    ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
    check_load_store_instr();
    // checkregs(&ref_r, decode.pc, decode.next_pc);
    // checkcsrs(&ref_r, decode.pc, decode.next_pc);
}


#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif


