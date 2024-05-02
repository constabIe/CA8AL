CC  = x86_64-linux-gnu-gcc

CFLAGS = \
	-m32 \
	-Wfatal-errors \
	-no-pie \
	-g

SOURCES = \
	src/macro.c \
	src/benchmark.c

OBJECTS = ${SOURCES:src/%.c=build/%.o}

all: ${EXECUTABLE}

build/%.o: ${SOURCES}
	@mkdir -p build
	${CC} ${CFLAGS} -c $< -o $@

clean:
	rm -rf build
