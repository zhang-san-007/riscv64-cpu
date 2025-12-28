#include <common.h>
#include <cstdint>
#include <cstdio>
#include <defs.h>
#include "verilated_dpi.h" // For VerilatedDpiOpenVar and other DPI related definitions


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

extern "C" uint64_t dpi_mem_read(uint64_t addr, uint64_t len, uint32_t instr){
	if(addr == 0) return 0;
	else{
		if(len == 2) addr = addr & ~0x1u;
		else if(len == 4) addr = addr & ~0x3u;
		else if(len == 8) addr = addr & ~0x7u;
		uint64_t data = pmem_read(addr, len);

		IFDEF(CONFIG_INS_TRACE,Log("[read instr = %x]addr = %lx,data = %lx,len = %ld",instr,addr,data,len));
		return data;
	}
}

extern "C" void dpi_mem_write(uint64_t addr, uint64_t data, int len, uint32_t instr, uint64_t pc){
//	printf("store指令, 写入地址addr=[%lx], 写入数据wdata=[%lx], 写入长度len=[%d]\n", addr, data, len);

	if(addr == CONFIG_SERIAL_MMIO){
		char ch = data;
		printf("%c", ch);
		fflush(stdout);
	}else{
		IFDEF(CONFIG_INS_TRACE,Log("[write instr = %x]addr = %lx,data = %lx,len = %d",instr,addr,data,len));
		if(len == 2) addr = addr & ~0x1u;
		else if(len == 4) addr = addr & ~0x3u;
		else if(len == 8) addr = addr & ~0x7u;
		
		pmem_write(addr, len, data);
	}

}


extern uint32_t  *reg_ptr;
extern "C" void dpi_read_regfile(const svOpenArrayHandle r) {
  reg_ptr = (uint32_t *)(((VerilatedDpiOpenVar*)r)->datap());
}