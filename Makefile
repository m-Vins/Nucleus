CXX=g++
CXXFLAGS=-Wall -std=c++11 -O2 -DNDEBUG -fpermissive -I./include
LDFLAGS=-lcapstone -lbfd-multiarch

SRC=$(wildcard src/*.cc)
OBJ=$(patsubst src/%.cc, obj/%.o, $(SRC))
BIN=nucleus

.PHONY: all clean setup test

all: $(BIN)

$(OBJ): | obj

obj:
	@mkdir -p $@

obj/%.o: src/%.cc ./include/%.h
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(BIN): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $(BIN) $(OBJ) $(LDFLAGS)

setup:
	sudo apt install binutils-multiarch-dev libcapstone-dev

build_test:
	$(MAKE) -C test

clean:
	rm -f $(OBJ)
	rm -Rf obj
	rm -f $(BIN)
	# clean test dir

