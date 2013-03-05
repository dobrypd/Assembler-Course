#Makefile using this Paths file should be placed in the root of the project.
ROOT=.
ROOT:=$(abspath $(ROOT))
BIN=$(ROOT)/bin
SRC=$(ROOT)/src
INCLUDES=$(SRC)/includes
KERNEL=$(SRC)/kernel
TESTS=$(ROOT)/tests
SCRIPTS=$(ROOT)/scripts
