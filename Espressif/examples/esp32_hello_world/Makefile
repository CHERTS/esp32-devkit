#############################################################
#
# ESP32 Root Level Makefile
#
# Version 1.0
#
# (c) 2015 by CHERTS <sleuthhound@gmail.com>
#
#############################################################

BUILD_BASE	= build
FW_BASE		= firmware

# Base directory for the compiler
XTENSA_TOOLS_ROOT ?= c:/Espressif/xtensa-esp108-elf/bin

# base directory of the ESP32 SDK package, absolute
SDK_BASE	?= c:/Espressif/ESP32_RTOS_SDK
SDK_TOOLS	?= c:/Espressif/utils

# name for the target project
TARGET = app

# which modules (subdirectories) of the project to include in compiling
MODULES	= user
EXTRA_INCDIR = include $(SDK_BASE)/extra_include

# libraries used in this project, mainly provided by the SDK
LIBS = c gcc hal m crypto freertos lwip main net80211 phy pp rtc wpa

# compiler flags using during compilation of source files
CFLAGS = -Os -g -O2 -std=gnu90 -Wpointer-arith -Wundef -Werror -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -mno-serialize-volatile -D__ets__ -DICACHE_FLASH

# linker flags used to generate the main object file
LDFLAGS = -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static

# linker script used for the above linkier step
LD_SCRIPT = eagle.pro.v7.ld

# various paths from the SDK used in this project
SDK_LIBDIR	= lib
SDK_LDDIR	= ld
SDK_INCDIR	= include include/espressif include/lwip include/lwip/ipv4 include/lwip/ipv6

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
SRC		:= $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.c))
OBJ		:= $(patsubst %.c,$(BUILD_BASE)/%.o,$(SRC))
LIBS		:= $(addprefix -l,$(LIBS))
APP_AR		:= $(addprefix $(BUILD_BASE)/,$(TARGET)_app.a)
TARGET_OUT	:= $(addprefix $(BUILD_BASE)/,$(TARGET).out)
LD_SCRIPT	:= $(addprefix -T$(SDK_BASE)/$(SDK_LDDIR)/,$(LD_SCRIPT))
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

.PHONY: all checkdirs clean flash rebuild

all: checkdirs $(TARGET_OUT)

$(TARGET_OUT): $(APP_AR)
	$(vecho) "LD $@"
	$(Q) $(LD) -L$(SDK_LIBDIR) $(LD_SCRIPT) $(LDFLAGS) -Wl,--start-group $(LIBS) $(APP_AR) -Wl,--end-group -o $@
	$(vecho) "Run objcopy, please wait..."
	$(Q) $(OBJCOPY) --only-section .text -O binary $@ eagle.app.v7.text.bin
	$(Q) $(OBJCOPY) --only-section .data -O binary $@ eagle.app.v7.data.bin
	$(Q) $(OBJCOPY) --only-section .rodata -O binary $@ eagle.app.v7.rodata.bin
	$(Q) $(OBJCOPY) --only-section .irom0.text -O binary $@ eagle.app.v7.irom0text.bin
	$(Q) $(OBJCOPY) --only-section .irom1.text -O binary $@ eagle.app.v7.irom1text.bin
	$(Q) rm -f irom0_flash.bin irom1.bin
	$(vecho) "objcopy done"
	$(vecho) "Run gen_appbin_esp32.exe"
	$(Q) $(SDK_TOOLS)/gen_appbin_esp32.exe $@ $(SDK_BASE)/ld
	$(Q) mv eagle.app.flash.bin $(FW_BASE)/$(TARGET).ota
	$(Q) mv irom1.bin $(FW_BASE)/irom1.bin &>/dev/null
	$(Q) mv irom0_flash.bin $(FW_BASE)/irom0_flash.bin &>/dev/null
	$(Q) rm eagle.app.v7.*
	$(vecho) "------------------------------------------------------------------------------"
	$(vecho) "Generate related files successully in folder $(FW_BASE)"	
	$(vecho) "$(SDK_BASE)/bin/boot.bin ------------------>0x00000"
	$(vecho) "irom1.bin ----------------->0x04000" 
	$(vecho) "irom0_flash.bin ----------->0x40000"
	$(vecho) "user.ota ------------------>(used for OTA)"
	$(vecho) "Done"

$(APP_AR): $(OBJ)
	$(vecho) "AR $@"
	$(Q) $(AR) cru $@ $^

checkdirs: $(BUILD_DIR) $(FW_BASE)

$(BUILD_DIR):
	$(Q) mkdir -p $@

$(FW_BASE):
	$(Q) mkdir -p $@

flash: all
	$(vecho) "Please run $(SDK_TOOLS)/ESP31_FLASH_DOWNLOAD_TOOL_V1.0.1/ESP31_FLASH_DOWNLOAD_TOOL_V1.0.1.exe burn firmware in ESP32 board."

rebuild: clean all

clean:
	$(Q) rm -f $(APP_AR)
	$(Q) rm -f $(TARGET_OUT)
	$(Q) rm -rf $(BUILD_DIR)
	$(Q) rm -rf $(BUILD_BASE)
	$(Q) rm -rf $(FW_BASE)

$(foreach bdir,$(BUILD_DIR),$(eval $(call compile-objects,$(bdir))))
