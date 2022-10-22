// Author: Dylan Turner
// Description: Entry point for game

const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;

pub fn main() !void {
    if(c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDL_InitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Snake", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDL_InitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDL_InitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var quit = false;
    while(!quit) {
        var event: c.SDL_Event = undefined;
        while(c.SDL_PollEvent(&event) != 0) {
            switch(event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                }, else => {}
            }
        }

        _ = c.SDL_RenderClear(renderer);
        // TODO
        _ = c.SDL_RenderPresent(renderer);

        // TODO: Make 60fps
        c.SDL_Delay(17);
    }
}

