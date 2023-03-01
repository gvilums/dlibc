MUSL_DIR = musl

CFLAGS = -nostdlib --sysroot=./musl-install -isystem ./musl-install/include -c -g
CXXFLAGS = $(CFLAGS) 
CC ?= clang-15
CXX ?= clang++-15

LD = clang-15 ./musl-install/lib/crt1.o -nostdlib --sysroot=./musl-install -static -fuse-ld=lld
LIBS = -L ./musl-install/lib -lc 
LIBSXX = $(LIBS) -stdlib=libc++

all: build/test

build:
	mkdir -p build 

musl/config.mak:
	cd musl && CFLAGS="-g" ./configure --prefix="$(shell pwd)/musl-install" --disable-shared 

musl-install: $(shell find $(MUSL_DIR)) $(MUSL_DIR) musl/config.mak
	rm -rf musl-install
	cd musl && make -j 16 && make install -j 16

build/test.o: test.c musl-install | build
	$(CC) $(CFLAGS) test.c -o build/test.o

build/test: build/test.o
	$(LD) $(LDFLAGS) build/test.o $(LIBS) -o build/test
# ./musl-install/bin/musl-gcc test.c -o ./build/test -static -g

build/testxx.o: test.cpp musl-install | build
	$(CXX) $(CXXFLAGS) test.cpp -o build/testxx.o 

build/testxx: build/testxx.o
	$(LD) $(LDFLAGS) build/testxx.o $(LIBSXX) -o build/testxx

run: build/test
	./build/test

trace: build/test
	strace ./build/test

debug: build/test
	gdb ./build/test

clean:
	rm -rf ./build/*

clean-all: clean
	-rm -rf ./musl-install
	-rm -f musl/config.mak
	cd musl && make clean

.PHONY: all run clean clean-all trace debug

