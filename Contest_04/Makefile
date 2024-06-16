#-----------------------
# Compiler/linker flags
#-----------------------

CC  = x86_64-linux-gnu-gcc
AS  = nasm
GDB = gdb

CFLAGS = \
	-std=gnu99 \
	-m32 \
	-Wfatal-errors \
	-no-pie

ASFLAGS = \
	-f elf32 \
	-DUNIX 

LDFLAGS = \
	-m32 \
	-no-pie \
	-z noexecstack

LDLIBS = -lm

ifeq (${DEBUG}, 1)
	CFLAGS += -g
	ASFLAGS += -g
else
	CFLAGS  += -flto
	LDFLAGS += -flto
endif

#--------
# Colors
#--------

BRED    = \033[1;31m
BGREEN  = \033[1;32m
BYELLOW = \033[1;33m
GREEN   = \033[1;35m
BCYAN   = \033[1;36m
RESET   = \033[0m

#-------
# Files
#-------

BUILDDIR = build
INCLUDEDIR = include
SOURCEDIR = src

CFLAGS += -I ${INCLUDE}

SOURCES = ${wildcard ${SOURCEDIR}/*.c}

# OBJECTS_C = $(patsubst $(SOURCEDIR)/%.c, $(BUILDDIR)/%.o, $(SOURCES))
# OBJECTS_ASM = $(patsubst $(SOURCEDIR)/%.asm, $(BUILDDIR)/%.o, $(SOURCES))
OBJECTS = $(patsubst $(SOURCEDIR)/%.%, $(BUILDDIR)/%.o, $(SOURCES))

EXECUTABLE = ${BUILDDIR}/main

#---------------
# Build process
#---------------

default: ${EXECUTABLE}

${EXECUTABLE}: ${OBJECTS}
	@printf "${BYELLOW}Linking executable ${BCYAN}$@${RESET}\n"
	${CC} ${OBJECTS} ${LDFLAGS} -o $@ ${LDLIBS}

${BUILDDIR}/%.o: $(SOURCEDIR)/%.c
	@printf "${BYELLOW}Building object file ${BCYAN}$@${RESET}\n"
	@mkdir -p ${BUILDDIR}
	${CC} -c $< ${CFLAGS} -o $@

${BUILDDIR}/%.o: $(SOURCEDIR)/%.asm
	@printf "${BYELLOW}Building object file ${BCYAN}$@${RESET}\n"
	@mkdir -p ${BUILDDIR}
	${AS} ${ASFLAGS} $< ${CFLAGS} -o $@

#--------------
# Test scripts
#--------------

run: ${EXECUTABLE}
	./$<

#---------------
# Miscellaneous
#---------------

clean:
	@printf "${BYELLOW}Cleaning build directories${RESET}\n"
	rm -rf ${BUILDDIR}

GDB_FLAGS = \
	--eval-command="set architecture i386" \
	--eval-command="file $(EXECUTABLE)" \
	--eval-command="b main" \
	--eval-command="run" \
	--eval-command="tui e" \
	--eval-command="la regs"

gdb: $(EXECUTABLE)
	$(GDB) $(GDB_FLAGS)

.PHONY: default clean run gdb
