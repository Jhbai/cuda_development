# ----- Comipiler Definition ----- #
CC := gcc
NVCC := nvcc

# ----- Compiling Parameters Setup ----- #
# sm_89 -> ada,
# sm_80 -> Ampere, 
# sm_75 -> Turing, 
# sm_70 -> Volta, 
# sm_60 -> Maxwell, 
# sm_53 -> Pascal, 
# sm_50 -> Maxwell, 
# if GPU Type is not sure, you can remove -arch=sm_XX so that nvcc will choose the default architecture
CUDA_ARCH := -arch=sm_89

# C Compiling Parameters (Host Code)
# -O3: Enable optimization
# -Wall: Enable all standard warnings
# -Wextra: Enable -Wall not included extra warnings
# -std=c99: Use C99 (C Standard 1999)
CFLAGS := -O3 -Wall -Wextra -std=c99

# CUDA Compiling Parameters (Device Code)
# -O3: Enable optimization
# -dc: Generate relocatable device code, needed for separate compilation
NVCCFLAGS := -O3 $(CUDA_ARCH)

# ----- Path Setup ----- #
# Tell Linker to go to Library Path to find out lib<Name>.so or lib<Name>.a after .o files are linked
# Using -L <path> to specify additional library path
# if cuda in /usr/local/cuda, then it is not necessary to add -L/usr/local/cuda/lib64
# If link the custom library, you may need to add -L<custom_library_path> -l<custom_library_name>
# that is LDFLAGS := -lcudart -lm -L<custom_library_path> -l<custom_library_name>
# ?= means if CUDA_PATH is not defined in environment variables, then set it to /usr/local/cuda
CUDA_PATH ?= /usr/local/cuda
LDFLAGS := -L$(CUDA_PATH)/lib64 -lcudart -lm

# ----- File Structure ----- #
# build folder setup to sotre all object files and intermediate files
# moreover, when using make clean, we can just delete the build folder to clean all intermediate files
# and gitignore the build folder in .gitignore
# TARGET is the final executable name
TARGET := main_app
BUILD_DIR := build
GPU_DIR := gpu

# ----- Source Files Setup ----- #
C_SRCS := main.c alg.c
CU_SRCS := $(GPU_DIR)/simd.cu

# Here is Variable Expansion for Object Files
# %.c -> $(BUILD_DIR)/%.o
# See $(...) as a function of replacing all %.c with $(BUILD_DIR)/%.o
C_OBJS := $(C_SRCS:%.c=$(BUILD_DIR)/%.o)
CU_OBJS := $(CU_SRCS:%.cu=$(BUILD_DIR)/%.o)

# ----- Compiling Rules ---- #
# 1. Default Traget, build all, check and create build directory and target first
all: $(BUILD_DIR) $(TARGET)

# ----- Link all the object files ----- #
# Target file: Linked Object File
# @echo is used to print messages during the build process, if @ is not used, the command itself will also be printed
# $^ is an automatic variable that represents all the prerequisites (dependencies) of the target
# $@ is an automatic variable that represents the target name
# Use NVCC to link both C and CUDA object files
$(TARGET): $(C_OBJS) $(CU_OBJS)
	@echo "Linking target: $@"
	$(NVCC) $(CUDA_ARCH) $^ -o $@ $(LDFLAGS)

# ----- Compiling C Code into Object Files ----- #
# Here will occur hard matching for the pattern rules
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "Compiling C source: $<"
	$(CC) $(CFLAGS) -c $< -o $@

# ----- Compiling CUDA Code into Object Files ----- #
# Here will occur hard matching for the pattern rules
$(BUILD_DIR)/%.o: %.cu
	@mkdir -p $(dir $@)
	@echo "Compiling CUDA source: $<"
	$(NVCC) $(NVCCFLAGS) -c $< -o $@

# ----- establish build directory if not exist ----- #
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# ----- clean up all build files and target ------ #
clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_DIR) $(TARGET)

# ------ run the target ------ #
# Here will execute the run: all first to ensure the target is up-to-date
run: all
	@echo "Running $(TARGET)..."
	./$(TARGET)

# ----- Phony Targets ----- #
# Tell Make Tools that these targets are not actual files, not take them as files
.PHONY: all clean run
