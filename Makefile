CXX=g++
CXXFLAGS=-Wall -std=c++11 -O2 -DNDEBUG -fpermissive -I./include
LDFLAGS=-lcapstone -lbfd-multiarch

SRC=$(wildcard src/*.cc)
OBJ=$(patsubst src/%.cc, obj/%.o, $(SRC))
BIN=nucleus

.PHONY: all clean setup build_simple_test simple_test test generate_raw_files\
		test_raw download_all

all: $(BIN)

$(OBJ): | obj

obj:
	@mkdir -p $@

obj/%.o: src/%.cc ./include/%.h
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(BIN): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $(BIN) $(OBJ) $(LDFLAGS)

build_simple_test:
	$(MAKE) -C test/simple_tests

simple_test: $(BIN) 
	@for bin_file in $$(ls ./test/simple_tests/bin); do \
		echo =============== $$bin_file ===============; \
		bash ./utilities/cmp_symbols.sh ./test/simple_tests/bin/"$$bin_file"; \
		echo; \
	done 

test: $(BIN)
	./utilities/test.sh

generate_raw_files:
	./utilities/generate_raw_dataset.sh

test_raw: generate_raw_files
	./utilities/test_raw.sh

download_all:
	./utilities/test_prepare_binaries.sh

clean:
	rm $(OBJ)
	rm -f $(BIN)
	$(MAKE) -C test/simple_tests clean

