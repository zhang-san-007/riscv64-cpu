#include <common.h>
#include <cstdint>
#include <cstdio>
#include <defs.h>
#include "verilated_dpi.h" 
extern CPU_state cpu; 
extern u64 *reg_ptr;





extern "C" void dpi_ebreak(){
	printf("下一个要执行的指令是ebreak\n");
	SIMTRAP(0x80000000, 0);
}
extern "C" uint32_t dpi_instr_mem_read(uint64_t addr){
  if(addr >= CONFIG_MBASE && addr < CONFIG_MBASE + CONFIG_MSIZE){
		addr = addr & ~0x3u;
		IFDEF(,Log("[fetch]addr = %lx,intsr = %lx",addr,pmem_read(addr, 4)));
		return pmem_read(addr, 4);
	}else{
      return 0;
   }
}


extern "C" uint64_t dpi_mem_read(uint64_t addr, int len) {
    if (addr == 0) return 0;
    return pmem_read(addr, 8); 
}
//store指令
extern "C" void dpi_mem_write(uint64_t addr, uint64_t data, int len, uint32_t instr, uint64_t pc){
	if(addr == CONFIG_SERIAL_MMIO){
		char ch = data;
		printf("%c", ch);
		fflush(stdout);
	}else{
		pmem_write(addr, len, data);
	}
}

extern "C" void dpi_read_regfile(const svOpenArrayHandle r) {
  reg_ptr = (word_t *)(((VerilatedDpiOpenVar*)r)->datap());
}
extern "C" void get_m_information_csr(long long mvendorid, long long marchid, long long mimpid, long long mhartid, long long mconfigptr) {
	cpu.csr[mvendorid]  = mvendorid;
	cpu.csr[marchid]    = marchid;
	cpu.csr[mimpid]     = mimpid;
	cpu.csr[mhartid]    = mhartid;
	cpu.csr[mconfigptr] = mconfigptr;
}


extern "C" void get_m_trap_setup_csr(long long mstatus, long long misa, long long medeleg, long long mideleg, 
						  long long mie, long long mtvec, long long mcounteren) {
	cpu.csr[mstatus] = mstatus;
	cpu.csr[misa]    = misa;
	cpu.csr[medeleg] = medeleg;
	cpu.csr[mideleg] = mideleg;
	cpu.csr[mie]     = mie;
	cpu.csr[mtvec]   = mtvec;
	cpu.csr[mcounteren] = mcounteren;
}


extern "C" void get_m_trap_handing_csr(long long mscratch, long long mepc, long long mcause, long long mtval, long long mip) {
	cpu.csr[mscratch] = mscratch;
	cpu.csr[mepc]  = mepc;
	cpu.csr[mcause] = mcause;
	cpu.csr[mtval]  = mtval;
	cpu.csr[mip]    = mip;
}


extern "C" void get_m_counter_timer_csr(long long mcycle, long long minstret) {
	cpu.csr[mcycle] = mcycle;
	cpu.csr[minstret] = minstret;
}


extern "C" void get_s_satp_csr(long long satp) {
	cpu.csr[satp] = satp;
}


extern "C" void get_s_trap_setup_csr(long long sstatus, long long sie, long long stvec, long long scounteren) {
	cpu.csr[sstatus] = sstatus;
	cpu.csr[sie] = sie;
	cpu.csr[stvec] = stvec;
	cpu.csr[scounteren] = scounteren;
}

extern "C" void get_s_trap_handing_csr(long long sscratch, long long sepc, long long scause, long long stval, long long sip) {
	cpu.csr[sscratch] = sscratch;
	cpu.csr[sepc] 		= sepc;
	cpu.csr[scause] 	= scause;
	cpu.csr[stval]  	= stval;
	cpu.csr[sip]    	= sip;
}

extern "C" void get_u_counter_timer_csr(long long cycle, long long timer, long long instret) {
	cpu.csr[cycle] = cycle;
	cpu.csr[timer] = timer;
	cpu.csr[instret] = instret;
}

extern "C" void get_pmp_cfg_csr(long long pmpcfg0, long long pmpcfg1, long long pmpcfg2, long long pmpcfg3) {
	cpu.csr[pmpcfg0] = pmpcfg0;
	cpu.csr[pmpcfg1] = pmpcfg1;
	cpu.csr[pmpcfg2] = pmpcfg2;
	cpu.csr[pmpcfg3] = pmpcfg3;
}

extern "C" void get_pmp_addr1_csr(long long pmpaddr0, long long pmpaddr1, long long pmpaddr2, long long pmpaddr3) {
	cpu.csr[pmpaddr0] = pmpaddr0;
	cpu.csr[pmpaddr1] = pmpaddr1;
	cpu.csr[pmpaddr2] = pmpaddr2;
	cpu.csr[pmpaddr3] = pmpaddr3;
}

extern "C" void get_pmp_addr2_csr(long long pmpaddr4, long long pmpaddr5, long long pmpaddr6, long long pmpaddr7) {
	cpu.csr[pmpaddr4] = pmpaddr4;
	cpu.csr[pmpaddr5] = pmpaddr5;
	cpu.csr[pmpaddr6] = pmpaddr6;
	cpu.csr[pmpaddr7] = pmpaddr7;
}

extern "C" void get_pmp_addr3_csr(long long pmpaddr8, long long pmpaddr9, long long pmpaddr10, long long pmpaddr11) {
	cpu.csr[pmpaddr8] = pmpaddr8;
	cpu.csr[pmpaddr9] = pmpaddr9;
	cpu.csr[pmpaddr10] = pmpaddr10;
	cpu.csr[pmpaddr11] = pmpaddr11;
}

extern "C" void get_pmp_addr4_csr(long long pmpaddr12, long long pmpaddr13, long long pmpaddr14, long long pmpaddr15) {
	cpu.csr[pmpaddr12] = pmpaddr12;
	cpu.csr[pmpaddr13] = pmpaddr13;
	cpu.csr[pmpaddr14] = pmpaddr14;
	cpu.csr[pmpaddr15] = pmpaddr15;
}



