# Author Piotr Dobrowolski
# pd291528@students.mimuw.edu.pl
include bin/Paths.mk

ARM_VERSION=armv5te
#ARM_CPU_VERSION=arm926ej-s
KERNEL_ARCH=$(KERNEL_ARM)
CC=arm-linux-gnu-gcc
ifeq ($(arch), native)
	CC=gcc
	KERNEL_ARCH=$(KERNEL_NATIVE)
else ifneq (,$(findstring arm, $(shell uname -m)))
		CC=gcc
	else
		LD=arm-linux-ld
		CC=arm-linux-gnu-gcc
endif

PROJECT=LineDetector
BINARY=linedetector

OBJECTS_C:=$(patsubst $(KERNEL)/%.c,$(BIN)/%.o,$(wildcard $(KERNEL)/*.c))
# One of this below will be empty.
OBJECTS_NATIVE:=$(patsubst $(KERNEL_ARCH)/%.c,$(BIN)/%.o,$(wildcard $(KERNEL_ARCH)/*.c))
OBJECTS_ARM:=$(patsubst $(KERNEL_ARCH)/%.S,$(BIN)/%.o,$(wildcard $(KERNEL_ARCH)/*.S))

OPTDBG= -O3 -DNDEBUG
ifdef debug
	OPTDBG= -g -DDBGLVL=$(debug)
endif

AFLAGS=-Wall -Werror -c $(OPTDBG) -march=$(ARM_VERSION)
CFLAGS=-Wall -Werror -c $(OPTDBG)
LFLAGS=-Wall -Werror $(OPTDBG) -lm

all : $(PROJECT)

$(PROJECT): $(OBJECTS_ARM) $(OBJECTS_NATIVE) $(OBJECTS_C)
	@echo -en "\033[38m\033[32mLinking $(PROJECT)...\033[0m\n"
	$(CC) $(LFLAGS) $^ -I $(INCLUDES) -o $(BINARY)

$(OBJECTS_C): $(BIN)/%.o : $(KERNEL)/%.c
	@echo -en "Compiling \033[38m\033[33m$(patsubst $(KERNEL)/%,%, $<)\033[0m...\n"
	$(CC) $(CFLAGS) $< -I $(INCLUDES) -o $@
	
$(OBJECTS_NATIVE): $(BIN)/%.o : $(KERNEL_NATIVE)/%.c
	@echo -en "Compiling \033[38m\033[33m$(patsubst $(KERNEL_NATIVE)/%,%, $<)\033[0m...\n"
	$(CC) $(CFLAGS) $< -I $(INCLUDES) -o $@
	
$(OBJECTS_ARM): $(BIN)/%.o : $(KERNEL_ARM)/%.S
	@echo -en "Assembling \033[38m\033[33m$(patsubst $(SRC)/kernel/%,%, $<)\033[0m...\n"
	$(CC) $(AFLAGS) $< -o $@
	
asm: $(KERNEL_NATIVE)/*.c
	@echo -en " \033[38m\033[35mAssembly from native...\033[0m\n"
	$(CC) $(AFLAGS) -S $< -I $(INCLUDES) -o $(BIN)/$@.S

test: all
	$(SCRIPTS)/test_runner.sh
	cd $(ROOT)


clean:
	rm -f $(BIN)/*.o
	rm -f $(BIN)/*.S
	find $(ROOT) -iname "*.bak" | xargs rm -f
	find $(ROOT) -iname "*.swp" | xargs rm -f
	find $(ROOT) -iname "*~" | xargs rm -f

distclean: clean
	rm -f $(BINARY)

.PHONY: clean, distclean, test
