# Zig-Snake

## Description

A snake clone in Zig with statically-compiled SDL2

## Purpose

The purpose of making this is to serve 1) as a learning exercize and 2) as a starting point for others who want to learn Zig.

That said, I can't recommend Zig after using it. The entire time I've been making this, I've wanted to use another language like Rust, C++, and C.

Zig is cool in concept and does a lot right in terms of features, but it's my opinion that these features are not executed upon well.

## Build

For the main project you only need a zig compiler.

However, SDL2 requires some dependencies:
- wget (downloading SDL2)
- tar (extracting SDL2)
- cmake (configuring SDL2)
- make (building SDL2)
- gcc (should have this if zig is installed tbf)

With those installed, you just need to run `make`

