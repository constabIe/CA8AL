CC = gcc

CFLAGS = \
		 -Werror \
		 -Wall \
  	 	 -Wfloat-equal \
		 -O2 \
		 -std=gnu99

SOURCES = slv.c

EXECUTABLE = build/slv_c


all: build run 

build: ${SOURCES}
	@mkdir -p $@
	${CC} ${CFLAGS} $< -o ${EXECUTABLE}

run:
	./${EXECUTABLE}

clean:
	rm -rf build

.PHONY: run clean