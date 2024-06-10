# CC = gcc

# CFLAGS ?= -O2 -g

# CFLAGS += -std=gnu99

# CFLAGS += -Wall \ 
# 			-Werror \ 
# 			-Wformat-security \
# 			-Wignored-qualifiers \
# 			-Winit-self \
# 			-Wswitch-default \
# 			-Wpointer-arith \
# 			-Wtype-limits \
# 			-Wempty-body \
# 			-Wstrict-prototypes \
#  			-Wold-style-declaration \
#  			-Wold-style-definition \
# 			-Wmissing-parameter-type \
# 			-Wmissing-field-initializers \
# 			-Wnested-externs \
# 			-Wstack-usage=4096 \
# 			-Wmissing-prototypes \
# 			-Wfloat-equal \
# 			-Wabsolute-value 

# CFLAGS += -fsanitize=undefined \
# 			-fsanitize-undefined-trap-on-error

# CC += -m32 -no-pie -fno-pie

# SOURCES = slv.c

# EXECUTABLE = build/slv_c

# all: build run 

# build: ${SOURCES}
# 	@mkdir -p $@
# 	${CC} ${CFLAGS} $< -o ${EXECUTABLE}

# run:
# 	./${EXECUTABLE}

# clean:
# 	rm -rf build

# .PHONY: run clean

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
	