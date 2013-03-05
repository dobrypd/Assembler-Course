# Author Piotr Dobrowolski
# pd291528@students.mimuw.edu.pl
include bin/Paths.mk

ARCH=x86_64

PROJECT=GameOfLife
BINARY=gol

OBJECTS_C:=$(patsubst $(SRC)/kernel/%.c,$(BIN)/%.o,$(wildcard $(SRC)/kernel/*.c))
OBJECTS_A:=$(patsubst $(SRC)/kernel/%.asm,$(BIN)/%.o,$(wildcard $(SRC)/kernel/*.asm))

OPTDBG= -O2 -DNDEBUG
ifeq ($(debug), 1)
	OPTDBG= -g
endif


NASM=nasm
NASM_FLAGS=-f elf64
CC=gcc
CFLAGS=-Wall -Werror -c $(OPTDBG) -D_ARCH_$(ARCH)
LFLAGS=-Wall -Werror $(OPTDBG)

all : $(PROJECT)

$(PROJECT): $(OBJECTS_A) $(OBJECTS_C)
	@echo -en "\033[38m\033[32mLinking $(PROJECT)...\033[0m\n"
	$(CC) $(LFLAGS) $^ -I $(INCLUDES) -o $(BINARY)

$(OBJECTS_C): $(BIN)/%.o : $(SRC)/kernel/%.cpp
	@echo -en "Compiling \033[38m\033[33m$(patsubst $(SRC)/kernel/%,%, $<)\033[0m...\n"
	$(CC) $(CFLAGS) $< -I $(INCLUDES) -I $(GRAMMAR_BIN) -o $@
	
$(OBJECTS_A): $(BIN)/%.o : $(SRC)/kernel/%.asm
	@echo -en "Assembling \033[38m\033[33m$(patsubst $(SRC)/kernel/%,%, $<)\033[0m...\n"
	$(NASM) $(NASM_FLAGS) $< -o $@

test: all
	cd $(SCRIPTS); ./test_runner.sh
	cd $(ROOT)


clean:
	rm -f $(BIN)/*.o
	find $(ROOT) -iname "*.bak" | xargs rm -f
	find $(ROOT) -iname "*.swp" | xargs rm -f
	find $(ROOT) -iname "*~" | xargs rm -f

distclean: clean
	rm -f $(BINARY)

.PHONY: clean, distclean, test
