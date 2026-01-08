
#include "simulator_state.h"
#include <dlfcn.h>
#include <utils.h>
#include <common.h>
#include <defs.h>
#include <debug.h>
#include <cpu.h>
typedef struct {
    int id;
    const char *name;
} csr_map_t;

// 将你 enum 中定义的 CSR 罗列在此
static const csr_map_t target_csrs[] = {
    {0xc00, "cycle"},    {0xc01, "timer"},     {0xc02, "instret"},
    {0x100, "sstatus"},  {0x104, "sie"},       {0x105, "stvec"},      {0x106, "scounteren"},
    {0x140, "sscratch"}, {0x141, "sepc"},      {0x142, "scause"},     {0x143, "stval"}, {0x144, "sip"},
    {0x180, "satp"},
    {0xf11, "mvendorid"}, {0xf12, "marchid"},  {0xf13, "mimpid"},     {0xf14, "mhartid"}, {0xf15, "mconfigptr"},
    {0x300, "mstatus"},   {0x301, "misa"},     {0x302, "medeleg"},    {0x303, "mideleg"}, {0x304, "mie"}, {0x305, "mtvec"}, {0x306, "mcounteren"},
    {0x340, "mscratch"},  {0x341, "mepc"},     {0x342, "mcause"},     {0x343, "mtval"}, {0x344, "mip"},
    {0xb00, "mcycle"},    {0xb02, "minstret"}, {0x7a0, "tselect"},    {0x7a1, "tdata1"},
    {0x3a0, "pmpcfg0"},   {0x3a1, "pmpcfg1"},  {0x3a2, "pmpcfg2"},    {0x3a3, "pmpcfg3"},
    {0x3b0, "pmpaddr0"},  {0x3b1, "pmpaddr1"}, {0x3b2, "pmpaddr2"},   {0x3b3, "pmpaddr3"},
    {0x3b4, "pmpaddr4"},  {0x3b5, "pmpaddr5"}, {0x3b6, "pmpaddr6"},   {0x3b7, "pmpaddr7"},
    {0x3b8, "pmpaddr8"},  {0x3b9, "pmpaddr9"}, {0x3ba, "pmpaddr10"},  {0x3bb, "pmpaddr11"},
    {0x3bc, "pmpaddr12"}, {0x3bd, "pmpaddr13"}, {0x3be, "pmpaddr14"}, {0x3bf, "pmpaddr15"}
};

#define NR_TARGET_CSR (sizeof(target_csrs) / sizeof(target_csrs[0]))

void (*ref_difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;
#ifdef CONFIG_DIFFTEST
extern CPU_state cpu;
extern SIMState sim_state;

//这两个函数暂时没有用到，不管了
static bool is_skip_ref = false;
static int skip_dut_nr_inst = 0;
void difftest_skip_ref() {
  is_skip_ref = true;
  skip_dut_nr_inst = 0;
}
void difftest_skip_dut(int nr_ref, int nr_dut) {
  skip_dut_nr_inst += nr_dut;
  while (nr_ref -- > 0) {
    ref_difftest_exec(1);
  }
}



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

  printf("img_size=%ld\n",img_size);
  printf("RESET_VECTOR=%lx\n", RESET_VECTOR);


  //执行spike的difftest_memcpy函数，将处理器的内存写入到spike里面
  ref_difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_size, DIFFTEST_TO_REF); 
  //执行spike的difftest_regcpy函数，将处理器的寄存器写入到spike里面
  ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);  
  Log("Difftest已打开");
}

static void display_diff_error(CPU_state *ref, u64 pc, u64 next_pc, const char *msg) {
    printf("\n%-9s\n", ANSI_FMT("DIFFTEST ERROR", ANSI_FG_YELLOW ANSI_BG_RED));         
//    instr_coverage_display();
    
    printf("[NPC] 执行完pc=[0x%016lx]处的指令后出错。错误原因: %s\n", pc, msg);
    printf("[NPC] PC 状态: [参考 REF.pc]=0x%016lx, [你的 DUT.pc]=0x%016lx\n", ref->pc, next_pc);
    instr_itrace_display();

    // 2. 对比寄存器数据
    printf("\n----------- 寄存器状态对比 (REF vs DUT) -----------\n");
    for (int i = 0; i < 32; i++) {
        bool mismatch = (ref->gpr[i] != cpu.gpr[i]);
        const char* color = mismatch ? ANSI_FG_RED : "";
        // 只在有差异的行前加一个 '*' 符号，方便快速定位
        printf("%s%c [REF.%-3s]=0x%016lx | [DUT.%-3s]=0x%016lx%s\n", 
               color, mismatch ? '*' : ' ', reg_name(i), ref->gpr[i], reg_name(i), cpu.gpr[i], ANSI_NONE);
    }


    npc_single_cycle();
    npc_close_simulation();
    Log("[NPC] Difftest 终止，请检查上述差异。\n");
    exit(1);
}
static void checkcsrs(CPU_state *ref, u64 pc, u64 next_pc) {
    for (int i = 0; i < NR_TARGET_CSR; i++) {
        int id = target_csrs[i].id;
        const char *name = target_csrs[i].name;
        if( id == cycle || id==timer || instret) {
            continue;
        }
        // if (id == mcycle || id == minstret || id == cycle || id == timer || id == instret) {
        //     continue;
        // }
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
        display_diff_error(ref, pc, next_pc, "PC 轨迹不一致");
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

#define GET_OPCODE(i) ((i) & 0x7f)
#define GET_FUNCT3(i) (((i) >> 12) & 0x7)
#define GET_RD(i)     (((i) >> 7) & 0x1f)

#define op_load  0b0000011
#define op_store 0b0100011
void difftest_step(commit_t *commit) {
    CPU_state ref_r;
    ref_difftest_exec(1);
    ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);

    uint32_t instr = commit->instr;
    uint32_t opcode = instr & 0b01111111;
    uint32_t funct3 = (instr >> 12) & 0b111;
        
    //load_store特殊处理一下
    if (opcode == op_load) {
        int rd = GET_RD(instr);
        int bytes = (1 << (funct3 & 0x3)); 

        u64 ref_mem_data = 0;
        ref_difftest_memcpy(commit->mem_addr, &ref_mem_data, bytes, DIFFTEST_TO_DUT);

        word_t dut_mem_data = commit->mem_rdata;

        word_t mask = (bytes == 8) ? -1ULL : (1ULL << (bytes * 8)) - 1;

        if ((dut_mem_data & mask) != (ref_mem_data & mask)) {
            printf("\n[Difftest Error] Load Data Mismatch at PC = 0x%lx\n", commit->pc);
            printf("load error: 指令希望读取内存地址%lx处的%dbytes数据\n", commit->mem_addr, bytes);
            printf("DUT read from memory: 0x%lx\n", dut_mem_data & mask);
            printf("REF expected memory: 0x%lx\n", ref_mem_data & mask);
        }
        if (rd != 0) {
        }
    }
    //store
    if (opcode == op_store) {
        int bytes = (1 << (funct3 & 0x3));
        word_t spike_mem_val = 0;
        ref_difftest_memcpy(commit->mem_addr, &spike_mem_val, bytes, DIFFTEST_TO_DUT);
        word_t dut_mem_val = pmem_read(commit->mem_addr, bytes);
        word_t mask = (bytes == 8) ? -1ULL : (1ULL << (bytes * 8)) - 1;

        // 核心比对：DUT内存 vs REF内存
        if ((dut_mem_val & mask) != (spike_mem_val & mask)) {
            printf("\n[Difftest Error] Memory Consistency Mismatch at PC = 0x%lx\n", commit->pc);
            printf("Address: 0x%lx, Size: %d bytes\n", commit->mem_addr, bytes);
            printf("DUT Memory: 0x%lx | REF Memory: 0x%lx\n", 
                    dut_mem_val & mask, spike_mem_val & mask);
            Assert(0, "Store1");

                    sim_state.state = SIM_ABORT;
        }
        
        // 进阶比对：验证 DUT 提交的数据与 DUT 内存中的数据是否一致
        if ((commit->mem_wdata & mask) != (dut_mem_val & mask)) {
            printf("[Difftest Error] Commit Data Mismatch! WData: 0x%lx, pmem: 0x%lx\n",
                    commit->mem_wdata & mask, dut_mem_val & mask);
            Assert(0, "Store2");
            sim_state.state = SIM_ABORT;
        }
    }
    //
    checkregs(&ref_r, commit->pc, commit->next_pc);
    checkcsrs(&ref_r, commit->pc, commit->next_pc);
}


#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif