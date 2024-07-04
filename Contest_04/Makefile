# x86_64-linux-gnu-gcc
CC  = gcc
AS  = nasm
GDB = gdb

CFLAGS = \
		-m32 \
		-Wall \
		-Werror \
		-Wextra

ASFLAGS = \
		-f elf32 \
		-DUNIX

LDLIBS = -lm
LDFLAGS = \
		-m32 \
		-no-pie \
		-z noexecstack \

ifeq (${DEBUG}, 1)
	CFLAGS += -g
	ASFLAGS += -g
	LDFLAGS += -g
else
	LDFLAGS += -flto
endif

ifeq (${MEMVIEW}, 1)
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

LIBS = $(LIBDIR)/function.c \
		$(LIBDIR)/square.c
LIB_OBJS = $(LIBS:$(LIBDIR)/%.c=$(BUILDDIR)/%.o)

SOURCES = $(SOURCEDIR)/functions_deployment.c \
			$(SOURCEDIR)/main.c
SOURCE_OBJS = $(SOURCES:(SOURCEDIR)/%.c=$(BUILDDIR)/%.o)

FUNCTIONS = $(wildcard $(FUNCTIONDIR)/*.asm)
FUNCTION_OBJS = $(FUNCTIONS:$(FUNCTIONDIR)/%.asm=$(BUILDDIR)/%.o)

CFLAGS += -I $(abspath ${INCLUDEDIR})

MAIN_OBJ = $(BUILDDIR)/main.o
MAIN_EXE = $(BUILDDIR)/main

FUNCTION_DEPLOYMENT_OBJ = $(BUILDDIR)/functions_deployment.o
FUNCTION_DEPLOYMENT_EXE = $(BUILDDIR)/functions_deployment

all: $(MAIN_EXE) $(FUNCTION_DEPLOYMENT_EXE)

$(MAIN_EXE): $(MAIN_OBJ) $(FUNCTION_OBJS)
	@printf "${BYELLOW}Linking executable ${BCYAN}$@${RESET}\n"
	${CC} ${LDFLAGS} $< $(FUNCTION_OBJS) -o $@ ${LDLIBS}

$(FUNCTION_DEPLOYMENT_EXE): $(FUNCTION_DEPLOYMENT_OBJ) $(LIB_OBJS)
	@printf "${BYELLOW}Linking executable ${BCYAN}$@${RESET}\n"
	${CC} ${LDFLAGS} $^ -o $@ $(LDLIBS)

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c Makefile
	@printf "${BYELLOW}Building object file ${BCYAN}$@${RESET}\n"
	@mkdir -p $(dir $@)
	${CC} -c ${CFLAGS} $< -o $@

$(BUILDDIR)/%.o: $(LIBDIR)/%.c Makefile
	@printf "${BYELLOW}Building object file ${BCYAN}$@${RESET}\n"
	@mkdir -p $(dir $@)
	${CC} -c ${CFLAGS} $< -o $@

$(BUILDDIR)/%.o: $(FUNCTIONDIR)/%.asm Makefile
	@printf "${BYELLOW}Building object file ${BCYAN}$@${RESET}\n"
	@mkdir -p ${BUILDDIR}

	${AS} ${ASFLAGS} $< -o $@

run_main: $(MAIN_EXE) $(FUNCTION_DEPLOYMENT_EXE)
	./$(MAIN_EXE)

run_func: $(FUNCTION_DEPLOYMENT_EXE)
	./$(FUNCTION_DEPLOYMENT_EXE)

clean:
	@printf "${BYELLOW}Cleaning proccess${RESET}\n"
	rm -rf ${BUILDDIR}
	rm -rf ${FUNCTIONDIR}


functionn:
	@printf "${BYELLOW}The implementation of the function ${BCYAN}$(FUNCNAME)${RESET}\n"
	@mkdir -p $(FUNCTIONDIR)
	@touch $(FUNCTIONDIR)/$(FUNCNAME).asm

.PHONY: run clean functionn

