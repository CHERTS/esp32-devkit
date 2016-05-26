#############################################################
#
# ESP32 Root Level Makefile
#
# Version 2.0
#
# (c) 2015-2016 by CHERTS <sleuthhound@gmail.com>
#
#############################################################

sinclude esp.conf

BUILD_BASE	= build
FW_BASE		= firmware

# Base directory for the compiler
XTENSA_TOOLS_ROOT ?= c:/Espressif/xtensa-esp108-elf/bin

# base directory of the ESP32 SDK package, absolute
SDK_BASE	?= c:/Espressif/ESP32_RTOS_SDK
SDK_TOOLS	?= c:/Espressif/utils/ESP32

# esptool path and port
ESP_TOOL ?= $(SDK_TOOLS)/esptool_esp32.exe

#FLAVOR = release
FLAVOR = debug

# Verbose build output
VERBOSE = 0

ESP_COMPILE_APP_CPU ?= 0
ESP_COMBINE_APP_CPU_BIN ?= 0

# 1MB spi Flash
ifeq ($(ESP_FS), 1MB)
ESP_RFINIT_ADDR = 0xFC000
ESP_SYSPARAM_ADDR = 0xFE000
endif

# 2MB spi Flash
ifeq ($(ESP_FS), 2MB)
ESP_RFINIT_ADDR = 0x1FC000
ESP_SYSPARAM_ADDR = 0x1FE000
endif

# 4MB spi Flash
ifeq ($(ESP_FS), 4MB)
ESP_RFINIT_ADDR = 0x3FC000
ESP_SYSPARAM_ADDR = 0x3FE000
endif

# 8MB spi Flash
ifeq ($(ESP_FS), 8MB)
ESP_RFINIT_ADDR = 0x7FC000
ESP_SYSPARAM_ADDR = 0x7FE000
endif

# 16MB spi Flash
ifeq ($(ESP_FS), 16MB)
ESP_RFINIT_ADDR = 0xFFC000
ESP_SYSPARAM_ADDR = 0xFFE000
endif

ifeq ($(ESP_COMPILE_APP_CPU), 1)
	LD_FILE_CORE = $(SDK_BASE)/ld/app.map.ld
	LD_FILE = $(SDK_BASE)/ld/app.map.ld $(SDK_BASE)/ld/app.rom.addr.ld
else
	ifeq ($(ESP_LOCAL_LD), 1)
		LD_FILE_CORE = ./ld/$(ESP_LD_FILE)
		LD_FILE = $(LD_FILE_CORE) $(SDK_BASE)/ld/pro.rom.addr.ld
	else
		LD_FILE_CORE = $(SDK_BASE)/ld/pro.map$(ESP_MAP_MODE).ld
		LD_FILE = $(LD_FILE_CORE) $(SDK_BASE)/ld/pro.rom.addr.ld
	endif
endif

ifeq ($(FLAVOR),debug)
    TARGET_LDFLAGS += -g -O2
endif

ifeq ($(FLAVOR),release)
    TARGET_LDFLAGS += -g -O0
endif

# name for the target project
TARGET = eagle

# which modules (subdirectories) of the project to include in compiling
MODULES	= user
EXTRA_INCDIR = include $(SDK_BASE)/extra_include $(SDK_BASE)/third_party/include $(SDK_BASE)/third_party/include/freertos $(SDK_BASE)/third_party/include/cjson $(SDK_BASE)/third_party/include/ssl $(SDK_BASE)/third_party/include/lwip $(SDK_BASE)/third_party/include/lwip/ipv4 $(SDK_BASE)/third_party/include/lwip/ipv6

# libraries used in this project, mainly provided by the SDK
LIBS = c gcc hal m crypto freertos lwip main net80211 phy pp rtc wpa

# compiler flags using during compilation of source files
CFLAGS += $(TARGET_LDFLAGS)
CFLAGS += -Os -std=gnu90 -Wpointer-arith -Wundef -Werror -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -mno-serialize-volatile -D__ets__ -DICACHE_FLASH

# linker flags used to generate the main object file
LDFLAGS += $(TARGET_LDFLAGS)
LDFLAGS += -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static

# various paths from the SDK used in this project
SDK_LIBDIR	= lib
SDK_LDDIR	= ld
SDK_INCDIR	= include include/esp32

# select which tools to use as compiler, librarian and linker
CC	:= $(XTENSA_TOOLS_ROOT)/xtensa-esp108-elf-gcc
AR	:= $(XTENSA_TOOLS_ROOT)/xtensa-esp108-elf-ar
LD	:= $(XTENSA_TOOLS_ROOT)/xtensa-esp108-elf-gcc
OBJCOPY := $(XTENSA_TOOLS_ROOT)/xtensa-esp108-elf-objcopy
OBJDUMP := $(XTENSA_TOOLS_ROOT)/xtensa-esp108-elf-objdump

# no user configurable options below here
SRC_DIR		:= $(MODULES)
BUILD_DIR	:= $(addprefix $(BUILD_BASE)/,$(MODULES))
SDK_LIBDIR	:= $(addprefix $(SDK_BASE)/,$(SDK_LIBDIR))
SDK_INCDIR	:= $(addprefix -I$(SDK_BASE)/,$(SDK_INCDIR))
SRC			:= $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.c))
OBJ			:= $(patsubst %.c,$(BUILD_BASE)/%.o,$(SRC))
LIBS		:= $(addprefix -l,$(LIBS))
APP_AR		:= $(addprefix $(BUILD_BASE)/,$(TARGET)_app.a)
TARGET_OUT	:= $(addprefix $(BUILD_BASE)/,$(TARGET).out)
INCDIR		:= $(addprefix -I,$(SRC_DIR))
EXTRA_INCDIR	:= $(addprefix -I,$(EXTRA_INCDIR))
MODULE_INCDIR	:= $(addsuffix /include,$(INCDIR))

V ?= $(VERBOSE)
ifeq ("$(V)","1")
Q :=
vecho := @true
else
Q := @
vecho := @echo
endif

vpath %.c $(SRC_DIR)

define compile-objects
$1/%.o: %.c
	$(vecho) "CC $$<"
	$(Q) $(CC) $(INCDIR) $(MODULE_INCDIR) $(EXTRA_INCDIR) $(SDK_INCDIR) $(CFLAGS)  -c $$< -o $$@
endef

.PHONY: all checkdirs clean fflash_all flash_boot flash_app flash_blank rebuild

all: checkdirs $(TARGET_OUT)

$(TARGET_OUT): $(APP_AR)
	$(Q) $(RM) -r $(FW_BASE)/user.S $(FW_BASE)/user.dump
	$(Q) $(OBJDUMP) -x -s $< > $(FW_BASE)/user.dump
	$(Q) $(OBJDUMP) -S $< > $(FW_BASE)/user.S
	$(vecho) "LD $@"
	$(Q) $(LD) -L$(SDK_LIBDIR) -T$(LD_FILE) $(LDFLAGS) -Wl,--start-group $(LIBS) $(APP_AR) -Wl,--end-group -o $@
	$(vecho) "Run objcopy, please wait..."
	$(Q) $(OBJCOPY) --only-section .text -O binary $@ eagle.app.v7.text.bin
	$(Q) $(OBJCOPY) --only-section .data -O binary $@ eagle.app.v7.data.bin
	$(Q) $(OBJCOPY) --only-section .rodata -O binary $@ eagle.app.v7.rodata.bin
	$(Q) $(OBJCOPY) --only-section .irom0.text -O binary $@ eagle.app.v7.irom0text.bin
	$(Q) $(OBJCOPY) --only-section .drom0.text -O binary $@ eagle.app.v7.drom0text.bin
	$(vecho) "objcopy done"
	$(vecho) "Run gen_appbin_esp32.exe"
ifeq ($(ESP_COMPILE_APP_CPU), 0)
	$(Q) $(RM) -r $(FW_BASE)/irom0_flash.bin $(FW_BASE)/drom0.bin
	$(Q) $(RM) -r $(FW_BASE)/user.ota
	$(Q) $(SDK_TOOLS)/gen_appbin_esp32.exe $@ $(LD_FILE_CORE) $(ESP_COMPILE_APP_CPU) $(ESP_COMBINE_APP_CPU_BIN) $(SDK_BASE)/bin/app_cpu.bin $(FW_BASE)
else
	@$(RM) -r $(FW_BASE)/app_cpu.bin
	$(Q) $(SDK_TOOLS)/gen_appbin_esp32.exe $@ $(LD_FILE_CORE) $(ESP_COMPILE_APP_CPU) $(ESP_COMBINE_APP_CPU_BIN) $(FW_BASE)/app_cpu.bin $(FW_BASE)
endif
	$(Q) $(RM) -f eagle.app.v7.*
	$(vecho) "$(SDK_BASE)/bin/blank.bin ----------------->$(ESP_SYSPARAM_ADDR)"

$(APP_AR): $(OBJ)
	$(vecho) "AR $@"
	$(Q) $(AR) cru $@ $^

checkdirs: $(BUILD_DIR) $(FW_BASE)

$(BUILD_DIR):
	$(Q) mkdir -p $@

$(FW_BASE):
	$(Q) mkdir -p $@

flash_all:
	$(ESP_TOOL) -c ESP32 -p $(ESP_PORT) -b $(ESP_BAUD) write_flash -fs $(ESP_FS) -fm $(ESP_FM) -ff $(ESP_FF)	\
	0x0 $(SDK_BASE)/bin/boot.bin	\
	0x04000 $(FW_BASE)/drom0.bin 0x40000 $(FW_BASE)/irom0_flash.bin	\
	$(ESP_SYSPARAM_ADDR) $(SDK_BASE)/bin/blank.bin

flash_boot:
	$(ESP_TOOL) -c ESP32 -p $(ESP_PORT) -b $(ESP_BAUD) write_flash -fs $(ESP_FS) -fm $(ESP_FM) -ff $(ESP_FF)	\
	0x0 $(SDK_BASE)/bin/boot.bin

flash_app:
	$(ESP_TOOL) -c ESP32 -p $(ESP_PORT) -b $(ESP_BAUD) write_flash	\
	0x04000 $(FW_BASE)/drom0.bin 0x40000 $(FW_BASE)/irom0_flash.bin

flash_blank:
	$(ESP_TOOL) -c ESP32 -p $(ESP_PORT) -b $(ESP_BAUD) write_flash	\
	$(ESP_SYSPARAM_ADDR) $(SDK_BASE)/bin/blank.bin

rebuild: clean all

clean:
	$(Q) rm -f $(APP_AR)
	$(Q) rm -f $(TARGET_OUT)
	$(Q) rm -rf $(BUILD_DIR)
	$(Q) rm -rf $(BUILD_BASE)
	$(Q) rm -rf $(FW_BASE)

$(foreach bdir,$(BUILD_DIR),$(eval $(call compile-objects,$(bdir))))
