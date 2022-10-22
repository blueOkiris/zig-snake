# Author: Dylan Turner
# Description: Build system for snake project

# Settings

## SDL Settings

SDL_SRC_URL :=		https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.24.1.tar.gz
SDL_IMG_SRC_URL :=	https://github.com/libsdl-org/SDL_image/archive/refs/tags/release-2.6.2.tar.gz
SDL_SRC :=			sdl2.tar.gz
SDL_IMG_SRC :=		sdl2-img.tar.gz
DEF_SDL_FLDR :=		SDL-release-2.24.1/
DEF_SDL_IMG_FLDR :=	SDL_image-release-2.6.2/
SDL_FLDR :=			sdl2/
SDL_IMG_FLDR :=		sdl2-img/

# Project Settings

OBJNAME :=			zig-snake
SRC :=				build.zig \
					${wildcard src/*.zig} \
					${wildcard src/*.cpp} \
					${wildcard src/*.h}
# Targets

## Helper

.PHONY: all
all: ${OBJNAME}

.PHONY: run
run: ${OBJNAME}
	zig build run

.PHONY: clean
clean:
	rm -rf ${SDL_SRC}
	rm -rf ${SDL_FLDR}
	rm -rf build/
	rm -rf libSDL2.a
	rm -rf zig-out/
	rm -rf zig-cache/
	rm -rf ${OBJNAME}

${SDL_SRC}:
	wget ${SDL_SRC_URL} -O $@

${SDL_IMG_SRC}:
	wget ${SDL_IMG_SRC_URL} -O $@

${SDL_FLDR}: ${SDL_SRC}
	tar xfvz $<
	mv ${DEF_SDL_FLDR} $@

${SDL_IMG_FLDR}: ${SDL_IMG_SRC}
	tar xfvz $<
	mv ${DEF_SDL_IMG_FLDR} $@

libSDL2.a: ${SDL_FLDR}
	cd ${SDL_FLDR}; mkdir -p build
	cd ${SDL_FLDR}build; ../configure
	${MAKE} -C ${SDL_FLDR}build -j${shell nproc}
	cp ${SDL_FLDR}build/build/.libs/libSDL2.a ./$@

libSDL2_image.a: ${SDL_IMG_FLDR}
	cd ${SDL_IMG_FLDR}; mkdir -p build
	cd ${SDL_IMG_FLDR}build; ../configure
	${MAKE} -C ${SDL_IMG_FLDR}build -j${shell nproc}
	cp ${SDL_IMG_FLDR}build/.libs/libSDL2_image.a ./$@

# Main

$(OBJNAME): ${SRC} libSDL2.a libSDL2_image.a
	zig build -Drelease-safe=true
	strip zig-out/bin/${OBJNAME}
	cp zig-out/bin/${OBJNAME} ./$@

