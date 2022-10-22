# Author: Dylan Turner
# Description: Build system for snake project

# Settings

## SDL Settings

SDL_SRC_URL :=			https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.24.1.tar.gz
SDL_SRC :=				sdl2.tar.gz
DEF_SDL_FLDR :=			SDL-release-2.24.1/
SDL_FLDR :=				sdl2/

# Project Settings

OBJNAME :=				zig-snake
SRC :=					build.zig \
						${wildcard src/*.zig}
# Targets

## Helper

.PHONY: all
all: ${OBJNAME}

.PHONY: run
run: ${SRC} libSDL2.a
	zig build run

.PHONY: clean
clean:
	rm -rf ${SDL_SRC}
	rm -rf ${SDL_FLDR}
	rm -rf libSDL2.a
	rm -rf zig-out/
	rm -rf zig-cache/
	rm -rf ${OBJNAME}

${SDL_SRC}:
	wget ${SDL_SRC_URL} -O $@

${SDL_FLDR}: ${SDL_SRC}
	tar xfvz $<
	mv ${DEF_SDL_FLDR} $@

libSDL2.a: ${SDL_FLDR}
	cd ${SDL_FLDR}; mkdir -p build
	cd ${SDL_FLDR}build; ../configure
	${MAKE} -C ${SDL_FLDR}build -j${shell nproc}
	cp ${SDL_FLDR}build/build/.libs/libSDL2.a ./$@

# Main

$(OBJNAME): ${SRC} libSDL2.a
	zig build
	cp zig-out/bin/${OBJNAME} ./$@

