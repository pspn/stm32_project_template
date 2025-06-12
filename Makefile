#==============================================================================
# Makefile for STM32L476RG Bare-Metal Project
#==============================================================================

# --- Application Details ---
TARGET = main
# The MCU variant
MCU = cortex-m4

# --- Toolchain ---
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump
SIZE = $(PREFIX)size
GDB = $(PREFIX)gdb
STFLASH = st-flash # From stlink-tools: https://github.com/stlink-org/stlink

# --- Build Directory ---
BUILD_DIR = build

# --- Source Files ---
# C sources
C_SOURCES = \
Src/main.c \
Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c

# Assembly sources
ASM_SOURCES = startup_stm32l476xx.s

# --- Compiler Flags ---
# CPU specific flags
CPU_FLAGS = -mcpu=$(MCU) -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16

# C flags
CFLAGS = $(CPU_FLAGS)
CFLAGS += -Wall -Wextra -g3 -O0 # Debug flags, optimization off for easier debugging
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -std=c11

# Add CMSIS and user include directories
INC_DIRS = -IInc \
           -IDrivers/CMSIS/Include \
           -IDrivers/CMSIS/Device/ST/STM32L4xx/Include
CFLAGS += $(INC_DIRS)

# Define the microcontroller part number for CMSIS headers
CFLAGS += -DSTM32L476xx

# --- Linker ---
# Linker script
LDSCRIPT = STM32L476RGx_FLASH.ld

# Linker flags
LDFLAGS = $(CPU_FLAGS)
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -nostdlib -T$(LDSCRIPT) # Use our linker script, not standard libraries

# --- Build Rules ---
# Object files
C_OBJS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
ASM_OBJS = $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
OBJS = $(C_OBJS) $(ASM_OBJS)

# Phony targets
.PHONY: all build clean flash gdb

# Default target
all: build

# Build the application
build: $(BUILD_DIR)/$(TARGET).elf

# Create ELF file
$(BUILD_DIR)/$(TARGET).elf: $(OBJS)
	@echo "Linking..."
	$(CC) $(LDFLAGS) $(OBJS) -o $@
	@echo "Creating binary and hex files..."
	$(OBJCOPY) -O binary $@ $(BUILD_DIR)/$(TARGET).bin
	$(OBJCOPY) -O ihex $@ $(BUILD_DIR)/$(TARGET).hex
	@echo "Build size:"
	$(SIZE) $@
	@echo "Build finished."

# Compile C source files
$(BUILD_DIR)/%.o: Src/%.c
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/%.c
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble startup file
$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(BUILD_DIR)
	@echo "Assembling $<..."
	$(AS) $(CPU_FLAGS) $< -o $@

# Clean build artifacts
clean:
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR)
	@echo "Clean finished."

# Flash the binary to the target
flash: $(BUILD_DIR)/$(TARGET).bin
	@echo "Flashing binary to the target..."
	$(STFLASH) write $(BUILD_DIR)/$(TARGET).bin 0x8000000

# Start a GDB session
gdb: $(BUILD_DIR)/$(TARGET).elf
	$(GDB) -tui $(BUILD_DIR)/$(TARGET).elf


