#include <common.h>
#include <cstdint>
#include <defs.h>
#include <cpu.h>

CPU_state cpu; 
u64 *reg_ptr = NULL;
u64 *csr_ptr = NULL;

const char *regs[] = {
  "$0", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
  "s0", "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
  "a6", "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

int check_reg_idx(int idx) {
  assert(idx >= 0 && idx < GPR_NUM);
  return idx;
}
int check_csr_idx(int idx){
  assert(idx >= 0 && idx < CSR_NUM);
  return idx;
}
const char* reg_name(int idx) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}




void isa_reg_display(CPU_state *state, const char *msg) {
    const char *prefix = (msg != NULL) ? msg : "CPU";

    printf("\n--- Reg [%s] ---\n", prefix);
    for (int i = 0; i < GPR_NUM; i++) {
        printf("%-4s: 0x%016lx\n", reg_name(i), state->gpr[i]);
    }
    printf("pc  : 0x%016lx\n", state->pc);
    printf("--------------------------------------\n");
}



const csr_map_t csr_map[] = {
    // User Mode Counters
    {0xc00, "cycle"},      {0xc01, "timer"},     {0xc02, "instret"},

    // Supervisor Mode Registers
    {0x100, "sstatus"},    {0x104, "sie"},       {0x105, "stvec"},     {0x106, "scounteren"},
    {0x140, "sscratch"},   {0x141, "sepc"},      {0x142, "scause"},    {0x143, "stval"},     {0x144, "sip"},
    {0x180, "satp"},

    // Machine Mode Information
    {0xf11, "mvendorid"},  {0xf12, "marchid"},   {0xf13, "mimpid"},    {0xf14, "mhartid"},   {0xf15, "mconfigptr"},

    // Machine Mode Setup & Control
    {0x300, "mstatus"},    {0x301, "misa"},      {0x302, "medeleg"},   {0x303, "mideleg"}, 
    {0x304, "mie"},        {0x305, "mtvec"},     {0x306, "mcounteren"},
    {0x340, "mscratch"},   {0x341, "mepc"},      {0x342, "mcause"},    {0x343, "mtval"},     {0x344, "mip"},
    {0xb00, "mcycle"},     {0xb02, "minstret"},

    // Debug / Trigger
    {0x7a0, "tselect"},    {0x7a1, "tdata1"},

    // PMP Configuration
    {0x3a0, "pmpcfg0"},    {0x3a1, "pmpcfg1"},   {0x3a2, "pmpcfg2"},   {0x3a3, "pmpcfg3"},

    // PMP Addresses
    {0x3b0, "pmpaddr0"},   {0x3b1, "pmpaddr1"},  {0x3b2, "pmpaddr2"},  {0x3b3, "pmpaddr3"},
    {0x3b4, "pmpaddr4"},   {0x3b5, "pmpaddr5"},  {0x3b6, "pmpaddr6"},  {0x3b7, "pmpaddr7"},
    {0x3b8, "pmpaddr8"},   {0x3b9, "pmpaddr9"},  {0x3ba, "pmpaddr10"}, {0x3bb, "pmpaddr11"},
    {0x3bc, "pmpaddr12"},  {0x3bd, "pmpaddr13"}, {0x3be, "pmpaddr14"}, {0x3bf, "pmpaddr15"}
};

const int NR_TARGET_CSR = sizeof(csr_map) / sizeof(csr_map[0]);
void isa_csr_display(CPU_state *state, const char *msg) {
    printf("---------- CSR Debug Dump (%s) ----------\n", msg);

    int nr_csr = sizeof(csr_map) / sizeof(csr_map[0]);
    for (int i = 0; i < nr_csr; i++) {
        uint32_t id = csr_map[i].id;
        const char *name = csr_map[i].name;

        // 直接从 state->csr 数组中根据 ID 取值
        // 假设 state->csr 是 word_t csr[4096]
        word_t val = state->csr[id];

        // 打印格式：名称[ID] = 16进制值
        // 使用 %-10s 让名称左对齐，确保列对齐
        printf("%-10s [0x%03x] = 0x%016lx", name, id, (uint64_t)val);

        // 每行打印两个，美观且易于对比
        if ((i + 1) % 2 == 0) {
            printf("\n");
        } else {
            printf("    "); // 间距
        }
    }

    // 如果总数是奇数，补一个换行
    if (nr_csr % 2 != 0) printf("\n");

    printf("------------------------------------------\n");
}