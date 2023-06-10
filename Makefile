CXX=g++
CXXFLAGS=-Wall -std=c++11 -O2 -DNDEBUG -fpermissive -I./include
LDFLAGS=-lcapstone -lbfd-multiarch

SRC=$(wildcard src/*.cc)
OBJ=$(patsubst src/%.cc, obj/%.o, $(SRC))
BIN=nucleus

.PHONY: all clean setup build_test test

all: $(BIN)

$(OBJ): | obj

obj:
	@mkdir -p $@

obj/%.o: src/%.cc ./include/%.h
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(BIN): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $(BIN) $(OBJ) $(LDFLAGS)

setup:
	sudo apt install binutils-multiarch-dev libcapstone-dev file

build_test:
	$(MAKE) -C test

test: $(BIN) build_test
	@for bin_file in $$(ls ./test/bin); do \
		echo =============== $$bin_file ===============; \
		bash ./utilities/cmp_symbols.sh ./test/bin/"$$bin_file"; \
		echo; \
	done 


clean:
	rm -f $(OBJ)
	rm -Rf obj
	rm -f $(BIN)
	$(MAKE) -C test clean

