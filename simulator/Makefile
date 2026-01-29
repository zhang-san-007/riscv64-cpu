TOPNAME :=top_cpu
CPU_DIR=$(SIM_HOME)/IP/rv64-pipeline-cpu-2026-ready-valid
SRC_DIR:=$(SIM_HOME)/src  


BUILD_DIR := $(SIM_HOME)/build
OBJ_DIR := $(BUILD_DIR)/obj_dir
INC_DIR := $(SIM_HOME)/include
BIN := $(BUILD_DIR)/$(TOPNAME)

# --- 编译器设置 ---
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -j 8 -trace-fst -cc -O0 
VERILATOR_CFLAGS += --x-assign fast --x-initial fast --noassert
VERILATOR_CFLAGS += -I$(CPU_DIR) --top-module $(TOPNAME) --prefix npc

INC_PATH = $(INC_DIR) $(INC_DIR)/utils $(INC_DIR)/riscv $(INC_DIR)/difftest $(INC_DIR)/generated
INCFLAGS := $(addprefix -I, $(INC_PATH))


LDFLAGS += -lreadline -lhistory -ldl -pie $(shell llvm-config --libs)
CXXFLAGS += $(INCFLAGS) -DTOP_NAME=npc -fpermissive

VSRCS = $(shell find $(abspath $(CPU_DIR)) -name "*.v" -o -name "*.sv")
CSRCS = $(shell find $(abspath $(SRC_DIR)) -name "*.c" -o -name "*.cpp" -o -name "*.cc")

# --- 颜色与图标定义 ---
BLUE   = \033[1;34m
GREEN  = \033[1;32m
PURPLE = \033[1;35m
CYAN   = \033[1;36m
YELLOW = \033[1;33m
RESET  = \033[0m
ROCKET = 🚀
CHECK  = ✅
BUILD  = 🛠️
RUN    = 🏃

# --- 构建规则 ---

default: $(BIN)
generate:
	python3 scripts/verilog.py $(CPU_DIR)/top_cpu.v
$(BIN): generate $(VSRCS) $(CSRCS) $(AUTOCONF_H)
	@echo "$(BLUE)$(BUILD) [1/2] Preparing build directory...$(RESET)"
	@mkdir -p $(BUILD_DIR)
	@rm -rf $(OBJ_DIR)
	@echo "$(PURPLE)$(ROCKET) [2/2] Starting Verilator compilation...$(RESET)"
	$(VERILATOR) $(VERILATOR_CFLAGS) $(VSRCS) $(CSRCS) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))
	@echo "$(GREEN)$(CHECK) Build successful! Binary: $(BIN)$(RESET)"

override ARGS ?= --log=$(SIM_HOME)/bin/npc-log.txt
override ARGS += --diff=$(SIM_HOME)/diff/riscv64-spike-so
override ARGS += --batch


run: $(BIN)
	@echo "$(CYAN)$(RUN) Launching simulation...$(RESET)"
	@$(BIN) $(ARGS) $(IMAGE)

sim:
	@echo "$(BLUE)🌊 Opening GTKWave...$(RESET)"
	@gtkwave $(SIM_HOME)/waveform.fst

clean:
	@echo "$(YELLOW)🧹 Cleaning up build artifacts...$(RESET)"
	@rm -rf $(BUILD_DIR)
	@rm -f $(AUTOCONF_H)
	@echo "$(GREEN)$(CHECK) Clean done.$(RESET)"

#menuconfig
-include $(SIM_HOME)/include/config/auto.conf
-include $(SIM_HOME)/include/config/auto.conf.cmd
include $(SIM_HOME)/scripts/config.mk

.PHONY: default all clean run sim menuconfig syncconfig