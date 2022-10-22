# Zig-Snake

## Description

A snake clone in Zig with statically-compiled SDL2

## Purpose

The purpose of making this is to serve 1) as a learning exercise and 2) as a starting point for others who want to learn Zig.

That said, I can't recommend Zig after using it. The entire time I've been making it, I've kept yearning to use another language like Rust, C++, C, or Python.

Zig is cool in concept and does a lot right in terms of features, but it's my opinion that these features are not executed upon well. The syntax is, imo, silly, and it really hurts what could be a fantastic language.

I want to like it, but it feels so far from elegant.

## Build

For the main project you only need a zig compiler. It needs to be >0.10 as that's when good timing was introduced.

However, SDL2 requires some dependencies:
- wget (downloading SDL2)
- tar (extracting SDL2)
- cmake (configuring SDL2)
- make (building SDL2)
- gcc (building)

With those installed, you just need to run `make`

