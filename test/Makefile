all: bin test 
	@file bin/test

bin:
	mkdir -p bin

test: test.c
	gcc test.c -o bin/test

clean:
	rm -fr bin

.PHONY:
	all
	clean
	bin