# Author: Dylan Turner
# Description: Build system for snake project

# Settings

## SDL Settings

SDL_SRC_URL :=		https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.24.1.tar.gz
SDL_IMG_SRC_URL :=	https://github.com/libsdl-org/SDL_image/archive/refs/tags/release-2.6.2.tar.gz
SDL_TTF_SRC_URL :=	https://github.com/libsdl-org/SDL_ttf/archive/refs/tags/release-2.20.0.tar.gz
SDL_SRC :=			sdl2.tar.gz
SDL_IMG_SRC :=		sdl2-img.tar.gz
SDL_TTF_SRC :=		sdl2-ttf.tar.gz
DEF_SDL_FLDR :=		SDL-release-2.24.1/
DEF_SDL_IMG_FLDR :=	SDL_image-release-2.6.2/
DEF_SDL_TTF_FLDR := SDL_ttf-release-2.20.0/
SDL_FLDR :=			sdl2/
SDL_IMG_FLDR :=		sdl2-img/
SDL_TTF_FLDR :=		sdl2-ttf/

## Project Settings

OBJNAME :=			zig-snake
SRC :=				build.zig \
					${wildcard src/*.zig} \
					${wildcard src/*.cpp} \
					${wildcard src/*.h}

## Ubuntu Font

UB_FONT_URL :=		https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip
UB_FONT_FLDR :=		ubuntu-font-family-0.83/
UB_FONT :=			fonts/Ubuntu-R.ttf

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

${SDL_TTF_SRC}:
	wget ${SDL_TTF_SRC_URL} -O $@

${SDL_FLDR}: ${SDL_SRC}
	tar xfvz $<
	mv ${DEF_SDL_FLDR} $@

${SDL_IMG_FLDR}: ${SDL_IMG_SRC}
	tar xfvz $<
	mv ${DEF_SDL_IMG_FLDR} $@

${SDL_TTF_FLDR}: ${SDL_TTF_SRC}
	tar xfvz $<
	mv ${DEF_SDL_TTF_FLDR} $@

${UB_FONT_FLDR}:
	wget ${UB_FONT_URL}
	unzip *.zip

## Main targets

${UB_FONT}: ${UB_FONT_FLDR}
	mkdir -p fonts
	cp ${UB_FONT_FLDR}Ubuntu-R.ttf $@

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

libSDL2_ttf.a: ${SDL_TTF_FLDR}
	cd ${SDL_TTF_FLDR}; mkdir -p build
	cd ${SDL_TTF_FLDR}build; ../configure --disable-freetype-builtin --disable-harfbuzz-builtin
	${MAKE} -C ${SDL_TTF_FLDR}build -j${shell nproc}
	cp ${SDL_TTF_FLDR}build/.libs/libSDL2_ttf.a ./$@

$(OBJNAME): ${SRC} libSDL2.a libSDL2_image.a libSDL2_ttf.a ${UB_FONT}
	zig build -Drelease-safe=true
	strip zig-out/bin/${OBJNAME}
	cp zig-out/bin/${OBJNAME} ./$@

