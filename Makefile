MUSL_DIR = musl

all: build/test

build:
	mkdir -p build 

musl/config.mak:
	cd musl && CFLAGS="-g" ./configure --prefix="$(shell pwd)/musl-install" --disable-shared 

musl-install: $(shell find $(MUSL_DIR)) $(MUSL_DIR) musl/config.mak
	rm -rf musl-install
	cd musl && make -j 16 && make install -j 16

build/test: test.c musl-install | build
	./musl-install/bin/musl-gcc test.c -o ./build/test -static -g

run: build/test
	./build/test

clean:
	rm -rf ./build/*

clean-all: clean
	-rm -rf ./musl-install
	-rm -f musl/config.mak
	cd musl && make clean

.PHONY: all run clean clean-all
