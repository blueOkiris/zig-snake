// Author: Dylan Turner
// Description: Entry point for game

const std = @import("std");
const sdl = @import("sdl.zig");
const snake = @import("snake.zig");
const err = @import("error.zig");
const settings = @import("settings.zig");

pub fn main() !void {
    if(sdl.init(sdl.INIT_VIDEO) < 0) {
        sdl.log("Unable to initialize SDL: %s", sdl.getError());
        return err.SnakeError.InitFailed;
    }
    defer sdl.quit();

    const window = sdl.createWindow(
        "Snake", 0, 0, settings.WINDOW_WIDTH, settings.WINDOW_HEIGHT, 0
    ) orelse {
        sdl.log("Unable to initialize SDL: %s", sdl.getError());
        return err.SnakeError.InitFailed;
    };
    defer sdl.destroyWindow(window);

    const renderer = sdl.createRenderer(window, -1, sdl.RENDERER_ACCELERATED) orelse {
        sdl.log("Unable to initialize SDL: %s", sdl.getError());
        return err.SnakeError.InitFailed;
    };
    defer sdl.destroyRenderer(renderer);

    _ = sdl.setRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

    if(sdl.imgInit(sdl.INIT_PNG) & sdl.INIT_PNG == 0) {
        sdl.log("Unable to initialize SDL_image: %s", sdl.imgGetError());
        return err.SnakeError.ImgInitFailed;
    }
    defer sdl.imgQuit();

    //const stdout = std.io.getStdOut().writer();

    var player = try snake.Snake.init(renderer);
    defer sdl.destroyTexture(player.spr.tex);

    var quit = false;
    var timer = try std.time.Timer.start();
    var elapsed_time_s: f64 = 0;
    while(!quit) {
        // Handle events always
        var event: sdl.Event = undefined;
        while(sdl.pollEvent(&event) != 0) {
            switch(event.@"type") {
                sdl.QUIT => {
                    quit = true;
                }, else => {}
            }
        }

        // Calculate delta
        const dt_ns = timer.lap();
        const dt_s = @intToFloat(f64, dt_ns) / @intToFloat(f64, std.time.ns_per_s);
        player.update(dt_s);
        // TODO: Game objects

        // Don't render until 1/fps seconds have passed
        elapsed_time_s += dt_s;
        const min_dt_s = 1.0 / @intToFloat(f64, settings.FPS);
        if(elapsed_time_s > min_dt_s) {
            elapsed_time_s = 0;
        
            // Draw to screen
            _ = sdl.renderClear(renderer);
            player.draw(renderer);
            // TODO: Make all the game objects
            _ = sdl.renderPresent(renderer);
        }
    }
}

