# No copyright. Vladislav Alenik, 2024

#-----------------------
# Compiler/linker flags
#-----------------------

CC = gcc

BUILDDIR = build
INCLUDEDIR = include
SOURCEDIR = src

CFLAGS = \
	-std=gnu99 \
	-Wall      \
	-Wextra    \
	-O2

LDLIBS = -lm

ifeq (${DEBUG}, 1)
	CFLAGS += -g
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

INCLUDES = ${wildcard ${INCLUDEDIR}/*.h}

CFLAGS += -I ${abspath ${INCLUDES}}

SOURCES = ${wildcard ${SOURCEDIR}/*.c}

OBJECTS = $(patsubst $(SOURCEDIR)/%.c, $(BUILDDIR)/%.o, $(SOURCES))

EXECUTABLE = ${BUILDDIR}/main

#---------------
# Build process
#---------------

default: ${EXECUTABLE}

${EXECUTABLE}: ${OBJECTS}
	@printf "${BYELLOW}Linking executable ${BCYAN}$@${RESET}\n"
	${CC} ${OBJECTS} ${LDFLAGS} -o $@ ${LDLIBS}

${BUILDDIR}/%.o: $(SOURCEDIR)/%.c ${INCLUDES}
	@printf "${BYELLOW}Building object file ${BCYAN}$@${RESET}\n"
	@mkdir -p ${BUILDDIR}
	${CC} -c $< ${CFLAGS} -o $@

#--------------
# Test scripts
#--------------

run: ${EXECUTABLE}
	./$<

#---------------
# Miscellaneous
#---------------

clean:
	@printf "${BYELLOW}Cleaning build and resource directories${RESET}\n"
	rm -rf ${BUILDDIR}

.PHONY: run clean default