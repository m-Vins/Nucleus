CC = gcc
CFLAGS = -Wall -Wextra


SRCS = $(wildcard *.c)
BIN=$(patsubst %.c, bin/%, $(SRCS))

all: $(BIN) 

bin/% : %.c 
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f bin/*

test: $(BIN)
	@for bin_file in $(BIN); do \
		echo =============== $$bin_file ===============; \
		bash ../utilities/cmp_symbols.sh ./"$$bin_file"; \
		echo; \
	done 

.PHONY:
	all
	clean
	bin