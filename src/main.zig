// Author: Dylan Turner
// Description: Entry point for game

const std = @import("std");
const sdl = @import("sdl.zig");
const snake = @import("snake.zig");

const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const FPS = 60;

pub fn main() !void {
    if(sdl.init(sdl.INIT_VIDEO) < 0) {
        sdl.log("Unable to initialize SDL: %s", sdl.get_error());
        return error.init_failed;
    }
    defer sdl.quit();

    const window = sdl.create_window("Snake", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0) orelse {
        sdl.log("Unable to initialize SDL: %s", sdl.get_error());
        return error.init_failed;
    };
    defer sdl.destroy_window(window);

    const renderer = sdl.create_renderer(window, -1, sdl.RENDERER_ACCELERATED) orelse {
        sdl.log("Unable to initialize SDL: %s", sdl.get_error());
        return error.init_failed;
    };
    defer sdl.destroy_renderer(renderer);

    _ = sdl.set_render_draw_color(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

    if(sdl.img_init(sdl.INIT_PNG) & sdl.INIT_PNG == 0) {
        sdl.log("Unable to initialize SDL_image: %s", sdl.img_get_error());
        return error.img_init_failed;
    }
    defer sdl.img_quit();

    const head = try snake.SnakeHead.init(renderer);

    var quit = false;
    var last_time_us: i128 = @divTrunc(std.time.nanoTimestamp(), 1000);
    while(!quit) {
        // Handle events always
        var event: sdl.Event = undefined;
        while(sdl.poll_event(&event) != 0) {
            switch(event.@"type") {
                sdl.QUIT => {
                    quit = true;
                }, else => {}
            }
        }

        // Maintain fps
        // 1 / (fps f/s * 1s/1000ms) = 1000/60 ms/f = 1000000/fps us/f
        var min_dt_us: i128 = 1000000 / FPS;
        var new_time_us: i128 = @divTrunc(std.time.nanoTimestamp(), 1000);
        var dt = new_time_us - last_time_us;
        if(dt < min_dt_us) {
            continue; // Don't render until 1/fps seconds have passed
        }

        // Draw to screen
        _ = sdl.render_clear(renderer);
        head.spr.draw(renderer);
        // TODO: Make all the game objects
        _ = sdl.render_present(renderer);
    }
}

