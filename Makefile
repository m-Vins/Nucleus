CXX=g++
CXXFLAGS=-Wall -std=c++11 -O2 -DNDEBUG -fpermissive -I./include
LDFLAGS=-lcapstone -lbfd-multiarch

SRC=$(wildcard src/*.cc)
OBJ=$(patsubst src/%.cc, obj/%.o, $(SRC))
BIN=nucleus

.PHONY: all clean setup build_test

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

test: build_test $(BIN)
	$(MAKE) -C test test

clean:
	rm -f $(OBJ)
	rm -Rf obj
	rm -f $(BIN)
	$(MAKE) -C test clean

