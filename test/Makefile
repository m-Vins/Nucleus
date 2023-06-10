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


.PHONY:
	all
	clean
	bin