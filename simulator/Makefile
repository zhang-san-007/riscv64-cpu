# --- 颜色定义 ---
GREEN  = \033[1;32m
YELLOW = \033[1;33m
BLUE   = \033[1;34m
PURPLE = \033[1;35m
CYAN   = \033[1;36m
RESET  = \033[0m

# --- 图标定义 ---
ROCKET = 🚀
CHECK  = ✅
CLEAN  = 🧹
BUILD  = 🛠️
RUN    = 🏃
WAVE   = 🌊

# --- 现有变量保持不变 ---
TOPNAME := top_cpu
CPU_DIR = $(SIM_HOME)/IP/rv64-pipeline-cpu-2026-ready-valid
SRC_DIR := $(SIM_HOME)/src

PREFIX_NAME := npc
TOPNAME_FLAG = --top-module $(TOPNAME)
PREFIX_FLAG  = --prefix $(PREFIX_NAME)
VL_ROOT_HEADER = \"$(PREFIX_NAME).h\"

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -j 8 -trace-fst -cc -O0 --x-assign fast --x-initial fast --noassert -I$(CPU_DIR)
VERILATOR_CFLAGS += $(TOPNAME_FLAG) $(PREFIX_FLAG)

BUILD_DIR = $(SIM_HOME)/build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

INC_DIR  := $(SIM_HOME)/include
INC_PATH = $(INC_DIR) $(INC_DIR)/utils $(INC_DIR)/riscv $(INC_DIR)/difftest
INCFLAGS := $(addprefix -I, $(INC_PATH))

LDFLAGS += -lreadline -lhistory -ldl -pie $(shell llvm-config --libs)
CXXFLAGS += $(INCFLAGS)
CXXFLAGS += -DTOP_NAME=$(PREFIX_NAME) -DVL_ROOT_HEADER=$(VL_ROOT_HEADER) -fpermissive

# --- 核心逻辑 ---

VSRCS = $(shell find $(abspath $(CPU_DIR)) -name "*.v" -o -name "*.sv")
CSRCS = $(shell find $(abspath $(SRC_DIR)) -name "*.c" -o -name "*.cpp" -o -name "*.cc")

default: $(BIN)

$(BIN): $(VSRCS) $(CSRCS)
	@echo "$(BLUE)$(BUILD) [1/2] Preparing build directory...$(RESET)"
	@mkdir -p $(BUILD_DIR)
	@rm -rf $(OBJ_DIR)
	@rm -f waveform.vcd
	@echo "$(PURPLE)$(ROCKET) [2/2] Starting Verilator compilation...$(RESET)"
	$(VERILATOR) $(VERILATOR_CFLAGS) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))
	@echo "$(GREEN)$(CHECK) Build successful! Binary: $(BIN)$(RESET)"

override ARGS ?= --log=$(SIM_HOME)/bin/npc-log.txt
override ARGS += --diff=$(SIM_HOME)/diff/riscv64-spike-so --batch

run: $(BIN)
	@echo "$(CYAN)$(RUN) Launching simulation...$(RESET)"
	@$(BIN) $(ARGS) $(IMAGE)

sim:
	@echo "$(BLUE)$(WAVE) Opening GTKWave...$(RESET)"
	@gtkwave $(SIM_HOME)/waveform.fst $(SIM_HOME)/waveform.view 

clean:
	@echo "$(YELLOW)$(CLEAN) Cleaning up build artifacts...$(RESET)"
	@rm -rf $(BUILD_DIR)
	@rm -f $(SIM_HOME)/waveform.fst
	@echo "$(GREEN)$(CHECK) Clean done.$(RESET)"

.PHONY: default all clean run sim