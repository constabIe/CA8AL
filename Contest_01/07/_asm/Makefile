#-----------
# Toolchain
#-----------

CC  = x86_64-linux-gnu-gcc
AS  = nasm
GDB = gdb

#-----------------------
# Compiler/linker flags
#-----------------------

CFLAGS = \
	-m32 \
	-Wfatal-errors \
	-no-pie \
	-g

ASFLAGS = \
	-f elf32 \
	-DUNIX \
	-g

LDFLAGS = \
	-m32 \
	-no-pie \
	-z noexecstack \
	-g

#-------
# Files
#-------

SOURCES = \
	../../../standart_IO/src/macro.c \
	../../../standart_IO/src/benchmark.c \
	slv.asm

OBJECTS_HALFWAY_DONE = $(SOURCES:../../../standart_IO/src/%.c=build/%.o)
OBJECTS              = $(OBJECTS_HALFWAY_DONE:%.asm=build/%.o)

EXECUTABLE = build/slv_asm

#---------------
# Build scripts
#---------------

all: $(EXECUTABLE) $(SOURCES)

$(EXECUTABLE): $(OBJECTS) Makefile
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

build/%.o: ../../../standart_IO/src/%.c
	@mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: %.asm
	@mkdir -p build
	$(AS) $(ASFLAGS) $< -o $@

run: $(EXECUTABLE)
	./$<
	
clean:
	rm -rf build

# ----------------------
#  Emulator interaction  
# ---------------------- 

GDB_FLAGS = \
	--eval-command="set architecture i386" \
	--eval-command="file $(EXECUTABLE)" \
	--eval-command="b main" \
	--eval-command="run" \
	--eval-command="tui e" \
	--eval-command="la regs"

gdb: $(EXECUTABLE)
	$(GDB) $(GDB_FLAGS)

.PHONY: all clean gdb