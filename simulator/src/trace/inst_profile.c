#include <common.h>
#include <utils.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

// --- Opcode 宏定义 ---
#define op_lui         0b0110111
#define op_auipc       0b0010111
#define op_jalr        0b1100111
#define op_jal         0b1101111
#define op_alu_reg     0b0110011
#define op_alu_reg_w   0b0111011
#define op_alu_imm     0b0010011
#define op_alu_imm_w   0b0011011
#define op_load        0b0000011
#define op_store       0b0100011
#define op_branch      0b1100011
#define op_system      0b1110011
#define op_fence       0b0001111
#define op_amo         0b0101111

// --- 指令覆盖记录结构体 ---
typedef struct {
    bool inst_unknown;
    uint32_t last_unknown_val;
    
    bool inst_lui, inst_auipc, inst_jal, inst_jalr;

    struct {
        bool inst_beq, inst_bne, inst_blt, inst_bge, inst_bltu, inst_bgeu;
    } branch;

    struct {
        bool inst_lb, inst_lh, inst_lw, inst_ld, inst_lbu, inst_lhu, inst_lwu;
        bool inst_sb, inst_sh, inst_sw, inst_sd;
    } load_store;

    struct {
        bool inst_addi, inst_slti, inst_sltiu, inst_xori, inst_ori, inst_andi, inst_slli, inst_srli, inst_srai;
        bool inst_addiw, inst_slliw, inst_srliw, inst_sraiw;
        bool inst_add, inst_sub, inst_sll, inst_slt, inst_sltu, inst_xor, inst_srl, inst_sra, inst_or, inst_and;
        bool inst_addw, inst_subw, inst_sllw, inst_srlw, inst_sraw;
    } alu;

    struct {
        bool inst_mul, inst_mulh, inst_mulhsu, inst_mulhu, inst_div, inst_divu, inst_rem, inst_remu;
        bool inst_mulw, inst_divw, inst_divuw, inst_remw, inst_remuw;
    } mul_div;

    struct {
        bool inst_lrw, inst_scw, inst_amoswapw, inst_amoaddw, inst_amoxorw, inst_amoandw, inst_amoorw, inst_amominw, inst_amomaxw, inst_amominuw, inst_amomaxuw; 
        bool inst_lrd, inst_scd, inst_amoswapd, inst_amoaddd, inst_amoxord, inst_amoandd, inst_amoord, inst_amomind, inst_amomaxd, inst_amominud, inst_amomaxud;
    } amo;

    struct {
        bool inst_csrrw, inst_csrrs, inst_csrrc, inst_csrrwi, inst_csrrsi, inst_csrrci;
        bool inst_ecall, inst_ebreak, inst_uret, inst_sret, inst_mret, inst_wfi, inst_sfence_vma;
    } system;

    struct {
        bool inst_fence, inst_fence_i;
    } fence;
} InstExisted;

static InstExisted g_existed = {0};

#define MARK_UNKNOWN(instr_val) do { g_existed.inst_unknown = true; g_existed.last_unknown_val = instr_val; } while(0)

// --- 核心译码标记函数 ---
void mark_instr_executed(uint32_t instr) {
    uint32_t opcode = instr & 0x7F;
    uint32_t f3     = (instr >> 12) & 0x7;
    uint32_t f7     = (instr >> 25) & 0x7F;
    uint32_t f5_amo = (instr >> 27) & 0x1F;

    switch (opcode) {
        case op_lui:   g_existed.inst_lui   = true; break;
        case op_auipc: g_existed.inst_auipc = true; break;
        case op_jal:   g_existed.inst_jal   = true; break;
        case op_jalr:  g_existed.inst_jalr  = true; break;

        case op_branch:
            switch (f3) {
                case 0b000: g_existed.branch.inst_beq  = true; break;
                case 0b001: g_existed.branch.inst_bne  = true; break;
                case 0b100: g_existed.branch.inst_blt  = true; break;
                case 0b101: g_existed.branch.inst_bge  = true; break;
                case 0b110: g_existed.branch.inst_bltu = true; break;
                case 0b111: g_existed.branch.inst_bgeu = true; break;
                default:    MARK_UNKNOWN(instr); break;
            } break;

        case op_load:
            switch (f3) {
                case 0b000: g_existed.load_store.inst_lb  = true; break;
                case 0b001: g_existed.load_store.inst_lh  = true; break;
                case 0b010: g_existed.load_store.inst_lw  = true; break;
                case 0b011: g_existed.load_store.inst_ld  = true; break;
                case 0b100: g_existed.load_store.inst_lbu = true; break;
                case 0b101: g_existed.load_store.inst_lhu = true; break;
                case 0b110: g_existed.load_store.inst_lwu = true; break;
                default:    MARK_UNKNOWN(instr); break;
            } break;

        case op_store:
            switch (f3) {
                case 0b000: g_existed.load_store.inst_sb = true; break;
                case 0b001: g_existed.load_store.inst_sh = true; break;
                case 0b010: g_existed.load_store.inst_sw = true; break;
                case 0b011: g_existed.load_store.inst_sd = true; break;
                default:    MARK_UNKNOWN(instr); break;
            } break;

        case op_alu_imm:
            switch (f3) {
                case 0b000: g_existed.alu.inst_addi = true; break;
                case 0b001: g_existed.alu.inst_slli = true; break;
                case 0b010: g_existed.alu.inst_slti = true; break;
                case 0b011: g_existed.alu.inst_sltiu = true; break;
                case 0b100: g_existed.alu.inst_xori = true; break;
                case 0b110: g_existed.alu.inst_ori = true; break;
                case 0b111: g_existed.alu.inst_andi = true; break;
                case 0b101: 
                    if (f7 == 0b0000000)      g_existed.alu.inst_srli = true; 
                    else if (f7 == 0b0100000) g_existed.alu.inst_srai = true;
                    else MARK_UNKNOWN(instr); 
                    break;
                default:    MARK_UNKNOWN(instr); break;
            } break;

        case op_alu_imm_w:
            switch (f3) {
                case 0b000: g_existed.alu.inst_addiw = true; break;
                case 0b001: g_existed.alu.inst_slliw = true; break;
                case 0b101:
                    if (f7 == 0b0000000)      g_existed.alu.inst_srliw = true; 
                    else if (f7 == 0b0100000) g_existed.alu.inst_sraiw = true;
                    else MARK_UNKNOWN(instr);
                    break;
                default:    MARK_UNKNOWN(instr); break;
            } break;

        case op_alu_reg:
            if (f7 == 0b0000001) {
                switch (f3) {
                    case 0b000: g_existed.mul_div.inst_mul = true; break;
                    case 0b001: g_existed.mul_div.inst_mulh = true; break;
                    case 0b010: g_existed.mul_div.inst_mulhsu = true; break;
                    case 0b011: g_existed.mul_div.inst_mulhu = true; break;
                    case 0b100: g_existed.mul_div.inst_div = true; break;
                    case 0b101: g_existed.mul_div.inst_divu = true; break;
                    case 0b110: g_existed.mul_div.inst_rem = true; break;
                    case 0b111: g_existed.mul_div.inst_remu = true; break;
                    default:    MARK_UNKNOWN(instr); break;
                }
            } else {
                switch (f3) {
                    case 0b000: if (f7 == 0x00) g_existed.alu.inst_add = true; else if (f7 == 0x20) g_existed.alu.inst_sub = true; else MARK_UNKNOWN(instr); break;
                    case 0b001: g_existed.alu.inst_sll = true; break;
                    case 0b010: g_existed.alu.inst_slt = true; break;
                    case 0b011: g_existed.alu.inst_sltu = true; break;
                    case 0b100: g_existed.alu.inst_xor = true; break;
                    case 0b101: if (f7 == 0x00) g_existed.alu.inst_srl = true; else if (f7 == 0x20) g_existed.alu.inst_sra = true; else MARK_UNKNOWN(instr); break;
                    case 0b110: g_existed.alu.inst_or = true; break;
                    case 0b111: g_existed.alu.inst_and = true; break;
                    default:    MARK_UNKNOWN(instr); break;
                }
            } break;

        case op_alu_reg_w:
            if (f7 == 0b0000001) {
                switch (f3) {
                    case 0b000: g_existed.mul_div.inst_mulw = true; break;
                    case 0b100: g_existed.mul_div.inst_divw = true; break;
                    case 0b101: g_existed.mul_div.inst_divuw = true; break;
                    case 0b110: g_existed.mul_div.inst_remw = true; break;
                    case 0b111: g_existed.mul_div.inst_remuw = true; break;
                    default:    MARK_UNKNOWN(instr); break;
                }
            } else {
                switch (f3) {
                    case 0b000: if (f7 == 0x00) g_existed.alu.inst_addw = true; else if (f7 == 0x20) g_existed.alu.inst_subw = true; else MARK_UNKNOWN(instr); break;
                    case 0b001: g_existed.alu.inst_sllw = true; break;
                    case 0b101: if (f7 == 0x00) g_existed.alu.inst_srlw = true; else if (f7 == 0x20) g_existed.alu.inst_sraw = true; else MARK_UNKNOWN(instr); break;
                    default:    MARK_UNKNOWN(instr); break;
                }
            } break;

        case op_amo:
            if (f3 == 0b010) { // Word
                switch (f5_amo) {
                    case 0b00010: g_existed.amo.inst_lrw = true; break;
                    case 0b00011: g_existed.amo.inst_scw = true; break;
                    case 0b00001: g_existed.amo.inst_amoswapw = true; break;
                    case 0b00000: g_existed.amo.inst_amoaddw = true; break;
                    case 0b00100: g_existed.amo.inst_amoxorw = true; break;
                    case 0b01100: g_existed.amo.inst_amoandw = true; break;
                    case 0b01000: g_existed.amo.inst_amoorw = true; break;
                    case 0b10000: g_existed.amo.inst_amominw = true; break;
                    case 0b10100: g_existed.amo.inst_amomaxw = true; break;
                    case 0b11000: g_existed.amo.inst_amominuw = true; break;
                    case 0b11100: g_existed.amo.inst_amomaxuw = true; break;
                    default:      MARK_UNKNOWN(instr); break;
                }
            } else if (f3 == 0b011) { // Double Word
                switch (f5_amo) {
                    case 0b00010: g_existed.amo.inst_lrd = true; break;
                    case 0b00011: g_existed.amo.inst_scd = true; break;
                    case 0b00001: g_existed.amo.inst_amoswapd = true; break;
                    case 0b00000: g_existed.amo.inst_amoaddd = true; break;
                    case 0b00100: g_existed.amo.inst_amoxord = true; break;
                    case 0b01100: g_existed.amo.inst_amoandd = true; break;
                    case 0b01000: g_existed.amo.inst_amoord = true; break;
                    case 0b10000: g_existed.amo.inst_amomind = true; break;
                    case 0b10100: g_existed.amo.inst_amomaxd = true; break;
                    case 0b11000: g_existed.amo.inst_amominud = true; break;
                    case 0b11100: g_existed.amo.inst_amomaxud = true; break;
                    default:      MARK_UNKNOWN(instr); break;
                }
            } else MARK_UNKNOWN(instr);
            break;

        case op_system:
            if (f3 == 0b000) {
                if (instr == 0x00000073)      g_existed.system.inst_ecall = true;
                else if (instr == 0x00100073) g_existed.system.inst_ebreak = true;
                else if (instr == 0x00200073) g_existed.system.inst_uret = true;
                else if (instr == 0x10200073) g_existed.system.inst_sret = true;
                else if (instr == 0x30200073) g_existed.system.inst_mret = true;
                else if (instr == 0x10500073) g_existed.system.inst_wfi = true;
                else if ((instr >> 25) == 0b0001001) g_existed.system.inst_sfence_vma = true;
                else MARK_UNKNOWN(instr);
            } else {
                switch (f3) {
                    case 0b001: g_existed.system.inst_csrrw  = true; break;
                    case 0b010: g_existed.system.inst_csrrs  = true; break;
                    case 0b011: g_existed.system.inst_csrrc  = true; break;
                    case 0b101: g_existed.system.inst_csrrwi = true; break;
                    case 0b110: g_existed.system.inst_csrrsi = true; break;
                    case 0b111: g_existed.system.inst_csrrci = true; break;
                    default:    MARK_UNKNOWN(instr); break;
                }
            } break;

        case op_fence:
            if (f3 == 0b000)      g_existed.fence.inst_fence = true;
            else if (f3 == 0b001) g_existed.fence.inst_fence_i = true;
            else MARK_UNKNOWN(instr);
            break;

        default: 
            MARK_UNKNOWN(instr); 
            break; 
    }
}

// --- 可视化覆盖率报告 ---
#include <stdio.h>

void instr_coverage_display() {
    int total = 0, executed = 0;

    // 内部打印宏：格式为 "指令名 [X]" 或 "指令名 [ ]"
    // \033[1;32m 是绿色，\033[1;31m 是红色，增强视觉反馈
    #define P(name, field) do { \
        total++; \
        if(field) { \
            executed++; \
            printf("%-8s \033[1;32m[X]\033[0m   ", name " "); \
        } else { \
            printf("%-8s \033[1;31m[ ]\033[0m   ", name " "); \
        } \
        if(total % 4 == 0) printf("\n"); \
    } while(0)

    printf("\n\033[1;34m==================== RISC-V INSTRUCTION COVERAGE REPORT ====================\033[0m\n");
    
    printf("\n\033[1;33m[ Base & Control Flow ]\033[0m\n");
    P("lui", g_existed.inst_lui); P("auipc", g_existed.inst_auipc);
    P("jal", g_existed.inst_jal); P("jalr", g_existed.inst_jalr);
    P("beq", g_existed.branch.inst_beq); P("bne", g_existed.branch.inst_bne);
    P("blt", g_existed.branch.inst_blt); P("bge", g_existed.branch.inst_bge);
    P("bltu", g_existed.branch.inst_bltu); P("bgeu", g_existed.branch.inst_bgeu);
    printf("\n");

    printf("\n\033[1;33m[ Load & Store ]\033[0m\n");
    P("lb", g_existed.load_store.inst_lb); P("lh", g_existed.load_store.inst_lh);
    P("lw", g_existed.load_store.inst_lw); P("ld", g_existed.load_store.inst_ld);
    P("lbu", g_existed.load_store.inst_lbu); P("lhu", g_existed.load_store.inst_lhu);
    P("lwu", g_existed.load_store.inst_lwu); 
    P("sb", g_existed.load_store.inst_sb); P("sh", g_existed.load_store.inst_sh);
    P("sw", g_existed.load_store.inst_sw); P("sd", g_existed.load_store.inst_sd);
    printf("\n");

    printf("\n\033[1;33m[ ALU Immediate ]\033[0m\n");
    P("addi", g_existed.alu.inst_addi); P("addiw", g_existed.alu.inst_addiw);
    P("slti", g_existed.alu.inst_slti); P("sltiu", g_existed.alu.inst_sltiu);
    P("xori", g_existed.alu.inst_xori); P("ori", g_existed.alu.inst_ori);
    P("andi", g_existed.alu.inst_andi); P("slli", g_existed.alu.inst_slli);
    P("slliw", g_existed.alu.inst_slliw); P("srli", g_existed.alu.inst_srli);
    P("srliw", g_existed.alu.inst_srliw); P("srai", g_existed.alu.inst_srai);
    P("sraiw", g_existed.alu.inst_sraiw);
    printf("\n");

    printf("\n\033[1;33m[ ALU Register ]\033[0m\n");
    P("add", g_existed.alu.inst_add); P("addw", g_existed.alu.inst_addw);
    P("sub", g_existed.alu.inst_sub); P("subw", g_existed.alu.inst_subw);
    P("sll", g_existed.alu.inst_sll); P("sllw", g_existed.alu.inst_sllw);
    P("slt", g_existed.alu.inst_slt); P("sltu", g_existed.alu.inst_sltu);
    P("xor", g_existed.alu.inst_xor); P("srl", g_existed.alu.inst_srl);
    P("srlw", g_existed.alu.inst_srlw); P("sra", g_existed.alu.inst_sra);
    P("sraw", g_existed.alu.inst_sraw); P("or", g_existed.alu.inst_or);
    P("and", g_existed.alu.inst_and);
    printf("\n");

    printf("\n\033[1;33m[ M-Extension (Mul/Div) ]\033[0m\n");
    P("mul", g_existed.mul_div.inst_mul); P("mulh", g_existed.mul_div.inst_mulh);
    P("mulhsu", g_existed.mul_div.inst_mulhsu); P("mulhu", g_existed.mul_div.inst_mulhu);
    P("mulw", g_existed.mul_div.inst_mulw); P("div", g_existed.mul_div.inst_div);
    P("divu", g_existed.mul_div.inst_divu); P("divw", g_existed.mul_div.inst_divw);
    P("divuw", g_existed.mul_div.inst_divuw); P("rem", g_existed.mul_div.inst_rem);
    P("remu", g_existed.mul_div.inst_remu); P("remw", g_existed.mul_div.inst_remw);
    P("remuw", g_existed.mul_div.inst_remuw);
    printf("\n");

    printf("\n\033[1;33m[ A-Extension (Atomic) ]\033[0m\n");
    P("lr.w", g_existed.amo.inst_lrw); P("sc.w", g_existed.amo.inst_scw);
    P("amoswap.w", g_existed.amo.inst_amoswapw); P("amoadd.w", g_existed.amo.inst_amoaddw);
    P("lr.d", g_existed.amo.inst_lrd); P("sc.d", g_existed.amo.inst_scd);
    P("amoswap.d", g_existed.amo.inst_amoswapd); P("amoadd.d", g_existed.amo.inst_amoaddd);
    // ... 可以根据需要继续添加 amoxor, amoand 等
    printf("\n");

    printf("\n\033[1;33m[ System & Fence ]\033[0m\n");
    P("ecall", g_existed.system.inst_ecall); P("ebreak", g_existed.system.inst_ebreak);
    P("mret", g_existed.system.inst_mret); P("sret", g_existed.system.inst_sret);
    P("csrrw", g_existed.system.inst_csrrw); P("csrrs", g_existed.system.inst_csrrs);
    P("csrrc", g_existed.system.inst_csrrc); P("csrrwi", g_existed.system.inst_csrrwi);
    P("fence", g_existed.fence.inst_fence); P("fence.i", g_existed.fence.inst_fence_i);
    printf("\n");

    printf("\n\033[1;34m----------------------------------------------------------------------------\033[0m\n");
    float rate = (total > 0) ? ((float)executed / total * 100.0f) : 0;
    printf("STAT: %d/%d instructions covered. | \033[1;32mCoverage Rate: %.2f%%\033[0m\n", executed, total, rate);

    if (g_existed.inst_unknown) {
        printf("\n\033[1;31m[!] UNKNOWN INSTRUCTION ENCOUNTERED: 0x%08x\033[0m\n", g_existed.last_unknown_val);
    }
    printf("\033[1;34m============================================================================\033[0m\n\n");

    #undef P
}