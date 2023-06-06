CC = gcc
CFLAGS = -Wall -Wextra


SRCS = $(wildcard *.c)
BIN=$(patsubst %.c, bin/%, $(SRCS))

all: $(BIN) 
	# @file bin/test

bin/% : %.c 
	mkdir -p bin
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f bin/*

test: $(BIN)
	for bin_file in $(BIN); do \
		bash cmp_symbols.sh ./"$$bin_file"; \
	done 

.PHONY:
	all
	clean
	bin