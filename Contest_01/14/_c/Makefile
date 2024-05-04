# CC = g++

# CXXFLAGS = -std=c++17 \
# 		 -Werror \
# 		 -Wall \
# 		 -Wextra \

# SOURCES = slv.cpp

# EXECUTABLE = build/slv_cpp

# all: build run clean

# build: ${SOURCES}
# 	@mkdir -p build
# 	@${CC} ${CXXFLAGS} $< -o ${EXECUTABLE}

# run:
# 	@./${EXECUTABLE}

# clean:
# 	@rm -rf build

# .PHONY: run clean

CC = gcc

CFLAGS = \
		 -Werror \
		 -Wall \
  	 	 -Wfloat-equal \
		 -O2

SOURCES = slv.c

EXECUTABLE = build/slv_c


all: build run 

build: ${SOURCES}
	@mkdir -p $@
	@${CC} ${CFLAGS} $< -o ${EXECUTABLE}

run:
	@./${EXECUTABLE}

clean:
	@rm -rf build

.PHONY: run clean