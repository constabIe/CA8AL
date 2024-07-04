# x86_64-linux-gnu-gcc
CC  = gcc
AS  = nasm
GDB = gdb

CFLAGS = \
		-Wall \
		-Werror \
		-Wextra

ASFLAGS = \
		-f elf32 \
		-DUNIX

LDFLAGS =

LDLIBS = -lm

ifeq ($(i386), 1)
  CFLAGS += -m32
  LDFLAGS += -m32 -no-pie -z noexecstack
endif

ifeq ($(DEBUG), 1)
  CFLAGS += -g
  ASFLAGS += -g
  LDFLAGS += -g
else
  LDFLAGS += -flto
endif

ifeq ($(MEMVIEW), 1)
  CFLAGS += -fsanitize=address,undefined
  LDFLAGS += -fsanitize=address,undefined
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
LIBDIR = lib
FUNCTIONDIR = functions_implementation

LIBS =  $(notdir $(wildcard $(LIBDIR)/*.c))
LIB_OBJS = $(LIBS:%.c=$(BUILDDIR)/%.o)

SOURCES = $(notdir $(wildcard $(SOURCEDIR)/*.c))
SOURCE_OBJS = $(SOURCES:%.c=$(BUILDDIR)/%.o)

FUNCTIONS = $(notdir $(wildcard $(FUNCTIONDIR)/*.asm))
FUNCTION_OBJS = $(FUNCTIONS:%.asm=$(BUILDDIR)/%.o)

CFLAGS += -I $(abspath $(INCLUDEDIR))

MAIN_OBJ = $(BUILDDIR)/main.o
MAIN_EXE = $(BUILDDIR)/main

FUNCTION_DEPLOYMENT_OBJ = $(BUILDDIR)/functions_deployment.o
FUNCTION_DEPLOYMENT_EXE = $(BUILDDIR)/functions_deployment


all: $(FUNCTION_DEPLOYMENT_EXE) $(MAIN_EXE)

print_var:
	@echo $(FUNCTION_OBJS)

$(MAIN_EXE): $(FUNCTION_OBJS) $(MAIN_OBJ)
	@printf "$(BYELLOW)Linking executable $(BCYAN)$@$(RESET)\n"
	$(CC) $(LDFLAGS) $^ $(FUNCTION_OBJS) -o $@ $(LDLIBS)

$(FUNCTION_DEPLOYMENT_EXE): $(LIB_OBJS) $(FUNCTION_DEPLOYMENT_OBJ)
	@printf "$(BYELLOW)Linking executable $(BCYAN)$@$(RESET)\n"
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c Makefile
	@printf "$(BYELLOW)Building object file $(BCYAN)$@$(RESET)\n"
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILDDIR)/%.o: $(LIBDIR)/%.c Makefile
	@printf "$(BYELLOW)Building object file $(BCYAN)$@$(RESET)\n"
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILDDIR)/%.o: $(FUNCTIONDIR)/%.asm Makefile
	@printf "$(BYELLOW)Building object file $(BCYAN)$@$(RESET)\n"
	@mkdir -p $(dir $@)

	$(AS) $(ASFLAGS) $< -o $@ $(LDLIBS)

func: $(FUNCTION_DEPLOYMENT_EXE)
	./$(FUNCTION_DEPLOYMENT_EXE)

touch_function:
	@printf "$(BYELLOW)The implementation of the function $(BCYAN)$(FUNCNAME)$(RESET)\n"
	@mkdir -p $(FUNCTIONDIR)
	@touch $(FUNCTIONDIR)/$(FUNCNAME).asm

run: $(MAIN_EXE) $(FUNCTION_DEPLOYMENT_EXE)  $(FUNCTION_OBJS)
	./$<

clean:
	@printf "$(BYELLOW)Cleaning proccess$(RESET)\n"
	rm -rf $(BUILDDIR)
	rm -rf $(FUNCTIONDIR)

.PHONY: run clean functionn

