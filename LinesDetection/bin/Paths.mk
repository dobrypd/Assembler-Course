#Makefile using this Paths file should be placed in the root of the project.
ROOT=.
ROOT:=$(abspath $(ROOT))
BIN=$(ROOT)/bin
SRC=$(ROOT)/src
INCLUDES=$(SRC)/includes
KERNEL=$(SRC)/kernel
KERNEL_ARM=$(SRC)/kernel/arm
KERNEL_NATIVE=$(SRC)/kernel/native
TESTS=$(ROOT)/tests
SCRIPTS=$(ROOT)/scripts
